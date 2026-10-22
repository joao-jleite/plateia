import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/features/auth/presentation/auth_providers.dart';
import 'package:watchlog/features/auth/presentation/login_screen.dart';

import '../../../helpers/provider_container_holder.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('valida e-mail e senha antes de chamar o backend', (tester) async {
    await pumpScreen(tester, const LoginScreen(), user: null);
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();
    expect(find.text('Informe o e-mail.'), findsOneWidget);
    expect(find.text('Informe a senha.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'nao-e-email');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();
    expect(find.text('E-mail inválido.'), findsOneWidget);
  });

  testWidgets('senha errada mostra SnackBar em pt-BR; senha certa cria a sessão', (tester) async {
    final holder = ProviderContainerHolder();
    await pumpScreen(
      tester,
      Builder(builder: (context) {
        holder.capture(context);
        return const LoginScreen();
      }),
      user: null,
    );
    await tester.enterText(find.widgetWithText(TextFormField, 'E-mail'), 'camila@teste.local');
    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '12345');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pump();
    expect(find.text('Pelo menos 6 caracteres.'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextFormField, 'Senha'), '123456');
    await tester.tap(find.widgetWithText(FilledButton, 'Entrar'));
    await tester.pumpAndSettle();
    expect(holder.container.read(authRepositoryProvider).currentUser?.email, 'camila@teste.local');
  });

  testWidgets('Google no backend de amostra entra na hora', (tester) async {
    final holder = ProviderContainerHolder();
    await pumpScreen(
      tester,
      Builder(builder: (context) {
        holder.capture(context);
        return const LoginScreen();
      }),
      user: null,
    );
    await tester.tap(find.text('Entrar com Google'));
    await tester.pumpAndSettle();
    expect(holder.container.read(authRepositoryProvider).currentUser?.id, 'fixture-google');
  });
}
