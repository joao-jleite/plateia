import 'package:flutter/material.dart';

/// Cabeçalho comum das três telas do onboarding (SPEC §J1): "Passo n de 3",
/// três traços de progresso, título e uma frase. Dá o acabamento sem mexer no
/// fluxo que as fases 03, 05 e 06 já entregaram.
class OnboardingHeader extends StatelessWidget {
  const OnboardingHeader({super.key, required this.step, required this.title, required this.subtitle, this.icon});

  static const totalSteps = 3;

  /// 1 = seu @, 2 = importar a Netflix, 3 = encontrar amigos.
  final int step;
  final String title;
  final String subtitle;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Semantics(
          label: 'Passo $step de $totalSteps',
          child: ExcludeSemantics(
            child: Row(
              children: [
                for (var i = 1; i <= totalSteps; i++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      height: 4,
                      decoration: BoxDecoration(
                        color: i <= step ? scheme.primary : scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  ),
                  if (i < totalSteps) const SizedBox(width: 6),
                ],
                const SizedBox(width: 12),
                Text('$step de $totalSteps', style: theme.textTheme.labelSmall?.copyWith(color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),
        if (icon != null) ...[
          Icon(icon, size: 36, color: scheme.primary),
          const SizedBox(height: 12),
        ],
        Text(title, style: theme.textTheme.headlineSmall),
        const SizedBox(height: 6),
        Text(subtitle, style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant)),
      ],
    );
  }
}
