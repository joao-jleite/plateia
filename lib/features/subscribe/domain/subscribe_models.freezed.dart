// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint, type=warning, deprecated_member_use, deprecated_member_use_from_same_package
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'subscribe_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ProviderPrice {

 int get providerId; PricePlan get plan; String get planLabel; int get priceCents; String get currency; bool get isEstimate; String? get sourceUrl; DateTime get updatedAt;
/// Create a copy of ProviderPrice
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProviderPriceCopyWith<ProviderPrice> get copyWith => _$ProviderPriceCopyWithImpl<ProviderPrice>(this as ProviderPrice, _$identity);

  /// Serializes this ProviderPrice to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProviderPrice&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.planLabel, planLabel) || other.planLabel == planLabel)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isEstimate, isEstimate) || other.isEstimate == isEstimate)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,plan,planLabel,priceCents,currency,isEstimate,sourceUrl,updatedAt);

@override
String toString() {
  return 'ProviderPrice(providerId: $providerId, plan: $plan, planLabel: $planLabel, priceCents: $priceCents, currency: $currency, isEstimate: $isEstimate, sourceUrl: $sourceUrl, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ProviderPriceCopyWith<$Res>  {
  factory $ProviderPriceCopyWith(ProviderPrice value, $Res Function(ProviderPrice) _then) = _$ProviderPriceCopyWithImpl;
@useResult
$Res call({
 int providerId, PricePlan plan, String planLabel, int priceCents, String currency, bool isEstimate, String? sourceUrl, DateTime updatedAt
});




}
/// @nodoc
class _$ProviderPriceCopyWithImpl<$Res>
    implements $ProviderPriceCopyWith<$Res> {
  _$ProviderPriceCopyWithImpl(this._self, this._then);

  final ProviderPrice _self;
  final $Res Function(ProviderPrice) _then;

/// Create a copy of ProviderPrice
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? plan = null,Object? planLabel = null,Object? priceCents = null,Object? currency = null,Object? isEstimate = null,Object? sourceUrl = freezed,Object? updatedAt = null,}) {
  return _then(ProviderPrice(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PricePlan,planLabel: null == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isEstimate: null == isEstimate ? _self.isEstimate : isEstimate // ignore: cast_nullable_to_non_nullable
as bool,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}

}


/// Adds pattern-matching-related methods to [ProviderPrice].
extension ProviderPricePatterns on ProviderPrice {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProviderPrice value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProviderPrice() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProviderPrice value)  $default,){
final _that = this;
switch (_that) {
case _ProviderPrice():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProviderPrice value)?  $default,){
final _that = this;
switch (_that) {
case _ProviderPrice() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int providerId,  PricePlan plan,  String planLabel,  int priceCents,  String currency,  bool isEstimate,  String? sourceUrl,  DateTime updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProviderPrice() when $default != null:
return $default(_that.providerId,_that.plan,_that.planLabel,_that.priceCents,_that.currency,_that.isEstimate,_that.sourceUrl,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int providerId,  PricePlan plan,  String planLabel,  int priceCents,  String currency,  bool isEstimate,  String? sourceUrl,  DateTime updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ProviderPrice():
return $default(_that.providerId,_that.plan,_that.planLabel,_that.priceCents,_that.currency,_that.isEstimate,_that.sourceUrl,_that.updatedAt);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int providerId,  PricePlan plan,  String planLabel,  int priceCents,  String currency,  bool isEstimate,  String? sourceUrl,  DateTime updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ProviderPrice() when $default != null:
return $default(_that.providerId,_that.plan,_that.planLabel,_that.priceCents,_that.currency,_that.isEstimate,_that.sourceUrl,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ProviderPrice extends ProviderPrice {
  const _ProviderPrice({required this.providerId, required this.plan, required this.planLabel, required this.priceCents, this.currency = 'BRL', this.isEstimate = true, this.sourceUrl, required this.updatedAt}): super._();
  factory _ProviderPrice.fromJson(Map<String, dynamic> json) => _$ProviderPriceFromJson(json);

@override final  int providerId;
@override final  PricePlan plan;
@override final  String planLabel;
@override final  int priceCents;
@override@JsonKey() final  String currency;
@override@JsonKey() final  bool isEstimate;
@override final  String? sourceUrl;
@override final  DateTime updatedAt;

/// Create a copy of ProviderPrice
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProviderPriceCopyWith<_ProviderPrice> get copyWith => __$ProviderPriceCopyWithImpl<_ProviderPrice>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ProviderPriceToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProviderPrice&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.planLabel, planLabel) || other.planLabel == planLabel)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.currency, currency) || other.currency == currency)&&(identical(other.isEstimate, isEstimate) || other.isEstimate == isEstimate)&&(identical(other.sourceUrl, sourceUrl) || other.sourceUrl == sourceUrl)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,providerId,plan,planLabel,priceCents,currency,isEstimate,sourceUrl,updatedAt);

