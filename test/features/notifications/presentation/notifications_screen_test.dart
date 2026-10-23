import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_social.dart';
import 'package:watchlog/features/feed/presentation/activity_screen.dart';
import 'package:watchlog/features/notifications/presentation/notifications_screen.dart';
import 'package:watchlog/features/profile/presentation/profile_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late FixtureDiaryStore diary;
  late FixtureSocialStore social;

  setUp(() {
    diary = FixtureDiaryStore();
    social = FixtureSocialStore(diary);
  });

  testWidgets('@foxer: seguiu, curtiu e comentou; marcar como lidas; tocar abre a atividade', (tester) async {
    await pumpScreen(
      tester,
      const NotificationsScreen(),
      user: asFixture('foxer'),
      diary: diary,
      social: social,
      routes: {
        '/activity/:id': (s) => ActivityScreen(activityId: s.pathParameters['id']!),
        '/profile/:username': (s) => ProfileScreen(username: s.pathParameters['username']),
      },
    );
    await tester.pumpAndSettle();

    // cena: camila seguiu, vini seguiu, camila curtiu + comentou Frieren, vini curtiu Frieren
    expect(find.textContaining('começou a seguir você'), findsNWidgets(2));
    expect(find.textContaining('curtiu sua review de Frieren'), findsNWidgets(2));
    expect(find.textContaining('comentou em sua review de Frieren'), findsOneWidget);
    expect(find.textContaining('A trilha é um absurdo'), findsOneWidget, reason: 'trecho do comentário');
    expect(find.byKey(const Key('mark-all-read')), findsOneWidget);
    expect(social.unreadFor(FixtureDiaryStore.foxer.id), 5);

    await tester.tap(find.byKey(const Key('mark-all-read')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('mark-all-read')), findsNothing, reason: 'nada mais por ler');
    expect(social.unreadFor(FixtureDiaryStore.foxer.id), 0);

    await tester.tap(find.textContaining('comentou em sua review'));
    await tester.pumpAndSettle();
    expect(find.byType(ActivityScreen), findsOneWidget);
  });

  testWidgets('comentário com spoiler não mostra o texto na lista', (tester) async {
    // cena: foxer comentou com spoiler a review do vini sobre Duna
    await pumpScreen(tester, const NotificationsScreen(), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.textContaining('comentou em sua review de Duna: Parte Dois (contém spoiler)'), findsOneWidget);
    expect(find.textContaining('Vi no IMAX'), findsNothing, reason: 'o texto do spoiler só aparece na atividade, atrás do borrão');
  });

  testWidgets('pedido para seguir: Aceitar na própria linha', (tester) async {
    social.follow(FixtureDiaryStore.vini.id, FixtureDiaryStore.camila.id); // vini pede para seguir a camila (privada)
    await pumpScreen(tester, const NotificationsScreen(), user: asFixture('camila'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.textContaining('pediu para seguir você'), findsOneWidget);
    final n = social.notifications.firstWhere((n) => n.userId == FixtureDiaryStore.camila.id && n.kind.name == 'followRequest');
    await tester.tap(find.byKey(Key('notif-accept-${n.id}')));
    await tester.pumpAndSettle();
    expect(find.textContaining('pediu para seguir você'), findsNothing, reason: 'aceitar apaga a notificação do pedido');
    expect(social.isFollowing(FixtureDiaryStore.vini.id, FixtureDiaryStore.camila.id), isTrue);
  });

  testWidgets('sem notificações: estado vazio', (tester) async {
    await pumpScreen(tester, const NotificationsScreen(), diary: FixtureDiaryStore(seed: false));
    await tester.pumpAndSettle();
    expect(find.text('Nada por aqui ainda'), findsOneWidget);
  });
}
