import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/app_notification.dart';

/// Notificações in-app (`notifications`): só o destinatário lê e marca como
/// lida (RLS + grant por coluna em `read_at`, migração 0005). Criadas por
/// trigger; o cliente nunca insere.
abstract class NotificationsRepository {
  static const pageSize = 30;

  Future<List<AppNotification>> page({int offset = 0, int limit = pageSize});
  Future<int> unreadCount();
  Future<void> markAllRead();
  Future<void> markRead(String id);
}

class SupabaseNotificationsRepository implements NotificationsRepository {
  SupabaseNotificationsRepository(this._client);

  final SupabaseClient _client;

  // Dois FKs para profiles (destinatário e quem causou): embed pelo nome da constraint.
  static const _select =
      '*, actor:profiles!notifications_actor_id_fkey(*), activity:activities(*, title:titles(*), list:lists(*)), comment:comments(*)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  @override
  Future<List<AppNotification>> page({int offset = 0, int limit = NotificationsRepository.pageSize}) async {
    final rows = await _client
        .from('notifications')
        .select(_select)
        .eq('user_id', _uid)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return rows.map(AppNotification.fromJson).toList();
  }

  @override
  Future<int> unreadCount() async {
    // `count` exato sem trazer linhas além de uma (range 0..0).
    final res = await _client
        .from('notifications')
        .select('id')
        .eq('user_id', _uid)
        .isFilter('read_at', null)
        .range(0, 0)
        .count(CountOption.exact);
    return res.count;
  }

  @override
  Future<void> markAllRead() async {
    await _client
        .from('notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('user_id', _uid)
        .isFilter('read_at', null);
  }

  @override
  Future<void> markRead(String id) async {
    await _client
        .from('notifications')
        .update({'read_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', id)
        .eq('user_id', _uid);
  }
}
