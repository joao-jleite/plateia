// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'recommendation.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Candidate {

 String get titleId; String get name; CandidateSource get source; MediaType? get mediaType; int? get tmdbId; String? get posterPath;/// `@` de quem assistiu/avaliou, quando a fonte é `friends`.
 String? get friendUsername;
/// Create a copy of Candidate
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CandidateCopyWith<Candidate> get copyWith => _$CandidateCopyWithImpl<Candidate>(this as Candidate, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Candidate&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.friendUsername, friendUsername) || other.friendUsername == friendUsername));
}


@override
int get hashCode => Object.hash(runtimeType,titleId,name,source,mediaType,tmdbId,posterPath,friendUsername);

@override
String toString() {
  return 'Candidate(titleId: $titleId, name: $name, source: $source, mediaType: $mediaType, tmdbId: $tmdbId, posterPath: $posterPath, friendUsername: $friendUsername)';
}


}

/// @nodoc
abstract mixin class $CandidateCopyWith<$Res>  {
  factory $CandidateCopyWith(Candidate value, $Res Function(Candidate) _then) = _$CandidateCopyWithImpl;
@useResult
$Res call({
 String titleId, String name, CandidateSource source, MediaType? mediaType, int? tmdbId, String? posterPath, String? friendUsername
});




}
/// @nodoc
class _$CandidateCopyWithImpl<$Res>
    implements $CandidateCopyWith<$Res> {
  _$CandidateCopyWithImpl(this._self, this._then);

  final Candidate _self;
  final $Res Function(Candidate) _then;

/// Create a copy of Candidate
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? titleId = null,Object? name = null,Object? source = null,Object? mediaType = freezed,Object? tmdbId = freezed,Object? posterPath = freezed,Object? friendUsername = freezed,}) {
  return _then(Candidate(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CandidateSource,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,tmdbId: freezed == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,friendUsername: freezed == friendUsername ? _self.friendUsername : friendUsername // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Candidate].
extension CandidatePatterns on Candidate {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Candidate value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Candidate() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Candidate value)  $default,){
final _that = this;
switch (_that) {
case _Candidate():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Candidate value)?  $default,){
final _that = this;
switch (_that) {
case _Candidate() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String titleId,  String name,  CandidateSource source,  MediaType? mediaType,  int? tmdbId,  String? posterPath,  String? friendUsername)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Candidate() when $default != null:
return $default(_that.titleId,_that.name,_that.source,_that.mediaType,_that.tmdbId,_that.posterPath,_that.friendUsername);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String titleId,  String name,  CandidateSource source,  MediaType? mediaType,  int? tmdbId,  String? posterPath,  String? friendUsername)  $default,) {final _that = this;
switch (_that) {
case _Candidate():
return $default(_that.titleId,_that.name,_that.source,_that.mediaType,_that.tmdbId,_that.posterPath,_that.friendUsername);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String titleId,  String name,  CandidateSource source,  MediaType? mediaType,  int? tmdbId,  String? posterPath,  String? friendUsername)?  $default,) {final _that = this;
switch (_that) {
case _Candidate() when $default != null:
return $default(_that.titleId,_that.name,_that.source,_that.mediaType,_that.tmdbId,_that.posterPath,_that.friendUsername);case _:
  return null;

}
}

}

/// @nodoc


class _Candidate extends Candidate {
  const _Candidate({required this.titleId, required this.name, required this.source, this.mediaType, this.tmdbId, this.posterPath, this.friendUsername}): super._();
  

@override final  String titleId;
@override final  String name;
@override final  CandidateSource source;
@override final  MediaType? mediaType;
@override final  int? tmdbId;
@override final  String? posterPath;
/// `@` de quem assistiu/avaliou, quando a fonte é `friends`.
@override final  String? friendUsername;

/// Create a copy of Candidate
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CandidateCopyWith<_Candidate> get copyWith => __$CandidateCopyWithImpl<_Candidate>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Candidate&&(identical(other.titleId, titleId) || other.titleId == titleId)&&(identical(other.name, name) || other.name == name)&&(identical(other.source, source) || other.source == source)&&(identical(other.mediaType, mediaType) || other.mediaType == mediaType)&&(identical(other.tmdbId, tmdbId) || other.tmdbId == tmdbId)&&(identical(other.posterPath, posterPath) || other.posterPath == posterPath)&&(identical(other.friendUsername, friendUsername) || other.friendUsername == friendUsername));
}


@override
int get hashCode => Object.hash(runtimeType,titleId,name,source,mediaType,tmdbId,posterPath,friendUsername);

@override
String toString() {
  return 'Candidate(titleId: $titleId, name: $name, source: $source, mediaType: $mediaType, tmdbId: $tmdbId, posterPath: $posterPath, friendUsername: $friendUsername)';
}


}

/// @nodoc
abstract mixin class _$CandidateCopyWith<$Res> implements $CandidateCopyWith<$Res> {
  factory _$CandidateCopyWith(_Candidate value, $Res Function(_Candidate) _then) = __$CandidateCopyWithImpl;
@override @useResult
$Res call({
 String titleId, String name, CandidateSource source, MediaType? mediaType, int? tmdbId, String? posterPath, String? friendUsername
});




}
/// @nodoc
class __$CandidateCopyWithImpl<$Res>
    implements _$CandidateCopyWith<$Res> {
  __$CandidateCopyWithImpl(this._self, this._then);

  final _Candidate _self;
  final $Res Function(_Candidate) _then;

/// Create a copy of Candidate
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? titleId = null,Object? name = null,Object? source = null,Object? mediaType = freezed,Object? tmdbId = freezed,Object? posterPath = freezed,Object? friendUsername = freezed,}) {
  return _then(_Candidate(
titleId: null == titleId ? _self.titleId : titleId // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,source: null == source ? _self.source : source // ignore: cast_nullable_to_non_nullable
as CandidateSource,mediaType: freezed == mediaType ? _self.mediaType : mediaType // ignore: cast_nullable_to_non_nullable
as MediaType?,tmdbId: freezed == tmdbId ? _self.tmdbId : tmdbId // ignore: cast_nullable_to_non_nullable
as int?,posterPath: freezed == posterPath ? _self.posterPath : posterPath // ignore: cast_nullable_to_non_nullable
as String?,friendUsername: freezed == friendUsername ? _self.friendUsername : friendUsername // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$CachedOffer {

 int get providerId; OfferType get offerType;
/// Create a copy of CachedOffer
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CachedOfferCopyWith<CachedOffer> get copyWith => _$CachedOfferCopyWithImpl<CachedOffer>(this as CachedOffer, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CachedOffer&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.offerType, offerType) || other.offerType == offerType));
}


@override
int get hashCode => Object.hash(runtimeType,providerId,offerType);

@override
String toString() {
  return 'CachedOffer(providerId: $providerId, offerType: $offerType)';
}


}

