// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'social_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$FollowRequest {

 Profile get follower; DateTime? get createdAt;
/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$FollowRequestCopyWith<FollowRequest> get copyWith => _$FollowRequestCopyWithImpl<FollowRequest>(this as FollowRequest, _$identity);

  /// Serializes this FollowRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is FollowRequest&&(identical(other.follower, follower) || other.follower == follower)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,follower,createdAt);

@override
String toString() {
  return 'FollowRequest(follower: $follower, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $FollowRequestCopyWith<$Res>  {
  factory $FollowRequestCopyWith(FollowRequest value, $Res Function(FollowRequest) _then) = _$FollowRequestCopyWithImpl;
@useResult
$Res call({
 Profile follower, DateTime? createdAt
});


$ProfileCopyWith<$Res> get follower;

}
/// @nodoc
class _$FollowRequestCopyWithImpl<$Res>
    implements $FollowRequestCopyWith<$Res> {
  _$FollowRequestCopyWithImpl(this._self, this._then);

  final FollowRequest _self;
  final $Res Function(FollowRequest) _then;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? follower = null,Object? createdAt = freezed,}) {
  return _then(FollowRequest(
follower: null == follower ? _self.follower : follower // ignore: cast_nullable_to_non_nullable
as Profile,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get follower {
  
  return $ProfileCopyWith<$Res>(_self.follower, (value) {
    return _then(_self.copyWith(follower: value));
  });
}
}


/// Adds pattern-matching-related methods to [FollowRequest].
extension FollowRequestPatterns on FollowRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _FollowRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _FollowRequest value)  $default,){
final _that = this;
switch (_that) {
case _FollowRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _FollowRequest value)?  $default,){
final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Profile follower,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
return $default(_that.follower,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Profile follower,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _FollowRequest():
return $default(_that.follower,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Profile follower,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _FollowRequest() when $default != null:
return $default(_that.follower,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _FollowRequest implements FollowRequest {
  const _FollowRequest({required this.follower, this.createdAt});
  factory _FollowRequest.fromJson(Map<String, dynamic> json) => _$FollowRequestFromJson(json);

@override final  Profile follower;
@override final  DateTime? createdAt;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$FollowRequestCopyWith<_FollowRequest> get copyWith => __$FollowRequestCopyWithImpl<_FollowRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$FollowRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _FollowRequest&&(identical(other.follower, follower) || other.follower == follower)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,follower,createdAt);

@override
String toString() {
  return 'FollowRequest(follower: $follower, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$FollowRequestCopyWith<$Res> implements $FollowRequestCopyWith<$Res> {
  factory _$FollowRequestCopyWith(_FollowRequest value, $Res Function(_FollowRequest) _then) = __$FollowRequestCopyWithImpl;
@override @useResult
$Res call({
 Profile follower, DateTime? createdAt
});


@override $ProfileCopyWith<$Res> get follower;

}
/// @nodoc
class __$FollowRequestCopyWithImpl<$Res>
    implements _$FollowRequestCopyWith<$Res> {
  __$FollowRequestCopyWithImpl(this._self, this._then);

  final _FollowRequest _self;
  final $Res Function(_FollowRequest) _then;

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? follower = null,Object? createdAt = freezed,}) {
  return _then(_FollowRequest(
follower: null == follower ? _self.follower : follower // ignore: cast_nullable_to_non_nullable
as Profile,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of FollowRequest
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProfileCopyWith<$Res> get follower {
  
  return $ProfileCopyWith<$Res>(_self.follower, (value) {
    return _then(_self.copyWith(follower: value));
  });
}
}


/// @nodoc
mixin _$BlockedUser {

 String get id; String get username; String? get displayName; String? get avatarUrl; DateTime? get blockedAt;
/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockedUserCopyWith<BlockedUser> get copyWith => _$BlockedUserCopyWithImpl<BlockedUser>(this as BlockedUser, _$identity);

  /// Serializes this BlockedUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,avatarUrl,blockedAt);

@override
String toString() {
  return 'BlockedUser(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class $BlockedUserCopyWith<$Res>  {
  factory $BlockedUserCopyWith(BlockedUser value, $Res Function(BlockedUser) _then) = _$BlockedUserCopyWithImpl;
@useResult
$Res call({
 String id, String username, String? displayName, String? avatarUrl, DateTime? blockedAt
});




}
/// @nodoc
class _$BlockedUserCopyWithImpl<$Res>
    implements $BlockedUserCopyWith<$Res> {
  _$BlockedUserCopyWithImpl(this._self, this._then);

  final BlockedUser _self;
  final $Res Function(BlockedUser) _then;

/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? blockedAt = freezed,}) {
  return _then(BlockedUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockedUser].
extension BlockedUserPatterns on BlockedUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockedUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockedUser value)  $default,){
final _that = this;
switch (_that) {
case _BlockedUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockedUser value)?  $default,){
final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String username,  String? displayName,  String? avatarUrl,  DateTime? blockedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.blockedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String username,  String? displayName,  String? avatarUrl,  DateTime? blockedAt)  $default,) {final _that = this;
switch (_that) {
case _BlockedUser():
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.blockedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String username,  String? displayName,  String? avatarUrl,  DateTime? blockedAt)?  $default,) {final _that = this;
switch (_that) {
case _BlockedUser() when $default != null:
return $default(_that.id,_that.username,_that.displayName,_that.avatarUrl,_that.blockedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlockedUser extends BlockedUser {
  const _BlockedUser({required this.id, required this.username, this.displayName, this.avatarUrl, this.blockedAt}): super._();
  factory _BlockedUser.fromJson(Map<String, dynamic> json) => _$BlockedUserFromJson(json);

@override final  String id;
@override final  String username;
@override final  String? displayName;
@override final  String? avatarUrl;
@override final  DateTime? blockedAt;

/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockedUserCopyWith<_BlockedUser> get copyWith => __$BlockedUserCopyWithImpl<_BlockedUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockedUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockedUser&&(identical(other.id, id) || other.id == id)&&(identical(other.username, username) || other.username == username)&&(identical(other.displayName, displayName) || other.displayName == displayName)&&(identical(other.avatarUrl, avatarUrl) || other.avatarUrl == avatarUrl)&&(identical(other.blockedAt, blockedAt) || other.blockedAt == blockedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,username,displayName,avatarUrl,blockedAt);

@override
String toString() {
  return 'BlockedUser(id: $id, username: $username, displayName: $displayName, avatarUrl: $avatarUrl, blockedAt: $blockedAt)';
}


}

/// @nodoc
abstract mixin class _$BlockedUserCopyWith<$Res> implements $BlockedUserCopyWith<$Res> {
  factory _$BlockedUserCopyWith(_BlockedUser value, $Res Function(_BlockedUser) _then) = __$BlockedUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String username, String? displayName, String? avatarUrl, DateTime? blockedAt
});




}
/// @nodoc
class __$BlockedUserCopyWithImpl<$Res>
    implements _$BlockedUserCopyWith<$Res> {
  __$BlockedUserCopyWithImpl(this._self, this._then);

  final _BlockedUser _self;
  final $Res Function(_BlockedUser) _then;

/// Create a copy of BlockedUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? username = null,Object? displayName = freezed,Object? avatarUrl = freezed,Object? blockedAt = freezed,}) {
  return _then(_BlockedUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,username: null == username ? _self.username : username // ignore: cast_nullable_to_non_nullable
as String,displayName: freezed == displayName ? _self.displayName : displayName // ignore: cast_nullable_to_non_nullable
as String?,avatarUrl: freezed == avatarUrl ? _self.avatarUrl : avatarUrl // ignore: cast_nullable_to_non_nullable
as String?,blockedAt: freezed == blockedAt ? _self.blockedAt : blockedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
