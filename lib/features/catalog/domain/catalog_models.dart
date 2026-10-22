import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/model/media_type.dart';

part 'catalog_models.freezed.dart';
part 'catalog_models.g.dart';

/// Item leve de lista (busca, seções do Início). Vem das Edge Functions
/// `catalog-search` e `home-sections` (docs/ARQUITETURA.md §9).
@freezed
abstract class CatalogItem with _$CatalogItem {
  const factory CatalogItem({
    required int tmdbId,
    required MediaType mediaType,
    required String title,
    int? year,
    String? posterPath,
    @Default(false) bool isAnime,
  }) = _CatalogItem;

  factory CatalogItem.fromJson(Map<String, dynamic> json) => _$CatalogItemFromJson(json);
}

@freezed
abstract class SearchPage with _$SearchPage {
  const factory SearchPage({
    required List<CatalogItem> results,
    @Default(1) int page,
    @Default(1) int totalPages,
  }) = _SearchPage;

  factory SearchPage.fromJson(Map<String, dynamic> json) => _$SearchPageFromJson(json);
}

@freezed
abstract class HomeSection with _$HomeSection {
  const factory HomeSection({
    required String key,
    required String title,
    required List<CatalogItem> items,
  }) = _HomeSection;

  factory HomeSection.fromJson(Map<String, dynamic> json) => _$HomeSectionFromJson(json);
}

@freezed
abstract class HomeSections with _$HomeSections {
  const factory HomeSections({
    required List<HomeSection> sections,
    required DateTime fetchedAt,
  }) = _HomeSections;

  factory HomeSections.fromJson(Map<String, dynamic> json) => _$HomeSectionsFromJson(json);
}

/// Linha de `public.titles` (cache do TMDB em pt-BR).
@freezed
abstract class Title with _$Title {
  const factory Title({
    required String id,
    required int tmdbId,
    required MediaType mediaType,
    required String title,
    String? originalTitle,
    String? overview,
    String? posterPath,
    String? backdropPath,
    DateTime? releaseDate,
    int? year,
    @Default(<String>[]) List<String> genres,
    @Default(false) bool isAnime,
    int? runtimeMinutes,
    int? episodeRunTime,
    int? numberOfSeasons,
    int? numberOfEpisodes,
    @Default(<Season>[]) List<Season> seasons,
    @Default(<CastMember>[]) List<CastMember> castTop,
    String? status,
    double? voteAverage,
    required DateTime fetchedAt,
  }) = _Title;

  factory Title.fromJson(Map<String, dynamic> json) => _$TitleFromJson(json);
}

@freezed
abstract class Season with _$Season {
  const factory Season({
    required int seasonNumber,
    required String name,
    @Default(0) int episodeCount,
    DateTime? airDate,
    String? posterPath,
  }) = _Season;

  factory Season.fromJson(Map<String, dynamic> json) => _$SeasonFromJson(json);
}

@freezed
abstract class CastMember with _$CastMember {
  const factory CastMember({
    required String name,
    String? character,
    String? profilePath,
  }) = _CastMember;

  factory CastMember.fromJson(Map<String, dynamic> json) => _$CastMemberFromJson(json);
}

/// Linha de `public.providers` (streaming; id = provider_id do TMDB).
@freezed
abstract class StreamingProvider with _$StreamingProvider {
  const factory StreamingProvider({
    required int id,
    String? slug,
    required String name,
    String? logoPath,
    String? androidPackage,
    String? webDomain,
    String? searchUrlTemplate,
    @Default(false) bool isFeatured,
    int? displayOrder,
    int? parentId,
  }) = _StreamingProvider;

  factory StreamingProvider.fromJson(Map<String, dynamic> json) => _$StreamingProviderFromJson(json);
}

/// Tipo de oferta (`title_availability.offer_type`), na ordem de exibição da
/// SPEC §5.7: assinatura → com anúncios → grátis → aluguel → compra.
enum OfferType {
  @JsonValue('flatrate')
  flatrate,
  @JsonValue('ads')
  ads,
  @JsonValue('free')
  free,
  @JsonValue('rent')
  rent,
  @JsonValue('buy')
  buy;

  String get labelPtBr => switch (this) {
        OfferType.flatrate => 'Assinatura',
        OfferType.ads => 'Com anúncios',
        OfferType.free => 'Grátis',
        OfferType.rent => 'Aluguel',
        OfferType.buy => 'Compra',
      };

  /// Assinatura (com ou sem anúncios) e grátis "resolvem" o título; aluguel e
  /// compra são à parte (fase 07).
  bool get isSubscriptionLike => this == flatrate || this == ads || this == free;
}

/// Linha de `public.title_availability` com o streaming embutido.
@freezed
abstract class Availability with _$Availability {
  const factory Availability({
    required int providerId,
    required OfferType offerType,
    String? deepLink,
    String? deepLinkSource,
    int? priceCents,
    required DateTime fetchedAt,
    DateTime? linkFetchedAt,
    required StreamingProvider provider,
  }) = _Availability;

  factory Availability.fromJson(Map<String, dynamic> json) => _$AvailabilityFromJson(json);
}

/// Linha de `public.title_sync`: quando o cache foi renovado.
@freezed
abstract class TitleSync with _$TitleSync {
  const factory TitleSync({
    DateTime? providersFetchedAt,
    DateTime? linksFetchedAt,
    String? linksStatus,
  }) = _TitleSync;

  factory TitleSync.fromJson(Map<String, dynamic> json) => _$TitleSyncFromJson(json);
}

/// Resposta da Edge Function `catalog-title`.
@freezed
abstract class TitleDetail with _$TitleDetail {
  const factory TitleDetail({
    required Title title,
    @Default(<Availability>[]) List<Availability> availability,
    @Default(TitleSync()) TitleSync sync,
  }) = _TitleDetail;

  factory TitleDetail.fromJson(Map<String, dynamic> json) => _$TitleDetailFromJson(json);
}
