import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../../feed/presentation/feed_item.dart';
import '../domain/social_models.dart';
import 'social_providers.dart';

/// Pedidos para me seguir (perfil privado): aceitar atualiza o follow para
/// `accepted`; recusar apaga a linha. Otimista com desfazer no erro.
class FollowRequestsScreen extends ConsumerWidget {
  const FollowRequestsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final requests = ref.watch(pendingRequestsProvider);

    Future<void> resolve(FollowRequest r, {required bool accept}) async {
      final messenger = ScaffoldMessenger.of(context);
      final notifier = ref.read(pendingRequestsProvider.notifier);
      final error = accept ? await notifier.accept(r.follower.id) : await notifier.reject(r.follower.id);
      if (error != null) {
        messenger.showSnackBar(SnackBar(content: Text('Não deu para ${accept ? 'aceitar' : 'recusar'}. Desfizemos. ($error)')));
      } else if (accept) {
        messenger.showSnackBar(SnackBar(content: Text('@${r.follower.username} agora segue você.')));
      }
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Pedidos para seguir')),
      body: AsyncView<List<FollowRequest>>(
        value: requests,
        onRetry: () => ref.invalidate(pendingRequestsProvider),
        isEmpty: (l) => l.isEmpty,
        empty: const EmptyView(
          icon: Icons.how_to_reg_outlined,
          title: 'Nenhum pedido pendente',
          subtitle: 'Com o perfil privado, quem quiser seguir você aparece aqui.',
        ),
        data: (list) => ListView.builder(
          itemCount: list.length,
          itemBuilder: (context, i) {
            final r = list[i];
            return UserTile(
              profile: r.follower,
              below: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  FilledButton(
                    key: Key('accept-${r.follower.id}'),
                    // minimumSize 0: o tema dá largura infinita ao FilledButton, que num Row estoura
                    style: FilledButton.styleFrom(visualDensity: VisualDensity.compact, minimumSize: const Size(0, 36)),
                    onPressed: () => unawaited(resolve(r, accept: true)),
                    child: const Text('Aceitar'),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    key: Key('reject-${r.follower.id}'),
                    style: TextButton.styleFrom(visualDensity: VisualDensity.compact),
                    onPressed: () => unawaited(resolve(r, accept: false)),
                    child: const Text('Recusar'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
