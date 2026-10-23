// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Cartão de um perfil pelo @. Null = não existe (ou bloqueio). Recarrega
/// quando a rede muda (bloquear some com o cartão).

@ProviderFor(profileByUsername)
final profileByUsernameProvider = ProfileByUsernameFamily._();

/// Cartão de um perfil pelo @. Null = não existe (ou bloqueio). Recarrega
/// quando a rede muda (bloquear some com o cartão).

final class ProfileByUsernameProvider
    extends
        $FunctionalProvider<AsyncValue<Profile?>, Profile?, FutureOr<Profile?>>
    with $FutureModifier<Profile?>, $FutureProvider<Profile?> {
  /// Cartão de um perfil pelo @. Null = não existe (ou bloqueio). Recarrega
  /// quando a rede muda (bloquear some com o cartão).
  ProfileByUsernameProvider._({
    required ProfileByUsernameFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileByUsernameProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileByUsernameHash();

  @override
  String toString() {
    return r'profileByUsernameProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<Profile?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<Profile?> create(Ref ref) {
    final argument = this.argument as String;
    return profileByUsername(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileByUsernameProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileByUsernameHash() => r'59a89e731f4bb8f3e962f7b1872fde6e385bca36';

/// Cartão de um perfil pelo @. Null = não existe (ou bloqueio). Recarrega
/// quando a rede muda (bloquear some com o cartão).

final class ProfileByUsernameFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<Profile?>, String> {
  ProfileByUsernameFamily._()
    : super(
        retry: null,
        name: r'profileByUsernameProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cartão de um perfil pelo @. Null = não existe (ou bloqueio). Recarrega
  /// quando a rede muda (bloquear some com o cartão).

  ProfileByUsernameProvider call(String username) =>
      ProfileByUsernameProvider._(argument: username, from: this);

  @override
  String toString() => r'profileByUsernameProvider';
}

/// Contadores (`profile_counts`). Recarrega quando meu diário, listas ou a
/// rede (seguir/aceitar) mudam.

@ProviderFor(profileCounts)
final profileCountsProvider = ProfileCountsFamily._();

/// Contadores (`profile_counts`). Recarrega quando meu diário, listas ou a
/// rede (seguir/aceitar) mudam.

final class ProfileCountsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfileCounts>,
          ProfileCounts,
          FutureOr<ProfileCounts>
        >
    with $FutureModifier<ProfileCounts>, $FutureProvider<ProfileCounts> {
  /// Contadores (`profile_counts`). Recarrega quando meu diário, listas ou a
  /// rede (seguir/aceitar) mudam.
  ProfileCountsProvider._({
    required ProfileCountsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileCountsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileCountsHash();

  @override
  String toString() {
    return r'profileCountsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProfileCounts> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProfileCounts> create(Ref ref) {
    final argument = this.argument as String;
    return profileCounts(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileCountsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileCountsHash() => r'822485bc6774876d58c8ab708fe7b2f52a6f69bc';

/// Contadores (`profile_counts`). Recarrega quando meu diário, listas ou a
/// rede (seguir/aceitar) mudam.

final class ProfileCountsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProfileCounts>, String> {
  ProfileCountsFamily._()
    : super(
        retry: null,
        name: r'profileCountsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Contadores (`profile_counts`). Recarrega quando meu diário, listas ou a
  /// rede (seguir/aceitar) mudam.

  ProfileCountsProvider call(String profileId) =>
      ProfileCountsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileCountsProvider';
}

/// Posso ver o conteúdo (diário, listas, estatísticas) desse perfil? Muda ao
/// ser aceito num perfil privado ou ao bloquear.

@ProviderFor(canViewContent)
final canViewContentProvider = CanViewContentFamily._();

/// Posso ver o conteúdo (diário, listas, estatísticas) desse perfil? Muda ao
/// ser aceito num perfil privado ou ao bloquear.

final class CanViewContentProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// Posso ver o conteúdo (diário, listas, estatísticas) desse perfil? Muda ao
  /// ser aceito num perfil privado ou ao bloquear.
  CanViewContentProvider._({
    required CanViewContentFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'canViewContentProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$canViewContentHash();

  @override
  String toString() {
    return r'canViewContentProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<bool> create(Ref ref) {
    final argument = this.argument as String;
    return canViewContent(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is CanViewContentProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$canViewContentHash() => r'ccfc902d0263eebe913e0089ac187004cca6259e';

/// Posso ver o conteúdo (diário, listas, estatísticas) desse perfil? Muda ao
/// ser aceito num perfil privado ou ao bloquear.

final class CanViewContentFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  CanViewContentFamily._()
    : super(
        retry: null,
        name: r'canViewContentProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Posso ver o conteúdo (diário, listas, estatísticas) desse perfil? Muda ao
  /// ser aceito num perfil privado ou ao bloquear.

  CanViewContentProvider call(String profileId) =>
      CanViewContentProvider._(argument: profileId, from: this);

  @override
  String toString() => r'canViewContentProvider';
}

/// Diário de um perfil por aba, paginado de 60 em 60 ("Mostrar mais").

@ProviderFor(ProfileEntries)
final profileEntriesProvider = ProfileEntriesFamily._();

/// Diário de um perfil por aba, paginado de 60 em 60 ("Mostrar mais").
final class ProfileEntriesProvider
    extends $AsyncNotifierProvider<ProfileEntries, List<Entry>> {
  /// Diário de um perfil por aba, paginado de 60 em 60 ("Mostrar mais").
  ProfileEntriesProvider._({
    required ProfileEntriesFamily super.from,
    required (String, EntryStatus?, bool) super.argument,
  }) : super(
         retry: null,
         name: r'profileEntriesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileEntriesHash();

  @override
  String toString() {
    return r'profileEntriesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ProfileEntries create() => ProfileEntries();

  @override
  bool operator ==(Object other) {
    return other is ProfileEntriesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileEntriesHash() => r'8351f05abe37f51cebabd6c87634a652335d5f61';

/// Diário de um perfil por aba, paginado de 60 em 60 ("Mostrar mais").

final class ProfileEntriesFamily extends $Family
    with
        $ClassFamilyOverride<
          ProfileEntries,
          AsyncValue<List<Entry>>,
          List<Entry>,
          FutureOr<List<Entry>>,
          (String, EntryStatus?, bool)
        > {
  ProfileEntriesFamily._()
    : super(
        retry: null,
        name: r'profileEntriesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Diário de um perfil por aba, paginado de 60 em 60 ("Mostrar mais").

  ProfileEntriesProvider call(
    String userId,
    EntryStatus? status,
    bool onlyReviews,
  ) => ProfileEntriesProvider._(
    argument: (userId, status, onlyReviews),
    from: this,
  );

  @override
  String toString() => r'profileEntriesProvider';
}

/// Diário de um perfil por aba, paginado de 60 em 60 ("Mostrar mais").

abstract class _$ProfileEntries extends $AsyncNotifier<List<Entry>> {
  late final _$args = ref.$arg as (String, EntryStatus?, bool);
  String get userId => _$args.$1;
  EntryStatus? get status => _$args.$2;
  bool get onlyReviews => _$args.$3;

  FutureOr<List<Entry>> build(
    String userId,
    EntryStatus? status,
    bool onlyReviews,
  );
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Entry>>, List<Entry>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Entry>>, List<Entry>>,
              AsyncValue<List<Entry>>,
              Object?,
              Object?
            >;
    return element.handleCreate(
      ref,
      () => build(_$args.$1, _$args.$2, _$args.$3),
    );
  }
}

/// Estatísticas: linhas magras da view + função pura no cliente.

@ProviderFor(profileStats)
final profileStatsProvider = ProfileStatsFamily._();

/// Estatísticas: linhas magras da view + função pura no cliente.

final class ProfileStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<ProfileStats>,
          ProfileStats,
          FutureOr<ProfileStats>
        >
    with $FutureModifier<ProfileStats>, $FutureProvider<ProfileStats> {
  /// Estatísticas: linhas magras da view + função pura no cliente.
  ProfileStatsProvider._({
    required ProfileStatsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'profileStatsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$profileStatsHash();

  @override
  String toString() {
    return r'profileStatsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ProfileStats> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<ProfileStats> create(Ref ref) {
    final argument = this.argument as String;
    return profileStats(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ProfileStatsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$profileStatsHash() => r'5316836ad0244d461e07df9e57ee5bbd5c6d1b4f';

/// Estatísticas: linhas magras da view + função pura no cliente.

final class ProfileStatsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ProfileStats>, String> {
  ProfileStatsFamily._()
    : super(
        retry: null,
        name: r'profileStatsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Estatísticas: linhas magras da view + função pura no cliente.

  ProfileStatsProvider call(String profileId) =>
      ProfileStatsProvider._(argument: profileId, from: this);

  @override
  String toString() => r'profileStatsProvider';
}

/// Streamings por id (nome e logo para "por streaming").

@ProviderFor(providersIndex)
final providersIndexProvider = ProvidersIndexProvider._();

/// Streamings por id (nome e logo para "por streaming").

final class ProvidersIndexProvider
    extends
        $FunctionalProvider<
          AsyncValue<Map<int, StreamingProvider>>,
          Map<int, StreamingProvider>,
          FutureOr<Map<int, StreamingProvider>>
        >
    with
        $FutureModifier<Map<int, StreamingProvider>>,
        $FutureProvider<Map<int, StreamingProvider>> {
  /// Streamings por id (nome e logo para "por streaming").
  ProvidersIndexProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'providersIndexProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$providersIndexHash();

  @$internal
  @override
  $FutureProviderElement<Map<int, StreamingProvider>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<Map<int, StreamingProvider>> create(Ref ref) {
    return providersIndex(ref);
  }
}

String _$providersIndexHash() => r'31a6cf83399169356205a852e6cadf38f49effb2';
