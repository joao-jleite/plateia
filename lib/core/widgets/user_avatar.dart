import 'package:flutter/material.dart';

import '../../features/onboarding/domain/profile.dart';
import 'poster_image.dart';

/// Foto redonda do perfil (ou o ícone de pessoa). [onTap] abre o perfil.
class UserAvatar extends StatelessWidget {
  const UserAvatar({super.key, required this.profile, this.size = 40, this.onTap});

  final Profile? profile;
  final double size;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = PosterImage(
      url: profile?.avatarUrl,
      width: size,
      height: size,
      borderRadius: size / 2,
      fallbackIcon: Icons.person,
    );
    if (onTap == null) return avatar;
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: avatar,
    );
  }
}
