// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'entry.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Entry _$EntryFromJson(Map<String, dynamic> json) => _Entry(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  titleId: json['title_id'] as String,
  status: $enumDecode(_$EntryStatusEnumMap, json['status']),
  rating: (json['rating'] as num?)?.toDouble(),
  review: json['review'] as String?,
  hasSpoiler: json['has_spoiler'] as bool? ?? false,
  watchedAt: json['watched_at'] == null
      ? null
      : DateTime.parse(json['watched_at'] as String),
  currentSeason: (json['current_season'] as num?)?.toInt(),
  currentEpisode: (json['current_episode'] as num?)?.toInt(),
  episodesWatched: (json['episodes_watched'] as num?)?.toInt(),
  watchCount: (json['watch_count'] as num?)?.toInt() ?? 1,
  source: json['source'] as String? ?? 'manual',
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  title: json['title'] == null
      ? null
      : Title.fromJson(json['title'] as Map<String, dynamic>),
);

Map<String, dynamic> _$EntryToJson(_Entry instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title_id': instance.titleId,
  'status': _$EntryStatusEnumMap[instance.status]!,
  'rating': ?instance.rating,
  'review': ?instance.review,
  'has_spoiler': instance.hasSpoiler,
  'watched_at': ?instance.watchedAt?.toIso8601String(),
  'current_season': ?instance.currentSeason,
  'current_episode': ?instance.currentEpisode,
  'episodes_watched': ?instance.episodesWatched,
  'watch_count': instance.watchCount,
  'source': instance.source,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'title': ?instance.title?.toJson(),
};

const _$EntryStatusEnumMap = {
  EntryStatus.watched: 'watched',
  EntryStatus.watching: 'watching',
  EntryStatus.want: 'want',
};