/// @nodoc
abstract mixin class $CachedOfferCopyWith<$Res>  {
  factory $CachedOfferCopyWith(CachedOffer value, $Res Function(CachedOffer) _then) = _$CachedOfferCopyWithImpl;
@useResult
$Res call({
 int providerId, OfferType offerType
});




}
/// @nodoc
class _$CachedOfferCopyWithImpl<$Res>
    implements $CachedOfferCopyWith<$Res> {
  _$CachedOfferCopyWithImpl(this._self, this._then);

  final CachedOffer _self;
  final $Res Function(CachedOffer) _then;

/// Create a copy of CachedOffer
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? offerType = null,}) {
  return _then(CachedOffer(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,offerType: null == offerType ? _self.offerType : offerType // ignore: cast_nullable_to_non_nullable
as OfferType,
  ));
}

}


/// Adds pattern-matching-related methods to [CachedOffer].
extension CachedOfferPatterns on CachedOffer {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CachedOffer value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CachedOffer() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CachedOffer value)  $default,){
final _that = this;
switch (_that) {
case _CachedOffer():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CachedOffer value)?  $default,){
final _that = this;
switch (_that) {
case _CachedOffer() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int providerId,  OfferType offerType)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CachedOffer() when $default != null:
return $default(_that.providerId,_that.offerType);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int providerId,  OfferType offerType)  $default,) {final _that = this;
switch (_that) {
case _CachedOffer():
return $default(_that.providerId,_that.offerType);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int providerId,  OfferType offerType)?  $default,) {final _that = this;
switch (_that) {
case _CachedOffer() when $default != null:
return $default(_that.providerId,_that.offerType);case _:
  return null;

}
}

}

/// @nodoc


class _CachedOffer implements CachedOffer {
  const _CachedOffer({required this.providerId, required this.offerType});
  

@override final  int providerId;
@override final  OfferType offerType;

/// Create a copy of CachedOffer
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CachedOfferCopyWith<_CachedOffer> get copyWith => __$CachedOfferCopyWithImpl<_CachedOffer>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CachedOffer&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.offerType, offerType) || other.offerType == offerType));
}


@override
int get hashCode => Object.hash(runtimeType,providerId,offerType);

@override
String toString() {
  return 'CachedOffer(providerId: $providerId, offerType: $offerType)';
}


}

/// @nodoc
abstract mixin class _$CachedOfferCopyWith<$Res> implements $CachedOfferCopyWith<$Res> {
  factory _$CachedOfferCopyWith(_CachedOffer value, $Res Function(_CachedOffer) _then) = __$CachedOfferCopyWithImpl;
@override @useResult
$Res call({
 int providerId, OfferType offerType
});




}
/// @nodoc
class __$CachedOfferCopyWithImpl<$Res>
    implements _$CachedOfferCopyWith<$Res> {
  __$CachedOfferCopyWithImpl(this._self, this._then);

  final _CachedOffer _self;
  final $Res Function(_CachedOffer) _then;

/// Create a copy of CachedOffer
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? offerType = null,}) {
  return _then(_CachedOffer(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,offerType: null == offerType ? _self.offerType : offerType // ignore: cast_nullable_to_non_nullable
as OfferType,
  ));
}


}

/// @nodoc
mixin _$RecommendInput {

 List<Candidate> get candidates;/// titleId → ofertas em cache. **Chave ausente = sem dados** (o título
/// nunca teve "onde assistir" consultado); lista vazia = consultado e não
/// está em nenhum streaming.
 Map<String, List<CachedOffer>> get availability;/// Streamings destacados (`is_featured`), na ordem de exibição.
 List<StreamingProvider> get providers; List<ProviderPrice> get prices;/// Ids dos streamings que eu já assino (desempate e frase final).
 Set<int> get mySubscriptions;/// Chave "aceito plano com anúncios": usa o preço `ads` quando existir.
 bool get acceptAds; DateTime get now;
/// Create a copy of RecommendInput
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendInputCopyWith<RecommendInput> get copyWith => _$RecommendInputCopyWithImpl<RecommendInput>(this as RecommendInput, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RecommendInput&&const DeepCollectionEquality().equals(other.candidates, candidates)&&const DeepCollectionEquality().equals(other.availability, availability)&&const DeepCollectionEquality().equals(other.providers, providers)&&const DeepCollectionEquality().equals(other.prices, prices)&&const DeepCollectionEquality().equals(other.mySubscriptions, mySubscriptions)&&(identical(other.acceptAds, acceptAds) || other.acceptAds == acceptAds)&&(identical(other.now, now) || other.now == now));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(candidates),const DeepCollectionEquality().hash(availability),const DeepCollectionEquality().hash(providers),const DeepCollectionEquality().hash(prices),const DeepCollectionEquality().hash(mySubscriptions),acceptAds,now);

@override
String toString() {
  return 'RecommendInput(candidates: $candidates, availability: $availability, providers: $providers, prices: $prices, mySubscriptions: $mySubscriptions, acceptAds: $acceptAds, now: $now)';
}


}

/// @nodoc
abstract mixin class $RecommendInputCopyWith<$Res>  {
  factory $RecommendInputCopyWith(RecommendInput value, $Res Function(RecommendInput) _then) = _$RecommendInputCopyWithImpl;
@useResult
$Res call({
 List<Candidate> candidates, Map<String, List<CachedOffer>> availability, List<StreamingProvider> providers, List<ProviderPrice> prices, Set<int> mySubscriptions, bool acceptAds, DateTime now
});




}
/// @nodoc
class _$RecommendInputCopyWithImpl<$Res>
    implements $RecommendInputCopyWith<$Res> {
  _$RecommendInputCopyWithImpl(this._self, this._then);

  final RecommendInput _self;
  final $Res Function(RecommendInput) _then;

/// Create a copy of RecommendInput
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? candidates = null,Object? availability = null,Object? providers = null,Object? prices = null,Object? mySubscriptions = null,Object? acceptAds = null,Object? now = null,}) {
  return _then(RecommendInput(
candidates: null == candidates ? _self.candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<Candidate>,availability: null == availability ? _self.availability : availability // ignore: cast_nullable_to_non_nullable
as Map<String, List<CachedOffer>>,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<StreamingProvider>,prices: null == prices ? _self.prices : prices // ignore: cast_nullable_to_non_nullable
as List<ProviderPrice>,mySubscriptions: null == mySubscriptions ? _self.mySubscriptions : mySubscriptions // ignore: cast_nullable_to_non_nullable
as Set<int>,acceptAds: null == acceptAds ? _self.acceptAds : acceptAds // ignore: cast_nullable_to_non_nullable
as bool,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [RecommendInput].
extension RecommendInputPatterns on RecommendInput {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RecommendInput value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RecommendInput() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RecommendInput value)  $default,){
final _that = this;
switch (_that) {
case _RecommendInput():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RecommendInput value)?  $default,){
final _that = this;
switch (_that) {
case _RecommendInput() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Candidate> candidates,  Map<String, List<CachedOffer>> availability,  List<StreamingProvider> providers,  List<ProviderPrice> prices,  Set<int> mySubscriptions,  bool acceptAds,  DateTime now)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RecommendInput() when $default != null:
return $default(_that.candidates,_that.availability,_that.providers,_that.prices,_that.mySubscriptions,_that.acceptAds,_that.now);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Candidate> candidates,  Map<String, List<CachedOffer>> availability,  List<StreamingProvider> providers,  List<ProviderPrice> prices,  Set<int> mySubscriptions,  bool acceptAds,  DateTime now)  $default,) {final _that = this;
switch (_that) {
case _RecommendInput():
return $default(_that.candidates,_that.availability,_that.providers,_that.prices,_that.mySubscriptions,_that.acceptAds,_that.now);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Candidate> candidates,  Map<String, List<CachedOffer>> availability,  List<StreamingProvider> providers,  List<ProviderPrice> prices,  Set<int> mySubscriptions,  bool acceptAds,  DateTime now)?  $default,) {final _that = this;
switch (_that) {
case _RecommendInput() when $default != null:
return $default(_that.candidates,_that.availability,_that.providers,_that.prices,_that.mySubscriptions,_that.acceptAds,_that.now);case _:
  return null;

}
}

}

