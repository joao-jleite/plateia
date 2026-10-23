// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'feed_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

@ProviderFor(feedRepository)
final feedRepositoryProvider = FeedRepositoryProvider._();

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.

final class FeedRepositoryProvider
    extends $FunctionalProvider<FeedRepository, FeedRepository, FeedRepository>
    with $Provider<FeedRepository> {
  /// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
  FeedRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedRepositoryHash();

  @$internal
  @override
  $ProviderElement<FeedRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  FeedRepository create(Ref ref) {
    return feedRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FeedRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FeedRepository>(value),
    );
  }
}

String _$feedRepositoryHash() => r'd35a97cfef1551d95d464c7a3372e6d69859bac9';

/// Feed (`/feed`): página de 30, "mais" ao chegar no fim, curtir otimista e
/// remover a própria atividade. Recarrega quando o diário, as listas ou a rede
/// (seguir/bloquear) mudam; a tela mantém o dado antigo durante o reload.

@ProviderFor(Feed)
final feedProvider = FeedProvider._();

/// Feed (`/feed`): página de 30, "mais" ao chegar no fim, curtir otimista e
/// remover a própria atividade. Recarrega quando o diário, as listas ou a rede
/// (seguir/bloquear) mudam; a tela mantém o dado antigo durante o reload.
final class FeedProvider extends $AsyncNotifierProvider<Feed, List<Activity>> {
  /// Feed (`/feed`): página de 30, "mais" ao chegar no fim, curtir otimista e
  /// remover a própria atividade. Recarrega quando o diário, as listas ou a rede
  /// (seguir/bloquear) mudam; a tela mantém o dado antigo durante o reload.
  FeedProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'feedProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$feedHash();

  @$internal
  @override
  Feed create() => Feed();
}

String _$feedHash() => r'2e45237171ee34a961fef2e5493f1e36887d6049';

/// Feed (`/feed`): página de 30, "mais" ao chegar no fim, curtir otimista e
/// remover a própria atividade. Recarrega quando o diário, as listas ou a rede
/// (seguir/bloquear) mudam; a tela mantém o dado antigo durante o reload.

abstract class _$Feed extends $AsyncNotifier<List<Activity>> {
  FutureOr<List<Activity>> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Activity>>, List<Activity>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Activity>>, List<Activity>>,
              AsyncValue<List<Activity>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}

/// Uma atividade (`/activity/:id`). Null = não existe ou não posso ver.

@ProviderFor(ActivityDetail)
final activityDetailProvider = ActivityDetailFamily._();

