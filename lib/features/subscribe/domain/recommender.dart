// Recomendador "qual streaming assinar este mês" (SPEC §5.9 e §J5).
// Função pura: sem Flutter, Supabase ou interface. A tela monta o
// [RecommendInput] e só exibe a [Recommendation]. Toda regra está aqui e nos
// testes de `test/features/subscribe/domain/recommender_test.dart`, com a conta
// feita à mão.

import '../../../core/utils/money.dart';
import '../../catalog/domain/catalog_models.dart';
import 'recommendation.dart';
import 'subscribe_models.dart';

/// Quanto peso o segundo streaming precisa acrescentar para a combinação de
/// dois entrar na conta (SPEC §J5.3): 3 títulos meus, ou 10 de amigos.
const comboMinAdded = 3.0;

Recommendation recommend(RecommendInput input) {
  // 1. Um preço por streaming destacado: `ads` se a pessoa aceita anúncios e o
  //    plano existe; senão `standard`; senão o mais barato que houver. Sem
  //    preço nenhum, o streaming não entra na conta (seus títulos viram
  //    "em outro streaming": melhor que inventar um valor).
  final priceFor = <int, ProviderPrice>{};
  for (final p in input.providers) {
    final options = input.prices.where((x) => x.providerId == p.id).toList();
    if (options.isEmpty) continue;
    ProviderPrice? chosen;
    if (input.acceptAds) chosen = options.where((x) => x.plan == PricePlan.ads).firstOrNull;
    chosen ??= options.where((x) => x.plan == PricePlan.standard).firstOrNull;
    chosen ??= (options..sort((a, b) => a.priceCents.compareTo(b.priceCents))).first;
    priceFor[p.id] = chosen;
  }

  // 2. Cada candidato cai num balde. Chave ausente em `availability` = sem
  //    dados (nunca chutar); lista vazia = consultado e em nenhum streaming.
  final resolvedBy = <int, List<Candidate>>{for (final id in priceFor.keys) id: []};
  final resolvableProviders = <String, List<StreamingProvider>>{};
  final noData = <Candidate>[];
  final unavailable = <Candidate>[];
  final rentOnly = <Candidate>[];
  final freeOnly = <Candidate>[];
  final elsewhere = <Candidate>[];

  for (final c in input.candidates) {
    final offers = input.availability[c.titleId];
    if (offers == null) {
      noData.add(c);
      continue;
    }
    final subscription = {
      for (final o in offers)
        if (o.offerType == OfferType.flatrate || o.offerType == OfferType.ads) o.providerId,
    };
    final priced = input.providers.where((p) => subscription.contains(p.id) && priceFor.containsKey(p.id)).toList();
    if (priced.isNotEmpty) {
      for (final p in priced) {
        resolvedBy[p.id]!.add(c);
      }
      resolvableProviders[c.titleId] = priced;
    } else if (subscription.isNotEmpty) {
      elsewhere.add(c);
    } else if (offers.any((o) => o.offerType == OfferType.free)) {
      freeOnly.add(c);
    } else if (offers.any((o) => o.offerType == OfferType.rent || o.offerType == OfferType.buy)) {
      rentOnly.add(c);
    } else {
      unavailable.add(c);
    }
  }

  // 3. A conta de cada streaming, ordenada: peso (meus 1, amigos 0,3) →
  //    menor preço → já assino → ordem de exibição (SPEC §5.9, "Empate").
  final scores = <ProviderScore>[];
  for (final p in input.providers) {
    final price = priceFor[p.id];
    if (price == null) continue;
    final resolved = resolvedBy[p.id]!;
    // meus primeiro, mantendo a ordem da lista
    final ordered = [...resolved.where((c) => c.isMine), ...resolved.where((c) => !c.isMine)];
    scores.add(ProviderScore(
      provider: p,
      price: price,
      resolved: ordered,
      score: resolved.fold(0.0, (sum, c) => sum + c.weight),
      alreadySubscribed: input.mySubscriptions.contains(p.id),
      priceStale: price.isStale(input.now),
    ));
  }
  scores.sort(_compareScores);
  final ranking = scores.where((s) => s.resolved.isNotEmpty).toList();
  final resolvingNothing = [
    for (final p in input.providers)
      if (priceFor.containsKey(p.id) && resolvedBy[p.id]!.isEmpty) p,
  ];
  final best = ranking.firstOrNull;

  // 4. Combinação de dois: o segundo entra se acrescenta ≥ 3 títulos (em peso:
  //    três meus, ou dez de amigos) que o primeiro não tem e, juntos, o custo
  //    por título cai (SPEC §J5.3). Tudo em peso, a mesma medida do ranking e
  //    do "por título" da tela. Entre vários que valem: mais peso acrescentado →
  //    mais barato → posição no ranking.
  ProviderScore? combo;
  var comboAdded = const <Candidate>[];
  var comboAddedWeight = 0.0;
  if (best != null && best.score > 0) {
    final covered = {for (final c in best.resolved) c.titleId};
    final soloCost = best.price.priceCents / best.score;
    for (final s in ranking.skip(1)) {
      final added = s.resolved.where((c) => !covered.contains(c.titleId)).toList();
      final addedWeight = added.fold(0.0, (sum, c) => sum + c.weight);
      if (addedWeight < comboMinAdded) continue;
      final pairCost = (best.price.priceCents + s.price.priceCents) / (best.score + addedWeight);
      if (pairCost >= soloCost) continue;
      final better = combo == null ||
          addedWeight > comboAddedWeight ||
          (addedWeight == comboAddedWeight && s.price.priceCents < combo.price.priceCents);
      if (better) {
        combo = s;
        comboAdded = added;
        comboAddedWeight = addedWeight;
      }
    }
  }

  // 5. O que fica de fora: em assinatura, mas nem no melhor nem no segundo.
  final covered = {
    if (best != null) for (final c in best.resolved) c.titleId,
    for (final c in comboAdded) c.titleId,
  };
  final leftOut = [
    for (final c in input.candidates)
      if (resolvableProviders.containsKey(c.titleId) && !covered.contains(c.titleId))
        LeftOutTitle(candidate: c, providers: resolvableProviders[c.titleId]!),
  ];

  // 6. Data e "estimativa" dos preços usados: a linha "Preços de DD/MM" mostra
  //    a conferida mais recente; um preço velho ganha aviso no próprio cartão
  //    (`priceStale`), então a tela toda não fica carimbada com a data dele.
  DateTime? pricesUpdatedAt;
  var anyEstimate = false;
  for (final price in priceFor.values) {
    if (pricesUpdatedAt == null || price.updatedAt.isAfter(pricesUpdatedAt)) pricesUpdatedAt = price.updatedAt;
    anyEstimate = anyEstimate || price.isEstimate;
  }

  final totalMine = input.candidates.where((c) => c.isMine).length;
  final totalFriends = input.candidates.length - totalMine;

  return Recommendation(
    ranking: ranking,
    resolvingNothing: resolvingNothing,
    best: best,
    combo: combo,
    comboAdded: comboAdded,
    leftOut: leftOut,
    rentOnly: rentOnly,
    freeOnly: freeOnly,
    elsewhere: elsewhere,
    unavailable: unavailable,
    noData: noData,
    totalMine: totalMine,
    totalFriends: totalFriends,
    pricesUpdatedAt: pricesUpdatedAt,
    anyEstimate: anyEstimate,
    headline: _headline(
      hasCandidates: input.candidates.isNotEmpty,
      totalMine: totalMine,
      totalFriends: totalFriends,
      best: best,
      combo: combo,
      comboAdded: comboAdded,
    ),
  );
}

