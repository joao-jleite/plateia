// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'profile_stats.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$StatsRow {

 EntryStatus get status; int get watchCount; int? get episodesWatched; MediaType get mediaType; int? get runtimeMinutes; int? get episodeRunTime; int? get numberOfEpisodes; List<String> get genres; int? get year; List<int> get providerIds;
/// Create a copy of StatsRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatsRowCopyWith<StatsRow> get copyWith => _$StatsRowCopyWithImpl<StatsRow>(this as StatsRow, _$identity);

  /// Serializes this StatsRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatsRow&&(identical(other.status, status) || other.status == status)&&(identical(other.watchCount, watchCount) || other.watchCount == watchCount)&&(identical(other.episodesWatched, episodesWatched) || other.episodesWatched == episodesWatched)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.episodeRunTime, episodeRunTime) || other.episodeRunTime == episodeRunTime)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&const DeepCollectionEquality().equals(other.genres, genres)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other.providerIds, providerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,watchCount,episodesWatched,mediaType,runtimeMinutes,episodeRunTime,numberOfEpisodes,const DeepCollectionEquality().hash(genres),year,const DeepCollectionEquality().hash(providerIds));

@override
String toString() {
  return 'StatsRow(status: $status, watchCount: $watchCount, episodesWatched: $episodesWatched, mediaType: $mediaType, runtimeMinutes: $runtimeMinutes, episodeRunTime: $episodeRunTime, numberOfEpisodes: $numberOfEpisodes, genres: $genres, year: $year, providerIds: $providerIds)';
}


}

