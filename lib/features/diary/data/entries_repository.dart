import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/entry.dart';

/// Diário (`public.entries`). Leitura e escrita direto no PostgREST com o JWT
/// da sessão: a RLS decide o que aparece e o que pode ser gravado
/// (docs/ARQUITETURA.md §8).
abstract class EntriesRepository {
  /// Meu registro para o título, ou null se ainda não registrei.
  Future<Entry?> forTitle(String titleId);

  /// Upsert em (user_id, title_id). Devolve a linha gravada com o título embutido.
  Future<Entry> save(EntryDraft draft);

  /// Desmarcar: apaga a linha (as atividades do feed vão em cascata).
  Future<void> remove(String titleId);

  /// Diário de alguém, filtrado por status (ou só reviews), paginado.
  /// Quem não pode ver o conteúdo recebe lista vazia (RLS), não erro.
  Future<List<Entry>> byUser(
    String userId, {
    EntryStatus? status,
    bool onlyReviews = false,
    int offset = 0,
    int limit = 30,
  });
}

class SupabaseEntriesRepository implements EntriesRepository {
  SupabaseEntriesRepository(this._client);

  final SupabaseClient _client;

  static const _select = '*, title:titles(*)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  @override
  Future<Entry?> forTitle(String titleId) async {
    final row = await _client.from('entries').select(_select).eq('user_id', _uid).eq('title_id', titleId).maybeSingle();
    return row == null ? null : Entry.fromJson(row);
  }

  @override
  Future<Entry> save(EntryDraft draft) async {
    final d = draft.normalized();
    if (!isValidRating(d.rating)) {
      throw const AppException('invalid', 'Nota inválida: use meias estrelas de 0,5 a 5.');
    }
    try {
      final row = await _client
          .from('entries')
          .upsert({
            'user_id': _uid,
            'title_id': d.titleId,
            'status': d.status.dbValue,
            'rating': d.rating,
            'review': d.review,
            'has_spoiler': d.hasSpoiler,
            // coluna `date`: só a parte da data, no fuso local da pessoa
            'watched_at': d.watchedAt == null ? null : _dateOnly(d.watchedAt!),
            'current_season': d.currentSeason,
            'current_episode': d.currentEpisode,
            'episodes_watched': d.episodesWatched,
            'watch_count': d.watchCount,
          }, onConflict: 'user_id,title_id')
          .select(_select)
          .single();
      return Entry.fromJson(row);
    } on PostgrestException catch (e) {
      throw _translate(e);
    }
  }

  @override
  Future<void> remove(String titleId) async {
    await _client.from('entries').delete().eq('user_id', _uid).eq('title_id', titleId);
  }

  @override
  Future<List<Entry>> byUser(
    String userId, {
    EntryStatus? status,
    bool onlyReviews = false,
    int offset = 0,
    int limit = 30,
  }) async {
    var q = _client.from('entries').select(_select).eq('user_id', userId);
    if (status != null) q = q.eq('status', status.dbValue);
    if (onlyReviews) q = q.not('review', 'is', null);
    // Assisti: pela data informada (mais recente primeiro); o resto pela edição.
    final ordered = status == EntryStatus.watched
        ? q.order('watched_at', ascending: false, nullsFirst: false).order('updated_at', ascending: false)
        : q.order('updated_at', ascending: false);
    final rows = await ordered.range(offset, offset + limit - 1);
    return rows.map(Entry.fromJson).toList();
  }

  static String _dateOnly(DateTime d) {
    final l = d.toLocal();
    return '${l.year.toString().padLeft(4, '0')}-${l.month.toString().padLeft(2, '0')}-${l.day.toString().padLeft(2, '0')}';
  }

  static AppException _translate(PostgrestException e) => switch (e.code) {
        // check (status <> 'want' or rating/review null) e o check da nota
        '23514' => AppException('invalid', 'O servidor recusou: nota ou review inválidos para esse estado.', cause: e),
        '42501' => AppException('forbidden', 'Você só pode escrever no seu próprio diário.', cause: e),
        _ => AppException('internal', describeError(e), cause: e),
      };
}
