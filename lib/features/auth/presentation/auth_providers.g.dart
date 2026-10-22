// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

final class AuthRepositoryProvider
    extends $FunctionalProvider<AuthRepository, AuthRepository, AuthRepository>
    with $Provider<AuthRepository> {
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<AuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  AuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'e250063afa9b4c2b12a0a86d6b995516fe0ab0ae';

/// Usuário atual como stream: começa com o valor já restaurado do disco
/// (sem "loading" no boot) e segue as mudanças de sessão. Alimenta o
/// `redirect` do router.

@ProviderFor(authState)
final authStateProvider = AuthStateProvider._();

/// Usuário atual como stream: começa com o valor já restaurado do disco
/// (sem "loading" no boot) e segue as mudanças de sessão. Alimenta o
/// `redirect` do router.

final class AuthStateProvider
    extends
        $FunctionalProvider<AsyncValue<AuthUser?>, AuthUser?, Stream<AuthUser?>>
    with $FutureModifier<AuthUser?>, $StreamProvider<AuthUser?> {
  /// Usuário atual como stream: começa com o valor já restaurado do disco
  /// (sem "loading" no boot) e segue as mudanças de sessão. Alimenta o
  /// `redirect` do router.
  AuthStateProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authStateProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authStateHash();

  @$internal
  @override
  $StreamProviderElement<AuthUser?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<AuthUser?> create(Ref ref) {
    return authState(ref);
  }
}

String _$authStateHash() => r'47e00e21e2dd62814b6fccb9f205f96141ba63e4';

@ProviderFor(authAppEvents)
final authAppEventsProvider = AuthAppEventsProvider._();

final class AuthAppEventsProvider
    extends
        $FunctionalProvider<
          AsyncValue<AuthAppEvent>,
          AuthAppEvent,
          Stream<AuthAppEvent>
        >
    with $FutureModifier<AuthAppEvent>, $StreamProvider<AuthAppEvent> {
  AuthAppEventsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authAppEventsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authAppEventsHash();

  @$internal
  @override
  $StreamProviderElement<AuthAppEvent> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<AuthAppEvent> create(Ref ref) {
    return authAppEvents(ref);
  }
}

String _$authAppEventsHash() => r'947655cf3024a38cc70393d7a5f59f863ca6430b';

/// Ações de login/cadastro. O estado é `AsyncValue<void>`: loading enquanto a
/// chamada roda e error para a tela mostrar o SnackBar.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// Ações de login/cadastro. O estado é `AsyncValue<void>`: loading enquanto a
/// chamada roda e error para a tela mostrar o SnackBar.
final class AuthControllerProvider
    extends $AsyncNotifierProvider<AuthController, void> {
  /// Ações de login/cadastro. O estado é `AsyncValue<void>`: loading enquanto a
  /// chamada roda e error para a tela mostrar o SnackBar.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();
}

String _$authControllerHash() => r'e8c66e9ae64f578fc9935f2a89c0b00bb838ab47';

/// Ações de login/cadastro. O estado é `AsyncValue<void>`: loading enquanto a
/// chamada roda e error para a tela mostrar o SnackBar.

abstract class _$AuthController extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