/// @nodoc


class _RecommendInput implements RecommendInput {
  const _RecommendInput({required  List<Candidate> candidates, required  Map<String, List<CachedOffer>> availability, required  List<StreamingProvider> providers, required  List<ProviderPrice> prices,  Set<int> mySubscriptions = const <int>{}, this.acceptAds = false, required this.now}): _candidates = candidates,_availability = availability,_providers = providers,_prices = prices,_mySubscriptions = mySubscriptions;
  

 final  List<Candidate> _candidates;
@override List<Candidate> get candidates {
  if (_candidates is EqualUnmodifiableListView) return _candidates;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_candidates);
}

/// titleId → ofertas em cache. **Chave ausente = sem dados** (o título
/// nunca teve "onde assistir" consultado); lista vazia = consultado e não
/// está em nenhum streaming.
 final  Map<String, List<CachedOffer>> _availability;
/// titleId → ofertas em cache. **Chave ausente = sem dados** (o título
/// nunca teve "onde assistir" consultado); lista vazia = consultado e não
/// está em nenhum streaming.
@override Map<String, List<CachedOffer>> get availability {
  if (_availability is EqualUnmodifiableMapView) return _availability;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_availability);
}

/// Streamings destacados (`is_featured`), na ordem de exibição.
 final  List<StreamingProvider> _providers;
/// Streamings destacados (`is_featured`), na ordem de exibição.
@override List<StreamingProvider> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}

 final  List<ProviderPrice> _prices;
@override List<ProviderPrice> get prices {
  if (_prices is EqualUnmodifiableListView) return _prices;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_prices);
}

/// Ids dos streamings que eu já assino (desempate e frase final).
 final  Set<int> _mySubscriptions;
/// Ids dos streamings que eu já assino (desempate e frase final).
@override@JsonKey() Set<int> get mySubscriptions {
  if (_mySubscriptions is EqualUnmodifiableSetView) return _mySubscriptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_mySubscriptions);
}

/// Chave "aceito plano com anúncios": usa o preço `ads` quando existir.
@override@JsonKey() final  bool acceptAds;
@override final  DateTime now;

/// Create a copy of RecommendInput
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendInputCopyWith<_RecommendInput> get copyWith => __$RecommendInputCopyWithImpl<_RecommendInput>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RecommendInput&&const DeepCollectionEquality().equals(other._candidates, _candidates)&&const DeepCollectionEquality().equals(other._availability, _availability)&&const DeepCollectionEquality().equals(other._providers, _providers)&&const DeepCollectionEquality().equals(other._prices, _prices)&&const DeepCollectionEquality().equals(other._mySubscriptions, _mySubscriptions)&&(identical(other.acceptAds, acceptAds) || other.acceptAds == acceptAds)&&(identical(other.now, now) || other.now == now));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_candidates),const DeepCollectionEquality().hash(_availability),const DeepCollectionEquality().hash(_providers),const DeepCollectionEquality().hash(_prices),const DeepCollectionEquality().hash(_mySubscriptions),acceptAds,now);

@override
String toString() {
  return 'RecommendInput(candidates: $candidates, availability: $availability, providers: $providers, prices: $prices, mySubscriptions: $mySubscriptions, acceptAds: $acceptAds, now: $now)';
}


}

