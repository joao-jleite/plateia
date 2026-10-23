import '../../core/errors/app_exception.dart';
import '../../features/diary/domain/entry.dart';
import '../../features/feed/data/feed_repository.dart';
import '../../features/feed/domain/activity.dart';
import '../../features/lists/domain/list_models.dart';
import '../../features/notifications/data/notifications_repository.dart';
import '../../features/notifications/domain/app_notification.dart';
import '../../features/onboarding/domain/profile.dart';
import '../../features/social/data/social_repository.dart';
import '../../features/social/domain/social_models.dart';
import 'fixture_auth_repository.dart';
import 'fixture_data.dart';
import 'fixture_diary.dart';

/// Rede social em memória: `follows`, `blocks`, `activities`, `likes`,
/// `comments`, `checkins`, `notifications` e `reports`, com as mesmas regras
/// que no banco são triggers e policies (0001 + 0005):
///   • seguir perfil privado vira pedido; bloqueio desfaz follows e limpa
///     notificações nos dois sentidos; o bloqueado não vê nada do bloqueador;
///   • atividades nascem do diário (review > nota > status; rajada de 1 h
///     atualiza em vez de duplicar) e de lista pública;
///   • curtida e comentário atualizam contadores e notificam o autor (não a si
///     mesmo); descurtir remove a notificação; lista que vira privada sai do feed.
/// Nasce com uma cena pronta: @foxer ↔ @camila, @vini → @foxer, curtidas e
/// comentários entre eles e um check-in do @foxer em One Piece.
class FixtureSocialStore implements FixtureSocialHooks {
  FixtureSocialStore(this.diary, {DateTime Function()? clock, bool seed = true}) : _clock = clock ?? DateTime.now {
    diary.social = this;
    // os três perfis foram semeados no construtor do diário, antes de existirmos
    for (final e in diary.seededEntries.toList()) {
      onEntrySeeded(e);
    }
    for (final l in diary.lists.values.where((l) => !l.isPrivate)) {
      _insertActivity(l.userId, ActivityKind.listCreated, listId: l.id, payload: {'name': l.name}, at: l.createdAt);
    }
    if (seed) _seedScene();
  }

  final FixtureDiaryStore diary;
  final DateTime Function() _clock;

  /// `'$follower|$followee'` → status
  final Map<String, FollowStatus> follows = {};
  final Map<String, DateTime> followedAt = {};

  /// `'$blocker|$blocked'`
  final Set<String> blocks = {};
  final List<Activity> activities = [];

  /// `'$userId|$activityId'`
  final Set<String> likes = {};
  final Map<String, Comment> comments = {};
  final Map<String, Checkin> checkins = {};
  final List<AppNotification> notifications = [];
  final List<Map<String, Object?>> reports = [];
  int _seq = 0;

  DateTime now() => _clock();

  String newId(String prefix) => '$prefix-${(++_seq).toString().padLeft(4, '0')}';
  static String pair(String a, String b) => '$a|$b';

  // ---- cena inicial ---------------------------------------------------------

  void _seedScene() {
    final foxer = FixtureDiaryStore.foxer.id;
    final camila = FixtureDiaryStore.camila.id;
    final vini = FixtureDiaryStore.vini.id;
    follow(foxer, camila, at: DateTime(2026, 9, 13), forceAccepted: true);
    follow(camila, foxer, at: DateTime(2026, 9, 13));
    follow(vini, foxer, at: DateTime(2026, 9, 21));
    follow(foxer, vini, at: DateTime(2026, 9, 22));

    final frieren = _activityOf(foxer, 209867);
    final duna = _activityOf(vini, 693134);
    if (frieren != null) {
      like(camila, frieren.id, at: DateTime(2026, 10, 2, 9));
      comment(camila, frieren.id, 'Concordo. A trilha é um absurdo.', at: DateTime(2026, 10, 2, 9, 5));
      like(vini, frieren.id, at: DateTime(2026, 10, 2, 20));
    }
    if (duna != null) {
      like(foxer, duna.id, at: DateTime(2026, 10, 21, 22));
      comment(foxer, duna.id, 'Vi no IMAX também. O final deixa a Parte Três obrigatória.',
          hasSpoiler: true, at: DateTime(2026, 10, 21, 22, 10));
    }
    final now = _clock();
    checkins[newId('checkin')] = Checkin(
      id: 'checkin-foxer',
      userId: foxer,
      titleId: FixtureDiaryStore.titleByTmdb(37854).id,
      season: 21,
      episode: 1051,
      note: 'Wano chegando no fim!',
      createdAt: now.subtract(const Duration(minutes: 20)),
      expiresAt: now.add(const Duration(hours: 2, minutes: 40)),
    );
  }

