import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/reset_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/import_placeholder_screen.dart';
import '../../features/onboarding/presentation/my_profile_provider.dart';
import '../../features/onboarding/presentation/username_screen.dart';
import '../../features/profile/presentation/profile_tab_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/splash_screen.dart';
import '../../features/subscribe/presentation/subscribe_screen.dart';
import '../../features/title/presentation/title_screen.dart';
import '../model/media_type.dart';
import 'redirect.dart';
import 'routes.dart';

part 'app_router.g.dart';

/// Acorda o GoRouter quando sessão ou perfil mudam, sem recriar o router
/// (recriar perderia a pilha de navegação).
class RouterRefresh extends ChangeNotifier {
  void poke() => notifyListeners();
}

final rootNavigatorKey = GlobalKey<NavigatorState>(debugLabel: 'root');

@Riverpod(keepAlive: true)
GoRouter appRouter(Ref ref) {
  final refresh = RouterRefresh();
  ref.onDispose(refresh.dispose);
  ref.listen(authStateProvider, (_, _) => refresh.poke());
  ref.listen(myProfileProvider, (_, _) => refresh.poke());

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.home,
    refreshListenable: refresh,
    debugLogDiagnostics: kDebugMode,
    redirect: (context, state) {
      final gate = gateFrom(ref.read(authStateProvider), ref.read(myProfileProvider));
      return computeRedirect(gate: gate, location: state.matchedLocation);
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.login, builder: (_, _) => const LoginScreen()),
      GoRoute(path: Routes.signup, builder: (_, _) => const SignupScreen()),
      GoRoute(path: Routes.reset, builder: (_, _) => const ResetScreen()),
      GoRoute(path: Routes.newPassword, builder: (_, _) => const NewPasswordScreen()),
      GoRoute(path: Routes.onboardingUsername, builder: (_, _) => const UsernameScreen()),
      GoRoute(path: Routes.onboardingImport, builder: (_, _) => const ImportPlaceholderScreen()),
      GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),

      // Detalhe do título abre por cima da aba atual: sub-rota de cada ramo
      // seria o ideal, mas uma rota raiz com o navigator raiz mantém o botão
      // voltar funcionando e evita duplicar a rota em 5 ramos.
      GoRoute(
        path: '/title/:type/:tmdbId',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) {
          final type = MediaType.tryParse(state.pathParameters['type']);
          final id = int.tryParse(state.pathParameters['tmdbId'] ?? '');
          if (type == null || id == null) {
            return const Scaffold(body: Center(child: Text('Título inválido')));
          }
          return TitleScreen(type: type, tmdbId: id);
        },
      ),

      // Shell com 5 abas, cada uma com a própria pilha (docs/ARQUITETURA.md §6).
      StatefulShellRoute.indexedStack(
        builder: (context, state, shell) => AppShell(shell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.home, builder: (_, _) => const HomeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.search, builder: (_, _) => const SearchScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.feed, builder: (_, _) => const FeedScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.subscribe, builder: (_, _) => const SubscribeScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.profile, builder: (_, _) => const ProfileTabScreen())]),
        ],
      ),
    ],
  );
}
