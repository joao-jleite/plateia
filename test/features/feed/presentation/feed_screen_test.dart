import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/errors/app_exception.dart';
import 'package:watchlog/core/widgets/spoiler_blur.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_social.dart';
import 'package:watchlog/features/feed/data/feed_repository.dart';
import 'package:watchlog/features/feed/domain/activity.dart';
import 'package:watchlog/features/feed/presentation/activity_screen.dart';
import 'package:watchlog/features/feed/presentation/feed_item.dart';
import 'package:watchlog/features/feed/presentation/feed_screen.dart';
import 'package:watchlog/features/social/presentation/user_search_screen.dart';

import '../../../helpers/pump_app.dart';

/// Repositório que falha em tudo: estado de erro do feed.
class _FailingFeed implements FeedRepository {
  int calls = 0;

  @override
  Future<List<Activity>> feedPage({int offset = 0, int limit = FeedRepository.pageSize}) async {
    calls++;
    throw const AppException('network', 'Sem conexão. Verifique a internet e tente de novo.');
  }

  @override
  Future<List<Checkin>> friendsCheckins() async => const [];

  @override
  Future<Checkin?> myCheckin() async => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => throw UnimplementedError();
}

void main() {
  testWidgets('vazio: sem seguir ninguém e sem diário, convida a encontrar pessoas', (tester) async {
    await pumpScreen(
      tester,
      const FeedScreen(),
      diary: FixtureDiaryStore(seed: false),
      routes: {'/search/users': (_) => const UserSearchScreen()},
    );
    await tester.pumpAndSettle();
    expect(find.text('Seu feed está vazio'), findsOneWidget);
    await tester.tap(find.text('Encontrar pessoas'));
    await tester.pumpAndSettle();
    expect(find.byType(UserSearchScreen), findsOneWidget);
  });

  testWidgets('erro mostra a mensagem e "Tentar de novo" refaz a chamada', (tester) async {
    final failing = _FailingFeed();
    await pumpScreen(tester, const FeedScreen(), feed: failing);
    await tester.pumpAndSettle();
    expect(find.text('Sem conexão. Verifique a internet e tente de novo.'), findsOneWidget);
    expect(failing.calls, 1);
    await tester.tap(find.text('Tentar de novo'));
    await tester.pumpAndSettle();
    expect(failing.calls, 2);
  });

  testWidgets('lista: minhas atividades do diário de amostra, agrupadas, review com spoiler borrada', (tester) async {
    await pumpScreen(
      tester,
      const FeedScreen(),
      routes: {'/activity/:id': (s) => ActivityScreen(activityId: s.pathParameters['id']!)},
    );
    await tester.pumpAndSettle();

    // 4 eventos do diário de amostra (One Piece reviewed, Oppenheimer reviewed, Duna rated, Cidade de Deus rated)
    expect(find.byType(ActivityTile), findsNWidgets(4));
    expect(find.textContaining('escreveu sobre One Piece', findRichText: true), findsOneWidget);
    expect(find.textContaining('avaliou Duna: Parte Dois', findRichText: true), findsOneWidget);
    expect(find.text('hoje'), findsNothing, reason: 'os registros de amostra têm datas passadas');
    // a review do One Piece é spoiler: borrada; a do Oppenheimer aparece
    expect(find.byType(SpoilerBlur), findsNWidgets(2));
    expect(find.text('Mostrar spoiler'), findsOneWidget);
    expect(find.textContaining('Som absurdo'), findsOneWidget);

    // tocar num item abre o detalhe
    await tester.tap(find.textContaining('Som absurdo'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityScreen), findsOneWidget);
  });

  testWidgets('como @vini: feed traz as atividades do @foxer (seguido) e não as da @camila; curtir é otimista', (tester) async {
    final diary = FixtureDiaryStore();
    final social = FixtureSocialStore(diary);
    await pumpScreen(tester, const FeedScreen(), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();

    // 3 do vini + 4 do foxer (Frieren reviewed, Oppenheimer rated, One Piece watching, lista "Animes de 2023");
    // nada da camila (privada, vini não a segue). A lista é preguiçosa: conferimos o repositório e o topo da tela.
    final feed = social.feedFor(FixtureDiaryStore.vini.id);
    expect(feed.length, 7);
    expect(feed.any((a) => a.userId == FixtureDiaryStore.camila.id), isFalse);
    expect(feed.first.userId, FixtureDiaryStore.vini.id, reason: 'mais novo primeiro (The Last of Us, 22/10)');
    expect(find.byType(ActivityTile), findsWidgets);
    expect(find.textContaining('começou a assistir The Last of Us', findRichText: true), findsOneWidget);
    expect(find.text('Assistindo agora'), findsOneWidget, reason: 'faixa com o check-in do foxer');
    expect(find.textContaining('Wano chegando no fim!'), findsOneWidget);
    await tester.dragUntilVisible(find.textContaining('Animes de 2023', findRichText: true), find.byType(ListView).first, const Offset(0, -200));
    expect(find.textContaining('Animes de 2023', findRichText: true), findsOneWidget);
    expect(find.textContaining('Chorei no 3'), findsNothing);

    // curtir a review do Frieren (já tem 2 curtidas: camila e vini) → descurtir → 1
    final frieren = social.activities.firstWhere((a) => a.userId == FixtureDiaryStore.foxer.id && a.kind == ActivityKind.reviewed);
    expect(frieren.likeCount, 2);
    final likeKey = Key('like-${frieren.id}');
    await tester.dragUntilVisible(find.byKey(likeKey), find.byType(ListView).first, const Offset(0, -200));
    await tester.tap(find.byKey(likeKey));
    await tester.pump();
    expect(find.descendant(of: find.byKey(likeKey), matching: find.text('1')), findsOneWidget, reason: 'otimista: já mostra 1');
    await tester.pumpAndSettle();
    expect(social.likes.contains('${FixtureDiaryStore.vini.id}|${frieren.id}'), isFalse);
    await tester.tap(find.byKey(likeKey));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(likeKey), matching: find.text('2')), findsOneWidget);
    expect(social.notifications.where((n) => n.kind.name == 'like' && n.actorId == FixtureDiaryStore.vini.id).length, 1,
        reason: 'curtir de novo notifica o foxer uma vez só');
  });

  testWidgets('servidor recusa a curtida: desfaz e avisa', (tester) async {
    final diary = FixtureDiaryStore();
    final social = FixtureSocialStore(diary);
    await pumpScreen(tester, const FeedScreen(), user: asFixture('vini'), diary: diary, social: social, failWrites: true);
    await tester.pumpAndSettle();
    final duna = social.activities.firstWhere((a) => a.userId == FixtureDiaryStore.vini.id && a.kind == ActivityKind.reviewed);
    final likeKey = Key('like-${duna.id}');
    expect(find.descendant(of: find.byKey(likeKey), matching: find.text('1')), findsOneWidget, reason: 'foxer curtiu');
    await tester.tap(find.byKey(likeKey));
    await tester.pumpAndSettle();
    expect(find.descendant(of: find.byKey(likeKey), matching: find.text('1')), findsOneWidget, reason: 'voltou');
    expect(find.textContaining('Desfizemos'), findsOneWidget);
  });
}
