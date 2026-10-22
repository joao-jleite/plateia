// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'list_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ListModel {

 String get id; String get userId; String get name; String? get description; bool get isPrivate; bool get isRanked; int get itemCount; DateTime? get createdAt; DateTime? get updatedAt;
/// Create a copy of ListModel
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListModelCopyWith<ListModel> get copyWith => _$ListModelCopyWithImpl<ListModel>(this as ListModel, _$identity);

  /// Serializes this ListModel to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isRanked, isRanked) || other.isRanked == isRanked)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,isPrivate,isRanked,itemCount,createdAt,updatedAt);

@override
String toString() {
  return 'ListModel(id: $id, userId: $userId, name: $name, description: $description, isPrivate: $isPrivate, isRanked: $isRanked, itemCount: $itemCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ListModelCopyWith<$Res>  {
  factory $ListModelCopyWith(ListModel value, $Res Function(ListModel) _then) = _$ListModelCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String name, String? description, bool isPrivate, bool isRanked, int itemCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class _$ListModelCopyWithImpl<$Res>
    implements $ListModelCopyWith<$Res> {
  _$ListModelCopyWithImpl(this._self, this._then);

  final ListModel _self;
  final $Res Function(ListModel) _then;

/// Create a copy of ListModel
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? isPrivate = null,Object? isRanked = null,Object? itemCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(ListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,isRanked: null == isRanked ? _self.isRanked : isRanked // ignore: cast_nullable_to_non_nullable
as bool,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ListModel].
extension ListModelPatterns on ListModel {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListModel value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListModel() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListModel value)  $default,){
final _that = this;
switch (_that) {
case _ListModel():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListModel value)?  $default,){
final _that = this;
switch (_that) {
case _ListModel() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  bool isPrivate,  bool isRanked,  int itemCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.isPrivate,_that.isRanked,_that.itemCount,_that.createdAt,_that.updatedAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String name,  String? description,  bool isPrivate,  bool isRanked,  int itemCount,  DateTime? createdAt,  DateTime? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ListModel():
return $default(_that.id,_that.userId,_that.name,_that.description,_that.isPrivate,_that.isRanked,_that.itemCount,_that.createdAt,_that.updatedAt);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String name,  String? description,  bool isPrivate,  bool isRanked,  int itemCount,  DateTime? createdAt,  DateTime? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ListModel() when $default != null:
return $default(_that.id,_that.userId,_that.name,_that.description,_that.isPrivate,_that.isRanked,_that.itemCount,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListModel extends ListModel {
  const _ListModel({required this.id, required this.userId, required this.name, this.description, this.isPrivate = false, this.isRanked = false, this.itemCount = 0, this.createdAt, this.updatedAt}): super._();
  factory _ListModel.fromJson(Map<String, dynamic> json) => _$ListModelFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String name;
@override final  String? description;
@override@JsonKey() final  bool isPrivate;
@override@JsonKey() final  bool isRanked;
@override@JsonKey() final  int itemCount;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;

/// Create a copy of ListModel
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListModelCopyWith<_ListModel> get copyWith => __$ListModelCopyWithImpl<_ListModel>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListModelToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListModel&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isRanked, isRanked) || other.isRanked == isRanked)&&(identical(other.itemCount, itemCount) || other.itemCount == itemCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,name,description,isPrivate,isRanked,itemCount,createdAt,updatedAt);

@override
String toString() {
  return 'ListModel(id: $id, userId: $userId, name: $name, description: $description, isPrivate: $isPrivate, isRanked: $isRanked, itemCount: $itemCount, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ListModelCopyWith<$Res> implements $ListModelCopyWith<$Res> {
  factory _$ListModelCopyWith(_ListModel value, $Res Function(_ListModel) _then) = __$ListModelCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String name, String? description, bool isPrivate, bool isRanked, int itemCount, DateTime? createdAt, DateTime? updatedAt
});




}
/// @nodoc
class __$ListModelCopyWithImpl<$Res>
    implements _$ListModelCopyWith<$Res> {
  __$ListModelCopyWithImpl(this._self, this._then);

  final _ListModel _self;
  final $Res Function(_ListModel) _then;

/// Create a copy of ListModel
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? name = null,Object? description = freezed,Object? isPrivate = null,Object? isRanked = null,Object? itemCount = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ListModel(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,isRanked: null == isRanked ? _self.isRanked : isRanked // ignore: cast_nullable_to_non_nullable
as bool,itemCount: null == itemCount ? _self.itemCount : itemCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ListItem {

 String get listId; String get titleId; int get position; String? get note; DateTime? get addedAt; Title? get title;
/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListItemCopyWith<ListItem> get copyWith => _$ListItemCopyWithImpl<ListItem>(this as ListItem, _$identity);

  /// Serializes this ListItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListItem&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.position, position) || other.position == position)&&(identical(other.note, note) || other.note == note)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listId,titleId,position,note,addedAt,title);

@override
String toString() {
  return 'ListItem(listId: $listId, titleId: $titleId, position: $position, note: $note, addedAt: $addedAt, title: $title)';
}


}

/// @nodoc
abstract mixin class $ListItemCopyWith<$Res>  {
  factory $ListItemCopyWith(ListItem value, $Res Function(ListItem) _then) = _$ListItemCopyWithImpl;
@useResult
$Res call({
 String listId, String titleId, int position, String? note, DateTime? addedAt, Title? title
});


$TitleCopyWith<$Res>? get title;

}
/// @nodoc
class _$ListItemCopyWithImpl<$Res>
    implements $ListItemCopyWith<$Res> {
  _$ListItemCopyWithImpl(this._self, this._then);

  final ListItem _self;
  final $Res Function(ListItem) _then;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? listId = null,Object? titleId = null,Object? position = null,Object? note = freezed,Object? addedAt = freezed,Object? title = freezed,}) {
  return _then(ListItem(
listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,
  ));
}
/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleCopyWith<$Res>? get title {
    if (_self.title == null) {
    return null;
  }

  return $TitleCopyWith<$Res>(_self.title!, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}


/// Adds pattern-matching-related methods to [ListItem].
extension ListItemPatterns on ListItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListItem value)  $default,){
final _that = this;
switch (_that) {
case _ListItem():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListItem value)?  $default,){
final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String listId,  String titleId,  int position,  String? note,  DateTime? addedAt,  Title? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that.listId,_that.titleId,_that.position,_that.note,_that.addedAt,_that.title);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String listId,  String titleId,  int position,  String? note,  DateTime? addedAt,  Title? title)  $default,) {final _that = this;
switch (_that) {
case _ListItem():
return $default(_that.listId,_that.titleId,_that.position,_that.note,_that.addedAt,_that.title);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String listId,  String titleId,  int position,  String? note,  DateTime? addedAt,  Title? title)?  $default,) {final _that = this;
switch (_that) {
case _ListItem() when $default != null:
return $default(_that.listId,_that.titleId,_that.position,_that.note,_that.addedAt,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ListItem implements ListItem {
  const _ListItem({required this.listId, required this.titleId, this.position = 0, this.note, this.addedAt, this.title});
  factory _ListItem.fromJson(Map<String, dynamic> json) => _$ListItemFromJson(json);

@override final  String listId;
@override final  String titleId;
@override@JsonKey() final  int position;
@override final  String? note;
@override final  DateTime? addedAt;
@override final  Title? title;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListItemCopyWith<_ListItem> get copyWith => __$ListItemCopyWithImpl<_ListItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ListItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListItem&&(identical(other.listId, listId) || other.listId == listId)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.position, position) || other.position == position)&&(identical(other.note, note) || other.note == note)&&(identical(other.addedAt, addedAt) || other.addedAt == addedAt)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,listId,titleId,position,note,addedAt,title);

@override
String toString() {
  return 'ListItem(listId: $listId, titleId: $titleId, position: $position, note: $note, addedAt: $addedAt, title: $title)';
}


}

