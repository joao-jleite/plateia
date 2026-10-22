import 'dart:async';

import 'package:flutter/material.dart' hide Title;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/async_view.dart';
import '../../catalog/domain/catalog_models.dart';
import '../domain/list_models.dart';
import 'list_edit_dialog.dart';
import 'lists_providers.dart';

/// "Adicionar à lista" (SPEC §J3.5): marca/desmarca o título nas minhas
/// listas e cria uma nova na mesma folha. Tudo otimista.
Future<void> showAddToListSheet(BuildContext context, {required Title title}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    useSafeArea: true,
    builder: (_) => AddToListSheet(title: title),
  );
}

class AddToListSheet extends ConsumerWidget {
  const AddToListSheet({super.key, required this.title});

  final Title title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final lists = ref.watch(myListsProvider);
    final membership = ref.watch(titleListMembershipProvider(title.id));
    final messenger = ScaffoldMessenger.of(context);

    Future<void> toggle(String listId) async {
      final error = await ref.read(titleListMembershipProvider(title.id).notifier).toggle(listId, title: title);
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para salvar. Desfizemos. ($error)')));
    }

    Future<void> createAndAdd() async {
      final draft = await showListEditDialog(context);
      if (draft == null) return;
      try {
        final created = await ref.read(myListsProvider.notifier).create(draft);
        await toggle(created.id);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
      }
    }

    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: Text('Adicionar "${title.title}" à lista', style: theme.textTheme.titleMedium),
          ),
          Flexible(
            child: AsyncView<List<ListModel>>(
              value: lists,
              onRetry: () => ref.invalidate(myListsProvider),
              isEmpty: (l) => l.isEmpty,
              empty: const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Você ainda não tem listas. Crie a primeira abaixo.'),
              ),
              data: (l) => ListView(
                shrinkWrap: true,
                children: [
                  for (final list in l)
                    CheckboxListTile(
                      value: membership.value?.contains(list.id) ?? false,
                      onChanged: list.id.startsWith('pending-') ? null : (_) => unawaited(toggle(list.id)),
                      title: Text(list.name),
                      subtitle: Text([list.countLabel, if (list.isPrivate) 'privada', if (list.isRanked) 'ranqueada'].join(' · ')),
                      secondary: Icon(list.isPrivate ? Icons.lock_outline : Icons.list_alt_outlined),
                    ),
                ],
              ),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.add),
            title: const Text('Nova lista'),
            onTap: () => unawaited(createAndAdd()),
          ),
        ],
      ),
    );
  }
}
