import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/errors/app_exception.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/catalog/data/catalog_repository.dart';
import 'package:watchlog/features/catalog/domain/catalog_models.dart';
import 'package:watchlog/features/home/presentation/home_screen.dart';

import '../../../helpers/pump_app.dart';

class _FailingCatalog implements CatalogRepository {
  int calls = 0;

  @override
  Future<HomeSections> homeSections() async {
    calls++;
    throw const AppException('upstream', 'O serviço de catálogo não respondeu.');
  }

  @override
  Future<SearchPage> search(String query, {int page = 1}) => throw UnimplementedError();

  @override
  Future<TitleDetail> title({required MediaType type, required int tmdbId, bool force = false}) =>
      throw UnimplementedError();

  @override
  Future<List<StreamingProvider>> providers() => throw UnimplementedError();
}

void main() {
  testWidgets('mostra as seções com as novidades por streaming e esconde as vazias', (tester) async {
    await pumpScreen(tester, const HomeScreen());
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpAndSettle();

    expect(find.text('Em alta no Brasil'), findsOneWidget);
    expect(find.text('Novidades na Netflix'), findsOneWidget);
    expect(find.text('Novidades no Prime Video'), findsNothing, reason: 'seção vazia não aparece');
    // O rodapé fica fora da tela: rola a lista vertical (o primeiro ListView da árvore) até ele.
    await tester.dragUntilVisible(
      find.textContaining('dados do TMDB'),
      find.byType(ListView).first,
      const Offset(0, -300),
    );
    expect(find.textContaining('dados do TMDB'), findsOneWidget);
  });

  testWidgets('erro mostra a mensagem e "Tentar de novo" refaz a chamada', (tester) async {
    final failing = _FailingCatalog();
    await pumpScreen(
      tester,
      const HomeScreen(),
      catalog: failing,
    );
    await tester.pumpAndSettle();
    expect(find.text('O serviço de catálogo não respondeu.'), findsOneWidget);
    expect(failing.calls, 1);

    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();
    expect(failing.calls, 2);
  });
}
