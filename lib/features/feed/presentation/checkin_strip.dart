import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/presentation/auth_providers.dart';
import '../domain/activity.dart';
import 'feed_providers.dart';

/// Faixa "Assistindo agora" (SPEC §J4.5): check-ins ativos meus e de quem eu
/// sigo, no topo do feed e do Início. Some quando não há nenhum. O meu vem
/// primeiro, com "Encerrar".
class CheckinStrip extends ConsumerWidget {
  const CheckinStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final uid = ref.watch(authStateProvider).value?.id;
    final checkins = ref.watch(friendsCheckinsProvider).value ?? const <Checkin>[];
    if (checkins.isEmpty) return const SizedBox.shrink();
    final ordered = [...checkins.where((c) => c.userId == uid), ...checkins.where((c) => c.userId != uid)];

    return Padding(
      padding: const EdgeInsets.only(top: 8, bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.play_circle_outline, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: 6),
                Text('Assistindo agora', style: theme.textTheme.titleSmall),
              ],
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 96,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: ordered.length,
              separatorBuilder: (_, _) => const SizedBox(width: 8),
              itemBuilder: (context, i) => _CheckinCard(checkin: ordered[i], isMine: ordered[i].userId == uid),
            ),
          ),
        ],
      ),
    );
  }
}

class _CheckinCard extends ConsumerWidget {
  const _CheckinCard({required this.checkin, required this.isMine});

  final Checkin checkin;
  final bool isMine;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = checkin;
    final t = c.title;
    // uma linha só para progresso, nota e tempo: o cartão tem 75 px de altura
    final meta = [
      if (c.progressLabel != null) c.progressLabel!,
      if (c.note != null && c.note!.isNotEmpty) c.note!,
      relativePtBr(c.createdAt),
    ].join(' · ');

    Future<void> end() async {
      final messenger = ScaffoldMessenger.of(context);
      final error = await ref.read(myCheckinProvider.notifier).end();
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para encerrar. ($error)')));
    }

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: t == null ? null : () => context.push(Routes.title(t.mediaType, t.tmdbId)),
        child: Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Stack(
                children: [
                  PosterImage(url: TmdbImages.poster(t?.posterPath, size: 'w154'), width: 50, height: 75, borderRadius: 6, fallbackLabel: ''),
                  Positioned(
                    left: -2,
                    bottom: -2,
                    child: DecoratedBox(
                      decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: theme.colorScheme.surface, width: 2)),
                      child: UserAvatar(profile: c.user, size: 26),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 10),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 150),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(isMine ? 'Você' : (c.user?.nameOrUsername ?? 'Alguém'), style: theme.textTheme.labelLarge, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(t?.title ?? 'um título', style: theme.textTheme.bodySmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                    Text(meta, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline), maxLines: 1, overflow: TextOverflow.ellipsis),
                  ],
                ),
              ),
              if (isMine) ...[
                const SizedBox(width: 4),
                IconButton(
                  tooltip: 'Encerrar',
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(Icons.stop_circle_outlined),
                  onPressed: () => unawaited(end()),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
