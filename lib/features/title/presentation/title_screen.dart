import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/model/media_type.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../catalog/presentation/catalog_providers.dart';
import 'where_to_watch_section.dart';

/// Detalhe do título (SPEC §J2.2): pôster, sinopse, elenco, temporadas e a
/// seção Onde assistir. O botão Registrar (diário) chega na fase 04.
class TitleScreen extends ConsumerWidget {
  const TitleScreen({super.key, required this.type, required this.tmdbId});

  final MediaType type;
  final int tmdbId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = titleDetailProvider(type, tmdbId);
    final detail = ref.watch(provider);

    return Scaffold(
      appBar: AppBar(title: Text(detail.value?.title.title ?? '')),
      body: RefreshIndicator(
        onRefresh: () => ref.read(provider.notifier).refresh(),
        child: AsyncView<TitleDetail>(
          value: detail,
          onRetry: () => ref.invalidate(provider),
          data: (d) => _TitleBody(detail: d),
        ),
      ),
    );
  }
}

class _TitleBody extends StatelessWidget {
  const _TitleBody({required this.detail});

  final TitleDetail detail;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final t = detail.title;
    final meta = [
      if (t.year != null) '${t.year}',
      t.isAnime ? 'Anime' : t.mediaType.labelPtBr,
      if (t.mediaType == MediaType.tv && t.numberOfSeasons != null)
        '${t.numberOfSeasons} ${t.numberOfSeasons == 1 ? 'temporada' : 'temporadas'}',
      runtimeLabel(movieMinutes: t.runtimeMinutes, episodeMinutes: t.episodeRunTime),
    ].where((s) => s.isNotEmpty).join(' · ');

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PosterImage(
              url: TmdbImages.poster(t.posterPath),
              width: 120,
              height: 180,
              fallbackLabel: t.title,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(t.title, style: theme.textTheme.titleLarge),
                  if (t.originalTitle != null && t.originalTitle != t.title)
                    Text(t.originalTitle!, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
                  const SizedBox(height: 6),
                  Text(meta, style: theme.textTheme.bodySmall),
                  if (t.genres.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(t.genres.join(', '), style: theme.textTheme.bodySmall),
                  ],
                  if (t.voteAverage != null && t.voteAverage! > 0) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.star, size: 16, color: Colors.amber),
                        const SizedBox(width: 4),
                        Text('${t.voteAverage!.toStringAsFixed(1)} no TMDB', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        WhereToWatchSection(detail: detail),
        if (t.overview != null && t.overview!.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Sinopse', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(t.overview!, style: theme.textTheme.bodyMedium),
        ],
        if (t.castTop.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Elenco', style: theme.textTheme.titleMedium),
          const SizedBox(height: 10),
          SizedBox(
            height: 140,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: t.castTop.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, i) => _CastTile(member: t.castTop[i]),
            ),
          ),
        ],
        if (t.seasons.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text('Temporadas', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          for (final s in t.seasons.where((s) => s.seasonNumber > 0))
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading: PosterImage(
                url: TmdbImages.poster(s.posterPath, size: 'w92'),
                width: 36,
                height: 54,
                borderRadius: 4,
              ),
              title: Text(s.name),
              subtitle: Text([
                '${s.episodeCount} ${s.episodeCount == 1 ? 'episódio' : 'episódios'}',
                if (s.airDate != null) '${s.airDate!.year}',
              ].join(' · ')),
            ),
        ],
      ],
    );
  }
}

class _CastTile extends StatelessWidget {
  const _CastTile({required this.member});

  final CastMember member;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 80,
      child: Column(
        children: [
          PosterImage(
            url: TmdbImages.profile(member.profilePath),
            width: 64,
            height: 64,
            borderRadius: 32,
            fallbackIcon: Icons.person_outline,
          ),
          const SizedBox(height: 6),
          Text(member.name, maxLines: 2, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: theme.textTheme.labelMedium),
          if (member.character != null)
            Text(member.character!, maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
    );
  }
}
