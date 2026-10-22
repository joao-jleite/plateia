import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/catalog/presentation/catalog_providers.dart';
import 'package:watchlog/features/title/domain/watch_action.dart';
import 'package:watchlog/features/title/presentation/title_screen.dart';

import '../../../helpers/provider_container_holder.dart';
import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('One Piece: detalhe, Onde assistir ordenado, botão abre o link da Netflix', (tester) async {
    final launcher = await pumpScreen(tester, const TitleScreen(type: MediaType.tv, tmdbId: 37854));
    expect(find.byType(CircularProgressIndicator), findsOneWidget, reason: 'estado carregando');
    await tester.pumpAndSettle();

    expect(find.text('One Piece'), findsWidgets);
    expect(find.text('Onde assistir'), findsOneWidget);
    expect(find.text('Onde assistir: dados da JustWatch via TMDB'), findsOneWidget, reason: 'atribuição');

    // Netflix (assinatura, com link) antes da Crunchyroll; variante "com anúncios" agrupada.
    final netflix = find.text('Netflix');
    final crunchy = find.text('Crunchyroll');
    expect(netflix, findsOneWidget);
    expect(crunchy, findsOneWidget);
    expect(tester.getTopLeft(netflix).dy, lessThan(tester.getTopLeft(crunchy).dy));
    expect(find.text('Netflix com anúncios'), findsNothing);

    await tester.tap(find.text('Abrir na Netflix'));
    await tester.pumpAndSettle();
    expect(launcher.opened, hasLength(1));
    expect(launcher.opened.single.kind, WatchActionKind.deepLink);
    expect(launcher.opened.single.uri.toString(), 'https://www.netflix.com/title/80107103');

    // A sinopse fica abaixo da dobra (o botão Registrar da fase 04 entrou antes dela).
    await tester.dragUntilVisible(find.textContaining('Monkey D. Luffy'), find.byType(ListView).first, const Offset(0, -200));
    expect(find.textContaining('Monkey D. Luffy'), findsOneWidget, reason: 'sinopse');
  });

  testWidgets('Disney+ sem link vira "Abrir o Disney+" pelo pacote', (tester) async {
    final launcher = await pumpScreen(tester, const TitleScreen(type: MediaType.tv, tmdbId: 136315));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Abrir o Disney+'));
    await tester.pumpAndSettle();
    expect(launcher.opened.single.kind, WatchActionKind.appPackage);
    expect(launcher.opened.single.package, 'com.disney.disneyplus');
  });

  testWidgets('Globoplay sem link vira "Buscar no Globoplay"', (tester) async {
    final launcher = await pumpScreen(tester, const TitleScreen(type: MediaType.tv, tmdbId: 95557));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Buscar no Globoplay'));
    await tester.pumpAndSettle();
    expect(launcher.opened.single.kind, WatchActionKind.search);
    expect(launcher.opened.single.uri!.queryParameters['q'], 'Arcanjo Renegado');
  });

  testWidgets('aluguel e compra mostram preço; HBO Max normalizado', (tester) async {
    final launcher = await pumpScreen(tester, const TitleScreen(type: MediaType.tv, tmdbId: 100088));
    await tester.pumpAndSettle();
    expect(find.textContaining('Compra R\$'), findsOneWidget);
    await tester.tap(find.text('Abrir na HBO Max'));
    await tester.pumpAndSettle();
    expect(launcher.opened.single.uri!.host, 'play.hbomax.com');
  });

  testWidgets('título sem disponibilidade mostra o estado vazio da seção', (tester) async {
    await pumpScreen(tester, const TitleScreen(type: MediaType.movie, tmdbId: 598));
    await tester.pumpAndSettle();
    expect(find.textContaining('nenhum streaming no Brasil'), findsOneWidget);
  });

  testWidgets('id desconhecido mostra erro com "Tentar de novo"', (tester) async {
    await pumpScreen(tester, const TitleScreen(type: MediaType.movie, tmdbId: 1));
    await tester.pumpAndSettle();
    expect(find.text('Não encontramos esse título.'), findsOneWidget);
    expect(find.text('Tentar de novo'), findsOneWidget);
  });

  testWidgets('abrir o mesmo título de novo não chama API externa (cache no repositório)', (tester) async {
    final container = ProviderContainerHolder();
    await pumpScreen(tester, Builder(builder: (context) {
      container.capture(context);
      return const TitleScreen(type: MediaType.tv, tmdbId: 37854);
    }));
    await tester.pumpAndSettle();
    final first = container.container.read(titleDetailProvider(MediaType.tv, 37854)).value!;

    // Segunda chamada ao repositório (como se outra tela abrisse o mesmo título).
    // runAsync: fora do FakeAsync do teste, senão o Future.delayed nunca completa.
    final repo = container.container.read(catalogRepositoryProvider);
    final second = (await tester.runAsync(() => repo.title(type: MediaType.tv, tmdbId: 37854)))!;
    expect(second.sync.providersFetchedAt, first.sync.providersFetchedAt,
        reason: 'dentro do TTL o carimbo não muda: upstream_calls = 0');
  });
}
