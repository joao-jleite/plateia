import 'package:freezed_annotation/freezed_annotation.dart';

import '../../../core/model/media_type.dart';

part 'import_models.freezed.dart';
part 'import_models.g.dart';

/// Confiança do casamento (docs/ARQUITETURA.md §9). `high` entra direto no
/// diário; `medium` e `low` vão para a revisão.
enum MatchConfidence {
  @JsonValue('high')
  high,
  @JsonValue('medium')
  medium,
  @JsonValue('low')
  low;

  bool get isAutomatic => this == high;
}

/// Candidato devolvido pela Edge Function `import-match` e guardado em
/// `import_candidates.candidates` (jsonb). `title_id` já existe em `titles`
/// como linha-esboço.
@freezed
abstract class ImportCandidate with _$ImportCandidate {
  const factory ImportCandidate({
    required String titleId,
    required int tmdbId,
    required MediaType mediaType,
    required String title,
    int? year,
    String? posterPath,
    @Default(0) double score,
  }) = _ImportCandidate;

  factory ImportCandidate.fromJson(Map<String, dynamic> json) => _$ImportCandidateFromJson(json);
}

@freezed
abstract class ImportMatch with _$ImportMatch {
  const factory ImportMatch({
    required String rawName,
    required MatchConfidence confidence,
    ImportCandidate? best,
    @Default(<ImportCandidate>[]) List<ImportCandidate> candidates,
  }) = _ImportMatch;

  factory ImportMatch.fromJson(Map<String, dynamic> json) => _$ImportMatchFromJson(json);
}

@freezed
abstract class ImportMatchResponse with _$ImportMatchResponse {
  const factory ImportMatchResponse({
    required List<ImportMatch> matches,
    @Default(0) int upstreamCalls,
  }) = _ImportMatchResponse;

  factory ImportMatchResponse.fromJson(Map<String, dynamic> json) => _$ImportMatchResponseFromJson(json);
}

/// Linha de `public.imports` (resumo; o CSV nunca é guardado).
@freezed
abstract class ImportRecord with _$ImportRecord {
  const factory ImportRecord({
    required String id,
    required String userId,
    @Default('netflix') String source,
    String? fileHash,
    @Default(0) int rowsTotal,
    @Default(0) int titlesTotal,
    @Default(0) int titlesMatched,
    @Default(0) int titlesReview,
    @Default(0) int titlesNew,
    @Default('running') String status,
    DateTime? createdAt,
    DateTime? finishedAt,
  }) = _ImportRecord;

  factory ImportRecord.fromJson(Map<String, dynamic> json) => _$ImportRecordFromJson(json);
}

/// Linha de `public.import_candidates`: um nome do CSV que precisa de revisão.
@freezed
abstract class ImportCandidateRow with _$ImportCandidateRow {
  const ImportCandidateRow._();

  const factory ImportCandidateRow({
    required String id,
    required String importId,
    required String userId,
    required String rawName,
    MediaType? guessedType,
    @Default(1) int episodesCount,
    DateTime? lastWatchedAt,
    @Default(<ImportCandidate>[]) List<ImportCandidate> candidates,
    String? resolvedTitleId,
    DateTime? resolvedAt,
    @Default(false) bool skipped,
    DateTime? createdAt,
  }) = _ImportCandidateRow;

  factory ImportCandidateRow.fromJson(Map<String, dynamic> json) => _$ImportCandidateRowFromJson(json);

  bool get isPending => resolvedAt == null && !skipped;
}
