import '../model/media_type.dart';

/// Caminhos das rotas (SPEC §4). Mantidos num lugar só para o `redirect`
/// e as telas não divergirem.
abstract final class Routes {
  static const splash = '/splash';
  static const login = '/login';
  static const signup = '/signup';
  static const reset = '/reset';
  static const newPassword = '/account/password';

  static const onboardingUsername = '/onboarding/username';
  static const onboardingImport = '/onboarding/import';

  static const home = '/home';
  static const search = '/search';
  static const feed = '/feed';
  static const subscribe = '/subscribe';
  static const profile = '/profile';

  static const settings = '/settings';
  static const editProfile = '/settings/profile';
  static const about = '/settings/about';

  static String title(MediaType type, int tmdbId) => '/title/${type.path}/$tmdbId';

  /// Perfil de alguém pelo @ (o meu é a aba `/profile`).
  static String profileOf(String username) => '/profile/$username';
  static String stats(String username) => '/profile/$username/stats';
  static String list(String id) => '/list/$id';

  static bool isAuth(String location) =>
      location.startsWith(login) || location.startsWith(signup) || location.startsWith(reset);

  static bool isOnboarding(String location) => location.startsWith('/onboarding');
}
