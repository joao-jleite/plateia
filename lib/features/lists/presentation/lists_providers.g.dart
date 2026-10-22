// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lists_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(listsRepository)
final listsRepositoryProvider = ListsRepositoryProvider._();

final class ListsRepositoryProvider
    extends
        $FunctionalProvider<ListsRepository, ListsRepository, ListsRepository>
    with $Provider<ListsRepository> {
  ListsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listsRepositoryHash();

  @$internal
  @override
  $ProviderElement<ListsRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  ListsRepository create(Ref ref) {
    return listsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ListsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ListsRepository>(value),
    );
  }
}

String _$listsRepositoryHash() => r'1998b3ca57c5e2d6141a69ec395bfafc3a1ed40a';

/// Sobe a cada gravação bem-sucedida em listas (ver `DiaryVersion`).

@ProviderFor(ListsVersion)
final listsVersionProvider = ListsVersionProvider._();

/// Sobe a cada gravação bem-sucedida em listas (ver `DiaryVersion`).
final class ListsVersionProvider extends $NotifierProvider<ListsVersion, int> {
  /// Sobe a cada gravação bem-sucedida em listas (ver `DiaryVersion`).
  ListsVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'listsVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$listsVersionHash();

  @$internal
  @override
  ListsVersion create() => ListsVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$listsVersionHash() => r'b8c2fc4e970a5fb042237d0b894594038117fe95';

/// Sobe a cada gravação bem-sucedida em listas (ver `DiaryVersion`).

abstract class _$ListsVersion extends $Notifier<int> {
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

/// Listas de um perfil (as visíveis para mim). Para as minhas, com ações, use [MyLists].

@ProviderFor(userLists)
final userListsProvider = UserListsFamily._();

/// Listas de um perfil (as visíveis para mim). Para as minhas, com ações, use [MyLists].

final class UserListsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<ListModel>>,
          List<ListModel>,
          FutureOr<List<ListModel>>
        >
    with $FutureModifier<List<ListModel>>, $FutureProvider<List<ListModel>> {
  /// Listas de um perfil (as visíveis para mim). Para as minhas, com ações, use [MyLists].
  UserListsProvider._({
    required UserListsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userListsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userListsHash();

  @override
  String toString() {
    return r'userListsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<ListModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<ListModel>> create(Ref ref) {
    final argument = this.argument as String;
    return userLists(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserListsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userListsHash() => r'60cfd1b010e97845caa109a6744d099ececc50ad';

/// Listas de um perfil (as visíveis para mim). Para as minhas, com ações, use [MyLists].

final class UserListsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<ListModel>>, String> {
  UserListsFamily._()
    : super(
        retry: null,
        name: r'userListsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Listas de um perfil (as visíveis para mim). Para as minhas, com ações, use [MyLists].

  UserListsProvider call(String userId) =>
      UserListsProvider._(argument: userId, from: this);

  @override
  String toString() => r'userListsProvider';
}

/// Minhas listas, com criar/editar/apagar otimistas. Métodos devolvem a
/// mensagem de erro (null = deu certo), como no diário.

@ProviderFor(MyLists)
final myListsProvider = MyListsProvider._();

/// Minhas listas, com criar/editar/apagar otimistas. Métodos devolvem a
/// mensagem de erro (null = deu certo), como no diário.
final class MyListsProvider
    extends $AsyncNotifierProvider<MyLists, List<ListModel>> {
  /// Minhas listas, com criar/editar/apagar otimistas. Métodos devolvem a
  /// mensagem de erro (null = deu certo), como no diário.
  MyListsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myListsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myListsHash();

  @$internal
  @override
  MyLists create() => MyLists();
}

String _$myListsHash() => r'6c7b22ef43b5212fad4ab4f09c13fe294e005541';

/// Minhas listas, com criar/editar/apagar otimistas. Métodos devolvem a
/// mensagem de erro (null = deu certo), como no diário.

abstract class _$MyLists extends $AsyncNotifier<List<ListModel>> {
  FutureOr<List<ListModel>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ListModel>>, List<ListModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ListModel>>, List<ListModel>>,
              AsyncValue<List<ListModel>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Cabeçalho de uma lista (`/list/:id`). Null = não existe ou não posso ver.

@ProviderFor(listDetail)
final listDetailProvider = ListDetailFamily._();

/// Cabeçalho de uma lista (`/list/:id`). Null = não existe ou não posso ver.

final class ListDetailProvider
    extends
        $FunctionalProvider<
          AsyncValue<ListModel?>,
          ListModel?,
          FutureOr<ListModel?>
        >
    with $FutureModifier<ListModel?>, $FutureProvider<ListModel?> {
  /// Cabeçalho de uma lista (`/list/:id`). Null = não existe ou não posso ver.
  ListDetailProvider._({
    required ListDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listDetailHash();

  @override
  String toString() {
    return r'listDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<ListModel?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<ListModel?> create(Ref ref) {
    final argument = this.argument as String;
    return listDetail(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ListDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listDetailHash() => r'8096383f7599a3a0bf0f5253914597acd92e0521';

/// Cabeçalho de uma lista (`/list/:id`). Null = não existe ou não posso ver.

final class ListDetailFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<ListModel?>, String> {
  ListDetailFamily._()
    : super(
        retry: null,
        name: r'listDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Cabeçalho de uma lista (`/list/:id`). Null = não existe ou não posso ver.

  ListDetailProvider call(String listId) =>
      ListDetailProvider._(argument: listId, from: this);

  @override
  String toString() => r'listDetailProvider';
}

/// Itens de uma lista, com remover e arrastar otimistas.

@ProviderFor(ListItems)
final listItemsProvider = ListItemsFamily._();

/// Itens de uma lista, com remover e arrastar otimistas.
final class ListItemsProvider
    extends $AsyncNotifierProvider<ListItems, List<ListItem>> {
  /// Itens de uma lista, com remover e arrastar otimistas.
  ListItemsProvider._({
    required ListItemsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'listItemsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$listItemsHash();

  @override
  String toString() {
    return r'listItemsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ListItems create() => ListItems();

  @override
  bool operator ==(Object other) {
    return other is ListItemsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$listItemsHash() => r'a85dd54ba19efdb28468d64da4153e59ed29358d';

/// Itens de uma lista, com remover e arrastar otimistas.

final class ListItemsFamily extends $Family
    with
        $ClassFamilyOverride<
          ListItems,
          AsyncValue<List<ListItem>>,
          List<ListItem>,
          FutureOr<List<ListItem>>,
          String
        > {
  ListItemsFamily._()
    : super(
        retry: null,
        name: r'listItemsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Itens de uma lista, com remover e arrastar otimistas.

  ListItemsProvider call(String listId) =>
      ListItemsProvider._(argument: listId, from: this);

  @override
  String toString() => r'listItemsProvider';
}

/// Itens de uma lista, com remover e arrastar otimistas.

abstract class _$ListItems extends $AsyncNotifier<List<ListItem>> {
  late final _$args = ref.$arg as String;
  String get listId => _$args;

  FutureOr<List<ListItem>> build(String listId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<ListItem>>, List<ListItem>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<ListItem>>, List<ListItem>>,
              AsyncValue<List<ListItem>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Em quais das minhas listas um título já está (folha "Adicionar à lista").

@ProviderFor(TitleListMembership)
final titleListMembershipProvider = TitleListMembershipFamily._();

/// Em quais das minhas listas um título já está (folha "Adicionar à lista").
final class TitleListMembershipProvider
    extends $AsyncNotifierProvider<TitleListMembership, Set<String>> {
  /// Em quais das minhas listas um título já está (folha "Adicionar à lista").
  TitleListMembershipProvider._({
    required TitleListMembershipFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'titleListMembershipProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$titleListMembershipHash();

  @override
  String toString() {
    return r'titleListMembershipProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  TitleListMembership create() => TitleListMembership();

  @override
  bool operator ==(Object other) {
    return other is TitleListMembershipProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$titleListMembershipHash() =>
    r'c4a29a1c26fc0f907a626ca74f34c1d9e27ac8d4';

/// Em quais das minhas listas um título já está (folha "Adicionar à lista").

final class TitleListMembershipFamily extends $Family
    with
        $ClassFamilyOverride<
          TitleListMembership,
          AsyncValue<Set<String>>,
          Set<String>,
          FutureOr<Set<String>>,
          String
        > {
  TitleListMembershipFamily._()
    : super(
        retry: null,
        name: r'titleListMembershipProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Em quais das minhas listas um título já está (folha "Adicionar à lista").

  TitleListMembershipProvider call(String titleId) =>
      TitleListMembershipProvider._(argument: titleId, from: this);

  @override
  String toString() => r'titleListMembershipProvider';
}

/// Em quais das minhas listas um título já está (folha "Adicionar à lista").

abstract class _$TitleListMembership extends $AsyncNotifier<Set<String>> {
  late final _$args = ref.$arg as String;
  String get titleId => _$args;

  FutureOr<Set<String>> build(String titleId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Set<String>>, Set<String>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Set<String>>, Set<String>>,
              AsyncValue<Set<String>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}