@override
String toString() {
  return 'ProviderPrice(providerId: $providerId, plan: $plan, planLabel: $planLabel, priceCents: $priceCents, currency: $currency, isEstimate: $isEstimate, sourceUrl: $sourceUrl, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ProviderPriceCopyWith<$Res> implements $ProviderPriceCopyWith<$Res> {
  factory _$ProviderPriceCopyWith(_ProviderPrice value, $Res Function(_ProviderPrice) _then) = __$ProviderPriceCopyWithImpl;
@override @useResult
$Res call({
 int providerId, PricePlan plan, String planLabel, int priceCents, String currency, bool isEstimate, String? sourceUrl, DateTime updatedAt
});




}
/// @nodoc
class __$ProviderPriceCopyWithImpl<$Res>
    implements _$ProviderPriceCopyWith<$Res> {
  __$ProviderPriceCopyWithImpl(this._self, this._then);

  final _ProviderPrice _self;
  final $Res Function(_ProviderPrice) _then;

/// Create a copy of ProviderPrice
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? plan = null,Object? planLabel = null,Object? priceCents = null,Object? currency = null,Object? isEstimate = null,Object? sourceUrl = freezed,Object? updatedAt = null,}) {
  return _then(_ProviderPrice(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,plan: null == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PricePlan,planLabel: null == planLabel ? _self.planLabel : planLabel // ignore: cast_nullable_to_non_nullable
as String,priceCents: null == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int,currency: null == currency ? _self.currency : currency // ignore: cast_nullable_to_non_nullable
as String,isEstimate: null == isEstimate ? _self.isEstimate : isEstimate // ignore: cast_nullable_to_non_nullable
as bool,sourceUrl: freezed == sourceUrl ? _self.sourceUrl : sourceUrl // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,
  ));
}


}


/// @nodoc
mixin _$UserSubscription {

 String get userId; int get providerId; PricePlan? get plan; int? get priceCents; DateTime? get startedOn; DateTime? get renewsOn; bool get remindBeforeRenewal; DateTime? get createdAt; DateTime? get updatedAt; StreamingProvider? get provider;
/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserSubscriptionCopyWith<UserSubscription> get copyWith => _$UserSubscriptionCopyWithImpl<UserSubscription>(this as UserSubscription, _$identity);

  /// Serializes this UserSubscription to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserSubscription&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.startedOn, startedOn) || other.startedOn == startedOn)&&(identical(other.renewsOn, renewsOn) || other.renewsOn == renewsOn)&&(identical(other.remindBeforeRenewal, remindBeforeRenewal) || other.remindBeforeRenewal == remindBeforeRenewal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,providerId,plan,priceCents,startedOn,renewsOn,remindBeforeRenewal,createdAt,updatedAt,provider);

@override
String toString() {
  return 'UserSubscription(userId: $userId, providerId: $providerId, plan: $plan, priceCents: $priceCents, startedOn: $startedOn, renewsOn: $renewsOn, remindBeforeRenewal: $remindBeforeRenewal, createdAt: $createdAt, updatedAt: $updatedAt, provider: $provider)';
}


}

/// @nodoc
abstract mixin class $UserSubscriptionCopyWith<$Res>  {
  factory $UserSubscriptionCopyWith(UserSubscription value, $Res Function(UserSubscription) _then) = _$UserSubscriptionCopyWithImpl;
@useResult
$Res call({
 String userId, int providerId, PricePlan? plan, int? priceCents, DateTime? startedOn, DateTime? renewsOn, bool remindBeforeRenewal, DateTime? createdAt, DateTime? updatedAt, StreamingProvider? provider
});


$StreamingProviderCopyWith<$Res>? get provider;

}
/// @nodoc
class _$UserSubscriptionCopyWithImpl<$Res>
    implements $UserSubscriptionCopyWith<$Res> {
  _$UserSubscriptionCopyWithImpl(this._self, this._then);

  final UserSubscription _self;
  final $Res Function(UserSubscription) _then;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? userId = null,Object? providerId = null,Object? plan = freezed,Object? priceCents = freezed,Object? startedOn = freezed,Object? renewsOn = freezed,Object? remindBeforeRenewal = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? provider = freezed,}) {
  return _then(UserSubscription(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PricePlan?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,startedOn: freezed == startedOn ? _self.startedOn : startedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,renewsOn: freezed == renewsOn ? _self.renewsOn : renewsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,remindBeforeRenewal: null == remindBeforeRenewal ? _self.remindBeforeRenewal : remindBeforeRenewal // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as StreamingProvider?,
  ));
}
/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamingProviderCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $StreamingProviderCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}
}


