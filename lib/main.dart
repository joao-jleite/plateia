import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/branding/plateia_mark.dart';
import 'core/config/env.dart';
import 'core/errors/app_exception.dart';
import 'core/prefs/preferences.dart';
import 'core/theme/app_theme.dart';
import 'dev/fixtures/fixture_overrides.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  _installErrorLogging();
  await initializeDateFormatting('pt_BR');

  // Preferências locais (chave "aceito anúncios"…). Se o plugin falhar, o app
  // segue com memória: preferência perdida é melhor que app fechado.
  Preferences prefs;
  try {
    prefs = SharedPrefsPreferences(await SharedPreferences.getInstance());
  } catch (e) {
    debugPrint('[prefs] shared_preferences indisponível: $e');
    prefs = MemoryPreferences();
  }
  final overrides = <Override>[preferencesProvider.overrideWithValue(prefs)];
  switch (Env.backend) {
    case BackendKind.fixtures:
      // Backend de amostra só para desenvolvimento (emulador e testes de
      // widget). Um build de release com isto é erro de quem buildou.
      if (kReleaseMode) {
        runApp(const ConfigErrorApp(
          message: 'Este build foi feito com BACKEND=fixtures. Gere de novo sem esse --dart-define.',
        ));
        return;
      }
      overrides.addAll(fixtureOverrides());
    case BackendKind.supabase:
      if (!Env.hasSupabaseConfig) {
        runApp(const ConfigErrorApp(
          message: 'Faltam SUPABASE_URL e SUPABASE_ANON_KEY.\n\n'
              'Quem gerou este APK precisa compilar com --dart-define=SUPABASE_URL=… '
              '--dart-define=SUPABASE_ANON_KEY=… (docs/RELEASE.md). '
              'Para testar sem backend, use um build profile com --dart-define=BACKEND=fixtures.',
        ));
        return;
      }
      await Supabase.initialize(
        url: Env.supabaseUrl,
        publishableKey: Env.supabaseAnonKey,
        // PKCE é o fluxo seguro para app nativo (OAuth e links de e-mail).
        authOptions: const FlutterAuthClientOptions(authFlowType: AuthFlowType.pkce),
      );
  }

  runApp(
    ProviderScope(
      overrides: overrides,
      // Erro de negócio (4xx das Edge Functions, cota) não se resolve tentando
      // de novo sozinho; rede e 5xx seguem o backoff padrão do Riverpod.
      retry: (count, error) =>
          error is AppException && error.code != 'network' && error.code != 'upstream'
              ? null
              : ProviderContainer.defaultRetry(count, error),
      child: const WatchlogApp(),
    ),
  );
}

/// Monitoramento mínimo de erro (docs/ARQUITETURA.md §15): sem serviço externo
/// por enquanto (Sentry/Crashlytics exigem conta do João; pendência da fase 08),
/// então erro de framework e erro assíncrono não tratado vão para o logcat com
/// o prefixo `[crash]` (`adb logcat -s flutter`), também em release.
void _installErrorLogging() {
  final previous = FlutterError.onError;
  FlutterError.onError = (details) {
    previous?.call(details);
    if (kReleaseMode) debugPrint('[crash] ${details.exceptionAsString()}\n${details.stack}');
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    debugPrint('[crash] $error\n$stack');
    return true; // tratado: não derruba o app
  };
}

/// Tela de erro de configuração: melhor que um crash sem explicação quando o
/// APK foi instalado sem os `--dart-define`. É o que um release sem
/// `SUPABASE_URL` mostra (provado na fase 08) e o que um release com fixtures mostra.
class ConfigErrorApp extends StatelessWidget {
  const ConfigErrorApp({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark(withGoogleFonts: false),
      home: Scaffold(
        body: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const PlateiaMark(size: 96),
                  const SizedBox(height: 20),
                  Builder(
                    builder: (context) => Text(
                      'Este build não está configurado',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SelectableText(message, textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
