import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/deep_link_fallback.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/skeletons.dart';
import '../../../core/widgets/spoiler_blur.dart';
import '../../diary/domain/entry.dart';
import '../../diary/presentation/entry_poster_tile.dart';
import '../../lists/domain/list_models.dart';
import '../../lists/presentation/list_edit_dialog.dart';
import '../../lists/presentation/lists_providers.dart';
import '../../onboarding/domain/profile.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../../social/domain/social_models.dart';
import '../../social/presentation/follow_button.dart';
import '../../social/presentation/report_sheet.dart';
import '../../social/presentation/share_profile.dart';
import '../../social/presentation/social_providers.dart';
import '../domain/profile_stats.dart';
import 'profile_providers.dart';

/// Perfil (SPEC §4, `/profile` para o meu e `/profile/:username` para os
/// outros): cartão com contadores, abas Assisti / Quero ver / Listas / Reviews.
/// Perfil privado mostra o cartão e esconde as abas (SPEC §5.3). No de outra
/// pessoa: botão seguir e menu compartilhar / bloquear / denunciar (fase 06).
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
        // perfil de terceiro pode ser a primeira tela (link de convite): voltar vai ao Início
        leading: isMe ? null : const BackOrHomeButton(),
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
          if (profile != null) _ProfileMenu(profile: profile, isMe: isMe),
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
                          _EntriesGrid(
                            userId: profile.id,
                            status: EntryStatus.want,
                            emptyTitle: 'Nada na lista de "quero ver"',
                            emptySubtitle: isMe ? 'Marque o que quer ver e a aba Assinar diz onde está.' : null,
                            emptyAction: isMe ? _searchAction(context) : null,
                          ),
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

/// Menu ⋮ do perfil: compartilhar (os dois), pedidos (meu, privado),
/// bloquear e denunciar (dos outros). Bloquear pede confirmação e sai do
/// perfil: a RLS esconde o cartão nos dois sentidos (SPEC §5.4).
class _ProfileMenu extends ConsumerWidget {
  const _ProfileMenu({required this.profile, required this.isMe});

  final Profile profile;
  final bool isMe;

