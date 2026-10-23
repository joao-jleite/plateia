import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/async_view.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../feed/presentation/feed_item.dart';
import '../../onboarding/domain/profile.dart';
import '../../profile/presentation/profile_providers.dart';
import 'follow_button.dart';
import 'social_providers.dart';

/// Seguidores ou seguindo de um perfil (`/profile/:username/followers|following`).
/// A RLS decide quem aparece: seguidores de perfil privado que eu não sigo
/// ficam de fora (SPEC §5.3), bloqueados nunca aparecem.
class FollowListScreen extends ConsumerWidget {
  const FollowListScreen({super.key, required this.username, required this.mode});

  final String username;
  final FollowListMode mode;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileByUsernameProvider(username));
    final uid = ref.watch(authStateProvider).value?.id;
    final title = mode == FollowListMode.followers ? 'Seguidores' : 'Seguindo';

    return Scaffold(
      appBar: AppBar(title: Text('$title · @$username')),
      body: AsyncView<Profile?>(
        value: profile,
        onRetry: () => ref.invalidate(profileByUsernameProvider(username)),
        isEmpty: (p) => p == null,
        empty: const EmptyView(icon: Icons.person_off_outlined, title: 'Perfil não encontrado'),
        data: (p) {
          final provider = followListProvider(p!.id, mode);
          final list = ref.watch(provider);
          return AsyncView<List<Profile>>(
            value: list,
            onRetry: () => ref.invalidate(provider),
            isEmpty: (l) => l.isEmpty,
            empty: EmptyView(
              icon: Icons.people_outline,
              title: mode == FollowListMode.followers ? 'Nenhum seguidor visível' : 'Não segue ninguém visível',
              subtitle: 'Perfis privados que você não segue e pessoas bloqueadas não aparecem.',
            ),
            data: (people) => ListView.builder(
              itemCount: people.length + (ref.read(provider.notifier).hasMore ? 1 : 0),
              itemBuilder: (context, i) {
                if (i == people.length) {
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: OutlinedButton(onPressed: () => ref.read(provider.notifier).loadMore(), child: const Text('Mostrar mais')),
                  );
                }
                final person = people[i];
                return UserTile(
                  profile: person,
                  trailing: person.id == uid ? null : FollowButton(profile: person, compact: true),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
