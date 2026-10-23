import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/features/import_netflix/presentation/import_screen.dart';
import 'package:watchlog/features/onboarding/presentation/my_profile_provider.dart';
import 'package:watchlog/features/onboarding/presentation/username_screen.dart';
import 'package:watchlog/features/social/presentation/onboarding_follow_screen.dart';

import '../../../helpers/provider_container_holder.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('sugere o @ a partir do nome, recusa @ em uso e salva o válido', (tester) async {
    final holder = ProviderContainerHolder();
    await pumpScreen(
      tester,
      Builder(builder: (context) {
        holder.capture(context);
        return const UsernameScreen();
      }),
      routes: {
        '/onboarding/import': (_) => const ImportScreen(onboarding: true),
        '/onboarding/follow': (_) => const OnboardingFollowScreen(),
      },
    );
    await tester.pumpAndSettle();

    final field = find.widgetWithText(TextFormField, 'Nome de usuário');
    expect(find.text('pessoa_teste'), findsOneWidget, reason: 'sugestão vinda do nome');

    await tester.enterText(field, 'foxer'); // reservado nas fixtures
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Já está em uso'), findsOneWidget);

    await tester.enterText(field, 'Camila_27');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Disponível'), findsOneWidget);

    // Fase 08: sem aceitar os termos não passa; a caixa fica em vermelho.
    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.byType(ImportScreen), findsNothing, reason: 'termos não aceitos');
    expect(find.text('Para continuar, aceite os termos e a política.'), findsOneWidget);
    await tester.tap(find.byKey(const Key('terms-checkbox')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('Continuar'));
    await tester.pumpAndSettle();
    expect(find.byType(ImportScreen), findsOneWidget);
    expect(holder.container.read(myProfileProvider).value?.username, 'camila_27');
    expect(holder.container.read(myProfileProvider).value?.hasAcceptedTerms, isTrue, reason: 'terms_accepted_at gravado');

    // "Agora não" leva à etapa de encontrar amigos (fase 06); "Concluir" fecha o onboarding.
    await tester.tap(find.text('Agora não'));
    await tester.pumpAndSettle();
    expect(find.byType(OnboardingFollowScreen), findsOneWidget);
    expect(holder.container.read(myProfileProvider).value?.isOnboarded, isFalse);
    await tester.tap(find.byKey(const Key('onboarding-finish')));
    await tester.pumpAndSettle();
    expect(holder.container.read(myProfileProvider).value?.isOnboarded, isTrue);
  });
}
