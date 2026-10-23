import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../social/presentation/social_providers.dart';
import '../domain/app_notification.dart';
import 'notifications_providers.dart';

/// Notificações in-app (`/notifications`, SPEC §J4.7): seguiu, pediu, aceitou,
/// curtiu, comentou. Não lidas em destaque; "Marcar como lidas" na barra; o
/// pedido para seguir tem Aceitar/Recusar na própria linha.
class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifications = ref.watch(notificationsProvider);
    final hasUnread = notifications.value?.any((n) => n.isUnread) ?? false;

    Future<void> markAll() async {
      final messenger = ScaffoldMessenger.of(context);
      final error = await ref.read(notificationsProvider.notifier).markAllRead();
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para marcar. Desfizemos. ($error)')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notificações'),
        actions: [
          if (hasUnread)
            TextButton(
              key: const Key('mark-all-read'),
              onPressed: () => unawaited(markAll()),
              child: const Text('Marcar como lidas'),
            ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.refresh(notificationsProvider.future),
        child: AsyncView<List<AppNotification>>(
          value: notifications,
          onRetry: () => ref.invalidate(notificationsProvider),
          isEmpty: (l) => l.isEmpty,
          empty: const EmptyView(
            icon: Icons.notifications_none,
            title: 'Nada por aqui ainda',
            subtitle: 'Quando alguém seguir, curtir ou comentar, aparece aqui.',
          ),
          data: (list) {
            final notifier = ref.read(notificationsProvider.notifier);
            return ListView.builder(
              itemCount: list.length + (notifier.hasMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == list.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton(onPressed: notifier.loadMore, child: const Text('Mostrar mais')),
                  );
                }
                return _NotificationTile(notification: list[i]);
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationTile extends ConsumerWidget {
  const _NotificationTile({required this.notification});

  final AppNotification notification;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final n = notification;
    final actor = n.actor;

    void open() {
      unawaited(ref.read(notificationsProvider.notifier).markRead(n.id));
      if (n.activityId != null && (n.kind == NotificationKind.like || n.kind == NotificationKind.comment)) {
        context.push(Routes.activity(n.activityId!));
      } else if (actor != null) {
        context.push(Routes.profileOf(actor.username));
      }
    }

    Future<void> resolveRequest({required bool accept}) async {
      final actorId = n.actorId;
      if (actorId == null) return;
      final messenger = ScaffoldMessenger.of(context);
      final actions = ref.read(socialActionsProvider.notifier);
      final error = accept ? await actions.acceptRequest(actorId) : await actions.rejectRequest(actorId);
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text('Não deu para ${accept ? 'aceitar' : 'recusar'}. ($error)')));
        return;
      }
      // aceitar apaga a notificação do pedido (trigger); recusar a deixa sem ação
      ref.invalidate(notificationsProvider);
      if (accept) messenger.showSnackBar(SnackBar(content: Text('@${actor?.username ?? 'alguém'} agora segue você.')));
    }

    final isRequest = n.kind == NotificationKind.followRequest;
    final when = Text(relativePtBr(n.createdAt), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline));

    // O pedido traz Aceitar/Recusar numa linha própria, abaixo do texto. Um
    // Row com dois botões em `trailing` quebrava no aparelho (Flutter 3.44:
    // o título ficava com 1 caractere de largura); o subtítulo tem largura
    // limitada e nunca disputa espaço com o texto.
    return ListTile(
      key: Key('notification-${n.id}'),
      tileColor: n.isUnread ? theme.colorScheme.primaryContainer.withValues(alpha: 0.25) : null,
      leading: UserAvatar(profile: actor, size: 40),
      isThreeLine: isRequest,
      title: Text.rich(
        TextSpan(children: [
          TextSpan(text: actor == null ? 'Alguém ' : '@${actor.username} ', style: const TextStyle(fontWeight: FontWeight.w600)),
          TextSpan(text: n.phrase),
        ]),
        style: theme.textTheme.bodyMedium,
      ),
      subtitle: !isRequest
          ? when
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                when,
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      FilledButton(
                        key: Key('notif-accept-${n.id}'),
                        // o tema dá minimumSize de largura infinita aos FilledButton (botão de
                        // formulário); num Row isso estoura, então a largura mínima volta a 0
                        style: FilledButton.styleFrom(visualDensity: VisualDensity.compact, minimumSize: const Size(0, 36)),
                        onPressed: () => unawaited(resolveRequest(accept: true)),
                        child: const Text('Aceitar'),
                      ),
                      const SizedBox(width: 8),
                      TextButton(
                        key: Key('notif-reject-${n.id}'),
                        style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                        onPressed: () => unawaited(resolveRequest(accept: false)),
                        child: const Text('Recusar'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
      trailing: n.isUnread ? Icon(Icons.circle, size: 10, color: theme.colorScheme.primary) : null,
      onTap: open,
    );
  }
}