/// @nodoc
abstract mixin class _$RecommendInputCopyWith<$Res> implements $RecommendInputCopyWith<$Res> {
  factory _$RecommendInputCopyWith(_RecommendInput value, $Res Function(_RecommendInput) _then) = __$RecommendInputCopyWithImpl;
@override @useResult
$Res call({
 List<Candidate> candidates, Map<String, List<CachedOffer>> availability, List<StreamingProvider> providers, List<ProviderPrice> prices, Set<int> mySubscriptions, bool acceptAds, DateTime now
});




}
/// @nodoc
class __$RecommendInputCopyWithImpl<$Res>
    implements _$RecommendInputCopyWith<$Res> {
  __$RecommendInputCopyWithImpl(this._self, this._then);

  final _RecommendInput _self;
  final $Res Function(_RecommendInput) _then;

/// Create a copy of RecommendInput
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? candidates = null,Object? availability = null,Object? providers = null,Object? prices = null,Object? mySubscriptions = null,Object? acceptAds = null,Object? now = null,}) {
  return _then(_RecommendInput(
candidates: null == candidates ? _self._candidates : candidates // ignore: cast_nullable_to_non_nullable
as List<Candidate>,availability: null == availability ? _self._availability : availability // ignore: cast_nullable_to_non_nullable
as Map<String, List<CachedOffer>>,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<StreamingProvider>,prices: null == prices ? _self._prices : prices // ignore: cast_nullable_to_non_nullable
as List<ProviderPrice>,mySubscriptions: null == mySubscriptions ? _self._mySubscriptions : mySubscriptions // ignore: cast_nullable_to_non_nullable
as Set<int>,acceptAds: null == acceptAds ? _self.acceptAds : acceptAds // ignore: cast_nullable_to_non_nullable
as bool,now: null == now ? _self.now : now // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}

/// @nodoc
mixin _$ProviderScore {

 StreamingProvider get provider; ProviderPrice get price;/// Títulos que ele resolve (assinatura, com ou sem anúncios), meus primeiro.
 List<Candidate> get resolved;/// Soma dos pesos (meus 1 + amigos 0,3): é o que ordena o ranking.
 double get score; bool get alreadySubscribed;/// `updated_at` do preço com mais de 60 dias.
 bool get priceStale;
/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderScoreCopyWith<ProviderScore> get copyWith => _$ProviderScoreCopyWithImpl<ProviderScore>(this as ProviderScore, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderScore&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other.resolved, resolved)&&(identical(other.score, score) || other.score == score)&&(identical(other.alreadySubscribed, alreadySubscribed) || other.alreadySubscribed == alreadySubscribed)&&(identical(other.priceStale, priceStale) || other.priceStale == priceStale));
}


@override
int get hashCode => Object.hash(runtimeType,provider,price,const DeepCollectionEquality().hash(resolved),score,alreadySubscribed,priceStale);

@override
String toString() {
  return 'ProviderScore(provider: $provider, price: $price, resolved: $resolved, score: $score, alreadySubscribed: $alreadySubscribed, priceStale: $priceStale)';
}


}

/// @nodoc
abstract mixin class $ProviderScoreCopyWith<$Res>  {
  factory $ProviderScoreCopyWith(ProviderScore value, $Res Function(ProviderScore) _then) = _$ProviderScoreCopyWithImpl;
@useResult
$Res call({
 StreamingProvider provider, ProviderPrice price, List<Candidate> resolved, double score, bool alreadySubscribed, bool priceStale
});


$StreamingProviderCopyWith<$Res> get provider;$ProviderPriceCopyWith<$Res> get price;

}
/// @nodoc
class _$ProviderScoreCopyWithImpl<$Res>
    implements $ProviderScoreCopyWith<$Res> {
  _$ProviderScoreCopyWithImpl(this._self, this._then);

  final ProviderScore _self;
  final $Res Function(ProviderScore) _then;

/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? provider = null,Object? price = null,Object? resolved = null,Object? score = null,Object? alreadySubscribed = null,Object? priceStale = null,}) {
  return _then(ProviderScore(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as StreamingProvider,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as ProviderPrice,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as List<Candidate>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,alreadySubscribed: null == alreadySubscribed ? _self.alreadySubscribed : alreadySubscribed // ignore: cast_nullable_to_non_nullable
as bool,priceStale: null == priceStale ? _self.priceStale : priceStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}
/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamingProviderCopyWith<$Res> get provider {
  
  return $StreamingProviderCopyWith<$Res>(_self.provider, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderPriceCopyWith<$Res> get price {
  
  return $ProviderPriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}


/// Adds pattern-matching-related methods to [ProviderScore].
extension ProviderScorePatterns on ProviderScore {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderScore value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderScore() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderScore value)  $default,){
final _that = this;
switch (_that) {
case _ProviderScore():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderScore value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderScore() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( StreamingProvider provider,  ProviderPrice price,  List<Candidate> resolved,  double score,  bool alreadySubscribed,  bool priceStale)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderScore() when $default != null:
return $default(_that.provider,_that.price,_that.resolved,_that.score,_that.alreadySubscribed,_that.priceStale);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( StreamingProvider provider,  ProviderPrice price,  List<Candidate> resolved,  double score,  bool alreadySubscribed,  bool priceStale)  $default,) {final _that = this;
switch (_that) {
case _ProviderScore():
return $default(_that.provider,_that.price,_that.resolved,_that.score,_that.alreadySubscribed,_that.priceStale);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( StreamingProvider provider,  ProviderPrice price,  List<Candidate> resolved,  double score,  bool alreadySubscribed,  bool priceStale)?  $default,) {final _that = this;
switch (_that) {
case _ProviderScore() when $default != null:
return $default(_that.provider,_that.price,_that.resolved,_that.score,_that.alreadySubscribed,_that.priceStale);case _:
  return null;

}
}

}

/// @nodoc


class _ProviderScore extends ProviderScore {
  const _ProviderScore({required this.provider, required this.price, required  List<Candidate> resolved, required this.score, this.alreadySubscribed = false, this.priceStale = false}): _resolved = resolved,super._();
  

@override final  StreamingProvider provider;
@override final  ProviderPrice price;
/// Títulos que ele resolve (assinatura, com ou sem anúncios), meus primeiro.
 final  List<Candidate> _resolved;
/// Títulos que ele resolve (assinatura, com ou sem anúncios), meus primeiro.
@override List<Candidate> get resolved {
  if (_resolved is EqualUnmodifiableListView) return _resolved;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resolved);
}

/// Soma dos pesos (meus 1 + amigos 0,3): é o que ordena o ranking.
@override final  double score;
@override@JsonKey() final  bool alreadySubscribed;
/// `updated_at` do preço com mais de 60 dias.
@override@JsonKey() final  bool priceStale;

/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderScoreCopyWith<_ProviderScore> get copyWith => __$ProviderScoreCopyWithImpl<_ProviderScore>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderScore&&(identical(other.provider, provider) || other.provider == provider)&&(identical(other.price, price) || other.price == price)&&const DeepCollectionEquality().equals(other._resolved, _resolved)&&(identical(other.score, score) || other.score == score)&&(identical(other.alreadySubscribed, alreadySubscribed) || other.alreadySubscribed == alreadySubscribed)&&(identical(other.priceStale, priceStale) || other.priceStale == priceStale));
}


@override
int get hashCode => Object.hash(runtimeType,provider,price,const DeepCollectionEquality().hash(_resolved),score,alreadySubscribed,priceStale);

@override
String toString() {
  return 'ProviderScore(provider: $provider, price: $price, resolved: $resolved, score: $score, alreadySubscribed: $alreadySubscribed, priceStale: $priceStale)';
}


}

/// @nodoc
abstract mixin class _$ProviderScoreCopyWith<$Res> implements $ProviderScoreCopyWith<$Res> {
  factory _$ProviderScoreCopyWith(_ProviderScore value, $Res Function(_ProviderScore) _then) = __$ProviderScoreCopyWithImpl;
@override @useResult
$Res call({
 StreamingProvider provider, ProviderPrice price, List<Candidate> resolved, double score, bool alreadySubscribed, bool priceStale
});


@override $StreamingProviderCopyWith<$Res> get provider;@override $ProviderPriceCopyWith<$Res> get price;

}
/// @nodoc
class __$ProviderScoreCopyWithImpl<$Res>
    implements _$ProviderScoreCopyWith<$Res> {
  __$ProviderScoreCopyWithImpl(this._self, this._then);

  final _ProviderScore _self;
  final $Res Function(_ProviderScore) _then;

/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? provider = null,Object? price = null,Object? resolved = null,Object? score = null,Object? alreadySubscribed = null,Object? priceStale = null,}) {
  return _then(_ProviderScore(
provider: null == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as StreamingProvider,price: null == price ? _self.price : price // ignore: cast_nullable_to_non_nullable
as ProviderPrice,resolved: null == resolved ? _self._resolved : resolved // ignore: cast_nullable_to_non_nullable
as List<Candidate>,score: null == score ? _self.score : score // ignore: cast_nullable_to_non_nullable
as double,alreadySubscribed: null == alreadySubscribed ? _self.alreadySubscribed : alreadySubscribed // ignore: cast_nullable_to_non_nullable
as bool,priceStale: null == priceStale ? _self.priceStale : priceStale // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamingProviderCopyWith<$Res> get provider {
  
  return $StreamingProviderCopyWith<$Res>(_self.provider, (value) {
    return _then(_self.copyWith(provider: value));
  });
}/// Create a copy of ProviderScore
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderPriceCopyWith<$Res> get price {
  
  return $ProviderPriceCopyWith<$Res>(_self.price, (value) {
    return _then(_self.copyWith(price: value));
  });
}
}

/// @nodoc
mixin _$LeftOutTitle {

 Candidate get candidate; List<StreamingProvider> get providers;
/// Create a copy of LeftOutTitle
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LeftOutTitleCopyWith<LeftOutTitle> get copyWith => _$LeftOutTitleCopyWithImpl<LeftOutTitle>(this as LeftOutTitle, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LeftOutTitle&&(identical(other.candidate, candidate) || other.candidate == candidate)&&const DeepCollectionEquality().equals(other.providers, providers));
}


@override
int get hashCode => Object.hash(runtimeType,candidate,const DeepCollectionEquality().hash(providers));

@override
String toString() {
  return 'LeftOutTitle(candidate: $candidate, providers: $providers)';
}


}

