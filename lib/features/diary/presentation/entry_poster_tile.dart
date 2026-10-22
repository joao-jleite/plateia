import 'package:flutter/material.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../core/widgets/rating_stars.dart';
import '../domain/entry.dart';

/// Pôster do diário para a grade do perfil: nota embaixo, marca de reassistir
/// e, para "assistindo", o progresso (T21 E1050).
class EntryPosterTile extends StatelessWidget {
  const EntryPosterTile({super.key, required this.entry, this.onTap});

  final Entry entry;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = entry.title;
    final progress = entry.status == EntryStatus.watching && entry.currentSeason != null
        ? 'T${entry.currentSeason}${entry.currentEpisode != null ? ' E${entry.currentEpisode}' : ''}'
        : null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                PosterImage(url: TmdbImages.poster(title?.posterPath), fallbackLabel: title?.title ?? ''),
                if (entry.isRewatch || progress != null)
                  Positioned(
                    top: 4,
                    right: 4,
                    child: _Badge(
                      icon: progress != null ? Icons.play_arrow : Icons.replay,
                      text: progress ?? '${entry.watchCount}×',
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 16,
            child: entry.rating != null
                ? RatingStars(rating: entry.rating, size: 13)
                : Text(
                    title?.title ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                  ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(999)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: Colors.white),
          const SizedBox(width: 2),
          Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
