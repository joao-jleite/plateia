import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/core/widgets/spoiler_blur.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/features/diary/domain/entry.dart';
import 'package:watchlog/features/diary/presentation/log_sheet.dart';
import 'package:watchlog/features/title/presentation/title_screen.dart';

import '../../../helpers/pump_app.dart';

/// Só o diário do usuário de teste (o store também tem os de @foxer e @camila).
Iterable<Entry> mine(FixtureDiaryStore store) => store.entries.values.where((e) => e.userId == testUser.id);

/// Texto dentro da folha (o botão do detalhe, atrás dela, repete o estado).
Finder inSheet(String text) => find.descendant(of: find.byType(LogSheet), matching: find.text(text));

/// Rola a folha até o alvo e toca.
Future<void> tapInSheet(WidgetTester tester, String text) async {
  final target = inSheet(text);
  await tester.ensureVisible(target);
  await tester.pump();
  await tester.tap(target);
}

void main() {
  const frieren = TitleScreen(type: MediaType.tv, tmdbId: 209867); // sem registro no diário de amostra

  testWidgets('2 toques: Registrar → Assisti grava na hora (otimista) e o botão vira o resumo', (tester) async {
    final store = FixtureDiaryStore(seed: false);
    await pumpScreen(tester, frieren, diary: store);
    await tester.pumpAndSettle();

    expect(find.text('Registrar'), findsOneWidget);
    await tester.tap(find.text('Registrar')); // toque 1
    await tester.pumpAndSettle();
    expect(find.text('Quero ver'), findsOneWidget, reason: 'folha aberta');

    await tester.tap(inSheet('Assisti')); // toque 2
    await tester.pump(); // sem esperar o "servidor": o estado já mudou
    expect(find.text('Assistiu em'), findsOneWidget, reason: 'otimista: registrado antes da resposta');

    await tester.pumpAndSettle();
    final saved = mine(store).where((e) => e.titleId.endsWith('209867'));
    expect(saved, hasLength(1));
    expect(saved.single.status, EntryStatus.watched);
    expect(saved.single.episodesWatched, 28, reason: '"assisti" em série sem progresso conta todos os episódios');
    expect(find.text('hoje'), findsOneWidget);
    expect(inSheet('Fechar'), findsOneWidget, reason: 'nada pendente: o botão só fecha');

    await tapInSheet(tester, 'Fechar');
    await tester.pumpAndSettle();
    expect(find.text('Registrar'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Assisti'), findsOneWidget, reason: 'botão do detalhe mostra o estado');
  });

  testWidgets('o mesmo toque desmarca; "quero ver" esconde nota e review', (tester) async {
    final store = FixtureDiaryStore(seed: false);
    await pumpScreen(tester, frieren, diary: store);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    await tester.tap(inSheet('Quero ver'));
    await tester.pumpAndSettle();
    expect(mine(store).single.status, EntryStatus.want);
    expect(find.byKey(const Key('log-review')), findsNothing, reason: 'quero ver não tem review');
    expect(find.text('Contém spoiler'), findsNothing);

    await tester.tap(inSheet('Quero ver')); // segundo toque no mesmo estado
    await tester.pumpAndSettle();
    expect(mine(store), isEmpty, reason: 'desmarcou: a linha foi apagada');
  });

  testWidgets('nota em meias estrelas grava (e sem estado marca Assisti); tocar de novo limpa', (tester) async {
    final store = FixtureDiaryStore(seed: false);
    await pumpScreen(tester, frieren, diary: store);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('rating-half-9'))); // 4,5
    await tester.pumpAndSettle();
    final entry = mine(store).single;
    expect(entry.status, EntryStatus.watched, reason: 'nota implica ter visto');
    expect(entry.rating, 4.5);
    expect(find.text('4,5'), findsOneWidget);

    await tester.tap(find.byKey(const Key('rating-half-9')));
    await tester.pumpAndSettle();
    expect(mine(store).single.rating, isNull);
    expect(mine(store).single.status, EntryStatus.watched, reason: 'limpar a nota não desmarca');
  });

  testWidgets('review com spoiler: Salvar grava, detalhe mostra borrado até tocar', (tester) async {
    final store = FixtureDiaryStore(seed: false);
    await pumpScreen(tester, frieren, diary: store);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();
    await tester.tap(inSheet('Assisti'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('log-review')));
    await tester.enterText(find.byKey(const Key('log-review')), 'Himmel morre no começo.');
    await tester.pump();
    await tapInSheet(tester, 'Contém spoiler');
    await tester.pump();
    expect(inSheet('Salvar'), findsOneWidget, reason: 'há mudança pendente');
    await tapInSheet(tester, 'Salvar');
    await tester.pumpAndSettle();

    final entry = mine(store).single;
    expect(entry.review, 'Himmel morre no começo.');
    expect(entry.hasSpoiler, isTrue);

    expect(find.text('Sua review'), findsOneWidget);
    expect(find.text('Mostrar spoiler'), findsOneWidget);
    expect(find.byType(SpoilerBlur), findsOneWidget);
    await tester.tap(find.text('Mostrar spoiler'));
    await tester.pumpAndSettle();
    expect(find.text('Mostrar spoiler'), findsNothing);
    expect(find.text('Himmel morre no começo.'), findsOneWidget);
  });

  testWidgets('série assistindo: temporada e episódio calculam os episódios vistos', (tester) async {
    final store = FixtureDiaryStore(seed: false);
    await pumpScreen(tester, const TitleScreen(type: MediaType.tv, tmdbId: 37854), diary: store);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();
    await tester.tap(inSheet('Assistindo'));
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.byKey(const Key('log-season')));
    await tester.tap(find.byKey(const Key('log-season')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('T2 · 16 ep').last);
    await tester.pumpAndSettle();
    await tester.enterText(find.byKey(const Key('log-episode')), '5');
    await tester.pump();
    expect(find.text('66 episódios contados nas suas horas'), findsOneWidget, reason: '61 da T1 + 5');

    await tapInSheet(tester, 'Salvar');
    await tester.pumpAndSettle();
    final entry = mine(store).single;
    expect(entry.currentSeason, 2);
    expect(entry.currentEpisode, 5);
    expect(entry.episodesWatched, 66);
    expect(find.textContaining('T2 E5'), findsOneWidget, reason: 'resumo no detalhe');
  });

  testWidgets('servidor recusa: a interface desfaz e avisa', (tester) async {
    final store = FixtureDiaryStore(seed: false);
    await pumpScreen(tester, frieren, diary: store, failWrites: true);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Registrar'));
    await tester.pumpAndSettle();

    await tester.tap(inSheet('Assisti'));
    await tester.pump(); // otimista: já aparece registrado
    expect(find.text('Assistiu em'), findsOneWidget);

    await tester.pumpAndSettle(); // o "servidor" recusou
    expect(mine(store), isEmpty);
    expect(find.text('Assistiu em'), findsNothing, reason: 'estado voltou ao anterior');
    expect(find.textContaining('Desfizemos a alteração'), findsOneWidget, reason: 'SnackBar');
  });

  testWidgets('registro existente abre com nota, review e "Assisti de novo"; reassistir soma', (tester) async {
    final store = FixtureDiaryStore(); // diário de amostra: Oppenheimer assistido 2× com review
    await pumpScreen(tester, const TitleScreen(type: MediaType.movie, tmdbId: 872585), diary: store);
    await tester.pumpAndSettle();
    expect(find.text('2×'), findsOneWidget);
    expect(find.text('Sua review'), findsOneWidget);
    expect(find.byType(SpoilerBlur), findsOneWidget);
    expect(find.text('Mostrar spoiler'), findsNothing, reason: 'review sem spoiler aparece direto');

    await tester.tap(find.widgetWithText(FilledButton, 'Assisti'));
    await tester.pumpAndSettle();
    expect(inSheet('5'), findsOneWidget, reason: 'nota 5');
    await tapInSheet(tester, 'Assisti de novo (2ª vez)');
    await tester.pumpAndSettle();
    final entry = mine(store).firstWhere((e) => e.titleId.endsWith('872585'));
    expect(entry.watchCount, 3);
    expect(entry.rating, 5, reason: 'reassistir mantém a nota');
  });
}
