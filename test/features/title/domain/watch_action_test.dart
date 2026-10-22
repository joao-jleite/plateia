import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/dev/fixtures/fixture_data.dart';
import 'package:watchlog/features/catalog/domain/catalog_models.dart';
import 'package:watchlog/features/title/domain/watch_action.dart';

void main() {
  WatchAction resolve(StreamingProvider p, String? link) => resolveWatchAction(
        provider: p,
        deepLink: link,
        titleName: 'One Piece',
        mediaType: MediaType.tv,
        tmdbId: 37854,
      );

  group('resolveWatchAction (SPEC §5.7)', () {
    test('com deep link → "Abrir na Netflix" e abre o link', () {
      final a = resolve(FixtureProviders.netflix, 'https://www.netflix.com/title/80107103');
      expect(a.kind, WatchActionKind.deepLink);
      expect(a.label, 'Abrir na Netflix');
      expect(a.uri.toString(), 'https://www.netflix.com/title/80107103');
    });

    test('sem link mas com busca → "Buscar no Globoplay" com o título codificado', () {
      final a = resolve(FixtureProviders.globoplay, null);
      expect(a.kind, WatchActionKind.search);
      expect(a.label, 'Buscar no Globoplay');
      expect(a.uri.toString(), 'https://globoplay.globo.com/busca/?q=One+Piece');
    });

    test('Disney+ sem link e sem busca → "Abrir o Disney+" pelo pacote', () {
      final a = resolve(FixtureProviders.disney, '');
      expect(a.kind, WatchActionKind.appPackage);
      expect(a.label, 'Abrir o Disney+');
      expect(a.package, 'com.disney.disneyplus');
    });

    test('sem nada → "Ver na JustWatch" (página do TMDB em BR)', () {
      const bare = StreamingProvider(id: 999, name: 'Telecine');
      final a = resolve(bare, null);
      expect(a.kind, WatchActionKind.justwatch);
      expect(a.label, 'Ver na JustWatch');
      expect(a.uri.toString(), 'https://www.themoviedb.org/tv/37854/watch?locale=BR');
    });

    test('link que não é http é ignorado (cai para a busca)', () {
      final a = resolve(FixtureProviders.netflix, 'nflx://title/1');
      expect(a.kind, WatchActionKind.search);
    });

    test('HBO Max: play.max.com e max.com viram play.hbomax.com (deep link e busca)', () {
      final deep = resolve(FixtureProviders.max, 'https://play.max.com/show/urn:hbo:series:X');
      expect(deep.uri!.host, 'play.hbomax.com');
      expect(deep.uri!.path, '/show/urn:hbo:series:X');
      expect(normalizeHboMax(Uri.parse('https://www.hbomax.com/x')).host, 'play.hbomax.com');
      expect(normalizeHboMax(Uri.parse('https://www.netflix.com/x')).host, 'www.netflix.com');
    });

    test('preposição por marca; "em" para streaming fora dos destacados', () {
      expect(providerPreposition(FixtureProviders.prime), 'no');
      expect(providerPreposition(FixtureProviders.crunchyroll), 'na');
      expect(providerPreposition(const StreamingProvider(id: 1, name: 'X')), 'em');
    });
  });

  group('groupAvailability', () {
    final now = DateTime(2026, 10, 22);
    Availability row(StreamingProvider p, OfferType t, {String? link}) =>
        Availability(providerId: p.id, offerType: t, deepLink: link, fetchedAt: now, provider: p);

    test('um cartão por streaming, assinatura antes de aluguel/compra, variante agrupa no principal', () {
      final groups = groupAvailability([
        row(FixtureProviders.apple, OfferType.buy),
        row(FixtureProviders.apple, OfferType.rent),
        row(FixtureProviders.netflixAds, OfferType.ads, link: 'https://www.netflix.com/title/1'),
        row(FixtureProviders.crunchyroll, OfferType.flatrate),
        row(FixtureProviders.netflix, OfferType.flatrate),
      ], providers: FixtureProviders.byId);

      expect(groups.map((g) => g.provider.name), ['Netflix', 'Crunchyroll', 'Apple TV+']);
      final netflix = groups.first;
      expect(netflix.offers.map((o) => o.offerType), [OfferType.flatrate, OfferType.ads]);
      expect(netflix.deepLink, 'https://www.netflix.com/title/1', reason: 'link da variante serve para o principal');
      expect(groups.last.offers.map((o) => o.offerType), [OfferType.rent, OfferType.buy]);
    });

    test('empate no tipo de oferta desempata por display_order', () {
      final groups = groupAvailability([
        row(FixtureProviders.paramount, OfferType.flatrate),
        row(FixtureProviders.prime, OfferType.flatrate),
      ]);
      expect(groups.map((g) => g.provider.slug), ['prime', 'paramount']);
    });
  });
}
