// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$Entry {

 String get id; String get userId; String get titleId; EntryStatus get status; double? get rating; String? get review; bool get hasSpoiler; DateTime? get watchedAt; int? get currentSeason; int? get currentEpisode; int? get episodesWatched; int get watchCount; String get source; DateTime? get createdAt; DateTime? get updatedAt; Title? get title;
/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryCopyWith<Entry> get copyWith => _$EntryCopyWithImpl<Entry>(this as Entry, _$identity);

  /// Serializes this Entry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Entry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.hasSpoiler, hasSpoiler) || other.hasSpoiler == hasSpoiler)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&(identical(other.currentEpisode, currentEpisode) || other.currentEpisode == currentEpisode)&&(identical(other.episodesWatched, episodesWatched) || other.episodesWatched == episodesWatched)&&(identical(other.watchCount, watchCount) || other.watchCount == watchCount)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,titleId,status,rating,review,hasSpoiler,watchedAt,currentSeason,currentEpisode,episodesWatched,watchCount,source,createdAt,updatedAt,title);

@override
String toString() {
  return 'Entry(id: $id, userId: $userId, titleId: $titleId, status: $status, rating: $rating, review: $review, hasSpoiler: $hasSpoiler, watchedAt: $watchedAt, currentSeason: $currentSeason, currentEpisode: $currentEpisode, episodesWatched: $episodesWatched, watchCount: $watchCount, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, title: $title)';
}


}

/// @nodoc
abstract mixin class $EntryCopyWith<$Res>  {
  factory $EntryCopyWith(Entry value, $Res Function(Entry) _then) = _$EntryCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String titleId, EntryStatus status, double? rating, String? review, bool hasSpoiler, DateTime? watchedAt, int? currentSeason, int? currentEpisode, int? episodesWatched, int watchCount, String source, DateTime? createdAt, DateTime? updatedAt, Title? title
});


$TitleCopyWith<$Res>? get title;

}
/// @nodoc
class _$EntryCopyWithImpl<$Res>
    implements $EntryCopyWith<$Res> {
  _$EntryCopyWithImpl(this._self, this._then);

  final Entry _self;
  final $Res Function(Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? titleId = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? hasSpoiler = null,Object? watchedAt = freezed,Object? currentSeason = freezed,Object? currentEpisode = freezed,Object? episodesWatched = freezed,Object? watchCount = null,Object? source = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? title = freezed,}) {
  return _then(Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntryStatus,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,hasSpoiler: null == hasSpoiler ? _self.hasSpoiler : hasSpoiler // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,currentSeason: freezed == currentSeason ? _self.currentSeason : currentSeason // ignore: cast_nullable_to_non_nullable
as int?,currentEpisode: freezed == currentEpisode ? _self.currentEpisode : currentEpisode // ignore: cast_nullable_to_non_nullable
as int?,episodesWatched: freezed == episodesWatched ? _self.episodesWatched : episodesWatched // ignore: cast_nullable_to_non_nullable
as int?,watchCount: null == watchCount ? _self.watchCount : watchCount // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,
  ));
}
/// Create a copy of Entry
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


