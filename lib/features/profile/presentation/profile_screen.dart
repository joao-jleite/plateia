import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/spoiler_blur.dart';
import '../../diary/domain/entry.dart';
import '../../diary/presentation/entry_poster_tile.dart';
import '../../lists/domain/list_models.dart';
import '../../lists/presentation/list_edit_dialog.dart';
import '../../lists/presentation/lists_providers.dart';
import '../../onboarding/domain/profile.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../domain/profile_stats.dart';
import 'profile_providers.dart';

/// Perfil (SPEC §4, `/profile` para o meu e `/profile/:username` para os
/// outros): cartão com contadores, abas Assisti / Quero ver / Listas / Reviews.
/// Perfil privado mostra o cartão e esconde as abas (SPEC §5.3).
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.username});

  /// Null = o meu (aba Perfil).
  final String? username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final my = ref.watch(myProfileProvider);
    final isMe = username == null || username == my.value?.username;
    final target = isMe ? my : ref.watch(profileByUsernameProvider(username!));
    final profile = target.value;

    return Scaffold(
      appBar: AppBar(
        title: Text(profile != null ? '@${profile.username}' : 'Perfil'),
        actions: [
          if (profile != null)
            IconButton(
              tooltip: 'Estatísticas',
              icon: const Icon(Icons.bar_chart_outlined),
              onPressed: () => context.push(Routes.stats(profile.username)),
            ),
          if (isMe)
            IconButton(
              tooltip: 'Configurações',
              icon: const Icon(Icons.settings_outlined),
              onPressed: () => context.push(Routes.settings),
            ),
        ],
      ),
      body: AsyncView<Profile?>(
        value: target,
        onRetry: () => isMe ? ref.invalidate(myProfileProvider) : ref.invalidate(profileByUsernameProvider(username!)),
        isEmpty: (p) => p == null,
        empty: const EmptyView(icon: Icons.person_off_outlined, title: 'Perfil não encontrado'),
        data: (p) => _ProfileBody(profile: p!, isMe: isMe),
      ),
    );
  }
}

class _ProfileBody extends ConsumerWidget {
  const _ProfileBody({required this.profile, required this.isMe});

  final Profile profile;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = isMe ? const AsyncData(true) : ref.watch(canViewContentProvider(profile.id));
    final visible = canView.value ?? false;

    return DefaultTabController(
      length: 4,
      child: Column(
        children: [
          _Header(profile: profile, isMe: isMe),
          const TabBar(
            tabs: [Tab(text: 'Assisti'), Tab(text: 'Quero ver'), Tab(text: 'Listas'), Tab(text: 'Reviews')],
          ),
          Expanded(
            child: canView.isLoading && !canView.hasValue
                ? const LoadingView()
                : !visible
                    ? const _PrivateView()
                    : TabBarView(
                        children: [
                          _WatchedTab(userId: profile.id),
                          _EntriesGrid(userId: profile.id, status: EntryStatus.want, emptyTitle: 'Nada na lista de "quero ver"'),
                          _ListsTab(userId: profile.id, isMe: isMe),
                          _ReviewsTab(userId: profile.id),
                        ],
                      ),
          ),
        ],
      ),
    );
  }
}

class _Header extends ConsumerWidget {
  const _Header({required this.profile, required this.isMe});

  final Profile profile;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final counts = ref.watch(profileCountsProvider(profile.id)).value ?? const ProfileCounts();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PosterImage(url: profile.avatarUrl, width: 72, height: 72, borderRadius: 36, fallbackIcon: Icons.person),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(child: Text(profile.nameOrUsername, style: theme.textTheme.titleLarge, maxLines: 1, overflow: TextOverflow.ellipsis)),
                        if (profile.isPrivate) Icon(Icons.lock_outline, size: 18, color: theme.colorScheme.outline),
                      ],
                    ),
                    Text('@${profile.username}', style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                    if (profile.bio != null && profile.bio!.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(profile.bio!, maxLines: 3, overflow: TextOverflow.ellipsis),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _Counter(label: 'Assistidos', value: counts.watched),
              _Counter(label: 'Reviews', value: counts.reviews),
              _Counter(label: 'Listas', value: counts.lists),
              _Counter(label: 'Seguidores', value: counts.followers),
              _Counter(label: 'Seguindo', value: counts.following),
            ],
          ),
          if (isMe) ...[
            const SizedBox(height: 8),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
              onPressed: () => context.push(Routes.editProfile),
              icon: const Icon(Icons.edit_outlined, size: 18),
              label: const Text('Editar perfil'),
            ),
          ],
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: theme.textTheme.titleMedium),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _PrivateView extends StatelessWidget {
  const _PrivateView();

  @override
  Widget build(BuildContext context) {
    return const EmptyView(
      icon: Icons.lock_outline,
      title: 'Perfil privado',
      subtitle: 'Diário, listas e estatísticas só aparecem para seguidores aceitos.',
    );
  }
}

/// Aba Assisti: faixa "Assistindo" (se houver) + grade dos assistidos.
class _WatchedTab extends ConsumerWidget {
  const _WatchedTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final watching = ref.watch(profileEntriesProvider(userId, EntryStatus.watching, false)).value ?? const <Entry>[];
    return _EntriesGrid(
      userId: userId,
      status: EntryStatus.watched,
      emptyTitle: 'Nada assistido ainda',
      emptySubtitle: 'Abra um título e toque em Registrar.',
      header: watching.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                  child: Text('Assistindo', style: Theme.of(context).textTheme.titleSmall),
                ),
                SizedBox(
                  height: 170,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemCount: watching.length,
                    separatorBuilder: (_, _) => const SizedBox(width: 10),
                    itemBuilder: (_, i) => SizedBox(width: 96, child: _tile(context, watching[i])),
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Divider(height: 1),
                ),
              ],
            ),
    );
  }

  static Widget _tile(BuildContext context, Entry e) => EntryPosterTile(
        entry: e,
        onTap: e.title == null ? null : () => context.push(Routes.title(e.title!.mediaType, e.title!.tmdbId)),
      );
}

