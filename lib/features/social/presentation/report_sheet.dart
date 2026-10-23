import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/social_models.dart';
import 'social_providers.dart';

/// Folha "Denunciar" (SPEC §5.10): motivo obrigatório, detalhes opcionais.
/// Serve para perfil, review (entrada), lista, comentário e atividade; a
/// denúncia vai para `reports` e o João trata pelo dashboard.
Future<void> showReportSheet(BuildContext context, {required ReportTarget target, required String targetId}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(ctx).bottom),
      child: _ReportSheet(target: target, targetId: targetId),
    ),
  );
}

class _ReportSheet extends ConsumerStatefulWidget {
  const _ReportSheet({required this.target, required this.targetId});

  final ReportTarget target;
  final String targetId;

  @override
  ConsumerState<_ReportSheet> createState() => _ReportSheetState();
}

class _ReportSheetState extends ConsumerState<_ReportSheet> {
  ReportReason? _reason;
  final _details = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final reason = _reason;
    if (reason == null) return;
    setState(() => _sending = true);
    final messenger = ScaffoldMessenger.of(context);
    final navigator = Navigator.of(context);
    final error = await ref.read(socialActionsProvider.notifier).report(
          target: widget.target,
          targetId: widget.targetId,
          reason: reason,
          details: _details.text,
        );
    if (!mounted) return;
    setState(() => _sending = false);
    if (error != null) {
      messenger.showSnackBar(SnackBar(content: Text('Não deu para enviar. ($error)')));
      return;
    }
    navigator.pop();
    messenger.showSnackBar(const SnackBar(content: Text('Denúncia enviada. Obrigado por avisar.')));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text('Denunciar ${widget.target.labelPtBr}', style: theme.textTheme.titleLarge),
          const SizedBox(height: 4),
          Text('Só você vê a denúncia. A moderação analisa e pode remover o conteúdo.',
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline)),
          const SizedBox(height: 8),
          RadioGroup<ReportReason>(
            groupValue: _reason,
            onChanged: (v) => setState(() => _reason = v),
            child: Column(
              children: [
                for (final r in ReportReason.values)
                  RadioListTile<ReportReason>(
                    key: Key('report-${r.name}'),
                    value: r,
                    dense: true,
                    title: Text(r.labelPtBr),
                  ),
              ],
            ),
          ),
          TextField(
            key: const Key('report-details'),
            controller: _details,
            maxLength: 1000,
            maxLines: 3,
            minLines: 1,
            decoration: const InputDecoration(labelText: 'Detalhes (opcional)', counterText: ''),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            key: const Key('report-send'),
            onPressed: _reason == null || _sending ? null : () => unawaited(_submit()),
            icon: const Icon(Icons.flag_outlined),
            label: Text(_sending ? 'Enviando…' : 'Enviar denúncia'),
          ),
        ],
      ),
    );
  }
}
