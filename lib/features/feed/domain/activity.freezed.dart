// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'activity.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Activity {

 String get id; String get userId; ActivityKind get kind; String? get titleId; String? get entryId; String? get listId; Map<String, dynamic> get payload; int get likeCount; int get commentCount; DateTime get createdAt; Profile? get user; Title? get title; ListModel? get list; Entry? get entry; bool get likedByMe;
/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ActivityCopyWith<Activity> get copyWith => _$ActivityCopyWithImpl<Activity>(this as Activity, _$identity);

  /// Serializes this Activity to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.listId, listId) || other.listId == listId)&&const DeepCollectionEquality().equals(other.payload, payload)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.title, title) || other.title == title)&&(identical(other.list, list) || other.list == list)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.likedByMe, likedByMe) || other.likedByMe == likedByMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,kind,titleId,entryId,listId,const DeepCollectionEquality().hash(payload),likeCount,commentCount,createdAt,user,title,list,entry,likedByMe);

@override
String toString() {
  return 'Activity(id: $id, userId: $userId, kind: $kind, titleId: $titleId, entryId: $entryId, listId: $listId, payload: $payload, likeCount: $likeCount, commentCount: $commentCount, createdAt: $createdAt, user: $user, title: $title, list: $list, entry: $entry, likedByMe: $likedByMe)';
}


}

