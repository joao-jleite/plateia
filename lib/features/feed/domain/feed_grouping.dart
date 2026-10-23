import 'activity.dart';

/// "4,5" no padrão brasileiro (cópia pura de `ratingLabel` para `domain/` não
/// depender do Flutter).
String _ratingLabel(double rating) =>
    rating == rating.roundToDouble() ? rating.toInt().toString() : rating.toString().replaceAll('.', ',');

/// Eventos consecutivos do mesmo autor no mesmo dia (local), como o feed os
/// mostra ("assistiu 4 títulos hoje"). A lista de entrada já vem ordenada do
/// mais novo para o mais velho; a agregação é só visual (SPEC §5.5).
class FeedGroup {
  const FeedGroup({required this.userId, required this.day, required this.items});

  final String userId;

  /// Dia local (meia-noite) do primeiro item do grupo.
  final DateTime day;
  final List<Activity> items;

  Activity get first => items.first;
}

List<FeedGroup> groupFeed(List<Activity> items) {
  final groups = <FeedGroup>[];
  for (final a in items) {
    final day = _dayOf(a.createdAt);
    final last = groups.isEmpty ? null : groups.last;
    if (last != null && last.userId == a.userId && last.day == day) {
      last.items.add(a);
    } else {
      groups.add(FeedGroup(userId: a.userId, day: day, items: [a]));
    }
  }
  return groups;
}

DateTime _dayOf(DateTime t) {
  final l = t.toLocal();
  return DateTime(l.year, l.month, l.day);
}

/// "hoje", "ontem", "22/10" ou "22/10/2025" (ano só se for outro).
String feedDayLabel(DateTime day, {DateTime? now}) {
  final today = _dayOf(now ?? DateTime.now());
  final diff = today.difference(_dayOf(day)).inDays;
  if (diff == 0) return 'hoje';
  if (diff == 1) return 'ontem';
  final d = day.toLocal();
  final dd = d.day.toString().padLeft(2, '0');
  final mm = d.month.toString().padLeft(2, '0');
  return d.year == today.year ? '$dd/$mm' : '$dd/$mm/${d.year}';
}

/// Verbo do evento, sem o sujeito ("@ana" vem do cabeçalho do grupo):
/// "assistiu", "avaliou", "escreveu sobre", "começou a assistir", "criou a
/// lista", "importou N títulos da Netflix".
String activityVerb(Activity a) => switch (a.kind) {
      ActivityKind.watched => a.isRewatch ? 'assistiu de novo' : 'assistiu',
      ActivityKind.rated => 'avaliou',
      ActivityKind.reviewed => 'escreveu sobre',
      ActivityKind.watching => 'começou a assistir',
      ActivityKind.listCreated => 'criou a lista',
      ActivityKind.imported => 'importou',
    };

/// Objeto da frase: o título, o nome da lista ou "312 títulos da Netflix".
String activityObject(Activity a) => switch (a.kind) {
      ActivityKind.listCreated => a.listName,
      ActivityKind.imported => '${a.importedCount} ${a.importedCount == 1 ? 'título' : 'títulos'} da Netflix',
      _ => a.title?.title ?? 'um título',
    };

/// Frase inteira, para leitores de tela e notificações:
/// "@ana avaliou The Bear ★ 4,5".
String activitySentence(Activity a) {
  final who = a.user == null ? 'Alguém' : '@${a.user!.username}';
  final rating = a.rating;
  final stars = rating == null || a.kind == ActivityKind.listCreated || a.kind == ActivityKind.imported
      ? ''
      : ' ★ ${_ratingLabel(rating)}';
  return '$who ${activityVerb(a)} ${activityObject(a)}$stars';
}

/// Resumo do grupo quando tem mais de um item: "3 atividades".
String groupSummary(FeedGroup g) =>
    g.items.length == 1 ? '' : '${g.items.length} atividades';
