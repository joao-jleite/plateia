import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/core/utils/clock.dart';
import 'package:watchlog/dev/fixtures/fixture_catalog_repository.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_social.dart';
import 'package:watchlog/features/subscribe/presentation/my_subscriptions_screen.dart';
import 'package:watchlog/features/subscribe/presentation/subscribe_providers.dart';
import 'package:watchlog/features/subscribe/presentation/subscribe_screen.dart';
import 'package:watchlog/features/title/presentation/title_screen.dart';

import '../../../helpers/pump_app.dart';

/// Data fixa: as atividades de amostra dos amigos são de outubro de 2026 e a
/// janela é de 30 dias.
final fixedNow = DateTime(2026, 10, 23, 12);
final clockOverride = clockProvider.overrideWithValue(() => fixedNow);

void main() {
  testWidgets('diário vazio: estado vazio com atalho para a busca', (tester) async {
    await pumpScreen(tester, const SubscribeScreen(), diary: FixtureDiaryStore(seed: false), overrides: [clockOverride]);
    await tester.pumpAndSettle();
    expect(find.text('Sua lista está vazia'), findsOneWidget);
    expect(find.text('Buscar títulos'), findsOneWidget);
  });

  testWidgets('diário de amostra: frase, conta aberta, de fora, aluguel à parte, sem dados e data dos preços', (tester) async {
    // Conta do diário de amostra (fixture_diary.dart, usuário por e-mail), 9 candidatos meus:
    //   HBO Max: The Last of Us, Succession, The White Lotus → 3 (R$ 39,90 → R$ 13,30/título)
    //   Netflix: One Piece (assistindo), Stranger Things → 2
    //   Crunchyroll: One Piece → 1 · Apple TV+: Ruptura → 1 · Paramount+: Yellowstone → 1 (preço de 01/08: velho)
    //   Furiosa: só aluguel/compra · Bebê Rena: sem cache de "onde assistir" → sem dados
    await pumpScreen(tester, const SubscribeScreen(), overrides: [clockOverride]);
    await tester.pumpAndSettle();

    expect(find.text('Este mês, assine a HBO Max: ela resolve 3 dos seus 9 títulos, por R\$ 39,90.'), findsOneWidget);
    expect(find.text('Preços de 22/10/2026 · estimativa'), findsOneWidget);
    expect(find.text('A conta'), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'HBO Max'), findsOneWidget);
    expect(find.text('Resolve 3 dos seus 9'), findsOneWidget);
    expect(find.text('R\$ 39,90/mês (Padrão) · R\$ 13,30 por título'), findsOneWidget);
    expect(find.text('Resolve 2 dos seus 9'), findsOneWidget, reason: 'Netflix');
    expect(find.text('você assina'), findsOneWidget, reason: 'o usuário de amostra já assina a Netflix');
    // empate em 1 título: Crunchyroll (16,99) antes de Paramount+ (19,90) e Apple TV+ (21,90)
    expect(find.widgetWithText(ExpansionTile, 'Crunchyroll'), findsOneWidget);
    expect(find.widgetWithText(ExpansionTile, 'Paramount+'), findsOneWidget);
    expect(find.text('Preço de 01/08/2026: pode ter mudado.'), findsOneWidget, reason: 'Paramount+ com preço de mais de 60 dias');
    final crunchy = tester.getTopLeft(find.widgetWithText(ExpansionTile, 'Crunchyroll')).dy;
    final paramount = tester.getTopLeft(find.widgetWithText(ExpansionTile, 'Paramount+')).dy;
    expect(crunchy, lessThan(paramount));

    // a lista é preguiçosa (só monta o que cabe nos 600 px do teste): rola por partes
    final list = find.byType(ListView).first;
    await tester.drag(list, const Offset(0, -300));
    await tester.pumpAndSettle();
    expect(find.widgetWithText(ExpansionTile, 'Apple TV+'), findsOneWidget);
    expect(find.textContaining('Prime Video, Disney+ e Globoplay'), findsOneWidget);
    expect(find.textContaining('não têm nenhum dos seus títulos'), findsOneWidget);
    expect(find.text('Ficam de fora'), findsOneWidget);
    expect(find.text('Netflix e Crunchyroll'), findsOneWidget, reason: 'One Piece fica de fora e a tela diz onde ele está');

    for (var i = 0; i < 2; i++) {
      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
    }
    expect(find.text('Só para alugar ou comprar (1)'), findsOneWidget);
    expect(find.text('Furiosa: Uma Saga Mad Max'), findsOneWidget);
    expect(find.text('Sem dados (1)'), findsOneWidget);
    expect(find.text('Bebê Rena'), findsOneWidget);
    expect(find.text('sem dados'), findsOneWidget);
  });

  testWidgets('chave "aceito anúncios" troca o preço para o plano com anúncios', (tester) async {
    await pumpScreen(tester, const SubscribeScreen(), overrides: [clockOverride]);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Aceito plano com anúncios'));
    await tester.pumpAndSettle();
    expect(find.text('Este mês, assine a HBO Max: ela resolve 3 dos seus 9 títulos, por R\$ 29,90.'), findsOneWidget);
    expect(find.text('R\$ 29,90/mês (Básico com anúncios) · R\$ 9,97 por título'), findsOneWidget);
  });

  testWidgets('abrir o detalhe de um título "sem dados" o traz para a conta', (tester) async {
    final catalog = FixtureCatalogRepository(latency: Duration.zero);
    await pumpScreen(
      tester,
      const SubscribeScreen(),
      catalog: catalog,
      overrides: [clockOverride],
      routes: {
        '/title/:type/:tmdbId': (s) => TitleScreen(type: MediaType.tryParse(s.pathParameters['type'])!, tmdbId: int.parse(s.pathParameters['tmdbId']!)),
      },
    );
    await tester.pumpAndSettle();
    final list = find.byType(ListView).first;
    await tester.dragUntilVisible(find.text('Bebê Rena'), list, const Offset(0, -300));
    await tester.tap(find.text('Bebê Rena'));
    await tester.pumpAndSettle();
    expect(find.byType(TitleScreen), findsOneWidget);
    expect(catalog.hasFetched(MediaType.tv, 241259), isTrue);

    // voltar: a conta refaz sozinha (o detalhe avisou que o cache mudou); a Netflix
    // passa a resolver 3 e empata com a HBO Max, que ganha por ser mais barata
    Navigator.of(tester.element(find.byType(TitleScreen))).pop();
    await tester.pumpAndSettle();
    expect(find.byType(TitleScreen), findsNothing);
    // a lista continua rolada até o fim: volta ao topo para ler a frase
    await tester.drag(list, const Offset(0, 2000));
    await tester.pumpAndSettle();
    expect(find.text('Este mês, assine a HBO Max: ela resolve 3 dos seus 9 títulos, por R\$ 39,90.'), findsOneWidget);
    expect(find.text('Resolve 3 dos seus 9'), findsNWidgets(2), reason: 'HBO Max e Netflix');
    expect(find.text('Sem dados (1)'), findsNothing);
  });

  testWidgets('como @foxer: títulos dos amigos (camila e vini) entram com peso 0,3 e desempatam', (tester) async {
    // foxer: 8 meus (HBO Max 2, Netflix 2, Apple 1, Paramount 1, Crunchyroll 1, Furiosa aluguel, Bebê Rena sem dados)
    // + amigos: The Last of Us (camila, 03/10) e Duna 2 (vini, 21/10), ambos na HBO Max → 2 + 0,6 = 2,6 > Netflix 2
    final diary = FixtureDiaryStore();
    final social = FixtureSocialStore(diary);
    await pumpScreen(tester, const SubscribeScreen(), user: asFixture('foxer'), diary: diary, social: social, overrides: [clockOverride]);
    await tester.pumpAndSettle();
    expect(
      find.text('Este mês, assine a HBO Max: ela resolve 2 dos seus 8 títulos (e mais 2 que seus amigos estão vendo), por R\$ 39,90.'),
      findsOneWidget,
    );
    expect(find.text('Resolve 2 dos seus 8 + 2 dos amigos'), findsOneWidget);
    final list = find.byType(ListView).first;
    await tester.dragUntilVisible(find.textContaining('2 títulos vêm de quem você segue'), list, const Offset(0, -300));
    expect(find.textContaining('contam 0,3 cada'), findsOneWidget);
  });

  testWidgets('"Meus streamings" abre a tela e o título com "você assina" ganha o selo', (tester) async {
    await pumpScreen(
      tester,
      const SubscribeScreen(),
      overrides: [clockOverride],
      routes: {'/subscribe/mine': (_) => const MySubscriptionsScreen()},
    );
    await tester.pumpAndSettle();
    expect(find.text('você assina'), findsOneWidget, reason: 'o usuário de amostra já assina a Netflix');
    await tester.tap(find.text('Meus streamings'));
    await tester.pumpAndSettle();
    expect(find.byType(MySubscriptionsScreen), findsOneWidget);
  });

  test('joinProviderNames', () {
    expect(joinProviderNames(const []), '');
  });

  testWidgets('erro na leitura mostra "Tentar de novo"', (tester) async {
    await pumpScreen(
      tester,
      const SubscribeScreen(),
      overrides: [
        clockOverride,
        providerPricesProvider.overrideWith((ref) async => throw Exception('boom')),
      ],
    );
    await tester.pumpAndSettle();
    expect(find.text('Tentar de novo'), findsOneWidget);
  });
}
