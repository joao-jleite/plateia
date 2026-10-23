import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../onboarding/domain/profile.dart';
import '../domain/social_models.dart';
import 'social_providers.dart';

/// Botão seguir / pedido enviado / seguindo (SPEC §J4.2), otimista com
/// desfazer: deixar de seguir mostra "Desfazer" no aviso. [compact] é a
/// versão curta para listas.
class FollowButton extends ConsumerWidget {
  const FollowButton({super.key, required this.profile, this.compact = false});

  final Profile profile;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(followStateProvider(profile.id));
    final status = state.value;
    final busy = state.isLoading && !state.hasValue;

    Future<void> tap() async {
      final notifier = ref.read(followStateProvider(profile.id).notifier);
      // um aviso por vez: o anterior sai para o novo (com "Desfazer") aparecer na hora
      final messenger = ScaffoldMessenger.of(context)..hideCurrentSnackBar();
      final current = status ?? FollowStatus.none;
      switch (current) {
        case FollowStatus.none:
          final error = await notifier.follow(targetIsPrivate: profile.isPrivate);
          if (error != null) {
            messenger.showSnackBar(SnackBar(content: Text('Não deu para seguir. ($error)')));
          } else if (profile.isPrivate) {
            messenger.showSnackBar(SnackBar(content: Text('Pedido enviado para @${profile.username}.')));
          }
        case FollowStatus.pending:
        case FollowStatus.accepted:
          final error = await notifier.unfollow();
          if (error != null) {
            messenger.showSnackBar(SnackBar(content: Text('Não deu para desfazer. ($error)')));
            return;
          }
          messenger.showSnackBar(SnackBar(
            content: Text(current == FollowStatus.pending ? 'Pedido cancelado.' : 'Você deixou de seguir @${profile.username}.'),
            action: SnackBarAction(label: 'Desfazer', onPressed: () => unawaited(notifier.follow(targetIsPrivate: profile.isPrivate))),
          ));
      }
    }

    final label = Text((status ?? FollowStatus.none).buttonLabel);
    final style = compact ? ButtonStyle(visualDensity: VisualDensity.compact, minimumSize: WidgetStateProperty.all(const Size(0, 36))) : null;
    final onPressed = busy ? null : () => unawaited(tap());
    final key = Key('follow-${profile.id}');

    return switch (status) {
      FollowStatus.accepted => FilledButton.tonal(key: key, style: style, onPressed: onPressed, child: label),
      FollowStatus.pending => OutlinedButton(key: key, style: style, onPressed: onPressed, child: label),
      _ => FilledButton(key: key, style: style, onPressed: onPressed, child: label),
    };
  }
}