  Activity? _activityOf(String userId, int tmdbId) {
    final titleId = FixtureDiaryStore.titleByTmdb(tmdbId).id;
    return activities.where((a) => a.userId == userId && a.titleId == titleId).firstOrNull;
  }

  // ---- visibilidade (mesma regra das funções do banco) ----------------------

  bool isBlockedBetween(String a, String b) => blocks.contains(pair(a, b)) || blocks.contains(pair(b, a));

  bool isFollowing(String follower, String followee) => follows[pair(follower, followee)] == FollowStatus.accepted;

  @override
  bool canViewContent(String viewer, String owner) {
    if (viewer == owner) return true;
    if (isBlockedBetween(viewer, owner)) return false;
    final p = diary.profiles[owner];
    if (p == null) return true;
    return !p.isPrivate || isFollowing(viewer, owner);
  }

  @override
  bool canViewProfile(String viewer, String target) => viewer == target || !isBlockedBetween(viewer, target);

  @override
  int followersCount(String userId) =>
      follows.entries.where((e) => e.key.endsWith('|$userId') && e.value == FollowStatus.accepted).length;

  @override
  int followingCount(String userId) =>
      follows.entries.where((e) => e.key.startsWith('$userId|') && e.value == FollowStatus.accepted).length;

  Set<String> followees(String userId) => {
        for (final e in follows.entries)
          if (e.key.startsWith('$userId|') && e.value == FollowStatus.accepted) e.key.split('|')[1],
      };

  // ---- follows / blocks -----------------------------------------------------

  FollowStatus follow(String follower, String followee, {DateTime? at, bool forceAccepted = false}) {
    if (isBlockedBetween(follower, followee)) {
      throw const AppException('forbidden', 'Não é possível seguir este perfil.');
    }
    final target = diary.profiles[followee];
    if (target == null) throw const AppException('not_found', 'Perfil não encontrado.');
    final existing = follows[pair(follower, followee)];
    if (existing != null) return existing;
    final status = (target.isPrivate && !forceAccepted) ? FollowStatus.pending : FollowStatus.accepted;
    follows[pair(follower, followee)] = status;
    followedAt[pair(follower, followee)] = at ?? _clock();
    _notify(followee, follower, status == FollowStatus.accepted ? NotificationKind.follow : NotificationKind.followRequest, at: at);
    return status;
  }

  void accept(String follower, String followee, {DateTime? at}) {
    if (follows[pair(follower, followee)] != FollowStatus.pending) return;
    follows[pair(follower, followee)] = FollowStatus.accepted;
    _notify(follower, followee, NotificationKind.followAccepted, at: at);
    notifications.removeWhere((n) => n.userId == followee && n.actorId == follower && n.kind == NotificationKind.followRequest);
  }

  void unfollow(String follower, String followee) {
    follows.remove(pair(follower, followee));
    followedAt.remove(pair(follower, followee));
  }

  void block(String blocker, String blocked) {
    blocks.add(pair(blocker, blocked));
    unfollow(blocker, blocked);
    unfollow(blocked, blocker);
    notifications.removeWhere((n) =>
        (n.userId == blocker && n.actorId == blocked) || (n.userId == blocked && n.actorId == blocker));
  }

  @override
  void onPrivacyChanged(String userId, {required bool isPrivate}) {
    if (isPrivate) return;
    // virar público aceita os pedidos pendentes
    for (final e in follows.entries.where((e) => e.key.endsWith('|$userId') && e.value == FollowStatus.pending).toList()) {
      accept(e.key.split('|')[0], userId);
    }
  }

  // ---- atividades (triggers do diário e das listas) -------------------------