/// Adds pattern-matching-related methods to [UserSubscription].
extension UserSubscriptionPatterns on UserSubscription {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserSubscription value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserSubscription value)  $default,){
final _that = this;
switch (_that) {
case _UserSubscription():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserSubscription value)?  $default,){
final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String userId,  int providerId,  PricePlan? plan,  int? priceCents,  DateTime? startedOn,  DateTime? renewsOn,  bool remindBeforeRenewal,  DateTime? createdAt,  DateTime? updatedAt,  StreamingProvider? provider)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
return $default(_that.userId,_that.providerId,_that.plan,_that.priceCents,_that.startedOn,_that.renewsOn,_that.remindBeforeRenewal,_that.createdAt,_that.updatedAt,_that.provider);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String userId,  int providerId,  PricePlan? plan,  int? priceCents,  DateTime? startedOn,  DateTime? renewsOn,  bool remindBeforeRenewal,  DateTime? createdAt,  DateTime? updatedAt,  StreamingProvider? provider)  $default,) {final _that = this;
switch (_that) {
case _UserSubscription():
return $default(_that.userId,_that.providerId,_that.plan,_that.priceCents,_that.startedOn,_that.renewsOn,_that.remindBeforeRenewal,_that.createdAt,_that.updatedAt,_that.provider);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String userId,  int providerId,  PricePlan? plan,  int? priceCents,  DateTime? startedOn,  DateTime? renewsOn,  bool remindBeforeRenewal,  DateTime? createdAt,  DateTime? updatedAt,  StreamingProvider? provider)?  $default,) {final _that = this;
switch (_that) {
case _UserSubscription() when $default != null:
return $default(_that.userId,_that.providerId,_that.plan,_that.priceCents,_that.startedOn,_that.renewsOn,_that.remindBeforeRenewal,_that.createdAt,_that.updatedAt,_that.provider);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserSubscription extends UserSubscription {
  const _UserSubscription({required this.userId, required this.providerId, this.plan, this.priceCents, this.startedOn, this.renewsOn, this.remindBeforeRenewal = true, this.createdAt, this.updatedAt, this.provider}): super._();
  factory _UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);

@override final  String userId;
@override final  int providerId;
@override final  PricePlan? plan;
@override final  int? priceCents;
@override final  DateTime? startedOn;
@override final  DateTime? renewsOn;
@override@JsonKey() final  bool remindBeforeRenewal;
@override final  DateTime? createdAt;
@override final  DateTime? updatedAt;
@override final  StreamingProvider? provider;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserSubscriptionCopyWith<_UserSubscription> get copyWith => __$UserSubscriptionCopyWithImpl<_UserSubscription>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserSubscriptionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserSubscription&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.startedOn, startedOn) || other.startedOn == startedOn)&&(identical(other.renewsOn, renewsOn) || other.renewsOn == renewsOn)&&(identical(other.remindBeforeRenewal, remindBeforeRenewal) || other.remindBeforeRenewal == remindBeforeRenewal)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.provider, provider) || other.provider == provider));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,userId,providerId,plan,priceCents,startedOn,renewsOn,remindBeforeRenewal,createdAt,updatedAt,provider);

@override
String toString() {
  return 'UserSubscription(userId: $userId, providerId: $providerId, plan: $plan, priceCents: $priceCents, startedOn: $startedOn, renewsOn: $renewsOn, remindBeforeRenewal: $remindBeforeRenewal, createdAt: $createdAt, updatedAt: $updatedAt, provider: $provider)';
}


}

