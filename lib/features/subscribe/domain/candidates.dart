// Quem entra na conta do recomendador (SPEC §J5.1). Pura, testada em
// `test/features/subscribe/domain/candidates_test.dart`.

import '../../diary/domain/entry.dart';
import '../../feed/domain/activity.dart';
import 'recommendation.dart';

/// Janela em que o que os amigos assistiram ainda conta.
const friendsWindow = Duration(days: 30);

/// Nota mínima para "avaliou bem".
const friendsMinRating = 4.0;

/// Monta a lista de candidatos:
/// - meus registros em "Quero ver" e "Assistindo" (peso 1);
/// - títulos que quem eu sigo **assistiu, avaliou ≥ 4 ou escreveu sobre** nos
///   últimos 30 dias, que **não estão no meu diário** em nenhum estado (peso
///   0,3). Uma atividade avaliada abaixo de 4 não entra (o amigo não gostou);
///   "começou a assistir" também não (ainda não é veredito). Cada título
///   aparece uma vez, pela atividade mais recente.
///
/// [friendActivities] é o feed (quem eu sigo + eu): as minhas são ignoradas
/// pelo [myUserId]. Entradas sem título embutido são puladas: sem nome e tipo
/// não dá para mostrar nem abrir.
List<Candidate> buildCandidates({
  required String myUserId,
  required List<Entry> myEntries,
  required List<Activity> friendActivities,
  required DateTime now,
}) {
  final inMyDiary = {for (final e in myEntries) e.titleId};
  final mine = <Candidate>[
    for (final e in myEntries)
      if ((e.status == EntryStatus.want || e.status == EntryStatus.watching) && e.title != null)
        Candidate(
          titleId: e.titleId,
          name: e.title!.title,
          source: CandidateSource.mine,
          mediaType: e.title!.mediaType,
          tmdbId: e.title!.tmdbId,
          posterPath: e.title!.posterPath,
        ),
  ];

  final since = now.subtract(friendsWindow);
  final seen = <String>{};
  final friends = <Candidate>[];
  final recentFirst = [...friendActivities]..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  for (final a in recentFirst) {
    if (a.userId == myUserId) continue;
    if (a.createdAt.isBefore(since)) continue;
    if (!_isVerdict(a)) continue;
    final titleId = a.titleId;
    final title = a.title;
    if (titleId == null || title == null) continue;
    if (inMyDiary.contains(titleId) || !seen.add(titleId)) continue;
    friends.add(Candidate(
      titleId: titleId,
      name: title.title,
      source: CandidateSource.friends,
      mediaType: title.mediaType,
      tmdbId: title.tmdbId,
      posterPath: title.posterPath,
      friendUsername: a.user?.username,
    ));
  }
  return [...mine, ...friends];
}

/// Assistiu (sem nota ou com nota ≥ 4), avaliou ≥ 4 ou escreveu review (idem).
bool _isVerdict(Activity a) {
  switch (a.kind) {
    case ActivityKind.watched:
    case ActivityKind.rated:
    case ActivityKind.reviewed:
      final rating = a.rating;
      return rating == null || rating >= friendsMinRating;
    case ActivityKind.watching:
    case ActivityKind.listCreated:
    case ActivityKind.imported:
      return false;
  }
}
