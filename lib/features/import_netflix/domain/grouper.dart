/// Agrupa as linhas do CSV por série/filme. É o que vai para a Edge Function
/// `import-match` (só nomes, ≤ 100 por chamada) e o que vira `entries`
/// (`episodes_watched` = episódios distintos, `watched_at` = última reprodução).
library;

import '../../../core/model/media_type.dart';
import 'netflix_csv.dart';
import 'text_normalize.dart';
import 'title_patterns.dart';

class ImportGroup {
  const ImportGroup({
    required this.rawName,
    required this.guessedType,
    required this.episodesCount,
    required this.rowsCount,
    required this.firstWatchedAt,
    required this.lastWatchedAt,
    this.seasonLabels = const [],
    this.altQuery,
    this.dominantKind = TitleKind.plain,
  });

  /// Nome da série (ou título do filme) como veio no CSV, sem episódio.
  final String rawName;

  /// `tv` com padrão de temporada; `movie` sem padrão; null quando a estrutura
  /// é ambígua (arco nomeado com uma linha só pode ser um filme com dois ":").
  final MediaType? guessedType;

  /// Episódios distintos (reprise do mesmo episódio conta uma vez). 1 para filme.
  final int episodesCount;
  final int rowsCount;
  final DateTime firstWatchedAt;
  final DateTime lastWatchedAt;
  final List<String> seasonLabels;

  /// Consulta alternativa para a função (o título completo, no caso ambíguo).
  final String? altQuery;
  final TitleKind dominantKind;

  bool get isUncertain => guessedType == null;

  /// Item do corpo de `import-match` (docs/ARQUITETURA.md §9).
  Map<String, Object?> toRequestJson() => {
        'raw_name': rawName,
        'guessed_type': guessedType?.path,
        if (altQuery != null) 'alt_query': altQuery,
      };
}

class _Acc {
  _Acc(this.displayName, this.firstRaw);

  final String displayName;
  final String firstRaw;
  final Map<TitleKind, int> kinds = {};
  final Set<String> episodeKeys = {};
  final Set<String> seasonLabels = {};
  DateTime? first;
  DateTime? last;
  int rows = 0;

  void add(ParsedTitle t, DateTime when) {
    rows++;
    kinds[t.kind] = (kinds[t.kind] ?? 0) + 1;
    episodeKeys.add(t.episodeKey);
    if (t.seasonLabel != null) seasonLabels.add(t.seasonLabel!);
    if (first == null || when.isBefore(first!)) first = when;
    if (last == null || when.isAfter(last!)) last = when;
  }

  bool get structured => kinds.keys.any((k) => k != TitleKind.plain);
}

List<ImportGroup> groupRows(Iterable<ViewingRow> rows) {
  final accs = <String, _Acc>{};
  final plain = <(ParsedTitle, DateTime)>[];

  // 1ª passada: linhas com estrutura de episódio agrupam pela série.
  for (final r in rows) {
    final t = parseTitle(r.title);
    if (!t.isEpisode) {
      plain.add((t, r.watchedAt));
      continue;
    }
    accs.putIfAbsent(normalizeName(t.showName), () => _Acc(t.showName, t.raw)).add(t, r.watchedAt);
  }

  // 2ª passada: título puro cujo prefixo (antes do ":") é uma série já vista
  // ("Stranger Things: Especial") entra na série; o resto é filme.
  for (final (t, at) in plain) {
    String? key;
    final colon = t.raw.indexOf(':');
    if (colon > 0) {
      final prefix = normalizeName(t.raw.substring(0, colon));
      if (accs[prefix]?.structured ?? false) key = prefix;
    }
    key ??= normalizeName(t.raw);
    accs.putIfAbsent(key, () => _Acc(t.showName, t.raw)).add(t, at);
  }

  final groups = <ImportGroup>[];
  for (final acc in accs.values) {
    final kinds = acc.kinds;
    final onlyArc = kinds.keys.every((k) => k == TitleKind.namedArc);
    final structured = acc.structured;
    MediaType? type;
    String? alt;
    if (!structured) {
      type = MediaType.movie;
    } else if (onlyArc && acc.episodeKeys.length < 2) {
      // "X: Y: Z" uma vez só: pode ser anime de um episódio ou filme com dois ":"
      type = null;
      alt = acc.firstRaw;
    } else {
      type = MediaType.tv;
    }
    final dominant = kinds.entries.reduce((a, b) => b.value > a.value ? b : a).key;
    final labels = acc.seasonLabels.toList()..sort(_compareLabels);
    groups.add(ImportGroup(
      rawName: acc.displayName,
      guessedType: type,
      episodesCount: structured ? acc.episodeKeys.length : 1,
      rowsCount: acc.rows,
      firstWatchedAt: acc.first!,
      lastWatchedAt: acc.last!,
      seasonLabels: labels,
      altQuery: alt,
      dominantKind: dominant,
    ));
  }

  // Mais recente primeiro: é a ordem em que a revisão e o resumo fazem sentido.
  groups.sort((a, b) {
    final byDate = b.lastWatchedAt.compareTo(a.lastWatchedAt);
    return byDate != 0 ? byDate : a.rawName.compareTo(b.rawName);
  });
  return groups;
}

final _trailingNumber = RegExp(r'(\d+)\s*$');

/// "Temporada 2" antes de "Temporada 10"; rótulos sem número em ordem alfabética.
int _compareLabels(String a, String b) {
  final na = _trailingNumber.firstMatch(a);
  final nb = _trailingNumber.firstMatch(b);
  if (na != null && nb != null) {
    final pa = a.substring(0, na.start), pb = b.substring(0, nb.start);
    if (pa == pb) return int.parse(na.group(1)!).compareTo(int.parse(nb.group(1)!));
  }
  return a.compareTo(b);
}
