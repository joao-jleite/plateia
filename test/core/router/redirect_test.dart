import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/router/redirect.dart';
import 'package:watchlog/core/router/routes.dart';
import 'package:watchlog/features/auth/domain/auth_user.dart';
import 'package:watchlog/features/onboarding/domain/profile.dart';

void main() {
  const user = AuthUser(id: 'u1', email: 'a@b.c');
  final onboarded = Profile(id: 'u1', username: 'foxer', onboardedAt: DateTime(2026));
  const fresh = Profile(id: 'u1', username: 'u_0123456789');

  group('gateFrom', () {
    test('sessão carregando → loading', () {
      expect(gateFrom(const AsyncLoading(), const AsyncLoading()), GateState.loading);
    });
    test('sem usuário → signedOut (perfil não importa)', () {
      expect(gateFrom(const AsyncData(null), const AsyncLoading()), GateState.signedOut);
    });
    test('com usuário e perfil sem onboarding → needsOnboarding', () {
      expect(gateFrom(const AsyncData(user), const AsyncData(fresh)), GateState.needsOnboarding);
    });
    test('com usuário e perfil pronto → ready', () {
      expect(gateFrom(const AsyncData(user), AsyncData(onboarded)), GateState.ready);
    });
    test('perfil com erro e sem valor → error', () {
      expect(gateFrom(const AsyncData(user), AsyncError(Exception('x'), StackTrace.empty)), GateState.error);
    });
  });

  group('computeRedirect', () {
    test('deslogado vai para o login, exceto nas rotas de auth', () {
      expect(computeRedirect(gate: GateState.signedOut, location: Routes.home), Routes.login);
      expect(computeRedirect(gate: GateState.signedOut, location: Routes.signup), isNull);
      expect(computeRedirect(gate: GateState.signedOut, location: Routes.reset), isNull);
    });
    test('sem onboarding vai para o username, e pode andar dentro do onboarding', () {
      expect(computeRedirect(gate: GateState.needsOnboarding, location: Routes.home), Routes.onboardingUsername);
      expect(computeRedirect(gate: GateState.needsOnboarding, location: Routes.onboardingImport), isNull);
    });
    test('pronto sai de auth/onboarding/splash para o Início e fica nas outras', () {
      expect(computeRedirect(gate: GateState.ready, location: Routes.login), Routes.home);
      expect(computeRedirect(gate: GateState.ready, location: Routes.splash), Routes.home);
      expect(computeRedirect(gate: GateState.ready, location: '/title/tv/37854'), isNull);
      expect(computeRedirect(gate: GateState.ready, location: Routes.profile), isNull);
    });
    test('carregando/erro vão para o splash', () {
      expect(computeRedirect(gate: GateState.loading, location: Routes.home), Routes.splash);
      expect(computeRedirect(gate: GateState.error, location: Routes.splash), isNull);
    });
  });
}
