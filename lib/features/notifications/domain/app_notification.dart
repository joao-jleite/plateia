import 'package:freezed_annotation/freezed_annotation.dart';

import '../../feed/domain/activity.dart';
import '../../onboarding/domain/profile.dart';

part 'app_notification.freezed.dart';
part 'app_notification.g.dart';

/// `notifications.kind`. Push fica para depois (SPEC §6): estas são só in-app.
enum NotificationKind {
  @JsonValue('follow')
  follow,
  @JsonValue('follow_request')
  followRequest,
  @JsonValue('follow_accepted')
  followAccepted,
  @JsonValue('like')
  like,
  @JsonValue('comment')
  comment,
}

/// Linha de `notifications` com quem causou e, quando houver, a atividade e o
/// comentário embutidos (`actor:profiles!notifications_actor_id_fkey`).
@freezed
abstract class AppNotification with _$AppNotification {
  const AppNotification._();

  const factory AppNotification({
    required String id,
    required String userId,
    String? actorId,
    required NotificationKind kind,
    String? activityId,
    String? commentId,
    DateTime? readAt,
    required DateTime createdAt,
    Profile? actor,
    Activity? activity,
    Comment? comment,
  }) = _AppNotification;

  factory AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

  bool get isUnread => readAt == null;

  /// Texto da linha, sem o nome de quem causou (ele vai em negrito na tela).
  String get phrase => switch (kind) {
        NotificationKind.follow => 'começou a seguir você',
        NotificationKind.followRequest => 'pediu para seguir você',
        NotificationKind.followAccepted => 'aceitou seu pedido',
        NotificationKind.like => 'curtiu ${_what()}',
        // comentário com spoiler não vaza o texto na lista: a pessoa abre a atividade e decide
        NotificationKind.comment => comment == null
            ? 'comentou em ${_what()}'
            : comment!.hasSpoiler
                ? 'comentou em ${_what()} (contém spoiler)'
                : 'comentou em ${_what()}: "${_short(comment!.body)}"',
      };

  String _what() {
    final t = activity?.title?.title;
    if (activity?.kind == ActivityKind.reviewed) return t == null ? 'sua review' : 'sua review de $t';
    if (activity?.kind == ActivityKind.listCreated) return 'sua lista ${activity!.listName}';
    return t == null ? 'sua atividade' : 'sua atividade em $t';
  }

  static String _short(String s) => s.length <= 60 ? s : '${s.substring(0, 57)}…';
}
