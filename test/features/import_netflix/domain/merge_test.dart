import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/diary/domain/entry.dart';
import 'package:watchlog/features/import_netflix/domain/merge.dart';

Entry entry(
  String titleId, {
  EntryStatus status = EntryStatus.watched,
  String source = 'netflix_import',
  DateTime? watchedAt,
  int? episodesWatched,
  double? rating,
  String? review,
}) =>
    Entry(
      id: 'e-$titleId',
      userId: 'u',
      titleId: titleId,
      status: status,
      source: source,
      watchedAt: watchedAt,
      episodesWatched: episodesWatched,
      rating: rating,
      review: review,
    );

ImportedTitle tv(String id, DateTime last, int eps) =>
    ImportedTitle(titleId: id, mediaType: MediaType.tv, lastWatchedAt: last, episodesCount: eps);
ImportedTitle movie(String id, DateTime last) =>
    ImportedTitle(titleId: id, mediaType: MediaType.movie, lastWatchedAt: last, episodesCount: 1);

void main() {
  final d1 = DateTime(2024, 7, 15);
  final d2 = DateTime(2025, 1, 10);

  test('título novo vira insert watched com source netflix_import; filme sem episodes_watched', () {
    final plan = planMerge([tv('st', d1, 34), movie('opp', d1)], {});
    expect(plan.inserts.length, 2);
    expect(plan.patches, isEmpty);
    final st = plan.inserts.firstWhere((i) => i.titleId == 'st');
    expect(st.toJson('u'), {
      'user_id': 'u',
      'title_id': 'st',
      'status': 'watched',
      'watched_at': '2024-07-15',
      'episodes_watched': 34,
      'source': 'netflix_import',
    });
    final opp = plan.inserts.firstWhere((i) => i.titleId == 'opp');
    expect(opp.toJson('u').containsKey('episodes_watched'), isFalse);
  });

  test('reimportar o mesmo arquivo não muda nada', () {
    final plan = planMerge([tv('st', d1, 34)], {'st': entry('st', watchedAt: d1, episodesWatched: 34)});
    expect(plan.inserts, isEmpty);
    expect(plan.patches, isEmpty);
    expect(plan.untouched, 1);
  });

  test('registro só importado avança data e episódios (nunca recua)', () {
    final existing = {'st': entry('st', watchedAt: d1, episodesWatched: 34)};
    final forward = planMerge([tv('st', d2, 40)], existing);
    expect(forward.patches.single.toJson(), {'watched_at': '2025-01-10', 'episodes_watched': 40});
    final backward = planMerge([tv('st', DateTime(2023, 1, 1), 10)], existing);
    expect(backward.patches, isEmpty);
    expect(backward.untouched, 1);
  });

  test('registro editado à mão (source manual) só preenche o que está vazio', () {
    final rated = entry('st', source: 'manual', watchedAt: d1, episodesWatched: 34, rating: 4.5, review: 'ótima');
    expect(planMerge([tv('st', d2, 40)], {'st': rated}).patches, isEmpty, reason: 'data e episódios manuais ficam');
    final blank = entry('opp', source: 'manual', rating: 5);
    final plan = planMerge([movie('opp', d2)], {'opp': blank});
    expect(plan.patches.single.toJson(), {'watched_at': '2025-01-10'}, reason: 'data vazia é preenchida; nota não aparece no patch');
  });

  test('status diferente de "assisti" (assistindo / quero ver) não é tocado', () {
    final watching = entry('st', status: EntryStatus.watching, source: 'manual');
    final want = entry('opp', status: EntryStatus.want, source: 'manual');
    final plan = planMerge([tv('st', d2, 40), movie('opp', d2)], {'st': watching, 'opp': want});
    expect(plan.inserts, isEmpty);
    expect(plan.patches, isEmpty);
    expect(plan.untouched, 2);
  });

  test('dois nomes do CSV no mesmo título somam episódios e ficam com a data mais recente', () {
    final merged = dedupeImported([tv('op', d1, 61), tv('op', d2, 12)]);
    expect(merged.single.episodesCount, 73);
    expect(merged.single.lastWatchedAt, d2);
    final plan = planMerge([tv('op', d1, 61), tv('op', d2, 12)], {});
    expect(plan.inserts.single.episodesWatched, 73);
  });

  test('dateOnly formata para a coluna date', () {
    expect(dateOnly(DateTime(2024, 1, 5, 23, 59)), '2024-01-05');
  });
}
