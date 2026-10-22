import 'package:freezed_annotation/freezed_annotation.dart';

part 'profile.freezed.dart';
part 'profile.g.dart';

/// Linha de `public.profiles` (1:1 com auth.users, criada por trigger).
@freezed
abstract class Profile with _$Profile {
  const Profile._();

  const factory Profile({
    required String id,
    required String username,
    String? displayName,
    String? bio,
    String? avatarUrl,
    @Default(false) bool isPrivate,
    @Default('BR') String region,
    DateTime? onboardedAt,
    DateTime? createdAt,
  }) = _Profile;

  factory Profile.fromJson(Map<String, dynamic> json) => _$ProfileFromJson(json);

  bool get isOnboarded => onboardedAt != null;

  /// O trigger cria `u_` + 10 hex do id; o onboarding pede a troca.
  bool get hasProvisionalUsername => RegExp(r'^u_[0-9a-f]{10}$').hasMatch(username);

  String get nameOrUsername =>
      (displayName != null && displayName!.trim().isNotEmpty) ? displayName!.trim() : '@$username';
}
