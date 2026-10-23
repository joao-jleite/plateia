import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/dev/fixtures/fixture_auth_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_import_repository.dart';
import 'package:watchlog/features/diary/domain/entry.dart';
import 'package:watchlog/features/import_netflix/domain/import_models.dart';
import 'package:watchlog/features/import_netflix/presentation/import_review_screen.dart';

import '../../../helpers/pump_app.dart';

/// Semeia a fila de revisão direto nas listas do repositório de amostra: dentro
/// do `testWidgets` não dá para `await` o repositório antes do primeiro pump
/// (o tempo é falso), então nada aqui é assíncrono.
({FixtureAuthRepository auth, FixtureDiaryStore store, FixtureImportRepository imports}) seeded({bool failWrites = false}) {
  final auth = FixtureAuthRepository(initialUser: testUser, latency: Duration.zero);
  final store = FixtureDiaryStore();
  final imports = FixtureImportRepository(store, auth, latency: Duration.zero, failWrites: failWrites);
  final anime = FixtureDiaryStore.titleByTmdb(37854);
  final live = FixtureDiaryStore.titleByTmdb(111110);
  final duna2 = FixtureDiaryStore.titleByTmdb(693134);
  ImportCandidateRow row(String id, String rawName, MediaType type, int episodes, DateTime last, List<ImportCandidate> candidates) =>
      ImportCandidateRow(
        id: id,
        importId: 'import-seed',
        userId: testUser.id,
        rawName: rawName,
        guessedType: type,
        episodesCount: episodes,
        lastWatchedAt: last,
        candidates: candidates,
        createdAt: DateTime(2026, 10, 22),
      );
  imports.candidates.addAll([
    row('cand-op', 'One Piece', MediaType.tv, 12, DateTime(2024, 6, 10), [
      ImportCandidate(titleId: anime.id, tmdbId: 37854, mediaType: MediaType.tv, title: anime.title, year: anime.year, score: 0.8),
      ImportCandidate(titleId: live.id, tmdbId: 111110, mediaType: MediaType.tv, title: live.title, year: live.year, score: 0.8),
    ]),
    row('cand-duna', 'Duna', MediaType.movie, 1, DateTime(2024, 8, 25), [
      ImportCandidate(titleId: duna2.id, tmdbId: 693134, mediaType: MediaType.movie, title: duna2.title, year: duna2.year, score: 0.5),
    ]),
    row('cand-trailer', 'Trailer: Round 6', MediaType.movie, 1, DateTime(2021, 9, 17), const []),
  ]);
  return (auth: auth, store: store, imports: imports);
}

void main() {
  testWidgets('lista os pendentes com 2–3 candidatos; escolher grava a entrada; "Nenhum destes" e "Pular" tiram da fila', (tester) async {
    final h = seeded();
    await pumpScreen(tester, const ImportReviewScreen(), auth: h.auth, diary: h.store, imports: h.imports);
    await tester.pumpAndSettle();

    expect(find.text('3 restantes'), findsOneWidget);
    // mais recente primeiro: Duna (25/08/24), One Piece (10/06/24), Trailer (17/09/21)
    expect(find.text('Duna'), findsOneWidget);
    expect(find.text('Filme · visto em 25/08/2024'), findsOneWidget);
    expect(find.text('12 episódios · último em 10/06/2024'), findsOneWidget);
    expect(find.text('One Piece'), findsNWidgets(3), reason: 'o nome do CSV + os dois candidatos homônimos');
    expect(find.text('1999 · Série'), findsOneWidget);
    expect(find.text('2023 · Série'), findsOneWidget);
    expect(find.text('Não encontramos esse título no catálogo (pode ser um trailer ou extra).'), findsOneWidget);
    expect(find.text('Pular'), findsOneWidget);
    expect(find.text('Nenhum destes'), findsNWidgets(2));

    // escolher o anime grava a entrada com a data e os episódios do CSV
    await tester.tap(find.text('1999 · Série'));
    await tester.pumpAndSettle();
    expect(find.text('2 restantes'), findsOneWidget);
    final anime = FixtureDiaryStore.titleByTmdb(37854);
    final entry = h.store.entries[FixtureDiaryStore.key(testUser.id, anime.id)]!;
    expect(entry.status, EntryStatus.watching, reason: 'One Piece já estava no diário como "assistindo" (semente): status manual não é sobrescrito');
    expect(entry.source, 'manual');
    expect(entry.rating, 4.5, reason: 'nota da semente preservada');
    expect(h.imports.candidates.firstWhere((c) => c.rawName == 'One Piece').resolvedTitleId, anime.id);

    // Duna: "Nenhum destes" pula sem gravar
    await tester.tap(find.text('Nenhum destes'));
    await tester.pumpAndSettle();
    expect(find.text('1 restantes'), findsOneWidget);
    expect(h.imports.candidates.firstWhere((c) => c.rawName == 'Duna').skipped, isTrue);

    // trailer: pular → fila vazia
    await tester.tap(find.text('Pular'));
    await tester.pumpAndSettle();
    expect(find.text('Nada para revisar'), findsOneWidget);
    expect(h.imports.candidates.where((c) => c.isPending), isEmpty);
  });

  testWidgets('escolher um título novo cria a entrada importada', (tester) async {
    final h = seeded();
    await pumpScreen(tester, const ImportReviewScreen(), auth: h.auth, diary: h.store, imports: h.imports);
    await tester.pumpAndSettle();
    await tester.tap(find.text('2023 · Série')); // One Piece live action: não estava no diário
    await tester.pumpAndSettle();
    final live = FixtureDiaryStore.titleByTmdb(111110);
    final entry = h.store.entries[FixtureDiaryStore.key(testUser.id, live.id)]!;
    expect(entry.source, 'netflix_import');
    expect(entry.watchedAt, DateTime(2024, 6, 10));
    expect(entry.episodesWatched, 12);
  });

  testWidgets('servidor recusa: a linha volta e aparece o aviso', (tester) async {
    final h = seeded(failWrites: true);
    await pumpScreen(tester, const ImportReviewScreen(), auth: h.auth, diary: h.store, imports: h.imports);
    await tester.pumpAndSettle();
    expect(find.text('3 restantes'), findsOneWidget);
    await tester.tap(find.text('Nenhum destes').first); // Duna, o primeiro cartão
    await tester.pump();
    expect(find.text('2 restantes'), findsOneWidget, reason: 'otimista: some na hora');
    await tester.pumpAndSettle();
    expect(find.text('3 restantes'), findsOneWidget, reason: 'volta quando o servidor recusa');
    expect(find.textContaining('Não deu para salvar. Desfizemos.'), findsOneWidget);
    expect(find.byType(SnackBar), findsOneWidget);
  });
}
