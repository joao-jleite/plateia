import 'package:freezed_annotation/freezed_annotation.dart';

import '../../onboarding/domain/profile.dart';

part 'social_models.freezed.dart';
part 'social_models.g.dart';

/// Minha relação com um perfil (`follows.status` + "não sigo"). O cliente nunca
/// escolhe entre pending e accepted: o trigger decide pela privacidade do seguido.
enum FollowStatus {
  none,
  pending,
  accepted;

  static FollowStatus fromDb(String? status) => switch (status) {
        'pending' => FollowStatus.pending,
        'accepted' => FollowStatus.accepted,
        _ => FollowStatus.none,
      };

  /// Texto do botão no perfil (SPEC §J4.2).
  String get buttonLabel => switch (this) {
        FollowStatus.none => 'Seguir',
        FollowStatus.pending => 'Pedido enviado',
        FollowStatus.accepted => 'Seguindo',
      };
}

/// Pedido para me seguir (perfil privado): linha de `follows` pendente com o
/// cartão de quem pediu embutido (`follower:profiles!follows_follower_id_fkey`).
@freezed
abstract class FollowRequest with _$FollowRequest {
  const factory FollowRequest({
    required Profile follower,
    DateTime? createdAt,
  }) = _FollowRequest;

  factory FollowRequest.fromJson(Map<String, dynamic> json) => _$FollowRequestFromJson(json);
}

/// Linha da RPC `list_blocked_users()` (a RLS de `profiles` esconde essas pessoas
/// de mim; a RPC é o único lugar que as mostra).
@freezed
abstract class BlockedUser with _$BlockedUser {
  const BlockedUser._();

  const factory BlockedUser({
    required String id,
    required String username,
    String? displayName,
    String? avatarUrl,
    DateTime? blockedAt,
  }) = _BlockedUser;

  factory BlockedUser.fromJson(Map<String, dynamic> json) => _$BlockedUserFromJson(json);

  String get nameOrUsername =>
      (displayName != null && displayName!.trim().isNotEmpty) ? displayName!.trim() : '@$username';
}

/// `reports.target_type`.
enum ReportTarget {
  profile,
  entry,
  list,
  comment,
  activity;

  String get dbValue => name;

  String get labelPtBr => switch (this) {
        ReportTarget.profile => 'perfil',
        ReportTarget.entry => 'review',
        ReportTarget.list => 'lista',
        ReportTarget.comment => 'comentário',
        ReportTarget.activity => 'atividade',
      };
}

/// `reports.reason` (SPEC §5.10).
enum ReportReason {
  spam,
  harassment,
  hate,
  sexual,
  violence,
  spoiler,
  copyright,
  other;

  String get dbValue => name;

  String get labelPtBr => switch (this) {
        ReportReason.spam => 'Spam',
        ReportReason.harassment => 'Assédio ou bullying',
        ReportReason.hate => 'Discurso de ódio',
        ReportReason.sexual => 'Conteúdo sexual',
        ReportReason.violence => 'Violência',
        ReportReason.spoiler => 'Spoiler sem aviso',
        ReportReason.copyright => 'Direitos autorais',
        ReportReason.other => 'Outro',
      };
}