/// @nodoc
abstract mixin class $StatsRowCopyWith<$Res>  {
  factory $StatsRowCopyWith(StatsRow value, $Res Function(StatsRow) _then) = _$StatsRowCopyWithImpl;
@useResult
$Res call({
 EntryStatus status, int watchCount, int? episodesWatched, MediaType mediaType, int? runtimeMinutes, int? episodeRunTime, int? numberOfEpisodes, List<String> genres, int? year, List<int> providerIds
});




}
/// @nodoc
class _$StatsRowCopyWithImpl<$Res>
    implements $StatsRowCopyWith<$Res> {
  _$StatsRowCopyWithImpl(this._self, this._then);

  final StatsRow _self;
  final $Res Function(StatsRow) _then;

/// Create a copy of StatsRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? watchCount = null,Object? episodesWatched = freezed,Object? mediaType = null,Object? runtimeMinutes = freezed,Object? episodeRunTime = freezed,Object? numberOfEpisodes = freezed,Object? genres = null,Object? year = freezed,Object? providerIds = null,}) {
  return _then(StatsRow(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntryStatus,watchCount: null == watchCount ? _self.watchCount : watchCount // ignore: cast_nullable_to_non_nullable
as int,episodesWatched: freezed == episodesWatched ? _self.episodesWatched : episodesWatched // ignore: cast_nullable_to_non_nullable
as int?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,episodeRunTime: freezed == episodeRunTime ? _self.episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as int?,numberOfEpisodes: freezed == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int?,genres: null == genres ? _self.genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,providerIds: null == providerIds ? _self.providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}

}


/// Adds pattern-matching-related methods to [StatsRow].
extension StatsRowPatterns on StatsRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatsRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatsRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatsRow value)  $default,){
final _that = this;
switch (_that) {
case _StatsRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatsRow value)?  $default,){
final _that = this;
switch (_that) {
case _StatsRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( EntryStatus status,  int watchCount,  int? episodesWatched,  MediaType mediaType,  int? runtimeMinutes,  int? episodeRunTime,  int? numberOfEpisodes,  List<String> genres,  int? year,  List<int> providerIds)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatsRow() when $default != null:
return $default(_that.status,_that.watchCount,_that.episodesWatched,_that.mediaType,_that.runtimeMinutes,_that.episodeRunTime,_that.numberOfEpisodes,_that.genres,_that.year,_that.providerIds);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( EntryStatus status,  int watchCount,  int? episodesWatched,  MediaType mediaType,  int? runtimeMinutes,  int? episodeRunTime,  int? numberOfEpisodes,  List<String> genres,  int? year,  List<int> providerIds)  $default,) {final _that = this;
switch (_that) {
case _StatsRow():
return $default(_that.status,_that.watchCount,_that.episodesWatched,_that.mediaType,_that.runtimeMinutes,_that.episodeRunTime,_that.numberOfEpisodes,_that.genres,_that.year,_that.providerIds);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( EntryStatus status,  int watchCount,  int? episodesWatched,  MediaType mediaType,  int? runtimeMinutes,  int? episodeRunTime,  int? numberOfEpisodes,  List<String> genres,  int? year,  List<int> providerIds)?  $default,) {final _that = this;
switch (_that) {
case _StatsRow() when $default != null:
return $default(_that.status,_that.watchCount,_that.episodesWatched,_that.mediaType,_that.runtimeMinutes,_that.episodeRunTime,_that.numberOfEpisodes,_that.genres,_that.year,_that.providerIds);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _StatsRow implements StatsRow {
  const _StatsRow({required this.status, this.watchCount = 1, this.episodesWatched, required this.mediaType, this.runtimeMinutes, this.episodeRunTime, this.numberOfEpisodes,  List<String> genres = const <String>[], this.year,  List<int> providerIds = const <int>[]}): _genres = genres,_providerIds = providerIds;
  factory _StatsRow.fromJson(Map<String, dynamic> json) => _$StatsRowFromJson(json);

@override final  EntryStatus status;
@override@JsonKey() final  int watchCount;
@override final  int? episodesWatched;
@override final  MediaType mediaType;
@override final  int? runtimeMinutes;
@override final  int? episodeRunTime;
@override final  int? numberOfEpisodes;
 final  List<String> _genres;
@override@JsonKey() List<String> get genres {
  if (_genres is EqualUnmodifiableListView) return _genres;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_genres);
}

@override final  int? year;
 final  List<int> _providerIds;
@override@JsonKey() List<int> get providerIds {
  if (_providerIds is EqualUnmodifiableListView) return _providerIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providerIds);
}


/// Create a copy of StatsRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatsRowCopyWith<_StatsRow> get copyWith => __$StatsRowCopyWithImpl<_StatsRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$StatsRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatsRow&&(identical(other.status, status) || other.status == status)&&(identical(other.watchCount, watchCount) || other.watchCount == watchCount)&&(identical(other.episodesWatched, episodesWatched) || other.episodesWatched == episodesWatched)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.runtimeMinutes, runtimeMinutes) || other.runtimeMinutes == runtimeMinutes)&&(identical(other.episodeRunTime, episodeRunTime) || other.episodeRunTime == episodeRunTime)&&(identical(other.numberOfEpisodes, numberOfEpisodes) || other.numberOfEpisodes == numberOfEpisodes)&&const DeepCollectionEquality().equals(other._genres, _genres)&&(identical(other.year, year) || other.year == year)&&const DeepCollectionEquality().equals(other._providerIds, _providerIds));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,watchCount,episodesWatched,mediaType,runtimeMinutes,episodeRunTime,numberOfEpisodes,const DeepCollectionEquality().hash(_genres),year,const DeepCollectionEquality().hash(_providerIds));

@override
String toString() {
  return 'StatsRow(status: $status, watchCount: $watchCount, episodesWatched: $episodesWatched, mediaType: $mediaType, runtimeMinutes: $runtimeMinutes, episodeRunTime: $episodeRunTime, numberOfEpisodes: $numberOfEpisodes, genres: $genres, year: $year, providerIds: $providerIds)';
}


}

/// @nodoc
abstract mixin class _$StatsRowCopyWith<$Res> implements $StatsRowCopyWith<$Res> {
  factory _$StatsRowCopyWith(_StatsRow value, $Res Function(_StatsRow) _then) = __$StatsRowCopyWithImpl;
@override @useResult
$Res call({
 EntryStatus status, int watchCount, int? episodesWatched, MediaType mediaType, int? runtimeMinutes, int? episodeRunTime, int? numberOfEpisodes, List<String> genres, int? year, List<int> providerIds
});




}
/// @nodoc
class __$StatsRowCopyWithImpl<$Res>
    implements _$StatsRowCopyWith<$Res> {
  __$StatsRowCopyWithImpl(this._self, this._then);

  final _StatsRow _self;
  final $Res Function(_StatsRow) _then;

/// Create a copy of StatsRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? watchCount = null,Object? episodesWatched = freezed,Object? mediaType = null,Object? runtimeMinutes = freezed,Object? episodeRunTime = freezed,Object? numberOfEpisodes = freezed,Object? genres = null,Object? year = freezed,Object? providerIds = null,}) {
  return _then(_StatsRow(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as EntryStatus,watchCount: null == watchCount ? _self.watchCount : watchCount // ignore: cast_nullable_to_non_nullable
as int,episodesWatched: freezed == episodesWatched ? _self.episodesWatched : episodesWatched // ignore: cast_nullable_to_non_nullable
as int?,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,runtimeMinutes: freezed == runtimeMinutes ? _self.runtimeMinutes : runtimeMinutes // ignore: cast_nullable_to_non_nullable
as int?,episodeRunTime: freezed == episodeRunTime ? _self.episodeRunTime : episodeRunTime // ignore: cast_nullable_to_non_nullable
as int?,numberOfEpisodes: freezed == numberOfEpisodes ? _self.numberOfEpisodes : numberOfEpisodes // ignore: cast_nullable_to_non_nullable
as int?,genres: null == genres ? _self._genres : genres // ignore: cast_nullable_to_non_nullable
as List<String>,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,providerIds: null == providerIds ? _self._providerIds : providerIds // ignore: cast_nullable_to_non_nullable
as List<int>,
  ));
}


}


/// @nodoc
mixin _$ProfileCounts {

 int get followers; int get following; int get watched; int get reviews; int get lists;
/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileCountsCopyWith<ProfileCounts> get copyWith => _$ProfileCountsCopyWithImpl<ProfileCounts>(this as ProfileCounts, _$identity);

  /// Serializes this ProfileCounts to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileCounts&&(identical(other.followers, followers) || other.followers == followers)&&(identical(other.following, following) || other.following == following)&&(identical(other.watched, watched) || other.watched == watched)&&(identical(other.reviews, reviews) || other.reviews == reviews)&&(identical(other.lists, lists) || other.lists == lists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followers,following,watched,reviews,lists);

@override
String toString() {
  return 'ProfileCounts(followers: $followers, following: $following, watched: $watched, reviews: $reviews, lists: $lists)';
}


}

/// @nodoc
abstract mixin class $ProfileCountsCopyWith<$Res>  {
  factory $ProfileCountsCopyWith(ProfileCounts value, $Res Function(ProfileCounts) _then) = _$ProfileCountsCopyWithImpl;
@useResult
$Res call({
 int followers, int following, int watched, int reviews, int lists
});




}
/// @nodoc
class _$ProfileCountsCopyWithImpl<$Res>
    implements $ProfileCountsCopyWith<$Res> {
  _$ProfileCountsCopyWithImpl(this._self, this._then);

  final ProfileCounts _self;
  final $Res Function(ProfileCounts) _then;

/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? followers = null,Object? following = null,Object? watched = null,Object? reviews = null,Object? lists = null,}) {
  return _then(ProfileCounts(
followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,following: null == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as int,watched: null == watched ? _self.watched : watched // ignore: cast_nullable_to_non_nullable
as int,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as int,lists: null == lists ? _self.lists : lists // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileCounts].
extension ProfileCountsPatterns on ProfileCounts {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileCounts value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileCounts value)  $default,){
final _that = this;
switch (_that) {
case _ProfileCounts():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileCounts value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int followers,  int following,  int watched,  int reviews,  int lists)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
return $default(_that.followers,_that.following,_that.watched,_that.reviews,_that.lists);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int followers,  int following,  int watched,  int reviews,  int lists)  $default,) {final _that = this;
switch (_that) {
case _ProfileCounts():
return $default(_that.followers,_that.following,_that.watched,_that.reviews,_that.lists);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int followers,  int following,  int watched,  int reviews,  int lists)?  $default,) {final _that = this;
switch (_that) {
case _ProfileCounts() when $default != null:
return $default(_that.followers,_that.following,_that.watched,_that.reviews,_that.lists);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProfileCounts implements ProfileCounts {
  const _ProfileCounts({this.followers = 0, this.following = 0, this.watched = 0, this.reviews = 0, this.lists = 0});
  factory _ProfileCounts.fromJson(Map<String, dynamic> json) => _$ProfileCountsFromJson(json);

@override@JsonKey() final  int followers;
@override@JsonKey() final  int following;
@override@JsonKey() final  int watched;
@override@JsonKey() final  int reviews;
@override@JsonKey() final  int lists;

/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileCountsCopyWith<_ProfileCounts> get copyWith => __$ProfileCountsCopyWithImpl<_ProfileCounts>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProfileCountsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileCounts&&(identical(other.followers, followers) || other.followers == followers)&&(identical(other.following, following) || other.following == following)&&(identical(other.watched, watched) || other.watched == watched)&&(identical(other.reviews, reviews) || other.reviews == reviews)&&(identical(other.lists, lists) || other.lists == lists));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,followers,following,watched,reviews,lists);

@override
String toString() {
  return 'ProfileCounts(followers: $followers, following: $following, watched: $watched, reviews: $reviews, lists: $lists)';
}


}

/// @nodoc
abstract mixin class _$ProfileCountsCopyWith<$Res> implements $ProfileCountsCopyWith<$Res> {
  factory _$ProfileCountsCopyWith(_ProfileCounts value, $Res Function(_ProfileCounts) _then) = __$ProfileCountsCopyWithImpl;
@override @useResult
$Res call({
 int followers, int following, int watched, int reviews, int lists
});




}
/// @nodoc
class __$ProfileCountsCopyWithImpl<$Res>
    implements _$ProfileCountsCopyWith<$Res> {
  __$ProfileCountsCopyWithImpl(this._self, this._then);

  final _ProfileCounts _self;
  final $Res Function(_ProfileCounts) _then;

/// Create a copy of ProfileCounts
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? followers = null,Object? following = null,Object? watched = null,Object? reviews = null,Object? lists = null,}) {
  return _then(_ProfileCounts(
followers: null == followers ? _self.followers : followers // ignore: cast_nullable_to_non_nullable
as int,following: null == following ? _self.following : following // ignore: cast_nullable_to_non_nullable
as int,watched: null == watched ? _self.watched : watched // ignore: cast_nullable_to_non_nullable
as int,reviews: null == reviews ? _self.reviews : reviews // ignore: cast_nullable_to_non_nullable
as int,lists: null == lists ? _self.lists : lists // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$StatBucket {

 String get label; int get count; int get minutes;
/// Create a copy of StatBucket
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StatBucketCopyWith<StatBucket> get copyWith => _$StatBucketCopyWithImpl<StatBucket>(this as StatBucket, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StatBucket&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count)&&(identical(other.minutes, minutes) || other.minutes == minutes));
}


@override
int get hashCode => Object.hash(runtimeType,label,count,minutes);

@override
String toString() {
  return 'StatBucket(label: $label, count: $count, minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class $StatBucketCopyWith<$Res>  {
  factory $StatBucketCopyWith(StatBucket value, $Res Function(StatBucket) _then) = _$StatBucketCopyWithImpl;
@useResult
$Res call({
 String label, int count, int minutes
});




}
/// @nodoc
class _$StatBucketCopyWithImpl<$Res>
    implements $StatBucketCopyWith<$Res> {
  _$StatBucketCopyWithImpl(this._self, this._then);

  final StatBucket _self;
  final $Res Function(StatBucket) _then;

/// Create a copy of StatBucket
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? label = null,Object? count = null,Object? minutes = null,}) {
  return _then(StatBucket(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [StatBucket].
extension StatBucketPatterns on StatBucket {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StatBucket value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StatBucket() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StatBucket value)  $default,){
final _that = this;
switch (_that) {
case _StatBucket():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StatBucket value)?  $default,){
final _that = this;
switch (_that) {
case _StatBucket() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String label,  int count,  int minutes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StatBucket() when $default != null:
return $default(_that.label,_that.count,_that.minutes);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String label,  int count,  int minutes)  $default,) {final _that = this;
switch (_that) {
case _StatBucket():
return $default(_that.label,_that.count,_that.minutes);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String label,  int count,  int minutes)?  $default,) {final _that = this;
switch (_that) {
case _StatBucket() when $default != null:
return $default(_that.label,_that.count,_that.minutes);case _:
  return null;

}
}

}

/// @nodoc


class _StatBucket implements StatBucket {
  const _StatBucket({required this.label, required this.count, this.minutes = 0});
  

@override final  String label;
@override final  int count;
@override@JsonKey() final  int minutes;

/// Create a copy of StatBucket
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StatBucketCopyWith<_StatBucket> get copyWith => __$StatBucketCopyWithImpl<_StatBucket>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StatBucket&&(identical(other.label, label) || other.label == label)&&(identical(other.count, count) || other.count == count)&&(identical(other.minutes, minutes) || other.minutes == minutes));
}


