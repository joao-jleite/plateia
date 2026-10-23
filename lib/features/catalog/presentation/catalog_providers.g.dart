// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'catalog_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

@ProviderFor(catalogRepository)
final catalogRepositoryProvider = CatalogRepositoryProvider._();

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

final class CatalogRepositoryProvider
    extends
        $FunctionalProvider<
          CatalogRepository,
          CatalogRepository,
          CatalogRepository
        >
    with $Provider<CatalogRepository> {
  /// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
  CatalogRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'catalogRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$catalogRepositoryHash();

  @$internal
  @override
  $ProviderElement<CatalogRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CatalogRepository create(Ref ref) {
    return catalogRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CatalogRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CatalogRepository>(value),
    );
  }
}

String _$catalogRepositoryHash() => r'20e0557d699468ce4d1db2a740352fdab045cc9e';

/// Seções do Início. keepAlive para não refazer a chamada ao trocar de aba;
/// puxar para atualizar faz `ref.invalidate`.

@ProviderFor(homeSections)
final homeSectionsProvider = HomeSectionsProvider._();

/// Seções do Início. keepAlive para não refazer a chamada ao trocar de aba;
/// puxar para atualizar faz `ref.invalidate`.

final class HomeSectionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<HomeSections>,
          HomeSections,
          FutureOr<HomeSections>
        >
    with $FutureModifier<HomeSections>, $FutureProvider<HomeSections> {
  /// Seções do Início. keepAlive para não refazer a chamada ao trocar de aba;
  /// puxar para atualizar faz `ref.invalidate`.
  HomeSectionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeSectionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeSectionsHash();

  @$internal
  @override
  $FutureProviderElement<HomeSections> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<HomeSections> create(Ref ref) {
    return homeSections(ref);
  }
}

String _$homeSectionsHash() => r'c2018f3c1d7513ec58f5dac698b505675ef68249';

/// Sobe quando um detalhe de título chega com "onde assistir" renovado (a tela
/// do título avisa). A aba Assinar observa: um título "sem dados" entra na
/// conta assim que alguém abre o detalhe dele, sem puxar para atualizar.

@ProviderFor(TitleCacheVersion)
final titleCacheVersionProvider = TitleCacheVersionProvider._();

