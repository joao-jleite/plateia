import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/async_view.dart';
import '../../../core/widgets/deep_link_fallback.dart';
import '../../../core/widgets/spoiler_blur.dart';
import '../../../core/widgets/user_avatar.dart';
import '../../auth/presentation/auth_providers.dart';
import '../../social/domain/social_models.dart';
import '../../social/presentation/report_sheet.dart';
import '../domain/activity.dart';
import 'feed_item.dart';
import 'feed_providers.dart';

/// Uma atividade (`/activity/:id`): o evento inteiro, curtir, comentários com
/// chave de spoiler. O autor do comentário e o dono da atividade apagam; o
/// dono remove a atividade do feed; qualquer um denuncia (SPEC §J4.4, §5.5).
class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key, required this.activityId});

  final String activityId;

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  final _composer = TextEditingController();
  bool _spoiler = false;
  bool _sending = false;

  @override
  void dispose() {
    _composer.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final body = _composer.text;
    final error = validateCommentBody(body);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      return;
    }
    setState(() => _sending = true);
    _composer.clear();
    final spoiler = _spoiler;
    setState(() => _spoiler = false);
    final messenger = ScaffoldMessenger.of(context);
    final result = await ref.read(commentsProvider(widget.activityId).notifier).add(body, hasSpoiler: spoiler);
    if (!mounted) return;
    setState(() => _sending = false);
    if (result != null) {
      // devolve o texto para a pessoa não perder o que escreveu
      _composer.text = body;
      messenger.showSnackBar(SnackBar(content: Text('Não deu para comentar. ($result)')));
    }
  }

  Future<void> _deleteActivity(Activity a) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Remover do feed?'),
        content: const Text('A atividade some do feed com as curtidas e os comentários. Seu diário não muda.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Remover')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(activityDetailProvider(widget.activityId).notifier).delete();
    if (!mounted) return;
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text('Não deu para remover. ($error)')));
      return;
    }
    context.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Atividade removida do feed.')));
  }

  @override
  Widget build(BuildContext context) {
    final detail = ref.watch(activityDetailProvider(widget.activityId));
    final uid = ref.watch(authStateProvider).value?.id;
    final a = detail.value;
    final isMine = a != null && a.userId == uid;

    return Scaffold(
      appBar: AppBar(
        leading: const BackOrHomeButton(),
        title: const Text('Atividade'),
        actions: [
          if (a != null)
            PopupMenuButton<String>(
              onSelected: (v) {
                if (v == 'delete') unawaited(_deleteActivity(a));
                if (v == 'report') unawaited(showReportSheet(context, target: ReportTarget.activity, targetId: a.id));
              },
              itemBuilder: (_) => [
                if (isMine) const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Remover do feed'))),
                if (!isMine) const PopupMenuItem(value: 'report', child: ListTile(leading: Icon(Icons.flag_outlined), title: Text('Denunciar'))),
              ],
            ),
        ],
      ),
      body: AsyncView<Activity?>(
        value: detail,
        onRetry: () => ref.invalidate(activityDetailProvider(widget.activityId)),
        isEmpty: (v) => v == null,
        empty: const EmptyView(icon: Icons.visibility_off_outlined, title: 'Atividade indisponível', subtitle: 'Ela foi removida ou você não pode vê-la.'),
        data: (act) => Column(
          children: [
            Expanded(child: _Body(activity: act!, uid: uid)),
            _Composer(
              controller: _composer,
              spoiler: _spoiler,
              sending: _sending,
              onSpoilerChanged: (v) => setState(() => _spoiler = v),
              onSend: () => unawaited(_send()),
            ),
          ],
        ),
      ),
    );
  }
}

class _Body extends ConsumerWidget {
  const _Body({required this.activity, required this.uid});

  final Activity activity;
  final String? uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final comments = ref.watch(commentsProvider(activity.id));
    final user = activity.user;

    Future<void> like() async {
      final messenger = ScaffoldMessenger.of(context);
      final error = await ref.read(activityDetailProvider(activity.id).notifier).toggleLike();
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para curtir. Desfizemos. ($error)')));
    }