  Activity _insertActivity(
    String userId,
    ActivityKind kind, {
    String? titleId,
    String? entryId,
    String? listId,
    Map<String, dynamic> payload = const {},
    DateTime? at,
  }) {
    final a = Activity(
      id: newId('act'),
      userId: userId,
      kind: kind,
      titleId: titleId,
      entryId: entryId,
      listId: listId,
      payload: payload,
      createdAt: at ?? _clock(),
    );
    activities.add(a);
    return a;
  }

  static Map<String, dynamic> _payloadOf(Entry e) => {
        'status': e.status.dbValue,
        'rating': e.rating,
        'has_review': e.hasReview,
        'has_spoiler': e.hasSpoiler,
        'is_rewatch': e.isRewatch,
      };

  @override
  void onEntrySeeded(Entry e) {
    if (activities.any((a) => a.entryId == e.id)) return;
    final kind = e.hasReview
        ? ActivityKind.reviewed
        : e.rating != null
            ? ActivityKind.rated
            : switch (e.status) {
                EntryStatus.watched => ActivityKind.watched,
                EntryStatus.watching => ActivityKind.watching,
                EntryStatus.want => null,
              };
    if (kind == null) return;
    _insertActivity(e.userId, kind, titleId: e.titleId, entryId: e.id, payload: _payloadOf(e), at: e.watchedAt ?? e.updatedAt);
  }

  @override
  void onEntryUpserted(Entry? previous, Entry saved) {
    if (saved.source == 'netflix_import') return;
    ActivityKind? kind;
    if (saved.review != previous?.review && saved.hasReview) {
      kind = ActivityKind.reviewed;
    } else if (saved.rating != previous?.rating && saved.rating != null) {
      kind = ActivityKind.rated;
    } else if (saved.status != previous?.status && saved.status == EntryStatus.watched) {
      kind = ActivityKind.watched;
    } else if (saved.status != previous?.status && saved.status == EntryStatus.watching) {
      kind = ActivityKind.watching;
    }
    if (kind == null) return;
    final now = _clock();
    final recent = activities.indexWhere(
        (a) => a.entryId == saved.id && a.kind == kind && now.difference(a.createdAt) < const Duration(hours: 1));
    if (recent >= 0) {
      activities[recent] = activities[recent].copyWith(payload: _payloadOf(saved), createdAt: now);
    } else {
      _insertActivity(saved.userId, kind, titleId: saved.titleId, entryId: saved.id, payload: _payloadOf(saved), at: now);
    }
  }

  @override
  void onEntryRemoved(Entry entry) => deleteActivities((a) => a.entryId == entry.id);

  @override
  void onListCreated(ListModel list) {
    if (!list.isPrivate) _insertActivity(list.userId, ActivityKind.listCreated, listId: list.id, payload: {'name': list.name});
  }

  @override
  void onListUpdated(ListModel previous, ListModel updated) {
    if (updated.isPrivate && !previous.isPrivate) {
      deleteActivities((a) => a.listId == updated.id);
    } else if (updated.name != previous.name) {
      for (var i = 0; i < activities.length; i++) {
        if (activities[i].listId == updated.id) {
          activities[i] = activities[i].copyWith(payload: {...activities[i].payload, 'name': updated.name});
        }
      }
    }
  }

  @override
  void onListDeleted(String listId) => deleteActivities((a) => a.listId == listId);

  void deleteActivities(bool Function(Activity) where) {
    final ids = {for (final a in activities.where(where)) a.id};
    if (ids.isEmpty) return;
    activities.removeWhere((a) => ids.contains(a.id));
    likes.removeWhere((k) => ids.contains(k.split('|')[1]));
    comments.removeWhere((_, c) => ids.contains(c.activityId));
    notifications.removeWhere((n) => n.activityId != null && ids.contains(n.activityId));
  }

  // ---- curtidas, comentários, notificações ---------------------------------

  Activity? activityById(String id) => activities.where((a) => a.id == id).firstOrNull;

  int _indexOf(String activityId) => activities.indexWhere((a) => a.id == activityId);

