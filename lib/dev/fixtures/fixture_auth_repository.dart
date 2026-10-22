import 'dart:async';

import '../../core/errors/app_exception.dart';
import '../../features/auth/data/auth_repository.dart';
import '../../features/auth/domain/auth_user.dart';
import '../../features/onboarding/data/profile_repository.dart';
import '../../features/onboarding/domain/profile.dart';
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

/// Perfil em memória: nasce com @ provisório e sem onboarding, como o trigger
/// do banco faria.
class FixtureProfileRepository implements ProfileRepository {
  FixtureProfileRepository(this._auth, {this.latency = const Duration(milliseconds: 200), Profile? initial})
      : _profile = initial;

  final FixtureAuthRepository _auth;
  final Duration latency;
  Profile? _profile;

  /// @ já tomados, para a tela de username ter o caso "em uso".
  static const taken = {'foxer', 'camila', 'rafael'};

  Profile get _current {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return _profile ??= Profile(
      id: user.id,
      username: 'u_${user.id.hashCode.toRadixString(16).padLeft(10, '0').substring(0, 10)}',
      displayName: user.displayName,
      avatarUrl: user.avatarUrl,
      createdAt: DateTime.now(),
    );
  }

  @override
  Future<Profile> getMyProfile() async {
    await Future<void>.delayed(latency);
    return _current;
  }

  @override
  Future<bool> isUsernameAvailable(String username) async {
    await Future<void>.delayed(latency);
    return !taken.contains(username) || username == _current.username;
  }

  @override
  Future<Profile> saveUsername(String username, {String? displayName}) async {
    await Future<void>.delayed(latency);
    if (taken.contains(username)) throw const AppException('taken', 'Esse @ já está em uso.');
    return _profile = _current.copyWith(
      username: username,
      displayName: (displayName == null || displayName.trim().isEmpty) ? _current.displayName : displayName.trim(),
    );
  }

  @override
  Future<Profile> completeOnboarding() async {
    await Future<void>.delayed(latency);
    return _profile = _current.copyWith(onboardedAt: DateTime.now());
  }
}

class FixtureAccountRepository implements AccountRepository {
  FixtureAccountRepository(this._auth);

  final FixtureAuthRepository _auth;

  @override
  Future<void> deleteMyAccount() => _auth.signOut();
}