    return ListView(
      padding: const EdgeInsets.only(bottom: 16),
      children: [
        ListTile(
          leading: UserAvatar(profile: user, size: 40),
          title: Text(user?.nameOrUsername ?? 'Alguém'),
          subtitle: user == null ? null : Text('@${user.username}'),
          onTap: user == null ? null : () => context.push(Routes.profileOf(user.username)),
        ),
        ActivityTile(activity: activity, onLike: () => unawaited(like()), expanded: true),
        const Divider(),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
          child: Text(
            comments.value == null ? 'Comentários' : 'Comentários (${comments.value!.length})',
            style: theme.textTheme.titleSmall,
          ),
        ),
        AsyncView<List<Comment>>(
          value: comments,
          onRetry: () => ref.invalidate(commentsProvider(activity.id)),
          isEmpty: (l) => l.isEmpty,
          empty: const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Ninguém comentou ainda. Seja a primeira pessoa.'),
          ),
          data: (list) => Column(
            children: [for (final c in list) _CommentTile(comment: c, activity: activity, uid: uid)],
          ),
        ),
      ],
    );
  }
}

class _CommentTile extends ConsumerWidget {
  const _CommentTile({required this.comment, required this.activity, required this.uid});

  final Comment comment;
  final Activity activity;
  final String? uid;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final c = comment;
    final mine = c.userId == uid;
    final canDelete = mine || activity.userId == uid;
    final pending = c.id.startsWith('pending-');

    Future<void> remove() async {
      final messenger = ScaffoldMessenger.of(context);
      final error = await ref.read(commentsProvider(activity.id).notifier).remove(c.id);
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para apagar. Desfizemos. ($error)')));
    }

    return ListTile(
      key: Key('comment-${c.id}'),
      leading: UserAvatar(
        profile: c.user,
        size: 32,
        onTap: c.user == null ? null : () => context.push(Routes.profileOf(c.user!.username)),
      ),
      title: Row(
        children: [
          Text(c.user == null ? 'Alguém' : '@${c.user!.username}', style: theme.textTheme.labelLarge),
          const SizedBox(width: 8),
          Text(pending ? 'enviando…' : relativePtBr(c.createdAt), style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline)),
        ],
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 4),
        child: SpoilerBlur(hasSpoiler: c.hasSpoiler, child: Text(c.body, style: theme.textTheme.bodyMedium)),
      ),
      trailing: pending
          ? null
          : PopupMenuButton<String>(
              key: Key('comment-menu-${c.id}'),
              onSelected: (v) {
                if (v == 'delete') unawaited(remove());
                if (v == 'report') unawaited(showReportSheet(context, target: ReportTarget.comment, targetId: c.id));
              },
              itemBuilder: (_) => [
                if (canDelete) const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete_outline), title: Text('Apagar'))),
                if (!mine) const PopupMenuItem(value: 'report', child: ListTile(leading: Icon(Icons.flag_outlined), title: Text('Denunciar'))),
              ],
            ),
      isThreeLine: true,
    );
  }
}

class _Composer extends StatelessWidget {
  const _Composer({
    required this.controller,
    required this.spoiler,
    required this.sending,
    required this.onSpoilerChanged,
    required this.onSend,
  });

  final TextEditingController controller;
  final bool spoiler;
  final bool sending;
  final ValueChanged<bool> onSpoilerChanged;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      elevation: 3,
      color: theme.colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Tooltip(
                message: spoiler ? 'Marcado como spoiler' : 'Marcar como spoiler',
                child: IconButton(
                  key: const Key('comment-spoiler'),
                  isSelected: spoiler,
                  icon: const Icon(Icons.visibility_off_outlined),
                  selectedIcon: Icon(Icons.visibility_off, color: theme.colorScheme.primary),
                  onPressed: () => onSpoilerChanged(!spoiler),
                ),
              ),
              Expanded(
                child: TextField(
                  key: const Key('comment-field'),
                  controller: controller,
                  minLines: 1,
                  maxLines: 4,
                  maxLength: 1000,
                  textInputAction: TextInputAction.newline,
                  decoration: InputDecoration(
                    hintText: spoiler ? 'Comentário com spoiler…' : 'Comentar…',
                    counterText: '',
                    isDense: true,
                    border: const OutlineInputBorder(borderRadius: BorderRadius.all(Radius.circular(24))),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  ),
                ),
              ),
              IconButton(
                key: const Key('comment-send'),
                tooltip: 'Enviar',
                icon: const Icon(Icons.send),
                onPressed: sending ? null : onSend,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
