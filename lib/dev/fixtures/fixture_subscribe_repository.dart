import '../../core/errors/app_exception.dart';
import '../../features/catalog/data/catalog_repository.dart';
import '../../features/diary/domain/entry.dart';
import '../../features/feed/domain/activity.dart';
import '../../features/subscribe/data/subscribe_repository.dart';
import '../../features/subscribe/domain/recommendation.dart';
import '../../features/subscribe/domain/subscribe_models.dart';
import 'fixture_auth_repository.dart';
import 'fixture_catalog_repository.dart';
import 'fixture_data.dart';
import 'fixture_diary.dart';
import 'fixture_social.dart';

/// Aba Assinar com dados de amostra: preços do seed (`FixturePrices`), meu
/// diário e o feed de quem eu sigo (`FixtureSocialStore`), a disponibilidade
/// dos títulos de amostra como "cache" (um título com `providersCached = false`
/// só entra depois que o detalhe dele foi aberto, como `title_sync` no banco) e
/// assinaturas em memória, semeadas na primeira leitura de cada usuário.
class FixtureSubscribeRepository implements SubscribeRepository {
  FixtureSubscribeRepository(
    this._store,
    this._social,
    this._auth, {
    CatalogRepository? catalog,
    this.latency = const Duration(milliseconds: 200),
    this.failWrites = false,
    this.seed = true,
    DateTime Function()? clock,
  })  : _catalog = catalog is FixtureCatalogRepository ? catalog : null,
        _clock = clock ?? DateTime.now;

  final FixtureDiaryStore _store;
  final FixtureSocialStore? _social;
  final FixtureAuthRepository _auth;
  final FixtureCatalogRepository? _catalog;
  final Duration latency;
  final bool failWrites;
  final bool seed;
  final DateTime Function() _clock;

  /// userId → providerId → assinatura
  final Map<String, Map<int, UserSubscription>> subscriptions = {};
  final Set<String> _seeded = {};

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    _store.ensureSeeded(user.id);
    _ensureSeeded(user.id);
    return user.id;
  }

  Future<void> _read() => Future<void>.delayed(latency);

  Future<void> _write() async {
    await Future<void>.delayed(latency);
    if (failWrites) throw const AppException('internal', 'Simulação: o servidor recusou a gravação.');
  }

  /// Quem entra já assina Netflix (renova em 10 dias) e mais um: dá para ver a
  /// economia no ano e o lembrete sem marcar nada.
  void _ensureSeeded(String userId) {
    if (!seed || !_seeded.add(userId)) return;
    final today = _clock();
    final day = DateTime(today.year, today.month, today.day);
    final second = userId == FixtureDiaryStore.foxer.id ? FixtureProviders.crunchyroll : FixtureProviders.prime;
    subscriptions[userId] = {
      8: UserSubscription(
        userId: userId,
        providerId: 8,
        plan: PricePlan.standard,
        renewsOn: day.add(const Duration(days: 10)),
        startedOn: DateTime(2025, 3, 14),
        createdAt: day,
        updatedAt: day,
        provider: FixtureProviders.netflix,
      ),
      second.id: UserSubscription(
        userId: userId,
        providerId: second.id,
        plan: PricePlan.standard,
        renewsOn: day.add(const Duration(days: 21)),
        createdAt: day,
        updatedAt: day,
        provider: second,
      ),
    };
  }

  @override
  Future<List<ProviderPrice>> prices() async {
    await _read();
    return FixturePrices.all;
  }

  @override
  Future<List<Entry>> myEntries() async {
    final me = _uid;
    await _read();
    return _store.entries.values.where((e) => e.userId == me).toList();
  }

  @override
  Future<List<Activity>> friendsActivity({required DateTime since}) async {
    final me = _uid;
    await _read();
    final social = _social;
    if (social == null) return const [];
    return social
        .feedFor(me, limit: SubscribeRepository.friendsActivityLimit)
        .where((a) => a.userId != me && !a.createdAt.isBefore(since))
        .toList();
  }

  @override
  Future<Map<String, List<CachedOffer>>> availabilityFor(List<String> titleIds) async {
    await _read();
    final result = <String, List<CachedOffer>>{};
    for (final id in titleIds) {
      final fixture = fixtureTitles.where((t) => t.title.id == id).firstOrNull;
      if (fixture == null) continue;
      final cached = fixture.providersCached || (_catalog?.hasFetched(fixture.title.mediaType, fixture.title.tmdbId) ?? false);
      if (!cached) continue;
      result[id] = [
        for (final a in fixture.availability)
          CachedOffer(providerId: a.provider.parentId ?? a.providerId, offerType: a.offerType),
      ];
    }
    return result;
  }

  @override
  Future<List<UserSubscription>> mySubscriptions() async {
    final me = _uid;
    await _read();
    return (subscriptions[me]?.values.toList() ?? [])..sort((a, b) => a.providerId.compareTo(b.providerId));
  }

  @override
  Future<UserSubscription> saveSubscription(SubscriptionDraft draft) async {
    final me = _uid;
    await _write();
    final provider = FixtureProviders.byId[draft.providerId];
    if (provider == null) throw const AppException('invalid', 'Streaming desconhecido.');
    final now = _clock();
    final previous = subscriptions[me]?[draft.providerId];
    final saved = UserSubscription(
      userId: me,
      providerId: draft.providerId,
      plan: draft.plan,
      priceCents: draft.priceCents,
      startedOn: draft.startedOn,
      renewsOn: draft.renewsOn,
      remindBeforeRenewal: draft.remindBeforeRenewal,
      createdAt: previous?.createdAt ?? now,
      updatedAt: now,
      provider: provider,
    );
    (subscriptions[me] ??= {})[draft.providerId] = saved;
    return saved;
  }

  @override
  Future<void> removeSubscription(int providerId) async {
    final me = _uid;
    await _write();
    subscriptions[me]?.remove(providerId);
  }
}