/// Sobe quando um detalhe de título chega com "onde assistir" renovado (a tela
/// do título avisa). A aba Assinar observa: um título "sem dados" entra na
/// conta assim que alguém abre o detalhe dele, sem puxar para atualizar.
final class TitleCacheVersionProvider
    extends $NotifierProvider<TitleCacheVersion, int> {
  /// Sobe quando um detalhe de título chega com "onde assistir" renovado (a tela
  /// do título avisa). A aba Assinar observa: um título "sem dados" entra na
  /// conta assim que alguém abre o detalhe dele, sem puxar para atualizar.
  TitleCacheVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'titleCacheVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$titleCacheVersionHash();

  @$internal
  @override
  TitleCacheVersion create() => TitleCacheVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$titleCacheVersionHash() => r'9b95b9f58525ef3e5b9f25d58a071863ab58982e';

/// Sobe quando um detalhe de título chega com "onde assistir" renovado (a tela
/// do título avisa). A aba Assinar observa: um título "sem dados" entra na
/// conta assim que alguém abre o detalhe dele, sem puxar para atualizar.

abstract class _$TitleCacheVersion extends $Notifier<int> {
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

/// Detalhe do título com cache em memória por (tipo, id) enquanto o app vive.
/// O cache de verdade (30 d / 7 d) está no Postgres, atrás da Edge Function.

@ProviderFor(TitleDetailNotifier)
final titleDetailProvider = TitleDetailNotifierFamily._();

/// Detalhe do título com cache em memória por (tipo, id) enquanto o app vive.
/// O cache de verdade (30 d / 7 d) está no Postgres, atrás da Edge Function.
final class TitleDetailNotifierProvider
    extends $AsyncNotifierProvider<TitleDetailNotifier, TitleDetail> {
  /// Detalhe do título com cache em memória por (tipo, id) enquanto o app vive.
  /// O cache de verdade (30 d / 7 d) está no Postgres, atrás da Edge Function.
  TitleDetailNotifierProvider._({
    required TitleDetailNotifierFamily super.from,
    required (MediaType, int) super.argument,
  }) : super(
         retry: null,
         name: r'titleDetailProvider',
         isAutoDispose: false,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$titleDetailNotifierHash();

  @override
  String toString() {
    return r'titleDetailProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  TitleDetailNotifier create() => TitleDetailNotifier();

  @override
  bool operator ==(Object other) {
    return other is TitleDetailNotifierProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$titleDetailNotifierHash() =>
    r'53980b89c9db9e1b45e8e06d8bf4f07c58620c5a';

/// Detalhe do título com cache em memória por (tipo, id) enquanto o app vive.
/// O cache de verdade (30 d / 7 d) está no Postgres, atrás da Edge Function.

final class TitleDetailNotifierFamily extends $Family
    with
        $ClassFamilyOverride<
          TitleDetailNotifier,
          AsyncValue<TitleDetail>,
          TitleDetail,
          FutureOr<TitleDetail>,
          (MediaType, int)
        > {
  TitleDetailNotifierFamily._()
    : super(
        retry: null,
        name: r'titleDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: false,
      );

  /// Detalhe do título com cache em memória por (tipo, id) enquanto o app vive.
  /// O cache de verdade (30 d / 7 d) está no Postgres, atrás da Edge Function.

  TitleDetailNotifierProvider call(MediaType type, int tmdbId) =>
      TitleDetailNotifierProvider._(argument: (type, tmdbId), from: this);

  @override
  String toString() => r'titleDetailProvider';
}

/// Detalhe do título com cache em memória por (tipo, id) enquanto o app vive.
/// O cache de verdade (30 d / 7 d) está no Postgres, atrás da Edge Function.

abstract class _$TitleDetailNotifier extends $AsyncNotifier<TitleDetail> {
  late final _$args = ref.$arg as (MediaType, int);
  MediaType get type => _$args.$1;
  int get tmdbId => _$args.$2;

  FutureOr<TitleDetail> build(MediaType type, int tmdbId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<TitleDetail>, TitleDetail>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<TitleDetail>, TitleDetail>,
              AsyncValue<TitleDetail>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

/// Resultados da busca com paginação acumulada ("Mais resultados").

@ProviderFor(SearchResults)
final searchResultsProvider = SearchResultsFamily._();

/// Resultados da busca com paginação acumulada ("Mais resultados").
final class SearchResultsProvider
    extends $AsyncNotifierProvider<SearchResults, SearchPage> {
  /// Resultados da busca com paginação acumulada ("Mais resultados").
  SearchResultsProvider._({
    required SearchResultsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'searchResultsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @override
  String toString() {
    return r'searchResultsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  SearchResults create() => SearchResults();

  @override
  bool operator ==(Object other) {
    return other is SearchResultsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$searchResultsHash() => r'c8473c0ebedee9b9044e8489d93e7f8971a02284';

/// Resultados da busca com paginação acumulada ("Mais resultados").

final class SearchResultsFamily extends $Family
    with
        $ClassFamilyOverride<
          SearchResults,
          AsyncValue<SearchPage>,
          SearchPage,
          FutureOr<SearchPage>,
          String
        > {
  SearchResultsFamily._()
    : super(
        retry: null,
        name: r'searchResultsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Resultados da busca com paginação acumulada ("Mais resultados").

  SearchResultsProvider call(String query) =>
      SearchResultsProvider._(argument: query, from: this);

  @override
  String toString() => r'searchResultsProvider';
}

/// Resultados da busca com paginação acumulada ("Mais resultados").

abstract class _$SearchResults extends $AsyncNotifier<SearchPage> {
  late final _$args = ref.$arg as String;
  String get query => _$args;

  FutureOr<SearchPage> build(String query);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<SearchPage>, SearchPage>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SearchPage>, SearchPage>,
              AsyncValue<SearchPage>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
