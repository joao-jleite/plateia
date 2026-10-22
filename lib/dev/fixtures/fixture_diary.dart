import 'dart:typed_data';

import '../../core/errors/app_exception.dart';
import '../../core/model/media_type.dart';
import '../../features/catalog/domain/catalog_models.dart';
import '../../features/diary/data/entries_repository.dart';
import '../../features/diary/domain/entry.dart';
import '../../features/lists/data/lists_repository.dart';
import '../../features/lists/domain/list_models.dart';
import '../../features/onboarding/data/profile_repository.dart';
import '../../features/onboarding/domain/profile.dart';
import '../../features/profile/domain/profile_stats.dart';
import 'fixture_auth_repository.dart';
import 'fixture_data.dart';

/// Diário, listas e perfis alheios em memória, compartilhados pelos três
/// repositórios de amostra. Nasce com alguns registros para quem loga (perfil
/// cheio no emulador) e com dois perfis de terceiros: `@foxer` (público) e
/// `@camila` (privado), para a interface de privacidade ser visível sem a
/// fase 06 (seguir). `seed: false` dá um diário vazio para os testes.
class FixtureDiaryStore {
  FixtureDiaryStore({this.seed = true, DateTime Function()? clock}) : _clock = clock ?? DateTime.now {
    _seedOthers();
  }

  final bool seed;
  final DateTime Function() _clock;

  /// `'$userId|$titleId'` → registro
  final Map<String, Entry> entries = {};
  final Map<String, ListModel> lists = {};

  /// listId → itens em ordem de `position`
  final Map<String, List<ListItem>> items = {};
  final Set<String> _seeded = {};

  static final foxer = Profile(
    id: 'fixture-foxer',
    username: 'foxer',
    displayName: 'João Leite',
    bio: 'Anime, sci-fi e o que o Vini recomenda.',
    onboardedAt: DateTime(2026, 9, 1),
    createdAt: DateTime(2026, 9, 1),
  );
  static final camila = Profile(
    id: 'fixture-camila',
    username: 'camila',
    displayName: 'Camila Rocha',
    bio: 'Só vejo série com legenda. Perfil privado.',
    isPrivate: true,
    onboardedAt: DateTime(2026, 9, 12),
    createdAt: DateTime(2026, 9, 12),
  );
  static final others = {foxer.username: foxer, camila.username: camila};

  /// Quem o usuário logado "segue" (aceito). Vazio: Camila continua fechada.
  final Set<String> following = {};

  static Title titleById(String id) => fixtureTitles.firstWhere((t) => t.title.id == id).title;
  static Title titleByTmdb(int tmdbId) => fixtureTitles.firstWhere((t) => t.title.tmdbId == tmdbId).title;

  static String key(String userId, String titleId) => '$userId|$titleId';

  int _ids = 0;
  String nextId(String prefix) => '$prefix-${(++_ids).toString().padLeft(4, '0')}';

  /// Primeiro acesso do usuário logado: um diário que dá vontade de mostrar.
  void ensureSeeded(String userId) {
    if (!seed || _seeded.contains(userId)) return;
    _seeded.add(userId);
    final now = _clock();
    final onePiece = titleByTmdb(37854);
    _put(userId, onePiece, EntryStatus.watching,
        rating: 4.5,
        review: 'Wano é o melhor arco. Luffy acorda a fruta no fim e muda tudo.',
        spoiler: true,
        season: 21,
        episode: 1050,
        watchedAt: now.subtract(const Duration(days: 2)));
    _put(userId, titleByTmdb(872585), EntryStatus.watched,
        rating: 5, review: 'Três horas que passam voando. Som absurdo.', watchCount: 2, watchedAt: DateTime(2026, 10, 10));
    _put(userId, titleByTmdb(693134), EntryStatus.watched, rating: 4, watchedAt: DateTime(2026, 9, 28));
    _put(userId, titleByTmdb(598), EntryStatus.watched, rating: 4.5, watchedAt: DateTime(2026, 8, 15));
    _put(userId, titleByTmdb(66732), EntryStatus.want);
    _put(userId, titleByTmdb(73586), EntryStatus.want);

    final maratonar = _newList(userId, const ListDraft(name: 'Para maratonar', isRanked: true), now.subtract(const Duration(days: 5)));
    _addItem(maratonar.id, titleByTmdb(66732).id);
    _addItem(maratonar.id, titleByTmdb(73586).id);
    _addItem(maratonar.id, titleByTmdb(100088).id);
    final guilty = _newList(userId, const ListDraft(name: 'Guilty pleasures', isPrivate: true), now.subtract(const Duration(days: 1)));
    _addItem(guilty.id, titleByTmdb(136315).id);
  }

