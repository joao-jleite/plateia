import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show compute, debugPrint;
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../diary/presentation/diary_providers.dart';
import '../data/csv_picker.dart';
import '../data/import_repository.dart';
import '../domain/import_models.dart';
import '../domain/import_pipeline.dart';
import '../domain/merge.dart';
import '../domain/netflix_csv.dart';
import 'import_progress.dart';

part 'import_providers.g.dart';

/// Com `BACKEND=fixtures` este provider é sobrescrito em `main.dart`.
@Riverpod(keepAlive: true)
ImportRepository importRepository(Ref ref) => SupabaseImportRepository(ref.watch(supabaseClientProvider));

@Riverpod(keepAlive: true)
CsvPicker csvPicker(Ref ref) => FilePickerCsvPicker();

/// Roda uma função pura fora da thread da interface. Produção = `compute`
/// (isolate); testes de widget trocam por [inlineRunner], porque o isolate não
/// termina dentro do tempo falso do `testWidgets`.
typedef BackgroundRunner = Future<R> Function<Q, R>(R Function(Q) fn, Q arg);

Future<R> computeRunner<Q, R>(R Function(Q) fn, Q arg) => compute(fn, arg);
Future<R> inlineRunner<Q, R>(R Function(Q) fn, Q arg) async => fn(arg);

@Riverpod(keepAlive: true)
BackgroundRunner backgroundRunner(Ref ref) => computeRunner;

/// CSV de exemplo para demonstrar o fluxo sem arquivo (só o backend de
/// fixtures preenche; null esconde o botão na tela).
@Riverpod(keepAlive: true)
Uint8List? sampleCsv(Ref ref) => null;

/// Fila de revisão (`import_candidates` pendentes). Resolver e pular são
/// otimistas: a linha some na hora e volta se o servidor recusar.
@riverpod
class PendingReview extends _$PendingReview {
  @override
  Future<List<ImportCandidateRow>> build() => ref.watch(importRepositoryProvider).pendingCandidates();

  Future<String?> resolve(ImportCandidateRow row, ImportCandidate choice) => _apply(row, () async {
        await ref.read(importRepositoryProvider).resolveCandidate(row, choice);
        ref.read(diaryVersionProvider.notifier).bump();
      });

  Future<String?> skip(ImportCandidateRow row) => _apply(row, () => ref.read(importRepositoryProvider).skipCandidate(row.id));

  Future<String?> _apply(ImportCandidateRow row, Future<void> Function() action) async {
    final previous = state;
    state = AsyncData((previous.value ?? const []).where((r) => r.id != row.id).toList());
    try {
      await action();
      return null;
    } catch (e) {
      state = previous;
      return describeError(e);
    }
  }
}

/// Quantos títulos esperam revisão (banner na tela de importar e nas configurações).
@riverpod
Future<int> pendingReviewCount(Ref ref) async => (await ref.watch(pendingReviewProvider.future)).length;

/// Nomes por chamada de `import-match` (limite da função é 100). Se no projeto
/// real um lote estourar o tempo da Edge Function, baixe aqui (50) sem mexer
/// no servidor.
const matchBatchSize = 100;

/// A importação em si (SPEC §5.8, J1.4): ler → agrupar → casar (≤ 100 por
/// chamada) → gravar (merge) → candidatos → resumo. Guarda o progresso para a
/// tela; nunca guarda o arquivo.
@riverpod
class ImportController extends _$ImportController {
  @override
  ImportProgress build() => const ImportProgress();

  /// Lê e interpreta o arquivo fora da thread da interface. Null em erro (o
  /// estado vira `failed` com a mensagem).
  Future<PreparedCsv?> prepare(PickedCsv file) async {
    state = ImportProgress(phase: ImportPhase.reading, message: 'Lendo ${file.name}…');
    try {
      final run = ref.read(backgroundRunnerProvider);
      final prepared = await run(prepareCsv, PrepareCsvInput(bytes: file.bytes, fileName: file.name));
      if (prepared.parsed.rows.isEmpty) {
        state = const ImportProgress(phase: ImportPhase.failed, error: 'O arquivo não tem nenhuma linha de histórico válida.');
        return null;
      }
      state = const ImportProgress();
      return prepared;
    } on NetflixCsvFormatException catch (e) {
      state = ImportProgress(phase: ImportPhase.failed, error: e.message);
      return null;
    } catch (e) {
      state = ImportProgress(phase: ImportPhase.failed, error: describeError(e));
      return null;
    }
  }

