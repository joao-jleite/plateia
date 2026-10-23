// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscribe_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

@ProviderFor(subscribeRepository)
final subscribeRepositoryProvider = SubscribeRepositoryProvider._();

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

final class SubscribeRepositoryProvider
    extends
        $FunctionalProvider<
          SubscribeRepository,
          SubscribeRepository,
          SubscribeRepository
        >
    with $Provider<SubscribeRepository> {
  /// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
  SubscribeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscribeRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscribeRepositoryHash();

  @$internal
  @override
  $ProviderElement<SubscribeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  SubscribeRepository create(Ref ref) {
    return subscribeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SubscribeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SubscribeRepository>(value),
    );
  }
}

String _$subscribeRepositoryHash() =>
    r'f6751e4076569b76c7a59f1e6b98ad978eef9fdd';

/// Lembrete local. Nos testes de widget é um [RecordingReminderScheduler]
/// (`pumpScreen`); no app, o real, que ao toque na notificação abre Meus streamings.

@ProviderFor(reminderScheduler)
final reminderSchedulerProvider = ReminderSchedulerProvider._();

/// Lembrete local. Nos testes de widget é um [RecordingReminderScheduler]
/// (`pumpScreen`); no app, o real, que ao toque na notificação abre Meus streamings.

final class ReminderSchedulerProvider
    extends
        $FunctionalProvider<
          ReminderScheduler,
          ReminderScheduler,
          ReminderScheduler
        >
    with $Provider<ReminderScheduler> {
  /// Lembrete local. Nos testes de widget é um [RecordingReminderScheduler]
  /// (`pumpScreen`); no app, o real, que ao toque na notificação abre Meus streamings.
  ReminderSchedulerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reminderSchedulerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reminderSchedulerHash();

  @$internal
  @override
  $ProviderElement<ReminderScheduler> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReminderScheduler create(Ref ref) {
    return reminderScheduler(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReminderScheduler value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReminderScheduler>(value),
    );
  }
}

String _$reminderSchedulerHash() => r'19a12995e8f30b163928b92e2685469c9394e8bc';

/// Chave "aceito plano com anúncios" (SPEC §5.9). Vive enquanto o app vive:
/// ainda não há preferência local persistida (decisão da fase 07, ▶).

@ProviderFor(AcceptAds)
final acceptAdsProvider = AcceptAdsProvider._();

/// Chave "aceito plano com anúncios" (SPEC §5.9). Vive enquanto o app vive:
/// ainda não há preferência local persistida (decisão da fase 07, ▶).
final class AcceptAdsProvider extends $NotifierProvider<AcceptAds, bool> {
  /// Chave "aceito plano com anúncios" (SPEC §5.9). Vive enquanto o app vive:
  /// ainda não há preferência local persistida (decisão da fase 07, ▶).
  AcceptAdsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'acceptAdsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$acceptAdsHash();