/// @nodoc
abstract mixin class $ActivityCopyWith<$Res>  {
  factory $ActivityCopyWith(Activity value, $Res Function(Activity) _then) = _$ActivityCopyWithImpl;
@useResult
$Res call({
 String id, String userId, ActivityKind kind, String? titleId, String? entryId, String? listId, Map<String, dynamic> payload, int likeCount, int commentCount, DateTime createdAt, Profile? user, Title? title, ListModel? list, Entry? entry, bool likedByMe
});


$ProfileCopyWith<$Res>? get user;$TitleCopyWith<$Res>? get title;$ListModelCopyWith<$Res>? get list;$EntryCopyWith<$Res>? get entry;

}
/// @nodoc
class _$ActivityCopyWithImpl<$Res>
    implements $ActivityCopyWith<$Res> {
  _$ActivityCopyWithImpl(this._self, this._then);

  final Activity _self;
  final $Res Function(Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? kind = null,Object? titleId = freezed,Object? entryId = freezed,Object? listId = freezed,Object? payload = null,Object? likeCount = null,Object? commentCount = null,Object? createdAt = null,Object? user = freezed,Object? title = freezed,Object? list = freezed,Object? entry = freezed,Object? likedByMe = null,}) {
  return _then(Activity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ActivityKind,titleId: freezed == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String?,entryId: freezed == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String?,listId: freezed == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String?,payload: null == payload ? _self.payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Profile?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,list: freezed == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as ListModel?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as Entry?,likedByMe: null == likedByMe ? _self.likedByMe : likedByMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Activity
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
}/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListModelCopyWith<$Res>? get list {
    if (_self.list == null) {
    return null;
  }

  return $ListModelCopyWith<$Res>(_self.list!, (value) {
    return _then(_self.copyWith(list: value));
  });
}/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $EntryCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// Adds pattern-matching-related methods to [Activity].
extension ActivityPatterns on Activity {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Activity value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Activity value)  $default,){
final _that = this;
switch (_that) {
case _Activity():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Activity value)?  $default,){
final _that = this;
switch (_that) {
case _Activity() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  ActivityKind kind,  String? titleId,  String? entryId,  String? listId,  Map<String, dynamic> payload,  int likeCount,  int commentCount,  DateTime createdAt,  Profile? user,  Title? title,  ListModel? list,  Entry? entry,  bool likedByMe)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.userId,_that.kind,_that.titleId,_that.entryId,_that.listId,_that.payload,_that.likeCount,_that.commentCount,_that.createdAt,_that.user,_that.title,_that.list,_that.entry,_that.likedByMe);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  ActivityKind kind,  String? titleId,  String? entryId,  String? listId,  Map<String, dynamic> payload,  int likeCount,  int commentCount,  DateTime createdAt,  Profile? user,  Title? title,  ListModel? list,  Entry? entry,  bool likedByMe)  $default,) {final _that = this;
switch (_that) {
case _Activity():
return $default(_that.id,_that.userId,_that.kind,_that.titleId,_that.entryId,_that.listId,_that.payload,_that.likeCount,_that.commentCount,_that.createdAt,_that.user,_that.title,_that.list,_that.entry,_that.likedByMe);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  ActivityKind kind,  String? titleId,  String? entryId,  String? listId,  Map<String, dynamic> payload,  int likeCount,  int commentCount,  DateTime createdAt,  Profile? user,  Title? title,  ListModel? list,  Entry? entry,  bool likedByMe)?  $default,) {final _that = this;
switch (_that) {
case _Activity() when $default != null:
return $default(_that.id,_that.userId,_that.kind,_that.titleId,_that.entryId,_that.listId,_that.payload,_that.likeCount,_that.commentCount,_that.createdAt,_that.user,_that.title,_that.list,_that.entry,_that.likedByMe);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Activity extends Activity {
  const _Activity({required this.id, required this.userId, required this.kind, this.titleId, this.entryId, this.listId,  Map<String, dynamic> payload = const <String, dynamic>{}, this.likeCount = 0, this.commentCount = 0, required this.createdAt, this.user, this.title, this.list, this.entry, this.likedByMe = false}): _payload = payload,super._();
  factory _Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

@override final  String id;
@override final  String userId;
@override final  ActivityKind kind;
@override final  String? titleId;
@override final  String? entryId;
@override final  String? listId;
 final  Map<String, dynamic> _payload;
@override@JsonKey() Map<String, dynamic> get payload {
  if (_payload is EqualUnmodifiableMapView) return _payload;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_payload);
}

@override@JsonKey() final  int likeCount;
@override@JsonKey() final  int commentCount;
@override final  DateTime createdAt;
@override final  Profile? user;
@override final  Title? title;
@override final  ListModel? list;
@override final  Entry? entry;
@override@JsonKey() final  bool likedByMe;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ActivityCopyWith<_Activity> get copyWith => __$ActivityCopyWithImpl<_Activity>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ActivityToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Activity&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kind, kind) || other.kind == kind)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.entryId, entryId) || other.entryId == entryId)&&(identical(other.listId, listId) || other.listId == listId)&&const DeepCollectionEquality().equals(other._payload, _payload)&&(identical(other.likeCount, likeCount) || other.likeCount == likeCount)&&(identical(other.commentCount, commentCount) || other.commentCount == commentCount)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.title, title) || other.title == title)&&(identical(other.list, list) || other.list == list)&&(identical(other.entry, entry) || other.entry == entry)&&(identical(other.likedByMe, likedByMe) || other.likedByMe == likedByMe));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,kind,titleId,entryId,listId,const DeepCollectionEquality().hash(_payload),likeCount,commentCount,createdAt,user,title,list,entry,likedByMe);

@override
String toString() {
  return 'Activity(id: $id, userId: $userId, kind: $kind, titleId: $titleId, entryId: $entryId, listId: $listId, payload: $payload, likeCount: $likeCount, commentCount: $commentCount, createdAt: $createdAt, user: $user, title: $title, list: $list, entry: $entry, likedByMe: $likedByMe)';
}


}

/// @nodoc
abstract mixin class _$ActivityCopyWith<$Res> implements $ActivityCopyWith<$Res> {
  factory _$ActivityCopyWith(_Activity value, $Res Function(_Activity) _then) = __$ActivityCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, ActivityKind kind, String? titleId, String? entryId, String? listId, Map<String, dynamic> payload, int likeCount, int commentCount, DateTime createdAt, Profile? user, Title? title, ListModel? list, Entry? entry, bool likedByMe
});