  void like(String userId, String activityId, {DateTime? at}) {
    if (!likes.add(pair(userId, activityId))) return;   // curtir duas vezes não duplica
    final i = _indexOf(activityId);
    if (i < 0) return;
    activities[i] = activities[i].copyWith(likeCount: activities[i].likeCount + 1);
    if (activities[i].userId != userId) {
      _notify(activities[i].userId, userId, NotificationKind.like, activityId: activityId, at: at);
    }
  }

  void unlike(String userId, String activityId) {
    if (!likes.remove(pair(userId, activityId))) return;
    final i = _indexOf(activityId);
    if (i >= 0) activities[i] = activities[i].copyWith(likeCount: (activities[i].likeCount - 1).clamp(0, 1 << 30));
    notifications.removeWhere((n) => n.kind == NotificationKind.like && n.activityId == activityId && n.actorId == userId);
  }

  Comment comment(String userId, String activityId, String body, {bool hasSpoiler = false, DateTime? at}) {
    final stamp = at ?? _clock();
    final c = Comment(
      id: newId('cmt'),
      activityId: activityId,
      userId: userId,
      body: body,
      hasSpoiler: hasSpoiler,
      createdAt: stamp,
      updatedAt: stamp,
    );
    comments[c.id] = c;
    final i = _indexOf(activityId);
    if (i >= 0) {
      activities[i] = activities[i].copyWith(commentCount: activities[i].commentCount + 1);
      if (activities[i].userId != userId) {
        _notify(activities[i].userId, userId, NotificationKind.comment, activityId: activityId, commentId: c.id, at: at);
      }
    }
    return c;
  }

  void deleteComment(String commentId) {
    final c = comments.remove(commentId);
    if (c == null) return;
    final i = _indexOf(c.activityId);
    if (i >= 0) activities[i] = activities[i].copyWith(commentCount: (activities[i].commentCount - 1).clamp(0, 1 << 30));
    notifications.removeWhere((n) => n.commentId == commentId);
  }

  void _notify(String userId, String actorId, NotificationKind kind, {String? activityId, String? commentId, DateTime? at}) {
    notifications.add(AppNotification(
      id: newId('ntf'),
      userId: userId,
      actorId: actorId,
      kind: kind,
      activityId: activityId,
      commentId: commentId,
      createdAt: at ?? _clock(),
    ));
  }

  // ---- leituras com embed, pelo olhar de `viewer` ---------------------------

  Activity hydrate(Activity a, String viewer) => a.copyWith(
        user: diary.profiles[a.userId],
        title: a.titleId == null ? null : fixtureTitles.where((t) => t.title.id == a.titleId).firstOrNull?.title,
        list: a.listId == null ? null : diary.lists[a.listId],
        entry: a.entryId == null ? null : diary.entries.values.where((e) => e.id == a.entryId).firstOrNull,
        likedByMe: likes.contains(pair(viewer, a.id)),
      );

  List<Activity> feedFor(String viewer, {int offset = 0, int limit = 30}) {
    final authors = {viewer, ...followees(viewer)};
    final visible = activities.where((a) => authors.contains(a.userId) && canViewContent(viewer, a.userId)).toList()
      ..sort((x, y) => y.createdAt.compareTo(x.createdAt));
    if (offset >= visible.length) return const [];
    return visible.sublist(offset, (offset + limit).clamp(0, visible.length)).map((a) => hydrate(a, viewer)).toList();
  }

  Activity? activityFor(String viewer, String id) {
    final a = activityById(id);
    if (a == null || !canViewContent(viewer, a.userId)) return null;
    return hydrate(a, viewer);
  }

  List<Comment> commentsFor(String viewer, String activityId) {
    final a = activityById(activityId);
    if (a == null || !canViewContent(viewer, a.userId)) return const [];
    return comments.values
        .where((c) => c.activityId == activityId && !isBlockedBetween(viewer, c.userId))
        .map((c) => c.copyWith(user: diary.profiles[c.userId]))
        .toList()
      ..sort((x, y) => (x.createdAt ?? DateTime(0)).compareTo(y.createdAt ?? DateTime(0)));
  }

  Checkin hydrateCheckin(Checkin c) => c.copyWith(
        user: diary.profiles[c.userId],
        title: fixtureTitles.where((t) => t.title.id == c.titleId).firstOrNull?.title,
      );

