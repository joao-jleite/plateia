import 'package:flutter/material.dart';

import '../config/tmdb_images.dart';
import 'poster_image.dart';

/// Cartão de pôster usado nas grades e carrosséis (Início, Busca).
class PosterTile extends StatelessWidget {
  const PosterTile({
    super.key,
    required this.title,
    required this.posterPath,
    this.year,
    this.typeLabel,
    this.width = 120,
    this.onTap,
  });

  final String title;
  final String? posterPath;
  final int? year;
  final String? typeLabel;
  final double width;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final subtitle = [?year?.toString(), ?typeLabel].join(' · ');
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            PosterImage(
              url: TmdbImages.poster(posterPath),
              width: width,
              height: width * 1.5,
              fallbackLabel: title,
            ),
            const SizedBox(height: 6),
            Text(title, maxLines: 2, overflow: TextOverflow.ellipsis, style: theme.textTheme.bodyMedium),
            if (subtitle.isNotEmpty)
              Text(subtitle, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
          ],
        ),
      ),
    );
  }
}