/// @nodoc
abstract mixin class $LeftOutTitleCopyWith<$Res>  {
  factory $LeftOutTitleCopyWith(LeftOutTitle value, $Res Function(LeftOutTitle) _then) = _$LeftOutTitleCopyWithImpl;
@useResult
$Res call({
 Candidate candidate, List<StreamingProvider> providers
});


$CandidateCopyWith<$Res> get candidate;

}
/// @nodoc
class _$LeftOutTitleCopyWithImpl<$Res>
    implements $LeftOutTitleCopyWith<$Res> {
  _$LeftOutTitleCopyWithImpl(this._self, this._then);

  final LeftOutTitle _self;
  final $Res Function(LeftOutTitle) _then;

/// Create a copy of LeftOutTitle
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? candidate = null,Object? providers = null,}) {
  return _then(LeftOutTitle(
candidate: null == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as Candidate,providers: null == providers ? _self.providers : providers // ignore: cast_nullable_to_non_nullable
as List<StreamingProvider>,
  ));
}
/// Create a copy of LeftOutTitle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CandidateCopyWith<$Res> get candidate {
  
  return $CandidateCopyWith<$Res>(_self.candidate, (value) {
    return _then(_self.copyWith(candidate: value));
  });
}
}


/// Adds pattern-matching-related methods to [LeftOutTitle].
extension LeftOutTitlePatterns on LeftOutTitle {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LeftOutTitle value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LeftOutTitle() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LeftOutTitle value)  $default,){
final _that = this;
switch (_that) {
case _LeftOutTitle():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LeftOutTitle value)?  $default,){
final _that = this;
switch (_that) {
case _LeftOutTitle() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( Candidate candidate,  List<StreamingProvider> providers)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LeftOutTitle() when $default != null:
return $default(_that.candidate,_that.providers);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( Candidate candidate,  List<StreamingProvider> providers)  $default,) {final _that = this;
switch (_that) {
case _LeftOutTitle():
return $default(_that.candidate,_that.providers);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( Candidate candidate,  List<StreamingProvider> providers)?  $default,) {final _that = this;
switch (_that) {
case _LeftOutTitle() when $default != null:
return $default(_that.candidate,_that.providers);case _:
  return null;

}
}

}

/// @nodoc


class _LeftOutTitle implements LeftOutTitle {
  const _LeftOutTitle({required this.candidate, required  List<StreamingProvider> providers}): _providers = providers;
  

@override final  Candidate candidate;
 final  List<StreamingProvider> _providers;
@override List<StreamingProvider> get providers {
  if (_providers is EqualUnmodifiableListView) return _providers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_providers);
}


/// Create a copy of LeftOutTitle
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LeftOutTitleCopyWith<_LeftOutTitle> get copyWith => __$LeftOutTitleCopyWithImpl<_LeftOutTitle>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LeftOutTitle&&(identical(other.candidate, candidate) || other.candidate == candidate)&&const DeepCollectionEquality().equals(other._providers, _providers));
}


@override
int get hashCode => Object.hash(runtimeType,candidate,const DeepCollectionEquality().hash(_providers));

@override
String toString() {
  return 'LeftOutTitle(candidate: $candidate, providers: $providers)';
}


}

/// @nodoc
abstract mixin class _$LeftOutTitleCopyWith<$Res> implements $LeftOutTitleCopyWith<$Res> {
  factory _$LeftOutTitleCopyWith(_LeftOutTitle value, $Res Function(_LeftOutTitle) _then) = __$LeftOutTitleCopyWithImpl;
@override @useResult
$Res call({
 Candidate candidate, List<StreamingProvider> providers
});


@override $CandidateCopyWith<$Res> get candidate;

}
/// @nodoc
class __$LeftOutTitleCopyWithImpl<$Res>
    implements _$LeftOutTitleCopyWith<$Res> {
  __$LeftOutTitleCopyWithImpl(this._self, this._then);

  final _LeftOutTitle _self;
  final $Res Function(_LeftOutTitle) _then;

/// Create a copy of LeftOutTitle
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? candidate = null,Object? providers = null,}) {
  return _then(_LeftOutTitle(
candidate: null == candidate ? _self.candidate : candidate // ignore: cast_nullable_to_non_nullable
as Candidate,providers: null == providers ? _self._providers : providers // ignore: cast_nullable_to_non_nullable
as List<StreamingProvider>,
  ));
}

/// Create a copy of LeftOutTitle
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$CandidateCopyWith<$Res> get candidate {
  
  return $CandidateCopyWith<$Res>(_self.candidate, (value) {
    return _then(_self.copyWith(candidate: value));
  });
}
}

