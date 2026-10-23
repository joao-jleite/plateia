import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../social/presentation/social_providers.dart';
import '../data/notifications_repository.dart';
import '../domain/app_notification.dart';

part 'notifications_providers.g.dart';

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
@Riverpod(keepAlive: true)
NotificationsRepository notificationsRepository(Ref ref) =>
    SupabaseNotificationsRepository(ref.watch(supabaseClientProvider));

/// Sobe quando notificações são marcadas como lidas (o contador observa).
@Riverpod(keepAlive: true)
class NotificationsVersion extends _$NotificationsVersion {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Não lidas, para o badge no sino. keepAlive: a shell observa o tempo todo;
/// recarrega quando a rede muda ou algo é marcado como lido.
@Riverpod(keepAlive: true)
Future<int> unreadCount(Ref ref) {
  // keepAlive sobrevive ao sair/entrar: sem observar o usuário, o contador da
  // conta anterior ficava no sino da nova (visto na demo ao trocar de perfil)
  ref.watch(authStateProvider).value?.id;
  ref.watch(socialVersionProvider);
  ref.watch(notificationsVersionProvider);
  return ref.watch(notificationsRepositoryProvider).unreadCount();
}

/// Lista (`/notifications`), página de 30, marcar como lidas otimista.
@riverpod
class Notifications extends _$Notifications {
  @override
  Future<List<AppNotification>> build() {
    ref.watch(socialVersionProvider);
    return ref.watch(notificationsRepositoryProvider).page();
  }

  bool get hasMore {
    final current = state.value;
    return current != null && current.isNotEmpty && current.length % NotificationsRepository.pageSize == 0;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || !hasMore) return;
    final repo = ref.read(notificationsRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final next = await repo.page(offset: current.length);
      final seen = {for (final n in current) n.id};
      return [...current, ...next.where((n) => !seen.contains(n.id))];
    });
  }

  Future<String?> markAllRead() async {
    final previous = state;
    final now = DateTime.now();
    state = AsyncData([for (final n in previous.value ?? const <AppNotification>[]) n.isUnread ? n.copyWith(readAt: now) : n]);
    try {
      await ref.read(notificationsRepositoryProvider).markAllRead();
      if (ref.mounted) ref.read(notificationsVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }

  /// Marca uma ao tocar nela (sem desfazer: é só visual).
  Future<void> markRead(String id) async {
    final current = state.value;
    final target = current?.where((n) => n.id == id).firstOrNull;
    if (current == null || target == null || !target.isUnread) return;
    state = AsyncData([for (final n in current) n.id == id ? n.copyWith(readAt: DateTime.now()) : n]);
    try {
      await ref.read(notificationsRepositoryProvider).markRead(id);
      if (ref.mounted) ref.read(notificationsVersionProvider.notifier).bump();
    } catch (_) {
      // a próxima abertura da tela corrige
    }
  }
}