/// Adds pattern-matching-related methods to [Entry].
extension EntryPatterns on Entry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Entry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Entry value)  $default,){
final _that = this;
switch (_that) {
case _Entry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Entry value)?  $default,){
final _that = this;
switch (_that) {
case _Entry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String titleId,  EntryStatus status,  double? rating,  String? review,  bool hasSpoiler,  DateTime? watchedAt,  int? currentSeason,  int? currentEpisode,  int? episodesWatched,  int watchCount,  String source,  DateTime? createdAt,  DateTime? updatedAt,  Title? title)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.userId,_that.titleId,_that.status,_that.rating,_that.review,_that.hasSpoiler,_that.watchedAt,_that.currentSeason,_that.currentEpisode,_that.episodesWatched,_that.watchCount,_that.source,_that.createdAt,_that.updatedAt,_that.title);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String titleId,  EntryStatus status,  double? rating,  String? review,  bool hasSpoiler,  DateTime? watchedAt,  int? currentSeason,  int? currentEpisode,  int? episodesWatched,  int watchCount,  String source,  DateTime? createdAt,  DateTime? updatedAt,  Title? title)  $default,) {final _that = this;
switch (_that) {
case _Entry():
return $default(_that.id,_that.userId,_that.titleId,_that.status,_that.rating,_that.review,_that.hasSpoiler,_that.watchedAt,_that.currentSeason,_that.currentEpisode,_that.episodesWatched,_that.watchCount,_that.source,_that.createdAt,_that.updatedAt,_that.title);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String titleId,  EntryStatus status,  double? rating,  String? review,  bool hasSpoiler,  DateTime? watchedAt,  int? currentSeason,  int? currentEpisode,  int? episodesWatched,  int watchCount,  String source,  DateTime? createdAt,  DateTime? updatedAt,  Title? title)?  $default,) {final _that = this;
switch (_that) {
case _Entry() when $default != null:
return $default(_that.id,_that.userId,_that.titleId,_that.status,_that.rating,_that.review,_that.hasSpoiler,_that.watchedAt,_that.currentSeason,_that.currentEpisode,_that.episodesWatched,_that.watchCount,_that.source,_that.createdAt,_that.updatedAt,_that.title);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Entry extends Entry {
  const _Entry({required this.id, required this.userId, required this.titleId, required this.status, this.rating, this.review, this.hasSpoiler = false, this.watchedAt, this.currentSeason, this.currentEpisode, this.episodesWatched, this.watchCount = 1, this.source = 'manual', this.createdAt, this.updatedAt, this.title}): super._();
  factory _Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

@override final  String id;
@override final  String userId;
@override final  String titleId;
@override final  EntryStatus status;
@override final  double? rating;
@override final  String? review;
@override@JsonKey() final  bool hasSpoiler;
@override final  DateTime? watchedAt;
@override final  int? currentSeason;
@override final  int? currentEpisode;
@override final  int? episodesWatched;
@override@JsonKey() final  int watchCount;
@override@JsonKey() final  String source;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  Title? title;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryCopyWith<_Entry> get copyWith => __$EntryCopyWithImpl<_Entry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Entry&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.hasSpoiler, hasSpoiler) || other.hasSpoiler == hasSpoiler)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&(identical(other.currentEpisode, currentEpisode) || other.currentEpisode == currentEpisode)&&(identical(other.episodesWatched, episodesWatched) || other.episodesWatched == episodesWatched)&&(identical(other.watchCount, watchCount) || other.watchCount == watchCount)&&(identical(other.source, source) || other.source == source)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.title, title) || other.title == title));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,titleId,status,rating,review,hasSpoiler,watchedAt,currentSeason,currentEpisode,episodesWatched,watchCount,source,createdAt,updatedAt,title);

@override
String toString() {
  return 'Entry(id: $id, userId: $userId, titleId: $titleId, status: $status, rating: $rating, review: $review, hasSpoiler: $hasSpoiler, watchedAt: $watchedAt, currentSeason: $currentSeason, currentEpisode: $currentEpisode, episodesWatched: $episodesWatched, watchCount: $watchCount, source: $source, createdAt: $createdAt, updatedAt: $updatedAt, title: $title)';
}


}

/// @nodoc
abstract mixin class _$EntryCopyWith<$Res> implements $EntryCopyWith<$Res> {
  factory _$EntryCopyWith(_Entry value, $Res Function(_Entry) _then) = __$EntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String titleId, EntryStatus status, double? rating, String? review, bool hasSpoiler, DateTime? watchedAt, int? currentSeason, int? currentEpisode, int? episodesWatched, int watchCount, String source, DateTime? createdAt, DateTime? updatedAt, Title? title
});


@override $TitleCopyWith<$Res>? get title;

}
/// @nodoc
class __$EntryCopyWithImpl<$Res>
    implements _$EntryCopyWith<$Res> {
  __$EntryCopyWithImpl(this._self, this._then);

  final _Entry _self;
  final $Res Function(_Entry) _then;

/// Create a copy of Entry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? titleId = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? hasSpoiler = null,Object? watchedAt = freezed,Object? currentSeason = freezed,Object? currentEpisode = freezed,Object? episodesWatched = freezed,Object? watchCount = null,Object? source = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? title = freezed,}) {
  return _then(_Entry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntryStatus,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,hasSpoiler: null == hasSpoiler ? _self.hasSpoiler : hasSpoiler // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,currentSeason: freezed == currentSeason ? _self.currentSeason : currentSeason // ignore: cast_nullable_to_non_nullable
as int?,currentEpisode: freezed == currentEpisode ? _self.currentEpisode : currentEpisode // ignore: cast_nullable_to_non_nullable
as int?,episodesWatched: freezed == episodesWatched ? _self.episodesWatched : episodesWatched // ignore: cast_nullable_to_non_nullable
as int?,watchCount: null == watchCount ? _self.watchCount : watchCount // ignore: cast_nullable_to_non_nullable
as int,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as Title?,
  ));
}

