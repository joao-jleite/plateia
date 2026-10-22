import 'package:android_intent_plus/android_intent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../domain/watch_action.dart';

/// Executa a [WatchAction] no Android. Separado do widget para o teste de
/// widget substituir por um fake (provider abaixo).
abstract class StreamingLauncher {
  Future<void> open(WatchAction action);
}

class AndroidStreamingLauncher implements StreamingLauncher {
  const AndroidStreamingLauncher();

  @override
  Future<void> open(WatchAction action) async {
    switch (action.kind) {
      case WatchActionKind.deepLink:
      case WatchActionKind.search:
      case WatchActionKind.justwatch:
        // externalApplication: o Android entrega ao app do streaming (App Links
        // verificados) ou ao navegador, nunca a uma WebView dentro do nosso app.
        final ok = await launchUrl(action.uri!, mode: LaunchMode.externalApplication);
        if (!ok) throw Exception('Não foi possível abrir ${action.uri}');
      case WatchActionKind.appPackage:
        await _openPackageOrStore(action.package!);
    }
  }

  /// Disney+ não tem URL de busca: abre o app pelo pacote; sem o app, a Play Store.
  Future<void> _openPackageOrStore(String package) async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      final intent = AndroidIntent(
        action: 'android.intent.action.MAIN',
        category: 'android.intent.category.LAUNCHER',
        package: package,
      );
      if (await intent.canResolveActivity() ?? false) {
        await intent.launch();
        return;
      }
    }
    final market = Uri.parse('market://details?id=$package');
    if (!await launchUrl(market, mode: LaunchMode.externalApplication)) {
      await launchUrl(
        Uri.parse('https://play.google.com/store/apps/details?id=$package'),
        mode: LaunchMode.externalApplication,
      );
    }
  }
}

final streamingLauncherProvider =
    Provider<StreamingLauncher>((ref) => const AndroidStreamingLauncher());
