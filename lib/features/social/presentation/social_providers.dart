import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../onboarding/domain/profile.dart';
import '../data/social_repository.dart';
import '../domain/social_models.dart';

part 'social_providers.g.dart';

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
@Riverpod(keepAlive: true)
SocialRepository socialRepository(Ref ref) =>
    SupabaseSocialRepository(ref.watch(supabaseClientProvider));

/// Sobe a cada mudança social (seguir, aceitar, bloquear, denunciar). Perfil,
/// contadores, feed e notificações observam este número para recarregar.
@Riverpod(keepAlive: true)
class SocialVersion extends _$SocialVersion {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Minha relação com um perfil, com seguir/deixar de seguir otimistas. O
/// status otimista é adivinhado pela privacidade do alvo; o servidor (trigger)
/// confirma. Métodos devolvem a mensagem de erro (null = deu certo).
@riverpod
class FollowState extends _$FollowState {
  @override
  Future<FollowStatus> build(String targetId) => ref.watch(socialRepositoryProvider).followStatus(targetId);

  Future<String?> follow({required bool targetIsPrivate}) async {
    final previous = state;
    state = AsyncData(targetIsPrivate ? FollowStatus.pending : FollowStatus.accepted);
    try {
      final status = await ref.read(socialRepositoryProvider).follow(targetId);
      if (!ref.mounted) return null; // a tela saiu durante a chamada: nada a atualizar
      state = AsyncData(status);
      ref.read(socialVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }

  /// Deixar de seguir ou cancelar o pedido.
  Future<String?> unfollow() async {
    final previous = state;
    state = const AsyncData(FollowStatus.none);
    try {
      await ref.read(socialRepositoryProvider).unfollow(targetId);
      if (!ref.mounted) return null;
      ref.read(socialVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }
}

/// "Segue você" no perfil de alguém.
@riverpod
Future<bool> isFollowingMe(Ref ref, String targetId) {
  ref.watch(socialVersionProvider);
  return ref.watch(socialRepositoryProvider).isFollowingMe(targetId);
}

/// Pedidos recebidos (perfil privado), com aceitar/recusar otimistas.
@riverpod
class PendingRequests extends _$PendingRequests {
  @override
  Future<List<FollowRequest>> build() {
    ref.watch(socialVersionProvider);
    return ref.watch(socialRepositoryProvider).pendingRequests();
  }

  Future<String?> accept(String followerId) => _resolve(followerId, accept: true);

  Future<String?> reject(String followerId) => _resolve(followerId, accept: false);

  Future<String?> _resolve(String followerId, {required bool accept}) async {
    final previous = state;
    state = AsyncData([for (final r in previous.value ?? const <FollowRequest>[]) if (r.follower.id != followerId) r]);
    try {
      final repo = ref.read(socialRepositoryProvider);
      if (accept) {
        await repo.acceptRequest(followerId);
      } else {
        await repo.rejectRequest(followerId);
      }
      if (ref.mounted) ref.read(socialVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }
}

enum FollowListMode { followers, following }

/// Seguidores ou seguindo de um perfil, página de 60 com "Mostrar mais".
@riverpod
class FollowList extends _$FollowList {
  static const pageSize = 60;

  @override
  Future<List<Profile>> build(String userId, FollowListMode mode) {
    ref.watch(socialVersionProvider);
    return _fetch(0);
  }

  Future<List<Profile>> _fetch(int offset) {
    final repo = ref.read(socialRepositoryProvider);
    return mode == FollowListMode.followers
        ? repo.followers(userId, offset: offset, limit: pageSize)
        : repo.following(userId, offset: offset, limit: pageSize);
  }

  bool get hasMore {
    final current = state.value;
    return current != null && current.isNotEmpty && current.length % pageSize == 0;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || !hasMore) return;
    state = await AsyncValue.guard(() async => [...current, ...await _fetch(current.length)]);
  }
}

/// Busca de pessoas por `@` ou nome (a tela aplica o debounce).
@riverpod
Future<List<Profile>> userSearch(Ref ref, String query) {
  ref.watch(socialVersionProvider);
  if (normalizeUserQuery(query).isEmpty) return Future.value(const []);
  return ref.watch(socialRepositoryProvider).searchUsers(query);
}

/// Configurações → Bloqueados, com desbloquear otimista.
@riverpod
class BlockedUsers extends _$BlockedUsers {
  @override
  Future<List<BlockedUser>> build() {
    ref.watch(socialVersionProvider);
    return ref.watch(socialRepositoryProvider).blockedUsers();
  }

  Future<String?> unblock(String userId) async {
    final previous = state;
    state = AsyncData([for (final u in previous.value ?? const <BlockedUser>[]) if (u.id != userId) u]);
    try {
      await ref.read(socialRepositoryProvider).unblock(userId);
      if (ref.mounted) ref.read(socialVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }
}

/// Ações sem estado próprio na tela (a confirmação é um diálogo): bloquear,
/// denunciar, aceitar/recusar pedido a partir de uma notificação. keepAlive
/// porque são chamadas por `ref.read` sem ninguém observando: um provider
/// autoDispose morreria durante o `await` e a confirmação se perderia.
/// Devolvem a mensagem de erro, null = deu certo.
@Riverpod(keepAlive: true)
class SocialActions extends _$SocialActions {
  @override
  void build() {}

  Future<String?> block(String userId) async {
    try {
      await ref.read(socialRepositoryProvider).block(userId);
      // bloquear desfaz follows e some com a pessoa de tudo: recarrega o que depende
      ref.read(socialVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      return describeError(e);
    }
  }

  Future<String?> acceptRequest(String followerId) => _request(followerId, accept: true);

  Future<String?> rejectRequest(String followerId) => _request(followerId, accept: false);

  Future<String?> _request(String followerId, {required bool accept}) async {
    try {
      final repo = ref.read(socialRepositoryProvider);
      if (accept) {
        await repo.acceptRequest(followerId);
      } else {
        await repo.rejectRequest(followerId);
      }
      ref.read(socialVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      return describeError(e);
    }
  }

  Future<String?> report({
    required ReportTarget target,
    required String targetId,
    required ReportReason reason,
    String? details,
  }) async {
    try {
      await ref.read(socialRepositoryProvider).report(target: target, targetId: targetId, reason: reason, details: details);
      return null;
    } catch (e) {
      return describeError(e);
    }
  }
}
