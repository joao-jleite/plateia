// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'import_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ImportCandidate {

 String get titleId; int get tmdbId; MediaType get mediaType; String get title; int? get year; String? get posterPath; double get score;
/// Create a copy of ImportCandidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportCandidateCopyWith<ImportCandidate> get copyWith => _$ImportCandidateCopyWithImpl<ImportCandidate>(this as ImportCandidate, _$identity);

  /// Serializes this ImportCandidate to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportCandidate&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleId,tmdbId,mediaType,title,year,posterPath,score);

@override
String toString() {
  return 'ImportCandidate(titleId: $titleId, tmdbId: $tmdbId, mediaType: $mediaType, title: $title, year: $year, posterPath: $posterPath, score: $score)';
}


}

/// @nodoc
abstract mixin class $ImportCandidateCopyWith<$Res>  {
  factory $ImportCandidateCopyWith(ImportCandidate value, $Res Function(ImportCandidate) _then) = _$ImportCandidateCopyWithImpl;
@useResult
$Res call({
 String titleId, int tmdbId, MediaType mediaType, String title, int? year, String? posterPath, double score
});




}
/// @nodoc
class _$ImportCandidateCopyWithImpl<$Res>
    implements $ImportCandidateCopyWith<$Res> {
  _$ImportCandidateCopyWithImpl(this._self, this._then);

  final ImportCandidate _self;
  final $Res Function(ImportCandidate) _then;

/// Create a copy of ImportCandidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleId = null,Object? tmdbId = null,Object? mediaType = null,Object? title = null,Object? year = freezed,Object? posterPath = freezed,Object? score = null,}) {
  return _then(ImportCandidate(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportCandidate].
extension ImportCandidatePatterns on ImportCandidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportCandidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportCandidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportCandidate value)  $default,){
final _that = this;
switch (_that) {
case _ImportCandidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportCandidate value)?  $default,){
final _that = this;
switch (_that) {
case _ImportCandidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleId,  int tmdbId,  MediaType mediaType,  String title,  int? year,  String? posterPath,  double score)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportCandidate() when $default != null:
return $default(_that.titleId,_that.tmdbId,_that.mediaType,_that.title,_that.year,_that.posterPath,_that.score);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleId,  int tmdbId,  MediaType mediaType,  String title,  int? year,  String? posterPath,  double score)  $default,) {final _that = this;
switch (_that) {
case _ImportCandidate():
return $default(_that.titleId,_that.tmdbId,_that.mediaType,_that.title,_that.year,_that.posterPath,_that.score);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleId,  int tmdbId,  MediaType mediaType,  String title,  int? year,  String? posterPath,  double score)?  $default,) {final _that = this;
switch (_that) {
case _ImportCandidate() when $default != null:
return $default(_that.titleId,_that.tmdbId,_that.mediaType,_that.title,_that.year,_that.posterPath,_that.score);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportCandidate implements ImportCandidate {
  const _ImportCandidate({required this.titleId, required this.tmdbId, required this.mediaType, required this.title, this.year, this.posterPath, this.score = 0});
  factory _ImportCandidate.fromJson(Map<String, dynamic> json) => _$ImportCandidateFromJson(json);

@override final  String titleId;
@override final  int tmdbId;
@override final  MediaType mediaType;
@override final  String title;
@override final  int? year;
@override final  String? posterPath;
@override@JsonKey() final  double score;

/// Create a copy of ImportCandidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportCandidateCopyWith<_ImportCandidate> get copyWith => __$ImportCandidateCopyWithImpl<_ImportCandidate>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportCandidateToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportCandidate&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.title, title) || other.title == title)&&(identical(other.year, year) || other.year == year)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.score, score) || other.score == score));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,titleId,tmdbId,mediaType,title,year,posterPath,score);

@override
String toString() {
  return 'ImportCandidate(titleId: $titleId, tmdbId: $tmdbId, mediaType: $mediaType, title: $title, year: $year, posterPath: $posterPath, score: $score)';
}


}

/// @nodoc
abstract mixin class _$ImportCandidateCopyWith<$Res> implements $ImportCandidateCopyWith<$Res> {
  factory _$ImportCandidateCopyWith(_ImportCandidate value, $Res Function(_ImportCandidate) _then) = __$ImportCandidateCopyWithImpl;
@override @useResult
$Res call({
 String titleId, int tmdbId, MediaType mediaType, String title, int? year, String? posterPath, double score
});




}
/// @nodoc
class __$ImportCandidateCopyWithImpl<$Res>
    implements _$ImportCandidateCopyWith<$Res> {
  __$ImportCandidateCopyWithImpl(this._self, this._then);

  final _ImportCandidate _self;
  final $Res Function(_ImportCandidate) _then;

/// Create a copy of ImportCandidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleId = null,Object? tmdbId = null,Object? mediaType = null,Object? title = null,Object? year = freezed,Object? posterPath = freezed,Object? score = null,}) {
  return _then(_ImportCandidate(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,tmdbId: null == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int,mediaType: null == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,year: freezed == year ? _self.year : year // ignore: cast_nullable_to_non_nullable
as int?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,
  ));
}


}


/// @nodoc
mixin _$ImportMatch {

 String get rawName; MatchConfidence get confidence; ImportCandidate? get best; List<ImportCandidate> get candidates;
/// Create a copy of ImportMatch
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportMatchCopyWith<ImportMatch> get copyWith => _$ImportMatchCopyWithImpl<ImportMatch>(this as ImportMatch, _$identity);

  /// Serializes this ImportMatch to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportMatch&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.best, best) || other.best == best)&&const DeepCollectionEquality().equals(other.candidates, candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawName,confidence,best,const DeepCollectionEquality().hash(candidates));

@override
String toString() {
  return 'ImportMatch(rawName: $rawName, confidence: $confidence, best: $best, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class $ImportMatchCopyWith<$Res>  {
  factory $ImportMatchCopyWith(ImportMatch value, $Res Function(ImportMatch) _then) = _$ImportMatchCopyWithImpl;
@useResult
$Res call({
 String rawName, MatchConfidence confidence, ImportCandidate? best, List<ImportCandidate> candidates
});


$ImportCandidateCopyWith<$Res>? get best;

}
/// @nodoc
class _$ImportMatchCopyWithImpl<$Res>
    implements $ImportMatchCopyWith<$Res> {
  _$ImportMatchCopyWithImpl(this._self, this._then);

  final ImportMatch _self;
  final $Res Function(ImportMatch) _then;

/// Create a copy of ImportMatch
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? rawName = null,Object? confidence = null,Object? best = freezed,Object? candidates = null,}) {
  return _then(ImportMatch(
rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as MatchConfidence,best: freezed == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as ImportCandidate?,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<ImportCandidate>,
  ));
}
/// Create a copy of ImportMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportCandidateCopyWith<$Res>? get best {
    if (_self.best == null) {
    return null;
  }

  return $ImportCandidateCopyWith<$Res>(_self.best!, (value) {
    return _then(_self.copyWith(best: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImportMatch].
extension ImportMatchPatterns on ImportMatch {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportMatch value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportMatch() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportMatch value)  $default,){
final _that = this;
switch (_that) {
case _ImportMatch():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportMatch value)?  $default,){
final _that = this;
switch (_that) {
case _ImportMatch() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String rawName,  MatchConfidence confidence,  ImportCandidate? best,  List<ImportCandidate> candidates)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportMatch() when $default != null:
return $default(_that.rawName,_that.confidence,_that.best,_that.candidates);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String rawName,  MatchConfidence confidence,  ImportCandidate? best,  List<ImportCandidate> candidates)  $default,) {final _that = this;
switch (_that) {
case _ImportMatch():
return $default(_that.rawName,_that.confidence,_that.best,_that.candidates);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String rawName,  MatchConfidence confidence,  ImportCandidate? best,  List<ImportCandidate> candidates)?  $default,) {final _that = this;
switch (_that) {
case _ImportMatch() when $default != null:
return $default(_that.rawName,_that.confidence,_that.best,_that.candidates);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportMatch implements ImportMatch {
  const _ImportMatch({required this.rawName, required this.confidence, this.best,  List<ImportCandidate> candidates = const <ImportCandidate>[]}): _candidates = candidates;
  factory _ImportMatch.fromJson(Map<String, dynamic> json) => _$ImportMatchFromJson(json);

@override final  String rawName;
@override final  MatchConfidence confidence;
@override final  ImportCandidate? best;
 final  List<ImportCandidate> _candidates;
@override@JsonKey() List<ImportCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}


/// Create a copy of ImportMatch
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportMatchCopyWith<_ImportMatch> get copyWith => __$ImportMatchCopyWithImpl<_ImportMatch>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportMatchToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportMatch&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.confidence, confidence) || other.confidence == confidence)&&(identical(other.best, best) || other.best == best)&&const DeepCollectionEquality().equals(other._candidates, _candidates));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,rawName,confidence,best,const DeepCollectionEquality().hash(_candidates));

