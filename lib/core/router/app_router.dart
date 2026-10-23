import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/auth_providers.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/new_password_screen.dart';
import '../../features/auth/presentation/reset_screen.dart';
import '../../features/auth/presentation/signup_screen.dart';
import '../../features/feed/presentation/activity_screen.dart';
import '../../features/feed/presentation/feed_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/import_netflix/presentation/import_review_screen.dart';
import '../../features/import_netflix/presentation/import_screen.dart';
import '../../features/lists/presentation/list_screen.dart';
import '../../features/notifications/presentation/notifications_screen.dart';
import '../../features/onboarding/presentation/my_profile_provider.dart';
import '../../features/onboarding/presentation/username_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/profile/presentation/stats_screen.dart';
import '../../features/search/presentation/search_screen.dart';
import '../../features/settings/presentation/about_screen.dart';
import '../../features/settings/presentation/blocked_users_screen.dart';
import '../../features/settings/presentation/edit_profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/shell/presentation/app_shell.dart';
import '../../features/shell/presentation/splash_screen.dart';
import '../../features/social/presentation/follow_list_screen.dart';
import '../../features/social/presentation/follow_requests_screen.dart';
import '../../features/social/presentation/onboarding_follow_screen.dart';
import '../../features/social/presentation/social_providers.dart';
import '../../features/social/presentation/user_search_screen.dart';
import '../../features/subscribe/presentation/my_subscriptions_screen.dart';
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
    // caminho desconhecido (link velho, deep link estranho): Início, sem tela vermelha
    onException: (_, _, router) => router.go(Routes.home),
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
      GoRoute(path: Routes.onboardingImport, builder: (_, _) => const ImportScreen(onboarding: true)),
      GoRoute(
        path: Routes.onboardingFollow,
        builder: (_, state) => OnboardingFollowScreen(reviewAfter: state.uri.queryParameters['review'] == '1'),
      ),
      GoRoute(path: Routes.settings, builder: (_, _) => const SettingsScreen()),
      GoRoute(path: Routes.editProfile, builder: (_, _) => const EditProfileScreen()),
      GoRoute(path: Routes.about, builder: (_, _) => const AboutScreen()),
      GoRoute(path: Routes.blocked, builder: (_, _) => const BlockedUsersScreen()),

      // Importar a Netflix pelo perfil e revisar os duvidosos: por cima da aba
      // atual (voltar devolve a quem chamou: configurações ou o resumo).
      GoRoute(path: Routes.import, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const ImportScreen()),
      GoRoute(path: Routes.importReview, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const ImportReviewScreen()),

      // Meus streamings (fase 07): por cima da aba Assinar (e da notificação
      // do lembrete, que abre esta rota direto).
      GoRoute(path: Routes.mySubscriptions, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const MySubscriptionsScreen()),

      // Rede social (fase 06): tudo por cima da aba atual, como o detalhe.
      GoRoute(path: Routes.searchUsers, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const UserSearchScreen()),
      GoRoute(path: Routes.notifications, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const NotificationsScreen()),
      GoRoute(path: Routes.followRequests, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const FollowRequestsScreen()),
      GoRoute(
        path: '/activity/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ActivityScreen(activityId: state.pathParameters['id']!),
      ),
      // Link de convite: só redireciona para o perfil. O intent-filter entrega
      // a URL inteira ao GoRouter, então o caminho real traz o prefixo do
      // GitHub Pages (`/plateia/u/<username>`); `/u/:username` fica para o
      // dia em que houver domínio próprio.
      GoRoute(
        path: '/u/:username',
        redirect: (_, state) => Routes.profileOf(state.pathParameters['username']!),
      ),
      GoRoute(
        path: '/plateia/u/:username',
        redirect: (_, state) => Routes.profileOf(state.pathParameters['username']!),
      ),

      // Perfil de outra pessoa, estatísticas, seguidores e lista: por cima da
      // aba atual, como o detalhe do título (o meu perfil é a aba `/profile`).
      GoRoute(
        path: '/profile/:username',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ProfileScreen(username: state.pathParameters['username']),
      ),
      GoRoute(
        path: '/profile/:username/stats',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => StatsScreen(username: state.pathParameters['username']!),
      ),
      GoRoute(
        path: '/profile/:username/followers',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => FollowListScreen(username: state.pathParameters['username']!, mode: FollowListMode.followers),
      ),
      GoRoute(
        path: '/profile/:username/following',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => FollowListScreen(username: state.pathParameters['username']!, mode: FollowListMode.following),
      ),
      GoRoute(
        path: '/list/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (context, state) => ListScreen(listId: state.pathParameters['id']!),
      ),

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
          StatefulShellBranch(routes: [GoRoute(path: Routes.profile, builder: (_, _) => const ProfileScreen())]),
        ],
      ),
    ],
  );
}
