import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/search/presentation/search_screen.dart';
import 'package:watchlog/features/title/presentation/title_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  testWidgets('estado inicial, busca "One Piece" com debounce e abre o detalhe', (tester) async {
    await pumpScreen(
      tester,
      const SearchScreen(),
      routes: {
        '/title/:type/:tmdbId': (s) => TitleScreen(
              type: MediaType.tryParse(s.pathParameters['type'])!,
              tmdbId: int.parse(s.pathParameters['tmdbId']!),
            ),
      },
    );
    expect(find.text('Busque qualquer título'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'One Piece');
    await tester.pump(const Duration(milliseconds: 500)); // debounce
    await tester.pumpAndSettle();

    // Anime (1999) e live-action (2023), os dois com o mesmo nome (fora o campo de busca).
    expect(find.descendant(of: find.byType(ListTile), matching: find.text('One Piece')), findsNWidgets(2));
    expect(find.text('1999 · Anime'), findsOneWidget);
    expect(find.text('2023 · Série'), findsOneWidget);

    await tester.tap(find.text('1999 · Anime'));
    await tester.pumpAndSettle();
    expect(find.byType(TitleScreen), findsOneWidget);
    expect(find.text('Abrir na Netflix'), findsOneWidget);
  });

  testWidgets('sem resultado mostra o estado vazio com a busca', (tester) async {
    await pumpScreen(tester, const SearchScreen());
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Nada encontrado para "zzzz"'), findsOneWidget);
  });

  testWidgets('busca ignora acento e maiúsculas', (tester) async {
    await pumpScreen(tester, const SearchScreen());
    await tester.enterText(find.byType(TextField), 'ARCANJO renegado');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Arcanjo Renegado'), findsOneWidget);
  });
}