@override
String toString() {
  return 'ImportMatch(rawName: $rawName, confidence: $confidence, best: $best, candidates: $candidates)';
}


}

/// @nodoc
abstract mixin class _$ImportMatchCopyWith<$Res> implements $ImportMatchCopyWith<$Res> {
  factory _$ImportMatchCopyWith(_ImportMatch value, $Res Function(_ImportMatch) _then) = __$ImportMatchCopyWithImpl;
@override @useResult
$Res call({
 String rawName, MatchConfidence confidence, ImportCandidate? best, List<ImportCandidate> candidates
});


@override $ImportCandidateCopyWith<$Res>? get best;

}
/// @nodoc
class __$ImportMatchCopyWithImpl<$Res>
    implements _$ImportMatchCopyWith<$Res> {
  __$ImportMatchCopyWithImpl(this._self, this._then);

  final _ImportMatch _self;
  final $Res Function(_ImportMatch) _then;

/// Create a copy of ImportMatch
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? rawName = null,Object? confidence = null,Object? best = freezed,Object? candidates = null,}) {
  return _then(_ImportMatch(
rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,confidence: null == confidence ? _self.confidence : confidence // ignore: cast_nullable_to_non_nullable
as MatchConfidence,best: freezed == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as ImportCandidate?,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<ImportCandidate>,
  ));
}

