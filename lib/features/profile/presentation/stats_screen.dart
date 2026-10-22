import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../onboarding/domain/profile.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../domain/profile_stats.dart';
import 'profile_providers.dart';

/// Estatísticas do perfil (`/profile/:username/stats`): horas assistidas, por
/// streaming (assinatura em BR), por gênero e por década. Cálculo no cliente
/// (`computeProfileStats`) sobre a view `entry_stats_rows`.
class StatsScreen extends ConsumerWidget {
  const StatsScreen({super.key, required this.username});

  final String username;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final my = ref.watch(myProfileProvider);
    final isMe = username == my.value?.username;
    final target = isMe ? my : ref.watch(profileByUsernameProvider(username));

    return Scaffold(
      appBar: AppBar(title: Text(target.value != null ? 'Estatísticas de @$username' : 'Estatísticas')),
      body: AsyncView<Profile?>(
        value: target,
        onRetry: () => isMe ? ref.invalidate(myProfileProvider) : ref.invalidate(profileByUsernameProvider(username)),
        isEmpty: (p) => p == null,
        empty: const EmptyView(icon: Icons.person_off_outlined, title: 'Perfil não encontrado'),
        data: (p) => _StatsBody(profile: p!, isMe: isMe),
      ),
    );
  }
}

class _StatsBody extends ConsumerWidget {
  const _StatsBody({required this.profile, required this.isMe});

  final Profile profile;
  final bool isMe;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final canView = isMe ? const AsyncData(true) : ref.watch(canViewContentProvider(profile.id));
    if (canView.isLoading && !canView.hasValue) return const LoadingView();
    if (canView.value != true) {
      return const EmptyView(icon: Icons.lock_outline, title: 'Perfil privado', subtitle: 'As estatísticas só aparecem para seguidores aceitos.');
    }
    final stats = ref.watch(profileStatsProvider(profile.id));
    final providers = ref.watch(providersIndexProvider).value ?? const <int, StreamingProvider>{};

    return AsyncView<ProfileStats>(
      value: stats,
      onRetry: () => ref.invalidate(profileStatsProvider(profile.id)),
      isEmpty: (s) => s.isEmpty,
      empty: const EmptyView(icon: Icons.bar_chart_outlined, title: 'Nada para contar ainda', subtitle: 'Registre o que você assistiu e as horas aparecem aqui.'),
      data: (s) => _StatsList(stats: s, providers: providers),
    );
  }
}

class _StatsList extends StatelessWidget {
  const _StatsList({required this.stats, required this.providers});

  final ProfileStats stats;
  final Map<int, StreamingProvider> providers;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ranked = stats.providersRanked;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text(hoursLabel(stats.totalMinutes), style: theme.textTheme.displaySmall?.copyWith(fontWeight: FontWeight.bold)),
                Text('assistidas', style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
                const SizedBox(height: 16),
                Row(
                  children: [
                    _Mini(label: 'Títulos', value: stats.watchedTitles + stats.watchingTitles),
                    _Mini(label: 'Filmes', value: stats.movies),
                    _Mini(label: 'Séries', value: stats.series),
                    _Mini(label: 'Reassistidos', value: stats.rewatches),
                  ],
                ),
              ],
            ),
          ),
        ),
        if (stats.withoutRuntime > 0)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Text(
              '${stats.withoutRuntime} ${stats.withoutRuntime == 1 ? 'título sem duração conhecida não entra' : 'títulos sem duração conhecida não entram'} nas horas.',
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        _Section(
          title: 'Por streaming',
          subtitle: 'Onde cada título está hoje (assinatura, Brasil)',
          empty: 'Nenhum título em streaming por assinatura.',
          rows: [
            for (final e in ranked.take(8))
              _BarRow(
                leading: PosterImage(url: TmdbImages.logo(providers[e.key]?.logoPath), width: 28, height: 28, borderRadius: 6, fallbackIcon: Icons.live_tv_outlined),
                label: providers[e.key]?.name ?? 'Streaming ${e.key}',
                count: e.value.count,
                max: ranked.isEmpty ? 1 : ranked.first.value.count,
              ),
          ],
        ),
        _Section(
          title: 'Por gênero',
          empty: 'Sem gêneros ainda.',
          rows: [
            for (final b in stats.byGenre.take(8))
              _BarRow(label: b.label, count: b.count, max: stats.byGenre.isEmpty ? 1 : stats.byGenre.first.count),
          ],
        ),
        _Section(
          title: 'Por década',
          empty: 'Sem anos ainda.',
          rows: [
            for (final b in stats.byDecade.take(8))
              _BarRow(label: 'Anos ${b.label}', count: b.count, max: stats.byDecade.isEmpty ? 1 : stats.byDecade.first.count),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Horas: filmes pela duração; séries por episódios vistos × duração média do TMDB. "Quero ver" não conta.',
          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

class _Mini extends StatelessWidget {
  const _Mini({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Column(
        children: [
          Text('$value', style: theme.textTheme.titleLarge),
          Text(label, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, this.subtitle, required this.rows, required this.empty});

  final String title;
  final String? subtitle;
  final List<Widget> rows;
  final String empty;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: theme.textTheme.titleMedium),
          if (subtitle != null) Text(subtitle!, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 8),
          if (rows.isEmpty) Text(empty, style: theme.textTheme.bodySmall) else ...rows,
        ],
      ),
    );
  }
}

class _BarRow extends StatelessWidget {
  const _BarRow({this.leading, required this.label, required this.count, required this.max});

  final Widget? leading;
  final String label;
  final int count;
  final int max;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        children: [
          if (leading != null) ...[leading!, const SizedBox(width: 10)],
          SizedBox(width: 110, child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium)),
          const SizedBox(width: 8),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(value: max == 0 ? 0 : count / max, minHeight: 10),
            ),
          ),
          const SizedBox(width: 10),
          SizedBox(width: 28, child: Text('$count', textAlign: TextAlign.end, style: theme.textTheme.bodyMedium)),
        ],
      ),
    );
  }
}
