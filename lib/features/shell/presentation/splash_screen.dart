import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/branding/plateia_mark.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../onboarding/presentation/my_profile_provider.dart';

/// Tela de espera enquanto sessão e perfil carregam: a mesma marca do splash
/// nativo, para a troca ser invisível. Se o perfil falhar (sem rede, RLS…),
/// mostra o erro com "tentar de novo" e "sair".
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    final auth = ref.watch(authStateProvider);
    final error = profile.hasError && !profile.hasValue
        ? profile.error
        : (auth.hasError && !auth.hasValue ? auth.error : null);

    return Scaffold(
      body: error == null
          ? const Center(child: PlateiaMark(size: 128))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ErrorView(
                  message: describeError(error),
                  onRetry: () {
                    ref.invalidate(authStateProvider);
                    ref.invalidate(myProfileProvider);
                  },
                ),
                TextButton(
                  onPressed: () => ref.read(authControllerProvider.notifier).signOut(),
                  child: const Text('Sair da conta'),
                ),
              ],
            ),
    );
  }
}
