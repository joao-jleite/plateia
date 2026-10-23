import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../diary/presentation/diary_providers.dart';
import '../../lists/presentation/lists_providers.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../../social/presentation/social_providers.dart';
import '../data/feed_repository.dart';
import '../domain/activity.dart';

part 'feed_providers.g.dart';

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) =>
    SupabaseFeedRepository(ref.watch(supabaseClientProvider));

/// Feed (`/feed`): página de 30, "mais" ao chegar no fim, curtir otimista e
/// remover a própria atividade. Recarrega quando o diário, as listas ou a rede
/// (seguir/bloquear) mudam; a tela mantém o dado antigo durante o reload.
@riverpod
class Feed extends _$Feed {
  @override
  Future<List<Activity>> build() {
    ref.watch(diaryVersionProvider);
    ref.watch(listsVersionProvider);
    ref.watch(socialVersionProvider);
    return ref.watch(feedRepositoryProvider).feedPage();
  }

  bool get hasMore {
    final current = state.value;
    return current != null && current.isNotEmpty && current.length % FeedRepository.pageSize == 0;
  }

  Future<void> loadMore() async {
    final current = state.value;
    if (current == null || state.isLoading || !hasMore) return;
    final repo = ref.read(feedRepositoryProvider);
    state = await AsyncValue.guard(() async {
      final next = await repo.feedPage(offset: current.length);
      // a página seguinte pode repetir itens se algo novo entrou no topo
      final seen = {for (final a in current) a.id};
      return [...current, ...next.where((a) => !seen.contains(a.id))];
    });
  }

  Future<void> refresh() async {
    state = await AsyncValue.guard(() => ref.read(feedRepositoryProvider).feedPage());
  }

  /// Curtir/descurtir otimista. Null = deu certo.
  Future<String?> toggleLike(String activityId) async {
    final current = state.value;
    final item = current?.where((a) => a.id == activityId).firstOrNull;
    if (current == null || item == null) return null;
    final liked = !item.likedByMe;
    applyLike(activityId, liked);
    try {
      final repo = ref.read(feedRepositoryProvider);
      if (liked) {
        await repo.like(activityId);
      } else {
        await repo.unlike(activityId);
      }
      if (!ref.mounted) return null;
      // mantém o detalhe (se estiver aberto) coerente sem nova chamada
      if (ref.exists(activityDetailProvider(activityId))) {
        ref.read(activityDetailProvider(activityId).notifier).applyLike(liked);
      }
      return null;
    } catch (e) {
      if (ref.mounted) applyLike(activityId, !liked);
      return describeError(e);
    }
  }

  /// Só muda o estado local (quem gravou foi quem chamou).
  void applyLike(String activityId, bool liked) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final a in current)
        if (a.id == activityId && a.likedByMe != liked)
          a.copyWith(likedByMe: liked, likeCount: (a.likeCount + (liked ? 1 : -1)).clamp(0, 1 << 30))
        else
          a,
    ]);
  }

  void adjustCommentCount(String activityId, int delta) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData([
      for (final a in current)
        if (a.id == activityId) a.copyWith(commentCount: (a.commentCount + delta).clamp(0, 1 << 30)) else a,
    ]);
  }

  /// Autor tira a atividade do feed. Null = deu certo.
  Future<String?> remove(String activityId) async {
    final previous = state;
    state = AsyncData([for (final a in previous.value ?? const <Activity>[]) if (a.id != activityId) a]);
    try {
      await ref.read(feedRepositoryProvider).deleteActivity(activityId);
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }
}

/// Uma atividade (`/activity/:id`). Null = não existe ou não posso ver.
@riverpod
class ActivityDetail extends _$ActivityDetail {
  @override
  Future<Activity?> build(String activityId) {
    ref.watch(socialVersionProvider);
    return ref.watch(feedRepositoryProvider).activity(activityId);
  }

  Future<String?> toggleLike() async {
    final current = state.value;
    if (current == null) return null;
    final liked = !current.likedByMe;
    applyLike(liked);
    try {
      final repo = ref.read(feedRepositoryProvider);
      if (liked) {
        await repo.like(activityId);
      } else {
        await repo.unlike(activityId);
      }
      if (!ref.mounted) return null;
      if (ref.exists(feedProvider)) ref.read(feedProvider.notifier).applyLike(activityId, liked);
      return null;
    } catch (e) {
      if (ref.mounted) applyLike(!liked);
      return describeError(e);
    }
  }

  void applyLike(bool liked) {
    final current = state.value;
    if (current == null || current.likedByMe == liked) return;
    state = AsyncData(current.copyWith(likedByMe: liked, likeCount: (current.likeCount + (liked ? 1 : -1)).clamp(0, 1 << 30)));
  }

  void adjustCommentCount(int delta) {
    final current = state.value;
    if (current == null) return;
    state = AsyncData(current.copyWith(commentCount: (current.commentCount + delta).clamp(0, 1 << 30)));
  }

