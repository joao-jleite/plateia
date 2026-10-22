import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/catalog/domain/catalog_models.dart';
import 'package:watchlog/features/diary/domain/entry.dart';

void main() {
  final onePiece = Title(
    id: 't1',
    tmdbId: 37854,
    mediaType: MediaType.tv,
    title: 'One Piece',
    numberOfEpisodes: 1140,
    episodeRunTime: 24,
    seasons: const [
      Season(seasonNumber: 0, name: 'Especiais', episodeCount: 40),
      Season(seasonNumber: 1, name: 'East Blue', episodeCount: 61),
      Season(seasonNumber: 2, name: 'Grand Line', episodeCount: 16),
      Season(seasonNumber: 3, name: 'Alabasta', episodeCount: 50),
    ],
    fetchedAt: DateTime(2026, 10, 22),
  );

  group('isValidRating', () {
    test('meias estrelas de 0,5 a 5', () {
      expect(isValidRating(null), isTrue);
      expect(isValidRating(0.5), isTrue);
      expect(isValidRating(5), isTrue);
      expect(isValidRating(3.5), isTrue);
      expect(isValidRating(4.3), isFalse);
      expect(isValidRating(0), isFalse);
      expect(isValidRating(5.5), isFalse);
    });
  });

  group('episodesWatchedFor', () {
    test('assistindo em T2 E5 soma as temporadas anteriores (ignora especiais)', () {
      expect(episodesWatchedFor(onePiece, status: EntryStatus.watching, season: 2, episode: 5), 61 + 5);
      expect(episodesWatchedFor(onePiece, status: EntryStatus.watching, season: 3, episode: 1), 61 + 16 + 1);
    });

    test('assisti sem progresso = todos os episódios; assistindo sem progresso = null', () {
      expect(episodesWatchedFor(onePiece, status: EntryStatus.watched), 1140);
      expect(episodesWatchedFor(onePiece, status: EntryStatus.watching), isNull);
    });

    test('quero ver nunca conta', () {
      expect(episodesWatchedFor(onePiece, status: EntryStatus.want, season: 1, episode: 1), isNull);
    });
  });

  group('EntryDraft', () {
    test('normalized zera nota e review em "quero ver" e apara a review', () {
      const d = EntryDraft(titleId: 't1', status: EntryStatus.want, rating: 4, review: 'x', hasSpoiler: true);
      final n = d.normalized();
      expect(n.rating, isNull);
      expect(n.review, isNull);
      expect(n.hasSpoiler, isFalse);

      const w = EntryDraft(titleId: 't1', status: EntryStatus.watched, review: '  ótimo  ');
      expect(w.normalized().review, 'ótimo');
      expect(const EntryDraft(titleId: 't1', status: EntryStatus.watched, review: '   ').normalized().review, isNull);
    });

    test('from(null) começa em Assisti com a data de hoje', () {
      final today = DateTime(2026, 10, 22);
      final d = EntryDraft.from(null, titleId: 't1', today: today);
      expect(d.status, EntryStatus.watched);
      expect(d.watchedAt, today);
      expect(d.watchCount, 1);
    });
  });

  group('optimisticEntry', () {
    test('preserva id e origem do registro anterior e aplica o rascunho', () {
      final previous = Entry(
        id: 'e1',
        userId: 'u1',
        titleId: 't1',
        status: EntryStatus.want,
        source: 'netflix_import',
        createdAt: DateTime(2026, 1, 1),
      );
      const draft = EntryDraft(titleId: 't1', status: EntryStatus.watched, rating: 4.5, review: 'bom', watchCount: 2);
      final e = optimisticEntry(previous, draft, userId: 'u1', title: onePiece, now: DateTime(2026, 10, 22));
      expect(e.id, 'e1');
      expect(e.source, 'netflix_import');
      expect(e.createdAt, DateTime(2026, 1, 1));
      expect(e.updatedAt, DateTime(2026, 10, 22));
      expect(e.status, EntryStatus.watched);
      expect(e.rating, 4.5);
      expect(e.watchCount, 2);
      expect(e.title, onePiece);
    });

    test('sem registro anterior gera id provisório', () {
      const draft = EntryDraft(titleId: 't1', status: EntryStatus.want);
      final e = optimisticEntry(null, draft, userId: 'u1');
      expect(e.id, startsWith('pending-'));
      expect(e.source, 'manual');
    });
  });

  test('Entry.fromJson lê a linha do PostgREST com o título embutido', () {
    final e = Entry.fromJson({
      'id': 'e1',
      'user_id': 'u1',
      'title_id': 't1',
      'status': 'watching',
      'rating': 4.5,
      'review': null,
      'has_spoiler': false,
      'watched_at': '2026-10-20',
      'current_season': 21,
      'current_episode': 1050,
      'episodes_watched': 1050,
      'watch_count': 1,
      'source': 'manual',
      'created_at': '2026-10-20T12:00:00+00:00',
      'updated_at': '2026-10-20T12:00:00+00:00',
      'title': {
        'id': 't1',
        'tmdb_id': 37854,
        'media_type': 'tv',
        'title': 'One Piece',
        'genres': ['Animação'],
        'is_anime': true,
        'fetched_at': '2026-10-20T12:00:00+00:00',
      },
    });
    expect(e.status, EntryStatus.watching);
    expect(e.watchedAt, DateTime(2026, 10, 20));
    expect(e.title!.isAnime, isTrue);
    expect(e.isRewatch, isFalse);
  });
}
