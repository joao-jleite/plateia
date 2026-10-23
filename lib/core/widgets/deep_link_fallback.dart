import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../router/routes.dart';

/// Telas que podem ser a **primeira** do app (deep link de convite, notificação
/// do lembrete, link de título) não têm para onde "voltar": o Android fecharia
/// o app. Como `leading` da `AppBar`, este botão desenha a seta mesmo sem rota
/// anterior (o Material não desenharia) e, nesse caso, leva ao Início; o
/// `PopScope` faz o mesmo com o botão/gesto de voltar do sistema (ele vale para
/// a rota inteira, onde quer que esteja na árvore).
class BackOrHomeButton extends StatelessWidget {
  const BackOrHomeButton({super.key});

  @override
  Widget build(BuildContext context) {
    final canPop = GoRouter.of(context).canPop();
    return PopScope(
      canPop: canPop,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) context.go(Routes.home);
      },
      child: canPop
          ? const BackButton()
          : IconButton(
              tooltip: 'Ir para o Início',
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go(Routes.home),
            ),
    );
  }
}
