import 'package:flutter_test/flutter_test.dart';
import 'package:watchlog/core/model/media_type.dart';
import 'package:watchlog/features/catalog/domain/catalog_models.dart';
import 'package:watchlog/features/diary/domain/entry.dart';
import 'package:watchlog/features/feed/domain/activity.dart';
import 'package:watchlog/features/onboarding/domain/profile.dart';
import 'package:watchlog/features/subscribe/domain/candidates.dart';
import 'package:watchlog/features/subscribe/domain/recommendation.dart';

final now = DateTime(2026, 10, 23, 12);

Title title(String id, String name) =>
    Title(id: id, tmdbId: id.hashCode, mediaType: MediaType.tv, title: name, fetchedAt: now);

Entry entry(String titleId, EntryStatus status, {String name = 'T'}) => Entry(
      id: 'e-$titleId',
      userId: 'me',
      titleId: titleId,
      status: status,
      title: title(titleId, name),
    );

final vini = Profile(id: 'vini', username: 'vini', createdAt: now);

Activity activity(
  String titleId,
  ActivityKind kind, {
  String user = 'vini',
  double? rating,
  int daysAgo = 1,
  String name = 'F',
}) =>
    Activity(
      id: 'a-$titleId-$user-$kind',
      userId: user,
      kind: kind,
      titleId: titleId,
      payload: {'rating': ?rating},
      createdAt: now.subtract(Duration(days: daysAgo)),
      user: user == 'vini' ? vini : Profile(id: user, username: user, createdAt: now),
      title: title(titleId, name),
    );

void main() {
  test('meus "quero ver" e "assistindo" entram com peso 1; "assisti" não', () {
    final c = buildCandidates(
      myUserId: 'me',
      myEntries: [
        entry('a', EntryStatus.want, name: 'A'),
        entry('b', EntryStatus.watching, name: 'B'),
        entry('c', EntryStatus.watched, name: 'C'),
      ],
      friendActivities: const [],
      now: now,
    );
    expect(c.map((x) => x.name).toList(), ['A', 'B']);
    expect(c.every((x) => x.source == CandidateSource.mine && x.weight == 1.0), isTrue);
  });

  test('amigos: assistiu, avaliou ≥ 4 ou escreveu review nos últimos 30 dias, fora do meu diário, peso 0,3', () {
    final c = buildCandidates(
      myUserId: 'me',
      myEntries: [entry('mine', EntryStatus.watched), entry('want', EntryStatus.want, name: 'W')],
      friendActivities: [
        activity('f1', ActivityKind.watched, name: 'Assistiu'),
        activity('f2', ActivityKind.rated, rating: 4, name: 'Nota 4'),
        activity('f3', ActivityKind.rated, rating: 3.5, name: 'Nota 3,5'),
        activity('f4', ActivityKind.reviewed, rating: 5, name: 'Review 5'),
        activity('f5', ActivityKind.watching, name: 'Começou'),
        activity('f6', ActivityKind.watched, daysAgo: 31, name: 'Velho'),
        activity('f7', ActivityKind.watched, daysAgo: 30, name: 'No limite'),
        activity('mine', ActivityKind.watched, name: 'Já no meu diário'),
        activity('want', ActivityKind.rated, rating: 5, name: 'Já quero ver'),
        activity('me1', ActivityKind.watched, user: 'me', name: 'Minha'),
        activity('f8', ActivityKind.listCreated, name: 'Lista'),
      ],
      now: now,
    );
    final friends = c.where((x) => x.source == CandidateSource.friends).toList();
    expect(friends.map((x) => x.name).toList(), ['Assistiu', 'Nota 4', 'Review 5', 'No limite']);
    expect(friends.every((x) => x.weight == 0.3 && x.friendUsername == 'vini'), isTrue);
    // "W" é meu (quero ver); a atividade do amigo sobre ele não duplica
    expect(c.where((x) => x.titleId == 'want').length, 1);
    expect(c.first.name, 'W', reason: 'meus primeiro');
  });

  test('mesmo título por dois amigos entra uma vez, pela atividade mais recente', () {
    final c = buildCandidates(
      myUserId: 'me',
      myEntries: const [],
      friendActivities: [
        activity('f1', ActivityKind.watched, user: 'camila', daysAgo: 5),
        activity('f1', ActivityKind.rated, rating: 4.5, user: 'vini', daysAgo: 2),
      ],
      now: now,
    );
    expect(c.length, 1);
    expect(c.single.friendUsername, 'vini');
  });

  test('registro sem título embutido é pulado (não dá para mostrar)', () {
    final c = buildCandidates(
      myUserId: 'me',
      myEntries: [const Entry(id: 'e', userId: 'me', titleId: 'x', status: EntryStatus.want)],
      friendActivities: [activity('f', ActivityKind.watched).copyWith(title: null)],
      now: now,
    );
    expect(c, isEmpty);
  });
}