/// @nodoc
abstract mixin class _$ListItemCopyWith<$Res> implements $ListItemCopyWith<$Res> {
  factory _$ListItemCopyWith(_ListItem value, $Res Function(_ListItem) _then) = __$ListItemCopyWithImpl;
@override @useResult
$Res call({
 String listId, String titleId, int position, String? note, DateTime? addedAt, Title? title
});


@override $TitleCopyWith<$Res>? get title;

}
/// @nodoc
class __$ListItemCopyWithImpl<$Res>
    implements _$ListItemCopyWith<$Res> {
  __$ListItemCopyWithImpl(this._self, this._then);

  final _ListItem _self;
  final $Res Function(_ListItem) _then;

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? listId = null,Object? titleId = null,Object? position = null,Object? note = freezed,Object? addedAt = freezed,Object? title = freezed,}) {
  return _then(_ListItem(
listId: null == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,position: null == position ? _self.position : position // ignore: cast_nullable_to_non_nullable
as int,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,addedAt: freezed == addedAt ? _self.addedAt : addedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,
  ));
}

/// Create a copy of ListItem
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TitleCopyWith<$Res>? get title {
    if (_self.title == null) {
    return null;
  }

  return $TitleCopyWith<$Res>(_self.title!, (value) {
    return _then(_self.copyWith(title: value));
  });
}
}

