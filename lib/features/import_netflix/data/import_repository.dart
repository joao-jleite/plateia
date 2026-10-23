import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../../../core/model/media_type.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../diary/domain/entry.dart';
import '../domain/grouper.dart';
import '../domain/import_models.dart';
import '../domain/merge.dart';

/// Um nome do CSV que vai para a revisão (`import_candidates`).
class CandidateInsert {
  const CandidateInsert({
    required this.rawName,
    required this.guessedType,
    required this.episodesCount,
    required this.lastWatchedAt,
    required this.candidates,
  });

  final String rawName;
  final MediaType? guessedType;
  final int episodesCount;
  final DateTime lastWatchedAt;
  final List<ImportCandidate> candidates;

  Map<String, Object?> toJson(String userId, String importId) => {
        'user_id': userId,
        'import_id': importId,
        'raw_name': rawName,
        'guessed_type': guessedType?.path,
        'episodes_count': episodesCount,
        'last_watched_at': dateOnly(lastWatchedAt),
        'candidates': candidates.map((c) => c.toJson()).toList(),
      };
}

/// Tudo o que a importação grava ou lê no servidor. O CSV nunca passa por aqui:
/// só nomes agrupados (para a Edge Function) e o resultado (diário, resumo,
/// candidatos). Leitura e escrita de dado do usuário vão direto no PostgREST
/// com a RLS (docs/ARQUITETURA.md §8).
abstract class ImportRepository {
  /// Edge Function `import-match` (≤ 100 nomes por chamada; quem chama fatia).
  Future<List<ImportMatch>> match(List<ImportGroup> groups);

  /// Última importação concluída deste mesmo arquivo ("você já importou em DD/MM").
  Future<ImportRecord?> lastDoneByHash(String fileHash);

  Future<ImportRecord> start({required String fileHash, required int rowsTotal, required int titlesTotal});

  Future<ImportRecord> finish(
    String importId, {
    required int titlesMatched,
    required int titlesReview,
    required int titlesNew,
  });

  Future<void> fail(String importId);

  /// Meus registros para estes títulos (para a regra de merge).
  Future<Map<String, Entry>> entriesForTitles(List<String> titleIds);

  /// `on conflict (user_id, title_id) do nothing`. Devolve quantos entraram.
  Future<int> insertEntries(List<EntryInsert> rows);

  Future<void> patchEntries(List<EntryPatch> patches);

  /// `on conflict (user_id, raw_name) do nothing`: reimportar não repete a pergunta.
  Future<void> addCandidates(String importId, List<CandidateInsert> rows);

  Future<List<ImportCandidateRow>> pendingCandidates();

  /// Escolher um candidato grava a entrada (mesma regra de merge) e resolve o candidato.
  Future<void> resolveCandidate(ImportCandidateRow row, ImportCandidate choice);

  Future<void> skipCandidate(String candidateId);
}

class SupabaseImportRepository implements ImportRepository {
  SupabaseImportRepository(this._client);

  final SupabaseClient _client;

  /// Tamanho das páginas de escrita/leitura em lote (URL do PostgREST tem limite).
  static const _chunk = 100;

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  @override
  Future<List<ImportMatch>> match(List<ImportGroup> groups) async {
    if (groups.isEmpty) return const [];
    final json = await invokeFunction(_client, 'import-match', body: {
      'items': groups.map((g) => g.toRequestJson()).toList(),
    });
    return ImportMatchResponse.fromJson(json).matches;
  }

