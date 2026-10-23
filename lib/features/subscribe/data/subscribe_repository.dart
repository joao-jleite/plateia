import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../diary/domain/entry.dart';
import '../../feed/domain/activity.dart';
import '../domain/recommendation.dart';
import '../domain/subscribe_models.dart';

/// Dados da aba Assinar (SPEC §J5): preços de tabela (`provider_prices`,
/// só leitura), minhas assinaturas (`user_subscriptions`, só o dono), a
/// disponibilidade **em cache** dos títulos candidatos (`title_availability`
/// + `title_sync`) e o que os amigos assistiram (view `feed`). Tudo direto no
/// PostgREST com o JWT; nenhuma chamada a Edge Function: a conta nunca gasta
/// cota de API (sem cache = "sem dados", nunca buscar em lote).
abstract class SubscribeRepository {
  /// Teto de registros "quero ver"/"assistindo" que entram na conta.
  static const maxCandidates = 500;

  /// Quantas atividades do feed olhar para os títulos dos amigos.
  static const friendsActivityLimit = 200;

  Future<List<ProviderPrice>> prices();

  /// Meus registros em "Quero ver" e "Assistindo" com o título embutido, mais
  /// os ids de tudo o que está no meu diário (para excluir dos amigos).
  Future<List<Entry>> myEntries();

  /// Atividades recentes de quem eu sigo (a view `feed`, sem as minhas).
  Future<List<Activity>> friendsActivity({required DateTime since});

  /// titleId → ofertas em cache (variante já resolvida no streaming principal).
  /// Título sem `title_sync.providers_fetched_at` **não entra no mapa**.
  Future<Map<String, List<CachedOffer>>> availabilityFor(List<String> titleIds);

  Future<List<UserSubscription>> mySubscriptions();

  /// Upsert em (user_id, provider_id). Devolve a linha gravada com o streaming.
  Future<UserSubscription> saveSubscription(SubscriptionDraft draft);

  Future<void> removeSubscription(int providerId);
}

class SupabaseSubscribeRepository implements SubscribeRepository {
  SupabaseSubscribeRepository(this._client);

  final SupabaseClient _client;

  static const _subscriptionSelect = '*, provider:providers(*)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  @override
  Future<List<ProviderPrice>> prices() async {
    final rows = await _client.from('provider_prices').select().order('provider_id').order('plan');
    return rows.map(ProviderPrice.fromJson).toList();
  }

  @override
  Future<List<Entry>> myEntries() async {
    final uid = _uid;
    // Candidatos com o título (para nome, pôster e rota)…
    final candidates = await _client
        .from('entries')
        .select('*, title:titles(*)')
        .eq('user_id', uid)
        .inFilter('status', const ['want', 'watching'])
        .order('updated_at', ascending: false)
        .limit(SubscribeRepository.maxCandidates);
    // …e o resto só com o id, para excluir dos títulos dos amigos.
    final watched = await _client.from('entries').select('id, title_id, status').eq('user_id', uid).eq('status', 'watched');
    return [
      ...candidates.map(Entry.fromJson),
      for (final r in watched)
        Entry(id: r['id'] as String, userId: uid, titleId: r['title_id'] as String, status: EntryStatus.watched),
    ];
  }

  @override
  Future<List<Activity>> friendsActivity({required DateTime since}) async {
    final rows = await _client
        .from('feed')
        .select('*, user:profiles(*), title:titles(*)')
        .neq('user_id', _uid)
        .inFilter('kind', const ['watched', 'rated', 'reviewed'])
        .gte('created_at', since.toUtc().toIso8601String())
        .order('created_at', ascending: false)
        .limit(SubscribeRepository.friendsActivityLimit);
    return rows.map(Activity.fromJson).toList();
  }

  @override
  Future<Map<String, List<CachedOffer>>> availabilityFor(List<String> titleIds) async {
    final result = <String, List<CachedOffer>>{};
    // `in` com centenas de ids estoura a URL: lotes de 100.
    for (var i = 0; i < titleIds.length; i += 100) {
      final chunk = titleIds.sublist(i, (i + 100).clamp(0, titleIds.length));
      final synced = await _client
          .from('title_sync')
          .select('title_id')
          .eq('region', 'BR')
          .inFilter('title_id', chunk)
          .not('providers_fetched_at', 'is', null);
      for (final r in synced) {
        result[r['title_id'] as String] = [];
      }
      final offers = await _client
          .from('title_availability')
          .select('title_id, provider_id, offer_type, provider:providers(parent_id)')
          .eq('region', 'BR')
          .inFilter('title_id', chunk);
      for (final r in offers) {
        final type = _offerType(r['offer_type'] as String?);
        if (type == null) continue;
        final provider = r['provider'];
        final parent = provider is Map ? provider['parent_id'] as int? : null;
        // uma linha de disponibilidade sem title_sync não deveria existir;
        // se existir, ela prova que houve consulta
        result.putIfAbsent(r['title_id'] as String, () => []).add(
              CachedOffer(providerId: parent ?? (r['provider_id'] as int), offerType: type),
            );
      }
    }
    return result;
  }

  static OfferType? _offerType(String? value) => switch (value) {
        'flatrate' => OfferType.flatrate,
        'ads' => OfferType.ads,
        'free' => OfferType.free,
        'rent' => OfferType.rent,
        'buy' => OfferType.buy,
        _ => null,
      };

  @override
  Future<List<UserSubscription>> mySubscriptions() async {
    final rows = await _client.from('user_subscriptions').select(_subscriptionSelect).eq('user_id', _uid).order('provider_id');
    return rows.map(UserSubscription.fromJson).toList();
  }

  @override
  Future<UserSubscription> saveSubscription(SubscriptionDraft draft) async {
    try {
      final row = await _client
          .from('user_subscriptions')
          .upsert({
            'user_id': _uid,
            'provider_id': draft.providerId,
            'plan': draft.plan?.dbValue,
            'price_cents': draft.priceCents,
            'started_on': _dateOnly(draft.startedOn),
            'renews_on': _dateOnly(draft.renewsOn),
            'remind_before_renewal': draft.remindBeforeRenewal,
          }, onConflict: 'user_id,provider_id')
          .select(_subscriptionSelect)
          .single();
      return UserSubscription.fromJson(row);
    } on PostgrestException catch (e) {
      throw switch (e.code) {
        '23514' => AppException('invalid', 'O servidor recusou: plano ou preço inválidos.', cause: e),
        '42501' => AppException('forbidden', 'Você só pode mexer nas suas assinaturas.', cause: e),
        _ => AppException('internal', describeError(e), cause: e),
      };
    }
  }

  @override
  Future<void> removeSubscription(int providerId) async {
    await _client.from('user_subscriptions').delete().eq('user_id', _uid).eq('provider_id', providerId);
  }

  /// Coluna `date`: só a parte da data, no fuso local da pessoa.
  static String? _dateOnly(DateTime? d) {
    if (d == null) return null;
    final l = d.toLocal();
    return '${l.year.toString().padLeft(4, '0')}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
  }
}
