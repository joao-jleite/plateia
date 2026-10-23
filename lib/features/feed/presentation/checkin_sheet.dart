import 'dart:async';

import 'package:flutter/material.dart' hide Title;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/model/media_type.dart';
import '../../catalog/domain/catalog_models.dart';
import '../../diary/presentation/diary_providers.dart';
import '../domain/activity.dart';
import 'feed_providers.dart';

/// Botão "Assistindo agora" no detalhe do título: abre a folha do check-in
/// (3 h, com temporada/episódio para série e uma nota curta). Com um check-in
/// ativo neste título, vira "Encerrar".
class CheckinButton extends ConsumerWidget {
  const CheckinButton({super.key, required this.title});

  final Title title;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mine = ref.watch(myCheckinProvider).value;
    final activeHere = mine != null && mine.titleId == title.id && mine.isActive();

    Future<void> end() async {
      final messenger = ScaffoldMessenger.of(context);
      final error = await ref.read(myCheckinProvider.notifier).end();
      if (error != null) messenger.showSnackBar(SnackBar(content: Text('Não deu para encerrar. ($error)')));
    }

    return OutlinedButton.icon(
      key: const Key('checkin-button'),
      onPressed: activeHere ? () => unawaited(end()) : () => showCheckinSheet(context, title: title),
      icon: Icon(activeHere ? Icons.stop_circle_outlined : Icons.play_circle_outline),
      label: Text(activeHere ? 'Assistindo agora · Encerrar' : 'Assistindo agora'),
    );
  }
}

Future<void> showCheckinSheet(BuildContext context, {required Title title}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: _CheckinSheet(title: title),
    ),
  );
}

class _CheckinSheet extends ConsumerStatefulWidget {
  const _CheckinSheet({required this.title});

  final Title title;

  @override
  ConsumerState<_CheckinSheet> createState() => _CheckinSheetState();
}

class _CheckinSheetState extends ConsumerState<_CheckinSheet> {
  final _season = TextEditingController();
  final _episode = TextEditingController();
  final _note = TextEditingController();
  bool _saving = false;
  String? _error;

  bool get _isTv => widget.title.mediaType == MediaType.tv;

  @override
  void initState() {
    super.initState();
    // sugere o progresso do diário ("Assistindo em T21 E1050")
    final entry = ref.read(entryForTitleProvider(widget.title.id)).value;
    if (entry?.currentSeason != null) _season.text = '${entry!.currentSeason}';
    if (entry?.currentEpisode != null) _episode.text = '${entry!.currentEpisode}';
  }

  @override
  void dispose() {
    _season.dispose();
    _episode.dispose();
    _note.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final noteError = validateCheckinNote(_note.text);
    if (noteError != null) {
      setState(() => _error = noteError);
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    final draft = CheckinDraft(
      titleId: widget.title.id,
      season: _isTv ? int.tryParse(_season.text.trim()) : null,
      episode: _isTv ? int.tryParse(_episode.text.trim()) : null,
      note: _note.text.trim().isEmpty ? null : _note.text.trim(),
    );
    final messenger = ScaffoldMessenger.of(context);
    final error = await ref.read(myCheckinProvider.notifier).checkIn(draft);
    if (!mounted) return;
    if (error != null) {
      setState(() {
        _saving = false;
        _error = error;
      });
      return;
    }
    Navigator.of(context).pop();
    messenger.showSnackBar(const SnackBar(content: Text('Check-in feito. Seus amigos veem por 3 horas.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Assistindo agora', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text(widget.title.title, style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 16),
          if (_isTv) ...[
            Row(
              children: [
                Expanded(
                  child: TextField(
                    key: const Key('checkin-season'),
                    controller: _season,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Temporada'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    key: const Key('checkin-episode'),
                    controller: _episode,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Episódio'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          TextField(
            key: const Key('checkin-note'),
            controller: _note,
            maxLength: 140,
            decoration: const InputDecoration(labelText: 'Uma frase (opcional)', hintText: 'Ex.: maratona de domingo'),
            onChanged: (_) => setState(() => _error = null),
          ),
          if (_error != null) ...[
            const SizedBox(height: 4),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _saving ? null : () => unawaited(_submit()),
            icon: const Icon(Icons.play_circle_outline),
            label: Text(_saving ? 'Gravando…' : 'Fazer check-in (3 h)'),
          ),
          const SizedBox(height: 4),
          Text(
            'Aparece na faixa "Assistindo agora" de quem segue você e expira sozinho.',
            style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.outline),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