/// Uma atividade (`/activity/:id`). Null = não existe ou não posso ver.
final class ActivityDetailProvider
    extends $AsyncNotifierProvider<ActivityDetail, Activity?> {
  /// Uma atividade (`/activity/:id`). Null = não existe ou não posso ver.
  ActivityDetailProvider._({
    required ActivityDetailFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activityDetailProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activityDetailHash();

  @override
  String toString() {
    return r'activityDetailProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ActivityDetail create() => ActivityDetail();

  @override
  bool operator ==(Object other) {
    return other is ActivityDetailProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activityDetailHash() => r'81fbfd6eba35ee9c825169ac5122a09314ccb3e9';

/// Uma atividade (`/activity/:id`). Null = não existe ou não posso ver.

final class ActivityDetailFamily extends $Family
    with
        $ClassFamilyOverride<
          ActivityDetail,
          AsyncValue<Activity?>,
          Activity?,
          FutureOr<Activity?>,
          String
        > {
  ActivityDetailFamily._()
    : super(
        retry: null,
        name: r'activityDetailProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Uma atividade (`/activity/:id`). Null = não existe ou não posso ver.

  ActivityDetailProvider call(String activityId) =>
      ActivityDetailProvider._(argument: activityId, from: this);

  @override
  String toString() => r'activityDetailProvider';
}

/// Uma atividade (`/activity/:id`). Null = não existe ou não posso ver.

abstract class _$ActivityDetail extends $AsyncNotifier<Activity?> {
  late final _$args = ref.$arg as String;
  String get activityId => _$args;

  FutureOr<Activity?> build(String activityId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Activity?>, Activity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Activity?>, Activity?>,
              AsyncValue<Activity?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Comentários de uma atividade, com adicionar e apagar otimistas. O autor do
/// comentário e o dono da atividade podem apagar (a RLS confere).

@ProviderFor(Comments)
final commentsProvider = CommentsFamily._();

/// Comentários de uma atividade, com adicionar e apagar otimistas. O autor do
/// comentário e o dono da atividade podem apagar (a RLS confere).
final class CommentsProvider
    extends $AsyncNotifierProvider<Comments, List<Comment>> {
  /// Comentários de uma atividade, com adicionar e apagar otimistas. O autor do
  /// comentário e o dono da atividade podem apagar (a RLS confere).
  CommentsProvider._({
    required CommentsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'commentsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$commentsHash();

  @override
  String toString() {
    return r'commentsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  Comments create() => Comments();

  @override
  bool operator ==(Object other) {
    return other is CommentsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$commentsHash() => r'55bb934cc4ea374c3e4fcac1145b1e290ccbb02a';

/// Comentários de uma atividade, com adicionar e apagar otimistas. O autor do
/// comentário e o dono da atividade podem apagar (a RLS confere).

final class CommentsFamily extends $Family
    with
        $ClassFamilyOverride<
          Comments,
          AsyncValue<List<Comment>>,
          List<Comment>,
          FutureOr<List<Comment>>,
          String
        > {
  CommentsFamily._()
    : super(
        retry: null,
        name: r'commentsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Comentários de uma atividade, com adicionar e apagar otimistas. O autor do
  /// comentário e o dono da atividade podem apagar (a RLS confere).

  CommentsProvider call(String activityId) =>
      CommentsProvider._(argument: activityId, from: this);

  @override
  String toString() => r'commentsProvider';
}

/// Comentários de uma atividade, com adicionar e apagar otimistas. O autor do
/// comentário e o dono da atividade podem apagar (a RLS confere).

abstract class _$Comments extends $AsyncNotifier<List<Comment>> {
  late final _$args = ref.$arg as String;
  String get activityId => _$args;

  FutureOr<List<Comment>> build(String activityId);
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<Comment>>, List<Comment>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<Comment>>, List<Comment>>,
              AsyncValue<List<Comment>>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, () => build(_$args));
  }
}

/// Sobe a cada check-in criado/encerrado (a faixa do feed e do Início observam).

@ProviderFor(CheckinVersion)
final checkinVersionProvider = CheckinVersionProvider._();

/// Sobe a cada check-in criado/encerrado (a faixa do feed e do Início observam).
final class CheckinVersionProvider
    extends $NotifierProvider<CheckinVersion, int> {
  /// Sobe a cada check-in criado/encerrado (a faixa do feed e do Início observam).
  CheckinVersionProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'checkinVersionProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$checkinVersionHash();

  @$internal
  @override
  CheckinVersion create() => CheckinVersion();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$checkinVersionHash() => r'f7134d66cb6cc028e921ece651b3d30efe2cad99';

/// Sobe a cada check-in criado/encerrado (a faixa do feed e do Início observam).

abstract class _$CheckinVersion extends $Notifier<int> {
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

/// Faixa "assistindo agora" (view `friends_checkins`): eu + quem eu sigo.

@ProviderFor(friendsCheckins)
final friendsCheckinsProvider = FriendsCheckinsProvider._();

/// Faixa "assistindo agora" (view `friends_checkins`): eu + quem eu sigo.

final class FriendsCheckinsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Checkin>>,
          List<Checkin>,
          FutureOr<List<Checkin>>
        >
    with $FutureModifier<List<Checkin>>, $FutureProvider<List<Checkin>> {
  /// Faixa "assistindo agora" (view `friends_checkins`): eu + quem eu sigo.
  FriendsCheckinsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'friendsCheckinsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$friendsCheckinsHash();

  @$internal
  @override
  $FutureProviderElement<List<Checkin>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<Checkin>> create(Ref ref) {
    return friendsCheckins(ref);
  }
}

String _$friendsCheckinsHash() => r'75cef91e23e97af33fd496281b2da7d7a6c34cd5';

/// Meu check-in ativo, com fazer/encerrar otimistas.

@ProviderFor(MyCheckin)
final myCheckinProvider = MyCheckinProvider._();

/// Meu check-in ativo, com fazer/encerrar otimistas.
final class MyCheckinProvider
    extends $AsyncNotifierProvider<MyCheckin, Checkin?> {
  /// Meu check-in ativo, com fazer/encerrar otimistas.
  MyCheckinProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myCheckinProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myCheckinHash();

  @$internal
  @override
  MyCheckin create() => MyCheckin();
}

String _$myCheckinHash() => r'07ae475eaadbbae652da0a7d2ad5b0c26a6e5370';

/// Meu check-in ativo, com fazer/encerrar otimistas.

abstract class _$MyCheckin extends $AsyncNotifier<Checkin?> {
  FutureOr<Checkin?> build();
  @$mustCallSuper
  @override
  WhenComplete runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Checkin?>, Checkin?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Checkin?>, Checkin?>,
              AsyncValue<Checkin?>,
              Object?,
              Object?
            >;
    return element.handleCreate(ref, build);
  }
}
