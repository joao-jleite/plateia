// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_notification.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AppNotification _$AppNotificationFromJson(Map<String, dynamic> json) =>
    _AppNotification(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      actorId: json['actor_id'] as String?,
      kind: $enumDecode(_$NotificationKindEnumMap, json['kind']),
      activityId: json['activity_id'] as String?,
      commentId: json['comment_id'] as String?,
      readAt: json['read_at'] == null
          ? null
          : DateTime.parse(json['read_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
      actor: json['actor'] == null
          ? null
          : Profile.fromJson(json['actor'] as Map<String, dynamic>),
      activity: json['activity'] == null
          ? null
          : Activity.fromJson(json['activity'] as Map<String, dynamic>),
      comment: json['comment'] == null
          ? null
          : Comment.fromJson(json['comment'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$AppNotificationToJson(_AppNotification instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'actor_id': ?instance.actorId,
      'kind': _$NotificationKindEnumMap[instance.kind]!,
      'activity_id': ?instance.activityId,
      'comment_id': ?instance.commentId,
      'read_at': ?instance.readAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
      'actor': ?instance.actor?.toJson(),
      'activity': ?instance.activity?.toJson(),
      'comment': ?instance.comment?.toJson(),
    };

const _$NotificationKindEnumMap = {
  NotificationKind.follow: 'follow',
  NotificationKind.followRequest: 'follow_request',
  NotificationKind.followAccepted: 'follow_accepted',
  NotificationKind.like: 'like',
  NotificationKind.comment: 'comment',
};
