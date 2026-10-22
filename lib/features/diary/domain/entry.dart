import 'package:freezed_annotation/freezed_annotation.dart';

import '../../catalog/domain/catalog_models.dart';

part 'entry.freezed.dart';
part 'entry.g.dart';

/// `entries.status` (SPEC §5.2): o estado atual da pessoa com o título.
enum EntryStatus {
  @JsonValue('watched')
  watched,
  @JsonValue('watching')
  watching,
  @JsonValue('want')
  want;

  String get labelPtBr => switch (this) {
        EntryStatus.watched => 'Assisti',
        EntryStatus.watching => 'Assistindo',
        EntryStatus.want => 'Quero ver',
      };

  /// Valor gravado na coluna `status`.
  String get dbValue => name;

  /// "Quero ver" não tem nota nem review (check no banco).
  bool get allowsRatingAndReview => this != EntryStatus.want;

  static EntryStatus? tryParse(String? value) => switch (value) {
        'watched' => EntryStatus.watched,
        'watching' => EntryStatus.watching,
        'want' => EntryStatus.want,
        _ => null,
      };
}

/// Linha de `public.entries`: uma por (usuário, título). `title` vem embutido
/// (`select('*, title:titles(*)')`) quando a tela precisa do pôster.
@freezed
abstract class Entry with _$Entry {
  const Entry._();

  const factory Entry({
    required String id,
    required String userId,
    required String titleId,
    required EntryStatus status,
    double? rating,
    String? review,
    @Default(false) bool hasSpoiler,
    DateTime? watchedAt,
    int? currentSeason,
    int? currentEpisode,
    int? episodesWatched,
    @Default(1) int watchCount,
    @Default('manual') String source,
    DateTime? createdAt,
    DateTime? updatedAt,
    Title? title,
  }) = _Entry;

  factory Entry.fromJson(Map<String, dynamic> json) => _$EntryFromJson(json);

  bool get hasReview => review != null && review!.trim().isNotEmpty;
  bool get isRewatch => watchCount > 1;
}

/// O que a folha Registrar manda salvar. Vira um upsert em (user_id, title_id).
@freezed
abstract class EntryDraft with _$EntryDraft {
  const EntryDraft._();

  const factory EntryDraft({
    required String titleId,
    required EntryStatus status,
    double? rating,
    String? review,
    @Default(false) bool hasSpoiler,
    DateTime? watchedAt,
    int? currentSeason,
    int? currentEpisode,
    int? episodesWatched,
    @Default(1) int watchCount,
  }) = _EntryDraft;

  /// Rascunho a partir do registro existente (ou vazio, com a data de hoje).
  factory EntryDraft.from(Entry? entry, {required String titleId, DateTime? today}) {
    if (entry == null) {
      return EntryDraft(titleId: titleId, status: EntryStatus.watched, watchedAt: today ?? DateTime.now());
    }
    return EntryDraft(
      titleId: entry.titleId,
      status: entry.status,
      rating: entry.rating,
      review: entry.review,
      hasSpoiler: entry.hasSpoiler,
      watchedAt: entry.watchedAt ?? today ?? DateTime.now(),
      currentSeason: entry.currentSeason,
      currentEpisode: entry.currentEpisode,
      episodesWatched: entry.episodesWatched,
      watchCount: entry.watchCount,
    );
  }

  /// Aplica a regra do banco antes de mandar: "quero ver" zera nota e review.
  EntryDraft normalized() => status.allowsRatingAndReview
      ? copyWith(review: (review == null || review!.trim().isEmpty) ? null : review!.trim())
      : copyWith(rating: null, review: null, hasSpoiler: false);
}

/// Nota válida: 0,5 a 5 em meias estrelas (check de `entries.rating`).
bool isValidRating(double? rating) =>
    rating == null || (rating >= 0.5 && rating <= 5 && (rating * 2) == (rating * 2).floorToDouble());

/// Quantos episódios a pessoa já viu, para as horas assistidas (SPEC §5.2).
/// - Assistindo em T[season] E[episode]: soma dos episódios das temporadas
///   anteriores (pelo `seasons` do TMDB) + o episódio atual.
/// - Assisti sem progresso informado: todos os episódios do título.
/// - Sem dado suficiente: null (a estatística ignora a entrada).
int? episodesWatchedFor(
  Title title, {
  required EntryStatus status,
  int? season,
  int? episode,
}) {
  if (status == EntryStatus.want) return null;
  if (season != null && episode != null) {
    final regular = title.seasons.where((s) => s.seasonNumber > 0).toList();
    var before = 0;
    for (final s in regular) {
      if (s.seasonNumber < season) before += s.episodeCount;
    }
    return before + episode;
  }
  if (status == EntryStatus.watched) return title.numberOfEpisodes;
  return null;
}

/// Registro otimista que a tela mostra antes de o servidor responder
/// (docs/ARQUITETURA.md §5). Preserva id/datas do registro anterior.
Entry optimisticEntry(Entry? previous, EntryDraft draft, {required String userId, Title? title, DateTime? now}) {
  final d = draft.normalized();
  final stamp = now ?? DateTime.now();
  return Entry(
    id: previous?.id ?? 'pending-${d.titleId}',
    userId: userId,
    titleId: d.titleId,
    status: d.status,
    rating: d.rating,
    review: d.review,
    hasSpoiler: d.hasSpoiler,
    watchedAt: d.watchedAt,
    currentSeason: d.currentSeason,
    currentEpisode: d.currentEpisode,
    episodesWatched: d.episodesWatched,
    watchCount: d.watchCount,
    source: previous?.source ?? 'manual',
    createdAt: previous?.createdAt ?? stamp,
    updatedAt: stamp,
    title: title ?? previous?.title,
  );
}
