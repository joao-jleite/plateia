import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/domain/catalog_models.dart';

part 'subscribe_models.freezed.dart';
part 'subscribe_models.g.dart';

/// `provider_prices.plan` / `user_subscriptions.plan` (SPEC §5.9).
enum PricePlan {
  @JsonValue('ads')
  ads,
  @JsonValue('standard')
  standard,
  @JsonValue('premium')
  premium;

  String get dbValue => name;

  String get labelPtBr => switch (this) {
        PricePlan.ads => 'Com anúncios',
        PricePlan.standard => 'Padrão',
        PricePlan.premium => 'Premium',
      };

  static PricePlan? tryParse(String? value) => switch (value) {
        'ads' => PricePlan.ads,
        'standard' => PricePlan.standard,
        'premium' => PricePlan.premium,
        _ => null,
      };
}

/// Linha de `public.provider_prices`: preço mensal de um plano. Editado só
/// pelo João (dashboard); o app lê. `isEstimate` fica true até ele conferir.
@freezed
abstract class ProviderPrice with _$ProviderPrice {
  const ProviderPrice._();

  const factory ProviderPrice({
    required int providerId,
    required PricePlan plan,
    required String planLabel,
    required int priceCents,
    @Default('BRL') String currency,
    @Default(true) bool isEstimate,
    String? sourceUrl,
    required DateTime updatedAt,
  }) = _ProviderPrice;

  factory ProviderPrice.fromJson(Map<String, dynamic> json) => _$ProviderPriceFromJson(json);

  /// Preço com mais de 60 dias merece aviso na tela (prompt da fase 07).
  bool isStale(DateTime now) => now.difference(updatedAt).inDays > staleAfterDays;

  static const staleAfterDays = 60;
}

/// Linha de `public.user_subscriptions` com o streaming embutido
/// (`select('*, provider:providers(*)')`). Só o dono lê.
@freezed
abstract class UserSubscription with _$UserSubscription {
  const UserSubscription._();

  const factory UserSubscription({
    required String userId,
    required int providerId,
    PricePlan? plan,
    int? priceCents,
    DateTime? startedOn,
    DateTime? renewsOn,
    @Default(true) bool remindBeforeRenewal,
    DateTime? createdAt,
    DateTime? updatedAt,
    StreamingProvider? provider,
  }) = _UserSubscription;

  factory UserSubscription.fromJson(Map<String, dynamic> json) => _$UserSubscriptionFromJson(json);

  /// Lembrete só faz sentido com data e com a chave ligada.
  bool get wantsReminder => remindBeforeRenewal && renewsOn != null;
}

/// O que a tela Meus streamings manda gravar (upsert em `(user_id, provider_id)`).
@freezed
abstract class SubscriptionDraft with _$SubscriptionDraft {
  const factory SubscriptionDraft({
    required int providerId,
    PricePlan? plan,
    int? priceCents,
    DateTime? startedOn,
    DateTime? renewsOn,
    @Default(true) bool remindBeforeRenewal,
  }) = _SubscriptionDraft;

  /// Rascunho a partir da assinatura existente (ou os padrões para uma nova:
  /// plano padrão, renova daqui a 30 dias, lembrete ligado).
  factory SubscriptionDraft.from(UserSubscription? current, {required int providerId, required DateTime today}) {
    if (current == null) {
      return SubscriptionDraft(
        providerId: providerId,
        plan: PricePlan.standard,
        renewsOn: DateTime(today.year, today.month, today.day).add(const Duration(days: 30)),
      );
    }
    return SubscriptionDraft(
      providerId: current.providerId,
      plan: current.plan,
      priceCents: current.priceCents,
      startedOn: current.startedOn,
      renewsOn: current.renewsOn,
      remindBeforeRenewal: current.remindBeforeRenewal,
    );
  }
}