  List<Checkin> friendsCheckinsFor(String viewer) {
    final now = _clock();
    final authors = {viewer, ...followees(viewer)};
    return checkins.values
        .where((c) => c.isActive(now) && authors.contains(c.userId) && canViewContent(viewer, c.userId))
        .map(hydrateCheckin)
        .toList()
      ..sort((x, y) => (y.createdAt ?? DateTime(0)).compareTo(x.createdAt ?? DateTime(0)));
  }

  List<AppNotification> notificationsFor(String viewer, {int offset = 0, int limit = 30}) {
    final mine = notifications
        .where((n) => n.userId == viewer && (n.actorId == null || !isBlockedBetween(viewer, n.actorId!)))
        .toList()
      ..sort((x, y) => y.createdAt.compareTo(x.createdAt));
    if (offset >= mine.length) return const [];
    return mine.sublist(offset, (offset + limit).clamp(0, mine.length)).map((n) {
      final a = n.activityId == null ? null : activityById(n.activityId!);
      final c = n.commentId == null ? null : comments[n.commentId!];
      return n.copyWith(
        actor: n.actorId == null ? null : diary.profiles[n.actorId!],
        activity: a == null ? null : hydrate(a, viewer),
        comment: c,
      );
    }).toList();
  }

  int unreadFor(String viewer) =>
      notifications.where((n) => n.userId == viewer && n.isUnread && (n.actorId == null || !isBlockedBetween(viewer, n.actorId!))).length;

  List<Profile> searchFor(String viewer, String query) {
    final q = normalizeUserQuery(query);
    if (q.isEmpty) return const [];
    return diary.profiles.values
        .where((p) => p.id != viewer && !isBlockedBetween(viewer, p.id))
        .where((p) => p.username.startsWith(q) || (p.displayName ?? '').toLowerCase().contains(q))
        .toList()
      ..sort((x, y) => x.username.compareTo(y.username));
  }

  /// Linhas de `follows` visíveis para [viewer]: as dele e, dos outros, só as
  /// aceitas de quem ele pode ver o conteúdo e sem bloqueio com o seguido
  /// (policy "follows: ver as minhas e as públicas").
  bool _followRowVisible(String viewer, String follower, String followee, FollowStatus status) =>
      follower == viewer ||
      followee == viewer ||
      (status == FollowStatus.accepted && canViewContent(viewer, follower) && canViewProfile(viewer, followee));

  List<Profile> followersOf(String viewer, String userId) => [
        for (final e in follows.entries)
          if (e.key.endsWith('|$userId') &&
              e.value == FollowStatus.accepted &&
              _followRowVisible(viewer, e.key.split('|')[0], userId, e.value) &&
              canViewProfile(viewer, e.key.split('|')[0]) &&
              diary.profiles[e.key.split('|')[0]] != null)
            diary.profiles[e.key.split('|')[0]]!,
      ];

  List<Profile> followingOf(String viewer, String userId) => [
        for (final e in follows.entries)
          if (e.key.startsWith('$userId|') &&
              e.value == FollowStatus.accepted &&
              _followRowVisible(viewer, userId, e.key.split('|')[1], e.value) &&
              canViewProfile(viewer, e.key.split('|')[1]) &&
              diary.profiles[e.key.split('|')[1]] != null)
            diary.profiles[e.key.split('|')[1]]!,
      ];
}

/// Base dos três repositórios de amostra: usuário logado, latência e a
/// simulação de "o servidor recusou" (`failWrites`).
abstract class _FixtureSocialBase {
  _FixtureSocialBase(this.store, this.auth, {required this.latency, required this.failWrites});

  final FixtureSocialStore store;
  final FixtureAuthRepository auth;
  final Duration latency;
  final bool failWrites;

  String get uid {
    final user = auth.currentUser;
    if (user == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    store.diary.ensureSeeded(user.id);
    return user.id;
  }

  Future<void> read() => Future<void>.delayed(latency);

  Future<void> write() async {
    await Future<void>.delayed(latency);
    if (failWrites) throw const AppException('internal', 'Simulação: o servidor recusou a gravação.');
  }
}

class FixtureSocialRepository extends _FixtureSocialBase implements SocialRepository {
  FixtureSocialRepository(super.store, super.auth, {super.latency = const Duration(milliseconds: 200), super.failWrites = false});