  @override
  Future<ImportRecord?> lastDoneByHash(String fileHash) async {
    final row = await _client
        .from('imports')
        .select()
        .eq('user_id', _uid)
        .eq('file_hash', fileHash)
        .eq('status', 'done')
        .order('finished_at', ascending: false, nullsFirst: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : ImportRecord.fromJson(row);
  }

  @override
  Future<ImportRecord> start({required String fileHash, required int rowsTotal, required int titlesTotal}) async {
    final row = await _client
        .from('imports')
        .insert({'user_id': _uid, 'file_hash': fileHash, 'rows_total': rowsTotal, 'titles_total': titlesTotal})
        .select()
        .single();
    return ImportRecord.fromJson(row);
  }

  @override
  Future<ImportRecord> finish(String importId, {required int titlesMatched, required int titlesReview, required int titlesNew}) async {
    final row = await _client
        .from('imports')
        .update({
          'status': 'done',
          'titles_matched': titlesMatched,
          'titles_review': titlesReview,
          'titles_new': titlesNew,
          'finished_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', importId)
        .eq('user_id', _uid)
        .select()
        .single();
    return ImportRecord.fromJson(row);
  }

  @override
  Future<void> fail(String importId) async {
    await _client
        .from('imports')
        .update({'status': 'failed', 'finished_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', importId)
        .eq('user_id', _uid);
  }

  @override
  Future<Map<String, Entry>> entriesForTitles(List<String> titleIds) async {
    final uid = _uid;
    final out = <String, Entry>{};
    for (var i = 0; i < titleIds.length; i += _chunk) {
      final ids = titleIds.sublist(i, (i + _chunk).clamp(0, titleIds.length));
      final rows = await _client.from('entries').select().eq('user_id', uid).inFilter('title_id', ids);
      for (final r in rows) {
        final e = Entry.fromJson(r);
        out[e.titleId] = e;
      }
    }
    return out;
  }

  @override
  Future<int> insertEntries(List<EntryInsert> rows) async {
    final uid = _uid;
    var inserted = 0;
    for (var i = 0; i < rows.length; i += _chunk) {
      final page = rows.sublist(i, (i + _chunk).clamp(0, rows.length));
      // ignoreDuplicates = DO NOTHING; o `select` só devolve as linhas que entraram.
      final back = await _client
          .from('entries')
          .upsert(page.map((r) => r.toJson(uid)).toList(), onConflict: 'user_id,title_id', ignoreDuplicates: true)
          .select('title_id');
      inserted += back.length;
    }
    return inserted;
  }

  @override
  Future<void> patchEntries(List<EntryPatch> patches) async {
    final uid = _uid;
    for (final p in patches) {
      if (p.isEmpty) continue;
      await _client.from('entries').update(p.toJson()).eq('id', p.entryId).eq('user_id', uid);
    }
  }

  @override
  Future<void> addCandidates(String importId, List<CandidateInsert> rows) async {
    final uid = _uid;
    for (var i = 0; i < rows.length; i += _chunk) {
      final page = rows.sublist(i, (i + _chunk).clamp(0, rows.length));
      await _client
          .from('import_candidates')
          .upsert(page.map((r) => r.toJson(uid, importId)).toList(), onConflict: 'user_id,raw_name', ignoreDuplicates: true);
    }
  }

  @override
  Future<List<ImportCandidateRow>> pendingCandidates() async {
    final rows = await _client
        .from('import_candidates')
        .select()
        .eq('user_id', _uid)
        .isFilter('resolved_at', null)
        .eq('skipped', false)
        .order('last_watched_at', ascending: false, nullsFirst: false)
        .order('created_at');
    return rows.map(ImportCandidateRow.fromJson).toList();
  }

  @override
  Future<void> resolveCandidate(ImportCandidateRow row, ImportCandidate choice) async {
    final uid = _uid;
    final existing = await entriesForTitles([choice.titleId]);
    final plan = planMerge([
      ImportedTitle(
        titleId: choice.titleId,
        mediaType: choice.mediaType,
        lastWatchedAt: row.lastWatchedAt ?? DateTime.now(),
        episodesCount: row.episodesCount,
      ),
    ], existing);
    await insertEntries(plan.inserts);
    await patchEntries(plan.patches);
    await _client
        .from('import_candidates')
        .update({'resolved_title_id': choice.titleId, 'resolved_at': DateTime.now().toUtc().toIso8601String()})
        .eq('id', row.id)
        .eq('user_id', uid);
  }

  @override
  Future<void> skipCandidate(String candidateId) async {
    await _client.from('import_candidates').update({'skipped': true}).eq('id', candidateId).eq('user_id', _uid);
  }
}
