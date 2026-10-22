// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_CatalogItem _$CatalogItemFromJson(Map<String, dynamic> json) => _CatalogItem(
  tmdbId: (json['tmdb_id'] as num).toInt(),
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['media_type']),
  title: json['title'] as String,
  year: (json['year'] as num?)?.toInt(),
  posterPath: json['poster_path'] as String?,
  isAnime: json['is_anime'] as bool? ?? false,
);

Map<String, dynamic> _$CatalogItemToJson(_CatalogItem instance) =>
    <String, dynamic>{
      'tmdb_id': instance.tmdbId,
      'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
      'title': instance.title,
      'year': ?instance.year,
      'poster_path': ?instance.posterPath,
      'is_anime': instance.isAnime,
    };

const _$MediaTypeEnumMap = {MediaType.movie: 'movie', MediaType.tv: 'tv'};

_SearchPage _$SearchPageFromJson(Map<String, dynamic> json) => _SearchPage(
  results: (json['results'] as List<dynamic>)
      .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
      .toList(),
  page: (json['page'] as num?)?.toInt() ?? 1,
  totalPages: (json['total_pages'] as num?)?.toInt() ?? 1,
);

Map<String, dynamic> _$SearchPageToJson(_SearchPage instance) =>
    <String, dynamic>{
      'results': instance.results.map((e) => e.toJson()).toList(),
      'page': instance.page,
      'total_pages': instance.totalPages,
    };

_HomeSection _$HomeSectionFromJson(Map<String, dynamic> json) => _HomeSection(
  key: json['key'] as String,
  title: json['title'] as String,
  items: (json['items'] as List<dynamic>)
      .map((e) => CatalogItem.fromJson(e as Map<String, dynamic>))
      .toList(),
);

Map<String, dynamic> _$HomeSectionToJson(_HomeSection instance) =>
    <String, dynamic>{
      'key': instance.key,
      'title': instance.title,
      'items': instance.items.map((e) => e.toJson()).toList(),
    };

_HomeSections _$HomeSectionsFromJson(Map<String, dynamic> json) =>
    _HomeSections(
      sections: (json['sections'] as List<dynamic>)
          .map((e) => HomeSection.fromJson(e as Map<String, dynamic>))
          .toList(),
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
    );

Map<String, dynamic> _$HomeSectionsToJson(_HomeSections instance) =>
    <String, dynamic>{
      'sections': instance.sections.map((e) => e.toJson()).toList(),
      'fetched_at': instance.fetchedAt.toIso8601String(),
    };