@override $ProfileCopyWith<$Res>? get user;@override $TitleCopyWith<$Res>? get title;@override $ListModelCopyWith<$Res>? get list;@override $EntryCopyWith<$Res>? get entry;

}
/// @nodoc
class __$ActivityCopyWithImpl<$Res>
    implements _$ActivityCopyWith<$Res> {
  __$ActivityCopyWithImpl(this._self, this._then);

  final _Activity _self;
  final $Res Function(_Activity) _then;

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? kind = null,Object? titleId = freezed,Object? entryId = freezed,Object? listId = freezed,Object? payload = null,Object? likeCount = null,Object? commentCount = null,Object? createdAt = null,Object? user = freezed,Object? title = freezed,Object? list = freezed,Object? entry = freezed,Object? likedByMe = null,}) {
  return _then(_Activity(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kind: null == kind ? _self.kind : kind // ignore: cast_nullable_to_non_nullable
as ActivityKind,titleId: freezed == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String?,entryId: freezed == entryId ? _self.entryId : entryId // ignore: cast_nullable_to_non_nullable
as String?,listId: freezed == listId ? _self.listId : listId // ignore: cast_nullable_to_non_nullable
as String?,payload: null == payload ? _self._payload : payload // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,likeCount: null == likeCount ? _self.likeCount : likeCount // ignore: cast_nullable_to_non_nullable
as int,commentCount: null == commentCount ? _self.commentCount : commentCount // ignore: cast_nullable_to_non_nullable
as int,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Profile?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,list: freezed == list ? _self.list : list // ignore: cast_nullable_to_non_nullable
as ListModel?,entry: freezed == entry ? _self.entry : entry // ignore: cast_nullable_to_non_nullable
as Entry?,likedByMe: null == likedByMe ? _self.likedByMe : likedByMe // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Activity
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
}/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ListModelCopyWith<$Res>? get list {
    if (_self.list == null) {
    return null;
  }

  return $ListModelCopyWith<$Res>(_self.list!, (value) {
    return _then(_self.copyWith(list: value));
  });
}/// Create a copy of Activity
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryCopyWith<$Res>? get entry {
    if (_self.entry == null) {
    return null;
  }

  return $EntryCopyWith<$Res>(_self.entry!, (value) {
    return _then(_self.copyWith(entry: value));
  });
}
}


/// @nodoc
mixin _$Comment {

 String get id; String get activityId; String get userId; String get body; bool get hasSpoiler; DateTime? get createdAt; DateTime? get updatedAt; Profile? get user;
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CommentCopyWith<Comment> get copyWith => _$CommentCopyWithImpl<Comment>(this as Comment, _$identity);

  /// Serializes this Comment to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.body, body) || other.body == body)&&(identical(other.hasSpoiler, hasSpoiler) || other.hasSpoiler == hasSpoiler)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityId,userId,body,hasSpoiler,createdAt,updatedAt,user);

@override
String toString() {
  return 'Comment(id: $id, activityId: $activityId, userId: $userId, body: $body, hasSpoiler: $hasSpoiler, createdAt: $createdAt, updatedAt: $updatedAt, user: $user)';
}


}

/// @nodoc
abstract mixin class $CommentCopyWith<$Res>  {
  factory $CommentCopyWith(Comment value, $Res Function(Comment) _then) = _$CommentCopyWithImpl;
@useResult
$Res call({
 String id, String activityId, String userId, String body, bool hasSpoiler, DateTime? createdAt, DateTime? updatedAt, Profile? user
});


$ProfileCopyWith<$Res>? get user;

}
/// @nodoc
class _$CommentCopyWithImpl<$Res>
    implements $CommentCopyWith<$Res> {
  _$CommentCopyWithImpl(this._self, this._then);

  final Comment _self;
  final $Res Function(Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? activityId = null,Object? userId = null,Object? body = null,Object? hasSpoiler = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? user = freezed,}) {
  return _then(Comment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,hasSpoiler: null == hasSpoiler ? _self.hasSpoiler : hasSpoiler // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Profile?,
  ));
}
/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [Comment].
extension CommentPatterns on Comment {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Comment value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Comment value)  $default,){
final _that = this;
switch (_that) {
case _Comment():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Comment value)?  $default,){
final _that = this;
switch (_that) {
case _Comment() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String activityId,  String userId,  String body,  bool hasSpoiler,  DateTime? createdAt,  DateTime? updatedAt,  Profile? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.activityId,_that.userId,_that.body,_that.hasSpoiler,_that.createdAt,_that.updatedAt,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String activityId,  String userId,  String body,  bool hasSpoiler,  DateTime? createdAt,  DateTime? updatedAt,  Profile? user)  $default,) {final _that = this;
switch (_that) {
case _Comment():
return $default(_that.id,_that.activityId,_that.userId,_that.body,_that.hasSpoiler,_that.createdAt,_that.updatedAt,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String activityId,  String userId,  String body,  bool hasSpoiler,  DateTime? createdAt,  DateTime? updatedAt,  Profile? user)?  $default,) {final _that = this;
switch (_that) {
case _Comment() when $default != null:
return $default(_that.id,_that.activityId,_that.userId,_that.body,_that.hasSpoiler,_that.createdAt,_that.updatedAt,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Comment implements Comment {
  const _Comment({required this.id, required this.activityId, required this.userId, required this.body, this.hasSpoiler = false, this.createdAt, this.updatedAt, this.user});
  factory _Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);

@override final  String id;
@override final  String activityId;
@override final  String userId;
@override final  String body;
@override@JsonKey() final  bool hasSpoiler;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  Profile? user;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CommentCopyWith<_Comment> get copyWith => __$CommentCopyWithImpl<_Comment>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CommentToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Comment&&(identical(other.id, id) || other.id == id)&&(identical(other.activityId, activityId) || other.activityId == activityId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.body, body) || other.body == body)&&(identical(other.hasSpoiler, hasSpoiler) || other.hasSpoiler == hasSpoiler)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,activityId,userId,body,hasSpoiler,createdAt,updatedAt,user);

@override
String toString() {
  return 'Comment(id: $id, activityId: $activityId, userId: $userId, body: $body, hasSpoiler: $hasSpoiler, createdAt: $createdAt, updatedAt: $updatedAt, user: $user)';
}


}

/// @nodoc
abstract mixin class _$CommentCopyWith<$Res> implements $CommentCopyWith<$Res> {
  factory _$CommentCopyWith(_Comment value, $Res Function(_Comment) _then) = __$CommentCopyWithImpl;
@override @useResult
$Res call({
 String id, String activityId, String userId, String body, bool hasSpoiler, DateTime? createdAt, DateTime? updatedAt, Profile? user
});


@override $ProfileCopyWith<$Res>? get user;

}
/// @nodoc
class __$CommentCopyWithImpl<$Res>
    implements _$CommentCopyWith<$Res> {
  __$CommentCopyWithImpl(this._self, this._then);

  final _Comment _self;
  final $Res Function(_Comment) _then;

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? activityId = null,Object? userId = null,Object? body = null,Object? hasSpoiler = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? user = freezed,}) {
  return _then(_Comment(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,activityId: null == activityId ? _self.activityId : activityId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,body: null == body ? _self.body : body // ignore: cast_nullable_to_non_nullable
as String,hasSpoiler: null == hasSpoiler ? _self.hasSpoiler : hasSpoiler // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Profile?,
  ));
}

