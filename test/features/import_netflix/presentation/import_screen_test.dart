import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/dev/fixtures/fixture_auth_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_import_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_netflix_csv.dart';
import 'package:watchlog/features/diary/domain/entry.dart';
import 'package:watchlog/features/import_netflix/data/csv_picker.dart';
import 'package:watchlog/features/import_netflix/presentation/import_providers.dart';
import 'package:watchlog/features/import_netflix/presentation/import_review_screen.dart';
import 'package:watchlog/features/import_netflix/presentation/import_screen.dart';
import 'package:watchlog/features/onboarding/presentation/my_profile_provider.dart';
import 'package:watchlog/features/social/presentation/onboarding_follow_screen.dart';

import '../../../helpers/provider_container_holder.dart';
import '../../../helpers/pump_app.dart';

/// Seletor falso: devolve sempre o mesmo arquivo (ou cancela com null).
class FakeCsvPicker implements CsvPicker {
  FakeCsvPicker(this.bytes, {this.name = 'NetflixViewingHistory.csv'});

  final Uint8List? bytes;
  final String name;
  int picks = 0;

  @override
  Future<PickedCsv?> pick() async {
    picks++;
    return bytes == null ? null : PickedCsv(name: name, bytes: bytes!);
  }
}

({FixtureAuthRepository auth, FixtureDiaryStore store, FixtureImportRepository imports}) harness({bool failWrites = false}) {
  final auth = FixtureAuthRepository(initialUser: testUser, latency: Duration.zero);
  final store = FixtureDiaryStore();
  final imports = FixtureImportRepository(store, auth, latency: Duration.zero, failWrites: failWrites);
  return (auth: auth, store: store, imports: imports);
}