/// Create a copy of Entry
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
mixin _$EntryDraft {

 String get titleId; EntryStatus get status; double? get rating; String? get review; bool get hasSpoiler; DateTime? get watchedAt; int? get currentSeason; int? get currentEpisode; int? get episodesWatched; int get watchCount;
/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryDraftCopyWith<EntryDraft> get copyWith => _$EntryDraftCopyWithImpl<EntryDraft>(this as EntryDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryDraft&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.hasSpoiler, hasSpoiler) || other.hasSpoiler == hasSpoiler)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&(identical(other.currentEpisode, currentEpisode) || other.currentEpisode == currentEpisode)&&(identical(other.episodesWatched, episodesWatched) || other.episodesWatched == episodesWatched)&&(identical(other.watchCount, watchCount) || other.watchCount == watchCount));
}


@override
int get hashCode => Object.hash(runtimeType,titleId,status,rating,review,hasSpoiler,watchedAt,currentSeason,currentEpisode,episodesWatched,watchCount);

@override
String toString() {
  return 'EntryDraft(titleId: $titleId, status: $status, rating: $rating, review: $review, hasSpoiler: $hasSpoiler, watchedAt: $watchedAt, currentSeason: $currentSeason, currentEpisode: $currentEpisode, episodesWatched: $episodesWatched, watchCount: $watchCount)';
}


}

/// @nodoc
abstract mixin class $EntryDraftCopyWith<$Res>  {
  factory $EntryDraftCopyWith(EntryDraft value, $Res Function(EntryDraft) _then) = _$EntryDraftCopyWithImpl;
@useResult
$Res call({
 String titleId, EntryStatus status, double? rating, String? review, bool hasSpoiler, DateTime? watchedAt, int? currentSeason, int? currentEpisode, int? episodesWatched, int watchCount
});




}
/// @nodoc
class _$EntryDraftCopyWithImpl<$Res>
    implements $EntryDraftCopyWith<$Res> {
  _$EntryDraftCopyWithImpl(this._self, this._then);

  final EntryDraft _self;
  final $Res Function(EntryDraft) _then;

/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleId = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? hasSpoiler = null,Object? watchedAt = freezed,Object? currentSeason = freezed,Object? currentEpisode = freezed,Object? episodesWatched = freezed,Object? watchCount = null,}) {
  return _then(EntryDraft(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntryStatus,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,hasSpoiler: null == hasSpoiler ? _self.hasSpoiler : hasSpoiler // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,currentSeason: freezed == currentSeason ? _self.currentSeason : currentSeason // ignore: cast_nullable_to_non_nullable
as int?,currentEpisode: freezed == currentEpisode ? _self.currentEpisode : currentEpisode // ignore: cast_nullable_to_non_nullable
as int?,episodesWatched: freezed == episodesWatched ? _self.episodesWatched : episodesWatched // ignore: cast_nullable_to_non_nullable
as int?,watchCount: null == watchCount ? _self.watchCount : watchCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [EntryDraft].
extension EntryDraftPatterns on EntryDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryDraft value)  $default,){
final _that = this;
switch (_that) {
case _EntryDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryDraft value)?  $default,){
final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleId,  EntryStatus status,  double? rating,  String? review,  bool hasSpoiler,  DateTime? watchedAt,  int? currentSeason,  int? currentEpisode,  int? episodesWatched,  int watchCount)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
return $default(_that.titleId,_that.status,_that.rating,_that.review,_that.hasSpoiler,_that.watchedAt,_that.currentSeason,_that.currentEpisode,_that.episodesWatched,_that.watchCount);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleId,  EntryStatus status,  double? rating,  String? review,  bool hasSpoiler,  DateTime? watchedAt,  int? currentSeason,  int? currentEpisode,  int? episodesWatched,  int watchCount)  $default,) {final _that = this;
switch (_that) {
case _EntryDraft():
return $default(_that.titleId,_that.status,_that.rating,_that.review,_that.hasSpoiler,_that.watchedAt,_that.currentSeason,_that.currentEpisode,_that.episodesWatched,_that.watchCount);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleId,  EntryStatus status,  double? rating,  String? review,  bool hasSpoiler,  DateTime? watchedAt,  int? currentSeason,  int? currentEpisode,  int? episodesWatched,  int watchCount)?  $default,) {final _that = this;
switch (_that) {
case _EntryDraft() when $default != null:
return $default(_that.titleId,_that.status,_that.rating,_that.review,_that.hasSpoiler,_that.watchedAt,_that.currentSeason,_that.currentEpisode,_that.episodesWatched,_that.watchCount);case _:
  return null;

}
}

}

