import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/catalog/domain/catalog_models.dart';
import 'package:watchlog/features/subscribe/domain/recommendation.dart';
import 'package:watchlog/features/subscribe/domain/recommender.dart';
import 'package:watchlog/features/subscribe/domain/subscribe_models.dart';

// ─── Streamings e preços de teste (espelham o seed da migração 0001) ─────────
//   Netflix       8    standard 44,90 · ads 20,90
//   Prime Video   119  standard 19,90
//   Disney+       337  standard 43,90 · ads 27,90
//   HBO Max       1899 standard 39,90 · ads 29,90
//   Globoplay     307  standard 24,90
//   Apple TV+     350  standard 21,90
//   Paramount+    531  standard 19,90
//   Crunchyroll   283  standard 16,99
const netflix = StreamingProvider(id: 8, slug: 'netflix', name: 'Netflix', isFeatured: true, displayOrder: 1);
const prime = StreamingProvider(id: 119, slug: 'prime', name: 'Prime Video', isFeatured: true, displayOrder: 2);
const disney = StreamingProvider(id: 337, slug: 'disney', name: 'Disney+', isFeatured: true, displayOrder: 3);
const max = StreamingProvider(id: 1899, slug: 'max', name: 'HBO Max', isFeatured: true, displayOrder: 4);
const globoplay = StreamingProvider(id: 307, slug: 'globoplay', name: 'Globoplay', isFeatured: true, displayOrder: 5);
const apple = StreamingProvider(id: 350, slug: 'apple', name: 'Apple TV+', isFeatured: true, displayOrder: 6);
const paramount = StreamingProvider(id: 531, slug: 'paramount', name: 'Paramount+', isFeatured: true, displayOrder: 7);
const crunchyroll = StreamingProvider(id: 283, slug: 'crunchyroll', name: 'Crunchyroll', isFeatured: true, displayOrder: 8);
const providers = [netflix, prime, disney, max, globoplay, apple, paramount, crunchyroll];

final now = DateTime(2026, 10, 23, 12);
final priced = DateTime(2026, 10, 22, 9);

ProviderPrice price(int providerId, PricePlan plan, int cents, {DateTime? updatedAt, bool estimate = true}) =>
    ProviderPrice(providerId: providerId, plan: plan, planLabel: plan.labelPtBr, priceCents: cents, isEstimate: estimate, updatedAt: updatedAt ?? priced);

final prices = [
  price(8, PricePlan.ads, 2090),
  price(8, PricePlan.standard, 4490),
  price(8, PricePlan.premium, 5990),
  price(119, PricePlan.standard, 1990),
  price(337, PricePlan.ads, 2790),
  price(337, PricePlan.standard, 4390),
  price(1899, PricePlan.ads, 2990),
  price(1899, PricePlan.standard, 3990),
  price(1899, PricePlan.premium, 5590),
  price(307, PricePlan.standard, 2490),
  price(350, PricePlan.standard, 2190),
  price(531, PricePlan.standard, 1990),
  price(283, PricePlan.standard, 1699),
  price(283, PricePlan.premium, 2299),
];

Candidate mine(String id, String name) => Candidate(titleId: id, name: name, source: CandidateSource.mine, mediaType: MediaType.tv);
Candidate friend(String id, String name, {String by = 'vini'}) =>
    Candidate(titleId: id, name: name, source: CandidateSource.friends, friendUsername: by);

CachedOffer sub(StreamingProvider p) => CachedOffer(providerId: p.id, offerType: OfferType.flatrate);
CachedOffer ads(StreamingProvider p) => CachedOffer(providerId: p.id, offerType: OfferType.ads);
CachedOffer rent(StreamingProvider p) => CachedOffer(providerId: p.id, offerType: OfferType.rent);
CachedOffer buy(StreamingProvider p) => CachedOffer(providerId: p.id, offerType: OfferType.buy);
CachedOffer free(StreamingProvider p) => CachedOffer(providerId: p.id, offerType: OfferType.free);

RecommendInput input(
  List<Candidate> candidates,
  Map<String, List<CachedOffer>> availability, {
  Set<int> mySubscriptions = const {},
  bool acceptAds = false,
  List<ProviderPrice>? priceList,
  DateTime? at,
}) =>
    RecommendInput(
      candidates: candidates,
      availability: availability,
      providers: providers,
      prices: priceList ?? prices,
      mySubscriptions: mySubscriptions,
      acceptAds: acceptAds,
      now: at ?? now,
    );

