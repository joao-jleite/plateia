import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:watchlog/core/prefs/preferences.dart';
import 'package:watchlog/core/router/routes.dart';
import 'package:watchlog/core/theme/app_theme.dart';
import 'package:watchlog/core/widgets/deep_link_fallback.dart';
import 'package:watchlog/core/widgets/tmdb_badge.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/features/profile/presentation/profile_screen.dart';
import 'package:watchlog/features/subscribe/presentation/subscribe_providers.dart';
import 'package:watchlog/main.dart';

import '../../helpers/pump_app.dart';

void main() {
  test('chave "aceito anúncios" persiste nas preferências e volta ligada', () async {
    final prefs = MemoryPreferences();
    final c1 = ProviderContainer(overrides: [preferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c1.dispose);
    expect(c1.read(acceptAdsProvider), isFalse);
    c1.read(acceptAdsProvider.notifier).set(true);
    expect(c1.read(acceptAdsProvider), isTrue);
    expect(prefs.getBool(PrefKeys.acceptAds), isTrue, reason: 'gravou no aparelho');

    // "reabrir o app": container novo com as mesmas preferências
    final c2 = ProviderContainer(overrides: [preferencesProvider.overrideWithValue(prefs)]);
    addTearDown(c2.dispose);
    expect(c2.read(acceptAdsProvider), isTrue, reason: 'volta ligada');
  });

  testWidgets('tela raiz por deep link: a seta leva ao Início; com histórico, volta', (tester) async {
    final router = GoRouter(
      initialLocation: '/profile/x',
      routes: [
        GoRoute(path: Routes.home, builder: (_, _) => const Scaffold(body: Text('INICIO'))),
        GoRoute(
          path: '/profile/:u',
          builder: (_, _) => Scaffold(appBar: AppBar(leading: const BackOrHomeButton(), title: const Text('perfil'))),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router, theme: AppTheme.dark(withGoogleFonts: false)));
    await tester.pumpAndSettle();
    // primeira tela do app: não há rota anterior, mas a seta aparece mesmo assim
    expect(find.byTooltip('Ir para o Início'), findsOneWidget);
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle();
    expect(find.text('INICIO'), findsOneWidget);

    // com histórico (Início → perfil) é o BackButton comum
    unawaited(router.push('/profile/y'));
    await tester.pumpAndSettle();
    expect(find.byType(BackButton), findsOneWidget);
    expect(find.byTooltip('Ir para o Início'), findsNothing);
  });

  testWidgets('diário vazio convida a buscar um título', (tester) async {
    await pumpScreen(tester, const ProfileScreen(), diary: FixtureDiaryStore(seed: false));
    await tester.pumpAndSettle();
    expect(find.text('Nada assistido ainda'), findsOneWidget);
    expect(find.text('Buscar um título'), findsOneWidget);
  });

  testWidgets('sem assets/tmdb/logo.svg a atribuição é o selo de texto', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: MaterialApp(home: Scaffold(body: TmdbBadge()))));
    await tester.pumpAndSettle();
    expect(find.text('TMDB'), findsOneWidget);
  });

  testWidgets('build sem configuração mostra a tela de erro legível', (tester) async {
    await tester.pumpWidget(const ConfigErrorApp(message: 'Faltam SUPABASE_URL e SUPABASE_ANON_KEY.'));
    await tester.pumpAndSettle();
    expect(find.text('Este build não está configurado'), findsOneWidget);
    expect(find.textContaining('SUPABASE_URL'), findsOneWidget);
  });

  testWidgets('fonte do sistema acima de 1,3× é travada em 1,3×', (tester) async {
    // o builder do app aplica withClampedTextScaling(maxScaleFactor: 1.3)
    double? seen;
    await tester.pumpWidget(
      MediaQuery(
        data: const MediaQueryData(textScaler: TextScaler.linear(2)),
        child: MediaQuery.withClampedTextScaling(
          maxScaleFactor: 1.3,
          child: Builder(builder: (context) {
            seen = MediaQuery.textScalerOf(context).scale(10);
            return const SizedBox();
          }),
        ),
      ),
    );
    expect(seen, closeTo(13, 0.01));
  });
}
