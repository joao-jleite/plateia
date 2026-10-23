import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/router/routes.dart';
import '../../../core/utils/dates.dart';
import '../../onboarding/presentation/my_profile_provider.dart';
import '../data/csv_picker.dart';
import '../domain/import_pipeline.dart';
import 'import_progress.dart';
import 'import_providers.dart';

/// Importar o histórico da Netflix (SPEC §5.8). A mesma tela serve o
/// onboarding (`/onboarding/import`, com "Agora não") e o perfil (`/import`).
/// O arquivo é lido no aparelho e descartado; só os nomes agrupados vão ao
/// servidor.
class ImportScreen extends ConsumerStatefulWidget {
  const ImportScreen({super.key, this.onboarding = false});

  final bool onboarding;

  @override
  ConsumerState<ImportScreen> createState() => _ImportScreenState();
}

class _ImportScreenState extends ConsumerState<ImportScreen> {
  bool _finishing = false;

  Future<void> _pickAndImport() async {
    PickedCsv? file;
    try {
      file = await ref.read(csvPickerProvider).pick();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
      return;
    }
    if (file == null || !mounted) return;
    await _import(file);
  }

  Future<void> _importSample() async {
    final bytes = ref.read(sampleCsvProvider);
    if (bytes == null) return;
    await _import(PickedCsv(name: 'NetflixViewingHistory.csv', bytes: bytes));
  }

  Future<void> _import(PickedCsv file) async {
    final controller = ref.read(importControllerProvider.notifier);
    final prepared = await controller.prepare(file);
    if (prepared == null || !mounted) return;

    // "Você já importou este arquivo em DD/MM; importar de novo?"
    try {
      final previous = await ref.read(importRepositoryProvider).lastDoneByHash(prepared.fileHash);
      if (!mounted) return;
      if (previous != null) {
        final again = await _confirmReimport(previous.finishedAt ?? previous.createdAt);
        if (again != true) {
          controller.reset();
          return;
        }
      }
    } catch (e) {
      if (!mounted) return;
      controller.reset();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
      return;
    }

    // Exportação completa com mais de um perfil: a pessoa escolhe o dela.
    String? profile;
    if (prepared.parsed.profiles.length > 1) {
      profile = await _chooseProfile(prepared);
      if (profile == null) {
        controller.reset();
        return;
      }
    }
    if (!mounted) return;
    await controller.run(prepared, profile: profile);
  }

  Future<bool?> _confirmReimport(DateTime? when) => showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Arquivo já importado'),
          content: Text(
            'Você já importou este arquivo${when == null ? '' : ' em ${shortDatePtBr(when)}'}. '
            'Importar de novo não duplica nada: só atualiza datas e episódios do que veio da Netflix.',
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancelar')),
            FilledButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Importar de novo')),
          ],
        ),
      );

  Future<String?> _chooseProfile(PreparedCsv prepared) => showDialog<String>(
        context: context,
        builder: (ctx) => SimpleDialog(
          title: const Text('Qual perfil é o seu?'),
          children: [
            for (final p in prepared.parsed.profiles)
              SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, p),
                child: Text('$p · ${prepared.parsed.rowsFor(p).length} linhas'),
              ),
          ],
        ),
      );

  Future<void> _finishOnboarding({bool thenReview = false}) async {
    setState(() => _finishing = true);
    try {
      await ref.read(myProfileProvider.notifier).completeOnboarding();
      if (!mounted) return;
      if (thenReview) {
        // o router já deixa de redirecionar para o onboarding; vamos ao Início
        // e abrimos a revisão por cima
        context.go(Routes.home);
        unawaited(context.push(Routes.importReview));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(describeError(e))));
    } finally {
      if (mounted) setState(() => _finishing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final progress = ref.watch(importControllerProvider);
    final pending = ref.watch(pendingReviewCountProvider).value ?? 0;
    final sample = ref.watch(sampleCsvProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Importar da Netflix')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: switch (progress.phase) {
            ImportPhase.reading || ImportPhase.matching || ImportPhase.writing => _ProgressView(progress: progress),
            ImportPhase.done => _SummaryView(
                summary: progress.summary!,
                onboarding: widget.onboarding,
                finishing: _finishing,
                onReview: () => widget.onboarding ? _finishOnboarding(thenReview: true) : context.push(Routes.importReview),
                onAnother: () => ref.read(importControllerProvider.notifier).reset(),
                onFinish: () => widget.onboarding ? _finishOnboarding() : context.pop(),
              ),
            ImportPhase.idle || ImportPhase.failed => _IntroView(
                onboarding: widget.onboarding,
                error: progress.error,
                pending: pending,
                hasSample: sample != null,
                skipping: _finishing,
                onPick: _pickAndImport,
                onSample: _importSample,
                onReview: () => context.push(Routes.importReview),
                onSkip: _finishOnboarding,
              ),
          },
        ),
      ),
    );
  }
}

class _IntroView extends StatelessWidget {
  const _IntroView({
    required this.onboarding,
    required this.error,
    required this.pending,
    required this.hasSample,
    required this.skipping,
    required this.onPick,
    required this.onSample,
    required this.onReview,
    required this.onSkip,
  });