class _EntriesGrid extends ConsumerWidget {
  const _EntriesGrid({required this.userId, required this.status, required this.emptyTitle, this.emptySubtitle, this.header});

  final String userId;
  final EntryStatus status;
  final String emptyTitle;
  final String? emptySubtitle;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = profileEntriesProvider(userId, status, false);
    final entries = ref.watch(provider);
    return AsyncView<List<Entry>>(
      value: entries,
      onRetry: () => ref.invalidate(provider),
      isEmpty: (l) => l.isEmpty && header == null,
      empty: EmptyView(icon: Icons.grid_view_outlined, title: emptyTitle, subtitle: emptySubtitle),
      data: (l) => CustomScrollView(
        slivers: [
          if (header != null) SliverToBoxAdapter(child: header),
          if (l.isEmpty)
            SliverToBoxAdapter(child: EmptyView(icon: Icons.grid_view_outlined, title: emptyTitle, subtitle: emptySubtitle))
          else
            SliverPadding(
              padding: const EdgeInsets.all(12),
              sliver: SliverGrid.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 2 / 3.45,
                ),
                itemCount: l.length,
                itemBuilder: (_, i) => _WatchedTab._tile(context, l[i]),
              ),
            ),
          if (ref.read(provider.notifier).hasMore)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                child: OutlinedButton(
                  onPressed: () => ref.read(provider.notifier).loadMore(),
                  child: const Text('Mostrar mais'),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ListsTab extends ConsumerWidget {
  const _ListsTab({required this.userId, required this.isMe});

  final String userId;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = isMe ? ref.watch(myListsProvider) : ref.watch(userListsProvider(userId));

    Future<void> create() async {
      final draft = await showListEditDialog(context);
      if (draft == null || !context.mounted) return;
      final messenger = ScaffoldMessenger.of(context);
      try {
        await ref.read(myListsProvider.notifier).create(draft);
      } catch (e) {
        messenger.showSnackBar(SnackBar(content: Text(describeError(e))));
      }
    }

    return AsyncView<List<ListModel>>(
      value: lists,
      onRetry: () => isMe ? ref.invalidate(myListsProvider) : ref.invalidate(userListsProvider(userId)),
      isEmpty: (l) => l.isEmpty && !isMe,
      empty: const EmptyView(icon: Icons.list_alt_outlined, title: 'Nenhuma lista pública'),
      data: (l) => ListView(
        children: [
          if (isMe)
            ListTile(
              leading: const Icon(Icons.add),
              title: const Text('Nova lista'),
              onTap: () => unawaited(create()),
            ),
          if (l.isEmpty && isMe)
            const EmptyView(icon: Icons.list_alt_outlined, title: 'Você ainda não tem listas', subtitle: 'Crie uma e adicione títulos pelo detalhe.'),
          for (final list in l)
            ListTile(
              leading: Icon(list.isPrivate ? Icons.lock_outline : (list.isRanked ? Icons.format_list_numbered : Icons.list_alt_outlined)),
              title: Text(list.name),
              subtitle: Text([list.countLabel, if (list.isPrivate) 'privada', if (list.isRanked) 'ranqueada'].join(' · ')),
              trailing: const Icon(Icons.chevron_right),
              onTap: list.id.startsWith('pending-') ? null : () => context.push(Routes.list(list.id)),
            ),
        ],
      ),
    );
  }
}

class _ReviewsTab extends ConsumerWidget {
  const _ReviewsTab({required this.userId});

  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = profileEntriesProvider(userId, null, true);
    final reviews = ref.watch(provider);
    return AsyncView<List<Entry>>(
      value: reviews,
      onRetry: () => ref.invalidate(provider),
      isEmpty: (l) => l.isEmpty,
      empty: const EmptyView(icon: Icons.rate_review_outlined, title: 'Nenhuma review ainda'),
      data: (l) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: l.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => ReviewCard(entry: l[i]),
      ),
    );
  }
}

/// Review no perfil: título, nota, data e o texto (borrado se spoiler).
class ReviewCard extends StatelessWidget {
  const ReviewCard({super.key, required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = entry.title;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: t == null ? null : () => context.push(Routes.title(t.mediaType, t.tmdbId)),
              child: Row(
                children: [
                  PosterImage(url: TmdbImages.poster(t?.posterPath, size: 'w92'), width: 40, height: 60, borderRadius: 6, fallbackLabel: ''),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(t?.title ?? 'Título', style: theme.textTheme.titleSmall, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 2),
                        Row(
                          children: [
                            if (entry.rating != null) ...[RatingStars(rating: entry.rating, size: 14), const SizedBox(width: 6)],
                            Text(
                              [if (t?.year != null) '${t!.year}', if (entry.watchedAt != null) shortDatePtBr(entry.watchedAt)].join(' · '),
                              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            SpoilerBlur(
              hasSpoiler: entry.hasSpoiler,
              child: Text(entry.review ?? '', style: theme.textTheme.bodyMedium),
            ),
          ],
        ),
      ),
    );
  }
}