  @override
  Future<FollowStatus> followStatus(String targetId) async {
    final me = uid;
    await read();
    return store.follows[FixtureSocialStore.pair(me, targetId)] ?? FollowStatus.none;
  }

  @override
  Future<FollowStatus> follow(String targetId) async {
    final me = uid;
    await write();
    return store.follow(me, targetId);
  }

  @override
  Future<void> unfollow(String targetId) async {
    final me = uid;
    await write();
    store.unfollow(me, targetId);
  }

  @override
  Future<bool> isFollowingMe(String targetId) async {
    final me = uid;
    await read();
    return store.isFollowing(targetId, me);
  }

  @override
  Future<List<FollowRequest>> pendingRequests() async {
    final me = uid;
    await read();
    return [
      for (final e in store.follows.entries)
        if (e.key.endsWith('|$me') && e.value == FollowStatus.pending && store.diary.profiles[e.key.split('|')[0]] != null)
          FollowRequest(follower: store.diary.profiles[e.key.split('|')[0]]!, createdAt: store.followedAt[e.key]),
    ]..sort((x, y) => (y.createdAt ?? DateTime(0)).compareTo(x.createdAt ?? DateTime(0)));
  }

  @override
  Future<void> acceptRequest(String followerId) async {
    final me = uid;
    await write();
    store.accept(followerId, me);
  }

  @override
  Future<void> rejectRequest(String followerId) async {
    final me = uid;
    await write();
    store.unfollow(followerId, me);
  }

  @override
  Future<List<Profile>> followers(String userId, {int offset = 0, int limit = 60}) async {
    final me = uid;
    await read();
    return _page(store.followersOf(me, userId), offset, limit);
  }

  @override
  Future<List<Profile>> following(String userId, {int offset = 0, int limit = 60}) async {
    final me = uid;
    await read();
    return _page(store.followingOf(me, userId), offset, limit);
  }

  static List<Profile> _page(List<Profile> all, int offset, int limit) =>
      offset >= all.length ? const [] : all.sublist(offset, (offset + limit).clamp(0, all.length));

  @override
  Future<List<Profile>> searchUsers(String query, {int limit = 20}) async {
    final me = uid;
    await read();
    return store.searchFor(me, query).take(limit).toList();
  }

  @override
  Future<void> block(String userId) async {
    final me = uid;
    await write();
    store.block(me, userId);
  }

  @override
  Future<void> unblock(String userId) async {
    final me = uid;
    await write();
    store.blocks.remove(FixtureSocialStore.pair(me, userId));
  }

  @override
  Future<List<BlockedUser>> blockedUsers() async {
    final me = uid;
    await read();
    return [
      for (final k in store.blocks)
        if (k.startsWith('$me|') && store.diary.profiles[k.split('|')[1]] != null)
          BlockedUser(
            id: k.split('|')[1],
            username: store.diary.profiles[k.split('|')[1]]!.username,
            displayName: store.diary.profiles[k.split('|')[1]]!.displayName,
            avatarUrl: store.diary.profiles[k.split('|')[1]]!.avatarUrl,
          ),
    ];
  }

  @override
  Future<void> report({required ReportTarget target, required String targetId, required ReportReason reason, String? details}) async {
    final me = uid;
    await write();
    store.reports.add({'reporter_id': me, 'target_type': target.dbValue, 'target_id': targetId, 'reason': reason.dbValue, 'details': details});
  }
}

class FixtureFeedRepository extends _FixtureSocialBase implements FeedRepository {
  FixtureFeedRepository(super.store, super.auth, {super.latency = const Duration(milliseconds: 200), super.failWrites = false});

  @override
  Future<List<Activity>> feedPage({int offset = 0, int limit = FeedRepository.pageSize}) async {
    final me = uid;
    await read();
    return store.feedFor(me, offset: offset, limit: limit);
  }

  @override
  Future<Activity?> activity(String id) async {
    final me = uid;
    await read();
    return store.activityFor(me, id);
  }

  @override
  Future<void> deleteActivity(String id) async {
    final me = uid;
    await write();
    final a = store.activityById(id);
    if (a == null || a.userId != me) throw const AppException('forbidden', 'Só o autor remove a atividade.');
    store.deleteActivities((x) => x.id == id);
  }

