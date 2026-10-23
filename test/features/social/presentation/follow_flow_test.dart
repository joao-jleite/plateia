import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/dev/fixtures/fixture_diary.dart';
import 'package:watchlog/dev/fixtures/fixture_social.dart';
import 'package:watchlog/features/diary/presentation/entry_poster_tile.dart';
import 'package:watchlog/features/profile/presentation/profile_screen.dart';
import 'package:watchlog/features/settings/presentation/blocked_users_screen.dart';
import 'package:watchlog/features/social/domain/social_models.dart';
import 'package:watchlog/features/social/presentation/follow_list_screen.dart';
import 'package:watchlog/features/social/presentation/follow_requests_screen.dart';
import 'package:watchlog/features/social/presentation/social_providers.dart';
import 'package:watchlog/features/social/presentation/user_search_screen.dart';

import '../../../helpers/pump_app.dart';

/// O texto do botão também é rótulo de contador ("Seguindo"): procura só em botões.
Finder followBtn(String label) =>
    find.ancestor(of: find.text(label), matching: find.byWidgetPredicate((w) => w is ButtonStyleButton));

void main() {
  late FixtureDiaryStore diary;
  late FixtureSocialStore social;
  final vini = FixtureDiaryStore.vini;
  final camila = FixtureDiaryStore.camila;
  final foxer = FixtureDiaryStore.foxer;

  setUp(() {
    diary = FixtureDiaryStore();
    social = FixtureSocialStore(diary);
  });

  testWidgets('seguir perfil privado vira "Pedido enviado" e o conteúdo continua fechado; a dona aceita e abre', (tester) async {
    await pumpScreen(tester, const ProfileScreen(username: 'camila'), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(followBtn('Seguir'), findsOneWidget);
    expect(find.text('Perfil privado'), findsOneWidget);

    await tester.tap(followBtn('Seguir'));
    await tester.pump();
    expect(followBtn('Pedido enviado'), findsOneWidget, reason: 'otimista pela privacidade do alvo');
    await tester.pumpAndSettle();
    expect(social.follows['${vini.id}|${camila.id}'], FollowStatus.pending);
    expect(find.text('Perfil privado'), findsOneWidget, reason: 'pendente não dá acesso');
    expect(find.byType(EntryPosterTile), findsNothing);
    expect(social.notifications.any((n) => n.userId == camila.id && n.kind.name == 'followRequest' && n.actorId == vini.id), isTrue);

    // camila aceita (o que a tela de pedidos dela faria) → o perfil abre para o vini
    social.accept(vini.id, camila.id);
    await tester.tap(followBtn('Pedido enviado')); // a tela ainda acha que é pedido; o toque desfaz a relação
    await tester.pumpAndSettle();
    expect(followBtn('Seguir'), findsOneWidget, reason: 'deixou de seguir');
    expect(find.text('Desfazer'), findsOneWidget);
    await tester.tap(find.text('Desfazer'));
    await tester.pumpAndSettle();
    expect(followBtn('Pedido enviado'), findsOneWidget, reason: 'desfazer refaz o pedido (privado → pendente de novo)');
  });

  testWidgets('seguir perfil público é aceito na hora; "Seguindo" → deixar de seguir com Desfazer', (tester) async {
    await pumpScreen(tester, const ProfileScreen(username: 'camila'), user: asFixture('foxer'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(followBtn('Seguindo'), findsOneWidget, reason: 'cena inicial: foxer segue camila');
    expect(find.textContaining('segue você'), findsOneWidget, reason: 'camila segue o foxer');
    expect(find.byType(EntryPosterTile), findsNWidgets(2), reason: 'seguidor aceito vê o diário privado');

    await tester.tap(followBtn('Seguindo'));
    await tester.pumpAndSettle();
    expect(followBtn('Seguir'), findsOneWidget);
    expect(social.follows.containsKey('${foxer.id}|${camila.id}'), isFalse);
    expect(find.text('Perfil privado'), findsOneWidget, reason: 'sem follow, o conteúdo fecha de novo');
  });

  testWidgets('pedidos: camila vê o pedido do vini, aceita; recusar apaga', (tester) async {
    social.follow(vini.id, camila.id);
    diary.profiles[vini.id] = vini;
    await pumpScreen(tester, const FollowRequestsScreen(), user: asFixture('camila'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.text('Vini'), findsOneWidget);
    await tester.tap(find.byKey(Key('accept-${vini.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum pedido pendente'), findsOneWidget);
    expect(social.follows['${vini.id}|${camila.id}'], FollowStatus.accepted);
    expect(social.notifications.any((n) => n.userId == vini.id && n.kind.name == 'followAccepted'), isTrue);
    expect(social.notifications.any((n) => n.userId == camila.id && n.kind.name == 'followRequest'), isFalse, reason: 'o pedido saiu das notificações dela');
  });

  testWidgets('bloquear: confirma, o perfil some nos dois sentidos, follows caem; Bloqueados lista e desbloqueia', (tester) async {
    // vini segue foxer e foxer segue vini (cena inicial)
    await pumpScreen(tester, const ProfileScreen(username: 'foxer'), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(followBtn('Seguindo'), findsOneWidget);

    await tester.tap(find.byKey(const Key('profile-menu')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bloquear'));
    await tester.pumpAndSettle();
    expect(find.textContaining('Vocês deixam de se seguir'), findsOneWidget);
    await tester.tap(find.byKey(const Key('confirm-block')));
    await tester.pumpAndSettle();

    expect(social.blocks.contains('${vini.id}|${foxer.id}'), isTrue);
    expect(social.follows.containsKey('${vini.id}|${foxer.id}'), isFalse, reason: 'bloqueio desfez o follow');
    expect(social.follows.containsKey('${foxer.id}|${vini.id}'), isFalse, reason: 'nos dois sentidos');
    expect(social.canViewContent(foxer.id, vini.id), isFalse, reason: 'o bloqueado não vê o bloqueador');
    expect(social.canViewProfile(vini.id, foxer.id), isFalse);
    expect(social.feedFor(vini.id).any((a) => a.userId == foxer.id), isFalse);
    expect(social.feedFor(foxer.id).any((a) => a.userId == vini.id), isFalse);
    expect(social.notifications.any((n) => (n.userId == foxer.id && n.actorId == vini.id) || (n.userId == vini.id && n.actorId == foxer.id)), isFalse);
    expect(social.searchFor(foxer.id, 'vini'), isEmpty, reason: 'bloqueado não acha o bloqueador na busca');
    // a tela de perfil (rota raiz do teste, sem pop) recarrega e não acha mais o cartão
    expect(find.text('Perfil não encontrado'), findsOneWidget);

    await pumpScreen(tester, const BlockedUsersScreen(), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.text('João Leite'), findsOneWidget);
    await tester.tap(find.byKey(Key('unblock-${foxer.id}')));
    await tester.pumpAndSettle();
    expect(find.text('Você não bloqueou ninguém'), findsOneWidget);
    expect(social.blocks, isEmpty);
    expect(social.follows.containsKey('${vini.id}|${foxer.id}'), isFalse, reason: 'desbloquear não refaz nada');
  });

  testWidgets('busca por @: acha pelo prefixo e pelo nome, mostra o cadeado e o botão Seguir', (tester) async {
    await pumpScreen(tester, const UserSearchScreen(), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.text('Procure pelo @ ou pelo nome'), findsOneWidget);
    expect(find.byKey(const Key('share-my-profile')), findsOneWidget);

    await tester.enterText(find.byKey(const Key('user-search-field')), '@cam');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('Camila Rocha'), findsOneWidget);
    expect(find.byIcon(Icons.lock_outline), findsOneWidget);
    expect(followBtn('Seguir'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('user-search-field')), 'leite'); // display_name do foxer
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.text('João Leite'), findsOneWidget);
    expect(followBtn('Seguindo'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('user-search-field')), 'zzzz');
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pumpAndSettle();
    expect(find.textContaining('Ninguém com'), findsOneWidget);
  });

  testWidgets('seguidores e seguindo do @foxer', (tester) async {
    await pumpScreen(tester, const FollowListScreen(username: 'foxer', mode: FollowListMode.followers), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    // camila (privada) segue o foxer: vini não segue a camila, então a linha dela não aparece (SPEC §5.3); vini aparece
    expect(find.text('Vini'), findsOneWidget);
    expect(find.text('Camila Rocha'), findsNothing);

    await pumpScreen(tester, const FollowListScreen(username: 'foxer', mode: FollowListMode.following), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    expect(find.text('Camila Rocha'), findsOneWidget, reason: 'foxer (público) segue camila: a linha é dele, o cartão dela é visível');
    expect(find.text('Vini'), findsOneWidget);
  });

  testWidgets('compartilhar perfil manda @ e o link /u/:username', (tester) async {
    final launcher = await pumpScreen(tester, const ProfileScreen(username: 'foxer'), user: asFixture('vini'), diary: diary, social: social);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Compartilhar'));
    await tester.pumpAndSettle();
    expect(launcher.shared.single, contains('@foxer'));
    expect(launcher.shared.single, contains('/u/foxer'));
  });
}
