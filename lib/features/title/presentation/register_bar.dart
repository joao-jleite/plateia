import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/dates.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/spoiler_blur.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../diary/domain/entry.dart';
import '../../diary/presentation/diary_providers.dart';
import '../../diary/presentation/log_sheet.dart';

/// Botão grande Registrar no detalhe (SPEC §J3.1). Registrado, vira o resumo
/// (estado, nota, data, vezes) e mostra "Sua review" com o spoiler borrado.
class RegisterBar extends ConsumerWidget {
  const RegisterBar({super.key, required this.detail});

  final TitleDetail detail;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final entryState = ref.watch(entryForTitleProvider(detail.title.id));
    final entry = entryState.value;

    final icon = switch (entry?.status) {
      EntryStatus.watched => Icons.check_circle,
      EntryStatus.watching => Icons.play_circle,
      EntryStatus.want => Icons.bookmark,
      null => Icons.add_circle_outline,
    };
    final label = entry == null ? 'Registrar' : entry.status.labelPtBr;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (entry == null)
          FilledButton.icon(
            onPressed: entryState.isLoading && !entryState.hasValue ? null : () => showLogSheet(context, detail: detail),
            icon: Icon(icon),
            label: Text(label),
          )
        else
          FilledButton.tonalIcon(
            onPressed: () => showLogSheet(context, detail: detail),
            icon: Icon(icon),
            label: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label),
                if (entry.rating != null) ...[
                  const SizedBox(width: 10),
                  RatingStars(rating: entry.rating, size: 16),
                ],
                if (entry.isRewatch) ...[
                  const SizedBox(width: 8),
                  Text('${entry.watchCount}×', style: theme.textTheme.labelMedium),
                ],
              ],
            ),
          ),
        if (entry != null && entry.status != EntryStatus.want && entry.watchedAt != null)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              '${entry.status == EntryStatus.watching ? 'Desde' : 'Em'} ${shortDatePtBr(entry.watchedAt)}'
              '${entry.currentSeason != null ? ' · T${entry.currentSeason}${entry.currentEpisode != null ? ' E${entry.currentEpisode}' : ''}' : ''}',
              textAlign: TextAlign.center,
              style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
            ),
          ),
        if (entry != null && entry.hasReview) ...[
          const SizedBox(height: 12),
          Text('Sua review', style: theme.textTheme.titleMedium),
          const SizedBox(height: 6),
          SpoilerBlur(
            hasSpoiler: entry.hasSpoiler,
            child: Text(entry.review!, style: theme.textTheme.bodyMedium),
          ),
        ],
      ],
    );
  }
}