  void _seedOthers() {
    _put(foxer.id, titleByTmdb(209867), EntryStatus.watched, rating: 5, review: 'Melhor anime de 2023, fácil.', watchedAt: DateTime(2026, 10, 1));
    _put(foxer.id, titleByTmdb(872585), EntryStatus.watched, rating: 4.5, watchedAt: DateTime(2026, 9, 20));
    _put(foxer.id, titleByTmdb(37854), EntryStatus.watching, rating: 4, season: 1, episode: 30, watchedAt: DateTime(2026, 10, 20));
    final animes = _newList(foxer.id, const ListDraft(name: 'Animes de 2023'), DateTime(2026, 10, 2));
    _addItem(animes.id, titleByTmdb(209867).id);
    // Camila: conteúdo existe (os contadores aparecem), mas fica escondido.
    _put(camila.id, titleByTmdb(100088), EntryStatus.watched, rating: 5, review: 'Chorei no 3.', watchedAt: DateTime(2026, 10, 3));
    _put(camila.id, titleByTmdb(136315), EntryStatus.watched, rating: 4, watchedAt: DateTime(2026, 9, 9));
    _newList(camila.id, const ListDraft(name: 'Comfort'), DateTime(2026, 10, 4));
  }

  void _put(
    String userId,
    Title title,
    EntryStatus status, {
    double? rating,
    String? review,
    bool spoiler = false,
    int? season,
    int? episode,
    int watchCount = 1,
    DateTime? watchedAt,
  }) {
    final stamp = watchedAt ?? _clock();
    entries[key(userId, title.id)] = Entry(
      id: nextId('entry'),
      userId: userId,
      titleId: title.id,
      status: status,
      rating: rating,
      review: review,
      hasSpoiler: spoiler,
      watchedAt: status == EntryStatus.want ? null : stamp,
      currentSeason: season,
      currentEpisode: episode,
      episodesWatched: title.mediaType == MediaType.tv
          ? episodesWatchedFor(title, status: status, season: season, episode: episode)
          : null,
      watchCount: watchCount,
      createdAt: stamp,
      updatedAt: stamp,
      title: title,
    );
  }

  ListModel _newList(String userId, ListDraft draft, DateTime at) {
    final list = ListModel(
      id: nextId('list'),
      userId: userId,
      name: draft.name,
      description: draft.description,
      isPrivate: draft.isPrivate,
      isRanked: draft.isRanked,
      createdAt: at,
      updatedAt: at,
    );
    lists[list.id] = list;
    items[list.id] = [];
    return list;
  }

  void _addItem(String listId, String titleId) {
    final current = items[listId]!;
    if (current.any((i) => i.titleId == titleId)) return;
    current.add(ListItem(listId: listId, titleId: titleId, position: current.length, addedAt: _clock(), title: titleById(titleId)));
    lists[listId] = lists[listId]!.copyWith(itemCount: current.length);
  }

  /// Mesma regra de `can_view_content`: dono sempre; público sim; privado só seguidor.
  bool canView(String viewer, String owner) {
    if (viewer == owner) return true;
    final profile = others.values.where((p) => p.id == owner).firstOrNull;
    if (profile == null) return true; // outro usuário de amostra sem cartão: trata como público
    return !profile.isPrivate || following.contains(owner);
  }

  // ---- ações usadas pelos repositórios ------------------------------------