  void _requireVisible(String me, String activityId) {
    final a = store.activityById(activityId);
    if (a == null || !store.canViewContent(me, a.userId)) {
      throw const AppException('forbidden', 'Você não pode interagir com essa atividade.');
    }
  }

  @override
  Future<void> like(String activityId) async {
    final me = uid;
    await write();
    _requireVisible(me, activityId);
    store.like(me, activityId);
  }

  @override
  Future<void> unlike(String activityId) async {
    final me = uid;
    await write();
    store.unlike(me, activityId);
  }

  @override
  Future<List<Comment>> comments(String activityId) async {
    final me = uid;
    await read();
    return store.commentsFor(me, activityId);
  }

  @override
  Future<Comment> addComment(String activityId, String body, {bool hasSpoiler = false}) async {
    final me = uid;
    final error = validateCommentBody(body);
    if (error != null) throw AppException('invalid', error);
    await write();
    _requireVisible(me, activityId);
    return store.comment(me, activityId, body.trim(), hasSpoiler: hasSpoiler).copyWith(user: store.diary.profiles[me]);
  }

  @override
  Future<void> deleteComment(String commentId) async {
    final me = uid;
    await write();
    final c = store.comments[commentId];
    if (c == null) return;
    final owner = store.activityById(c.activityId)?.userId;
    if (c.userId != me && owner != me) throw const AppException('forbidden', 'Só o autor ou o dono da atividade apagam.');
    store.deleteComment(commentId);
  }

  @override
  Future<List<Checkin>> friendsCheckins() async {
    final me = uid;
    await read();
    return store.friendsCheckinsFor(me);
  }

  @override
  Future<Checkin?> myCheckin() async {
    final me = uid;
    await read();
    final mine = store.checkins.values.where((c) => c.userId == me && c.isActive(store.now())).toList()
      ..sort((x, y) => (y.createdAt ?? DateTime(0)).compareTo(x.createdAt ?? DateTime(0)));
    return mine.isEmpty ? null : store.hydrateCheckin(mine.first);
  }

  @override
  Future<Checkin> checkIn(CheckinDraft draft) async {
    final me = uid;
    final error = validateCheckinNote(draft.note);
    if (error != null) throw AppException('invalid', error);
    await write();
    store.checkins.removeWhere((_, c) => c.userId == me);
    final now = store.now();
    final note = draft.note?.trim();
    final c = Checkin(
      id: store.newId('checkin'),
      userId: me,
      titleId: draft.titleId,
      season: draft.season,
      episode: draft.episode,
      note: (note == null || note.isEmpty) ? null : note,
      createdAt: now,
      expiresAt: now.add(const Duration(hours: 3)),
    );
    store.checkins[c.id] = c;
    return store.hydrateCheckin(c);
  }

  @override
  Future<void> endCheckin(String id) async {
    final me = uid;
    await write();
    store.checkins.removeWhere((k, c) => k == id && c.userId == me);
  }
}

class FixtureNotificationsRepository extends _FixtureSocialBase implements NotificationsRepository {
  FixtureNotificationsRepository(super.store, super.auth, {super.latency = const Duration(milliseconds: 200), super.failWrites = false});

  @override
  Future<List<AppNotification>> page({int offset = 0, int limit = NotificationsRepository.pageSize}) async {
    final me = uid;
    await read();
    return store.notificationsFor(me, offset: offset, limit: limit);
  }

  @override
  Future<int> unreadCount() async {
    final me = uid;
    await read();
    return store.unreadFor(me);
  }

  @override
  Future<void> markAllRead() async {
    final me = uid;
    await write();
    final now = store.now();
    for (var i = 0; i < store.notifications.length; i++) {
      final n = store.notifications[i];
      if (n.userId == me && n.isUnread) store.notifications[i] = n.copyWith(readAt: now);
    }
  }

  @override
  Future<void> markRead(String id) async {
    final me = uid;
    await write();
    final i = store.notifications.indexWhere((n) => n.id == id && n.userId == me);
    if (i >= 0) store.notifications[i] = store.notifications[i].copyWith(readAt: store.now());
  }
}
