// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_stats.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_StatsRow _$StatsRowFromJson(Map<String, dynamic> json) => _StatsRow(
  status: $enumDecode(_$EntryStatusEnumMap, json['status']),
  watchCount: (json['watch_count'] as num?)?.toInt() ?? 1,
  episodesWatched: (json['episodes_watched'] as num?)?.toInt(),
  mediaType: $enumDecode(_$MediaTypeEnumMap, json['media_type']),
  runtimeMinutes: (json['runtime_minutes'] as num?)?.toInt(),
  episodeRunTime: (json['episode_run_time'] as num?)?.toInt(),
  numberOfEpisodes: (json['number_of_episodes'] as num?)?.toInt(),
  genres:
      (json['genres'] as List<dynamic>?)?.map((e) => e as String).toList() ??
      const <String>[],
  year: (json['year'] as num?)?.toInt(),
  providerIds:
      (json['provider_ids'] as List<dynamic>?)
          ?.map((e) => (e as num).toInt())
          .toList() ??
      const <int>[],
);

Map<String, dynamic> _$StatsRowToJson(_StatsRow instance) => <String, dynamic>{
  'status': _$EntryStatusEnumMap[instance.status]!,
  'watch_count': instance.watchCount,
  'episodes_watched': ?instance.episodesWatched,
  'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
  'runtime_minutes': ?instance.runtimeMinutes,
  'episode_run_time': ?instance.episodeRunTime,
  'number_of_episodes': ?instance.numberOfEpisodes,
  'genres': instance.genres,
  'year': ?instance.year,
  'provider_ids': instance.providerIds,
};

const _$EntryStatusEnumMap = {
  EntryStatus.watched: 'watched',
  EntryStatus.watching: 'watching',
  EntryStatus.want: 'want',
};

const _$MediaTypeEnumMap = {MediaType.movie: 'movie', MediaType.tv: 'tv'};

_ProfileCounts _$ProfileCountsFromJson(Map<String, dynamic> json) =>
    _ProfileCounts(
      followers: (json['followers'] as num?)?.toInt() ?? 0,
      following: (json['following'] as num?)?.toInt() ?? 0,
      watched: (json['watched'] as num?)?.toInt() ?? 0,
      reviews: (json['reviews'] as num?)?.toInt() ?? 0,
      lists: (json['lists'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ProfileCountsToJson(_ProfileCounts instance) =>
    <String, dynamic>{
      'followers': instance.followers,
      'following': instance.following,
      'watched': instance.watched,
      'reviews': instance.reviews,
      'lists': instance.lists,
    };
