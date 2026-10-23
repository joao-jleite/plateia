import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/router/app_router.dart';
import 'core/router/routes.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/domain/auth_user.dart';
import 'features/auth/presentation/auth_providers.dart';

class WatchlogApp extends ConsumerWidget {
  const WatchlogApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    // Link de redefinir senha abre o app já logado: leva à tela de nova senha.
    ref.listen(authAppEventsProvider, (_, next) {
      if (next.value == AuthAppEvent.passwordRecovery) router.push(Routes.newPassword);
    });

    return MaterialApp.router(
      title: 'Plateia',
      debugShowCheckedModeBanner: false,
      // Escuro por padrão (docs/DESIGN.md): app de filme; o tema claro existe
      // só como reserva para uma chave futura em Configurações.
      theme: AppTheme.dark(),
      darkTheme: AppTheme.dark(),
      themeMode: ThemeMode.dark,
      // Respeita a fonte do sistema até 1,3×; acima disso a grade de pôsteres
      // e os botões de uma linha quebrariam (acessibilidade sem layout estourado).
      builder: (context, child) => MediaQuery.withClampedTextScaling(
        maxScaleFactor: 1.3,
        child: child ?? const SizedBox.shrink(),
      ),
      locale: const Locale('pt', 'BR'),
      supportedLocales: const [Locale('pt', 'BR')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: router,
    );
  }
}