/// @nodoc
mixin _$Recommendation {

/// Só quem resolve ≥ 1 título, do melhor para o pior.
 List<ProviderScore> get ranking;/// Streamings com preço que não resolvem nada (a tela lista os nomes).
 List<StreamingProvider> get resolvingNothing; ProviderScore? get best;/// Segundo streaming, só quando acrescenta ≥ 3 títulos e baixa o custo por título.
 ProviderScore? get combo; List<Candidate> get comboAdded;/// Em assinatura, mas fora do(s) escolhido(s).
 List<LeftOutTitle> get leftOut;/// Só aluguel ou compra.
 List<Candidate> get rentOnly;/// Já dá para ver grátis (não precisa assinar nada).
 List<Candidate> get freeOnly;/// Só em streaming que não está na lista de preços.
 List<Candidate> get elsewhere;/// Cache consultado: em nenhum streaming no Brasil.
 List<Candidate> get unavailable;/// Sem cache de "onde assistir": nunca chutar.
 List<Candidate> get noData; int get totalMine; int get totalFriends;/// O `updated_at` mais recente entre os preços usados ("Preços de
/// DD/MM/AAAA"); preço velho tem aviso próprio em [ProviderScore.priceStale].
 DateTime? get pricesUpdatedAt; bool get anyEstimate;/// Frase final, legível. Null só quando não há candidato nenhum.
 String? get headline;
/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RecommendationCopyWith<Recommendation> get copyWith => _$RecommendationCopyWithImpl<Recommendation>(this as Recommendation, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Recommendation&&const DeepCollectionEquality().equals(other.ranking, ranking)&&const DeepCollectionEquality().equals(other.resolvingNothing, resolvingNothing)&&(identical(other.best, best) || other.best == best)&&(identical(other.combo, combo) || other.combo == combo)&&const DeepCollectionEquality().equals(other.comboAdded, comboAdded)&&const DeepCollectionEquality().equals(other.leftOut, leftOut)&&const DeepCollectionEquality().equals(other.rentOnly, rentOnly)&&const DeepCollectionEquality().equals(other.freeOnly, freeOnly)&&const DeepCollectionEquality().equals(other.elsewhere, elsewhere)&&const DeepCollectionEquality().equals(other.unavailable, unavailable)&&const DeepCollectionEquality().equals(other.noData, noData)&&(identical(other.totalMine, totalMine) || other.totalMine == totalMine)&&(identical(other.totalFriends, totalFriends) || other.totalFriends == totalFriends)&&(identical(other.pricesUpdatedAt, pricesUpdatedAt) || other.pricesUpdatedAt == pricesUpdatedAt)&&(identical(other.anyEstimate, anyEstimate) || other.anyEstimate == anyEstimate)&&(identical(other.headline, headline) || other.headline == headline));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(ranking),const DeepCollectionEquality().hash(resolvingNothing),best,combo,const DeepCollectionEquality().hash(comboAdded),const DeepCollectionEquality().hash(leftOut),const DeepCollectionEquality().hash(rentOnly),const DeepCollectionEquality().hash(freeOnly),const DeepCollectionEquality().hash(elsewhere),const DeepCollectionEquality().hash(unavailable),const DeepCollectionEquality().hash(noData),totalMine,totalFriends,pricesUpdatedAt,anyEstimate,headline);

@override
String toString() {
  return 'Recommendation(ranking: $ranking, resolvingNothing: $resolvingNothing, best: $best, combo: $combo, comboAdded: $comboAdded, leftOut: $leftOut, rentOnly: $rentOnly, freeOnly: $freeOnly, elsewhere: $elsewhere, unavailable: $unavailable, noData: $noData, totalMine: $totalMine, totalFriends: $totalFriends, pricesUpdatedAt: $pricesUpdatedAt, anyEstimate: $anyEstimate, headline: $headline)';
}


}

/// @nodoc
abstract mixin class $RecommendationCopyWith<$Res>  {
  factory $RecommendationCopyWith(Recommendation value, $Res Function(Recommendation) _then) = _$RecommendationCopyWithImpl;
@useResult
$Res call({
 List<ProviderScore> ranking, List<StreamingProvider> resolvingNothing, ProviderScore? best, ProviderScore? combo, List<Candidate> comboAdded, List<LeftOutTitle> leftOut, List<Candidate> rentOnly, List<Candidate> freeOnly, List<Candidate> elsewhere, List<Candidate> unavailable, List<Candidate> noData, int totalMine, int totalFriends, DateTime? pricesUpdatedAt, bool anyEstimate, String? headline
});


$ProviderScoreCopyWith<$Res>? get best;$ProviderScoreCopyWith<$Res>? get combo;

}
/// @nodoc
class _$RecommendationCopyWithImpl<$Res>
    implements $RecommendationCopyWith<$Res> {
  _$RecommendationCopyWithImpl(this._self, this._then);

  final Recommendation _self;
  final $Res Function(Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? ranking = null,Object? resolvingNothing = null,Object? best = freezed,Object? combo = freezed,Object? comboAdded = null,Object? leftOut = null,Object? rentOnly = null,Object? freeOnly = null,Object? elsewhere = null,Object? unavailable = null,Object? noData = null,Object? totalMine = null,Object? totalFriends = null,Object? pricesUpdatedAt = freezed,Object? anyEstimate = null,Object? headline = freezed,}) {
  return _then(Recommendation(
ranking: null == ranking ? _self.ranking : ranking // ignore: cast_nullable_to_non_nullable
as List<ProviderScore>,resolvingNothing: null == resolvingNothing ? _self.resolvingNothing : resolvingNothing // ignore: cast_nullable_to_non_nullable
as List<StreamingProvider>,best: freezed == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as ProviderScore?,combo: freezed == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as ProviderScore?,comboAdded: null == comboAdded ? _self.comboAdded : comboAdded // ignore: cast_nullable_to_non_nullable
as List<Candidate>,leftOut: null == leftOut ? _self.leftOut : leftOut // ignore: cast_nullable_to_non_nullable
as List<LeftOutTitle>,rentOnly: null == rentOnly ? _self.rentOnly : rentOnly // ignore: cast_nullable_to_non_nullable
as List<Candidate>,freeOnly: null == freeOnly ? _self.freeOnly : freeOnly // ignore: cast_nullable_to_non_nullable
as List<Candidate>,elsewhere: null == elsewhere ? _self.elsewhere : elsewhere // ignore: cast_nullable_to_non_nullable
as List<Candidate>,unavailable: null == unavailable ? _self.unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as List<Candidate>,noData: null == noData ? _self.noData : noData // ignore: cast_nullable_to_non_nullable
as List<Candidate>,totalMine: null == totalMine ? _self.totalMine : totalMine // ignore: cast_nullable_to_non_nullable
as int,totalFriends: null == totalFriends ? _self.totalFriends : totalFriends // ignore: cast_nullable_to_non_nullable
as int,pricesUpdatedAt: freezed == pricesUpdatedAt ? _self.pricesUpdatedAt : pricesUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,anyEstimate: null == anyEstimate ? _self.anyEstimate : anyEstimate // ignore: cast_nullable_to_non_nullable
as bool,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderScoreCopyWith<$Res>? get best {
    if (_self.best == null) {
    return null;
  }

  return $ProviderScoreCopyWith<$Res>(_self.best!, (value) {
    return _then(_self.copyWith(best: value));
  });
}/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderScoreCopyWith<$Res>? get combo {
    if (_self.combo == null) {
    return null;
  }

  return $ProviderScoreCopyWith<$Res>(_self.combo!, (value) {
    return _then(_self.copyWith(combo: value));
  });
}
}


/// Adds pattern-matching-related methods to [Recommendation].
extension RecommendationPatterns on Recommendation {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Recommendation value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Recommendation value)  $default,){
final _that = this;
switch (_that) {
case _Recommendation():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Recommendation value)?  $default,){
final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<ProviderScore> ranking,  List<StreamingProvider> resolvingNothing,  ProviderScore? best,  ProviderScore? combo,  List<Candidate> comboAdded,  List<LeftOutTitle> leftOut,  List<Candidate> rentOnly,  List<Candidate> freeOnly,  List<Candidate> elsewhere,  List<Candidate> unavailable,  List<Candidate> noData,  int totalMine,  int totalFriends,  DateTime? pricesUpdatedAt,  bool anyEstimate,  String? headline)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.ranking,_that.resolvingNothing,_that.best,_that.combo,_that.comboAdded,_that.leftOut,_that.rentOnly,_that.freeOnly,_that.elsewhere,_that.unavailable,_that.noData,_that.totalMine,_that.totalFriends,_that.pricesUpdatedAt,_that.anyEstimate,_that.headline);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<ProviderScore> ranking,  List<StreamingProvider> resolvingNothing,  ProviderScore? best,  ProviderScore? combo,  List<Candidate> comboAdded,  List<LeftOutTitle> leftOut,  List<Candidate> rentOnly,  List<Candidate> freeOnly,  List<Candidate> elsewhere,  List<Candidate> unavailable,  List<Candidate> noData,  int totalMine,  int totalFriends,  DateTime? pricesUpdatedAt,  bool anyEstimate,  String? headline)  $default,) {final _that = this;
switch (_that) {
case _Recommendation():
return $default(_that.ranking,_that.resolvingNothing,_that.best,_that.combo,_that.comboAdded,_that.leftOut,_that.rentOnly,_that.freeOnly,_that.elsewhere,_that.unavailable,_that.noData,_that.totalMine,_that.totalFriends,_that.pricesUpdatedAt,_that.anyEstimate,_that.headline);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<ProviderScore> ranking,  List<StreamingProvider> resolvingNothing,  ProviderScore? best,  ProviderScore? combo,  List<Candidate> comboAdded,  List<LeftOutTitle> leftOut,  List<Candidate> rentOnly,  List<Candidate> freeOnly,  List<Candidate> elsewhere,  List<Candidate> unavailable,  List<Candidate> noData,  int totalMine,  int totalFriends,  DateTime? pricesUpdatedAt,  bool anyEstimate,  String? headline)?  $default,) {final _that = this;
switch (_that) {
case _Recommendation() when $default != null:
return $default(_that.ranking,_that.resolvingNothing,_that.best,_that.combo,_that.comboAdded,_that.leftOut,_that.rentOnly,_that.freeOnly,_that.elsewhere,_that.unavailable,_that.noData,_that.totalMine,_that.totalFriends,_that.pricesUpdatedAt,_that.anyEstimate,_that.headline);case _:
  return null;

}
}

}

