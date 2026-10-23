import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../notifications/presentation/notifications_providers.dart';

/// Barra inferior com as 5 abas (SPEC §4). Cada aba mantém a própria pilha.
/// A aba Feed mostra o contador de notificações não lidas.
class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.shell});

  final StatefulNavigationShell shell;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    return Scaffold(
      body: shell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: shell.currentIndex,
        // Tocar na aba atual volta ao topo dela (initialLocation).
        onDestinationSelected: (i) => shell.goBranch(i, initialLocation: i == shell.currentIndex),
        destinations: [
          const NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Início'),
          const NavigationDestination(icon: Icon(Icons.search), label: 'Buscar'),
          NavigationDestination(
            icon: Badge.count(count: unread, isLabelVisible: unread > 0, child: const Icon(Icons.dynamic_feed_outlined)),
            selectedIcon: Badge.count(count: unread, isLabelVisible: unread > 0, child: const Icon(Icons.dynamic_feed)),
            label: 'Feed',
          ),
          const NavigationDestination(icon: Icon(Icons.subscriptions_outlined), selectedIcon: Icon(Icons.subscriptions), label: 'Assinar'),
          const NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}
