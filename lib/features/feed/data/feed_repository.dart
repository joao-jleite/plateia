import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/app_exception.dart';
import '../domain/activity.dart';

/// Feed, atividade, curtidas, comentários e check-ins. Leitura pela view
/// `feed` (quem eu sigo + eu; `security_invoker`, então a RLS de `activities`
/// continua filtrando bloqueio e perfil privado) e pela view `friends_checkins`
/// (migração 0005). Página de 30 por `range` (docs/ARQUITETURA.md §11).
abstract class FeedRepository {
  static const pageSize = 30;

  Future<List<Activity>> feedPage({int offset = 0, int limit = pageSize});

  /// Uma atividade pelo id (vinda de notificação, pode ser de quem não sigo:
  /// a RLS decide). Null se não existe ou não posso ver.
  Future<Activity?> activity(String id);

  /// Autor tira a própria atividade do feed.
  Future<void> deleteActivity(String id);

  Future<void> like(String activityId);
  Future<void> unlike(String activityId);

  Future<List<Comment>> comments(String activityId);
  Future<Comment> addComment(String activityId, String body, {bool hasSpoiler = false});

  /// Autor do comentário ou dono da atividade (RLS).
  Future<void> deleteComment(String commentId);

  /// Faixa "assistindo agora": meus check-ins ativos e dos que eu sigo.
  Future<List<Checkin>> friendsCheckins();

  /// Meu check-in ativo (um por vez), ou null.
  Future<Checkin?> myCheckin();

  /// Encerra o anterior e cria um novo (3 h).
  Future<Checkin> checkIn(CheckinDraft draft);
  Future<void> endCheckin(String id);
}

class SupabaseFeedRepository implements FeedRepository {
  SupabaseFeedRepository(this._client);

  final SupabaseClient _client;

  // A view `feed` herda os FKs de `activities`, então os embeds funcionam como
  // na tabela (um FK só para cada uma: sem precisar do nome da constraint).
  static const _activitySelect = '*, user:profiles(*), title:titles(*), list:lists(*), entry:entries(*)';
  static const _commentSelect = '*, user:profiles(*)';
  static const _checkinSelect = '*, user:profiles(*), title:titles(*)';

  String get _uid {
    final id = _client.auth.currentUser?.id;
    if (id == null) throw const AppException('unauthorized', 'Sessão expirada. Entre de novo.');
    return id;
  }

  @override
  Future<List<Activity>> feedPage({int offset = 0, int limit = FeedRepository.pageSize}) async {
    final rows = await _client
        .from('feed')
        .select(_activitySelect)
        .order('created_at', ascending: false)
        .range(offset, offset + limit - 1);
    return _withLikes(rows.map(Activity.fromJson).toList());
  }

  @override
  Future<Activity?> activity(String id) async {
    final row = await _client.from('activities').select(_activitySelect).eq('id', id).maybeSingle();
    if (row == null) return null;
    final list = await _withLikes([Activity.fromJson(row)]);
    return list.single;
  }

  /// Marca `likedByMe` consultando as minhas curtidas da página (uma chamada).
  Future<List<Activity>> _withLikes(List<Activity> items) async {
    if (items.isEmpty) return items;
    final rows = await _client
        .from('likes')
        .select('activity_id')
        .eq('user_id', _uid)
        .inFilter('activity_id', [for (final a in items) a.id]);
    final liked = {for (final r in rows) r['activity_id'] as String};
    return [for (final a in items) a.copyWith(likedByMe: liked.contains(a.id))];
  }

  @override
  Future<void> deleteActivity(String id) async {
    await _client.from('activities').delete().eq('id', id);
  }

  @override
  Future<void> like(String activityId) async {
    try {
      // ignoreDuplicates: curtir duas vezes (toque duplo) não duplica nem falha.
      await _client.from('likes').upsert(
        {'user_id': _uid, 'activity_id': activityId},
        onConflict: 'user_id,activity_id',
        ignoreDuplicates: true,
      );
    } on PostgrestException catch (e) {
      throw _translate(e, 'Não deu para curtir.');
    }
  }

  @override
  Future<void> unlike(String activityId) async {
    await _client.from('likes').delete().eq('user_id', _uid).eq('activity_id', activityId);
  }

  @override
  Future<List<Comment>> comments(String activityId) async {
    final rows = await _client.from('comments').select(_commentSelect).eq('activity_id', activityId).order('created_at');
    return rows.map(Comment.fromJson).toList();
  }

  @override
  Future<Comment> addComment(String activityId, String body, {bool hasSpoiler = false}) async {
    final error = validateCommentBody(body);
    if (error != null) throw AppException('invalid', error);
    try {
      final row = await _client
          .from('comments')
          .insert({'activity_id': activityId, 'user_id': _uid, 'body': body.trim(), 'has_spoiler': hasSpoiler})
          .select(_commentSelect)
          .single();
      return Comment.fromJson(row);
    } on PostgrestException catch (e) {
      throw _translate(e, 'Não deu para comentar.');
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    await _client.from('comments').delete().eq('id', commentId);
  }

  @override
  Future<List<Checkin>> friendsCheckins() async {
    final rows = await _client.from('friends_checkins').select(_checkinSelect).order('created_at', ascending: false);
    return rows.map(Checkin.fromJson).toList();
  }

  @override
  Future<Checkin?> myCheckin() async {
    final row = await _client
        .from('checkins')
        .select(_checkinSelect)
        .eq('user_id', _uid)
        .gt('expires_at', DateTime.now().toUtc().toIso8601String())
        .order('created_at', ascending: false)
        .limit(1)
        .maybeSingle();
    return row == null ? null : Checkin.fromJson(row);
  }

  @override
  Future<Checkin> checkIn(CheckinDraft draft) async {
    final error = validateCheckinNote(draft.note);
    if (error != null) throw AppException('invalid', error);
    final uid = _uid;
    // Um check-in por vez: os anteriores (ativos ou não) saem; a tabela não é histórico.
    await _client.from('checkins').delete().eq('user_id', uid);
    final note = draft.note?.trim();
    try {
      final row = await _client
          .from('checkins')
          .insert({
            'user_id': uid,
            'title_id': draft.titleId,
            'season': draft.season,
            'episode': draft.episode,
            'note': (note == null || note.isEmpty) ? null : note,
          })
          .select(_checkinSelect)
          .single();
      return Checkin.fromJson(row);
    } on PostgrestException catch (e) {
      throw _translate(e, 'Não deu para fazer o check-in.');
    }
  }

  @override
  Future<void> endCheckin(String id) async {
    await _client.from('checkins').delete().eq('id', id).eq('user_id', _uid);
  }

  static AppException _translate(PostgrestException e, String fallback) => switch (e.code) {
        // with check da policy: atividade invisível (bloqueio/privado) ou fora do meu nome
        '42501' => AppException('forbidden', 'Você não pode interagir com essa atividade.', cause: e),
        '23514' => AppException('invalid', 'Texto inválido ou longo demais.', cause: e),
        _ => AppException('internal', '$fallback ${describeError(e)}', cause: e),
      };
}