/// Create a copy of ImportMatch
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ImportCandidateCopyWith<$Res>? get best {
    if (_self.best == null) {
    return null;
  }

  return $ImportCandidateCopyWith<$Res>(_self.best!, (value) {
    return _then(_self.copyWith(best: value));
  });
}
}


/// @nodoc
mixin _$ImportMatchResponse {

 List<ImportMatch> get matches; int get upstreamCalls;
/// Create a copy of ImportMatchResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportMatchResponseCopyWith<ImportMatchResponse> get copyWith => _$ImportMatchResponseCopyWithImpl<ImportMatchResponse>(this as ImportMatchResponse, _$identity);

  /// Serializes this ImportMatchResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportMatchResponse&&const DeepCollectionEquality().equals(other.matches, matches)&&(identical(other.upstreamCalls, upstreamCalls) || other.upstreamCalls == upstreamCalls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(matches),upstreamCalls);

@override
String toString() {
  return 'ImportMatchResponse(matches: $matches, upstreamCalls: $upstreamCalls)';
}


}

/// @nodoc
abstract mixin class $ImportMatchResponseCopyWith<$Res>  {
  factory $ImportMatchResponseCopyWith(ImportMatchResponse value, $Res Function(ImportMatchResponse) _then) = _$ImportMatchResponseCopyWithImpl;
@useResult
$Res call({
 List<ImportMatch> matches, int upstreamCalls
});




}
/// @nodoc
class _$ImportMatchResponseCopyWithImpl<$Res>
    implements $ImportMatchResponseCopyWith<$Res> {
  _$ImportMatchResponseCopyWithImpl(this._self, this._then);

  final ImportMatchResponse _self;
  final $Res Function(ImportMatchResponse) _then;

/// Create a copy of ImportMatchResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? matches = null,Object? upstreamCalls = null,}) {
  return _then(ImportMatchResponse(
matches: null == matches ? _self.matches : matches // ignore: cast_nullable_to_non_nullable
as List<ImportMatch>,upstreamCalls: null == upstreamCalls ? _self.upstreamCalls : upstreamCalls // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportMatchResponse].
extension ImportMatchResponsePatterns on ImportMatchResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportMatchResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportMatchResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportMatchResponse value)  $default,){
final _that = this;
switch (_that) {
case _ImportMatchResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportMatchResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ImportMatchResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ImportMatch> matches,  int upstreamCalls)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportMatchResponse() when $default != null:
return $default(_that.matches,_that.upstreamCalls);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ImportMatch> matches,  int upstreamCalls)  $default,) {final _that = this;
switch (_that) {
case _ImportMatchResponse():
return $default(_that.matches,_that.upstreamCalls);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ImportMatch> matches,  int upstreamCalls)?  $default,) {final _that = this;
switch (_that) {
case _ImportMatchResponse() when $default != null:
return $default(_that.matches,_that.upstreamCalls);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportMatchResponse implements ImportMatchResponse {
  const _ImportMatchResponse({required  List<ImportMatch> matches, this.upstreamCalls = 0}): _matches = matches;
  factory _ImportMatchResponse.fromJson(Map<String, dynamic> json) => _$ImportMatchResponseFromJson(json);

 final  List<ImportMatch> _matches;
@override List<ImportMatch> get matches {
  if (_matches is EqualUnmodifiableListView) return _matches;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_matches);
}

@override@JsonKey() final  int upstreamCalls;

/// Create a copy of ImportMatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportMatchResponseCopyWith<_ImportMatchResponse> get copyWith => __$ImportMatchResponseCopyWithImpl<_ImportMatchResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportMatchResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportMatchResponse&&const DeepCollectionEquality().equals(other._matches, _matches)&&(identical(other.upstreamCalls, upstreamCalls) || other.upstreamCalls == upstreamCalls));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_matches),upstreamCalls);

@override
String toString() {
  return 'ImportMatchResponse(matches: $matches, upstreamCalls: $upstreamCalls)';
}


}

/// @nodoc
abstract mixin class _$ImportMatchResponseCopyWith<$Res> implements $ImportMatchResponseCopyWith<$Res> {
  factory _$ImportMatchResponseCopyWith(_ImportMatchResponse value, $Res Function(_ImportMatchResponse) _then) = __$ImportMatchResponseCopyWithImpl;
@override @useResult
$Res call({
 List<ImportMatch> matches, int upstreamCalls
});




}
/// @nodoc
class __$ImportMatchResponseCopyWithImpl<$Res>
    implements _$ImportMatchResponseCopyWith<$Res> {
  __$ImportMatchResponseCopyWithImpl(this._self, this._then);

  final _ImportMatchResponse _self;
  final $Res Function(_ImportMatchResponse) _then;

/// Create a copy of ImportMatchResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? matches = null,Object? upstreamCalls = null,}) {
  return _then(_ImportMatchResponse(
matches: null == matches ? _self._matches : matches // ignore: cast_nullable_to_non_nullable
as List<ImportMatch>,upstreamCalls: null == upstreamCalls ? _self.upstreamCalls : upstreamCalls // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ImportRecord {

 String get id; String get userId; String get source; String? get fileHash; int get rowsTotal; int get titlesTotal; int get titlesMatched; int get titlesReview; int get titlesNew; String get status; DateTime? get createdAt; DateTime? get finishedAt;
/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportRecordCopyWith<ImportRecord> get copyWith => _$ImportRecordCopyWithImpl<ImportRecord>(this as ImportRecord, _$identity);

  /// Serializes this ImportRecord to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.source, source) || other.source == source)&&(identical(other.fileHash, fileHash) || other.fileHash == fileHash)&&(identical(other.rowsTotal, rowsTotal) || other.rowsTotal == rowsTotal)&&(identical(other.titlesTotal, titlesTotal) || other.titlesTotal == titlesTotal)&&(identical(other.titlesMatched, titlesMatched) || other.titlesMatched == titlesMatched)&&(identical(other.titlesReview, titlesReview) || other.titlesReview == titlesReview)&&(identical(other.titlesNew, titlesNew) || other.titlesNew == titlesNew)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,source,fileHash,rowsTotal,titlesTotal,titlesMatched,titlesReview,titlesNew,status,createdAt,finishedAt);

@override
String toString() {
  return 'ImportRecord(id: $id, userId: $userId, source: $source, fileHash: $fileHash, rowsTotal: $rowsTotal, titlesTotal: $titlesTotal, titlesMatched: $titlesMatched, titlesReview: $titlesReview, titlesNew: $titlesNew, status: $status, createdAt: $createdAt, finishedAt: $finishedAt)';
}


}

/// @nodoc
abstract mixin class $ImportRecordCopyWith<$Res>  {
  factory $ImportRecordCopyWith(ImportRecord value, $Res Function(ImportRecord) _then) = _$ImportRecordCopyWithImpl;
@useResult
$Res call({
 String id, String userId, String source, String? fileHash, int rowsTotal, int titlesTotal, int titlesMatched, int titlesReview, int titlesNew, String status, DateTime? createdAt, DateTime? finishedAt
});




}
/// @nodoc
class _$ImportRecordCopyWithImpl<$Res>
    implements $ImportRecordCopyWith<$Res> {
  _$ImportRecordCopyWithImpl(this._self, this._then);

  final ImportRecord _self;
  final $Res Function(ImportRecord) _then;

/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? source = null,Object? fileHash = freezed,Object? rowsTotal = null,Object? titlesTotal = null,Object? titlesMatched = null,Object? titlesReview = null,Object? titlesNew = null,Object? status = null,Object? createdAt = freezed,Object? finishedAt = freezed,}) {
  return _then(ImportRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,fileHash: freezed == fileHash ? _self.fileHash : fileHash // ignore: cast_nullable_to_non_nullable
as String?,rowsTotal: null == rowsTotal ? _self.rowsTotal : rowsTotal // ignore: cast_nullable_to_non_nullable
as int,titlesTotal: null == titlesTotal ? _self.titlesTotal : titlesTotal // ignore: cast_nullable_to_non_nullable
as int,titlesMatched: null == titlesMatched ? _self.titlesMatched : titlesMatched // ignore: cast_nullable_to_non_nullable
as int,titlesReview: null == titlesReview ? _self.titlesReview : titlesReview // ignore: cast_nullable_to_non_nullable
as int,titlesNew: null == titlesNew ? _self.titlesNew : titlesNew // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportRecord].
extension ImportRecordPatterns on ImportRecord {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportRecord value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportRecord value)  $default,){
final _that = this;
switch (_that) {
case _ImportRecord():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportRecord value)?  $default,){
final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String userId,  String source,  String? fileHash,  int rowsTotal,  int titlesTotal,  int titlesMatched,  int titlesReview,  int titlesNew,  String status,  DateTime? createdAt,  DateTime? finishedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
return $default(_that.id,_that.userId,_that.source,_that.fileHash,_that.rowsTotal,_that.titlesTotal,_that.titlesMatched,_that.titlesReview,_that.titlesNew,_that.status,_that.createdAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String userId,  String source,  String? fileHash,  int rowsTotal,  int titlesTotal,  int titlesMatched,  int titlesReview,  int titlesNew,  String status,  DateTime? createdAt,  DateTime? finishedAt)  $default,) {final _that = this;
switch (_that) {
case _ImportRecord():
return $default(_that.id,_that.userId,_that.source,_that.fileHash,_that.rowsTotal,_that.titlesTotal,_that.titlesMatched,_that.titlesReview,_that.titlesNew,_that.status,_that.createdAt,_that.finishedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String userId,  String source,  String? fileHash,  int rowsTotal,  int titlesTotal,  int titlesMatched,  int titlesReview,  int titlesNew,  String status,  DateTime? createdAt,  DateTime? finishedAt)?  $default,) {final _that = this;
switch (_that) {
case _ImportRecord() when $default != null:
return $default(_that.id,_that.userId,_that.source,_that.fileHash,_that.rowsTotal,_that.titlesTotal,_that.titlesMatched,_that.titlesReview,_that.titlesNew,_that.status,_that.createdAt,_that.finishedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportRecord implements ImportRecord {
  const _ImportRecord({required this.id, required this.userId, this.source = 'netflix', this.fileHash, this.rowsTotal = 0, this.titlesTotal = 0, this.titlesMatched = 0, this.titlesReview = 0, this.titlesNew = 0, this.status = 'running', this.createdAt, this.finishedAt});
  factory _ImportRecord.fromJson(Map<String, dynamic> json) => _$ImportRecordFromJson(json);

@override final  String id;
@override final  String userId;
@override@JsonKey() final  String source;
@override final  String? fileHash;
@override@JsonKey() final  int rowsTotal;
@override@JsonKey() final  int titlesTotal;
@override@JsonKey() final  int titlesMatched;
@override@JsonKey() final  int titlesReview;
@override@JsonKey() final  int titlesNew;
@override@JsonKey() final  String status;
@override final  DateTime? createdAt;
@override final  DateTime? finishedAt;

/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportRecordCopyWith<_ImportRecord> get copyWith => __$ImportRecordCopyWithImpl<_ImportRecord>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportRecordToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportRecord&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.source, source) || other.source == source)&&(identical(other.fileHash, fileHash) || other.fileHash == fileHash)&&(identical(other.rowsTotal, rowsTotal) || other.rowsTotal == rowsTotal)&&(identical(other.titlesTotal, titlesTotal) || other.titlesTotal == titlesTotal)&&(identical(other.titlesMatched, titlesMatched) || other.titlesMatched == titlesMatched)&&(identical(other.titlesReview, titlesReview) || other.titlesReview == titlesReview)&&(identical(other.titlesNew, titlesNew) || other.titlesNew == titlesNew)&&(identical(other.status, status) || other.status == status)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.finishedAt, finishedAt) || other.finishedAt == finishedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,userId,source,fileHash,rowsTotal,titlesTotal,titlesMatched,titlesReview,titlesNew,status,createdAt,finishedAt);

@override
String toString() {
  return 'ImportRecord(id: $id, userId: $userId, source: $source, fileHash: $fileHash, rowsTotal: $rowsTotal, titlesTotal: $titlesTotal, titlesMatched: $titlesMatched, titlesReview: $titlesReview, titlesNew: $titlesNew, status: $status, createdAt: $createdAt, finishedAt: $finishedAt)';
}


}

/// @nodoc
abstract mixin class _$ImportRecordCopyWith<$Res> implements $ImportRecordCopyWith<$Res> {
  factory _$ImportRecordCopyWith(_ImportRecord value, $Res Function(_ImportRecord) _then) = __$ImportRecordCopyWithImpl;
@override @useResult
$Res call({
 String id, String userId, String source, String? fileHash, int rowsTotal, int titlesTotal, int titlesMatched, int titlesReview, int titlesNew, String status, DateTime? createdAt, DateTime? finishedAt
});




}
/// @nodoc
class __$ImportRecordCopyWithImpl<$Res>
    implements _$ImportRecordCopyWith<$Res> {
  __$ImportRecordCopyWithImpl(this._self, this._then);

  final _ImportRecord _self;
  final $Res Function(_ImportRecord) _then;

/// Create a copy of ImportRecord
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? source = null,Object? fileHash = freezed,Object? rowsTotal = null,Object? titlesTotal = null,Object? titlesMatched = null,Object? titlesReview = null,Object? titlesNew = null,Object? status = null,Object? createdAt = freezed,Object? finishedAt = freezed,}) {
  return _then(_ImportRecord(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as String,fileHash: freezed == fileHash ? _self.fileHash : fileHash // ignore: cast_nullable_to_non_nullable
as String?,rowsTotal: null == rowsTotal ? _self.rowsTotal : rowsTotal // ignore: cast_nullable_to_non_nullable
as int,titlesTotal: null == titlesTotal ? _self.titlesTotal : titlesTotal // ignore: cast_nullable_to_non_nullable
as int,titlesMatched: null == titlesMatched ? _self.titlesMatched : titlesMatched // ignore: cast_nullable_to_non_nullable
as int,titlesReview: null == titlesReview ? _self.titlesReview : titlesReview // ignore: cast_nullable_to_non_nullable
as int,titlesNew: null == titlesNew ? _self.titlesNew : titlesNew // ignore: cast_nullable_to_non_nullable
as int,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,finishedAt: freezed == finishedAt ? _self.finishedAt : finishedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}


/// @nodoc
mixin _$ImportCandidateRow {

 String get id; String get importId; String get userId; String get rawName; MediaType? get guessedType; int get episodesCount; DateTime? get lastWatchedAt; List<ImportCandidate> get candidates; String? get resolvedTitleId; DateTime? get resolvedAt; bool get skipped; DateTime? get createdAt;
/// Create a copy of ImportCandidateRow
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImportCandidateRowCopyWith<ImportCandidateRow> get copyWith => _$ImportCandidateRowCopyWithImpl<ImportCandidateRow>(this as ImportCandidateRow, _$identity);

  /// Serializes this ImportCandidateRow to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImportCandidateRow&&(identical(other.id, id) || other.id == id)&&(identical(other.importId, importId) || other.importId == importId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.guessedType, guessedType) || other.guessedType == guessedType)&&(identical(other.episodesCount, episodesCount) || other.episodesCount == episodesCount)&&(identical(other.lastWatchedAt, lastWatchedAt) || other.lastWatchedAt == lastWatchedAt)&&const DeepCollectionEquality().equals(other.candidates, candidates)&&(identical(other.resolvedTitleId, resolvedTitleId) || other.resolvedTitleId == resolvedTitleId)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,importId,userId,rawName,guessedType,episodesCount,lastWatchedAt,const DeepCollectionEquality().hash(candidates),resolvedTitleId,resolvedAt,skipped,createdAt);

@override
String toString() {
  return 'ImportCandidateRow(id: $id, importId: $importId, userId: $userId, rawName: $rawName, guessedType: $guessedType, episodesCount: $episodesCount, lastWatchedAt: $lastWatchedAt, candidates: $candidates, resolvedTitleId: $resolvedTitleId, resolvedAt: $resolvedAt, skipped: $skipped, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $ImportCandidateRowCopyWith<$Res>  {
  factory $ImportCandidateRowCopyWith(ImportCandidateRow value, $Res Function(ImportCandidateRow) _then) = _$ImportCandidateRowCopyWithImpl;
@useResult
$Res call({
 String id, String importId, String userId, String rawName, MediaType? guessedType, int episodesCount, DateTime? lastWatchedAt, List<ImportCandidate> candidates, String? resolvedTitleId, DateTime? resolvedAt, bool skipped, DateTime? createdAt
});




}
/// @nodoc
class _$ImportCandidateRowCopyWithImpl<$Res>
    implements $ImportCandidateRowCopyWith<$Res> {
  _$ImportCandidateRowCopyWithImpl(this._self, this._then);

  final ImportCandidateRow _self;
  final $Res Function(ImportCandidateRow) _then;

/// Create a copy of ImportCandidateRow
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? importId = null,Object? userId = null,Object? rawName = null,Object? guessedType = freezed,Object? episodesCount = null,Object? lastWatchedAt = freezed,Object? candidates = null,Object? resolvedTitleId = freezed,Object? resolvedAt = freezed,Object? skipped = null,Object? createdAt = freezed,}) {
  return _then(ImportCandidateRow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,importId: null == importId ? _self.importId : importId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,guessedType: freezed == guessedType ? _self.guessedType : guessedType // ignore: cast_nullable_to_non_nullable
as MediaType?,episodesCount: null == episodesCount ? _self.episodesCount : episodesCount // ignore: cast_nullable_to_non_nullable
as int,lastWatchedAt: freezed == lastWatchedAt ? _self.lastWatchedAt : lastWatchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<ImportCandidate>,resolvedTitleId: freezed == resolvedTitleId ? _self.resolvedTitleId : resolvedTitleId // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

}


/// Adds pattern-matching-related methods to [ImportCandidateRow].
extension ImportCandidateRowPatterns on ImportCandidateRow {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImportCandidateRow value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImportCandidateRow() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImportCandidateRow value)  $default,){
final _that = this;
switch (_that) {
case _ImportCandidateRow():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImportCandidateRow value)?  $default,){
final _that = this;
switch (_that) {
case _ImportCandidateRow() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String importId,  String userId,  String rawName,  MediaType? guessedType,  int episodesCount,  DateTime? lastWatchedAt,  List<ImportCandidate> candidates,  String? resolvedTitleId,  DateTime? resolvedAt,  bool skipped,  DateTime? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImportCandidateRow() when $default != null:
return $default(_that.id,_that.importId,_that.userId,_that.rawName,_that.guessedType,_that.episodesCount,_that.lastWatchedAt,_that.candidates,_that.resolvedTitleId,_that.resolvedAt,_that.skipped,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String importId,  String userId,  String rawName,  MediaType? guessedType,  int episodesCount,  DateTime? lastWatchedAt,  List<ImportCandidate> candidates,  String? resolvedTitleId,  DateTime? resolvedAt,  bool skipped,  DateTime? createdAt)  $default,) {final _that = this;
switch (_that) {
case _ImportCandidateRow():
return $default(_that.id,_that.importId,_that.userId,_that.rawName,_that.guessedType,_that.episodesCount,_that.lastWatchedAt,_that.candidates,_that.resolvedTitleId,_that.resolvedAt,_that.skipped,_that.createdAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String importId,  String userId,  String rawName,  MediaType? guessedType,  int episodesCount,  DateTime? lastWatchedAt,  List<ImportCandidate> candidates,  String? resolvedTitleId,  DateTime? resolvedAt,  bool skipped,  DateTime? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _ImportCandidateRow() when $default != null:
return $default(_that.id,_that.importId,_that.userId,_that.rawName,_that.guessedType,_that.episodesCount,_that.lastWatchedAt,_that.candidates,_that.resolvedTitleId,_that.resolvedAt,_that.skipped,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImportCandidateRow extends ImportCandidateRow {
  const _ImportCandidateRow({required this.id, required this.importId, required this.userId, required this.rawName, this.guessedType, this.episodesCount = 1, this.lastWatchedAt,  List<ImportCandidate> candidates = const <ImportCandidate>[], this.resolvedTitleId, this.resolvedAt, this.skipped = false, this.createdAt}): _candidates = candidates,super._();
  factory _ImportCandidateRow.fromJson(Map<String, dynamic> json) => _$ImportCandidateRowFromJson(json);

@override final  String id;
@override final  String importId;
@override final  String userId;
@override final  String rawName;
@override final  MediaType? guessedType;
@override@JsonKey() final  int episodesCount;
@override final  DateTime? lastWatchedAt;
 final  List<ImportCandidate> _candidates;
@override@JsonKey() List<ImportCandidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}

@override final  String? resolvedTitleId;
@override final  DateTime? resolvedAt;
@override@JsonKey() final  bool skipped;
@override final  DateTime? createdAt;

/// Create a copy of ImportCandidateRow
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImportCandidateRowCopyWith<_ImportCandidateRow> get copyWith => __$ImportCandidateRowCopyWithImpl<_ImportCandidateRow>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImportCandidateRowToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImportCandidateRow&&(identical(other.id, id) || other.id == id)&&(identical(other.importId, importId) || other.importId == importId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.rawName, rawName) || other.rawName == rawName)&&(identical(other.guessedType, guessedType) || other.guessedType == guessedType)&&(identical(other.episodesCount, episodesCount) || other.episodesCount == episodesCount)&&(identical(other.lastWatchedAt, lastWatchedAt) || other.lastWatchedAt == lastWatchedAt)&&const DeepCollectionEquality().equals(other._candidates, _candidates)&&(identical(other.resolvedTitleId, resolvedTitleId) || other.resolvedTitleId == resolvedTitleId)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.skipped, skipped) || other.skipped == skipped)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,importId,userId,rawName,guessedType,episodesCount,lastWatchedAt,const DeepCollectionEquality().hash(_candidates),resolvedTitleId,resolvedAt,skipped,createdAt);

@override
String toString() {
  return 'ImportCandidateRow(id: $id, importId: $importId, userId: $userId, rawName: $rawName, guessedType: $guessedType, episodesCount: $episodesCount, lastWatchedAt: $lastWatchedAt, candidates: $candidates, resolvedTitleId: $resolvedTitleId, resolvedAt: $resolvedAt, skipped: $skipped, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$ImportCandidateRowCopyWith<$Res> implements $ImportCandidateRowCopyWith<$Res> {
  factory _$ImportCandidateRowCopyWith(_ImportCandidateRow value, $Res Function(_ImportCandidateRow) _then) = __$ImportCandidateRowCopyWithImpl;
@override @useResult
$Res call({
 String id, String importId, String userId, String rawName, MediaType? guessedType, int episodesCount, DateTime? lastWatchedAt, List<ImportCandidate> candidates, String? resolvedTitleId, DateTime? resolvedAt, bool skipped, DateTime? createdAt
});




}
/// @nodoc
class __$ImportCandidateRowCopyWithImpl<$Res>
    implements _$ImportCandidateRowCopyWith<$Res> {
  __$ImportCandidateRowCopyWithImpl(this._self, this._then);

  final _ImportCandidateRow _self;
  final $Res Function(_ImportCandidateRow) _then;

/// Create a copy of ImportCandidateRow
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? importId = null,Object? userId = null,Object? rawName = null,Object? guessedType = freezed,Object? episodesCount = null,Object? lastWatchedAt = freezed,Object? candidates = null,Object? resolvedTitleId = freezed,Object? resolvedAt = freezed,Object? skipped = null,Object? createdAt = freezed,}) {
  return _then(_ImportCandidateRow(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,importId: null == importId ? _self.importId : importId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,rawName: null == rawName ? _self.rawName : rawName // ignore: cast_nullable_to_non_nullable
as String,guessedType: freezed == guessedType ? _self.guessedType : guessedType // ignore: cast_nullable_to_non_nullable
as MediaType?,episodesCount: null == episodesCount ? _self.episodesCount : episodesCount // ignore: cast_nullable_to_non_nullable
as int,lastWatchedAt: freezed == lastWatchedAt ? _self.lastWatchedAt : lastWatchedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<ImportCandidate>,resolvedTitleId: freezed == resolvedTitleId ? _self.resolvedTitleId : resolvedTitleId // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,skipped: null == skipped ? _self.skipped : skipped // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}


}

// dart format on