  Entry upsert(String userId, EntryDraft draft) {
    final d = draft.normalized();
    final previous = entries[key(userId, d.titleId)];
    final title = titleById(d.titleId);
    final saved = optimisticEntry(previous, d, userId: userId, title: title, now: _clock())
        .copyWith(id: previous?.id ?? nextId('entry'));
    entries[key(userId, d.titleId)] = saved;
    return saved;
  }

  void remove(String userId, String titleId) => entries.remove(key(userId, titleId));

  ListModel createList(String userId, ListDraft draft) => _newList(userId, draft, _clock());

  ListModel updateList(String listId, ListDraft draft) {
    final updated = lists[listId]!.copyWith(
      name: draft.name,
      description: draft.description,
      isPrivate: draft.isPrivate,
      isRanked: draft.isRanked,
      updatedAt: _clock(),
    );
    lists[listId] = updated;
    return updated;
  }

  void deleteList(String listId) {
    lists.remove(listId);
    items.remove(listId);
  }

  void addItem(String listId, String titleId) => _addItem(listId, titleId);

  void removeItem(String listId, String titleId) {
    final current = items[listId]!..removeWhere((i) => i.titleId == titleId);
    for (var i = 0; i < current.length; i++) {
      current[i] = current[i].copyWith(position: i);
    }
    lists[listId] = lists[listId]!.copyWith(itemCount: current.length);
  }

  void reorder(String listId, List<String> titleIds) {
    final current = items[listId]!;
    final byTitle = {for (final i in current) i.titleId: i};
    final next = <ListItem>[];
    for (var i = 0; i < titleIds.length; i++) {
      final item = byTitle[titleIds[i]];
      if (item != null) next.add(item.copyWith(position: i));
    }
    items[listId] = next;
  }

  ProfileCounts countsFor(String profileId, {required String viewer}) {
    final mine = entries.values.where((e) => e.userId == profileId);
    final visibleLists = lists.values.where((l) => l.userId == profileId && (!l.isPrivate || viewer == profileId));
    final isOther = others.values.any((p) => p.id == profileId);
    return ProfileCounts(
      followers: isOther ? 128 : 3,
      following: isOther ? 64 : 5,
      watched: mine.where((e) => e.status == EntryStatus.watched).length,
      reviews: mine.where((e) => e.hasReview).length,
      lists: visibleLists.length,
    );
  }

  List<StatsRow> statsRows(String profileId) {
    return entries.values.where((e) => e.userId == profileId).map((e) {
      final fixture = fixtureTitles.firstWhere((t) => t.title.id == e.titleId);
      final t = fixture.title;
      final providerIds = fixture.availability
          .where((a) => a.offerType == OfferType.flatrate || a.offerType == OfferType.ads)
          .map((a) => a.provider.parentId ?? a.providerId)
          .toSet()
          .toList()
        ..sort();
      return StatsRow(
        status: e.status,
        watchCount: e.watchCount,
        episodesWatched: e.episodesWatched,
        mediaType: t.mediaType,
        runtimeMinutes: t.runtimeMinutes,
        episodeRunTime: t.episodeRunTime,
        numberOfEpisodes: t.numberOfEpisodes,
        genres: t.genres,
        year: t.year,
        providerIds: providerIds,
      );
    }).toList();
  }
}

/// Diário de amostra. `failWrites` simula o servidor recusando (para ver a
/// interface otimista desfazer com aviso).
class FixtureEntriesRepository implements EntriesRepository {
  FixtureEntriesRepository(this._store, this._auth, {this.latency = const Duration(milliseconds: 200), this.failWrites = false});

