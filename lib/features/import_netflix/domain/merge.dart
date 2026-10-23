/// Regra de merge da importação com o diário (SPEC §5.8: "reimportar não
/// sobrescreve nota, review ou status editados à mão"). Puro, testado em
/// `test/features/import_netflix/domain/merge_test.dart`.
///
/// - Título sem registro → cria `watched` com `source = netflix_import`.
/// - Registro com status diferente de `watched` (a pessoa pôs "assistindo" ou
///   "quero ver") → não mexe.
/// - Registro ainda `netflix_import` (ninguém editou) → avança `watched_at`
///   para a reprodução mais recente e `episodes_watched` para o maior valor.
/// - Registro `manual` (editado à mão) → só preenche o que está vazio.
/// - Nota, review, spoiler e `watch_count` nunca são tocados pela importação.
library;

import '../../../core/model/media_type.dart';
import '../../diary/domain/entry.dart';

/// Um título casado (high na função, ou escolhido na revisão) pronto para o diário.
class ImportedTitle {
  const ImportedTitle({
    required this.titleId,
    required this.mediaType,
    required this.lastWatchedAt,
    required this.episodesCount,
  });

  final String titleId;
  final MediaType mediaType;
  final DateTime lastWatchedAt;
  final int episodesCount;

  /// Filme não tem `episodes_watched`.
  int? get episodesWatched => mediaType == MediaType.tv ? episodesCount : null;
}

/// Linha nova em `entries` (insert com `on conflict do nothing`).
class EntryInsert {
  const EntryInsert({required this.titleId, required this.watchedAt, this.episodesWatched});

  final String titleId;
  final DateTime watchedAt;
  final int? episodesWatched;

  Map<String, Object?> toJson(String userId) => {
        'user_id': userId,
        'title_id': titleId,
        'status': 'watched',
        'watched_at': dateOnly(watchedAt),
        if (episodesWatched != null) 'episodes_watched': episodesWatched,
        'source': 'netflix_import',
      };
}

/// Atualização parcial de uma linha existente (só os campos presentes).
class EntryPatch {
  const EntryPatch({required this.entryId, required this.titleId, this.watchedAt, this.episodesWatched});

  final String entryId;
  final String titleId;
  final DateTime? watchedAt;
  final int? episodesWatched;

  bool get isEmpty => watchedAt == null && episodesWatched == null;

  Map<String, Object?> toJson() => {
        if (watchedAt != null) 'watched_at': dateOnly(watchedAt!),
        if (episodesWatched != null) 'episodes_watched': episodesWatched,
      };
}

class MergePlan {
  const MergePlan({required this.inserts, required this.patches, required this.untouched});

  final List<EntryInsert> inserts;
  final List<EntryPatch> patches;

  /// Já estavam no diário e não precisaram de nada (ou têm edição manual).
  final int untouched;
}

/// Dois nomes do CSV que casaram no mesmo título (ex.: "One Piece" e
/// "One Piece: Especial") viram um só: soma episódios, data mais recente.
List<ImportedTitle> dedupeImported(Iterable<ImportedTitle> items) {
  final byId = <String, ImportedTitle>{};
  for (final it in items) {
    final prev = byId[it.titleId];
    byId[it.titleId] = prev == null
        ? it
        : ImportedTitle(
            titleId: it.titleId,
            mediaType: it.mediaType,
            lastWatchedAt: it.lastWatchedAt.isAfter(prev.lastWatchedAt) ? it.lastWatchedAt : prev.lastWatchedAt,
            episodesCount: prev.episodesCount + it.episodesCount,
          );
  }
  return byId.values.toList();
}

MergePlan planMerge(Iterable<ImportedTitle> imported, Map<String, Entry> existingByTitleId) {
  final inserts = <EntryInsert>[];
  final patches = <EntryPatch>[];
  var untouched = 0;
  for (final it in dedupeImported(imported)) {
    final existing = existingByTitleId[it.titleId];
    if (existing == null) {
      inserts.add(EntryInsert(titleId: it.titleId, watchedAt: it.lastWatchedAt, episodesWatched: it.episodesWatched));
      continue;
    }
    if (existing.status != EntryStatus.watched) {
      untouched++;
      continue;
    }
    final imported = existing.source == 'netflix_import';
    DateTime? newDate;
    if (existing.watchedAt == null || (imported && it.lastWatchedAt.isAfter(_dateOnly(existing.watchedAt!)))) {
      newDate = it.lastWatchedAt;
    }
    int? newEpisodes;
    final eps = it.episodesWatched;
    if (eps != null && (existing.episodesWatched == null || (imported && eps > existing.episodesWatched!))) {
      newEpisodes = eps;
    }
    final patch = EntryPatch(entryId: existing.id, titleId: it.titleId, watchedAt: newDate, episodesWatched: newEpisodes);
    if (patch.isEmpty) {
      untouched++;
    } else {
      patches.add(patch);
    }
  }
  return MergePlan(inserts: inserts, patches: patches, untouched: untouched);
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

/// Coluna `date` do Postgres: `AAAA-MM-DD`, sem fuso.
String dateOnly(DateTime d) =>
    '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';
