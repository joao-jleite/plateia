/// Configuração que chega por `--dart-define`. Nada aqui é segredo: a chave
/// anon/publishable do Supabase é pública por natureza; as chaves de API
/// (TMDB, RapidAPI) ficam só nos secrets das Edge Functions.
///
/// Exemplo:
/// ```
/// flutter run --dart-define=SUPABASE_URL=https://xyz.supabase.co \
///             --dart-define=SUPABASE_ANON_KEY=... \
///             --dart-define=GOOGLE_WEB_CLIENT_ID=....apps.googleusercontent.com
/// ```
/// Para desenvolver sem backend: `--dart-define=BACKEND=fixtures` (nunca em release).
library;

enum BackendKind { supabase, fixtures }

abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');

  /// Aceita a anon key legada (JWT `eyJ…`) ou a publishable key nova
  /// (`sb_publishable_…`); o supabase_flutter 2.18 trata as duas como
  /// `publishableKey`.
  static const supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');

  /// Client ID do tipo **Web** do Google Cloud (o Android usa o Web como
  /// `serverClientId` para o id_token valer no Supabase).
  static const googleWebClientId = String.fromEnvironment('GOOGLE_WEB_CLIENT_ID');

  static const _backend = String.fromEnvironment('BACKEND', defaultValue: 'supabase');

  /// Deep link de volta do OAuth e do e-mail de redefinir senha. Mesmo valor em
  /// `supabase/config.toml` (additional_redirect_urls) e no AndroidManifest.
  static const authCallback = 'io.github.joaojleite.watchlog://login-callback';

  static BackendKind get backend =>
      _backend == 'fixtures' ? BackendKind.fixtures : BackendKind.supabase;

  static bool get hasSupabaseConfig =>
      supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;

  static bool get hasGoogleConfig => googleWebClientId.isNotEmpty;
}
