// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_FollowRequest _$FollowRequestFromJson(Map<String, dynamic> json) =>
    _FollowRequest(
      follower: Profile.fromJson(json['follower'] as Map<String, dynamic>),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$FollowRequestToJson(_FollowRequest instance) =>
    <String, dynamic>{
      'follower': instance.follower.toJson(),
      'created_at': ?instance.createdAt?.toIso8601String(),
    };

_BlockedUser _$BlockedUserFromJson(Map<String, dynamic> json) => _BlockedUser(
  id: json['id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  blockedAt: json['blocked_at'] == null
      ? null
      : DateTime.parse(json['blocked_at'] as String),
);

Map<String, dynamic> _$BlockedUserToJson(_BlockedUser instance) =>
    <String, dynamic>{
      'id': instance.id,
      'username': instance.username,
      'display_name': ?instance.displayName,
      'avatar_url': ?instance.avatarUrl,
      'blocked_at': ?instance.blockedAt?.toIso8601String(),
    };
