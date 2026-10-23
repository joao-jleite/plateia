import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:watchlog/core/prefs/preferences.dart';
import 'package:watchlog/core/theme/app_theme.dart';
import 'package:watchlog/core/widgets/poster_image.dart';
import 'package:watchlog/dev/fixtures/fixture_auth_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_catalog_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_import_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_overrides.dart';
import 'package:watchlog/dev/fixtures/fixture_social.dart';
import 'package:watchlog/features/auth/domain/auth_user.dart';
import 'package:watchlog/features/catalog/data/catalog_repository.dart';
import 'package:watchlog/features/feed/data/feed_repository.dart';
import 'package:watchlog/features/import_netflix/presentation/import_providers.dart';
import 'package:watchlog/features/social/presentation/share_profile.dart';
import 'package:watchlog/features/subscribe/data/reminder_scheduler.dart';
import 'package:watchlog/features/subscribe/presentation/subscribe_providers.dart';
import 'package:watchlog/features/title/domain/watch_action.dart';
import 'package:watchlog/features/title/presentation/streaming_launcher.dart';

/// Launcher falso: guarda o que o botão pediu para abrir e o que foi
/// compartilhado (folha nativa não existe no teste).
class FakeLauncher implements StreamingLauncher {
  final opened = <WatchAction>[];
  final shared = <String>[];

  @override
  Future<void> open(WatchAction action) async => opened.add(action);
}

const testUser = AuthUser(id: 'test-user', email: 'teste@plateia.app', displayName: 'Pessoa Teste');

/// Entrar como um dos perfis de amostra (`FixtureDiaryStore.foxer/camila/vini`):
/// o id do usuário é o id do perfil, então o perfil já vem pronto e onboarded.
AuthUser asFixture(String username) {
  final p = FixtureDiaryStore.others[username]!;
  return AuthUser(id: p.id, email: '$username@fixtures.local', displayName: p.displayName);
}

/// Sobe uma tela dentro de ProviderScope + MaterialApp com os repositórios de
/// amostra, sem rede nem latência. [routes] extras recebem navegação por
/// `context.push` (ex.: abrir um título a partir da busca).
Future<FakeLauncher> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  Map<String, Widget Function(GoRouterState state)> routes = const {},
  AuthUser? user = testUser,
  FixtureAuthRepository? auth,
  CatalogRepository? catalog,
  FixtureDiaryStore? diary,
  FixtureSocialStore? social,
  FixtureImportRepository? imports,
  FeedRepository? feed,
  ReminderScheduler? scheduler,
  bool failWrites = false,
}) async {
  final launcher = FakeLauncher();
  final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, _) => screen),
      for (final e in routes.entries) GoRoute(path: e.key, builder: (_, s) => e.value(s)),
    ],
  );
  await tester.pumpWidget(
    ProviderScope(
      // Sem retry automático: um erro proposital no teste não pode deixar timer pendente.
      retry: (_, _) => null,
      overrides: [
        ...fixtureOverrides(
          auth: auth ?? FixtureAuthRepository(initialUser: user, latency: Duration.zero),
          catalog: catalog ?? FixtureCatalogRepository(latency: Duration.zero),
          diary: diary,
          social: social,
          imports: imports,
          feed: feed,
          failWrites: failWrites,
          latency: Duration.zero,
        ),
        imagesEnabledProvider.overrideWithValue(false),
        preferencesProvider.overrideWithValue(MemoryPreferences()),
        streamingLauncherProvider.overrideWithValue(launcher),
        shareTextProvider.overrideWithValue((text) async => launcher.shared.add(text)),
        // sem plugin de notificação no teste: o lembrete fica em memória
        reminderSchedulerProvider.overrideWithValue(scheduler ?? RecordingReminderScheduler()),
        // o isolate do `compute` não termina no tempo falso do testWidgets
        backgroundRunnerProvider.overrideWithValue(inlineRunner),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: router,
        // o tema real do app (escuro), sem google_fonts: o HttpClient do
        // flutter_test devolve 400 e o pacote reportaria erro assíncrono.
        theme: AppTheme.dark(withGoogleFonts: false),
        locale: const Locale('pt', 'BR'),
        supportedLocales: const [Locale('pt', 'BR')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
      ),
    ),
  );
  return launcher;
}