/// @nodoc


class _Recommendation extends Recommendation {
  const _Recommendation({ List<ProviderScore> ranking = const <ProviderScore>[],  List<StreamingProvider> resolvingNothing = const <StreamingProvider>[], this.best, this.combo,  List<Candidate> comboAdded = const <Candidate>[],  List<LeftOutTitle> leftOut = const <LeftOutTitle>[],  List<Candidate> rentOnly = const <Candidate>[],  List<Candidate> freeOnly = const <Candidate>[],  List<Candidate> elsewhere = const <Candidate>[],  List<Candidate> unavailable = const <Candidate>[],  List<Candidate> noData = const <Candidate>[], this.totalMine = 0, this.totalFriends = 0, this.pricesUpdatedAt, this.anyEstimate = false, this.headline}): _ranking = ranking,_resolvingNothing = resolvingNothing,_comboAdded = comboAdded,_leftOut = leftOut,_rentOnly = rentOnly,_freeOnly = freeOnly,_elsewhere = elsewhere,_unavailable = unavailable,_noData = noData,super._();
  

/// Só quem resolve ≥ 1 título, do melhor para o pior.
 final  List<ProviderScore> _ranking;
/// Só quem resolve ≥ 1 título, do melhor para o pior.
@override@JsonKey() List<ProviderScore> get ranking {
  if (_ranking is EqualUnmodifiableListView) return _ranking;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_ranking);
}

/// Streamings com preço que não resolvem nada (a tela lista os nomes).
 final  List<StreamingProvider> _resolvingNothing;
/// Streamings com preço que não resolvem nada (a tela lista os nomes).
@override@JsonKey() List<StreamingProvider> get resolvingNothing {
  if (_resolvingNothing is EqualUnmodifiableListView) return _resolvingNothing;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resolvingNothing);
}

@override final  ProviderScore? best;
/// Segundo streaming, só quando acrescenta ≥ 3 títulos e baixa o custo por título.
@override final  ProviderScore? combo;
 final  List<Candidate> _comboAdded;
@override@JsonKey() List<Candidate> get comboAdded {
  if (_comboAdded is EqualUnmodifiableListView) return _comboAdded;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_comboAdded);
}

/// Em assinatura, mas fora do(s) escolhido(s).
 final  List<LeftOutTitle> _leftOut;
/// Em assinatura, mas fora do(s) escolhido(s).
@override@JsonKey() List<LeftOutTitle> get leftOut {
  if (_leftOut is EqualUnmodifiableListView) return _leftOut;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_leftOut);
}

/// Só aluguel ou compra.
 final  List<Candidate> _rentOnly;
/// Só aluguel ou compra.
@override@JsonKey() List<Candidate> get rentOnly {
  if (_rentOnly is EqualUnmodifiableListView) return _rentOnly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rentOnly);
}

/// Já dá para ver grátis (não precisa assinar nada).
 final  List<Candidate> _freeOnly;
/// Já dá para ver grátis (não precisa assinar nada).
@override@JsonKey() List<Candidate> get freeOnly {
  if (_freeOnly is EqualUnmodifiableListView) return _freeOnly;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_freeOnly);
}

/// Só em streaming que não está na lista de preços.
 final  List<Candidate> _elsewhere;
/// Só em streaming que não está na lista de preços.
@override@JsonKey() List<Candidate> get elsewhere {
  if (_elsewhere is EqualUnmodifiableListView) return _elsewhere;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_elsewhere);
}

/// Cache consultado: em nenhum streaming no Brasil.
 final  List<Candidate> _unavailable;
/// Cache consultado: em nenhum streaming no Brasil.
@override@JsonKey() List<Candidate> get unavailable {
  if (_unavailable is EqualUnmodifiableListView) return _unavailable;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_unavailable);
}

/// Sem cache de "onde assistir": nunca chutar.
 final  List<Candidate> _noData;
/// Sem cache de "onde assistir": nunca chutar.
@override@JsonKey() List<Candidate> get noData {
  if (_noData is EqualUnmodifiableListView) return _noData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_noData);
}

