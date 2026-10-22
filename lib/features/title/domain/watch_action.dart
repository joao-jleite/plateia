import '../../../core/config/tmdb_images.dart';
import '../../../core/model/media_type.dart';
import '../../catalog/domain/catalog_models.dart';

/// O que o botão da seção "Onde assistir" faz (SPEC §5.7), decidido por
/// lógica pura para ser testável:
/// - há `deep_link` → "Abrir na X" (abre o título no app via App Links);
/// - sem link mas com busca → "Buscar na X" (nunca prometer "abrir");
/// - sem busca mas com pacote (Disney+) → "Abrir o X" (abre o app ou a Play Store);
/// - último recurso → "Ver na JustWatch" (página do TMDB).
enum WatchActionKind { deepLink, search, appPackage, justwatch }

class WatchAction {
  const WatchAction._({required this.kind, required this.label, this.uri, this.package});

  final WatchActionKind kind;
  final String label;
  final Uri? uri;
  final String? package;

  @override
  String toString() => 'WatchAction($kind, $label, ${uri ?? package})';
}

/// "na Netflix", "no Prime Video"… O artigo depende da marca; fora dos 8
/// destacados usa "em", que é neutro ("Abrir em Telecine").
String providerPreposition(StreamingProvider p) => switch (p.slug) {
      'netflix' || 'max' || 'apple' || 'crunchyroll' => 'na',
      'prime' || 'disney' || 'globoplay' || 'paramount' => 'no',
      _ => 'em',
    };

/// HBO Max: só `play.hbomax.com` declara o pacote Android no assetlinks;
/// `play.max.com`/`max.com`/`www.hbomax.com` não abrem o app (fase 01).
Uri normalizeHboMax(Uri uri) {
  const wrongHosts = {'play.max.com', 'max.com', 'www.max.com', 'www.hbomax.com', 'hbomax.com'};
  if (wrongHosts.contains(uri.host)) return uri.replace(host: 'play.hbomax.com');
  return uri;
}

WatchAction resolveWatchAction({
  required StreamingProvider provider,
  required String? deepLink,
  required String titleName,
  required MediaType mediaType,
  required int tmdbId,
}) {
  final prep = providerPreposition(provider);

  final link = deepLink?.trim();
  if (link != null && link.isNotEmpty) {
    final uri = Uri.tryParse(link);
    if (uri != null && (uri.scheme == 'https' || uri.scheme == 'http')) {
      return WatchAction._(
        kind: WatchActionKind.deepLink,
        label: 'Abrir $prep ${provider.name}',
        uri: normalizeHboMax(uri),
      );
    }
  }

  final template = provider.searchUrlTemplate;
  if (template != null && template.contains('{q}')) {
    final uri = Uri.parse(template.replaceAll('{q}', Uri.encodeQueryComponent(titleName)));
    return WatchAction._(
      kind: WatchActionKind.search,
      label: 'Buscar $prep ${provider.name}',
      uri: normalizeHboMax(uri),
    );
  }

  final package = provider.androidPackage;
  if (package != null && package.isNotEmpty) {
    return WatchAction._(
      kind: WatchActionKind.appPackage,
      label: 'Abrir o ${provider.name}',
      package: package,
    );
  }

  return WatchAction._(
    kind: WatchActionKind.justwatch,
    label: 'Ver na JustWatch',
    uri: TmdbImages.watchPage(mediaType, tmdbId),
  );
}

/// Um cartão por streaming na seção "Onde assistir", ordenado por tipo de
/// oferta (assinatura → com anúncios → grátis → aluguel → compra). Variantes
/// ("Netflix com anúncios", `parent_id` = 8) somam ao cartão do principal.
class ProviderOffer {
  const ProviderOffer({required this.provider, required this.offers, required this.deepLink});

  final StreamingProvider provider;

  /// Ofertas deste streaming, já ordenadas; a primeira define a posição.
  final List<Availability> offers;

  /// Melhor link disponível entre as ofertas (prioriza assinatura).
  final String? deepLink;

  OfferType get bestOffer => offers.first.offerType;
}

List<ProviderOffer> groupAvailability(List<Availability> rows, {Map<int, StreamingProvider>? providers}) {
  final byProvider = <int, List<Availability>>{};
  final displayProvider = <int, StreamingProvider>{};
  for (final row in rows) {
    // Agrupa pela "marca" principal quando a variante tem parent_id.
    final parentId = row.provider.parentId;
    final key = parentId ?? row.providerId;
    // (sem `?[` dentro de ternário: o parser do Dart confunde com outro `?:`)
    final parent = (parentId != null && providers != null) ? providers[parentId] : null;
    byProvider.putIfAbsent(key, () => []).add(row);
    if (parent != null) {
      displayProvider[key] = parent;
    } else {
      displayProvider.putIfAbsent(key, () => row.provider);
    }
  }

  final groups = byProvider.entries.map((e) {
    final offers = [...e.value]..sort((a, b) => a.offerType.index.compareTo(b.offerType.index));
    final link = offers.map((o) => o.deepLink).firstWhere((l) => l != null && l.isNotEmpty, orElse: () => null);
    return ProviderOffer(provider: displayProvider[e.key]!, offers: offers, deepLink: link);
  }).toList();

  groups.sort((a, b) {
    final byOffer = a.bestOffer.index.compareTo(b.bestOffer.index);
    if (byOffer != 0) return byOffer;
    final ao = a.provider.displayOrder ?? 999;
    final bo = b.provider.displayOrder ?? 999;
    if (ao != bo) return ao.compareTo(bo);
    return a.provider.name.compareTo(b.provider.name);
  });
  return groups;
}
