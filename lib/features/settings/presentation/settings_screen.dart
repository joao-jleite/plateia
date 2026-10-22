import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../data/account_repository.dart';

/// Configurações (`/settings`): editar cartão, perfil privado (SPEC §5.3),
/// sobre, sair e apagar conta (exigência da Play). Bloqueados vem na fase 06.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profile = ref.watch(myProfileProvider).value;

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
