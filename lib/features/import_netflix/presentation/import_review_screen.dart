import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/model/media_type.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/poster_image.dart';
import '../domain/import_models.dart';
import 'import_providers.dart';

/// Revisão dos casos duvidosos da importação (`/import/review`, SPEC J1.5):
/// 2–3 candidatos por nome, ou "Nenhum destes". Escolher grava a entrada no
/// diário (mesma regra de merge da importação).
class ImportReviewScreen extends ConsumerWidget {
  const ImportReviewScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pending = ref.watch(pendingReviewProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Revisar importação'),
        actions: [
          if ((pending.value?.length ?? 0) > 0)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: Center(child: Text('${pending.value!.length} restantes', style: Theme.of(context).textTheme.labelLarge)),
            ),
        ],
      ),
      body: AsyncView<List<ImportCandidateRow>>(
        value: pending,
        onRetry: () => ref.invalidate(pendingReviewProvider),
        isEmpty: (rows) => rows.isEmpty,
        empty: const EmptyView(
          icon: Icons.task_alt_outlined,
          title: 'Nada para revisar',
          subtitle: 'Os títulos da importação sobre os quais não tivemos certeza aparecem aqui.',
        ),
        data: (rows) => ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: rows.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, i) => _CandidateCard(row: rows[i]),
        ),
      ),
    );
  }
}

class _CandidateCard extends ConsumerWidget {
  const _CandidateCard({required this.row});

  final ImportCandidateRow row;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final isMovie = row.guessedType == MediaType.movie;
    final when = row.lastWatchedAt == null ? null : shortDatePtBr(row.lastWatchedAt);
    final subtitle = [
      if (isMovie) 'Filme' else if (row.guessedType == MediaType.tv) '${row.episodesCount} ${row.episodesCount == 1 ? 'episódio' : 'episódios'}',
      if (when != null) '${isMovie ? 'visto' : 'último'} em $when',
    ].join(' · ');

    void report(String? error) {
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para salvar. Desfizemos. ($error)')));
    }

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(row.rawName, style: theme.textTheme.titleMedium),
                if (subtitle.isNotEmpty) Text(subtitle, style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
              ],
            ),
          ),
          if (row.candidates.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
              child: Text(
                'Não encontramos esse título no catálogo (pode ser um trailer ou extra).',
                style: theme.textTheme.bodyMedium,
              ),
            )
          else
            for (final c in row.candidates)
              ListTile(
                key: ValueKey('${row.id}-${c.tmdbId}-${c.mediaType.path}'),
                leading: PosterImage(url: TmdbImages.poster(c.posterPath, size: 'w92'), width: 40, height: 60, fallbackLabel: null),
                title: Text(c.title),
                subtitle: Text([?c.year?.toString(), c.mediaType.labelPtBr].join(' · ')),
                trailing: const Icon(Icons.check_circle_outline),
                onTap: () => unawaited(ref.read(pendingReviewProvider.notifier).resolve(row, c).then(report)),
              ),
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
              child: TextButton(
                onPressed: () => unawaited(ref.read(pendingReviewProvider.notifier).skip(row).then(report)),
                child: Text(row.candidates.isEmpty ? 'Pular' : 'Nenhum destes'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
