// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_Profile _$ProfileFromJson(Map<String, dynamic> json) => _Profile(
  id: json['id'] as String,
  username: json['username'] as String,
  displayName: json['display_name'] as String?,
  bio: json['bio'] as String?,
  avatarUrl: json['avatar_url'] as String?,
  isPrivate: json['is_private'] as bool? ?? false,
  region: json['region'] as String? ?? 'BR',
  onboardedAt: json['onboarded_at'] == null
      ? null
      : DateTime.parse(json['onboarded_at'] as String),
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
);

Map<String, dynamic> _$ProfileToJson(_Profile instance) => <String, dynamic>{
  'id': instance.id,
  'username': instance.username,
  'display_name': ?instance.displayName,
  'bio': ?instance.bio,
  'avatar_url': ?instance.avatarUrl,
  'is_private': instance.isPrivate,
  'region': instance.region,
  'onboarded_at': ?instance.onboardedAt?.toIso8601String(),
  'created_at': ?instance.createdAt?.toIso8601String(),
};