/// Create a copy of Comment
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$Checkin {

 String get id; String get userId; String get titleId; int? get season; int? get episode; String? get note; DateTime? get createdAt; DateTime get expiresAt; Profile? get user; Title? get title;
/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinCopyWith<Checkin> get copyWith => _$CheckinCopyWithImpl<Checkin>(this as Checkin, _$identity);

  /// Serializes this Checkin to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Checkin&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.season, season) || other.season == season)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,titleId,season,episode,note,createdAt,expiresAt,user,title);

@override
String toString() {
  return 'Checkin(id: $id, userId: $userId, titleId: $titleId, season: $season, episode: $episode, note: $note, createdAt: $createdAt, expiresAt: $expiresAt, user: $user, title: $title)';
}


}

/// @nodoc
abstract mixin class $CheckinCopyWith<$Res>  {
  factory $CheckinCopyWith(Checkin value, $Res Function(Checkin) _then) = _$CheckinCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String titleId, int? season, int? episode, String? note, DateTime? createdAt, DateTime expiresAt, Profile? user, Title? title
});


$ProfileCopyWith<$Res>? get user;$TitleCopyWith<$Res>? get title;

}
/// @nodoc
class _$CheckinCopyWithImpl<$Res>
    implements $CheckinCopyWith<$Res> {
  _$CheckinCopyWithImpl(this._self, this._then);

  final Checkin _self;
  final $Res Function(Checkin) _then;

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? titleId = null,Object? season = freezed,Object? episode = freezed,Object? note = freezed,Object? createdAt = freezed,Object? expiresAt = null,Object? user = freezed,Object? title = freezed,}) {
  return _then(Checkin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as int?,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Profile?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,
  ));
}
/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Checkin
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


