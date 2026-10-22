import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/list_models.dart';
import 'list_edit_dialog.dart';
import 'lists_providers.dart';

/// Uma lista (`/list/:id`): itens em ordem, arrastar para reordenar e
/// deslizar para remover (só o dono), editar e apagar. Ranqueada mostra a posição.
class ListScreen extends ConsumerWidget {
  const ListScreen({super.key, required this.listId});

  final String listId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final list = ref.watch(listDetailProvider(listId));
    final uid = ref.watch(authStateProvider).value?.id;
    final model = list.value;
    final isOwner = model != null && model.userId == uid;

    return Scaffold(
      appBar: AppBar(
        title: Text(model?.name ?? 'Lista'),
        actions: [
          if (isOwner) ...[
            IconButton(
              tooltip: 'Editar',
              icon: const Icon(Icons.edit_outlined),
              onPressed: () => unawaited(_edit(context, ref, model)),
            ),
            IconButton(
              tooltip: 'Apagar',
              icon: const Icon(Icons.delete_outline),
              onPressed: () => unawaited(_delete(context, ref, model)),
            ),
          ],
        ],
      ),
      body: AsyncView<ListModel?>(
        value: list,
        onRetry: () => ref.invalidate(listDetailProvider(listId)),
        isEmpty: (l) => l == null,
        empty: const EmptyView(icon: Icons.lock_outline, title: 'Lista indisponível', subtitle: 'Ela não existe mais ou é privada.'),
        data: (l) => _ListBody(list: l!, isOwner: isOwner),
      ),
    );
  }

  Future<void> _edit(BuildContext context, WidgetRef ref, ListModel list) async {
    final draft = await showListEditDialog(
      context,
      initial: ListDraft(name: list.name, description: list.description, isPrivate: list.isPrivate, isRanked: list.isRanked),
    );
    if (draft == null || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(myListsProvider.notifier).edit(list.id, draft);
    if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para salvar. Desfizemos. ($error)')));
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, ListModel list) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Apagar "${list.name}"?'),
        content: const Text('Os títulos continuam no seu diário; só a lista some.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Apagar')),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    final error = await ref.read(myListsProvider.notifier).delete(list.id);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text('Não deu para apagar. ($error)')));
      return;
    }
    if (router.canPop()) router.pop();
  }
}

class _ListBody extends ConsumerWidget {
  const _ListBody({required this.list, required this.isOwner});

  final ListModel list;
  final bool isOwner;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final provider = listItemsProvider(list.id);
    final items = ref.watch(provider);
    final messenger = ScaffoldMessenger.of(context);

    void warn(String? error, String what) {
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para $what. Desfizemos. ($error)')));
    }

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (list.description != null && list.description!.isNotEmpty) ...[
            Text(list.description!, style: theme.textTheme.bodyMedium),
            const SizedBox(height: 8),
          ],
          Wrap(
            spacing: 8,
            children: [
              Chip(label: Text(list.countLabel), visualDensity: VisualDensity.compact),
              if (list.isRanked) const Chip(avatar: Icon(Icons.format_list_numbered, size: 16), label: Text('Ranqueada'), visualDensity: VisualDensity.compact),
              Chip(
                avatar: Icon(list.isPrivate ? Icons.lock_outline : Icons.public, size: 16),
                label: Text(list.isPrivate ? 'Privada' : 'Pública'),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          if (isOwner && list.itemCount > 1)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text('Segure e arraste para reordenar; deslize para remover.', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
            ),
        ],
      ),
    );

    return AsyncView<List<ListItem>>(
      value: items,
      onRetry: () => ref.invalidate(provider),
      data: (l) {
        if (l.isEmpty) {
          return ListView(children: [
            header,
            const EmptyView(icon: Icons.playlist_add, title: 'Lista vazia', subtitle: 'Adicione títulos pela folha Registrar no detalhe.'),
          ]);
        }
        Widget tile(int i) {
          final item = l[i];
          final t = item.title;
          return ListTile(
            key: ValueKey(item.titleId),
            leading: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (list.isRanked)
                  SizedBox(width: 28, child: Text('${i + 1}.', style: theme.textTheme.titleMedium, textAlign: TextAlign.center)),
                PosterImage(url: TmdbImages.poster(t?.posterPath, size: 'w92'), width: 40, height: 60, borderRadius: 6, fallbackLabel: ''),
              ],
            ),
            title: Text(t?.title ?? 'Título', maxLines: 2, overflow: TextOverflow.ellipsis),
            subtitle: Text([
              if (t?.year != null) '${t!.year}',
              if (t != null) (t.isAnime ? 'Anime' : t.mediaType.labelPtBr),
              if (item.note != null && item.note!.isNotEmpty) item.note!,
            ].join(' · ')),
            trailing: isOwner ? ReorderableDragStartListener(index: i, child: const Icon(Icons.drag_handle)) : null,
            onTap: t == null ? null : () => context.push(Routes.title(t.mediaType, t.tmdbId)),
          );
        }

        if (!isOwner) {
          return ListView.builder(itemCount: l.length + 1, itemBuilder: (_, i) => i == 0 ? header : tile(i - 1));
        }
        return ReorderableListView.builder(
          header: header,
          buildDefaultDragHandles: false,
          itemCount: l.length,
          onReorderItem: (oldIndex, newIndex) => unawaited(ref.read(provider.notifier).move(oldIndex, newIndex).then((e) => warn(e, 'reordenar'))),
          itemBuilder: (_, i) => Dismissible(
            key: ValueKey('dismiss-${l[i].titleId}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              color: theme.colorScheme.errorContainer,
              child: Icon(Icons.delete_outline, color: theme.colorScheme.onErrorContainer),
            ),
            onDismissed: (_) => unawaited(ref.read(provider.notifier).remove(l[i].titleId).then((e) => warn(e, 'remover'))),
            child: tile(i),
          ),
        );
      },
    );
  }
}
