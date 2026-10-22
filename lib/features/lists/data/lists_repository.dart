import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/list_models.dart';

/// Listas (`public.lists` + `public.list_items`). A RLS esconde lista privada
/// de todo mundo menos o dono e lista pública de quem não vê o perfil.
abstract class ListsRepository {
  Future<List<ListModel>> byUser(String userId);
  Future<ListModel?> get(String listId);
  Future<ListModel> create(ListDraft draft);
  Future<ListModel> update(String listId, ListDraft draft);
  Future<void> delete(String listId);

  Future<List<ListItem>> items(String listId);
  Future<void> addItem(String listId, String titleId);
  Future<void> removeItem(String listId, String titleId);

  /// Regrava `position` na ordem dada (0, 1, 2…).
  Future<void> reorder(String listId, List<String> titleIdsInOrder);

  /// Ids das MINHAS listas que já têm o título (para a folha "Adicionar à lista").
  Future<Set<String>> myListIdsContaining(String titleId);
}

class SupabaseListsRepository implements ListsRepository {
  SupabaseListsRepository(this._client);

  final SupabaseClient _client;

  // `list_items(count)` vira [{"count": n}] no JSON; convertido abaixo.
  static const _select = '*, list_items(count)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  static ListModel _fromRow(Map<String, dynamic> row) {
    final counts = row['list_items'];
    var count = 0;
    if (counts is List && counts.isNotEmpty && counts.first is Map) {
      count = (counts.first as Map)['count'] as int? ?? 0;
    }
    return ListModel.fromJson({...row, 'item_count': count}..remove('list_items'));
  }

  @override
  Future<List<ListModel>> byUser(String userId) async {
    final rows = await _client.from('lists').select(_select).eq('user_id', userId).order('updated_at', ascending: false);
    return rows.map(_fromRow).toList();
  }

  @override
  Future<ListModel?> get(String listId) async {
    final row = await _client.from('lists').select(_select).eq('id', listId).maybeSingle();
    return row == null ? null : _fromRow(row);
  }

  @override
  Future<ListModel> create(ListDraft draft) async {
    final error = validateListName(draft.name);
    if (error != null) throw AppException('invalid', error);
    final row = await _client
        .from('lists')
        .insert({
          'user_id': _uid,
          'name': draft.name.trim(),
          'description': _blankToNull(draft.description),
          'is_private': draft.isPrivate,
          'is_ranked': draft.isRanked,
        })
        .select(_select)
        .single();
    return _fromRow(row);
  }

  @override
  Future<ListModel> update(String listId, ListDraft draft) async {
    final error = validateListName(draft.name);
    if (error != null) throw AppException('invalid', error);
    final row = await _client
        .from('lists')
        .update({
          'name': draft.name.trim(),
          'description': _blankToNull(draft.description),
          'is_private': draft.isPrivate,
          'is_ranked': draft.isRanked,
        })
        .eq('id', listId)
        .select(_select)
        .single();
    return _fromRow(row);
  }

  @override
  Future<void> delete(String listId) async {
    await _client.from('lists').delete().eq('id', listId);
  }

  @override
  Future<List<ListItem>> items(String listId) async {
    final rows = await _client
        .from('list_items')
        .select('*, title:titles(*)')
        .eq('list_id', listId)
        .order('position')
        .order('added_at');
    return rows.map(ListItem.fromJson).toList();
  }

  @override
  Future<void> addItem(String listId, String titleId) async {
    // posição = fim da lista
    final last = await _client
        .from('list_items')
        .select('position')
        .eq('list_id', listId)
        .order('position', ascending: false)
        .limit(1)
        .maybeSingle();
    final next = last == null ? 0 : ((last['position'] as int? ?? 0) + 1);
    await _client.from('list_items').upsert(
      {'list_id': listId, 'title_id': titleId, 'position': next},
      onConflict: 'list_id,title_id',
      ignoreDuplicates: true,
    );
  }

  @override
  Future<void> removeItem(String listId, String titleId) async {
    await _client.from('list_items').delete().eq('list_id', listId).eq('title_id', titleId);
  }

  @override
  Future<void> reorder(String listId, List<String> titleIdsInOrder) async {
    if (titleIdsInOrder.isEmpty) return;
    await _client.from('list_items').upsert(
      [
        for (var i = 0; i < titleIdsInOrder.length; i++)
          {'list_id': listId, 'title_id': titleIdsInOrder[i], 'position': i},
      ],
      onConflict: 'list_id,title_id',
    );
  }

  @override
  Future<Set<String>> myListIdsContaining(String titleId) async {
    // `lists!inner` restringe às listas cujo dono sou eu.
    final rows = await _client
        .from('list_items')
        .select('list_id, lists!inner(user_id)')
        .eq('title_id', titleId)
        .eq('lists.user_id', _uid);
    return {for (final r in rows) r['list_id'] as String};
  }

  static String? _blankToNull(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
}
