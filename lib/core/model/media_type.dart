import 'package:json_annotation/json_annotation.dart';

/// Tipo do título no TMDB e na coluna `titles.media_type` (`movie` | `tv`).
/// Anime não é um tipo: é `tv` (ou `movie`) com `is_anime = true`.
enum MediaType {
  @JsonValue('movie')
  movie,
  @JsonValue('tv')
  tv;

  /// Segmento usado nas rotas (`/title/tv/37854`) e nas URLs do TMDB.
  String get path => name;

  String get labelPtBr => switch (this) {
        MediaType.movie => 'Filme',
        MediaType.tv => 'Série',
      };

  static MediaType? tryParse(String? value) => switch (value) {
        'movie' => MediaType.movie,
        'tv' => MediaType.tv,
        _ => null,
      };
}
