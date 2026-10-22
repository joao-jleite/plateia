import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/supabase/supabase_providers.dart';
import '../data/auth_repository.dart';
import '../domain/auth_user.dart';

part 'auth_providers.g.dart';

@Riverpod(keepAlive: true)
AuthRepository authRepository(Ref ref) =>
    SupabaseAuthRepository(ref.watch(supabaseClientProvider));

/// Usuário atual como stream: começa com o valor já restaurado do disco
/// (sem "loading" no boot) e segue as mudanças de sessão. Alimenta o
/// `redirect` do router.
@Riverpod(keepAlive: true)
Stream<AuthUser?> authState(Ref ref) async* {
  final repo = ref.watch(authRepositoryProvider);
  yield repo.currentUser;
  yield* repo.authStateChanges();
}

@Riverpod(keepAlive: true)
Stream<AuthAppEvent> authAppEvents(Ref ref) =>
    ref.watch(authRepositoryProvider).appEvents();

/// Ações de login/cadastro. O estado é `AsyncValue<void>`: loading enquanto a
/// chamada roda e error para a tela mostrar o SnackBar.
@riverpod
class AuthController extends _$AuthController {
  @override
  FutureOr<void> build() {}

  AuthRepository get _repo => ref.read(authRepositoryProvider);

  Future<bool> signIn({required String email, required String password}) =>
      _run(() => _repo.signInWithEmail(email: email, password: password));

  Future<SignUpOutcome?> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    state = const AsyncLoading();
    final result = await AsyncValue.guard(
      () => _repo.signUpWithEmail(email: email, password: password, displayName: displayName),
    );
    state = result.hasError ? AsyncError(result.error!, result.stackTrace!) : const AsyncData(null);
    return result.value;
  }

  Future<bool> signInWithGoogle() => _run(_repo.signInWithGoogle);

  Future<bool> sendPasswordReset(String email) => _run(() => _repo.sendPasswordReset(email));

  Future<bool> updatePassword(String password) => _run(() => _repo.updatePassword(password));

  Future<bool> signOut() => _run(_repo.signOut);

  Future<bool> _run(Future<void> Function() action) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(action);
    return !state.hasError;
  }
}
