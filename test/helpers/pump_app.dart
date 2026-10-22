import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:watchlog/core/widgets/poster_image.dart';
import 'package:watchlog/dev/fixtures/fixture_auth_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_catalog_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_overrides.dart';
import 'package:watchlog/features/auth/domain/auth_user.dart';
import 'package:watchlog/features/catalog/data/catalog_repository.dart';
import 'package:watchlog/features/title/domain/watch_action.dart';
import 'package:watchlog/features/title/presentation/streaming_launcher.dart';

/// Launcher falso: guarda o que o botão pediu para abrir.
class FakeLauncher implements StreamingLauncher {
  final opened = <WatchAction>[];

  @override
  Future<void> open(WatchAction action) async => opened.add(action);
}

const testUser = AuthUser(id: 'test-user', email: 'teste@plateia.app', displayName: 'Pessoa Teste');

/// Sobe uma tela dentro de ProviderScope + MaterialApp com os repositórios de
/// amostra, sem rede nem latência. [routes] extras recebem navegação por
/// `context.push` (ex.: abrir um título a partir da busca).
Future<FakeLauncher> pumpScreen(
  WidgetTester tester,
  Widget screen, {
  List<Override> overrides = const [],
  Map<String, Widget Function(GoRouterState state)> routes = const {},
  AuthUser? user = testUser,
  CatalogRepository? catalog,
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
          auth: FixtureAuthRepository(initialUser: user, latency: Duration.zero),
          catalog: catalog ?? FixtureCatalogRepository(latency: Duration.zero),
          latency: Duration.zero,
        ),
        imagesEnabledProvider.overrideWithValue(false),
        streamingLauncherProvider.overrideWithValue(launcher),
        ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: router,
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
