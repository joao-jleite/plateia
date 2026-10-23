import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/widgets/spoiler_blur.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_social.dart';
import 'package:watchlog/features/feed/domain/activity.dart';
import 'package:watchlog/features/feed/presentation/activity_screen.dart';

import '../../../helpers/pump_app.dart';

void main() {
  late FixtureDiaryStore diary;
  late FixtureSocialStore social;
  late Activity frieren; // review do @foxer, com comentário da @camila
  late Activity duna; // review do @vini, com comentário spoiler do @foxer

  setUp(() {
    diary = FixtureDiaryStore();
    social = FixtureSocialStore(diary);
    frieren = social.activities.firstWhere((a) => a.userId == FixtureDiaryStore.foxer.id && a.kind == ActivityKind.reviewed);
    duna = social.activities.firstWhere((a) => a.userId == FixtureDiaryStore.vini.id && a.kind == ActivityKind.reviewed);
  });

  testWidgets('como @vini: vê a review e o comentário da @camila, comenta e apaga o próprio comentário', (tester) async {
    await pumpScreen(tester, ActivityScreen(activityId: frieren.id), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();

    expect(find.text('João Leite'), findsOneWidget, reason: 'autor');
    expect(find.textContaining('Melhor anime de 2023'), findsOneWidget);
    expect(find.text('Comentários (1)'), findsOneWidget);
    expect(find.textContaining('A trilha é um absurdo'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('comment-field')), 'Top 3 do ano fácil.');
    await tester.tap(find.byKey(const Key('comment-send')));
    await tester.pump();
    expect(find.text('Top 3 do ano fácil.'), findsOneWidget, reason: 'otimista');
    await tester.pumpAndSettle();
    expect(find.text('Comentários (2)'), findsOneWidget);
    expect(social.comments.values.where((c) => c.activityId == frieren.id).length, 2);
    expect(social.activityById(frieren.id)!.commentCount, 2);
    expect(social.notifications.where((n) => n.kind.name == 'comment' && n.userId == FixtureDiaryStore.foxer.id).length, 2,
        reason: 'foxer foi avisado do comentário novo');

    // só o meu comentário tem "Apagar"; o da camila só "Denunciar"
    final mine = social.comments.values.firstWhere((c) => c.userId == FixtureDiaryStore.vini.id);
    final hers = social.comments.values.firstWhere((c) => c.userId == FixtureDiaryStore.camila.id);
    await tester.tap(find.byKey(Key('comment-menu-${hers.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Apagar'), findsNothing);
    expect(find.text('Denunciar'), findsOneWidget);
    await tester.tapAt(const Offset(5, 5)); // fecha o menu
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(Key('comment-menu-${mine.id}')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();
    expect(find.text('Top 3 do ano fácil.'), findsNothing);
    expect(find.text('Comentários (1)'), findsOneWidget);
  });

  testWidgets('como @foxer (dono da atividade): apaga o comentário da @camila; menu tem "Remover do feed"', (tester) async {
    await pumpScreen(tester, ActivityScreen(activityId: frieren.id), user: asFixture('foxer'), diary: diary, social: social);
    await tester.pumpAndSettle();
    final hers = social.comments.values.firstWhere((c) => c.userId == FixtureDiaryStore.camila.id);
    await tester.tap(find.byKey(Key('comment-menu-${hers.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Apagar'), findsOneWidget, reason: 'dono da atividade modera');
    await tester.tap(find.text('Apagar'));
    await tester.pumpAndSettle();
    expect(find.textContaining('A trilha é um absurdo'), findsNothing);
    expect(social.activityById(frieren.id)!.commentCount, 0);

    await tester.tap(find.byType(PopupMenuButton<String>).first);
    await tester.pumpAndSettle();
    expect(find.text('Remover do feed'), findsOneWidget);
    expect(find.text('Denunciar'), findsNothing, reason: 'não denuncio a mim mesmo');
  });

  testWidgets('comentário com spoiler aparece borrado; o meu novo com a chave ligada também', (tester) async {
    await pumpScreen(tester, ActivityScreen(activityId: duna.id), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.text('Mostrar spoiler'), findsOneWidget, reason: 'comentário do foxer');
    await tester.tap(find.text('Mostrar spoiler'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Parte Três obrigatória'), findsOneWidget);

    await tester.tap(find.byKey(const Key('comment-spoiler')));
    await tester.enterText(find.byKey(const Key('comment-field')), 'O Paul vira o que vira.');
    await tester.tap(find.byKey(const Key('comment-send')));
    await tester.pumpAndSettle();
    final mine = social.comments.values.firstWhere((c) => c.userId == FixtureDiaryStore.vini.id && c.activityId == duna.id);
    expect(mine.hasSpoiler, isTrue);
    expect(find.byType(SpoilerBlur), findsWidgets);
    expect(find.text('Mostrar spoiler'), findsOneWidget, reason: 'o novo está borrado (o do foxer já foi revelado)');
  });

  testWidgets('atividade de perfil privado que não sigo: indisponível', (tester) async {
    final camilas = social.activities.firstWhere((a) => a.userId == FixtureDiaryStore.camila.id);
    await pumpScreen(tester, ActivityScreen(activityId: camilas.id), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.text('Atividade indisponível'), findsOneWidget);
  });
}
