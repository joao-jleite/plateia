import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_tile.dart';
import '../../../core/widgets/skeletons.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';
import '../../feed/presentation/checkin_strip.dart';
import '../../feed/presentation/feed_providers.dart';
import '../../notifications/presentation/notifications_bell.dart';

/// Início: faixa "assistindo agora" dos amigos (fase 06) e seções vindas de
/// `home_sections` (em alta no Brasil, novidades por streaming destacado).
/// Puxar para atualizar refaz a chamada; o servidor só vai ao TMDB se o cache
/// tiver mais de 6 h.
class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final sections = ref.watch(homeSectionsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Início'), actions: const [NotificationsBell()]),
      body: RefreshIndicator(
        onRefresh: () {
          ref.invalidate(friendsCheckinsProvider);
          return ref.refresh(homeSectionsProvider.future);
        },
        child: AsyncView<HomeSections>(
          value: sections,
          onRetry: () => ref.invalidate(homeSectionsProvider),
          loading: const HomeSkeleton(),
          isEmpty: (d) => d.sections.every((s) => s.items.isEmpty),
          empty: ListView(
            children: [
              EmptyView(
                title: 'Nada para mostrar ainda',
                subtitle: 'Puxe para atualizar ou procure um título.',
                action: FilledButton.icon(
                  onPressed: () => context.go(Routes.search),
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar um título'),
                ),
              ),
            ],
          ),
          data: (d) => ListView(
            padding: const EdgeInsets.symmetric(vertical: 12),
            children: [
              const CheckinStrip(),
              for (final section in d.sections)
                if (section.items.isNotEmpty) _SectionRow(section: section),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                child: Text(
                  'Atualizado ${relativePtBr(d.fetchedAt)} · dados do TMDB',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionRow extends StatelessWidget {
  const _SectionRow({required this.section});

  final HomeSection section;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(section.title, style: Theme.of(context).textTheme.titleMedium),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: PosterTile.heightFor(context),
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: section.items.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) {
                final item = section.items[i];
                return PosterTile(
                  title: item.title,
                  posterPath: item.posterPath,
                  year: item.year,
                  typeLabel: item.isAnime ? 'Anime' : item.mediaType.labelPtBr,
                  onTap: () => context.push(Routes.title(item.mediaType, item.tmdbId)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