@override
int get hashCode => Object.hash(runtimeType,label,count,minutes);

@override
String toString() {
  return 'StatBucket(label: $label, count: $count, minutes: $minutes)';
}


}

/// @nodoc
abstract mixin class _$StatBucketCopyWith<$Res> implements $StatBucketCopyWith<$Res> {
  factory _$StatBucketCopyWith(_StatBucket value, $Res Function(_StatBucket) _then) = __$StatBucketCopyWithImpl;
@override @useResult
$Res call({
 String label, int count, int minutes
});




}
/// @nodoc
class __$StatBucketCopyWithImpl<$Res>
    implements _$StatBucketCopyWith<$Res> {
  __$StatBucketCopyWithImpl(this._self, this._then);

  final _StatBucket _self;
  final $Res Function(_StatBucket) _then;

/// Create a copy of StatBucket
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? label = null,Object? count = null,Object? minutes = null,}) {
  return _then(_StatBucket(
label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,minutes: null == minutes ? _self.minutes : minutes // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

/// @nodoc
mixin _$ProfileStats {

 int get totalMinutes; int get watchedTitles; int get watchingTitles; int get wantTitles; int get movies; int get series; int get rewatches;/// Títulos por streaming (id do provider, só assinatura em BR).
 Map<int, StatBucket> get byProvider; List<StatBucket> get byGenre;/// Por década de lançamento ("2020", "2010", …), mais recente primeiro.
 List<StatBucket> get byDecade;/// Entradas sem duração conhecida (não entram nas horas).
 int get withoutRuntime;
/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProfileStatsCopyWith<ProfileStats> get copyWith => _$ProfileStatsCopyWithImpl<ProfileStats>(this as ProfileStats, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProfileStats&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&(identical(other.watchedTitles, watchedTitles) || other.watchedTitles == watchedTitles)&&(identical(other.watchingTitles, watchingTitles) || other.watchingTitles == watchingTitles)&&(identical(other.wantTitles, wantTitles) || other.wantTitles == wantTitles)&&(identical(other.movies, movies) || other.movies == movies)&&(identical(other.series, series) || other.series == series)&&(identical(other.rewatches, rewatches) || other.rewatches == rewatches)&&const DeepCollectionEquality().equals(other.byProvider, byProvider)&&const DeepCollectionEquality().equals(other.byGenre, byGenre)&&const DeepCollectionEquality().equals(other.byDecade, byDecade)&&(identical(other.withoutRuntime, withoutRuntime) || other.withoutRuntime == withoutRuntime));
}


@override
int get hashCode => Object.hash(runtimeType,totalMinutes,watchedTitles,watchingTitles,wantTitles,movies,series,rewatches,const DeepCollectionEquality().hash(byProvider),const DeepCollectionEquality().hash(byGenre),const DeepCollectionEquality().hash(byDecade),withoutRuntime);

@override
String toString() {
  return 'ProfileStats(totalMinutes: $totalMinutes, watchedTitles: $watchedTitles, watchingTitles: $watchingTitles, wantTitles: $wantTitles, movies: $movies, series: $series, rewatches: $rewatches, byProvider: $byProvider, byGenre: $byGenre, byDecade: $byDecade, withoutRuntime: $withoutRuntime)';
}


}

/// @nodoc
abstract mixin class $ProfileStatsCopyWith<$Res>  {
  factory $ProfileStatsCopyWith(ProfileStats value, $Res Function(ProfileStats) _then) = _$ProfileStatsCopyWithImpl;
@useResult
$Res call({
 int totalMinutes, int watchedTitles, int watchingTitles, int wantTitles, int movies, int series, int rewatches, Map<int, StatBucket> byProvider, List<StatBucket> byGenre, List<StatBucket> byDecade, int withoutRuntime
});




}
/// @nodoc
class _$ProfileStatsCopyWithImpl<$Res>
    implements $ProfileStatsCopyWith<$Res> {
  _$ProfileStatsCopyWithImpl(this._self, this._then);

  final ProfileStats _self;
  final $Res Function(ProfileStats) _then;

/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalMinutes = null,Object? watchedTitles = null,Object? watchingTitles = null,Object? wantTitles = null,Object? movies = null,Object? series = null,Object? rewatches = null,Object? byProvider = null,Object? byGenre = null,Object? byDecade = null,Object? withoutRuntime = null,}) {
  return _then(ProfileStats(
totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,watchedTitles: null == watchedTitles ? _self.watchedTitles : watchedTitles // ignore: cast_nullable_to_non_nullable
as int,watchingTitles: null == watchingTitles ? _self.watchingTitles : watchingTitles // ignore: cast_nullable_to_non_nullable
as int,wantTitles: null == wantTitles ? _self.wantTitles : wantTitles // ignore: cast_nullable_to_non_nullable
as int,movies: null == movies ? _self.movies : movies // ignore: cast_nullable_to_non_nullable
as int,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as int,rewatches: null == rewatches ? _self.rewatches : rewatches // ignore: cast_nullable_to_non_nullable
as int,byProvider: null == byProvider ? _self.byProvider : byProvider // ignore: cast_nullable_to_non_nullable
as Map<int, StatBucket>,byGenre: null == byGenre ? _self.byGenre : byGenre // ignore: cast_nullable_to_non_nullable
as List<StatBucket>,byDecade: null == byDecade ? _self.byDecade : byDecade // ignore: cast_nullable_to_non_nullable
as List<StatBucket>,withoutRuntime: null == withoutRuntime ? _self.withoutRuntime : withoutRuntime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ProfileStats].
extension ProfileStatsPatterns on ProfileStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProfileStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProfileStats value)  $default,){
final _that = this;
switch (_that) {
case _ProfileStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProfileStats value)?  $default,){
final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalMinutes,  int watchedTitles,  int watchingTitles,  int wantTitles,  int movies,  int series,  int rewatches,  Map<int, StatBucket> byProvider,  List<StatBucket> byGenre,  List<StatBucket> byDecade,  int withoutRuntime)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
return $default(_that.totalMinutes,_that.watchedTitles,_that.watchingTitles,_that.wantTitles,_that.movies,_that.series,_that.rewatches,_that.byProvider,_that.byGenre,_that.byDecade,_that.withoutRuntime);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalMinutes,  int watchedTitles,  int watchingTitles,  int wantTitles,  int movies,  int series,  int rewatches,  Map<int, StatBucket> byProvider,  List<StatBucket> byGenre,  List<StatBucket> byDecade,  int withoutRuntime)  $default,) {final _that = this;
switch (_that) {
case _ProfileStats():
return $default(_that.totalMinutes,_that.watchedTitles,_that.watchingTitles,_that.wantTitles,_that.movies,_that.series,_that.rewatches,_that.byProvider,_that.byGenre,_that.byDecade,_that.withoutRuntime);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalMinutes,  int watchedTitles,  int watchingTitles,  int wantTitles,  int movies,  int series,  int rewatches,  Map<int, StatBucket> byProvider,  List<StatBucket> byGenre,  List<StatBucket> byDecade,  int withoutRuntime)?  $default,) {final _that = this;
switch (_that) {
case _ProfileStats() when $default != null:
return $default(_that.totalMinutes,_that.watchedTitles,_that.watchingTitles,_that.wantTitles,_that.movies,_that.series,_that.rewatches,_that.byProvider,_that.byGenre,_that.byDecade,_that.withoutRuntime);case _:
  return null;

}
}

}

