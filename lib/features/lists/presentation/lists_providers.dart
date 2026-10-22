import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../catalog/domain/catalog_models.dart';
import '../data/lists_repository.dart';
import '../domain/list_models.dart';

part 'lists_providers.g.dart';

@Riverpod(keepAlive: true)
ListsRepository listsRepository(Ref ref) =>
    SupabaseListsRepository(ref.watch(supabaseClientProvider));

/// Sobe a cada gravação bem-sucedida em listas (ver `DiaryVersion`).
@Riverpod(keepAlive: true)
class ListsVersion extends _$ListsVersion {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Listas de um perfil (as visíveis para mim). Para as minhas, com ações, use [MyLists].
@riverpod
Future<List<ListModel>> userLists(Ref ref, String userId) {
  ref.watch(listsVersionProvider);
  return ref.watch(listsRepositoryProvider).byUser(userId);
}

/// Minhas listas, com criar/editar/apagar otimistas. Métodos devolvem a
/// mensagem de erro (null = deu certo), como no diário.
@riverpod
class MyLists extends _$MyLists {
  @override
  Future<List<ListModel>> build() async {
    final uid = ref.watch(authStateProvider).value?.id;
    if (uid == null) return const [];
    return ref.watch(listsRepositoryProvider).byUser(uid);
  }

  String get _uid => ref.read(authStateProvider).value?.id ?? '';

  /// Devolve a lista criada (para já adicionar um título nela) ou lança.
  Future<ListModel> create(ListDraft draft) async {
    final error = validateListName(draft.name);
    if (error != null) throw AppException('invalid', error);
    final previous = state;
    final now = DateTime.now();
    final optimistic = ListModel(
      id: 'pending-${now.microsecondsSinceEpoch}',
      userId: _uid,
      name: draft.name.trim(),
      description: draft.description,
      isPrivate: draft.isPrivate,
      isRanked: draft.isRanked,
      createdAt: now,
      updatedAt: now,
    );
    state = AsyncData([optimistic, ...previous.value ?? const []]);
    try {
      final created = await ref.read(listsRepositoryProvider).create(draft);
      state = AsyncData([created, ...(previous.value ?? const [])]);
      ref.read(listsVersionProvider.notifier).bump();
      return created;
    } catch (_) {
      state = previous;
      rethrow;
    }
  }

  Future<String?> edit(String listId, ListDraft draft) async {
    final previous = state;
    state = AsyncData([
      for (final l in previous.value ?? const <ListModel>[])
        if (l.id == listId)
          l.copyWith(name: draft.name.trim(), description: draft.description, isPrivate: draft.isPrivate, isRanked: draft.isRanked)
        else
          l,
    ]);
    try {
      final saved = await ref.read(listsRepositoryProvider).update(listId, draft);
      state = AsyncData([for (final l in state.value ?? const <ListModel>[]) l.id == listId ? saved : l]);
      ref.read(listsVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }

  Future<String?> delete(String listId) async {
    final previous = state;
    state = AsyncData([for (final l in previous.value ?? const <ListModel>[]) if (l.id != listId) l]);
    try {
      await ref.read(listsRepositoryProvider).delete(listId);
      ref.read(listsVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }
}

/// Cabeçalho de uma lista (`/list/:id`). Null = não existe ou não posso ver.
@riverpod
Future<ListModel?> listDetail(Ref ref, String listId) {
  ref.watch(listsVersionProvider);
  return ref.watch(listsRepositoryProvider).get(listId);
}

/// Itens de uma lista, com remover e arrastar otimistas.
@riverpod
class ListItems extends _$ListItems {
  @override
  Future<List<ListItem>> build(String listId) => ref.watch(listsRepositoryProvider).items(listId);

  Future<String?> remove(String titleId) async {
    final previous = state;
    state = AsyncData([for (final i in previous.value ?? const <ListItem>[]) if (i.titleId != titleId) i]);
    try {
      await ref.read(listsRepositoryProvider).removeItem(listId, titleId);
      ref.read(listsVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }

  /// Semântica do `ReorderableListView.onReorderItem`: [newIndex] já é a
  /// posição final (descontado o item retirado).
  Future<String?> move(int oldIndex, int newIndex) async {
    final previous = state;
    final items = [...previous.value ?? const <ListItem>[]];
    if (oldIndex < 0 || oldIndex >= items.length || oldIndex == newIndex) return null;
    final moved = items.removeAt(oldIndex);
    items.insert(newIndex.clamp(0, items.length), moved);
    final renumbered = [for (var i = 0; i < items.length; i++) items[i].copyWith(position: i)];
    state = AsyncData(renumbered);
    try {
      await ref.read(listsRepositoryProvider).reorder(listId, [for (final i in renumbered) i.titleId]);
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }
}

/// Em quais das minhas listas um título já está (folha "Adicionar à lista").
@riverpod
class TitleListMembership extends _$TitleListMembership {
  @override
  Future<Set<String>> build(String titleId) => ref.watch(listsRepositoryProvider).myListIdsContaining(titleId);

  Future<String?> toggle(String listId, {Title? title}) async {
    final previous = state;
    final current = {...previous.value ?? const <String>{}};
    final adding = !current.contains(listId);
    if (adding) {
      current.add(listId);
    } else {
      current.remove(listId);
    }
    state = AsyncData(current);
    try {
      final repo = ref.read(listsRepositoryProvider);
      if (adding) {
        await repo.addItem(listId, titleId);
      } else {
        await repo.removeItem(listId, titleId);
      }
      ref.read(listsVersionProvider.notifier).bump();
      ref.invalidate(listItemsProvider(listId));
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }
}