/// Adds pattern-matching-related methods to [Checkin].
extension CheckinPatterns on Checkin {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Checkin value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Checkin() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Checkin value)  $default,){
final _that = this;
switch (_that) {
case _Checkin():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Checkin value)?  $default,){
final _that = this;
switch (_that) {
case _Checkin() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String titleId,  int? season,  int? episode,  String? note,  DateTime? createdAt,  DateTime expiresAt,  Profile? user,  Title? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that.id,_that.userId,_that.titleId,_that.season,_that.episode,_that.note,_that.createdAt,_that.expiresAt,_that.user,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String titleId,  int? season,  int? episode,  String? note,  DateTime? createdAt,  DateTime expiresAt,  Profile? user,  Title? title)  $default,) {final _that = this;
switch (_that) {
case _Checkin():
return $default(_that.id,_that.userId,_that.titleId,_that.season,_that.episode,_that.note,_that.createdAt,_that.expiresAt,_that.user,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String titleId,  int? season,  int? episode,  String? note,  DateTime? createdAt,  DateTime expiresAt,  Profile? user,  Title? title)?  $default,) {final _that = this;
switch (_that) {
case _Checkin() when $default != null:
return $default(_that.id,_that.userId,_that.titleId,_that.season,_that.episode,_that.note,_that.createdAt,_that.expiresAt,_that.user,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Checkin extends Checkin {
  const _Checkin({required this.id, required this.userId, required this.titleId, this.season, this.episode, this.note, this.createdAt, required this.expiresAt, this.user, this.title}): super._();
  factory _Checkin.fromJson(Map<String, dynamic> json) => _$CheckinFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String titleId;
@override final  int? season;
@override final  int? episode;
@override final  String? note;
@override final  DateTime? createdAt;
@override final  DateTime expiresAt;
@override final  Profile? user;
@override final  Title? title;

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinCopyWith<_Checkin> get copyWith => __$CheckinCopyWithImpl<_Checkin>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CheckinToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Checkin&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.season, season) || other.season == season)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.note, note) || other.note == note)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.expiresAt, expiresAt) || other.expiresAt == expiresAt)&&(identical(other.user, user) || other.user == user)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,titleId,season,episode,note,createdAt,expiresAt,user,title);

@override
String toString() {
  return 'Checkin(id: $id, userId: $userId, titleId: $titleId, season: $season, episode: $episode, note: $note, createdAt: $createdAt, expiresAt: $expiresAt, user: $user, title: $title)';
}


}

/// @nodoc
abstract mixin class _$CheckinCopyWith<$Res> implements $CheckinCopyWith<$Res> {
  factory _$CheckinCopyWith(_Checkin value, $Res Function(_Checkin) _then) = __$CheckinCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String titleId, int? season, int? episode, String? note, DateTime? createdAt, DateTime expiresAt, Profile? user, Title? title
});


@override $ProfileCopyWith<$Res>? get user;@override $TitleCopyWith<$Res>? get title;

}
/// @nodoc
class __$CheckinCopyWithImpl<$Res>
    implements _$CheckinCopyWith<$Res> {
  __$CheckinCopyWithImpl(this._self, this._then);

  final _Checkin _self;
  final $Res Function(_Checkin) _then;

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? titleId = null,Object? season = freezed,Object? episode = freezed,Object? note = freezed,Object? createdAt = freezed,Object? expiresAt = null,Object? user = freezed,Object? title = freezed,}) {
  return _then(_Checkin(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as int?,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,expiresAt: null == expiresAt ? _self.expiresAt : expiresAt // ignore: cast_nullable_to_non_nullable
as DateTime,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as Profile?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,
  ));
}

