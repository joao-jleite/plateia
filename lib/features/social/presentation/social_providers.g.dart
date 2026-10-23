// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'social_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

@ProviderFor(socialRepository)
final socialRepositoryProvider = SocialRepositoryProvider._();

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

final class SocialRepositoryProvider
    extends
        $FunctionalProvider<
          SocialRepository,
          SocialRepository,
          SocialRepository
        >
    with $Provider<SocialRepository> {
  /// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
  SocialRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialRepositoryHash();

  @$internal
  @override
  $ProviderElement<SocialRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SocialRepository create(Ref ref) {
    return socialRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SocialRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SocialRepository>(value),
    );
  }
}

String _$socialRepositoryHash() => r'217ffd55f165b9efe255e01111175b9f07ab0fd8';

/// Sobe a cada mudança social (seguir, aceitar, bloquear, denunciar). Perfil,
/// contadores, feed e notificações observam este número para recarregar.

@ProviderFor(SocialVersion)
final socialVersionProvider = SocialVersionProvider._();

/// Sobe a cada mudança social (seguir, aceitar, bloquear, denunciar). Perfil,
/// contadores, feed e notificações observam este número para recarregar.
final class SocialVersionProvider
    extends $NotifierProvider<SocialVersion, int> {
  /// Sobe a cada mudança social (seguir, aceitar, bloquear, denunciar). Perfil,
  /// contadores, feed e notificações observam este número para recarregar.
  SocialVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialVersionHash();

  @$internal
  @override
  SocialVersion create() => SocialVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$socialVersionHash() => r'500d33237839ca25a92b19f2af43ed719fade9cd';

/// Sobe a cada mudança social (seguir, aceitar, bloquear, denunciar). Perfil,
/// contadores, feed e notificações observam este número para recarregar.

abstract class _$SocialVersion extends $Notifier<int> {
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

/// Minha relação com um perfil, com seguir/deixar de seguir otimistas. O
/// status otimista é adivinhado pela privacidade do alvo; o servidor (trigger)
/// confirma. Métodos devolvem a mensagem de erro (null = deu certo).

@ProviderFor(FollowState)
final followStateProvider = FollowStateFamily._();

/// Minha relação com um perfil, com seguir/deixar de seguir otimistas. O
/// status otimista é adivinhado pela privacidade do alvo; o servidor (trigger)
/// confirma. Métodos devolvem a mensagem de erro (null = deu certo).
final class FollowStateProvider
    extends $AsyncNotifierProvider<FollowState, FollowStatus> {
  /// Minha relação com um perfil, com seguir/deixar de seguir otimistas. O
  /// status otimista é adivinhado pela privacidade do alvo; o servidor (trigger)
  /// confirma. Métodos devolvem a mensagem de erro (null = deu certo).
  FollowStateProvider._({
    required FollowStateFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'followStateProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followStateHash();

  @override
  String toString() {
    return r'followStateProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  FollowState create() => FollowState();

  @override
  bool operator ==(Object other) {
    return other is FollowStateProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followStateHash() => r'217cd3c53ac784cfe0abdde8edf4fed4b7f275e9';

/// Minha relação com um perfil, com seguir/deixar de seguir otimistas. O
/// status otimista é adivinhado pela privacidade do alvo; o servidor (trigger)
/// confirma. Métodos devolvem a mensagem de erro (null = deu certo).

final class FollowStateFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowState,
          AsyncValue<FollowStatus>,
          FollowStatus,
          FutureOr<FollowStatus>,
          String
        > {
  FollowStateFamily._()
    : super(
        retry: null,
        name: r'followStateProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Minha relação com um perfil, com seguir/deixar de seguir otimistas. O
  /// status otimista é adivinhado pela privacidade do alvo; o servidor (trigger)
  /// confirma. Métodos devolvem a mensagem de erro (null = deu certo).

  FollowStateProvider call(String targetId) =>
      FollowStateProvider._(argument: targetId, from: this);

  @override
  String toString() => r'followStateProvider';
}

/// Minha relação com um perfil, com seguir/deixar de seguir otimistas. O
/// status otimista é adivinhado pela privacidade do alvo; o servidor (trigger)
/// confirma. Métodos devolvem a mensagem de erro (null = deu certo).

abstract class _$FollowState extends $AsyncNotifier<FollowStatus> {
  late final _$args = ref.$arg as String;
  String get targetId => _$args;

  FutureOr<FollowStatus> build(String targetId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<FollowStatus>, FollowStatus>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<FollowStatus>, FollowStatus>,
              AsyncValue<FollowStatus>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// "Segue você" no perfil de alguém.

@ProviderFor(isFollowingMe)
final isFollowingMeProvider = IsFollowingMeFamily._();

/// "Segue você" no perfil de alguém.

final class IsFollowingMeProvider
    extends $FunctionalProvider<AsyncValue<bool>, bool, FutureOr<bool>>
    with $FutureModifier<bool>, $FutureProvider<bool> {
  /// "Segue você" no perfil de alguém.
  IsFollowingMeProvider._({
    required IsFollowingMeFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'isFollowingMeProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$isFollowingMeHash();

  @override
  String toString() {
    return r'isFollowingMeProvider'
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
    return isFollowingMe(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is IsFollowingMeProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$isFollowingMeHash() => r'24c2206b95423671fd49b3998789520922b98117';

/// "Segue você" no perfil de alguém.

final class IsFollowingMeFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<bool>, String> {
  IsFollowingMeFamily._()
    : super(
        retry: null,
        name: r'isFollowingMeProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// "Segue você" no perfil de alguém.

  IsFollowingMeProvider call(String targetId) =>
      IsFollowingMeProvider._(argument: targetId, from: this);

  @override
  String toString() => r'isFollowingMeProvider';
}

/// Pedidos recebidos (perfil privado), com aceitar/recusar otimistas.

@ProviderFor(PendingRequests)
final pendingRequestsProvider = PendingRequestsProvider._();

/// Pedidos recebidos (perfil privado), com aceitar/recusar otimistas.
final class PendingRequestsProvider
    extends $AsyncNotifierProvider<PendingRequests, List<FollowRequest>> {
  /// Pedidos recebidos (perfil privado), com aceitar/recusar otimistas.
  PendingRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRequestsHash();

  @$internal
  @override
  PendingRequests create() => PendingRequests();
}

String _$pendingRequestsHash() => r'f9f3609915bda3262fe7f95301f26b2285304242';

/// Pedidos recebidos (perfil privado), com aceitar/recusar otimistas.

abstract class _$PendingRequests extends $AsyncNotifier<List<FollowRequest>> {
  FutureOr<List<FollowRequest>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<FollowRequest>>, List<FollowRequest>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<FollowRequest>>, List<FollowRequest>>,
              AsyncValue<List<FollowRequest>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Seguidores ou seguindo de um perfil, página de 60 com "Mostrar mais".

@ProviderFor(FollowList)
final followListProvider = FollowListFamily._();

/// Seguidores ou seguindo de um perfil, página de 60 com "Mostrar mais".
final class FollowListProvider
    extends $AsyncNotifierProvider<FollowList, List<Profile>> {
  /// Seguidores ou seguindo de um perfil, página de 60 com "Mostrar mais".
  FollowListProvider._({
    required FollowListFamily super.from,
    required (String, FollowListMode) super.argument,
  }) : super(
         retry: null,
         name: r'followListProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$followListHash();

  @override
  String toString() {
    return r'followListProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  FollowList create() => FollowList();

  @override
  bool operator ==(Object other) {
    return other is FollowListProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$followListHash() => r'573fa869ee0b46c5c7b49ebbb300bd989d3d4953';

/// Seguidores ou seguindo de um perfil, página de 60 com "Mostrar mais".

final class FollowListFamily extends $Family
    with
        $ClassFamilyOverride<
          FollowList,
          AsyncValue<List<Profile>>,
          List<Profile>,
          FutureOr<List<Profile>>,
          (String, FollowListMode)
        > {
  FollowListFamily._()
    : super(
        retry: null,
        name: r'followListProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Seguidores ou seguindo de um perfil, página de 60 com "Mostrar mais".

  FollowListProvider call(String userId, FollowListMode mode) =>
      FollowListProvider._(argument: (userId, mode), from: this);

  @override
  String toString() => r'followListProvider';
}

/// Seguidores ou seguindo de um perfil, página de 60 com "Mostrar mais".

abstract class _$FollowList extends $AsyncNotifier<List<Profile>> {
  late final _$args = ref.$arg as (String, FollowListMode);
  String get userId => _$args.$1;
  FollowListMode get mode => _$args.$2;

  FutureOr<List<Profile>> build(String userId, FollowListMode mode);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Profile>>, List<Profile>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Profile>>, List<Profile>>,
              AsyncValue<List<Profile>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args.$1, _$args.$2));
  }
}

/// Busca de pessoas por `@` ou nome (a tela aplica o debounce).

@ProviderFor(userSearch)
final userSearchProvider = UserSearchFamily._();

/// Busca de pessoas por `@` ou nome (a tela aplica o debounce).

final class UserSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Profile>>,
          List<Profile>,
          FutureOr<List<Profile>>
        >
    with $FutureModifier<List<Profile>>, $FutureProvider<List<Profile>> {
  /// Busca de pessoas por `@` ou nome (a tela aplica o debounce).
  UserSearchProvider._({
    required UserSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'userSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$userSearchHash();

  @override
  String toString() {
    return r'userSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<Profile>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Profile>> create(Ref ref) {
    final argument = this.argument as String;
    return userSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is UserSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$userSearchHash() => r'f01dd637a93dc8d31ad5dbd83ef90f5686bd5fdd';

/// Busca de pessoas por `@` ou nome (a tela aplica o debounce).

final class UserSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<Profile>>, String> {
  UserSearchFamily._()
    : super(
        retry: null,
        name: r'userSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Busca de pessoas por `@` ou nome (a tela aplica o debounce).

  UserSearchProvider call(String query) =>
      UserSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'userSearchProvider';
}

/// Configurações → Bloqueados, com desbloquear otimista.

@ProviderFor(BlockedUsers)
final blockedUsersProvider = BlockedUsersProvider._();

/// Configurações → Bloqueados, com desbloquear otimista.
final class BlockedUsersProvider
    extends $AsyncNotifierProvider<BlockedUsers, List<BlockedUser>> {
  /// Configurações → Bloqueados, com desbloquear otimista.
  BlockedUsersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'blockedUsersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$blockedUsersHash();

  @$internal
  @override
  BlockedUsers create() => BlockedUsers();
}

String _$blockedUsersHash() => r'38c9e61f09e72908c36afb73b148eea681f3177f';

/// Configurações → Bloqueados, com desbloquear otimista.

abstract class _$BlockedUsers extends $AsyncNotifier<List<BlockedUser>> {
  FutureOr<List<BlockedUser>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BlockedUser>>, List<BlockedUser>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BlockedUser>>, List<BlockedUser>>,
              AsyncValue<List<BlockedUser>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Ações sem estado próprio na tela (a confirmação é um diálogo): bloquear,
/// denunciar, aceitar/recusar pedido a partir de uma notificação. keepAlive
/// porque são chamadas por `ref.read` sem ninguém observando: um provider
/// autoDispose morreria durante o `await` e a confirmação se perderia.
/// Devolvem a mensagem de erro, null = deu certo.

@ProviderFor(SocialActions)
final socialActionsProvider = SocialActionsProvider._();

/// Ações sem estado próprio na tela (a confirmação é um diálogo): bloquear,
/// denunciar, aceitar/recusar pedido a partir de uma notificação. keepAlive
/// porque são chamadas por `ref.read` sem ninguém observando: um provider
/// autoDispose morreria durante o `await` e a confirmação se perderia.
/// Devolvem a mensagem de erro, null = deu certo.
final class SocialActionsProvider
    extends $NotifierProvider<SocialActions, void> {
  /// Ações sem estado próprio na tela (a confirmação é um diálogo): bloquear,
  /// denunciar, aceitar/recusar pedido a partir de uma notificação. keepAlive
  /// porque são chamadas por `ref.read` sem ninguém observando: um provider
  /// autoDispose morreria durante o `await` e a confirmação se perderia.
  /// Devolvem a mensagem de erro, null = deu certo.
  SocialActionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'socialActionsProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$socialActionsHash();

  @$internal
  @override
  SocialActions create() => SocialActions();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(void value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<void>(value),
    );
  }
}

String _$socialActionsHash() => r'f22705c92f008a51725193c93a586fcc42e8df01';

/// Ações sem estado próprio na tela (a confirmação é um diálogo): bloquear,
/// denunciar, aceitar/recusar pedido a partir de uma notificação. keepAlive
/// porque são chamadas por `ref.read` sem ninguém observando: um provider
/// autoDispose morreria durante o `await` e a confirmação se perderia.
/// Devolvem a mensagem de erro, null = deu certo.

abstract class _$SocialActions extends $Notifier<void> {
  void build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<void, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<void, void>,
              void,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
