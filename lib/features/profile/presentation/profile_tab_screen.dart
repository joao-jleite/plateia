import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../onboarding/domain/profile.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../../settings/data/account_repository.dart';

/// Perfil mínimo para o shell ficar inteiro: cartão, Sobre, sair e apagar
/// conta. O perfil de verdade (diário, listas, estatísticas) é a fase 04.
class ProfileTabScreen extends ConsumerWidget {
  const ProfileTabScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: AsyncView<Profile?>(
        value: profile,
        onRetry: () => ref.invalidate(myProfileProvider),
        data: (p) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (p != null) _ProfileCard(profile: p),
            const SizedBox(height: 24),
            const EmptyView(
              icon: Icons.grid_view_outlined,
              title: 'Seu diário chega na próxima fase',
              subtitle: 'Registrar, dar nota, listas e estatísticas.',
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Sobre e atribuições'),
              onTap: () => context.push(Routes.about),
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Sair'),
              onTap: () => ref.read(authControllerProvider.notifier).signOut(),
            ),
            ListTile(
              leading: Icon(Icons.delete_forever_outlined, color: Theme.of(context).colorScheme.error),
              title: Text('Apagar conta', style: TextStyle(color: Theme.of(context).colorScheme.error)),
              onTap: () => _confirmDelete(context, ref),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar sua conta?'),
        content: const Text(
          'Isso apaga seu perfil, diário, listas e tudo o que é seu. Não dá para desfazer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Apagar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    try {
      await ref.read(accountRepositoryProvider).deleteMyAccount();
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    }
  }
}

class _ProfileCard extends StatelessWidget {
  const _ProfileCard({required this.profile});

  final Profile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            PosterImage(
              url: profile.avatarUrl,
              width: 64,
              height: 64,
              borderRadius: 32,
              fallbackIcon: Icons.person,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.nameOrUsername, style: theme.textTheme.titleMedium),
                  Text('@${profile.username}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  if (profile.bio != null) ...[const SizedBox(height: 4), Text(profile.bio!)],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
