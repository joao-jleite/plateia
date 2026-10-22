import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/model/media_type.dart';
import '../../diary/domain/entry.dart';

part 'profile_stats.freezed.dart';
part 'profile_stats.g.dart';

/// Linha da view `entry_stats_rows` (migração 0003): o mínimo que o cálculo
/// das estatísticas precisa de cada entrada do diário.
@freezed
abstract class StatsRow with _$StatsRow {
  const factory StatsRow({
    required EntryStatus status,
    @Default(1) int watchCount,
    int? episodesWatched,
    required MediaType mediaType,
    int? runtimeMinutes,
    int? episodeRunTime,
    int? numberOfEpisodes,
    @Default(<String>[]) List<String> genres,
    int? year,
    @Default(<int>[]) List<int> providerIds,
  }) = _StatsRow;

  factory StatsRow.fromJson(Map<String, dynamic> json) => _$StatsRowFromJson(json);
}

/// Contadores do perfil (`profile_counts(uuid)`).
@freezed
abstract class ProfileCounts with _$ProfileCounts {
  const factory ProfileCounts({
    @Default(0) int followers,
    @Default(0) int following,
    @Default(0) int watched,
    @Default(0) int reviews,
    @Default(0) int lists,
  }) = _ProfileCounts;

  factory ProfileCounts.fromJson(Map<String, dynamic> json) => _$ProfileCountsFromJson(json);
}

/// Um rótulo com contagem, já ordenado para a tela (maior primeiro).
@freezed
abstract class StatBucket with _$StatBucket {
  const factory StatBucket({required String label, required int count, @Default(0) int minutes}) = _StatBucket;
}

/// Resultado do cálculo (SPEC §5.2, "Estatísticas do perfil").
@freezed
abstract class ProfileStats with _$ProfileStats {
  const ProfileStats._();

  const factory ProfileStats({
    @Default(0) int totalMinutes,
    @Default(0) int watchedTitles,
    @Default(0) int watchingTitles,
    @Default(0) int wantTitles,
    @Default(0) int movies,
    @Default(0) int series,
    @Default(0) int rewatches,
    /// Títulos por streaming (id do provider, só assinatura em BR).
    @Default(<int, StatBucket>{}) Map<int, StatBucket> byProvider,
    @Default(<StatBucket>[]) List<StatBucket> byGenre,
    /// Por década de lançamento ("2020", "2010", …), mais recente primeiro.
    @Default(<StatBucket>[]) List<StatBucket> byDecade,
    /// Entradas sem duração conhecida (não entram nas horas).
    @Default(0) int withoutRuntime,
  }) = _ProfileStats;

  double get totalHours => totalMinutes / 60;
  bool get isEmpty => watchedTitles == 0 && watchingTitles == 0;

  /// Streamings ordenados por quantidade de títulos (desempate pelo id).
  List<MapEntry<int, StatBucket>> get providersRanked => byProvider.entries.toList()
    ..sort((a, b) {
      final byCount = b.value.count.compareTo(a.value.count);
      return byCount != 0 ? byCount : a.key.compareTo(b.key);
    });
}

/// Minutos de uma entrada (filme: duração × vezes; série: episódios vistos ×
/// duração média × vezes). Null quando não há dado para calcular.
int? minutesFor(StatsRow row) {
  if (row.status == EntryStatus.want) return null;
  final times = row.watchCount < 1 ? 1 : row.watchCount;
  switch (row.mediaType) {
    case MediaType.movie:
      final rt = row.runtimeMinutes;
      if (rt == null || rt <= 0) return null;
      return rt * times;
    case MediaType.tv:
      final perEp = row.episodeRunTime;
      // "assisti" sem progresso informado = todos os episódios (decisão da fase 04)
      final eps = row.episodesWatched ?? (row.status == EntryStatus.watched ? row.numberOfEpisodes : null);
      if (perEp == null || perEp <= 0 || eps == null || eps <= 0) return null;
      return perEp * eps * times;
  }
}

/// Função pura: agrega as linhas da view em horas, por streaming, por gênero e
/// por década. Só `watched` e `watching` contam; "quero ver" entra só no total.
ProfileStats computeProfileStats(Iterable<StatsRow> rows) {
  var totalMinutes = 0;
  var watched = 0, watching = 0, want = 0, movies = 0, series = 0, rewatches = 0, withoutRuntime = 0;
  final byProvider = <int, ({int count, int minutes})>{};
  final byGenre = <String, ({int count, int minutes})>{};
  final byDecade = <int, ({int count, int minutes})>{};

  void bump<K>(Map<K, ({int count, int minutes})> map, K key, int minutes) {
    final cur = map[key] ?? (count: 0, minutes: 0);
    map[key] = (count: cur.count + 1, minutes: cur.minutes + minutes);
  }

  for (final row in rows) {
    switch (row.status) {
      case EntryStatus.want:
        want++;
        continue;
      case EntryStatus.watched:
        watched++;
      case EntryStatus.watching:
        watching++;
    }
    if (row.mediaType == MediaType.movie) {
      movies++;
    } else {
      series++;
    }
    if (row.watchCount > 1) rewatches += row.watchCount - 1;

    final minutes = minutesFor(row);
    if (minutes == null) {
      withoutRuntime++;
    } else {
      totalMinutes += minutes;
    }
    final m = minutes ?? 0;

    for (final p in row.providerIds.toSet()) {
      bump(byProvider, p, m);
    }
    for (final g in row.genres.map((g) => g.trim()).where((g) => g.isNotEmpty).toSet()) {
      bump(byGenre, g, m);
    }
    if (row.year != null && row.year! > 1800) bump(byDecade, (row.year! ~/ 10) * 10, m);
  }

  List<StatBucket> sorted<K>(Map<K, ({int count, int minutes})> map, String Function(K) label, int Function(K, K) tie) {
    final entries = map.entries.toList()
      ..sort((a, b) {
        final byCount = b.value.count.compareTo(a.value.count);
        return byCount != 0 ? byCount : tie(a.key, b.key);
      });
    return [for (final e in entries) StatBucket(label: label(e.key), count: e.value.count, minutes: e.value.minutes)];
  }

  return ProfileStats(
    totalMinutes: totalMinutes,
    watchedTitles: watched,
    watchingTitles: watching,
    wantTitles: want,
    movies: movies,
    series: series,
    rewatches: rewatches,
    withoutRuntime: withoutRuntime,
    byProvider: {
      for (final e in byProvider.entries) e.key: StatBucket(label: '${e.key}', count: e.value.count, minutes: e.value.minutes),
    },
    byGenre: sorted(byGenre, (g) => g, (a, b) => a.compareTo(b)),
    // décadas: desempate pela mais recente
    byDecade: sorted(byDecade, (d) => '$d', (a, b) => b.compareTo(a)),
  );
}

/// "128 h" ou "45 min"; "1.240 h" com separador de milhar pt-BR.
String hoursLabel(int totalMinutes) {
  if (totalMinutes < 60) return '$totalMinutes min';
  final hours = totalMinutes ~/ 60;
  final s = hours.toString();
  final buf = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) buf.write('.');
    buf.write(s[i]);
  }
  return '$buf h';
}
