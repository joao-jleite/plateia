// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ProviderPrice _$ProviderPriceFromJson(Map<String, dynamic> json) =>
    _ProviderPrice(
      providerId: (json['provider_id'] as num).toInt(),
      plan: $enumDecode(_$PricePlanEnumMap, json['plan']),
      planLabel: json['plan_label'] as String,
      priceCents: (json['price_cents'] as num).toInt(),
      currency: json['currency'] as String? ?? 'BRL',
      isEstimate: json['is_estimate'] as bool? ?? true,
      sourceUrl: json['source_url'] as String?,
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );

Map<String, dynamic> _$ProviderPriceToJson(_ProviderPrice instance) =>
    <String, dynamic>{
      'provider_id': instance.providerId,
      'plan': _$PricePlanEnumMap[instance.plan]!,
      'plan_label': instance.planLabel,
      'price_cents': instance.priceCents,
      'currency': instance.currency,
      'is_estimate': instance.isEstimate,
      'source_url': ?instance.sourceUrl,
      'updated_at': instance.updatedAt.toIso8601String(),
    };

const _$PricePlanEnumMap = {
  PricePlan.ads: 'ads',
  PricePlan.standard: 'standard',
  PricePlan.premium: 'premium',
};

_UserSubscription _$UserSubscriptionFromJson(Map<String, dynamic> json) =>
    _UserSubscription(
      userId: json['user_id'] as String,
      providerId: (json['provider_id'] as num).toInt(),
      plan: $enumDecodeNullable(_$PricePlanEnumMap, json['plan']),
      priceCents: (json['price_cents'] as num?)?.toInt(),
      startedOn: json['started_on'] == null
          ? null
          : DateTime.parse(json['started_on'] as String),
      renewsOn: json['renews_on'] == null
          ? null
          : DateTime.parse(json['renews_on'] as String),
      remindBeforeRenewal: json['remind_before_renewal'] as bool? ?? true,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] == null
          ? null
          : DateTime.parse(json['updated_at'] as String),
      provider: json['provider'] == null
          ? null
          : StreamingProvider.fromJson(
              json['provider'] as Map<String, dynamic>,
            ),
    );

Map<String, dynamic> _$UserSubscriptionToJson(_UserSubscription instance) =>
    <String, dynamic>{
      'user_id': instance.userId,
      'provider_id': instance.providerId,
      'plan': ?_$PricePlanEnumMap[instance.plan],
      'price_cents': ?instance.priceCents,
      'started_on': ?instance.startedOn?.toIso8601String(),
      'renews_on': ?instance.renewsOn?.toIso8601String(),
      'remind_before_renewal': instance.remindBeforeRenewal,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'updated_at': ?instance.updatedAt?.toIso8601String(),
      'provider': ?instance.provider?.toJson(),
    };