  /// Autor remove a atividade do feed. Null = deu certo.
  Future<String?> delete() async {
    try {
      await ref.read(feedRepositoryProvider).deleteActivity(activityId);
      if (!ref.mounted) return null;
      if (ref.exists(feedProvider)) unawaitedRemove();
      state = const AsyncData(null);
      return null;
    } catch (e) {
      return describeError(e);
    }
  }

  void unawaitedRemove() {
    final feed = ref.read(feedProvider).value;
    if (feed == null) return;
    ref.read(feedProvider.notifier).state = AsyncData([for (final a in feed) if (a.id != activityId) a]);
  }
}

/// Comentários de uma atividade, com adicionar e apagar otimistas. O autor do
/// comentário e o dono da atividade podem apagar (a RLS confere).
@riverpod
class Comments extends _$Comments {
  @override
  Future<List<Comment>> build(String activityId) {
    // bloquear alguém some com os comentários dele na hora (visto na demo: a tela ficava velha)
    ref.watch(socialVersionProvider);
    return ref.watch(feedRepositoryProvider).comments(activityId);
  }

  Future<String?> add(String body, {bool hasSpoiler = false}) async {
    final error = validateCommentBody(body);
    if (error != null) return error;
    final previous = state;
    final me = ref.read(myProfileProvider).value;
    final uid = ref.read(authStateProvider).value?.id ?? '';
    final now = DateTime.now();
    final optimistic = Comment(
      id: 'pending-${now.microsecondsSinceEpoch}',
      activityId: activityId,
      userId: uid,
      body: body.trim(),
      hasSpoiler: hasSpoiler,
      createdAt: now,
      updatedAt: now,
      user: me,
    );
    state = AsyncData([...previous.value ?? const <Comment>[], optimistic]);
    _bumpCounts(1);
    try {
      final saved = await ref.read(feedRepositoryProvider).addComment(activityId, body, hasSpoiler: hasSpoiler);
      if (!ref.mounted) return null;
      state = AsyncData([
        for (final c in state.value ?? const <Comment>[]) c.id == optimistic.id ? saved.copyWith(user: saved.user ?? me) : c,
      ]);
      return null;
    } catch (e) {
      if (!ref.mounted) return describeError(e);
      state = previous;
      _bumpCounts(-1);
      return describeError(e);
    }
  }

  Future<String?> remove(String commentId) async {
    final previous = state;
    state = AsyncData([for (final c in previous.value ?? const <Comment>[]) if (c.id != commentId) c]);
    _bumpCounts(-1);
    try {
      await ref.read(feedRepositoryProvider).deleteComment(commentId);
      return null;
    } catch (e) {
      if (!ref.mounted) return describeError(e);
      state = previous;
      _bumpCounts(1);
      return describeError(e);
    }
  }

  void _bumpCounts(int delta) {
    if (ref.exists(activityDetailProvider(activityId))) {
      ref.read(activityDetailProvider(activityId).notifier).adjustCommentCount(delta);
    }
    if (ref.exists(feedProvider)) ref.read(feedProvider.notifier).adjustCommentCount(activityId, delta);
  }
}

/// Sobe a cada check-in criado/encerrado (a faixa do feed e do Início observam).
@Riverpod(keepAlive: true)
class CheckinVersion extends _$CheckinVersion {
  @override
  int build() => 0;

  void bump() => state++;
}

/// Faixa "assistindo agora" (view `friends_checkins`): eu + quem eu sigo.
@riverpod
Future<List<Checkin>> friendsCheckins(Ref ref) {
  ref.watch(socialVersionProvider);
  ref.watch(checkinVersionProvider);
  return ref.watch(feedRepositoryProvider).friendsCheckins();
}

/// Meu check-in ativo, com fazer/encerrar otimistas.
@riverpod
class MyCheckin extends _$MyCheckin {
  @override
  Future<Checkin?> build() {
    ref.watch(checkinVersionProvider);
    return ref.watch(feedRepositoryProvider).myCheckin();
  }

  Future<String?> checkIn(CheckinDraft draft) async {
    final error = validateCheckinNote(draft.note);
    if (error != null) return error;
    final previous = state;
    final now = DateTime.now();
    state = AsyncData(Checkin(
      id: 'pending-${now.microsecondsSinceEpoch}',
      userId: ref.read(authStateProvider).value?.id ?? '',
      titleId: draft.titleId,
      season: draft.season,
      episode: draft.episode,
      note: draft.note,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 3)),
      user: ref.read(myProfileProvider).value,
    ));
    try {
      final saved = await ref.read(feedRepositoryProvider).checkIn(draft);
      if (!ref.mounted) return null;
      state = AsyncData(saved);
      ref.read(checkinVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }

  Future<String?> end() async {
    final previous = state;
    final current = previous.value;
    if (current == null) return null;
    state = const AsyncData(null);
    try {
      await ref.read(feedRepositoryProvider).endCheckin(current.id);
      if (ref.mounted) ref.read(checkinVersionProvider.notifier).bump();
      return null;
    } catch (e) {
      if (ref.mounted) state = previous;
      return describeError(e);
    }
  }
}
