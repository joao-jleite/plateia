import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../onboarding/domain/profile.dart';
import '../domain/social_models.dart';

/// Seguir, pedidos, seguidores, busca de pessoas, bloqueio e denúncia
/// (`follows`, `blocks`, `reports`, `profiles`). Tudo direto no PostgREST com o
/// JWT: a RLS decide o que aparece (docs/ARQUITETURA.md §12). A interface só
/// esconde botões; se algo vazar na tela, o bug é policy + migração.
abstract class SocialRepository {
  /// Minha relação com [targetId].
  Future<FollowStatus> followStatus(String targetId);

  /// Insere o follow; devolve o status que o trigger decidiu (pending/accepted).
  Future<FollowStatus> follow(String targetId);

  /// Deixar de seguir ou cancelar o pedido (mesma linha).
  Future<void> unfollow(String targetId);

  /// [targetId] me segue (aceito)?
  Future<bool> isFollowingMe(String targetId);

  /// Pedidos recebidos (perfil privado).
  Future<List<FollowRequest>> pendingRequests();
  Future<void> acceptRequest(String followerId);
  Future<void> rejectRequest(String followerId);

  Future<List<Profile>> followers(String userId, {int offset = 0, int limit = 60});
  Future<List<Profile>> following(String userId, {int offset = 0, int limit = 60});

  /// Busca por `@` (prefixo) ou nome. Bloqueados nunca aparecem (RLS).
  Future<List<Profile>> searchUsers(String query, {int limit = 20});

  Future<void> block(String userId);
  Future<void> unblock(String userId);
  Future<List<BlockedUser>> blockedUsers();

  Future<void> report({
    required ReportTarget target,
    required String targetId,
    required ReportReason reason,
    String? details,
  });
}

class SupabaseSocialRepository implements SocialRepository {
  SupabaseSocialRepository(this._client);

  final SupabaseClient _client;

  // Dois FKs para profiles em `follows`: o embed precisa do nome da constraint.
  static const _follower = 'follower:profiles!follows_follower_id_fkey(*)';
  static const _followee = 'followee:profiles!follows_followee_id_fkey(*)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  @override
  Future<FollowStatus> followStatus(String targetId) async {
    final row = await _client
        .from('follows')
        .select('status')
        .eq('follower_id', _uid)
        .eq('followee_id', targetId)
        .maybeSingle();
    return FollowStatus.fromDb(row?['status'] as String?);
  }

  @override
  Future<FollowStatus> follow(String targetId) async {
    try {
      final row = await _client
          .from('follows')
          .insert({'follower_id': _uid, 'followee_id': targetId})
          .select('status')
          .single();
      return FollowStatus.fromDb(row['status'] as String?);
    } on PostgrestException catch (e) {
      // já sigo (toque duplo): devolve o que está lá
      if (e.code == '23505') return followStatus(targetId);
      // trigger: bloqueio entre os dois ou perfil inexistente
      if (e.code == '42501') throw AppException('forbidden', 'Não é possível seguir este perfil.', cause: e);
      rethrow;
    }
  }

  @override
  Future<void> unfollow(String targetId) async {
    await _client.from('follows').delete().eq('follower_id', _uid).eq('followee_id', targetId);
  }

  @override
  Future<bool> isFollowingMe(String targetId) async {
    final row = await _client
        .from('follows')
        .select('status')
        .eq('follower_id', targetId)
        .eq('followee_id', _uid)
        .eq('status', 'accepted')
        .maybeSingle();
    return row != null;
  }

  @override
  Future<List<FollowRequest>> pendingRequests() async {
    final rows = await _client
        .from('follows')
        .select('created_at, $_follower')
        .eq('followee_id', _uid)
        .eq('status', 'pending')
        .order('created_at', ascending: false);
    return rows.map(FollowRequest.fromJson).toList();
  }

  @override
  Future<void> acceptRequest(String followerId) async {
    await _client
        .from('follows')
        .update({'status': 'accepted'})
        .eq('follower_id', followerId)
        .eq('followee_id', _uid);
  }

  @override
  Future<void> rejectRequest(String followerId) async {
    await _client.from('follows').delete().eq('follower_id', followerId).eq('followee_id', _uid);
  }

  @override
  Future<List<Profile>> followers(String userId, {int offset = 0, int limit = 60}) async {
    final rows = await _client
        .from('follows')
        .select(_follower)
        .eq('followee_id', userId)
        .eq('status', 'accepted')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return _profilesOf(rows, 'follower');
  }

  @override
  Future<List<Profile>> following(String userId, {int offset = 0, int limit = 60}) async {
    final rows = await _client
        .from('follows')
        .select(_followee)
        .eq('follower_id', userId)
        .eq('status', 'accepted')
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return _profilesOf(rows, 'followee');
  }

  // O embed vem null quando a RLS de profiles esconde a pessoa (bloqueio).
  static List<Profile> _profilesOf(List<Map<String, dynamic>> rows, String key) => [
        for (final r in rows)
          if (r[key] is Map) Profile.fromJson(Map<String, dynamic>.from(r[key] as Map)),
      ];

  @override
  Future<List<Profile>> searchUsers(String query, {int limit = 20}) async {
    final q = normalizeUserQuery(query);
    if (q.isEmpty) return const [];
    // `or` do PostgREST: vírgula, parênteses e aspas separariam os filtros; o
    // normalizador já tirou tudo o que não é letra, número, _ ou espaço.
    final rows = await _client
        .from('profiles')
        .select()
        .or('username.ilike.$q%,display_name.ilike.%$q%')
        .neq('id', _uid)
        .order('username')
        .limit(limit);
    return rows.map(Profile.fromJson).toList();
  }

  @override
  Future<void> block(String userId) async {
    try {
      await _client.from('blocks').insert({'blocker_id': _uid, 'blocked_id': userId});
    } on PostgrestException catch (e) {
      if (e.code == '23505') return; // já bloqueado
      rethrow;
    }
  }

  @override
  Future<void> unblock(String userId) async {
    await _client.from('blocks').delete().eq('blocker_id', _uid).eq('blocked_id', userId);
  }

  @override
  Future<List<BlockedUser>> blockedUsers() async {
    final res = await _client.rpc('list_blocked_users');
    if (res is! List) return const [];
    return [for (final r in res) if (r is Map) BlockedUser.fromJson(Map<String, dynamic>.from(r))];
  }

  @override
  Future<void> report({
    required ReportTarget target,
    required String targetId,
    required ReportReason reason,
    String? details,
  }) async {
    final d = details?.trim();
    await _client.from('reports').insert({
      'reporter_id': _uid,
      'target_type': target.dbValue,
      'target_id': targetId,
      'reason': reason.dbValue,
      'details': (d == null || d.isEmpty) ? null : d,
    });
  }
}

/// Texto da busca de pessoas: minúsculas, sem `@` inicial, só letras, números,
/// `_` e espaço (o que um @ ou um nome podem ter e o filtro `or` aceita sem
/// escape). Vazio = não buscar.
String normalizeUserQuery(String raw) {
  var s = raw.trim().toLowerCase();
  if (s.startsWith('@')) s = s.substring(1);
  s = s.replaceAll(RegExp(r'[^\p{L}\p{N}_ ]', unicode: true), '').trim();
  return s.length < 2 ? '' : s;
}
