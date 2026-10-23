import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/core/widgets/spoiler_blur.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/features/diary/presentation/entry_poster_tile.dart';
import 'package:watchlog/features/lists/presentation/list_screen.dart';
import 'package:watchlog/features/profile/presentation/profile_screen.dart';
import 'package:watchlog/features/profile/presentation/stats_screen.dart';
import 'package:watchlog/features/title/presentation/title_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('meu perfil: cartão, contadores e grade de pôsteres com nota e progresso', (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      routes: {
        '/title/:type/:tmdbId': (s) => TitleScreen(
              type: MediaType.tryParse(s.pathParameters['type'])!,
              tmdbId: int.parse(s.pathParameters['tmdbId']!),
            ),
      },
    );
    await tester.pumpAndSettle();

    expect(find.text('Pessoa Teste'), findsOneWidget);
    expect(find.text('Editar perfil'), findsOneWidget);
    expect(find.text('Assistidos'), findsOneWidget);
    // contadores do diário de amostra: 3 assistidos, 2 reviews, 2 listas (a privada conta para o dono)
    expect(find.text('3'), findsWidgets);
    expect(find.text('2'), findsWidgets);

    // grade: 3 assistidos + 1 assistindo na faixa de cima
    expect(find.text('Assistindo'), findsOneWidget);
    expect(find.byType(EntryPosterTile), findsNWidgets(4));
    expect(find.text('T21 E1050'), findsOneWidget, reason: 'progresso da série');
    expect(find.text('2×'), findsOneWidget, reason: 'reassistido');

    // tocar no pôster (o da faixa "Assistindo", visível sem rolar) abre o detalhe
    await tester.tap(find.byType(EntryPosterTile).first);
    await tester.pumpAndSettle();
    expect(find.byType(TitleScreen), findsOneWidget);
  });

  testWidgets('abas Quero ver, Listas e Reviews (spoiler borrado)', (tester) async {
    await pumpScreen(
      tester,
      const ProfileScreen(),
      routes: {'/list/:id': (s) => ListScreen(listId: s.pathParameters['id']!)},
    );
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, 'Quero ver'));
    await tester.pumpAndSettle();
    // 8 "quero ver" no diário de amostra (2 da fase 04 + 6 da fase 07, para a aba
    // Assinar); a grade é preguiçosa e só monta o que cabe na tela do teste
    expect(find.byType(EntryPosterTile), findsAtLeastNWidgets(3));

    await tester.tap(find.widgetWithText(Tab, 'Listas'));
    await tester.pumpAndSettle();
    expect(find.text('Nova lista'), findsOneWidget);
    expect(find.text('Para maratonar'), findsOneWidget);
    expect(find.text('Guilty pleasures'), findsOneWidget, reason: 'dono vê a privada');
    expect(find.text('3 títulos · ranqueada'), findsOneWidget);

    await tester.tap(find.text('Para maratonar'));
    await tester.pumpAndSettle();
    expect(find.byType(ListScreen), findsOneWidget);
    expect(find.text('1.'), findsOneWidget, reason: 'ranqueada mostra posição');
    expect(find.text('Stranger Things'), findsOneWidget);
    await tester.tap(find.byType(BackButton));
    await tester.pumpAndSettle();

    await tester.tap(find.widgetWithText(Tab, 'Reviews'));
    await tester.pumpAndSettle();
    expect(find.byType(SpoilerBlur), findsNWidgets(2));
    expect(find.text('Mostrar spoiler'), findsOneWidget, reason: 'só a review do One Piece tem spoiler');
    expect(find.textContaining('Som absurdo'), findsOneWidget, reason: 'review sem spoiler aparece');
  });

  testWidgets('perfil público de outra pessoa mostra conteúdo; privado mostra só o cartão', (tester) async {
    await pumpScreen(tester, const ProfileScreen(username: 'foxer'));
    await tester.pumpAndSettle();
    expect(find.text('João Leite'), findsOneWidget);
    expect(find.text('Editar perfil'), findsNothing);
    expect(find.byType(EntryPosterTile), findsNWidgets(3), reason: '2 assistidos + 1 assistindo');

    await pumpScreen(tester, const ProfileScreen(username: 'camila'));
    await tester.pumpAndSettle();
    expect(find.text('Camila Rocha'), findsOneWidget, reason: 'cartão visível');
    expect(find.text('Assistidos'), findsOneWidget, reason: 'contadores visíveis');
    expect(find.text('Perfil privado'), findsOneWidget);
    expect(find.byType(EntryPosterTile), findsNothing, reason: 'conteúdo escondido');
  });

  testWidgets('perfil inexistente', (tester) async {
    await pumpScreen(tester, const ProfileScreen(username: 'ninguem'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil não encontrado'), findsOneWidget);
  });

  testWidgets('estatísticas: horas, por streaming, gênero e década do diário de amostra', (tester) async {
    await pumpScreen(tester, const StatsScreen(username: 'foxer'));
    await tester.pumpAndSettle();
    // Frieren 28 ep × 24 min = 672; Oppenheimer 181; One Piece T1 E30 = 30 × 24 = 720 → 1573 min = 26 h
    expect(find.text('26 h'), findsOneWidget);
    expect(find.text('Por streaming'), findsOneWidget);
    expect(find.text('Crunchyroll'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
    await tester.dragUntilVisible(find.text('Anos 2020'), find.byType(ListView), const Offset(0, -200));
    await tester.pumpAndSettle();
    expect(find.text('Animação'), findsOneWidget);
    expect(find.text('Anos 2020'), findsOneWidget);

    await pumpScreen(tester, const StatsScreen(username: 'camila'));
    await tester.pumpAndSettle();
    expect(find.text('Perfil privado'), findsOneWidget);
  });

  testWidgets('diário vazio mostra o estado vazio com a dica', (tester) async {
    await pumpScreen(tester, const ProfileScreen(), diary: FixtureDiaryStore(seed: false));
    await tester.pumpAndSettle();
    expect(find.text('Nada assistido ainda'), findsOneWidget);
    expect(find.text('Abra um título e toque em Registrar.'), findsOneWidget);
  });
}