_Title _$TitleFromJson(Map<String, dynamic> json) => _Title(
  id: json['id'] as String,
  tmdbId: (json['tmdb_id'] as num).toInt(),
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['media_type']),
  title: json['title'] as String,
  originalTitle: json['original_title'] as String?,
  overview: json['overview'] as String?,
  posterPath: json['poster_path'] as String?,
  backdropPath: json['backdrop_path'] as String?,
  releaseDate: json['release_date'] == null
      ? null
      : DateTime.parse(json['release_date'] as String),
  year: (json['year'] as num?)?.toInt(),
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  isAnime: json['is_anime'] as bool? ?? false,
  runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
  episodeRunTime: (json['episode_run_time'] as num?)?.toInt(),
  numberOfSeasons: (json['number_of_seasons'] as num?)?.toInt(),
  numberOfEpisodes: (json['number_of_episodes'] as num?)?.toInt(),
  seasons:
      (json['seasons'] as List<dynamic>?)
          ?.map((e) => Season.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Season>[],
  castTop:
      (json['cast_top'] as List<dynamic>?)
          ?.map((e) => CastMember.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <CastMember>[],
  status: json['status'] as String?,
  voteAverage: (json['vote_average'] as num?)?.toDouble(),
  fetchedAt: DateTime.parse(json['fetched_at'] as String),
);

Map<String, dynamic> _$TitleToJson(_Title instance) => <String, dynamic>{
  'id': instance.id,
  'tmdb_id': instance.tmdbId,
  'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
  'title': instance.title,
  'original_title': ?instance.originalTitle,
  'overview': ?instance.overview,
  'poster_path': ?instance.posterPath,
  'backdrop_path': ?instance.backdropPath,
  'release_date': ?instance.releaseDate?.toIso8601String(),
  'year': ?instance.year,
  'genres': instance.genres,
  'is_anime': instance.isAnime,
  'runtime_minutes': ?instance.runtimeMinutes,
  'episode_run_time': ?instance.episodeRunTime,
  'number_of_seasons': ?instance.numberOfSeasons,
  'number_of_episodes': ?instance.numberOfEpisodes,
  'seasons': instance.seasons.map((e) => e.toJson()).toList(),
  'cast_top': instance.castTop.map((e) => e.toJson()).toList(),
  'status': ?instance.status,
  'vote_average': ?instance.voteAverage,
  'fetched_at': instance.fetchedAt.toIso8601String(),
};

_Season _$SeasonFromJson(Map<String, dynamic> json) => _Season(
  seasonNumber: (json['season_number'] as num).toInt(),
  name: json['name'] as String,
  episodeCount: (json['episode_count'] as num?)?.toInt() ?? 0,
  airDate: json['air_date'] == null
      ? null
      : DateTime.parse(json['air_date'] as String),
  posterPath: json['poster_path'] as String?,
);

Map<String, dynamic> _$SeasonToJson(_Season instance) => <String, dynamic>{
  'season_number': instance.seasonNumber,
  'name': instance.name,
  'episode_count': instance.episodeCount,
  'air_date': ?instance.airDate?.toIso8601String(),
  'poster_path': ?instance.posterPath,
};

_CastMember _$CastMemberFromJson(Map<String, dynamic> json) => _CastMember(
  name: json['name'] as String,
  character: json['character'] as String?,
  profilePath: json['profile_path'] as String?,
);

Map<String, dynamic> _$CastMemberToJson(_CastMember instance) =>
    <String, dynamic>{
      'name': instance.name,
      'character': ?instance.character,
      'profile_path': ?instance.profilePath,
    };

_StreamingProvider _$StreamingProviderFromJson(Map<String, dynamic> json) =>
    _StreamingProvider(
      id: (json['id'] as num).toInt(),
      slug: json['slug'] as String?,
      name: json['name'] as String,
      logoPath: json['logo_path'] as String?,
      androidPackage: json['android_package'] as String?,
      webDomain: json['web_domain'] as String?,
      searchUrlTemplate: json['search_url_template'] as String?,
      isFeatured: json['is_featured'] as bool? ?? false,
      displayOrder: (json['display_order'] as num?)?.toInt(),
      parentId: (json['parent_id'] as num?)?.toInt(),
    );

Map<String, dynamic> _$StreamingProviderToJson(_StreamingProvider instance) =>
    <String, dynamic>{
      'id': instance.id,
      'slug': ?instance.slug,
      'name': instance.name,
      'logo_path': ?instance.logoPath,
      'android_package': ?instance.androidPackage,
      'web_domain': ?instance.webDomain,
      'search_url_template': ?instance.searchUrlTemplate,
      'is_featured': instance.isFeatured,
      'display_order': ?instance.displayOrder,
      'parent_id': ?instance.parentId,
    };

_Availability _$AvailabilityFromJson(Map<String, dynamic> json) =>
    _Availability(
      providerId: (json['provider_id'] as num).toInt(),
      offerType: $enumDecode(_$OfferTypeEnumMap, json['offer_type']),
      deepLink: json['deep_link'] as String?,
      deepLinkSource: json['deep_link_source'] as String?,
      priceCents: (json['price_cents'] as num?)?.toInt(),
      fetchedAt: DateTime.parse(json['fetched_at'] as String),
      linkFetchedAt: json['link_fetched_at'] == null
          ? null
          : DateTime.parse(json['link_fetched_at'] as String),
      provider: StreamingProvider.fromJson(
        json['provider'] as Map<String, dynamic>,
      ),
    );

Map<String, dynamic> _$AvailabilityToJson(_Availability instance) =>
    <String, dynamic>{
      'provider_id': instance.providerId,
      'offer_type': _$OfferTypeEnumMap[instance.offerType]!,
      'deep_link': ?instance.deepLink,
      'deep_link_source': ?instance.deepLinkSource,
      'price_cents': ?instance.priceCents,
      'fetched_at': instance.fetchedAt.toIso8601String(),
      'link_fetched_at': ?instance.linkFetchedAt?.toIso8601String(),
      'provider': instance.provider.toJson(),
    };

const _$OfferTypeEnumMap = {
  OfferType.flatrate: 'flatrate',
  OfferType.ads: 'ads',
  OfferType.free: 'free',
  OfferType.rent: 'rent',
  OfferType.buy: 'buy',
};

_TitleSync _$TitleSyncFromJson(Map<String, dynamic> json) => _TitleSync(
  providersFetchedAt: json['providers_fetched_at'] == null
      ? null
      : DateTime.parse(json['providers_fetched_at'] as String),
  linksFetchedAt: json['links_fetched_at'] == null
      ? null
      : DateTime.parse(json['links_fetched_at'] as String),
  linksStatus: json['links_status'] as String?,
);

Map<String, dynamic> _$TitleSyncToJson(_TitleSync instance) =>
    <String, dynamic>{
      'providers_fetched_at': ?instance.providersFetchedAt?.toIso8601String(),
      'links_fetched_at': ?instance.linksFetchedAt?.toIso8601String(),
      'links_status': ?instance.linksStatus,
    };

_TitleDetail _$TitleDetailFromJson(Map<String, dynamic> json) => _TitleDetail(
  title: Title.fromJson(json['title'] as Map<String, dynamic>),
  availability:
      (json['availability'] as List<dynamic>?)
          ?.map((e) => Availability.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <Availability>[],
  sync: json['sync'] == null
      ? const TitleSync()
      : TitleSync.fromJson(json['sync'] as Map<String, dynamic>),
);

Map<String, dynamic> _$TitleDetailToJson(_TitleDetail instance) =>
    <String, dynamic>{
      'title': instance.title.toJson(),
      'availability': instance.availability.map((e) => e.toJson()).toList(),
      'sync': instance.sync.toJson(),
    };
