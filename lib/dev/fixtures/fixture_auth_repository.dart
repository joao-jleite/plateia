import 'dart:async';

import '../../core/errors/app_exception.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_user.dart';
import '../../features/settings/data/account_repository.dart';

/// Auth em memória: qualquer e-mail com senha de 6+ caracteres entra; a sessão
/// vive só enquanto o app vive. Começa deslogado (ou logado, com [initialUser])
/// para exercitar login e onboarding no emulador e nos testes.
class FixtureAuthRepository implements AuthRepository {
  FixtureAuthRepository({AuthUser? initialUser, this.latency = const Duration(milliseconds: 250)})
      : _user = initialUser;

  final Duration latency;
  AuthUser? _user;
  final _changes = StreamController<AuthUser?>.broadcast();
  final _events = StreamController<AuthAppEvent>.broadcast();

  @override
  AuthUser? get currentUser => _user;

  @override
  Stream<AuthUser?> authStateChanges() => _changes.stream;

  @override
  Stream<AuthAppEvent> appEvents() => _events.stream;

  void _set(AuthUser? user) {
    _user = user;
    _changes.add(user);
  }

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    await Future<void>.delayed(latency);
    if (password.length < 6) {
      throw const AppException('invalid_credentials', 'E-mail ou senha incorretos.');
    }
    _set(AuthUser(id: 'fixture-${email.hashCode.abs()}', email: email.trim()));
  }

  @override
  Future<SignUpOutcome> signUpWithEmail({required String email, required String password, String? displayName}) async {
    await Future<void>.delayed(latency);
    _set(AuthUser(id: 'fixture-${email.hashCode.abs()}', email: email.trim(), displayName: displayName));
    return SignUpOutcome.signedIn;
  }

  @override
  Future<void> signInWithGoogle() async {
    await Future<void>.delayed(latency);
    _set(const AuthUser(id: 'fixture-google', email: 'pessoa@gmail.com', displayName: 'Pessoa do Google'));
  }

  @override
  Future<void> sendPasswordReset(String email) => Future<void>.delayed(latency);

  @override
  Future<void> updatePassword(String newPassword) => Future<void>.delayed(latency);

  @override
  Future<void> signOut() async {
    await Future<void>.delayed(latency);
    _set(null);
  }
}

class FixtureAccountRepository implements AccountRepository {
  FixtureAccountRepository(this._auth);

  final FixtureAuthRepository _auth;

  @override
  Future<void> deleteMyAccount() => _auth.signOut();
}
