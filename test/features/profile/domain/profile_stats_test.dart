import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/diary/domain/entry.dart';
import 'package:watchlog/features/profile/domain/profile_stats.dart';

StatsRow movie({
  EntryStatus status = EntryStatus.watched,
  int? runtime = 120,
  int watchCount = 1,
  List<String> genres = const ['Drama'],
  int? year = 2023,
  List<int> providers = const [],
}) =>
    StatsRow(
      status: status,
      watchCount: watchCount,
      mediaType: MediaType.movie,
      runtimeMinutes: runtime,
      genres: genres,
      year: year,
      providerIds: providers,
    );

StatsRow series({
  EntryStatus status = EntryStatus.watching,
  int? episodesWatched,
  int? episodeRunTime = 24,
  int? numberOfEpisodes = 100,
  int watchCount = 1,
  List<String> genres = const ['Animação'],
  int? year = 1999,
  List<int> providers = const [8],
}) =>
    StatsRow(
      status: status,
      watchCount: watchCount,
      episodesWatched: episodesWatched,
      mediaType: MediaType.tv,
      episodeRunTime: episodeRunTime,
      numberOfEpisodes: numberOfEpisodes,
      genres: genres,
      year: year,
      providerIds: providers,
    );

void main() {
  group('minutesFor', () {
    test('filme: duração × vezes assistidas', () {
      expect(minutesFor(movie(runtime: 181)), 181);
      expect(minutesFor(movie(runtime: 181, watchCount: 2)), 362);
    });

    test('série assistindo: episódios vistos × duração média', () {
      expect(minutesFor(series(episodesWatched: 100, episodeRunTime: 24)), 2400);
    });

    test('série "assisti" sem progresso conta todos os episódios (decisão da fase 04)', () {
      expect(minutesFor(series(status: EntryStatus.watched, numberOfEpisodes: 16, episodeRunTime: 55)), 880);
    });

    test('série assistindo sem progresso não tem como contar', () {
      expect(minutesFor(series(episodesWatched: null)), isNull);
    });

    test('sem duração conhecida → null; "quero ver" → null', () {
      expect(minutesFor(movie(runtime: null)), isNull);
      expect(minutesFor(movie(runtime: 0)), isNull);
      expect(minutesFor(series(episodesWatched: 10, episodeRunTime: null)), isNull);
      expect(minutesFor(movie(status: EntryStatus.want)), isNull);
    });
  });

  group('computeProfileStats', () {
    test('diário vazio', () {
      final s = computeProfileStats(const []);
      expect(s.isEmpty, isTrue);
      expect(s.totalMinutes, 0);
      expect(s.byGenre, isEmpty);
      expect(s.byDecade, isEmpty);
      expect(s.byProvider, isEmpty);
    });

    test('só "quero ver" é vazio para horas, mas conta no total de quero ver', () {
      final s = computeProfileStats([movie(status: EntryStatus.want), movie(status: EntryStatus.want)]);
      expect(s.isEmpty, isTrue);
      expect(s.wantTitles, 2);
      expect(s.byGenre, isEmpty, reason: 'quero ver não entra em gênero');
    });

    test('horas, filmes/séries e reassistidos', () {
      final s = computeProfileStats([
        movie(runtime: 181, watchCount: 2), // 362
        movie(runtime: 167), // 167
        series(episodesWatched: 100, episodeRunTime: 24), // 2400
        series(status: EntryStatus.watched, numberOfEpisodes: 16, episodeRunTime: 55, providers: const [1899]), // 880
        movie(status: EntryStatus.want),
      ]);
      expect(s.totalMinutes, 362 + 167 + 2400 + 880);
      expect(s.totalHours, closeTo(63.48, 0.01));
      expect(s.watchedTitles, 3);
      expect(s.watchingTitles, 1);
      expect(s.wantTitles, 1);
      expect(s.movies, 2);
      expect(s.series, 2);
      expect(s.rewatches, 1);
      expect(s.withoutRuntime, 0);
    });

    test('título sem duração entra nas contagens mas não nas horas', () {
      final s = computeProfileStats([movie(runtime: null, genres: const ['Crime']), movie(runtime: 100)]);
      expect(s.totalMinutes, 100);
      expect(s.watchedTitles, 2);
      expect(s.withoutRuntime, 1);
      expect(s.byGenre.map((b) => b.label), containsAll(['Crime', 'Drama']));
    });

    test('por streaming: conta títulos, não ofertas; ordena por quantidade e desempata pelo id', () {
      final s = computeProfileStats([
        series(providers: const [8, 283]),
        series(providers: const [8, 8]), // repetido na mesma linha conta uma vez
        movie(providers: const [283]),
        movie(providers: const [1899]),
      ]);
      expect(s.byProvider[8]!.count, 2);
      expect(s.byProvider[283]!.count, 2);
      expect(s.byProvider[1899]!.count, 1);
      expect(s.providersRanked.map((e) => e.key).toList(), [8, 283, 1899]);
    });

    test('por gênero: maior primeiro, empate alfabético; gênero vazio ignorado', () {
      final s = computeProfileStats([
        movie(genres: const ['Drama', 'Crime']),
        movie(genres: const ['Drama', '']),
        movie(genres: const ['Aventura']),
      ]);
      expect(s.byGenre.map((b) => '${b.label}:${b.count}').toList(), ['Drama:2', 'Aventura:1', 'Crime:1']);
    });

    test('por década: agrupa o ano e ordena por quantidade, empate pela mais recente', () {
      final s = computeProfileStats([
        movie(year: 2023),
        movie(year: 2024),
        movie(year: 1999),
        movie(year: 2002),
        movie(year: 2008),
        movie(year: null),
      ]);
      expect(s.byDecade.map((b) => '${b.label}:${b.count}').toList(), ['2020:2', '2000:2', '1990:1']);
    });

    test('minutos por balde seguem as horas do título', () {
      final s = computeProfileStats([movie(runtime: 100, genres: const ['Drama']), movie(runtime: 50, genres: const ['Drama'])]);
      expect(s.byGenre.single.minutes, 150);
    });
  });

  group('hoursLabel', () {
    test('menos de uma hora em minutos; horas com milhar pt-BR', () {
      expect(hoursLabel(45), '45 min');
      expect(hoursLabel(60), '1 h');
      expect(hoursLabel(3809), '63 h');
      expect(hoursLabel(1240 * 60), '1.240 h');
      expect(hoursLabel(1234567 * 60), '1.234.567 h');
    });
  });
}
