import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import 'notifications_providers.dart';

/// Sino com o contador de não lidas (AppBar do Feed e do Início).
class NotificationsBell extends ConsumerWidget {
  const NotificationsBell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unread = ref.watch(unreadCountProvider).value ?? 0;
    return IconButton(
      tooltip: 'Notificações',
      icon: Badge.count(
        count: unread,
        isLabelVisible: unread > 0,
        child: Icon(unread > 0 ? Icons.notifications : Icons.notifications_none),
      ),
      onPressed: () => context.push(Routes.notifications),
    );
  }
}