int _compareScores(ProviderScore a, ProviderScore b) {
  final byScore = b.score.compareTo(a.score);
  if (byScore != 0) return byScore;
  final byPrice = a.price.priceCents.compareTo(b.price.priceCents);
  if (byPrice != 0) return byPrice;
  if (a.alreadySubscribed != b.alreadySubscribed) return a.alreadySubscribed ? -1 : 1;
  final ao = a.provider.displayOrder ?? 1 << 20;
  final bo = b.provider.displayOrder ?? 1 << 20;
  final byOrder = ao.compareTo(bo);
  if (byOrder != 0) return byOrder;
  return a.provider.name.compareTo(b.provider.name);
}

/// Artigo do streaming na frase ("a Netflix", "o Prime Video"). Decidido pelo
/// slug dos destacados; desconhecido vai no feminino ("a"), que é o comum.
String providerArticle(StreamingProvider p) => switch (p.slug) {
      'prime' || 'disney' || 'globoplay' || 'paramount' => 'o',
      _ => 'a',
    };

String? _headline({
  required bool hasCandidates,
  required int totalMine,
  required int totalFriends,
  required ProviderScore? best,
  required ProviderScore? combo,
  required List<Candidate> comboAdded,
}) {
  if (!hasCandidates) return null;
  if (best == null) {
    if (totalMine == 1) return 'Seu único título não está em streaming por assinatura agora.';
    if (totalMine > 1) return 'Nenhum dos seus $totalMine títulos está em streaming por assinatura agora.';
    return 'Nenhum dos $totalFriends títulos que seus amigos estão vendo está em streaming por assinatura agora.';
  }

  final article = providerArticle(best.provider);
  final pronoun = article == 'a' ? 'ela' : 'ele';
  final name = best.provider.name;

  final String coverage;
  if (totalMine == 0) {
    coverage = '$pronoun tem ${best.resolvedFriends} dos $totalFriends títulos que seus amigos estão vendo';
  } else {
    final n = best.resolvedMine;
    final mineText = (totalMine == 1 && n == 1)
        ? 'o único título da sua lista'
        : n == totalMine
            ? 'todos os seus $totalMine títulos'
            : '$n dos seus $totalMine títulos';
    final friends = best.resolvedFriends;
    final extra = friends > 0 ? ' (e mais $friends que seus amigos estão vendo)' : '';
    coverage = '$pronoun resolve $mineText$extra';
  }

  final price = formatBrl(best.price.priceCents);
  final buffer = StringBuffer(
    best.alreadySubscribed
        ? 'Você já assina $article $name: $coverage, por $price.'
        : 'Este mês, assine $article $name: $coverage, por $price.',
  );

  if (combo != null) {
    final comboArticle = providerArticle(combo.provider);
    final together = (article == 'a' && comboArticle == 'a') ? 'juntas' : 'juntos';
    final addedWeight = comboAdded.fold(0.0, (sum, c) => sum + c.weight);
    final pairCost = ((best.price.priceCents + combo.price.priceCents) / (best.score + addedWeight)).round();
    buffer.write(
      ' ${comboArticle.toUpperCase()} ${combo.provider.name} acrescenta mais ${comboAdded.length} por '
      '${formatBrl(combo.price.priceCents)}: $together saem a ${formatBrl(pairCost)} por título.',
    );
  } else if (best.alreadySubscribed) {
    buffer.write(' Não precisa de outra este mês.');
  }
  return buffer.toString();
}

