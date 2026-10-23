import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../import_netflix/presentation/import_providers.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../data/account_repository.dart';

/// Configurações (`/settings`): editar cartão, perfil privado (SPEC §5.3),
/// pedidos para seguir, bloqueados (SPEC §5.4), sobre, sair e apagar conta
/// (exigência da Play).
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(myProfileProvider).value;
    final pendingReview = ref.watch(pendingReviewCountProvider).value ?? 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Configurações')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.person_outline),
            title: const Text('Editar perfil'),
            subtitle: const Text('Foto, nome, @ e bio'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.editProfile),
          ),
          SwitchListTile(
            secondary: const Icon(Icons.lock_outline),
            title: const Text('Perfil privado'),
            subtitle: const Text(
              'Seu diário, listas e atividades só aparecem para seguidores aceitos. Nome, foto, bio e contadores continuam visíveis.',
            ),
            value: profile?.isPrivate ?? false,
            onChanged: profile == null
                ? null
                : (v) {
                    final messenger = ScaffoldMessenger.of(context);
                    unawaited(ref.read(myProfileProvider.notifier).setPrivate(v).then((error) {
                      if (error != null) {
                        messenger.showSnackBar(SnackBar(content: Text('Não deu para salvar. Desfizemos. ($error)')));
                      }
                    }));
                  },
          ),
          if (profile?.isPrivate ?? false)
            ListTile(
              leading: const Icon(Icons.how_to_reg_outlined),
              title: const Text('Pedidos para seguir'),
              subtitle: const Text('Quem pediu para seguir você'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(Routes.followRequests),
            ),
          ListTile(
            leading: const Icon(Icons.block_outlined),
            title: const Text('Bloqueados'),
            subtitle: const Text('Quem você bloqueou; desbloquear não refaz nada'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.blocked),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_file_outlined),
            title: const Text('Importar histórico da Netflix'),
            subtitle: Text(pendingReview > 0
                ? (pendingReview == 1 ? '1 título aguarda revisão' : '$pendingReview títulos aguardam revisão')
                : 'O CSV que a Netflix deixa baixar vira seu diário'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.import),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Sobre e atribuições'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => context.push(Routes.about),
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Sair'),
            onTap: () => ref.read(authControllerProvider.notifier).signOut(),
          ),
          const Divider(),
          ListTile(
            leading: Icon(Icons.delete_forever_outlined, color: theme.colorScheme.error),
            title: Text('Apagar conta', style: TextStyle(color: theme.colorScheme.error)),
            subtitle: const Text('Apaga perfil, diário, listas e tudo o que é seu.'),
            onTap: () => unawaited(_confirmDelete(context, ref)),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Apagar sua conta?'),
        content: const Text('Isso apaga seu perfil, diário, listas e tudo o que é seu. Não dá para desfazer.'),
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
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(accountRepositoryProvider).deleteMyAccount();
    } catch (e) {
      messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
    }
  }
}