/// @nodoc
abstract mixin class _$UserSubscriptionCopyWith<$Res> implements $UserSubscriptionCopyWith<$Res> {
  factory _$UserSubscriptionCopyWith(_UserSubscription value, $Res Function(_UserSubscription) _then) = __$UserSubscriptionCopyWithImpl;
@override @useResult
$Res call({
 String userId, int providerId, PricePlan? plan, int? priceCents, DateTime? startedOn, DateTime? renewsOn, bool remindBeforeRenewal, DateTime? createdAt, DateTime? updatedAt, StreamingProvider? provider
});


@override $StreamingProviderCopyWith<$Res>? get provider;

}
/// @nodoc
class __$UserSubscriptionCopyWithImpl<$Res>
    implements _$UserSubscriptionCopyWith<$Res> {
  __$UserSubscriptionCopyWithImpl(this._self, this._then);

  final _UserSubscription _self;
  final $Res Function(_UserSubscription) _then;

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? userId = null,Object? providerId = null,Object? plan = freezed,Object? priceCents = freezed,Object? startedOn = freezed,Object? renewsOn = freezed,Object? remindBeforeRenewal = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? provider = freezed,}) {
  return _then(_UserSubscription(
userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PricePlan?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,startedOn: freezed == startedOn ? _self.startedOn : startedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,renewsOn: freezed == renewsOn ? _self.renewsOn : renewsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,remindBeforeRenewal: null == remindBeforeRenewal ? _self.remindBeforeRenewal : remindBeforeRenewal // ignore: cast_nullable_to_non_nullable
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime?,provider: freezed == provider ? _self.provider : provider // ignore: cast_nullable_to_non_nullable
as StreamingProvider?,
  ));
}

/// Create a copy of UserSubscription
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$StreamingProviderCopyWith<$Res>? get provider {
    if (_self.provider == null) {
    return null;
  }

  return $StreamingProviderCopyWith<$Res>(_self.provider!, (value) {
    return _then(_self.copyWith(provider: value));
  });
}
}

/// @nodoc
mixin _$SubscriptionDraft {

 int get providerId; PricePlan? get plan; int? get priceCents; DateTime? get startedOn; DateTime? get renewsOn; bool get remindBeforeRenewal;
/// Create a copy of SubscriptionDraft
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SubscriptionDraftCopyWith<SubscriptionDraft> get copyWith => _$SubscriptionDraftCopyWithImpl<SubscriptionDraft>(this as SubscriptionDraft, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SubscriptionDraft&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.startedOn, startedOn) || other.startedOn == startedOn)&&(identical(other.renewsOn, renewsOn) || other.renewsOn == renewsOn)&&(identical(other.remindBeforeRenewal, remindBeforeRenewal) || other.remindBeforeRenewal == remindBeforeRenewal));
}


@override
int get hashCode => Object.hash(runtimeType,providerId,plan,priceCents,startedOn,renewsOn,remindBeforeRenewal);

@override
String toString() {
  return 'SubscriptionDraft(providerId: $providerId, plan: $plan, priceCents: $priceCents, startedOn: $startedOn, renewsOn: $renewsOn, remindBeforeRenewal: $remindBeforeRenewal)';
}


}

/// @nodoc
abstract mixin class $SubscriptionDraftCopyWith<$Res>  {
  factory $SubscriptionDraftCopyWith(SubscriptionDraft value, $Res Function(SubscriptionDraft) _then) = _$SubscriptionDraftCopyWithImpl;
@useResult
$Res call({
 int providerId, PricePlan? plan, int? priceCents, DateTime? startedOn, DateTime? renewsOn, bool remindBeforeRenewal
});




}
/// @nodoc
class _$SubscriptionDraftCopyWithImpl<$Res>
    implements $SubscriptionDraftCopyWith<$Res> {
  _$SubscriptionDraftCopyWithImpl(this._self, this._then);

  final SubscriptionDraft _self;
  final $Res Function(SubscriptionDraft) _then;

/// Create a copy of SubscriptionDraft
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? providerId = null,Object? plan = freezed,Object? priceCents = freezed,Object? startedOn = freezed,Object? renewsOn = freezed,Object? remindBeforeRenewal = null,}) {
  return _then(SubscriptionDraft(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PricePlan?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,startedOn: freezed == startedOn ? _self.startedOn : startedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,renewsOn: freezed == renewsOn ? _self.renewsOn : renewsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,remindBeforeRenewal: null == remindBeforeRenewal ? _self.remindBeforeRenewal : remindBeforeRenewal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [SubscriptionDraft].
extension SubscriptionDraftPatterns on SubscriptionDraft {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SubscriptionDraft value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SubscriptionDraft() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SubscriptionDraft value)  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDraft():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SubscriptionDraft value)?  $default,){
final _that = this;
switch (_that) {
case _SubscriptionDraft() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int providerId,  PricePlan? plan,  int? priceCents,  DateTime? startedOn,  DateTime? renewsOn,  bool remindBeforeRenewal)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SubscriptionDraft() when $default != null:
return $default(_that.providerId,_that.plan,_that.priceCents,_that.startedOn,_that.renewsOn,_that.remindBeforeRenewal);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int providerId,  PricePlan? plan,  int? priceCents,  DateTime? startedOn,  DateTime? renewsOn,  bool remindBeforeRenewal)  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDraft():
return $default(_that.providerId,_that.plan,_that.priceCents,_that.startedOn,_that.renewsOn,_that.remindBeforeRenewal);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int providerId,  PricePlan? plan,  int? priceCents,  DateTime? startedOn,  DateTime? renewsOn,  bool remindBeforeRenewal)?  $default,) {final _that = this;
switch (_that) {
case _SubscriptionDraft() when $default != null:
return $default(_that.providerId,_that.plan,_that.priceCents,_that.startedOn,_that.renewsOn,_that.remindBeforeRenewal);case _:
  return null;

}
}

}