/// Economia estimada no ano (SPEC §J5.5): tudo o que marquei × 12 contra o
/// recomendado × 12. Cada assinatura vale o preço que a pessoa informou ou, sem
/// ele, o preço de tabela do plano dela (ou do padrão). Null quando não há como
/// calcular (nenhuma assinatura marcada ou sem recomendação). Negativo quer
/// dizer que o recomendado custa mais do que ela paga hoje.
int? yearlySavingsCents({
  required List<UserSubscription> mine,
  required List<ProviderPrice> prices,
  required int? recommendedMonthlyCents,
}) {
  if (mine.isEmpty || recommendedMonthlyCents == null) return null;
  var monthly = 0;
  for (final s in mine) {
    final cents = s.priceCents ?? monthlyPriceFor(s, prices);
    if (cents != null) monthly += cents;
  }
  return (monthly - recommendedMonthlyCents) * 12;
}

/// Preço de tabela de uma assinatura: o plano dela ou, sem plano, o padrão;
/// sem nenhum dos dois, o mais barato do streaming. Null se não há preço.
int? monthlyPriceFor(UserSubscription s, List<ProviderPrice> prices) {
  final options = prices.where((p) => p.providerId == s.providerId).toList();
  if (options.isEmpty) return null;
  final exact = options.where((p) => p.plan == (s.plan ?? PricePlan.standard)).firstOrNull;
  if (exact != null) return exact.priceCents;
  options.sort((a, b) => a.priceCents.compareTo(b.priceCents));
  return options.first.priceCents;
}

/// Quanto a pessoa paga por mês com o que marcou (mesma regra de [yearlySavingsCents]).
int monthlyTotalCents(List<UserSubscription> mine, List<ProviderPrice> prices) {
  var total = 0;
  for (final s in mine) {
    total += s.priceCents ?? monthlyPriceFor(s, prices) ?? 0;
  }
  return total;
}
