import '../model/media_type.dart';

/// URLs de imagem do TMDB. Os `*_path` do banco começam com `/`.
abstract final class TmdbImages {
  static const _base = 'https://image.tmdb.org/t/p';

  static String? poster(String? path, {String size = 'w342'}) =>
      (path == null || path.isEmpty) ? null : '$_base/$size$path';

  static String? backdrop(String? path) => poster(path, size: 'w780');

  /// Logos dos streamings (só para indicar onde o título está).
  static String? logo(String? path) => poster(path, size: 'w92');

  static String? profile(String? path) => poster(path, size: 'w185');

  /// Página "onde assistir" do TMDB (redireciona para a JustWatch). É o último
  /// recurso do botão quando não há link nem busca no streaming (SPEC §5.7).
  static Uri watchPage(MediaType type, int tmdbId) =>
      Uri.parse('https://www.themoviedb.org/${type.path}/$tmdbId/watch?locale=BR');
}