/// @nodoc
mixin _$ListDraft {

 String get name; String? get description; bool get isPrivate; bool get isRanked;
/// Create a copy of ListDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ListDraftCopyWith<ListDraft> get copyWith => _$ListDraftCopyWithImpl<ListDraft>(this as ListDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ListDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isRanked, isRanked) || other.isRanked == isRanked));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,isPrivate,isRanked);

@override
String toString() {
  return 'ListDraft(name: $name, description: $description, isPrivate: $isPrivate, isRanked: $isRanked)';
}


}

/// @nodoc
abstract mixin class $ListDraftCopyWith<$Res>  {
  factory $ListDraftCopyWith(ListDraft value, $Res Function(ListDraft) _then) = _$ListDraftCopyWithImpl;
@useResult
$Res call({
 String name, String? description, bool isPrivate, bool isRanked
});




}
/// @nodoc
class _$ListDraftCopyWithImpl<$Res>
    implements $ListDraftCopyWith<$Res> {
  _$ListDraftCopyWithImpl(this._self, this._then);

  final ListDraft _self;
  final $Res Function(ListDraft) _then;

/// Create a copy of ListDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? description = freezed,Object? isPrivate = null,Object? isRanked = null,}) {
  return _then(ListDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,isRanked: null == isRanked ? _self.isRanked : isRanked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [ListDraft].
extension ListDraftPatterns on ListDraft {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ListDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ListDraft() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ListDraft value)  $default,){
final _that = this;
switch (_that) {
case _ListDraft():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ListDraft value)?  $default,){
final _that = this;
switch (_that) {
case _ListDraft() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  String? description,  bool isPrivate,  bool isRanked)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ListDraft() when $default != null:
return $default(_that.name,_that.description,_that.isPrivate,_that.isRanked);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  String? description,  bool isPrivate,  bool isRanked)  $default,) {final _that = this;
switch (_that) {
case _ListDraft():
return $default(_that.name,_that.description,_that.isPrivate,_that.isRanked);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  String? description,  bool isPrivate,  bool isRanked)?  $default,) {final _that = this;
switch (_that) {
case _ListDraft() when $default != null:
return $default(_that.name,_that.description,_that.isPrivate,_that.isRanked);case _:
  return null;

}
}

}

/// @nodoc


class _ListDraft implements ListDraft {
  const _ListDraft({required this.name, this.description, this.isPrivate = false, this.isRanked = false});
  

@override final  String name;
@override final  String? description;
@override@JsonKey() final  bool isPrivate;
@override@JsonKey() final  bool isRanked;

/// Create a copy of ListDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ListDraftCopyWith<_ListDraft> get copyWith => __$ListDraftCopyWithImpl<_ListDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ListDraft&&(identical(other.name, name) || other.name == name)&&(identical(other.description, description) || other.description == description)&&(identical(other.isPrivate, isPrivate) || other.isPrivate == isPrivate)&&(identical(other.isRanked, isRanked) || other.isRanked == isRanked));
}


@override
int get hashCode => Object.hash(runtimeType,name,description,isPrivate,isRanked);

@override
String toString() {
  return 'ListDraft(name: $name, description: $description, isPrivate: $isPrivate, isRanked: $isRanked)';
}


}

/// @nodoc
abstract mixin class _$ListDraftCopyWith<$Res> implements $ListDraftCopyWith<$Res> {
  factory _$ListDraftCopyWith(_ListDraft value, $Res Function(_ListDraft) _then) = __$ListDraftCopyWithImpl;
@override @useResult
$Res call({
 String name, String? description, bool isPrivate, bool isRanked
});




}
/// @nodoc
class __$ListDraftCopyWithImpl<$Res>
    implements _$ListDraftCopyWith<$Res> {
  __$ListDraftCopyWithImpl(this._self, this._then);

  final _ListDraft _self;
  final $Res Function(_ListDraft) _then;

/// Create a copy of ListDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? description = freezed,Object? isPrivate = null,Object? isRanked = null,}) {
  return _then(_ListDraft(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,isPrivate: null == isPrivate ? _self.isPrivate : isPrivate // ignore: cast_nullable_to_non_nullable
as bool,isRanked: null == isRanked ? _self.isRanked : isRanked // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