/// @nodoc


class _SubscriptionDraft implements SubscriptionDraft {
  const _SubscriptionDraft({required this.providerId, this.plan, this.priceCents, this.startedOn, this.renewsOn, this.remindBeforeRenewal = true});
  

@override final  int providerId;
@override final  PricePlan? plan;
@override final  int? priceCents;
@override final  DateTime? startedOn;
@override final  DateTime? renewsOn;
@override@JsonKey() final  bool remindBeforeRenewal;

/// Create a copy of SubscriptionDraft
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SubscriptionDraftCopyWith<_SubscriptionDraft> get copyWith => __$SubscriptionDraftCopyWithImpl<_SubscriptionDraft>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SubscriptionDraft&&(identical(other.providerId, providerId) || other.providerId == providerId)&&(identical(other.plan, plan) || other.plan == plan)&&(identical(other.priceCents, priceCents) || other.priceCents == priceCents)&&(identical(other.startedOn, startedOn) || other.startedOn == startedOn)&&(identical(other.renewsOn, renewsOn) || other.renewsOn == renewsOn)&&(identical(other.remindBeforeRenewal, remindBeforeRenewal) || other.remindBeforeRenewal == remindBeforeRenewal));
}


@override
int get hashCode => Object.hash(runtimeType,providerId,plan,priceCents,startedOn,renewsOn,remindBeforeRenewal);

@override
String toString() {
  return 'SubscriptionDraft(providerId: $providerId, plan: $plan, priceCents: $priceCents, startedOn: $startedOn, renewsOn: $renewsOn, remindBeforeRenewal: $remindBeforeRenewal)';
}


}

/// @nodoc
abstract mixin class _$SubscriptionDraftCopyWith<$Res> implements $SubscriptionDraftCopyWith<$Res> {
  factory _$SubscriptionDraftCopyWith(_SubscriptionDraft value, $Res Function(_SubscriptionDraft) _then) = __$SubscriptionDraftCopyWithImpl;
@override @useResult
$Res call({
 int providerId, PricePlan? plan, int? priceCents, DateTime? startedOn, DateTime? renewsOn, bool remindBeforeRenewal
});




}
/// @nodoc
class __$SubscriptionDraftCopyWithImpl<$Res>
    implements _$SubscriptionDraftCopyWith<$Res> {
  __$SubscriptionDraftCopyWithImpl(this._self, this._then);

  final _SubscriptionDraft _self;
  final $Res Function(_SubscriptionDraft) _then;

/// Create a copy of SubscriptionDraft
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? providerId = null,Object? plan = freezed,Object? priceCents = freezed,Object? startedOn = freezed,Object? renewsOn = freezed,Object? remindBeforeRenewal = null,}) {
  return _then(_SubscriptionDraft(
providerId: null == providerId ? _self.providerId : providerId // ignore: cast_nullable_to_non_nullable
as int,plan: freezed == plan ? _self.plan : plan // ignore: cast_nullable_to_non_nullable
as PricePlan?,priceCents: freezed == priceCents ? _self.priceCents : priceCents // ignore: cast_nullable_to_non_nullable
as int?,startedOn: freezed == startedOn ? _self.startedOn : startedOn // ignore: cast_nullable_to_non_nullable
as DateTime?,renewsOn: freezed == renewsOn ? _self.renewsOn : renewsOn // ignore: cast_nullable_to_non_nullable
as DateTime?,remindBeforeRenewal: null == remindBeforeRenewal ? _self.remindBeforeRenewal : remindBeforeRenewal // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on