  final bool onboarding;
  final String? error;
  final int pending;
  final bool hasSample;
  final bool skipping;
  final VoidCallback onPick;
  final VoidCallback onSample;
  final VoidCallback onReview;
  final VoidCallback onSkip;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              const Icon(Icons.upload_file_outlined, size: 56),
              const SizedBox(height: 16),
              Text('Seu perfil pode nascer cheio', style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 8),
              Text(
                'Baixe seu histórico na Netflix em Conta → Perfis → Atividade de visualização → '
                '"Baixar tudo" e escolha o arquivo aqui. O arquivo é lido no seu aparelho e descartado; '
                'só os nomes dos títulos vão para o servidor.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Também aceitamos o ViewingActivity.csv da exportação completa da conta.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
              ),
              if (error != null) ...[
                const SizedBox(height: 20),
                Card(
                  color: theme.colorScheme.errorContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: theme.colorScheme.onErrorContainer),
                        const SizedBox(width: 12),
                        Expanded(child: Text(error!, style: TextStyle(color: theme.colorScheme.onErrorContainer))),
                      ],
                    ),
                  ),
                ),
              ],
              if (pending > 0) ...[
                const SizedBox(height: 20),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.rule_outlined),
                    title: Text(pending == 1 ? '1 título aguarda revisão' : '$pending títulos aguardam revisão'),
                    subtitle: const Text('Casos em que não tivemos certeza do título'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: onReview,
                  ),
                ),
              ],
            ],
          ),
        ),
        FilledButton.icon(
          onPressed: onPick,
          icon: const Icon(Icons.folder_open_outlined),
          label: const Text('Escolher arquivo'),
        ),
        if (hasSample) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: onSample,
            icon: const Icon(Icons.science_outlined),
            label: const Text('Usar CSV de exemplo (fixtures)'),
          ),
        ],
        if (onboarding) ...[
          const SizedBox(height: 8),
          TextButton(
            onPressed: skipping ? null : onSkip,
            child: skipping
                ? const SizedBox.square(dimension: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Agora não'),
          ),
        ],
      ],
    );
  }
}

class _ProgressView extends StatelessWidget {
  const _ProgressView({required this.progress});

  final ImportProgress progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (progress.phase) {
      ImportPhase.matching => '${progress.done} de ${progress.total} títulos',
      ImportPhase.writing => '${progress.total} títulos',
      _ => null,
    };
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(progress.message ?? 'Importando…', style: theme.textTheme.titleMedium, textAlign: TextAlign.center),
        const SizedBox(height: 16),
        LinearProgressIndicator(value: progress.fraction, minHeight: 8, borderRadius: BorderRadius.circular(4)),
        if (label != null) ...[
          const SizedBox(height: 8),
          Text(label, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
        ],
        const SizedBox(height: 24),
        Text(
          'Pode levar um minuto num histórico grande. O arquivo não sai do seu aparelho.',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
        ),
      ],
    );
  }
}

class _SummaryView extends StatelessWidget {
  const _SummaryView({
    required this.summary,
    required this.onboarding,
    required this.finishing,
    required this.onReview,
    required this.onAnother,
    required this.onFinish,
  });

  final ImportSummary summary;
  final bool onboarding;
  final bool finishing;
  final VoidCallback onReview;
  final VoidCallback onAnother;
  final VoidCallback onFinish;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final s = summary;
    final details = <String>[
      '${s.rowsTotal} linhas no arquivo → ${s.titlesTotal} séries e filmes',
      if (s.titlesNew > 0 || s.alreadyThere > 0)
        '${s.titlesNew} ${s.titlesNew == 1 ? 'novo' : 'novos'} no diário'
            '${s.alreadyThere > 0 ? ', ${s.alreadyThere} já ${s.alreadyThere == 1 ? 'estava' : 'estavam'}' : ''}'
            '${s.titlesUpdated > 0 ? ' (${s.titlesUpdated} com data atualizada)' : ''}',
      if (s.skippedRows > 0) '${s.skippedRows} linhas ignoradas (trailers, prévias ou sem data)',
      if (s.profile != null) 'Perfil: ${s.profile}',
      if (s.dateAmbiguous) 'Datas lidas como dia/mês (o arquivo não deixou confirmar)',
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Expanded(
          child: ListView(
            children: [
              Icon(Icons.check_circle_outline, size: 56, color: theme.colorScheme.primary),
              const SizedBox(height: 16),
              Text(s.headline, style: theme.textTheme.titleLarge, textAlign: TextAlign.center),
              const SizedBox(height: 16),
              for (final d in details)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.circle, size: 6, color: theme.colorScheme.outline),
                      const SizedBox(width: 10),
                      Expanded(child: Text(d, style: theme.textTheme.bodyMedium)),
                    ],
                  ),
                ),
              if (s.titlesReview > 0) ...[
                const SizedBox(height: 12),
                Text(
                  'Nos ${s.titlesReview == 1 ? 'caso' : 'casos'} para revisar, você escolhe entre 2–3 opções ou pula.',
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.outline),
                  textAlign: TextAlign.center,
                ),
              ],
            ],
          ),
        ),
        if (s.titlesReview > 0)
          FilledButton.icon(
            onPressed: finishing ? null : onReview,
            icon: const Icon(Icons.rule_outlined),
            label: Text('Revisar agora (${s.titlesReview})'),
          ),
        const SizedBox(height: 8),
        if (s.titlesReview > 0)
          OutlinedButton(onPressed: finishing ? null : onFinish, child: Text(onboarding ? 'Revisar depois' : 'Concluir'))
        else
          FilledButton(onPressed: finishing ? null : onFinish, child: Text(onboarding ? 'Continuar' : 'Concluir')),
        const SizedBox(height: 8),
        TextButton(onPressed: finishing ? null : onAnother, child: const Text('Importar outro arquivo')),
      ],
    );
  }
}
