import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/widgets/async_view.dart';
import '../../notifications/presentation/notifications_bell.dart';
import '../domain/activity.dart';
import '../domain/feed_grouping.dart';
import 'checkin_strip.dart';
import 'feed_item.dart';
import 'feed_providers.dart';

/// Aba Feed (SPEC §J4.3): faixa "assistindo agora" + atividades de quem eu
/// sigo (e minhas), agrupadas por autor e dia, página de 30 com carregamento
/// ao chegar no fim. Curtir é otimista; puxar para atualizar recarrega.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);

    Future<void> like(Activity a) async {
      final messenger = ScaffoldMessenger.of(context);
      final error = await ref.read(feedProvider.notifier).toggleLike(a.id);
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para curtir. Desfizemos. ($error)')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Feed'),
        actions: [
          IconButton(
            tooltip: 'Encontrar pessoas',
            icon: const Icon(Icons.person_search_outlined),
            onPressed: () => context.push(Routes.searchUsers),
          ),
          const NotificationsBell(),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(friendsCheckinsProvider);
          await ref.read(feedProvider.notifier).refresh();
        },
        child: AsyncView<List<Activity>>(
          value: feed,
          onRetry: () => ref.invalidate(feedProvider),
          data: (items) {
            final groups = groupFeed(items);
            final notifier = ref.read(feedProvider.notifier);
            return ListView(
              padding: const EdgeInsets.only(bottom: 24),
              children: [
                const CheckinStrip(),
                if (items.isEmpty)
                  EmptyView(
                    icon: Icons.dynamic_feed_outlined,
                    title: 'Seu feed está vazio',
                    subtitle: 'Siga pessoas para ver o que elas assistem. O que você registrar também aparece aqui.',
                    action: FilledButton.icon(
                      onPressed: () => context.push(Routes.searchUsers),
                      icon: const Icon(Icons.person_search_outlined),
                      label: const Text('Encontrar pessoas'),
                    ),
                  )
                else ...[
                  for (final g in groups) FeedGroupCard(group: g, onLike: (a) => unawaited(like(a))),
                  if (notifier.hasMore) _LoadMore(onVisible: notifier.loadMore),
                ],
              ],
            );
          },
        ),
      ),
    );
  }
}

/// Sentinela no fim da lista: ao ser construída (entrou na tela) pede a
/// próxima página. Mostra o spinner enquanto ela chega.
class _LoadMore extends StatefulWidget {
  const _LoadMore({required this.onVisible});

  final Future<void> Function() onVisible;

  @override
  State<_LoadMore> createState() => _LoadMoreState();
}

class _LoadMoreState extends State<_LoadMore> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) unawaited(widget.onVisible());
    });
  }

  @override
  Widget build(BuildContext context) =>
      const Padding(padding: EdgeInsets.all(16), child: Center(child: CircularProgressIndicator()));
}