@override@JsonKey() final  int totalMine;
@override@JsonKey() final  int totalFriends;
/// O `updated_at` mais recente entre os preços usados ("Preços de
/// DD/MM/AAAA"); preço velho tem aviso próprio em [ProviderScore.priceStale].
@override final  DateTime? pricesUpdatedAt;
@override@JsonKey() final  bool anyEstimate;
/// Frase final, legível. Null só quando não há candidato nenhum.
@override final  String? headline;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RecommendationCopyWith<_Recommendation> get copyWith => __$RecommendationCopyWithImpl<_Recommendation>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Recommendation&&const DeepCollectionEquality().equals(other._ranking, _ranking)&&const DeepCollectionEquality().equals(other._resolvingNothing, _resolvingNothing)&&(identical(other.best, best) || other.best == best)&&(identical(other.combo, combo) || other.combo == combo)&&const DeepCollectionEquality().equals(other._comboAdded, _comboAdded)&&const DeepCollectionEquality().equals(other._leftOut, _leftOut)&&const DeepCollectionEquality().equals(other._rentOnly, _rentOnly)&&const DeepCollectionEquality().equals(other._freeOnly, _freeOnly)&&const DeepCollectionEquality().equals(other._elsewhere, _elsewhere)&&const DeepCollectionEquality().equals(other._unavailable, _unavailable)&&const DeepCollectionEquality().equals(other._noData, _noData)&&(identical(other.totalMine, totalMine) || other.totalMine == totalMine)&&(identical(other.totalFriends, totalFriends) || other.totalFriends == totalFriends)&&(identical(other.pricesUpdatedAt, pricesUpdatedAt) || other.pricesUpdatedAt == pricesUpdatedAt)&&(identical(other.anyEstimate, anyEstimate) || other.anyEstimate == anyEstimate)&&(identical(other.headline, headline) || other.headline == headline));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_ranking),const DeepCollectionEquality().hash(_resolvingNothing),best,combo,const DeepCollectionEquality().hash(_comboAdded),const DeepCollectionEquality().hash(_leftOut),const DeepCollectionEquality().hash(_rentOnly),const DeepCollectionEquality().hash(_freeOnly),const DeepCollectionEquality().hash(_elsewhere),const DeepCollectionEquality().hash(_unavailable),const DeepCollectionEquality().hash(_noData),totalMine,totalFriends,pricesUpdatedAt,anyEstimate,headline);

@override
String toString() {
  return 'Recommendation(ranking: $ranking, resolvingNothing: $resolvingNothing, best: $best, combo: $combo, comboAdded: $comboAdded, leftOut: $leftOut, rentOnly: $rentOnly, freeOnly: $freeOnly, elsewhere: $elsewhere, unavailable: $unavailable, noData: $noData, totalMine: $totalMine, totalFriends: $totalFriends, pricesUpdatedAt: $pricesUpdatedAt, anyEstimate: $anyEstimate, headline: $headline)';
}


}

/// @nodoc
abstract mixin class _$RecommendationCopyWith<$Res> implements $RecommendationCopyWith<$Res> {
  factory _$RecommendationCopyWith(_Recommendation value, $Res Function(_Recommendation) _then) = __$RecommendationCopyWithImpl;
@override @useResult
$Res call({
 List<ProviderScore> ranking, List<StreamingProvider> resolvingNothing, ProviderScore? best, ProviderScore? combo, List<Candidate> comboAdded, List<LeftOutTitle> leftOut, List<Candidate> rentOnly, List<Candidate> freeOnly, List<Candidate> elsewhere, List<Candidate> unavailable, List<Candidate> noData, int totalMine, int totalFriends, DateTime? pricesUpdatedAt, bool anyEstimate, String? headline
});


@override $ProviderScoreCopyWith<$Res>? get best;@override $ProviderScoreCopyWith<$Res>? get combo;

}
/// @nodoc
class __$RecommendationCopyWithImpl<$Res>
    implements _$RecommendationCopyWith<$Res> {
  __$RecommendationCopyWithImpl(this._self, this._then);

  final _Recommendation _self;
  final $Res Function(_Recommendation) _then;

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? ranking = null,Object? resolvingNothing = null,Object? best = freezed,Object? combo = freezed,Object? comboAdded = null,Object? leftOut = null,Object? rentOnly = null,Object? freeOnly = null,Object? elsewhere = null,Object? unavailable = null,Object? noData = null,Object? totalMine = null,Object? totalFriends = null,Object? pricesUpdatedAt = freezed,Object? anyEstimate = null,Object? headline = freezed,}) {
  return _then(_Recommendation(
ranking: null == ranking ? _self._ranking : ranking // ignore: cast_nullable_to_non_nullable
as List<ProviderScore>,resolvingNothing: null == resolvingNothing ? _self._resolvingNothing : resolvingNothing // ignore: cast_nullable_to_non_nullable
as List<StreamingProvider>,best: freezed == best ? _self.best : best // ignore: cast_nullable_to_non_nullable
as ProviderScore?,combo: freezed == combo ? _self.combo : combo // ignore: cast_nullable_to_non_nullable
as ProviderScore?,comboAdded: null == comboAdded ? _self._comboAdded : comboAdded // ignore: cast_nullable_to_non_nullable
as List<Candidate>,leftOut: null == leftOut ? _self._leftOut : leftOut // ignore: cast_nullable_to_non_nullable
as List<LeftOutTitle>,rentOnly: null == rentOnly ? _self._rentOnly : rentOnly // ignore: cast_nullable_to_non_nullable
as List<Candidate>,freeOnly: null == freeOnly ? _self._freeOnly : freeOnly // ignore: cast_nullable_to_non_nullable
as List<Candidate>,elsewhere: null == elsewhere ? _self._elsewhere : elsewhere // ignore: cast_nullable_to_non_nullable
as List<Candidate>,unavailable: null == unavailable ? _self._unavailable : unavailable // ignore: cast_nullable_to_non_nullable
as List<Candidate>,noData: null == noData ? _self._noData : noData // ignore: cast_nullable_to_non_nullable
as List<Candidate>,totalMine: null == totalMine ? _self.totalMine : totalMine // ignore: cast_nullable_to_non_nullable
as int,totalFriends: null == totalFriends ? _self.totalFriends : totalFriends // ignore: cast_nullable_to_non_nullable
as int,pricesUpdatedAt: freezed == pricesUpdatedAt ? _self.pricesUpdatedAt : pricesUpdatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,anyEstimate: null == anyEstimate ? _self.anyEstimate : anyEstimate // ignore: cast_nullable_to_non_nullable
as bool,headline: freezed == headline ? _self.headline : headline // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderScoreCopyWith<$Res>? get best {
    if (_self.best == null) {
    return null;
  }

  return $ProviderScoreCopyWith<$Res>(_self.best!, (value) {
    return _then(_self.copyWith(best: value));
  });
}/// Create a copy of Recommendation
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$ProviderScoreCopyWith<$Res>? get combo {
    if (_self.combo == null) {
    return null;
  }

  return $ProviderScoreCopyWith<$Res>(_self.combo!, (value) {
    return _then(_self.copyWith(combo: value));
  });
}
}

// dart format on