/// @nodoc


class _EntryDraft extends EntryDraft {
  const _EntryDraft({required this.titleId, required this.status, this.rating, this.review, this.hasSpoiler = false, this.watchedAt, this.currentSeason, this.currentEpisode, this.episodesWatched, this.watchCount = 1}): super._();
  

@override final  String titleId;
@override final  EntryStatus status;
@override final  double? rating;
@override final  String? review;
@override@JsonKey() final  bool hasSpoiler;
@override final  DateTime? watchedAt;
@override final  int? currentSeason;
@override final  int? currentEpisode;
@override final  int? episodesWatched;
@override@JsonKey() final  int watchCount;

/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryDraftCopyWith<_EntryDraft> get copyWith => __$EntryDraftCopyWithImpl<_EntryDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryDraft&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.status, status) || other.status == status)&&(identical(other.rating, rating) || other.rating == rating)&&(identical(other.review, review) || other.review == review)&&(identical(other.hasSpoiler, hasSpoiler) || other.hasSpoiler == hasSpoiler)&&(identical(other.watchedAt, watchedAt) || other.watchedAt == watchedAt)&&(identical(other.currentSeason, currentSeason) || other.currentSeason == currentSeason)&&(identical(other.currentEpisode, currentEpisode) || other.currentEpisode == currentEpisode)&&(identical(other.episodesWatched, episodesWatched) || other.episodesWatched == episodesWatched)&&(identical(other.watchCount, watchCount) || other.watchCount == watchCount));
}


@override
int get hashCode => Object.hash(runtimeType,titleId,status,rating,review,hasSpoiler,watchedAt,currentSeason,currentEpisode,episodesWatched,watchCount);

@override
String toString() {
  return 'EntryDraft(titleId: $titleId, status: $status, rating: $rating, review: $review, hasSpoiler: $hasSpoiler, watchedAt: $watchedAt, currentSeason: $currentSeason, currentEpisode: $currentEpisode, episodesWatched: $episodesWatched, watchCount: $watchCount)';
}


}

/// @nodoc
abstract mixin class _$EntryDraftCopyWith<$Res> implements $EntryDraftCopyWith<$Res> {
  factory _$EntryDraftCopyWith(_EntryDraft value, $Res Function(_EntryDraft) _then) = __$EntryDraftCopyWithImpl;
@override @useResult
$Res call({
 String titleId, EntryStatus status, double? rating, String? review, bool hasSpoiler, DateTime? watchedAt, int? currentSeason, int? currentEpisode, int? episodesWatched, int watchCount
});




}
/// @nodoc
class __$EntryDraftCopyWithImpl<$Res>
    implements _$EntryDraftCopyWith<$Res> {
  __$EntryDraftCopyWithImpl(this._self, this._then);

  final _EntryDraft _self;
  final $Res Function(_EntryDraft) _then;

/// Create a copy of EntryDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleId = null,Object? status = null,Object? rating = freezed,Object? review = freezed,Object? hasSpoiler = null,Object? watchedAt = freezed,Object? currentSeason = freezed,Object? currentEpisode = freezed,Object? episodesWatched = freezed,Object? watchCount = null,}) {
  return _then(_EntryDraft(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntryStatus,rating: freezed == rating ? _self.rating : rating // ignore: cast_nullable_to_non_nullable
as double?,review: freezed == review ? _self.review : review // ignore: cast_nullable_to_non_nullable
as String?,hasSpoiler: null == hasSpoiler ? _self.hasSpoiler : hasSpoiler // ignore: cast_nullable_to_non_nullable
as bool,watchedAt: freezed == watchedAt ? _self.watchedAt : watchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,currentSeason: freezed == currentSeason ? _self.currentSeason : currentSeason // ignore: cast_nullable_to_non_nullable
as int?,currentEpisode: freezed == currentEpisode ? _self.currentEpisode : currentEpisode // ignore: cast_nullable_to_non_nullable
as int?,episodesWatched: freezed == episodesWatched ? _self.episodesWatched : episodesWatched // ignore: cast_nullable_to_non_nullable
as int?,watchCount: null == watchCount ? _self.watchCount : watchCount // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
