import 'dart:async';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthUser;

import '../../../core/config/env.dart';
import '../../../core/errors/app_exception.dart';
import '../domain/auth_user.dart';

abstract class AuthRepository {
  AuthUser? get currentUser;

  /// Emite a cada mudança de sessão (login, logout, refresh). Não emite o
  /// valor atual ao assinar: quem precisa dele lê [currentUser] antes.
  Stream<AuthUser?> authStateChanges();

  Stream<AuthAppEvent> appEvents();

  Future<void> signInWithEmail({required String email, required String password});

  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  });

  Future<void> signInWithGoogle();

  Future<void> sendPasswordReset(String email);

  Future<void> updatePassword(String newPassword);

  Future<void> signOut();
}

class SupabaseAuthRepository implements AuthRepository {
  SupabaseAuthRepository(this._client);

  final SupabaseClient _client;
  bool _googleInitialized = false;

  GoTrueClient get _auth => _client.auth;

  @override
  AuthUser? get currentUser => _map(_auth.currentUser);

  @override
  Stream<AuthUser?> authStateChanges() =>
      _auth.onAuthStateChange.map((s) => _map(s.session?.user));

  @override
  Stream<AuthAppEvent> appEvents() => _auth.onAuthStateChange
      .where((s) => s.event == AuthChangeEvent.passwordRecovery)
      .map((_) => AuthAppEvent.passwordRecovery);

  @override
  Future<void> signInWithEmail({required String email, required String password}) async {
    await _auth.signInWithPassword(email: email.trim(), password: password);
  }

  @override
  Future<SignUpOutcome> signUpWithEmail({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // `full_name` é o que o trigger handle_new_user lê para o display_name.
    final res = await _auth.signUp(
      email: email.trim(),
      password: password,
      data: {if (displayName != null && displayName.trim().isNotEmpty) 'full_name': displayName.trim()},
      emailRedirectTo: Env.authCallback,
    );
    return res.session == null ? SignUpOutcome.needsEmailConfirmation : SignUpOutcome.signedIn;
  }

  /// Fluxo nativo (Credential Manager) → id_token → Supabase. Exige o client
  /// ID **Web** do Google Cloud como serverClientId (pendência do João).
  @override
  Future<void> signInWithGoogle() async {
    if (!Env.hasGoogleConfig) {
      throw const AppException(
        'config',
        'Login com Google ainda não configurado neste build (GOOGLE_WEB_CLIENT_ID).',
      );
    }
    final google = GoogleSignIn.instance;
    if (!_googleInitialized) {
      await google.initialize(serverClientId: Env.googleWebClientId);
      _googleInitialized = true;
    }
    final GoogleSignInAccount account;
    try {
      account = await google.authenticate();
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw AppException('canceled', 'Login cancelado.', cause: e);
      }
      throw AppException('google', 'Não deu para entrar com o Google: ${e.description ?? e.code.name}', cause: e);
    }
    final idToken = account.authentication.idToken;
    if (idToken == null) {
      throw const AppException('google', 'O Google não devolveu o token de identidade.');
    }
    await _auth.signInWithIdToken(provider: OAuthProvider.google, idToken: idToken);
  }

  @override
  Future<void> sendPasswordReset(String email) =>
      _auth.resetPasswordForEmail(email.trim(), redirectTo: Env.authCallback);

  @override
  Future<void> updatePassword(String newPassword) async {
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
    if (_googleInitialized) {
      // Sem isto o próximo "Entrar com Google" reaproveita a conta sem perguntar.
      await GoogleSignIn.instance.signOut();
    }
  }

  AuthUser? _map(User? u) {
    if (u == null) return null;
    final meta = u.userMetadata ?? const {};
    return AuthUser(
      id: u.id,
      email: u.email,
      displayName: (meta['full_name'] ?? meta['name']) as String?,
      avatarUrl: (meta['avatar_url'] ?? meta['picture']) as String?,
    );
  }
}
