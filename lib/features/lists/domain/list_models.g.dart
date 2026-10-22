// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'list_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ListModel _$ListModelFromJson(Map<String, dynamic> json) => _ListModel(
  id: json['id'] as String,
  userId: json['user_id'] as String,
  name: json['name'] as String,
  description: json['description'] as String?,
  isPrivate: json['is_private'] as bool? ?? false,
  isRanked: json['is_ranked'] as bool? ?? false,
  itemCount: (json['item_count'] as num?)?.toInt() ?? 0,
  createdAt: json['created_at'] == null
      ? null
      : DateTime.parse(json['created_at'] as String),
  updatedAt: json['updated_at'] == null
      ? null
      : DateTime.parse(json['updated_at'] as String),
);

Map<String, dynamic> _$ListModelToJson(_ListModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'name': instance.name,
      'description': ?instance.description,
      'is_private': instance.isPrivate,
      'is_ranked': instance.isRanked,
      'item_count': instance.itemCount,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
    };

_ListItem _$ListItemFromJson(Map<String, dynamic> json) => _ListItem(
  listId: json['list_id'] as String,
  titleId: json['title_id'] as String,
  position: (json['position'] as num?)?.toInt() ?? 0,
  note: json['note'] as String?,
  addedAt: json['added_at'] == null
      ? null
      : DateTime.parse(json['added_at'] as String),
  title: json['title'] == null
      ? null
      : Title.fromJson(json['title'] as Map<String, dynamic>),
);

Map<String, dynamic> _$ListItemToJson(_ListItem instance) => <String, dynamic>{
  'list_id': instance.listId,
  'title_id': instance.titleId,
  'position': instance.position,
  'note': ?instance.note,
  'added_at': ?instance.addedAt?.toIso8601String(),
  'title': ?instance.title?.toJson(),
};