  Future<void> run(PreparedCsv prepared, {String? profile}) async {
    final repo = ref.read(importRepositoryProvider);
    String? importId;
    try {
      state = const ImportProgress(phase: ImportPhase.reading, message: 'Agrupando por série e filme…');
      final groups = await ref.read(backgroundRunnerProvider)(groupPrepared, GroupInput(parsed: prepared.parsed, profile: profile));
      if (groups.isEmpty) {
        state = const ImportProgress(phase: ImportPhase.failed, error: 'Nenhum título encontrado nesse perfil.');
        return;
      }

      final record = await repo.start(fileHash: prepared.fileHash, rowsTotal: prepared.parsed.rowsTotal, titlesTotal: groups.length);
      importId = record.id;

      // 1) casar, em lotes de 100 (limite da função), mostrando o avanço
      state = ImportProgress(phase: ImportPhase.matching, done: 0, total: groups.length, message: 'Procurando no catálogo…');
      final matches = <ImportMatch>[];
      for (var i = 0; i < groups.length; i += matchBatchSize) {
        final chunk = groups.sublist(i, (i + matchBatchSize).clamp(0, groups.length));
        matches.addAll(await repo.match(chunk));
        state = state.copyWith(done: (i + chunk.length).clamp(0, groups.length));
      }

      // 2) separar: high entra no diário; medium/low vão para a revisão
      final byName = {for (final g in groups) g.rawName: g};
      final imported = <ImportedTitle>[];
      final review = <CandidateInsert>[];
      for (final m in matches) {
        final g = byName[m.rawName];
        if (g == null) continue;
        final best = m.best;
        if (m.confidence.isAutomatic && best != null) {
          imported.add(ImportedTitle(titleId: best.titleId, mediaType: best.mediaType, lastWatchedAt: g.lastWatchedAt, episodesCount: g.episodesCount));
        } else {
          review.add(CandidateInsert(
            rawName: g.rawName,
            guessedType: g.guessedType,
            episodesCount: g.episodesCount,
            lastWatchedAt: g.lastWatchedAt,
            candidates: m.candidates,
          ));
        }
      }

      // 3) gravar sem sobrescrever o que foi editado à mão (merge.dart)
      state = ImportProgress(phase: ImportPhase.writing, done: groups.length, total: groups.length, message: 'Gravando no diário…');
      final existing = await repo.entriesForTitles(imported.map((t) => t.titleId).toSet().toList());
      final plan = planMerge(imported, existing);
      final inserted = await repo.insertEntries(plan.inserts);
      await repo.patchEntries(plan.patches);
      await repo.addCandidates(importId, review);
      // "para revisar" = o que ficou pendente de verdade: um nome já resolvido
      // ou pulado numa importação anterior não volta à fila (unique por nome).
      final reviewNames = review.map((r) => r.rawName).toSet();
      final reviewPending = (await repo.pendingCandidates()).where((c) => reviewNames.contains(c.rawName)).length;
      await repo.finish(importId, titlesMatched: imported.length, titlesReview: reviewPending, titlesNew: inserted);

      ref.read(diaryVersionProvider.notifier).bump();
      ref.invalidate(pendingReviewProvider);
      // Linha para medir a % de casamento automático no CSV real (PENDENCIAS-JOAO, fase 05).
      final rate = groups.isEmpty ? 0 : (100 * imported.length / groups.length).round();
      debugPrint('[import] rows=${prepared.parsed.rowsTotal} groups=${groups.length} high=${imported.length} '
          'review=${review.length} pending=$reviewPending new=$inserted updated=${plan.patches.length} auto_match=$rate%');
      state = ImportProgress(
        phase: ImportPhase.done,
        done: groups.length,
        total: groups.length,
        summary: ImportSummary(
          importId: importId,
          rowsTotal: prepared.parsed.rowsTotal,
          titlesTotal: groups.length,
          titlesMatched: imported.length,
          titlesReview: reviewPending,
          titlesNew: inserted,
          titlesUpdated: plan.patches.length,
          skippedRows: prepared.parsed.skipped,
          dateAmbiguous: prepared.parsed.dateAmbiguous,
          profile: profile,
        ),
      );
    } catch (e) {
      if (importId != null) unawaited(repo.fail(importId).catchError((_) {}));
      state = ImportProgress(phase: ImportPhase.failed, error: describeError(e));
    }
  }

  void reset() => state = const ImportProgress();
}