  final FixtureDiaryStore _store;
  final FixtureAuthRepository _auth;
  final Duration latency;
  bool failWrites;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    _store.ensureSeeded(user.id);
    return user.id;
  }

  Future<void> _write() async {
    await Future<void>.delayed(latency);
    if (failWrites) throw const AppException('internal', 'Simulação: o servidor recusou a gravação.');
  }

  @override
  Future<Entry?> forTitle(String titleId) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    return _store.entries[FixtureDiaryStore.key(uid, titleId)];
  }

  @override
  Future<Entry> save(EntryDraft draft) async {
    final uid = _uid;
    await _write();
    if (!isValidRating(draft.normalized().rating)) {
      throw const AppException('invalid', 'Nota inválida: use meias estrelas de 0,5 a 5.');
    }
    return _store.upsert(uid, draft);
  }

  @override
  Future<void> remove(String titleId) async {
    final uid = _uid;
    await _write();
    _store.remove(uid, titleId);
  }

  @override
  Future<List<Entry>> byUser(String userId, {EntryStatus? status, bool onlyReviews = false, int offset = 0, int limit = 30}) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    if (!_store.canView(uid, userId)) return const [];
    var list = _store.entries.values.where((e) => e.userId == userId);
    if (status != null) list = list.where((e) => e.status == status);
    if (onlyReviews) list = list.where((e) => e.hasReview);
    final sorted = list.toList()
      ..sort((a, b) {
        if (status == EntryStatus.watched) {
          final byDate = (b.watchedAt ?? DateTime(0)).compareTo(a.watchedAt ?? DateTime(0));
          if (byDate != 0) return byDate;
        }
        return (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0));
      });
    if (offset >= sorted.length) return const [];
    return sorted.sublist(offset, (offset + limit).clamp(0, sorted.length));
  }
}

class FixtureListsRepository implements ListsRepository {
  FixtureListsRepository(this._store, this._auth, {this.latency = const Duration(milliseconds: 200), this.failWrites = false});

  final FixtureDiaryStore _store;
  final FixtureAuthRepository _auth;
  final Duration latency;
  bool failWrites;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    _store.ensureSeeded(user.id);
    return user.id;
  }

  Future<void> _write() async {
    await Future<void>.delayed(latency);
    if (failWrites) throw const AppException('internal', 'Simulação: o servidor recusou a gravação.');
  }

  bool _visible(ListModel l, String viewer) =>
      l.userId == viewer || (!l.isPrivate && _store.canView(viewer, l.userId));

  @override
  Future<List<ListModel>> byUser(String userId) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    return _store.lists.values.where((l) => l.userId == userId && _visible(l, uid)).toList()
      ..sort((a, b) => (b.updatedAt ?? DateTime(0)).compareTo(a.updatedAt ?? DateTime(0)));
  }

  @override
  Future<ListModel?> get(String listId) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    final l = _store.lists[listId];
    return (l != null && _visible(l, uid)) ? l : null;
  }

  @override
  Future<ListModel> create(ListDraft draft) async {
    final uid = _uid;
    final error = validateListName(draft.name);
    if (error != null) throw AppException('invalid', error);
    await _write();
    return _store.createList(uid, draft.copyWith(name: draft.name.trim()));
  }

  @override
  Future<ListModel> update(String listId, ListDraft draft) async {
    _own(listId);
    final error = validateListName(draft.name);
    if (error != null) throw AppException('invalid', error);
    await _write();
    return _store.updateList(listId, draft.copyWith(name: draft.name.trim()));
  }

  @override
  Future<void> delete(String listId) async {
    _own(listId);
    await _write();
    _store.deleteList(listId);
  }

  @override
  Future<List<ListItem>> items(String listId) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    final l = _store.lists[listId];
    if (l == null || !_visible(l, uid)) return const [];
    return List.unmodifiable(_store.items[listId] ?? const []);
  }

  @override
  Future<void> addItem(String listId, String titleId) async {
    _own(listId);
    await _write();
    _store.addItem(listId, titleId);
  }

  @override
  Future<void> removeItem(String listId, String titleId) async {
    _own(listId);
    await _write();
    _store.removeItem(listId, titleId);
  }

  @override
  Future<void> reorder(String listId, List<String> titleIdsInOrder) async {
    _own(listId);
    await _write();
    _store.reorder(listId, titleIdsInOrder);
  }

  @override
  Future<Set<String>> myListIdsContaining(String titleId) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    return {
      for (final l in _store.lists.values)
        if (l.userId == uid && (_store.items[l.id] ?? const []).any((i) => i.titleId == titleId)) l.id,
    };
  }

  void _own(String listId) {
    final uid = _uid;
    final l = _store.lists[listId];
    if (l == null || l.userId != uid) {
      throw const AppException('forbidden', 'Você só pode mexer nas suas listas.');
    }
  }
}