  Future<void> _block(BuildContext context, WidgetRef ref) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Bloquear @${profile.username}?'),
        content: const Text(
          'Vocês deixam de se seguir e nenhum dos dois vê o perfil, o diário, as atividades, as curtidas ou os comentários do outro. '
          'A pessoa não é avisada. Dá para desbloquear em Configurações → Bloqueados.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(
            key: const Key('confirm-block'),
            style: FilledButton.styleFrom(backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Bloquear'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(socialActionsProvider.notifier).block(profile.id);
    if (!context.mounted) return;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text('Não deu para bloquear. ($error)')));
      return;
    }
    if (context.canPop()) context.pop();
    messenger.showSnackBar(SnackBar(content: Text('@${profile.username} bloqueado.')));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return PopupMenuButton<String>(
      key: const Key('profile-menu'),
      tooltip: 'Mais',
      onSelected: (v) {
        switch (v) {
          case 'share':
            unawaited(shareProfile(ref, profile));
          case 'requests':
            context.push(Routes.followRequests);
          case 'block':
            unawaited(_block(context, ref));
          case 'report':
            unawaited(showReportSheet(context, target: ReportTarget.profile, targetId: profile.id));
        }
      },
      itemBuilder: (_) => [
        const PopupMenuItem(value: 'share', child: ListTile(leading: Icon(Icons.share_outlined), title: Text('Compartilhar perfil'))),
        if (isMe && profile.isPrivate)
          const PopupMenuItem(value: 'requests', child: ListTile(leading: Icon(Icons.how_to_reg_outlined), title: Text('Pedidos para seguir'))),
        if (!isMe) ...[
          const PopupMenuItem(value: 'block', child: ListTile(leading: Icon(Icons.block_outlined), title: Text('Bloquear'))),
          const PopupMenuItem(value: 'report', child: ListTile(leading: Icon(Icons.flag_outlined), title: Text('Denunciar'))),
        ],
      ],
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
    final followsMe = !isMe && (ref.watch(isFollowingMeProvider(profile.id)).value ?? false);
    final pending = isMe && profile.isPrivate ? (ref.watch(pendingRequestsProvider).value?.length ?? 0) : 0;
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
                    Text(
                      followsMe ? '@${profile.username} · segue você' : '@${profile.username}',
                      style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                    ),
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
              _Counter(label: 'Seguidores', value: counts.followers, onTap: () => context.push(Routes.followers(profile.username))),
              _Counter(label: 'Seguindo', value: counts.following, onTap: () => context.push(Routes.following(profile.username))),
            ],
          ),
          const SizedBox(height: 8),
          if (isMe)
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                    onPressed: () => context.push(Routes.editProfile),
                    icon: const Icon(Icons.edit_outlined, size: 18),
                    label: const Text('Editar perfil'),
                  ),
                ),
                if (profile.isPrivate) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: FilledButton.tonalIcon(
                      key: const Key('follow-requests'),
                      style: FilledButton.styleFrom(minimumSize: const Size.fromHeight(40)),
                      onPressed: () => context.push(Routes.followRequests),
                      icon: Badge.count(count: pending, isLabelVisible: pending > 0, child: const Icon(Icons.how_to_reg_outlined, size: 18)),
                      label: Text(pending > 0 ? 'Pedidos ($pending)' : 'Pedidos'),
                    ),
                  ),
                ],
              ],
            )
          else
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40,
                    child: FollowButton(profile: profile),
                  ),
                ),
                const SizedBox(width: 8),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(minimumSize: const Size(0, 40)),
                  onPressed: () => unawaited(shareProfile(ref, profile)),
                  icon: const Icon(Icons.share_outlined, size: 18),
                  label: const Text('Compartilhar'),
                ),
              ],
            ),
        ],
      ),
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({required this.label, required this.value, this.onTap});

  final String label;
  final int value;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Column(
            children: [
              Text('$value', style: theme.textTheme.titleMedium),
              Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
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
      emptyAction: _searchAction(context),
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

/// Ação dos estados vazios do meu diário: ir para a busca (aba Buscar).
Widget _searchAction(BuildContext context) => FilledButton.icon(
      onPressed: () => context.go(Routes.search),
      icon: const Icon(Icons.search),
      label: const Text('Buscar um título'),
    );

class _EntriesGrid extends ConsumerWidget {
  const _EntriesGrid({
    required this.userId,
    required this.status,
    required this.emptyTitle,
    this.emptySubtitle,
    this.emptyAction,
    this.header,
  });

  final String userId;
  final EntryStatus status;
  final String emptyTitle;
  final String? emptySubtitle;
  final Widget? emptyAction;
  final Widget? header;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = profileEntriesProvider(userId, status, false);
    final entries = ref.watch(provider);
    return AsyncView<List<Entry>>(
      value: entries,
      onRetry: () => ref.invalidate(provider),
      loading: const GridSkeleton(),
      isEmpty: (l) => l.isEmpty && header == null,
      empty: EmptyView(icon: Icons.grid_view_outlined, title: emptyTitle, subtitle: emptySubtitle, action: emptyAction),
      data: (l) => CustomScrollView(
        slivers: [
          if (header != null) SliverToBoxAdapter(child: header),
          if (l.isEmpty)
            SliverToBoxAdapter(child: EmptyView(icon: Icons.grid_view_outlined, title: emptyTitle, subtitle: emptySubtitle, action: emptyAction))
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
      empty: const EmptyView(icon: Icons.rate_review_outlined, title: 'Nenhuma review ainda', subtitle: 'Reviews ficam na folha Registrar, depois da nota.'),
      data: (l) => ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: l.length,
        separatorBuilder: (_, _) => const SizedBox(height: 12),
        itemBuilder: (_, i) => ReviewCard(entry: l[i]),
      ),
    );
  }
}

/// Review no perfil: título, nota, data e o texto (borrado se spoiler). Review
/// de outra pessoa tem o menu "Denunciar" (SPEC §5.10).
class ReviewCard extends ConsumerWidget {
  const ReviewCard({super.key, required this.entry});

  final Entry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final t = entry.title;
    final isMine = entry.userId == ref.watch(myProfileProvider).value?.id;
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
                  if (!isMine)
                    PopupMenuButton<String>(
                      tooltip: 'Mais',
                      onSelected: (_) => unawaited(showReportSheet(context, target: ReportTarget.entry, targetId: entry.id)),
                      itemBuilder: (_) => const [
                        PopupMenuItem(value: 'report', child: ListTile(leading: Icon(Icons.flag_outlined), title: Text('Denunciar review'))),
                      ],
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