void main() {
  testWidgets('importa o CSV de exemplo; reimportar avisa e não duplica entradas, candidatos nem evento', (tester) async {
    final h = harness();
    final picker = FakeCsvPicker(sampleNetflixCsvBytes());
    await pumpScreen(
      tester,
      const ImportScreen(),
      auth: h.auth,
      diary: h.store,
      imports: h.imports,
      overrides: [csvPickerProvider.overrideWithValue(picker)],
    );
    await tester.pumpAndSettle();
    expect(find.text('Seu perfil pode nascer cheio'), findsOneWidget);
    expect(find.text('Agora não'), findsNothing, reason: 'fora do onboarding não há "Agora não"');

    // 1ª importação
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    expect(find.text('9 títulos importados, 4 para revisar'), findsOneWidget);
    expect(find.text('23 linhas no arquivo → 13 séries e filmes'), findsOneWidget);
    expect(find.text('4 novos no diário, 5 já estavam'), findsOneWidget);
    expect(find.text('Revisar agora (4)'), findsOneWidget);

    final imported = h.imports.importedEntries();
    expect(imported.length, 4, reason: 'The Last of Us, Frieren, Arcanjo Renegado, O Urso');
    final tlou = imported.firstWhere((e) => e.title!.tmdbId == 100088);
    expect(tlou.status, EntryStatus.watched);
    expect(tlou.watchedAt, DateTime(2023, 1, 30), reason: 'data da última reprodução');
    expect(tlou.episodesWatched, 3, reason: 'linhas distintas da série');
    expect(imported.firstWhere((e) => e.title!.tmdbId == 66732, orElse: () => tlou), tlou,
        reason: 'Stranger Things estava em "quero ver" (manual): status não é sobrescrito');
    final opp = h.store.entries[FixtureDiaryStore.key(testUser.id, FixtureDiaryStore.titleByTmdb(872585).id)]!;
    expect(opp.rating, 5);
    expect(opp.watchCount, 2);
    expect(opp.source, 'manual');
    expect(h.imports.imports.single.status, 'done');
    expect(h.imports.imports.single.titlesNew, 4);
    expect(h.imports.importedEvents, 1);
    expect(h.imports.candidates.length, 4);

    // 2ª importação do mesmo arquivo: aviso com a data, nada duplica
    await tester.tap(find.text('Importar outro arquivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    expect(find.text('Arquivo já importado'), findsOneWidget);
    expect(find.textContaining('Você já importou este arquivo em '), findsOneWidget);
    await tester.tap(find.text('Importar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('9 títulos importados, 4 para revisar'), findsOneWidget);
    expect(find.text('0 novos no diário, 9 já estavam'), findsOneWidget);
    expect(h.imports.importedEntries().length, 4, reason: 'entradas não duplicam');
    expect(h.imports.imports.length, 2, reason: 'o histórico guarda as duas importações');
    expect(h.imports.importedEvents, 1, reason: 'sem título novo, sem evento imported');
    expect(h.imports.candidates.length, 4, reason: 'mesmo raw_name não entra de novo');
    expect(picker.picks, 2);

    // 3ª importação depois de resolver um candidato: "para revisar" conta só o que ficou pendente
    final onePiece = h.imports.candidates.firstWhere((c) => c.rawName == 'One Piece');
    // runAsync: o repositório usa Future.delayed, que não anda no tempo falso do testWidgets
    await tester.runAsync(() => h.imports.resolveCandidate(onePiece, onePiece.candidates.first));
    await tester.tap(find.text('Importar outro arquivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Importar de novo'));
    await tester.pumpAndSettle();
    expect(find.text('9 títulos importados, 3 para revisar'), findsOneWidget);
    expect(find.text('Revisar agora (3)'), findsOneWidget);
    expect(h.imports.imports.last.titlesReview, 3);
  });

  testWidgets('cancelar no aviso de "já importado" não grava nada', (tester) async {
    final h = harness();
    final picker = FakeCsvPicker(sampleNetflixCsvBytes());
    await pumpScreen(tester, const ImportScreen(), auth: h.auth, diary: h.store, imports: h.imports,
        overrides: [csvPickerProvider.overrideWithValue(picker)]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Importar outro arquivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(find.text('Seu perfil pode nascer cheio'), findsOneWidget);
    expect(h.imports.imports.length, 1);
    expect(find.text('4 títulos aguardam revisão'), findsOneWidget, reason: 'banner de pendentes na tela inicial');
  });

  testWidgets('arquivo que não é da Netflix mostra o erro e deixa tentar de novo', (tester) async {
    final h = harness();
    final picker = FakeCsvPicker(Uint8List.fromList('Nome,Quando,Onde\nx,y,z\n'.codeUnits));
    await pumpScreen(tester, const ImportScreen(), auth: h.auth, diary: h.store, imports: h.imports,
        overrides: [csvPickerProvider.overrideWithValue(picker)]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Cabeçalho não reconhecido'), findsOneWidget);
    expect(find.text('Escolher arquivo'), findsOneWidget);
    expect(h.imports.imports, isEmpty, reason: 'nada foi criado no servidor');
  });

  testWidgets('cancelar o seletor não faz nada', (tester) async {
    final h = harness();
    await pumpScreen(tester, const ImportScreen(), auth: h.auth, diary: h.store, imports: h.imports,
        overrides: [csvPickerProvider.overrideWithValue(FakeCsvPicker(null))]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    expect(find.text('Seu perfil pode nascer cheio'), findsOneWidget);
    expect(h.imports.imports, isEmpty);
  });

  testWidgets('exportação completa com dois perfis pede o perfil e importa só ele', (tester) async {
    final h = harness();
    final bytes = File('test/fixtures/netflix/viewing_activity.csv').readAsBytesSync();
    await pumpScreen(tester, const ImportScreen(), auth: h.auth, diary: h.store, imports: h.imports,
        overrides: [csvPickerProvider.overrideWithValue(FakeCsvPicker(bytes, name: 'ViewingActivity.csv'))]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    expect(find.text('Qual perfil é o seu?'), findsOneWidget);
    await tester.tap(find.text('João · 2 linhas'));
    await tester.pumpAndSettle();
    // João: Stranger Things (high; estava em "quero ver") + One Piece (medium → revisão)
    expect(find.text('1 título importado, 1 para revisar'), findsOneWidget);
    expect(find.text('Perfil: João'), findsOneWidget);
    expect(find.text('3 linhas ignoradas (trailers, prévias ou sem data)'), findsOneWidget);
    expect(h.imports.candidates.single.rawName, 'One Piece');
    expect(h.imports.candidates.single.candidates.length, 2, reason: 'anime e live action');
  });

  testWidgets('no onboarding: importar, "Revisar depois" segue para encontrar amigos, que conclui o onboarding', (tester) async {
    final h = harness();
    final holder = ProviderContainerHolder();
    await pumpScreen(
      tester,
      Builder(builder: (context) {
        holder.capture(context);
        // no app o router observa o perfil; aqui um Consumer faz esse papel
        return Consumer(builder: (_, ref, _) {
          ref.watch(myProfileProvider);
          return const ImportScreen(onboarding: true);
        });
      }),
      auth: h.auth,
      diary: h.store,
      imports: h.imports,
      overrides: [csvPickerProvider.overrideWithValue(FakeCsvPicker(sampleNetflixCsvBytes()))],
      routes: {
        '/import/review': (_) => const ImportReviewScreen(),
        '/onboarding/follow': (s) => OnboardingFollowScreen(reviewAfter: s.uri.queryParameters['review'] == '1'),
      },
    );
    await tester.pumpAndSettle();
    expect(find.text('Agora não'), findsOneWidget);
    expect(find.text('Usar CSV de exemplo (fixtures)'), findsOneWidget, reason: 'botão só existe com fixtures');
    await tester.tap(find.text('Usar CSV de exemplo (fixtures)'));
    await tester.pumpAndSettle();
    expect(find.text('9 títulos importados, 4 para revisar'), findsOneWidget);
    expect(holder.container.read(myProfileProvider).value?.isOnboarded, isFalse);
    await tester.tap(find.text('Revisar depois'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingFollowScreen), findsOneWidget, reason: 'última etapa: encontrar amigos');
    expect(holder.container.read(myProfileProvider).value?.isOnboarded, isFalse);
    await tester.tap(find.byKey(const Key('onboarding-finish')));
    await tester.pumpAndSettle();
    expect(holder.container.read(myProfileProvider).value?.isOnboarded, isTrue);
  });

  testWidgets('servidor recusa a gravação: a importação falha com aviso e marca failed', (tester) async {
    final h = harness(failWrites: true);
    await pumpScreen(tester, const ImportScreen(), auth: h.auth, diary: h.store, imports: h.imports,
        overrides: [csvPickerProvider.overrideWithValue(FakeCsvPicker(sampleNetflixCsvBytes()))]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Escolher arquivo'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Simulação: o servidor recusou'), findsOneWidget);
    expect(h.imports.importedEntries(), isEmpty);
  });
}