/// @nodoc


class _ProfileStats extends ProfileStats {
  const _ProfileStats({this.totalMinutes = 0, this.watchedTitles = 0, this.watchingTitles = 0, this.wantTitles = 0, this.movies = 0, this.series = 0, this.rewatches = 0,  Map<int, StatBucket> byProvider = const <int, StatBucket>{},  List<StatBucket> byGenre = const <StatBucket>[],  List<StatBucket> byDecade = const <StatBucket>[], this.withoutRuntime = 0}): _byProvider = byProvider,_byGenre = byGenre,_byDecade = byDecade,super._();
  

@override@JsonKey() final  int totalMinutes;
@override@JsonKey() final  int watchedTitles;
@override@JsonKey() final  int watchingTitles;
@override@JsonKey() final  int wantTitles;
@override@JsonKey() final  int movies;
@override@JsonKey() final  int series;
@override@JsonKey() final  int rewatches;
/// Títulos por streaming (id do provider, só assinatura em BR).
 final  Map<int, StatBucket> _byProvider;
/// Títulos por streaming (id do provider, só assinatura em BR).
@override@JsonKey() Map<int, StatBucket> get byProvider {
  if (_byProvider is EqualUnmodifiableMapView) return _byProvider;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_byProvider);
}

 final  List<StatBucket> _byGenre;
