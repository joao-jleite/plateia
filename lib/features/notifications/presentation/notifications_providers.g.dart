// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

@ProviderFor(notificationsRepository)
final notificationsRepositoryProvider = NotificationsRepositoryProvider._();

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

final class NotificationsRepositoryProvider
    extends
        $FunctionalProvider<
          NotificationsRepository,
          NotificationsRepository,
          NotificationsRepository
        >
    with $Provider<NotificationsRepository> {
  /// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
  NotificationsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsRepositoryHash();

  @$internal
  @override
  $ProviderElement<NotificationsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  NotificationsRepository create(Ref ref) {
    return notificationsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NotificationsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NotificationsRepository>(value),
    );
  }
}

String _$notificationsRepositoryHash() =>
    r'465cdfb5826f79a2351122251418ff26df4cb5d2';

/// Sobe quando notificações são marcadas como lidas (o contador observa).

@ProviderFor(NotificationsVersion)
final notificationsVersionProvider = NotificationsVersionProvider._();

/// Sobe quando notificações são marcadas como lidas (o contador observa).
final class NotificationsVersionProvider
    extends $NotifierProvider<NotificationsVersion, int> {
  /// Sobe quando notificações são marcadas como lidas (o contador observa).
  NotificationsVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsVersionHash();

  @$internal
  @override
  NotificationsVersion create() => NotificationsVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$notificationsVersionHash() =>
    r'1b114158b68baa855c53b6ed774181bc0b6aab54';

/// Sobe quando notificações são marcadas como lidas (o contador observa).

abstract class _$NotificationsVersion extends $Notifier<int> {
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

/// Não lidas, para o badge no sino. keepAlive: a shell observa o tempo todo;
/// recarrega quando a rede muda ou algo é marcado como lido.

@ProviderFor(unreadCount)
final unreadCountProvider = UnreadCountProvider._();

/// Não lidas, para o badge no sino. keepAlive: a shell observa o tempo todo;
/// recarrega quando a rede muda ou algo é marcado como lido.

final class UnreadCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Não lidas, para o badge no sino. keepAlive: a shell observa o tempo todo;
  /// recarrega quando a rede muda ou algo é marcado como lido.
  UnreadCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'unreadCountProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$unreadCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return unreadCount(ref);
  }
}

String _$unreadCountHash() => r'f7a6441c3bebcaa2e2bdf23773402c72b7e6ee53';

/// Lista (`/notifications`), página de 30, marcar como lidas otimista.

@ProviderFor(Notifications)
final notificationsProvider = NotificationsProvider._();

/// Lista (`/notifications`), página de 30, marcar como lidas otimista.
final class NotificationsProvider
    extends $AsyncNotifierProvider<Notifications, List<AppNotification>> {
  /// Lista (`/notifications`), página de 30, marcar como lidas otimista.
  NotificationsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsHash();

  @$internal
  @override
  Notifications create() => Notifications();
}

String _$notificationsHash() => r'e08731e5f26a4bd7960947f9e4dfc97ac64955b0';

/// Lista (`/notifications`), página de 30, marcar como lidas otimista.

abstract class _$Notifications extends $AsyncNotifier<List<AppNotification>> {
  FutureOr<List<AppNotification>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<List<AppNotification>>, List<AppNotification>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<AppNotification>>,
                List<AppNotification>
              >,
              AsyncValue<List<AppNotification>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
