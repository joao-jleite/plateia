// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'my_profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<
          ProfileRepository,
          ProfileRepository,
          ProfileRepository
        >
    with $Provider<ProfileRepository> {
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<ProfileRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ProfileRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ProfileRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ProfileRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'9ce0dc7c7cccd011e7ef202f77acac629e2a3592';

/// Perfil do usuário logado. `null` sem sessão. Alimenta o `redirect` do
/// router (onboarding feito?) e o cartão da aba Perfil.

@ProviderFor(MyProfile)
final myProfileProvider = MyProfileProvider._();

/// Perfil do usuário logado. `null` sem sessão. Alimenta o `redirect` do
/// router (onboarding feito?) e o cartão da aba Perfil.
final class MyProfileProvider
    extends $AsyncNotifierProvider<MyProfile, Profile?> {
  /// Perfil do usuário logado. `null` sem sessão. Alimenta o `redirect` do
  /// router (onboarding feito?) e o cartão da aba Perfil.
  MyProfileProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myProfileProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myProfileHash();

  @$internal
  @override
  MyProfile create() => MyProfile();
}

String _$myProfileHash() => r'6df151776cabe9315061e7b6393bc95fb2ddd83b';

/// Perfil do usuário logado. `null` sem sessão. Alimenta o `redirect` do
/// router (onboarding feito?) e o cartão da aba Perfil.

abstract class _$MyProfile extends $AsyncNotifier<Profile?> {
  FutureOr<Profile?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Profile?>, Profile?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Profile?>, Profile?>,
              AsyncValue<Profile?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
