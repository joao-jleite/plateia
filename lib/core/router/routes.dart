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

  /// Última etapa do onboarding (fase 06): encontrar amigos. `?review=1` abre
  /// a revisão da importação depois de concluir.
  static const onboardingFollow = '/onboarding/follow';

  static const home = '/home';
  static const search = '/search';
  static const feed = '/feed';
  static const subscribe = '/subscribe';
  static const profile = '/profile';

  /// Meus streamings (fase 07): o que assino, renovação e lembrete.
  static const mySubscriptions = '/subscribe/mine';

  static const settings = '/settings';
  static const editProfile = '/settings/profile';
  static const about = '/settings/about';
  static const blocked = '/settings/blocked';

  /// Importar a Netflix pelo perfil (fase 05) e revisar os duvidosos.
  static const import = '/import';
  static const importReview = '/import/review';

  // ---- rede social (fase 06) -------------------------------------------------
  static const searchUsers = '/search/users';
  static const notifications = '/notifications';
  static const followRequests = '/follow-requests';
  static String activity(String id) => '/activity/$id';

  /// Link de convite compartilhado: abre o perfil (`/u/:username`; o link
  /// real chega como `/plateia/u/:username`, ver [inviteUrl]).
  static String invite(String username) => '/u/$username';

  /// Caminho com que o link de convite chega ao app pelo intent-filter
  /// (o GitHub Pages serve em `/plateia`).
  static String invitePath(String username) => '/plateia/u/$username';

  /// Página pública do convite. Ainda não há domínio nem página web; o link
  /// usa o GitHub Pages do João e vira App Link quando a fase 08 publicar o
  /// `assetlinks.json` lá (até então o Android oferece abrir no app ou no navegador).
  static String inviteUrl(String username) => 'https://joao-jleite.github.io/plateia/u/$username';

  static String title(MediaType type, int tmdbId) => '/title/${type.path}/$tmdbId';

  /// Perfil de alguém pelo @ (o meu é a aba `/profile`).
  static String profileOf(String username) => '/profile/$username';
  static String stats(String username) => '/profile/$username/stats';
  static String followers(String username) => '/profile/$username/followers';
  static String following(String username) => '/profile/$username/following';
  static String list(String id) => '/list/$id';

  static bool isAuth(String location) =>
      location.startsWith(login) || location.startsWith(signup) || location.startsWith(reset);

  static bool isOnboarding(String location) => location.startsWith('/onboarding');
}
