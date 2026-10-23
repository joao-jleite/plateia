import 'package:flutter/foundation.dart';

import '../../core/errors/app_exception.dart';
import '../../core/model/media_type.dart';
import '../../features/catalog/domain/catalog_models.dart';
import '../../features/diary/domain/entry.dart';
import '../../features/import_netflix/data/import_repository.dart';
import '../../features/import_netflix/domain/grouper.dart';
import '../../features/import_netflix/domain/import_models.dart';
import '../../features/import_netflix/domain/matching_score.dart';
import '../../features/import_netflix/domain/merge.dart';
import '../../features/import_netflix/domain/text_normalize.dart';
import 'fixture_auth_repository.dart';
import 'fixture_data.dart';
import 'fixture_diary.dart';

/// Importação em memória. Imita a Edge Function `import-match` com a mesma
/// pontuação (`matching_score.dart`) sobre o catálogo de amostra, e as tabelas
/// `imports` / `import_candidates` com as mesmas regras de idempotência
/// (`on conflict do nothing` por título e por nome bruto). As entradas vão
/// para o `FixtureDiaryStore`, então a grade do perfil reflete a importação.
class FixtureImportRepository implements ImportRepository {
  FixtureImportRepository(
    this._store,
    this._auth, {
    this.latency = const Duration(milliseconds: 200),
    this.failWrites = false,
    DateTime Function()? clock,
  }) : _clock = clock ?? DateTime.now;

  final FixtureDiaryStore _store;
  final FixtureAuthRepository _auth;
  final Duration latency;
  final bool failWrites;
  final DateTime Function() _clock;

  final List<ImportRecord> imports = [];
  final List<ImportCandidateRow> candidates = [];
  int _seq = 0;

