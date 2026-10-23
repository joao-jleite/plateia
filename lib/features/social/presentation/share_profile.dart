import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/router/routes.dart';
import '../../onboarding/domain/profile.dart';

/// Quem compartilha o texto (folha nativa do Android). Provider para os testes
/// de widget trocarem por um falso sem canal de plataforma.
final shareTextProvider = Provider<Future<void> Function(String text)>(
  (ref) => (text) async {
    await SharePlus.instance.share(ShareParams(text: text));
  },
);

/// Texto do convite: "@username" + o link `/u/:username` (SPEC §J4.1).
String profileShareText(Profile p) =>
    'Me siga no Plateia: @${p.username}\n${Routes.inviteUrl(p.username)}';

Future<void> shareProfile(WidgetRef ref, Profile p) => ref.read(shareTextProvider)(profileShareText(p));