/// Create a copy of Checkin
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $ProfileCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}/// Create a copy of Checkin
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
mixin _$CheckinDraft {

 String get titleId; int? get season; int? get episode; String? get note;
/// Create a copy of CheckinDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CheckinDraftCopyWith<CheckinDraft> get copyWith => _$CheckinDraftCopyWithImpl<CheckinDraft>(this as CheckinDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CheckinDraft&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.season, season) || other.season == season)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,titleId,season,episode,note);

@override
String toString() {
  return 'CheckinDraft(titleId: $titleId, season: $season, episode: $episode, note: $note)';
}


}

/// @nodoc
abstract mixin class $CheckinDraftCopyWith<$Res>  {
  factory $CheckinDraftCopyWith(CheckinDraft value, $Res Function(CheckinDraft) _then) = _$CheckinDraftCopyWithImpl;
@useResult
$Res call({
 String titleId, int? season, int? episode, String? note
});




}
/// @nodoc
class _$CheckinDraftCopyWithImpl<$Res>
    implements $CheckinDraftCopyWith<$Res> {
  _$CheckinDraftCopyWithImpl(this._self, this._then);

  final CheckinDraft _self;
  final $Res Function(CheckinDraft) _then;

/// Create a copy of CheckinDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleId = null,Object? season = freezed,Object? episode = freezed,Object? note = freezed,}) {
  return _then(CheckinDraft(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as int?,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [CheckinDraft].
extension CheckinDraftPatterns on CheckinDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CheckinDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CheckinDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CheckinDraft value)  $default,){
final _that = this;
switch (_that) {
case _CheckinDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CheckinDraft value)?  $default,){
final _that = this;
switch (_that) {
case _CheckinDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleId,  int? season,  int? episode,  String? note)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CheckinDraft() when $default != null:
return $default(_that.titleId,_that.season,_that.episode,_that.note);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleId,  int? season,  int? episode,  String? note)  $default,) {final _that = this;
switch (_that) {
case _CheckinDraft():
return $default(_that.titleId,_that.season,_that.episode,_that.note);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleId,  int? season,  int? episode,  String? note)?  $default,) {final _that = this;
switch (_that) {
case _CheckinDraft() when $default != null:
return $default(_that.titleId,_that.season,_that.episode,_that.note);case _:
  return null;

}
}

}

/// @nodoc


class _CheckinDraft implements CheckinDraft {
  const _CheckinDraft({required this.titleId, this.season, this.episode, this.note});
  

@override final  String titleId;
@override final  int? season;
@override final  int? episode;
@override final  String? note;

/// Create a copy of CheckinDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CheckinDraftCopyWith<_CheckinDraft> get copyWith => __$CheckinDraftCopyWithImpl<_CheckinDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CheckinDraft&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.season, season) || other.season == season)&&(identical(other.episode, episode) || other.episode == episode)&&(identical(other.note, note) || other.note == note));
}


@override
int get hashCode => Object.hash(runtimeType,titleId,season,episode,note);

@override
String toString() {
  return 'CheckinDraft(titleId: $titleId, season: $season, episode: $episode, note: $note)';
}


}

/// @nodoc
abstract mixin class _$CheckinDraftCopyWith<$Res> implements $CheckinDraftCopyWith<$Res> {
  factory _$CheckinDraftCopyWith(_CheckinDraft value, $Res Function(_CheckinDraft) _then) = __$CheckinDraftCopyWithImpl;
@override @useResult
$Res call({
 String titleId, int? season, int? episode, String? note
});




}
/// @nodoc
class __$CheckinDraftCopyWithImpl<$Res>
    implements _$CheckinDraftCopyWith<$Res> {
  __$CheckinDraftCopyWithImpl(this._self, this._then);

  final _CheckinDraft _self;
  final $Res Function(_CheckinDraft) _then;

/// Create a copy of CheckinDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleId = null,Object? season = freezed,Object? episode = freezed,Object? note = freezed,}) {
  return _then(_CheckinDraft(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,season: freezed == season ? _self.season : season // ignore: cast_nullable_to_non_nullable
as int?,episode: freezed == episode ? _self.episode : episode // ignore: cast_nullable_to_non_nullable
as int?,note: freezed == note ? _self.note : note // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
