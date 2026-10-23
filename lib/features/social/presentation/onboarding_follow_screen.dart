import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../../onboarding/presentation/onboarding_header.dart';
import 'share_profile.dart';
import 'user_search_screen.dart';

/// Última etapa do onboarding (SPEC §J1, `/onboarding/follow`): achar amigos
/// pelo @ e compartilhar o próprio perfil. "Concluir" marca o onboarding como
/// feito; com [reviewAfter], abre a revisão da importação por cima do Início.
class OnboardingFollowScreen extends ConsumerStatefulWidget {
  const OnboardingFollowScreen({super.key, this.reviewAfter = false});

  final bool reviewAfter;

  @override
  ConsumerState<OnboardingFollowScreen> createState() => _OnboardingFollowScreenState();
}

class _OnboardingFollowScreenState extends ConsumerState<OnboardingFollowScreen> {
  bool _finishing = false;

  Future<void> _finish() async {
    setState(() => _finishing = true);
    try {
      await ref.read(myProfileProvider.notifier).completeOnboarding();
      if (!mounted) return;
      if (widget.reviewAfter) {
        // o router já deixa de redirecionar para o onboarding; vamos ao Início
        // e abrimos a revisão por cima
        context.go(Routes.home);
        unawaited(context.push(Routes.importReview));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final me = ref.watch(myProfileProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('Encontre amigos'), automaticallyImplyLeading: false),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(24, 8, 24, 4),
            child: OnboardingHeader(
              step: 3,
              title: 'Quem você quer acompanhar?',
              subtitle: 'O feed mostra o que quem você segue assiste. Procure pelo @ de quem você conhece ou mande o link do seu perfil. Dá para pular.',
            ),
          ),
          const Expanded(child: UserSearchBody(autofocus: false)),
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: me == null ? null : () => unawaited(shareProfile(ref, me)),
                      icon: const Icon(Icons.share_outlined),
                      label: const Text('Compartilhar'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      key: const Key('onboarding-finish'),
                      onPressed: _finishing ? null : () => unawaited(_finish()),
                      child: Text(_finishing ? 'Concluindo…' : 'Concluir'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