  /// Quantas "chamadas" à função foram feitas (para o log e os testes).
  int matchCalls = 0;

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    _store.ensureSeeded(user.id);
    return user.id;
  }

  Future<void> _write() async {
    await Future<void>.delayed(latency);
    if (failWrites) throw const AppException('internal', 'Simulação: o servidor recusou a gravação.');
  }

  // ---- import-match -------------------------------------------------------

  @override
  Future<List<ImportMatch>> match(List<ImportGroup> groups) async {
    _uid;
    if (groups.length > 100) throw const AppException('bad_request', 'Até 100 nomes por chamada.');
    await Future<void>.delayed(latency);
    matchCalls++;
    final matches = groups.map(matchGroup).toList();
    final tally = <MatchConfidence, int>{};
    for (final m in matches) {
      tally[m.confidence] = (tally[m.confidence] ?? 0) + 1;
    }
    debugPrint('[fixtures] {fn: import-match, user: fixture, ms: ${latency.inMilliseconds}, upstream_calls: ${groups.length}} '
        'items=${groups.length} high=${tally[MatchConfidence.high] ?? 0} medium=${tally[MatchConfidence.medium] ?? 0} low=${tally[MatchConfidence.low] ?? 0}');
    return matches;
  }

  /// Mesma estratégia da função: busca pelo nome; sem resultado e com ":",
  /// tenta sem o subtítulo; ainda nada e com alternativa, tenta a alternativa.
  static ImportMatch matchGroup(ImportGroup g) {
    var found = _search(g.rawName);
    if (found.isEmpty && g.rawName.contains(':')) found = _search(g.rawName.split(':').first);
    if (found.isEmpty && g.altQuery != null) found = _search(g.altQuery!);

    final exactRelevant = found.where((t) => isExactName(g.rawName, title: t.title, originalTitle: t.originalTitle)).length;
    final scored = found
        .map((t) => (
              title: t,
              score: scoreCandidate(
                rawName: g.rawName,
                guessedType: g.guessedType,
                title: t.title,
                originalTitle: t.originalTitle,
                mediaType: t.mediaType,
                resultYear: t.year,
                popularity: 100, // o catálogo de amostra só tem título conhecido
                exactRelevantCount: exactRelevant,
              ),
            ))
        .toList()
      ..sort((a, b) {
        final byScore = b.score.compareTo(a.score);
        return byScore != 0 ? byScore : (b.title.voteAverage ?? 0).compareTo(a.title.voteAverage ?? 0);
      });
    final top = scored.take(3).toList();
    final list = top
        .map((s) => ImportCandidate(
              titleId: s.title.id,
              tmdbId: s.title.tmdbId,
              mediaType: s.title.mediaType,
              title: s.title.title,
              year: s.title.year,
              posterPath: s.title.posterPath,
              score: s.score,
            ))
        .toList();
    final confidence = switch (confidenceFor(top.map((s) => s.score).toList())) {
      'high' => MatchConfidence.high,
      'medium' => MatchConfidence.medium,
      _ => MatchConfidence.low,
    };
    return ImportMatch(
      rawName: g.rawName,
      confidence: confidence,
      best: confidence == MatchConfidence.low ? null : list.firstOrNull,
      candidates: list,
    );
  }

  static List<Title> _search(String query) {
    final q = normalizeName(query);
    if (q.isEmpty) return const [];
    return fixtureTitles.map((f) => f.title).where((t) {
      final title = normalizeName(t.title);
      final original = normalizeName(t.originalTitle ?? '');
      return title == q || original == q || title.contains(q) || (original.isNotEmpty && original.contains(q)) || (title.length >= 4 && q.contains(title));
    }).toList();
  }

  // ---- imports ------------------------------------------------------------

  @override
  Future<ImportRecord?> lastDoneByHash(String fileHash) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    final mine = imports.where((i) => i.userId == uid && i.fileHash == fileHash && i.status == 'done').toList();
    if (mine.isEmpty) return null;
    mine.sort((a, b) => (b.finishedAt ?? DateTime(0)).compareTo(a.finishedAt ?? DateTime(0)));
    return mine.first;
  }

  @override
  Future<ImportRecord> start({required String fileHash, required int rowsTotal, required int titlesTotal}) async {
    final uid = _uid;
    await _write();
    final rec = ImportRecord(
      id: 'import-${(++_seq).toString().padLeft(3, '0')}',
      userId: uid,
      fileHash: fileHash,
      rowsTotal: rowsTotal,
      titlesTotal: titlesTotal,
      createdAt: _clock(),
    );
    imports.add(rec);
    return rec;
  }

  @override
  Future<ImportRecord> finish(String importId, {required int titlesMatched, required int titlesReview, required int titlesNew}) async {
    await _write();
    final i = imports.indexWhere((r) => r.id == importId);
    if (i < 0) throw const AppException('not_found', 'Importação não encontrada.');
    final wasDone = imports[i].status == 'done';
    imports[i] = imports[i].copyWith(
      status: 'done',
      titlesMatched: titlesMatched,
      titlesReview: titlesReview,
      titlesNew: titlesNew,
      finishedAt: _clock(),
    );
    // o trigger `imports_log_activity`: um evento `imported` só com título novo
    if (!wasDone && titlesNew > 0) importedEvents++;
    return imports[i];
  }

  /// Eventos `imported` que o trigger teria criado (para os testes).
  int importedEvents = 0;

  @override
  Future<void> fail(String importId) async {
    final i = imports.indexWhere((r) => r.id == importId);
    if (i >= 0) imports[i] = imports[i].copyWith(status: 'failed', finishedAt: _clock());
  }

  // ---- entries --------------------------------------------------------------

  @override
  Future<Map<String, Entry>> entriesForTitles(List<String> titleIds) async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    final out = <String, Entry>{};
    for (final id in titleIds) {
      final e = _store.entries[FixtureDiaryStore.key(uid, id)];
      if (e != null) out[id] = e;
    }
    return out;
  }

  @override
  Future<int> insertEntries(List<EntryInsert> rows) async {
    final uid = _uid;
    await _write();
    var n = 0;
    for (final r in rows) {
      if (_store.entries.containsKey(FixtureDiaryStore.key(uid, r.titleId))) continue; // do nothing
      _store.putImported(uid, r);
      n++;
    }
    return n;
  }

  @override
  Future<void> patchEntries(List<EntryPatch> patches) async {
    final uid = _uid;
    if (patches.isEmpty) return;
    await _write();
    for (final p in patches) {
      _store.patchImported(uid, p);
    }
  }

  // ---- import_candidates ------------------------------------------------------

  @override
  Future<void> addCandidates(String importId, List<CandidateInsert> rows) async {
    final uid = _uid;
    await _write();
    for (final r in rows) {
      // unique (user_id, raw_name): já perguntado (pendente, resolvido ou pulado) não entra de novo
      if (candidates.any((c) => c.userId == uid && c.rawName == r.rawName)) continue;
      candidates.add(ImportCandidateRow(
        id: 'cand-${(++_seq).toString().padLeft(3, '0')}',
        importId: importId,
        userId: uid,
        rawName: r.rawName,
        guessedType: r.guessedType,
        episodesCount: r.episodesCount,
        lastWatchedAt: r.lastWatchedAt,
        candidates: r.candidates,
        createdAt: _clock(),
      ));
    }
  }

  @override
  Future<List<ImportCandidateRow>> pendingCandidates() async {
    final uid = _uid;
    await Future<void>.delayed(latency);
    final mine = candidates.where((c) => c.userId == uid && c.isPending).toList()
      ..sort((a, b) => (b.lastWatchedAt ?? DateTime(0)).compareTo(a.lastWatchedAt ?? DateTime(0)));
    return mine;
  }

  @override
  Future<void> resolveCandidate(ImportCandidateRow row, ImportCandidate choice) async {
    final uid = _uid;
    await _write();
    final existing = await entriesForTitles([choice.titleId]);
    final plan = planMerge([
      ImportedTitle(
        titleId: choice.titleId,
        mediaType: choice.mediaType,
        lastWatchedAt: row.lastWatchedAt ?? _clock(),
        episodesCount: row.episodesCount,
      ),
    ], existing);
    for (final ins in plan.inserts) {
      _store.putImported(uid, ins);
    }
    for (final p in plan.patches) {
      _store.patchImported(uid, p);
    }
    final i = candidates.indexWhere((c) => c.id == row.id && c.userId == uid);
    if (i >= 0) candidates[i] = candidates[i].copyWith(resolvedTitleId: choice.titleId, resolvedAt: _clock());
  }

  @override
  Future<void> skipCandidate(String candidateId) async {
    final uid = _uid;
    await _write();
    final i = candidates.indexWhere((c) => c.id == candidateId && c.userId == uid);
    if (i >= 0) candidates[i] = candidates[i].copyWith(skipped: true);
  }

  /// Entradas do usuário logado que vieram da importação (testes e demonstração).
  List<Entry> importedEntries() {
    final uid = _uid;
    return _store.entries.values.where((e) => e.userId == uid && e.source == 'netflix_import').toList();
  }

  static MediaType? typeOf(String? s) => MediaType.tryParse(s);
}