  @$internal
  @override
  AcceptAds create() => AcceptAds();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$acceptAdsHash() => r'8bb602de83d13faa4b2d5c8658d96692f1d307fa';

/// Chave "aceito plano com anúncios" (SPEC §5.9). Vive enquanto o app vive:
/// ainda não há preferência local persistida (decisão da fase 07, ▶).

abstract class _$AcceptAds extends $Notifier<bool> {
  bool build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<bool, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<bool, bool>,
              bool,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Sobe a cada gravação em `user_subscriptions`; a recomendação observa.

@ProviderFor(SubscriptionsVersion)
final subscriptionsVersionProvider = SubscriptionsVersionProvider._();

/// Sobe a cada gravação em `user_subscriptions`; a recomendação observa.
final class SubscriptionsVersionProvider
    extends $NotifierProvider<SubscriptionsVersion, int> {
  /// Sobe a cada gravação em `user_subscriptions`; a recomendação observa.
  SubscriptionsVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'subscriptionsVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$subscriptionsVersionHash();

  @$internal
  @override
  SubscriptionsVersion create() => SubscriptionsVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$subscriptionsVersionHash() =>
    r'7b0338919af779dbaf785dc4bea3b474134a54c1';

/// Sobe a cada gravação em `user_subscriptions`; a recomendação observa.

abstract class _$SubscriptionsVersion extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Preços de tabela. keepAlive: mudam só pelo dashboard; puxar para atualizar invalida.

@ProviderFor(providerPrices)
final providerPricesProvider = ProviderPricesProvider._();

/// Preços de tabela. keepAlive: mudam só pelo dashboard; puxar para atualizar invalida.

final class ProviderPricesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ProviderPrice>>,
          List<ProviderPrice>,
          FutureOr<List<ProviderPrice>>
        >
    with
        $FutureModifier<List<ProviderPrice>>,
        $FutureProvider<List<ProviderPrice>> {
  /// Preços de tabela. keepAlive: mudam só pelo dashboard; puxar para atualizar invalida.
  ProviderPricesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providerPricesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providerPricesHash();

  @$internal
  @override
  $FutureProviderElement<List<ProviderPrice>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ProviderPrice>> create(Ref ref) {
    return providerPrices(ref);
  }
}

String _$providerPricesHash() => r'779be6fc882ccaeb1ba63903009769e2e4d2a242';

/// Os 8 streamings destacados (sem variantes), na ordem de exibição. É a lista
/// de "Meus streamings" e a base da conta.

@ProviderFor(featuredProviders)
final featuredProvidersProvider = FeaturedProvidersProvider._();

/// Os 8 streamings destacados (sem variantes), na ordem de exibição. É a lista
/// de "Meus streamings" e a base da conta.

final class FeaturedProvidersProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<StreamingProvider>>,
          List<StreamingProvider>,
          FutureOr<List<StreamingProvider>>
        >
    with
        $FutureModifier<List<StreamingProvider>>,
        $FutureProvider<List<StreamingProvider>> {
  /// Os 8 streamings destacados (sem variantes), na ordem de exibição. É a lista
  /// de "Meus streamings" e a base da conta.
  FeaturedProvidersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'featuredProvidersProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$featuredProvidersHash();

  @$internal
  @override
  $FutureProviderElement<List<StreamingProvider>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<StreamingProvider>> create(Ref ref) {
    return featuredProviders(ref);
  }
}

String _$featuredProvidersHash() => r'695a44d949a177fec5c6238c879837518960b006';

/// Minhas assinaturas (`/subscribe/mine`): leitura, gravação otimista com
/// desfazer e o lembrete local sincronizado a cada mudança (e ao carregar, para
/// o aparelho refletir o banco depois de reinstalar ou trocar de celular).

@ProviderFor(MySubscriptions)
final mySubscriptionsProvider = MySubscriptionsProvider._();

/// Minhas assinaturas (`/subscribe/mine`): leitura, gravação otimista com
/// desfazer e o lembrete local sincronizado a cada mudança (e ao carregar, para
/// o aparelho refletir o banco depois de reinstalar ou trocar de celular).
final class MySubscriptionsProvider
    extends $AsyncNotifierProvider<MySubscriptions, List<UserSubscription>> {
  /// Minhas assinaturas (`/subscribe/mine`): leitura, gravação otimista com
  /// desfazer e o lembrete local sincronizado a cada mudança (e ao carregar, para
  /// o aparelho refletir o banco depois de reinstalar ou trocar de celular).
  MySubscriptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mySubscriptionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mySubscriptionsHash();

  @$internal
  @override
  MySubscriptions create() => MySubscriptions();
}

String _$mySubscriptionsHash() => r'c965319f883ab0f90699b547251cc84721ff830b';

/// Minhas assinaturas (`/subscribe/mine`): leitura, gravação otimista com
/// desfazer e o lembrete local sincronizado a cada mudança (e ao carregar, para
/// o aparelho refletir o banco depois de reinstalar ou trocar de celular).

abstract class _$MySubscriptions
    extends $AsyncNotifier<List<UserSubscription>> {
  FutureOr<List<UserSubscription>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<UserSubscription>>, List<UserSubscription>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<UserSubscription>>,
                List<UserSubscription>
              >,
              AsyncValue<List<UserSubscription>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// A recomendação da aba Assinar: candidatos (meu diário + feed dos amigos),
/// disponibilidade **em cache** dos candidatos, preços e minhas assinaturas →
/// `recommend()`. Recalcula quando o diário, a rede, as assinaturas ou a chave
/// de anúncios mudam. Nunca chama Edge Function: sem cache é "sem dados".

@ProviderFor(recommendation)
final recommendationProvider = RecommendationProvider._();

/// A recomendação da aba Assinar: candidatos (meu diário + feed dos amigos),
/// disponibilidade **em cache** dos candidatos, preços e minhas assinaturas →
/// `recommend()`. Recalcula quando o diário, a rede, as assinaturas ou a chave
/// de anúncios mudam. Nunca chama Edge Function: sem cache é "sem dados".

final class RecommendationProvider
    extends
        $FunctionalProvider<
          AsyncValue<Recommendation>,
          Recommendation,
          FutureOr<Recommendation>
        >
    with $FutureModifier<Recommendation>, $FutureProvider<Recommendation> {
  /// A recomendação da aba Assinar: candidatos (meu diário + feed dos amigos),
  /// disponibilidade **em cache** dos candidatos, preços e minhas assinaturas →
  /// `recommend()`. Recalcula quando o diário, a rede, as assinaturas ou a chave
  /// de anúncios mudam. Nunca chama Edge Function: sem cache é "sem dados".
  RecommendationProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recommendationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recommendationHash();

  @$internal
  @override
  $FutureProviderElement<Recommendation> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Recommendation> create(Ref ref) {
    return recommendation(ref);
  }
}

String _$recommendationHash() => r'64e73dacc3747ca72def80a507879deacd668390';
