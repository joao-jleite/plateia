import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/tmdb_images.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/poster_image.dart';
import '../../../core/widgets/rating_stars.dart';
import '../../../core/widgets/spoiler_blur.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../onboarding/domain/profile.dart';
import '../domain/activity.dart';
import '../domain/feed_grouping.dart';

/// Cartão de um grupo do feed: cabeçalho com o autor e o dia, e um
/// [ActivityTile] por evento ("assistiu 4 títulos hoje" = 4 linhas).
class FeedGroupCard extends StatelessWidget {
  const FeedGroupCard({super.key, required this.group, required this.onLike});

  final FeedGroup group;
  final void Function(Activity activity) onLike;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = group.first.user;
    return Card(
      margin: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          InkWell(
            onTap: user == null ? null : () => context.push(Routes.profileOf(user.username)),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              child: Row(
                children: [
                  UserAvatar(profile: user, size: 36),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user?.nameOrUsername ?? 'Alguém', style: theme.textTheme.titleSmall, maxLines: 1, overflow: TextOverflow.ellipsis),
                        Text(
                          [if (user != null) '@${user.username}', feedDayLabel(group.day), groupSummary(group)].where((s) => s.isNotEmpty).join(' · '),
                          style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          for (var i = 0; i < group.items.length; i++) ...[
            if (i > 0) const Divider(height: 1, indent: 12, endIndent: 12),
            ActivityTile(activity: group.items[i], onLike: () => onLike(group.items[i])),
          ],
        ],
      ),
    );
  }
}

/// Um evento do feed: pôster, frase ("avaliou **The Bear** ★★★★½"), review
/// (borrada se spoiler), curtidas e comentários. [expanded] no detalhe mostra
/// a review inteira e a hora; no feed, até 4 linhas.
class ActivityTile extends StatelessWidget {
  const ActivityTile({
    super.key,
    required this.activity,
    required this.onLike,
    this.expanded = false,
    this.showAuthor = false,
  });

  final Activity activity;
  final VoidCallback onLike;
  final bool expanded;

  /// No detalhe o cabeçalho do grupo não existe: mostra "@autor" na própria frase.
  final bool showAuthor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final a = activity;
    final t = a.title;
    final review = a.review;
    final isTitleEvent = a.kind != ActivityKind.listCreated && a.kind != ActivityKind.imported;
    final rating = isTitleEvent ? a.rating : null;
    final progress = a.kind == ActivityKind.watching && a.entry?.currentSeason != null
        ? 'T${a.entry!.currentSeason}${a.entry!.currentEpisode != null ? ' E${a.entry!.currentEpisode}' : ''}'
        : null;

    void openActivity() => context.push(Routes.activity(a.id));
    void openObject() {
      if (isTitleEvent && t != null) {
        context.push(Routes.title(t.mediaType, t.tmdbId));
      } else if (a.kind == ActivityKind.listCreated && a.listId != null) {
        context.push(Routes.list(a.listId!));
      } else {
        openActivity();
      }
    }

    return InkWell(
      onTap: expanded ? null : openActivity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 4),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isTitleEvent)
              GestureDetector(
                onTap: openObject,
                child: PosterImage(url: TmdbImages.poster(t?.posterPath, size: 'w154'), width: 48, height: 72, borderRadius: 6, fallbackLabel: ''),
              )
            else
              Container(
                width: 48,
                height: 72,
                decoration: BoxDecoration(color: theme.colorScheme.surfaceContainerHighest, borderRadius: BorderRadius.circular(6)),
                child: Icon(a.kind == ActivityKind.listCreated ? Icons.list_alt_outlined : Icons.upload_file_outlined, color: theme.colorScheme.outline),
              ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    label: activitySentence(a),
                    child: ExcludeSemantics(
                      child: Text.rich(
                        TextSpan(
                          children: [
                            if (showAuthor && a.user != null) TextSpan(text: '@${a.user!.username} ', style: const TextStyle(fontWeight: FontWeight.w600)),
                            TextSpan(text: '${activityVerb(a)} '),
                            TextSpan(
                              text: activityObject(a),
                              style: const TextStyle(fontWeight: FontWeight.w600),
                              recognizer: null,
                            ),
                          ],
                        ),
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ),
                  if (rating != null || progress != null || a.isRewatch) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        if (rating != null) ...[RatingStars(rating: rating, size: 15), const SizedBox(width: 6)],
                        if (progress != null) Text(progress, style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                        if (a.isRewatch && a.kind != ActivityKind.watched)
                          Text(' · de novo', style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
                      ],
                    ),
                  ],
                  if (review != null && review.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    SpoilerBlur(
                      hasSpoiler: a.hasSpoiler,
                      child: Text(review, style: theme.textTheme.bodyMedium, maxLines: expanded ? null : 4, overflow: expanded ? null : TextOverflow.ellipsis),
                    ),
                  ],
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      _Counter(
                        key: Key('like-${a.id}'),
                        icon: a.likedByMe ? Icons.favorite : Icons.favorite_border,
                        color: a.likedByMe ? theme.colorScheme.error : null,
                        count: a.likeCount,
                        tooltip: a.likedByMe ? 'Descurtir' : 'Curtir',
                        onTap: onLike,
                      ),
                      _Counter(
                        icon: Icons.mode_comment_outlined,
                        count: a.commentCount,
                        tooltip: 'Comentários',
                        onTap: expanded ? null : openActivity,
                      ),
                      const Spacer(),
                      Text(
                        expanded ? '${shortDatePtBr(a.createdAt)} · ${relativePtBr(a.createdAt)}' : relativePtBr(a.createdAt),
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
    );
  }
}

class _Counter extends StatelessWidget {
  const _Counter({super.key, required this.icon, required this.count, required this.tooltip, this.onTap, this.color});

  final IconData icon;
  final int count;
  final String tooltip;
  final VoidCallback? onTap;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(4, 6, 10, 6),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color ?? theme.colorScheme.outline),
              const SizedBox(width: 4),
              Text('$count', style: theme.textTheme.labelMedium?.copyWith(color: color ?? theme.colorScheme.outline)),
            ],
          ),
        ),
      ),
    );
  }
}

/// Linha de pessoa (busca, seguidores, bloqueados): foto, nome, @ e um
/// [trailing] (botão Seguir, Desbloquear…). [below] vai numa linha própria
/// sob o @ (ex.: Aceitar/Recusar do pedido): um Row com dois botões em
/// `trailing` quebrava o ListTile no aparelho.
class UserTile extends StatelessWidget {
  const UserTile({super.key, required this.profile, this.trailing, this.onTap, this.subtitle, this.below});

  final Profile profile;
  final Widget? trailing;
  final VoidCallback? onTap;
  final String? subtitle;
  final Widget? below;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: UserAvatar(profile: profile, size: 40),
      title: Row(
        children: [
          Flexible(child: Text(profile.nameOrUsername, maxLines: 1, overflow: TextOverflow.ellipsis)),
          if (profile.isPrivate) ...[const SizedBox(width: 6), Icon(Icons.lock_outline, size: 14, color: Theme.of(context).colorScheme.outline)],
        ],
      ),
      isThreeLine: below != null,
      subtitle: below == null
          ? Text(subtitle ?? '@${profile.username}', maxLines: 1, overflow: TextOverflow.ellipsis)
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(subtitle ?? '@${profile.username}', maxLines: 1, overflow: TextOverflow.ellipsis),
                Padding(padding: const EdgeInsets.only(top: 8), child: below),
              ],
            ),
      trailing: trailing,
      onTap: onTap ?? () => context.push(Routes.profileOf(profile.username)),
    );
  }
}