@override@JsonKey() List<StatBucket> get byGenre {
  if (_byGenre is EqualUnmodifiableListView) return _byGenre;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byGenre);
}

/// Por década de lançamento ("2020", "2010", …), mais recente primeiro.
 final  List<StatBucket> _byDecade;
/// Por década de lançamento ("2020", "2010", …), mais recente primeiro.
@override@JsonKey() List<StatBucket> get byDecade {
  if (_byDecade is EqualUnmodifiableListView) return _byDecade;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_byDecade);
}

/// Entradas sem duração conhecida (não entram nas horas).
@override@JsonKey() final  int withoutRuntime;

/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProfileStatsCopyWith<_ProfileStats> get copyWith => __$ProfileStatsCopyWithImpl<_ProfileStats>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProfileStats&&(identical(other.totalMinutes, totalMinutes) || other.totalMinutes == totalMinutes)&&(identical(other.watchedTitles, watchedTitles) || other.watchedTitles == watchedTitles)&&(identical(other.watchingTitles, watchingTitles) || other.watchingTitles == watchingTitles)&&(identical(other.wantTitles, wantTitles) || other.wantTitles == wantTitles)&&(identical(other.movies, movies) || other.movies == movies)&&(identical(other.series, series) || other.series == series)&&(identical(other.rewatches, rewatches) || other.rewatches == rewatches)&&const DeepCollectionEquality().equals(other._byProvider, _byProvider)&&const DeepCollectionEquality().equals(other._byGenre, _byGenre)&&const DeepCollectionEquality().equals(other._byDecade, _byDecade)&&(identical(other.withoutRuntime, withoutRuntime) || other.withoutRuntime == withoutRuntime));
}


