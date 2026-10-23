// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Activity _$ActivityFromJson(Map<String, dynamic> json) => _Activity(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  kind: $enumDecode(_$ActivityKindEnumMap, json['kind']),
  titleId: json['title_id'] as String?,
  entryId: json['entry_id'] as String?,
  listId: json['list_id'] as String?,
  payload:
      json['payload'] as Map<String, dynamic>? ?? const <String, dynamic>{},
  likeCount: (json['like_count'] as num?)?.toInt() ?? 0,
  commentCount: (json['comment_count'] as num?)?.toInt() ?? 0,
  createdAt: DateTime.parse(json['created_at'] as String),
  user: json['user'] == null
      ? null
      : Profile.fromJson(json['user'] as Map<String, dynamic>),
  title: json['title'] == null
      ? null
      : Title.fromJson(json['title'] as Map<String, dynamic>),
  list: json['list'] == null
      ? null
      : ListModel.fromJson(json['list'] as Map<String, dynamic>),
  entry: json['entry'] == null
      ? null
      : Entry.fromJson(json['entry'] as Map<String, dynamic>),
  likedByMe: json['liked_by_me'] as bool? ?? false,
);

Map<String, dynamic> _$ActivityToJson(_Activity instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'kind': _$ActivityKindEnumMap[instance.kind]!,
  'title_id': ?instance.titleId,
  'entry_id': ?instance.entryId,
  'list_id': ?instance.listId,
  'payload': instance.payload,
  'like_count': instance.likeCount,
  'comment_count': instance.commentCount,
  'created_at': instance.createdAt.toIso8601String(),
  'user': ?instance.user?.toJson(),
  'title': ?instance.title?.toJson(),
  'list': ?instance.list?.toJson(),
  'entry': ?instance.entry?.toJson(),
  'liked_by_me': instance.likedByMe,
};

const _$ActivityKindEnumMap = {
  ActivityKind.watched: 'watched',
  ActivityKind.rated: 'rated',
  ActivityKind.reviewed: 'reviewed',
  ActivityKind.watching: 'watching',
  ActivityKind.listCreated: 'list_created',
  ActivityKind.imported: 'imported',
};

_Comment _$CommentFromJson(Map<String, dynamic> json) => _Comment(
  id: json['id'] as String,
  activityId: json['activity_id'] as String,
  userId: json['user_id'] as String,
  body: json['body'] as String,
  hasSpoiler: json['has_spoiler'] as bool? ?? false,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
  user: json['user'] == null
      ? null
      : Profile.fromJson(json['user'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CommentToJson(_Comment instance) => <String, dynamic>{
  'id': instance.id,
  'activity_id': instance.activityId,
  'user_id': instance.userId,
  'body': instance.body,
  'has_spoiler': instance.hasSpoiler,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'updated_at': ?instance.updatedAt?.toIso8601String(),
  'user': ?instance.user?.toJson(),
};

_Checkin _$CheckinFromJson(Map<String, dynamic> json) => _Checkin(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  titleId: json['title_id'] as String,
  season: (json['season'] as num?)?.toInt(),
  episode: (json['episode'] as num?)?.toInt(),
  note: json['note'] as String?,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  expiresAt: DateTime.parse(json['expires_at'] as String),
  user: json['user'] == null
      ? null
      : Profile.fromJson(json['user'] as Map<String, dynamic>),
  title: json['title'] == null
      ? null
      : Title.fromJson(json['title'] as Map<String, dynamic>),
);

Map<String, dynamic> _$CheckinToJson(_Checkin instance) => <String, dynamic>{
  'id': instance.id,
  'user_id': instance.userId,
  'title_id': instance.titleId,
  'season': ?instance.season,
  'episode': ?instance.episode,
  'note': ?instance.note,
  'created_at': ?instance.createdAt?.toIso8601String(),
  'expires_at': instance.expiresAt.toIso8601String(),
  'user': ?instance.user?.toJson(),
  'title': ?instance.title?.toJson(),
};
