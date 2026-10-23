import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../social/domain/social_models.dart';
import '../../social/presentation/social_providers.dart';

/// Configurações → Bloqueados (`/settings/blocked`): a RPC `list_blocked_users`
/// é o único lugar que mostra essas pessoas (a RLS de `profiles` as esconde).
/// Desbloquear é otimista e não refaz follows (SPEC §5.4).
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final blocked = ref.watch(blockedUsersProvider);

    Future<void> unblock(BlockedUser u) async {
      final messenger = ScaffoldMessenger.of(context);
      final error = await ref.read(blockedUsersProvider.notifier).unblock(u.id);
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text('Não deu para desbloquear. Desfizemos. ($error)')));
      } else {
        messenger.showSnackBar(SnackBar(content: Text('@${u.username} desbloqueado. Vocês não voltam a se seguir sozinhos.')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Bloqueados')),
      body: AsyncView<List<BlockedUser>>(
        value: blocked,
        onRetry: () => ref.invalidate(blockedUsersProvider),
        isEmpty: (l) => l.isEmpty,
        empty: const EmptyView(
          icon: Icons.block_outlined,
          title: 'Você não bloqueou ninguém',
          subtitle: 'Bloquear esconde vocês um do outro em tudo: perfil, feed, curtidas, comentários e busca.',
        ),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final u = list[i];
            return ListTile(
              leading: PosterImage(url: u.avatarUrl, width: 40, height: 40, borderRadius: 20, fallbackIcon: Icons.person),
              title: Text(u.nameOrUsername),
              subtitle: Text('@${u.username}'),
              trailing: OutlinedButton(
                key: Key('unblock-${u.id}'),
                // minimumSize 0: o tema dá largura infinita ao OutlinedButton; em trailing estoura
                style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36), visualDensity: VisualDensity.compact),
                onPressed: () => unawaited(unblock(u)),
                child: const Text('Desbloquear'),
              ),
            );
          },
        ),
      ),
    );
  }
}
