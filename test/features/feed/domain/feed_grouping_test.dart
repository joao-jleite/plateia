import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/catalog/domain/catalog_models.dart';
import 'package:watchlog/features/feed/domain/activity.dart';
import 'package:watchlog/features/feed/domain/feed_grouping.dart';
import 'package:watchlog/features/onboarding/domain/profile.dart';

void main() {
  final bear = Title(id: 't1', tmdbId: 136315, mediaType: MediaType.tv, title: 'O Urso', fetchedAt: DateTime(2026));
  const ana = Profile(id: 'u1', username: 'ana');
  const bia = Profile(id: 'u2', username: 'bia');

  Activity act(String id, Profile user, DateTime at, {ActivityKind kind = ActivityKind.watched, Map<String, dynamic> payload = const {}}) =>
      Activity(id: id, userId: user.id, kind: kind, createdAt: at, user: user, title: bear, payload: payload);

  group('groupFeed', () {
    test('agrupa eventos consecutivos do mesmo autor no mesmo dia', () {
      final items = [
        act('1', ana, DateTime(2026, 10, 22, 22)),
        act('2', ana, DateTime(2026, 10, 22, 9)),
        act('3', bia, DateTime(2026, 10, 22, 8)),
        act('4', ana, DateTime(2026, 10, 21, 23)), // dia anterior: grupo novo
        act('5', ana, DateTime(2026, 10, 21, 10)),
      ];
      final groups = groupFeed(items);
      expect(groups.map((g) => g.items.length), [2, 1, 2]);
      expect(groups.first.userId, 'u1');
      expect(groups[1].userId, 'u2');
      expect(groupSummary(groups.first), '2 atividades');
      expect(groupSummary(groups[1]), '');
    });

    test('mesmo autor em dias diferentes não se junta, mesmo que consecutivo', () {
      final items = [act('1', ana, DateTime(2026, 10, 22, 0, 10)), act('2', ana, DateTime(2026, 10, 21, 23, 50))];
      expect(groupFeed(items).length, 2);
    });

    test('lista vazia → nenhum grupo', () => expect(groupFeed(const []), isEmpty));
  });

  group('frases', () {
    test('verbo e objeto por tipo', () {
      expect(activityVerb(act('1', ana, DateTime(2026))), 'assistiu');
      expect(activityVerb(act('1', ana, DateTime(2026), payload: {'is_rewatch': true})), 'assistiu de novo');
      expect(activityVerb(act('1', ana, DateTime(2026), kind: ActivityKind.rated)), 'avaliou');
      expect(activityVerb(act('1', ana, DateTime(2026), kind: ActivityKind.reviewed)), 'escreveu sobre');
      expect(activityVerb(act('1', ana, DateTime(2026), kind: ActivityKind.watching)), 'começou a assistir');
      expect(activityObject(act('1', ana, DateTime(2026), kind: ActivityKind.listCreated, payload: {'name': 'Favoritas'})), 'Favoritas');
      expect(activityObject(act('1', ana, DateTime(2026), kind: ActivityKind.imported, payload: {'count': 312})), '312 títulos da Netflix');
      expect(activityObject(act('1', ana, DateTime(2026), kind: ActivityKind.imported, payload: {'count': 1})), '1 título da Netflix');
    });

    test('frase inteira com nota em meia estrela', () {
      final a = act('1', ana, DateTime(2026), kind: ActivityKind.rated, payload: {'rating': 4.5});
      expect(activitySentence(a), '@ana avaliou O Urso ★ 4,5');
      expect(a.rating, 4.5);
      // nota vinda do JSON como string (jsonb numeric pode virar texto)
      expect(act('1', ana, DateTime(2026), payload: {'rating': '3.0'}).rating, 3.0);
    });

    test('rótulo do dia: hoje, ontem, dd/MM, dd/MM/aaaa', () {
      final now = DateTime(2026, 10, 23, 15);
      expect(feedDayLabel(DateTime(2026, 10, 23, 1), now: now), 'hoje');
      expect(feedDayLabel(DateTime(2026, 10, 22, 23), now: now), 'ontem');
      expect(feedDayLabel(DateTime(2026, 10, 1), now: now), '01/10');
      expect(feedDayLabel(DateTime(2025, 12, 31), now: now), '31/12/2025');
    });
  });

  group('Activity', () {
    test('review só vem do embed de entries em eventos reviewed', () {
      final a = act('1', ana, DateTime(2026), kind: ActivityKind.reviewed, payload: {'has_spoiler': true});
      expect(a.review, isNull, reason: 'sem embed (RLS escondeu) não há texto');
      expect(a.hasSpoiler, isTrue, reason: 'payload guarda a flag mesmo sem o texto');
    });

    test('validações de comentário e nota do check-in', () {
      expect(validateCommentBody(''), isNotNull);
      expect(validateCommentBody('   '), isNotNull);
      expect(validateCommentBody('ok'), isNull);
      expect(validateCommentBody('x' * 1001), isNotNull);
      expect(validateCheckinNote(null), isNull);
      expect(validateCheckinNote('x' * 140), isNull);
      expect(validateCheckinNote('x' * 141), isNotNull);
    });
  });
}
