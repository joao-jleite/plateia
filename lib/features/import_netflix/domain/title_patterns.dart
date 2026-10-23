/// Padrões de título do CSV da Netflix (docs/decisoes-apis.md; regexes
/// portadas de `research/05_netflix_csv.py`). Uma série aparece uma vez por
/// episódio: "Série: Temporada 2: Nome do episódio". Aqui separamos o nome da
/// série do resto; o agrupamento fica em `grouper.dart`.
library;

enum TitleKind {
  /// "Stranger Things: Temporada 1: Capítulo Um"
  seasonNumbered,

  /// "La Casa de Papel: Parte 2: Episódio 1"
  part,

  /// "Stranger Things: Volume 1: …" (Netflix divide temporadas em volumes)
  volume,

  /// "Olhos que Condenam: Minissérie: Parte Um"
  miniseries,

  /// "Série: Capítulo 3" / "Série: Episódio 3" (sem temporada)
  chapter,

  /// "One Piece: East Blue: Eu sou Luffy!" (anime com arco nomeado) — ou um
  /// filme com dois ":" no nome; o agrupador decide pela repetição.
  namedArc,

  /// Sem estrutura: filme, especial ou título com um só ":" ("Duna: Parte Dois").
  plain,
}

class ParsedTitle {
  const ParsedTitle({
    required this.raw,
    required this.showName,
    required this.kind,
    this.seasonLabel,
    this.episodeTitle,
  });

  final String raw;

  /// O que vai para a busca: nome da série, ou o título inteiro se `plain`.
  final String showName;
  final TitleKind kind;

  /// "Temporada 2", "Parte 1", "Minissérie", "East Blue"…
  final String? seasonLabel;
  final String? episodeTitle;

  bool get isEpisode => kind != TitleKind.plain;

  /// Chave do episódio para contar distintos (reprise do mesmo episódio em
  /// dois dias conta uma vez).
  String get episodeKey => isEpisode ? '${seasonLabel ?? ''}|${episodeTitle ?? ''}' : raw;
}

class _Pattern {
  const _Pattern(this.kind, this.regex, {this.hasEpisode = true});

  final TitleKind kind;
  final RegExp regex;
  final bool hasEpisode;
}

// Do mais ao menos específico (pt-BR, en, es; alguns em fr/de/it por segurança).
final _patterns = <_Pattern>[
  _Pattern(TitleKind.seasonNumbered,
      RegExp(r'^(.+?): (?:Temporada|Season|Series|Saison|Staffel|Stagione) (\d+): (.+)$', caseSensitive: false)),
  _Pattern(TitleKind.part, RegExp(r'^(.+?): (?:Parte|Part) (\d+): (.+)$', caseSensitive: false)),
  _Pattern(TitleKind.volume, RegExp(r'^(.+?): (?:Volume|Vol\.) (\d+): (.+)$', caseSensitive: false)),
  _Pattern(TitleKind.miniseries,
      RegExp(r'^(.+?): (?:Minissérie|Minisserie|Miniserie|Miniseries|Limited Series): (.+)$', caseSensitive: false)),
  _Pattern(TitleKind.chapter,
      RegExp(r'^(.+?): (?:Capítulo|Capitulo|Chapter|Episódio|Episodio|Episode) (\d+)$', caseSensitive: false),
      hasEpisode: false),
  _Pattern(TitleKind.namedArc, RegExp(r'^(.+?): ([^:]+): (.+)$')),
];

ParsedTitle parseTitle(String raw) {
  final title = raw.trim();
  for (final p in _patterns) {
    final m = p.regex.firstMatch(title);
    if (m == null) continue;
    switch (p.kind) {
      case TitleKind.seasonNumbered:
      case TitleKind.part:
      case TitleKind.volume:
        // grupo 2 é o número; o rótulo guarda a palavra original ("Temporada 2")
        final word = title.substring(m.group(1)!.length + 2, title.indexOf(': ', m.group(1)!.length + 2));
        return ParsedTitle(raw: title, showName: m.group(1)!.trim(), kind: p.kind, seasonLabel: word.trim(), episodeTitle: m.group(3)!.trim());
      case TitleKind.miniseries:
        return ParsedTitle(raw: title, showName: m.group(1)!.trim(), kind: p.kind, seasonLabel: 'Minissérie', episodeTitle: m.group(2)!.trim());
      case TitleKind.chapter:
        return ParsedTitle(raw: title, showName: m.group(1)!.trim(), kind: p.kind, episodeTitle: title.substring(m.group(1)!.length + 2).trim());
      case TitleKind.namedArc:
        return ParsedTitle(raw: title, showName: m.group(1)!.trim(), kind: p.kind, seasonLabel: m.group(2)!.trim(), episodeTitle: m.group(3)!.trim());
      case TitleKind.plain:
        break;
    }
  }
  return ParsedTitle(raw: title, showName: title, kind: TitleKind.plain);
}