/// Perfil em memória: nasce com @ provisório e sem onboarding, como o trigger
/// do banco faria. Conhece `@foxer` e `@camila` (FixtureDiaryStore).
class FixtureProfileRepository implements ProfileRepository {
  FixtureProfileRepository(this._auth, this._store, {this.latency = const Duration(milliseconds: 200), Profile? initial})
      : _profile = initial;

  final FixtureAuthRepository _auth;
  final FixtureDiaryStore _store;
  final Duration latency;
  Profile? _profile;

  /// @ já tomados, para a tela de username ter o caso "em uso".
  static const taken = {'foxer', 'camila', 'rafael'};

  Profile get _current {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return _profile ??= Profile(
      id: user.id,
      username: 'u_${user.id.hashCode.toRadixString(16).padLeft(10, '0').substring(0, 10)}',
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Profile> getMyProfile() async {
    await Future<void>.delayed(latency);
    return _current;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    await Future<void>.delayed(latency);
    return !taken.contains(username) || username == _current.username;
  }

  @override
  Future<Profile> saveUsername(String username, {String? displayName}) async {
    await Future<void>.delayed(latency);
    if (taken.contains(username)) throw const AppException('taken', 'Esse @ já está em uso.');
    return _profile = _current.copyWith(
      username: username,
      displayName: (displayName == null || displayName.trim().isEmpty) ? _current.displayName : displayName.trim(),
    );
  }

  @override
  Future<Profile> completeOnboarding() async {
    await Future<void>.delayed(latency);
    return _profile = _current.copyWith(onboardedAt: DateTime.now());
  }

  @override
  Future<Profile?> getByUsername(String username) async {
    final me = _current;
    await Future<void>.delayed(latency);
    if (username == me.username) return me;
    return FixtureDiaryStore.others[username];
  }

  @override
  Future<Profile> updateCard(ProfileCardDraft draft) async {
    final me = _current;
    await Future<void>.delayed(latency);
    String? clean(String? s) => (s == null || s.trim().isEmpty) ? null : s.trim();
    if ((clean(draft.bio)?.length ?? 0) > 280) throw const AppException('invalid', 'Bio até 280 caracteres.');
    return _profile = me.copyWith(displayName: clean(draft.displayName), bio: clean(draft.bio));
  }

  @override
  Future<Profile> setPrivate(bool isPrivate) async {
    final me = _current;
    await Future<void>.delayed(latency);
    return _profile = me.copyWith(isPrivate: isPrivate);
  }

  @override
  Future<Profile> uploadAvatar(Uint8List bytes, {String contentType = 'image/jpeg'}) async {
    final me = _current;
    await Future<void>.delayed(latency);
    // Sem Storage aqui: a URL é fictícia e a tela mostra o placeholder.
    return _profile = me.copyWith(avatarUrl: 'https://fixtures.invalid/avatars/${me.id}/avatar.jpg?v=${DateTime.now().millisecondsSinceEpoch}');
  }

  @override
  Future<ProfileCounts> counts(String profileId) async {
    final me = _current;
    _store.ensureSeeded(me.id);
    await Future<void>.delayed(latency);
    return _store.countsFor(profileId, viewer: me.id);
  }

  @override
  Future<bool> canViewContent(String profileId) async {
    final me = _current;
    await Future<void>.delayed(latency);
    return _store.canView(me.id, profileId);
  }

  @override
  Future<List<StatsRow>> statsRows(String profileId) async {
    final me = _current;
    _store.ensureSeeded(me.id);
    await Future<void>.delayed(latency);
    if (!_store.canView(me.id, profileId)) return const [];
    return _store.statsRows(profileId);
  }
}
