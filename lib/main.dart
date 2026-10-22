import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:intl/date_symbol_data_local.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/errors/app_exception.dart';
import 'dev/fixtures/fixture_overrides.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('pt_BR');

  final overrides = <Override>[];
  switch (Env.backend) {
    case BackendKind.fixtures:
      // Backend de amostra só para desenvolvimento (emulador e testes de
      // widget). Um build de release com isto é erro de quem buildou.
      if (kReleaseMode) {
        runApp(const _ConfigErrorApp(
          message: 'Este build foi feito com BACKEND=fixtures. Gere de novo sem esse --dart-define.',
        ));
        return;
      }
      overrides.addAll(fixtureOverrides());
    case BackendKind.supabase:
      if (!Env.hasSupabaseConfig) {
        runApp(const _ConfigErrorApp(
          message: 'Faltam SUPABASE_URL e SUPABASE_ANON_KEY.\n\n'
              'Compile com --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=… '
              '(ver docs/PENDENCIAS-JOAO.md) ou, para testar sem backend, --dart-define=BACKEND=fixtures.',
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

/// Tela de erro de configuração: melhor que um crash sem explicação quando o
/// APK foi instalado sem os `--dart-define`.
class _ConfigErrorApp extends StatelessWidget {
  const _ConfigErrorApp({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.settings_suggest_outlined, size: 48),
                const SizedBox(height: 16),
                const Text('Plateia: configuração ausente', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Text(message, textAlign: TextAlign.center),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
