// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'diary_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

@ProviderFor(entriesRepository)
final entriesRepositoryProvider = EntriesRepositoryProvider._();

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

final class EntriesRepositoryProvider
    extends
        $FunctionalProvider<
          EntriesRepository,
          EntriesRepository,
          EntriesRepository
        >
    with $Provider<EntriesRepository> {
  /// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
  EntriesRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'entriesRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$entriesRepositoryHash();

  @$internal
  @override
  $ProviderElement<EntriesRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  EntriesRepository create(Ref ref) {
    return entriesRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EntriesRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EntriesRepository>(value),
    );
  }
}

String _$entriesRepositoryHash() => r'a5b23f5f2fe80e4129263d7c9e76db6f16d8879a';

/// Sobe a cada gravação bem-sucedida no diário. Grade do perfil, contadores e
/// estatísticas observam este número para recarregar sem polling.

@ProviderFor(DiaryVersion)
final diaryVersionProvider = DiaryVersionProvider._();

/// Sobe a cada gravação bem-sucedida no diário. Grade do perfil, contadores e
/// estatísticas observam este número para recarregar sem polling.
final class DiaryVersionProvider extends $NotifierProvider<DiaryVersion, int> {
  /// Sobe a cada gravação bem-sucedida no diário. Grade do perfil, contadores e
  /// estatísticas observam este número para recarregar sem polling.
  DiaryVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'diaryVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$diaryVersionHash();

  @$internal
  @override
  DiaryVersion create() => DiaryVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$diaryVersionHash() => r'77537829b150314f9b510044e865eb41cc8eeb97';

/// Sobe a cada gravação bem-sucedida no diário. Grade do perfil, contadores e
/// estatísticas observam este número para recarregar sem polling.

abstract class _$DiaryVersion extends $Notifier<int> {
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

/// Meu registro para um título. Interface otimista (docs/ARQUITETURA.md §5):
/// o estado muda na hora; se o servidor recusar, volta ao anterior e o método
/// devolve a mensagem para a tela avisar. `null` = deu certo.

@ProviderFor(EntryForTitle)
final entryForTitleProvider = EntryForTitleFamily._();

/// Meu registro para um título. Interface otimista (docs/ARQUITETURA.md §5):
/// o estado muda na hora; se o servidor recusar, volta ao anterior e o método
/// devolve a mensagem para a tela avisar. `null` = deu certo.
final class EntryForTitleProvider
    extends $AsyncNotifierProvider<EntryForTitle, Entry?> {
  /// Meu registro para um título. Interface otimista (docs/ARQUITETURA.md §5):
  /// o estado muda na hora; se o servidor recusar, volta ao anterior e o método
  /// devolve a mensagem para a tela avisar. `null` = deu certo.
  EntryForTitleProvider._({
    required EntryForTitleFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'entryForTitleProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$entryForTitleHash();

  @override
  String toString() {
    return r'entryForTitleProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  EntryForTitle create() => EntryForTitle();

  @override
  bool operator ==(Object other) {
    return other is EntryForTitleProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$entryForTitleHash() => r'465dbf6da5ebe6ae40ecd235a90e35c2535e27c1';

/// Meu registro para um título. Interface otimista (docs/ARQUITETURA.md §5):
/// o estado muda na hora; se o servidor recusar, volta ao anterior e o método
/// devolve a mensagem para a tela avisar. `null` = deu certo.

final class EntryForTitleFamily extends $Family
    with
        $ClassFamilyOverride<
          EntryForTitle,
          AsyncValue<Entry?>,
          Entry?,
          FutureOr<Entry?>,
          String
        > {
  EntryForTitleFamily._()
    : super(
        retry: null,
        name: r'entryForTitleProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Meu registro para um título. Interface otimista (docs/ARQUITETURA.md §5):
  /// o estado muda na hora; se o servidor recusar, volta ao anterior e o método
  /// devolve a mensagem para a tela avisar. `null` = deu certo.

  EntryForTitleProvider call(String titleId) =>
      EntryForTitleProvider._(argument: titleId, from: this);

  @override
  String toString() => r'entryForTitleProvider';
}

/// Meu registro para um título. Interface otimista (docs/ARQUITETURA.md §5):
/// o estado muda na hora; se o servidor recusar, volta ao anterior e o método
/// devolve a mensagem para a tela avisar. `null` = deu certo.

abstract class _$EntryForTitle extends $AsyncNotifier<Entry?> {
  late final _$args = ref.$arg as String;
  String get titleId => _$args;

  FutureOr<Entry?> build(String titleId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Entry?>, Entry?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Entry?>, Entry?>,
              AsyncValue<Entry?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