List<String> names(Iterable<Candidate> cs) => cs.map((c) => c.name).toList();

void main() {
  group('a lista de 12 títulos ("Pronto quando")', () {
    // Conta à mão.
    //   HBO Max:     The Last of Us, Duna 2, Succession, The White Lotus,
    //                House of the Dragon, Euphoria, Barbie, The Penguin      → 8
    //   Netflix:     Stranger Things, One Piece                              → 2
    //   Crunchyroll: One Piece                                               → 1
    //   Prime Video: só compra (TLOU) e aluguel (Barbie, Oppenheimer)        → 0
    //   Apple TV+:   só compra (Duna 2) e aluguel (Oppenheimer)              → 0
    //   Oppenheimer: só aluguel/compra                                       → "à parte"
    //   Cidade de Deus: nunca consultado                                     → "sem dados"
    //
    //   Melhor: HBO Max, 8 de 12, R$ 39,90 → 3990 / 8 = 498,75 → R$ 4,99 por título.
    //   Combinação: Netflix acrescentaria 2 (< 3) e Crunchyroll 1 → não vale.
    //   Ficam de fora (em assinatura): Stranger Things [Netflix], One Piece [Netflix, Crunchyroll].
    final candidates = [
      mine('tlou', 'The Last of Us'),
      mine('duna2', 'Duna: Parte Dois'),
      mine('succession', 'Succession'),
      mine('lotus', 'The White Lotus'),
      mine('hotd', 'House of the Dragon'),
      mine('euphoria', 'Euphoria'),
      mine('barbie', 'Barbie'),
      mine('penguin', 'The Penguin'),
      mine('st', 'Stranger Things'),
      mine('onepiece', 'One Piece'),
      mine('oppenheimer', 'Oppenheimer'),
      mine('cidade', 'Cidade de Deus'),
    ];
    final availability = {
      'tlou': [sub(max), buy(prime)],
      'duna2': [sub(max), buy(apple)],
      'succession': [sub(max)],
      'lotus': [sub(max)],
      'hotd': [sub(max)],
      'euphoria': [sub(max)],
      'barbie': [sub(max), rent(prime)],
      'penguin': [sub(max)],
      'st': [sub(netflix), ads(netflix)],
      'onepiece': [sub(netflix), sub(crunchyroll), ads(crunchyroll)],
      'oppenheimer': [rent(apple), buy(apple), rent(prime)],
      // 'cidade' ausente de propósito: sem cache
    };

    test('a recomendação bate com a conta à mão', () {
      final r = recommend(input(candidates, availability));

      expect(r.totalMine, 12);
      expect(r.totalFriends, 0);
      expect(r.best!.provider, max);
      expect(r.best!.resolved.length, 8);
      expect(r.best!.resolvedMine, 8);
      expect(r.best!.price.priceCents, 3990);
      expect(r.best!.costPerTitleCents, 499, reason: '3990 / 8 = 498,75 → arredonda para 499');
      expect(r.combo, isNull, reason: 'Netflix acrescenta 2 e Crunchyroll 1: menos de 3');

      // ranking: só quem resolve algo, HBO Max (8) > Netflix (2) > Crunchyroll (1)
      expect(r.ranking.map((s) => s.provider.name).toList(), ['HBO Max', 'Netflix', 'Crunchyroll']);
      expect(r.ranking[1].resolved.length, 2);
      expect(r.ranking[2].resolved.length, 1);
      expect(r.resolvingNothing.map((p) => p.name).toList(), ['Prime Video', 'Disney+', 'Globoplay', 'Apple TV+', 'Paramount+']);

      expect(names(r.leftOut.map((l) => l.candidate)), ['Stranger Things', 'One Piece']);
      expect(r.leftOut[1].providers.map((p) => p.name).toList(), ['Netflix', 'Crunchyroll']);
      expect(names(r.rentOnly), ['Oppenheimer']);
      expect(names(r.noData), ['Cidade de Deus']);
      expect(r.unavailable, isEmpty);
      expect(r.freeOnly, isEmpty);
      expect(r.elsewhere, isEmpty);

      expect(r.pricesUpdatedAt, priced);
      expect(r.anyEstimate, isTrue);
      expect(r.headline, 'Este mês, assine a HBO Max: ela resolve 8 dos seus 12 títulos, por R\$ 39,90.');
    });

    test('se já assino a melhor, a frase muda e não manda assinar outra', () {
      final r = recommend(input(candidates, availability, mySubscriptions: {1899}));
      expect(r.best!.alreadySubscribed, isTrue);
      expect(r.headline, 'Você já assina a HBO Max: ela resolve 8 dos seus 12 títulos, por R\$ 39,90. Não precisa de outra este mês.');
    });
  });

  group('casos fixos', () {
    test('lista vazia: nada a recomendar', () {
      final r = recommend(input(const [], const {}));
      expect(r.isEmpty, isTrue);
      expect(r.best, isNull);
      expect(r.ranking, isEmpty);
      expect(r.headline, isNull);
      expect(r.pricesUpdatedAt, priced, reason: 'a data dos preços aparece mesmo sem lista');
    });

    test('nenhum título em assinatura: frase explica em vez de recomendar', () {
      final r = recommend(input([mine('a', 'A'), mine('b', 'B')], {
        'a': [rent(apple)],
        'b': const [],
      }));
      expect(r.best, isNull);
      expect(names(r.rentOnly), ['A']);
      expect(names(r.unavailable), ['B']);
      expect(r.headline, 'Nenhum dos seus 2 títulos está em streaming por assinatura agora.');
    });

    test('empate: menor preço ganha; depois o que já assino; depois a ordem de exibição', () {
      // Paramount+ (19,90) e Apple TV+ (21,90) resolvem o mesmo título → Paramount+ (mais barata).
      var r = recommend(input([mine('a', 'A')], {
        'a': [sub(apple), sub(paramount)],
      }));
      expect(r.best!.provider, paramount);

      // Prime Video e Paramount+ custam o mesmo (19,90): já assino a Paramount+ → ela.
      r = recommend(input([mine('a', 'A')], {
        'a': [sub(prime), sub(paramount)],
      }, mySubscriptions: {531}));
      expect(r.best!.provider, paramount);

      // Mesmo preço, não assino nenhuma → ordem de exibição (Prime Video vem antes).
      r = recommend(input([mine('a', 'A')], {
        'a': [sub(prime), sub(paramount)],
      }));
      expect(r.best!.provider, prime);
      expect(r.ranking.map((s) => s.provider).toList(), [prime, paramount]);
    });

    test('título em vários streamings conta para cada um e só fica de fora uma vez', () {
      // A: Netflix e Crunchyroll; B: Netflix; C: HBO Max.
      //   Netflix 2 (A, B) > Crunchyroll 1 (A) = HBO Max 1 (C); Crunchyroll mais barata → 2ª.
      final r = recommend(input([mine('a', 'A'), mine('b', 'B'), mine('c', 'C')], {
        'a': [sub(netflix), sub(crunchyroll)],
        'b': [sub(netflix)],
        'c': [sub(max)],
      }));
      expect(r.ranking.map((s) => s.provider.name).toList(), ['Netflix', 'Crunchyroll', 'HBO Max']);
      expect(names(r.ranking[1].resolved), ['A']);
      expect(names(r.leftOut.map((l) => l.candidate)), ['C'], reason: 'A está resolvido pela Netflix; só C fica de fora');
    });

    test('título em nenhum streaming (cache vazio) não conta para ninguém e vai para "em nenhum"', () {
      final r = recommend(input([mine('a', 'A'), mine('b', 'B')], {
        'a': [sub(netflix)],
        'b': const [],
      }));
      expect(r.best!.provider, netflix);
      expect(r.best!.resolved.length, 1);
      expect(names(r.unavailable), ['B']);
      expect(r.headline, 'Este mês, assine a Netflix: ela resolve 1 dos seus 2 títulos, por R\$ 44,90.');
    });

    test('sem dados ≠ em nenhum: chave ausente nunca vira chute', () {
      final r = recommend(input([mine('a', 'A'), mine('b', 'B'), mine('c', 'C')], {
        'a': [sub(netflix)],
        'c': const [],
      }));
      expect(names(r.noData), ['B']);
      expect(names(r.unavailable), ['C']);
      expect(r.best!.resolved.length, 1);
    });

    test('preço desatualizado: mais de 60 dias marca aviso; 60 exatos não', () {
      final old = [
        ...prices.where((p) => p.providerId != 8 && p.providerId != 1899),
        price(8, PricePlan.standard, 4490, updatedAt: now.subtract(const Duration(days: 61))),
        price(1899, PricePlan.standard, 3990, updatedAt: now.subtract(const Duration(days: 60))),
      ];
      final r = recommend(input([mine('a', 'A'), mine('b', 'B')], {
        'a': [sub(netflix)],
        'b': [sub(max)],
      }, priceList: old));
      final byName = {for (final s in r.ranking) s.provider.name: s};
      expect(byName['Netflix']!.priceStale, isTrue);
      expect(byName['HBO Max']!.priceStale, isFalse);
      // a linha "Preços de…" mostra a conferida mais recente; o velho avisa no cartão
      expect(r.pricesUpdatedAt, priced);
    });

    test('combinação de 2 que vale: acrescenta ≥ 3 e baixa o custo por título', () {
      // HBO Max resolve 8 por 39,90 (R$ 4,99/título). Crunchyroll acrescenta 4 animes por 16,99:
      //   (3990 + 1699) / 12 = 474,08 → R$ 4,74 < R$ 4,99 → vale.
      final candidates = [
        for (var i = 1; i <= 8; i++) mine('h$i', 'HBO $i'),
        for (var i = 1; i <= 4; i++) mine('c$i', 'Anime $i'),
      ];
      final availability = {
        for (var i = 1; i <= 8; i++) 'h$i': [sub(max)],
        for (var i = 1; i <= 4; i++) 'c$i': [sub(crunchyroll)],
      };
      final r = recommend(input(candidates, availability));
      expect(r.best!.provider, max);
      expect(r.combo!.provider, crunchyroll);
      expect(r.comboAdded.length, 4);
      expect(r.leftOut, isEmpty);
      expect(
        r.headline,
        'Este mês, assine a HBO Max: ela resolve 8 dos seus 12 títulos, por R\$ 39,90. '
        'A Crunchyroll acrescenta mais 4 por R\$ 16,99: juntas saem a R\$ 4,74 por título.',
      );
    });

    test('combinação de 2 que não vale: acrescenta 3 mas encarece o título', () {
      // HBO Max 8 por 39,90 (4,99). Netflix acrescenta 3 por 44,90:
      //   (3990 + 4490) / 11 = 770,9 → R$ 7,71 > R$ 4,99 → não vale.
      final candidates = [
        for (var i = 1; i <= 8; i++) mine('h$i', 'HBO $i'),
        for (var i = 1; i <= 3; i++) mine('n$i', 'Netflix $i'),
      ];
      final availability = {
        for (var i = 1; i <= 8; i++) 'h$i': [sub(max)],
        for (var i = 1; i <= 3; i++) 'n$i': [sub(netflix)],
      };
      final r = recommend(input(candidates, availability));
      expect(r.best!.provider, max);
      expect(r.combo, isNull);
      expect(names(r.leftOut.map((l) => l.candidate)), ['Netflix 1', 'Netflix 2', 'Netflix 3']);
      expect(r.headline, 'Este mês, assine a HBO Max: ela resolve 8 dos seus 11 títulos, por R\$ 39,90.');
    });

    test('combinação só conta títulos que o primeiro não resolve', () {
      // HBO Max 8; Netflix tem 5 dos mesmos 8 + 2 novos → acrescenta 2 (< 3) → não vale.
      final candidates = [for (var i = 1; i <= 10; i++) mine('t$i', 'T$i')];
      final availability = {
        for (var i = 1; i <= 8; i++) 't$i': [sub(max), if (i <= 5) sub(netflix)],
        't9': [sub(netflix)],
        't10': [sub(netflix)],
      };
      final r = recommend(input(candidates, availability));
      expect(r.best!.provider, max);
      expect(r.ranking[1].provider, netflix);
      expect(r.ranking[1].resolved.length, 7);
      expect(r.combo, isNull);
    });

    test('chave "aceito anúncios": usa o plano com anúncios quando existe e pode virar o jogo', () {
      // HBO Max 5 por 39,90 (R$ 7,98/título). Netflix acrescenta 3:
      //   padrão 44,90 → (3990 + 4490) / 8 = R$ 10,60 > 7,98 → não vale;
      //   com anúncios 20,90 → (3990 + 2090) / 8 = R$ 7,60 < 7,98 → vale.
      final candidates = [
        for (var i = 1; i <= 5; i++) mine('h$i', 'HBO $i'),
        for (var i = 1; i <= 3; i++) mine('n$i', 'Netflix $i'),
      ];
      final availability = {
        for (var i = 1; i <= 5; i++) 'h$i': [sub(max)],
        for (var i = 1; i <= 3; i++) 'n$i': [sub(netflix), ads(netflix)],
      };
      final standard = recommend(input(candidates, availability));
      expect(standard.combo, isNull);
      expect(standard.ranking[1].price.plan, PricePlan.standard);

      final withAds = recommend(input(candidates, availability, acceptAds: true));
      expect(withAds.best!.price.plan, PricePlan.ads, reason: 'HBO Max também tem plano com anúncios (29,90)');
      expect(withAds.best!.price.priceCents, 2990);
      expect(withAds.ranking[1].price.plan, PricePlan.ads);
      expect(withAds.ranking[1].price.priceCents, 2090);
      // HBO Max 5 por 29,90 = R$ 5,98; + Netflix ads 20,90 → (2990 + 2090) / 8 = R$ 6,35 > 5,98 → não vale
      expect(withAds.combo, isNull);

      // Prime Video não tem plano com anúncios: continua no padrão
      final prime1 = recommend(input([mine('a', 'A')], {'a': [sub(prime)]}, acceptAds: true));
      expect(prime1.best!.price.plan, PricePlan.standard);
    });

    test('títulos dos amigos pesam 0,3: três deles perdem para um meu', () {
      // Crunchyroll: 3 dos amigos = 0,9; Paramount+: 1 meu = 1,0 → Paramount+ primeiro.
      final r = recommend(input([
        mine('y', 'Yellowstone'),
        friend('f1', 'Frieren'),
        friend('f2', 'Dandadan', by: 'foxer'),
        friend('f3', 'Jujutsu Kaisen'),
      ], {
        'y': [sub(paramount)],
        'f1': [sub(crunchyroll)],
        'f2': [sub(crunchyroll)],
        'f3': [sub(crunchyroll)],
      }));
      expect(r.totalMine, 1);
      expect(r.totalFriends, 3);
      expect(r.ranking.map((s) => s.provider.name).toList(), ['Paramount+', 'Crunchyroll']);
      expect(r.ranking[0].score, 1.0);
      expect(r.ranking[1].score, closeTo(0.9, 1e-9));
      // a combinação também é em peso: 0,9 acrescentado < 3 → a Crunchyroll não entra na frase
      expect(r.combo, isNull);
      expect(r.headline, 'Este mês, assine o Paramount+: ele resolve o único título da sua lista, por R\$ 19,90.');
    });

    test('amigos na frase: os títulos deles aparecem como extra; sem lista minha, a frase é só deles', () {
      var r = recommend(input([mine('a', 'A'), mine('b', 'B'), friend('f', 'F')], {
        'a': [sub(netflix)],
        'b': [sub(netflix)],
        'f': [sub(netflix)],
      }));
      expect(r.best!.resolvedFriends, 1);
      expect(r.headline, 'Este mês, assine a Netflix: ela resolve todos os seus 2 títulos (e mais 1 que seus amigos estão vendo), por R\$ 44,90.');

      r = recommend(input([friend('f', 'F'), friend('g', 'G')], {
        'f': [sub(netflix)],
        'g': [sub(max)],
      }));
      expect(r.totalMine, 0);
      expect(r.best!.provider, max, reason: 'empate em 0,3: HBO Max (39,90) mais barata que Netflix (44,90)');
      expect(r.headline, 'Este mês, assine a HBO Max: ela tem 1 dos 2 títulos que seus amigos estão vendo, por R\$ 39,90.');
    });

    test('grátis, outro streaming e sem preço', () {
      // X só grátis (Globoplay free) → não precisa assinar; Y só num streaming fora da lista (Pluto, 300);
      // Z na Netflix. Se a Netflix não tem preço, Z também vira "outro streaming" e não há recomendação.
      final r = recommend(input([mine('x', 'X'), mine('y', 'Y'), mine('z', 'Z')], {
        'x': [free(globoplay)],
        'y': [const CachedOffer(providerId: 300, offerType: OfferType.flatrate)],
        'z': [sub(netflix)],
      }));
      expect(names(r.freeOnly), ['X']);
      expect(names(r.elsewhere), ['Y']);
      expect(r.best!.provider, netflix);

      final noNetflixPrice = recommend(input([mine('z', 'Z')], {'z': [sub(netflix)]}, priceList: prices.where((p) => p.providerId != 8).toList()));
      expect(noNetflixPrice.best, isNull);
      expect(names(noNetflixPrice.elsewhere), ['Z']);
    });

    test('preço conferido tira a palavra "estimativa"', () {
      final checked = [for (final p in prices) p.copyWith(isEstimate: false)];
      final r = recommend(input([mine('a', 'A')], {'a': [sub(netflix)]}, priceList: checked));
      expect(r.anyEstimate, isFalse);
    });
  });
}