@override
int get hashCode => Object.hash(runtimeType,totalMinutes,watchedTitles,watchingTitles,wantTitles,movies,series,rewatches,const DeepCollectionEquality().hash(_byProvider),const DeepCollectionEquality().hash(_byGenre),const DeepCollectionEquality().hash(_byDecade),withoutRuntime);

@override
String toString() {
  return 'ProfileStats(totalMinutes: $totalMinutes, watchedTitles: $watchedTitles, watchingTitles: $watchingTitles, wantTitles: $wantTitles, movies: $movies, series: $series, rewatches: $rewatches, byProvider: $byProvider, byGenre: $byGenre, byDecade: $byDecade, withoutRuntime: $withoutRuntime)';
}


}

/// @nodoc
abstract mixin class _$ProfileStatsCopyWith<$Res> implements $ProfileStatsCopyWith<$Res> {
  factory _$ProfileStatsCopyWith(_ProfileStats value, $Res Function(_ProfileStats) _then) = __$ProfileStatsCopyWithImpl;
@override @useResult
$Res call({
 int totalMinutes, int watchedTitles, int watchingTitles, int wantTitles, int movies, int series, int rewatches, Map<int, StatBucket> byProvider, List<StatBucket> byGenre, List<StatBucket> byDecade, int withoutRuntime
});




}
/// @nodoc
class __$ProfileStatsCopyWithImpl<$Res>
    implements _$ProfileStatsCopyWith<$Res> {
  __$ProfileStatsCopyWithImpl(this._self, this._then);

  final _ProfileStats _self;
  final $Res Function(_ProfileStats) _then;

/// Create a copy of ProfileStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalMinutes = null,Object? watchedTitles = null,Object? watchingTitles = null,Object? wantTitles = null,Object? movies = null,Object? series = null,Object? rewatches = null,Object? byProvider = null,Object? byGenre = null,Object? byDecade = null,Object? withoutRuntime = null,}) {
  return _then(_ProfileStats(
totalMinutes: null == totalMinutes ? _self.totalMinutes : totalMinutes // ignore: cast_nullable_to_non_nullable
as int,watchedTitles: null == watchedTitles ? _self.watchedTitles : watchedTitles // ignore: cast_nullable_to_non_nullable
as int,watchingTitles: null == watchingTitles ? _self.watchingTitles : watchingTitles // ignore: cast_nullable_to_non_nullable
as int,wantTitles: null == wantTitles ? _self.wantTitles : wantTitles // ignore: cast_nullable_to_non_nullable
as int,movies: null == movies ? _self.movies : movies // ignore: cast_nullable_to_non_nullable
as int,series: null == series ? _self.series : series // ignore: cast_nullable_to_non_nullable
as int,rewatches: null == rewatches ? _self.rewatches : rewatches // ignore: cast_nullable_to_non_nullable
as int,byProvider: null == byProvider ? _self._byProvider : byProvider // ignore: cast_nullable_to_non_nullable
as Map<int, StatBucket>,byGenre: null == byGenre ? _self._byGenre : byGenre // ignore: cast_nullable_to_non_nullable
as List<StatBucket>,byDecade: null == byDecade ? _self._byDecade : byDecade // ignore: cast_nullable_to_non_nullable
as List<StatBucket>,withoutRuntime: null == withoutRuntime ? _self.withoutRuntime : withoutRuntime // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on
