import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/auth/domain/auth_user.dart';
import '../../features/onboarding/domain/profile.dart';
import 'routes.dart';

/// Em que "portão" o usuário está. Derivado da sessão e do perfil; lógica
/// pura para o teste unitário do redirect.
enum GateState { loading, error, signedOut, needsOnboarding, ready }

GateState gateFrom(AsyncValue<AuthUser?> auth, AsyncValue<Profile?> profile) {
  if (auth.isLoading && !auth.hasValue) return GateState.loading;
  if (auth.hasError && !auth.hasValue) return GateState.error;
  if (auth.value == null) return GateState.signedOut;

  if (profile.isLoading && !profile.hasValue) return GateState.loading;
  if (profile.hasError && !profile.hasValue) return GateState.error;
  final p = profile.value;
  if (p == null) return GateState.loading; // perfil ainda não carregado para este usuário
  return p.isOnboarded ? GateState.ready : GateState.needsOnboarding;
}

/// Devolve o caminho para onde ir, ou null para ficar onde está.
String? computeRedirect({required GateState gate, required String location}) {
  final onSplash = location == Routes.splash;
  switch (gate) {
    case GateState.loading:
    case GateState.error:
      return onSplash ? null : Routes.splash;
    case GateState.signedOut:
      return Routes.isAuth(location) ? null : Routes.login;
    case GateState.needsOnboarding:
      return Routes.isOnboarding(location) ? null : Routes.onboardingUsername;
    case GateState.ready:
      if (Routes.isAuth(location) || Routes.isOnboarding(location) || onSplash) return Routes.home;
      return null;
  }
}
