// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

@ProviderFor(importRepository)
final importRepositoryProvider = ImportRepositoryProvider._();

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

final class ImportRepositoryProvider
    extends
        $FunctionalProvider<
          ImportRepository,
          ImportRepository,
          ImportRepository
        >
    with $Provider<ImportRepository> {
  /// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
  ImportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importRepositoryHash();

  @$internal
  @override
  $ProviderElement<ImportRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ImportRepository create(Ref ref) {
    return importRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportRepository>(value),
    );
  }
}

String _$importRepositoryHash() => r'1cd7853bb99d79e8df21455ee7fff370889a6b95';

@ProviderFor(csvPicker)
final csvPickerProvider = CsvPickerProvider._();

final class CsvPickerProvider
    extends $FunctionalProvider<CsvPicker, CsvPicker, CsvPicker>
    with $Provider<CsvPicker> {
  CsvPickerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'csvPickerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$csvPickerHash();

  @$internal
  @override
  $ProviderElement<CsvPicker> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  CsvPicker create(Ref ref) {
    return csvPicker(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CsvPicker value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CsvPicker>(value),
    );
  }
}

String _$csvPickerHash() => r'ac86fe218f549f788793207471f6e5772575abdd';

@ProviderFor(backgroundRunner)
final backgroundRunnerProvider = BackgroundRunnerProvider._();

final class BackgroundRunnerProvider
    extends
        $FunctionalProvider<
          BackgroundRunner,
          BackgroundRunner,
          BackgroundRunner
        >
    with $Provider<BackgroundRunner> {
  BackgroundRunnerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'backgroundRunnerProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$backgroundRunnerHash();

  @$internal
  @override
  $ProviderElement<BackgroundRunner> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  BackgroundRunner create(Ref ref) {
    return backgroundRunner(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(BackgroundRunner value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<BackgroundRunner>(value),
    );
  }
}

String _$backgroundRunnerHash() => r'eb4b50791fce0c63dd037aad030fcc3d563b3526';

/// CSV de exemplo para demonstrar o fluxo sem arquivo (só o backend de
/// fixtures preenche; null esconde o botão na tela).

@ProviderFor(sampleCsv)
final sampleCsvProvider = SampleCsvProvider._();

/// CSV de exemplo para demonstrar o fluxo sem arquivo (só o backend de
/// fixtures preenche; null esconde o botão na tela).

final class SampleCsvProvider
    extends $FunctionalProvider<Uint8List?, Uint8List?, Uint8List?>
    with $Provider<Uint8List?> {
  /// CSV de exemplo para demonstrar o fluxo sem arquivo (só o backend de
  /// fixtures preenche; null esconde o botão na tela).
  SampleCsvProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sampleCsvProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sampleCsvHash();

  @$internal
  @override
  $ProviderElement<Uint8List?> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Uint8List? create(Ref ref) {
    return sampleCsv(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Uint8List? value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Uint8List?>(value),
    );
  }
}

String _$sampleCsvHash() => r'c6093c8fa67fd583dceaf399fcaca1d89f7cb7b7';

/// Fila de revisão (`import_candidates` pendentes). Resolver e pular são
/// otimistas: a linha some na hora e volta se o servidor recusar.

@ProviderFor(PendingReview)
final pendingReviewProvider = PendingReviewProvider._();

/// Fila de revisão (`import_candidates` pendentes). Resolver e pular são
/// otimistas: a linha some na hora e volta se o servidor recusar.
final class PendingReviewProvider
    extends $AsyncNotifierProvider<PendingReview, List<ImportCandidateRow>> {
  /// Fila de revisão (`import_candidates` pendentes). Resolver e pular são
  /// otimistas: a linha some na hora e volta se o servidor recusar.
  PendingReviewProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingReviewProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingReviewHash();

  @$internal
  @override
  PendingReview create() => PendingReview();
}

String _$pendingReviewHash() => r'00010a2ea4acf0bdddd6f43cbfb23f60a51550ce';

/// Fila de revisão (`import_candidates` pendentes). Resolver e pular são
/// otimistas: a linha some na hora e volta se o servidor recusar.

abstract class _$PendingReview
    extends $AsyncNotifier<List<ImportCandidateRow>> {
  FutureOr<List<ImportCandidateRow>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<ImportCandidateRow>>,
              List<ImportCandidateRow>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<ImportCandidateRow>>,
                List<ImportCandidateRow>
              >,
              AsyncValue<List<ImportCandidateRow>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Quantos títulos esperam revisão (banner na tela de importar e nas configurações).

@ProviderFor(pendingReviewCount)
final pendingReviewCountProvider = PendingReviewCountProvider._();

/// Quantos títulos esperam revisão (banner na tela de importar e nas configurações).

final class PendingReviewCountProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Quantos títulos esperam revisão (banner na tela de importar e nas configurações).
  PendingReviewCountProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingReviewCountProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingReviewCountHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return pendingReviewCount(ref);
  }
}

String _$pendingReviewCountHash() =>
    r'760c2d374b418230f2596bbee67a5a15377f9e75';

/// A importação em si (SPEC §5.8, J1.4): ler → agrupar → casar (≤ 100 por
/// chamada) → gravar (merge) → candidatos → resumo. Guarda o progresso para a
/// tela; nunca guarda o arquivo.

@ProviderFor(ImportController)
final importControllerProvider = ImportControllerProvider._();

/// A importação em si (SPEC §5.8, J1.4): ler → agrupar → casar (≤ 100 por
/// chamada) → gravar (merge) → candidatos → resumo. Guarda o progresso para a
/// tela; nunca guarda o arquivo.
final class ImportControllerProvider
    extends $NotifierProvider<ImportController, ImportProgress> {
  /// A importação em si (SPEC §5.8, J1.4): ler → agrupar → casar (≤ 100 por
  /// chamada) → gravar (merge) → candidatos → resumo. Guarda o progresso para a
  /// tela; nunca guarda o arquivo.
  ImportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'importControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$importControllerHash();

  @$internal
  @override
  ImportController create() => ImportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ImportProgress value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ImportProgress>(value),
    );
  }
}

String _$importControllerHash() => r'6814ca8675a31e054b66aa2907f4fdef123b3986';

/// A importação em si (SPEC §5.8, J1.4): ler → agrupar → casar (≤ 100 por
/// chamada) → gravar (merge) → candidatos → resumo. Guarda o progresso para a
/// tela; nunca guarda o arquivo.

abstract class _$ImportController extends $Notifier<ImportProgress> {
  ImportProgress build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<ImportProgress, ImportProgress>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<ImportProgress, ImportProgress>,
              ImportProgress,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
