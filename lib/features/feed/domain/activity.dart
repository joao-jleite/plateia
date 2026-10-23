import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/domain/catalog_models.dart';
import '../../diary/domain/entry.dart';
import '../../lists/domain/list_models.dart';
import '../../onboarding/domain/profile.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

/// `activities.kind` (SPEC §5.5). Só triggers criam linhas.
enum ActivityKind {
  @JsonValue('watched')
  watched,
  @JsonValue('rated')
  rated,
  @JsonValue('reviewed')
  reviewed,
  @JsonValue('watching')
  watching,
  @JsonValue('list_created')
  listCreated,
  @JsonValue('imported')
  imported,
}

/// Linha da view `feed` (ou de `activities`) com os embeds que a tela usa:
/// autor, título, lista e a entrada do diário (review, nota, spoiler).
/// [likedByMe] é calculado no cliente (consulta a `likes` da página).
@freezed
abstract class Activity with _$Activity {
  const Activity._();

  const factory Activity({
    required String id,
    required String userId,
    required ActivityKind kind,
    String? titleId,
    String? entryId,
    String? listId,
    @Default(<String, dynamic>{}) Map<String, dynamic> payload,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    required DateTime createdAt,
    Profile? user,
    Title? title,
    ListModel? list,
    Entry? entry,
    @Default(false) bool likedByMe,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) => _$ActivityFromJson(json);

  /// Nota no momento do evento (o payload acompanha a edição dentro da hora).
  double? get rating {
    final r = payload['rating'];
    if (r is num) return r.toDouble();
    if (r is String) return double.tryParse(r);
    return null;
  }

  bool get isRewatch => payload['is_rewatch'] == true;
  bool get hasSpoiler => entry?.hasSpoiler ?? payload['has_spoiler'] == true;

  /// Texto da review (vem do embed de `entries`; a RLS decide se chega).
  String? get review => kind == ActivityKind.reviewed ? entry?.review : null;

  int get importedCount => switch (payload['count']) {
        final int n => n,
        final num n => n.toInt(),
        _ => 0,
      };

  String get listName => (payload['name'] as String?) ?? list?.name ?? 'lista';
}

/// Linha de `comments` com o autor embutido.
@freezed
abstract class Comment with _$Comment {
  const factory Comment({
    required String id,
    required String activityId,
    required String userId,
    required String body,
    @Default(false) bool hasSpoiler,
    DateTime? createdAt,
    DateTime? updatedAt,
    Profile? user,
  }) = _Comment;

  factory Comment.fromJson(Map<String, dynamic> json) => _$CommentFromJson(json);
}

/// Linha de `checkins` (ou da view `friends_checkins`) com autor e título.
@freezed
abstract class Checkin with _$Checkin {
  const Checkin._();

  const factory Checkin({
    required String id,
    required String userId,
    required String titleId,
    int? season,
    int? episode,
    String? note,
    DateTime? createdAt,
    required DateTime expiresAt,
    Profile? user,
    Title? title,
  }) = _Checkin;

  factory Checkin.fromJson(Map<String, dynamic> json) => _$CheckinFromJson(json);

  bool isActive([DateTime? now]) => expiresAt.isAfter(now ?? DateTime.now());

  /// "T21 E1050" quando informado.
  String? get progressLabel =>
      season == null ? null : 'T$season${episode != null ? ' E$episode' : ''}';
}

/// O que a folha de check-in manda gravar.
@freezed
abstract class CheckinDraft with _$CheckinDraft {
  const factory CheckinDraft({
    required String titleId,
    int? season,
    int? episode,
    String? note,
  }) = _CheckinDraft;
}

/// Nota do check-in: até 140 caracteres (check de `checkins.note`).
String? validateCheckinNote(String? raw) {
  if (raw == null) return null;
  return raw.trim().length > 140 ? 'No máximo 140 caracteres.' : null;
}

/// Comentário: 1 a 1000 caracteres (check de `comments.body`).
String? validateCommentBody(String raw) {
  final s = raw.trim();
  if (s.isEmpty) return 'Escreva algo.';
  if (s.length > 1000) return 'No máximo 1000 caracteres.';
  return null;
}
