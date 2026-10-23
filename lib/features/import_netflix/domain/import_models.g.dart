// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'import_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImportCandidate _$ImportCandidateFromJson(Map<String, dynamic> json) =>
    _ImportCandidate(
      titleId: json['title_id'] as String,
      tmdbId: (json['tmdb_id'] as num).toInt(),
      mediaType: $enumDecode(_$MediaTypeEnumMap, json['media_type']),
      title: json['title'] as String,
      year: (json['year'] as num?)?.toInt(),
      posterPath: json['poster_path'] as String?,
      score: (json['score'] as num?)?.toDouble() ?? 0,
    );

Map<String, dynamic> _$ImportCandidateToJson(_ImportCandidate instance) =>
    <String, dynamic>{
      'title_id': instance.titleId,
      'tmdb_id': instance.tmdbId,
      'media_type': _$MediaTypeEnumMap[instance.mediaType]!,
      'title': instance.title,
      'year': ?instance.year,
      'poster_path': ?instance.posterPath,
      'score': instance.score,
    };

const _$MediaTypeEnumMap = {MediaType.movie: 'movie', MediaType.tv: 'tv'};

_ImportMatch _$ImportMatchFromJson(Map<String, dynamic> json) => _ImportMatch(
  rawName: json['raw_name'] as String,
  confidence: $enumDecode(_$MatchConfidenceEnumMap, json['confidence']),
  best: json['best'] == null
      ? null
      : ImportCandidate.fromJson(json['best'] as Map<String, dynamic>),
  candidates:
      (json['candidates'] as List<dynamic>?)
          ?.map((e) => ImportCandidate.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const <ImportCandidate>[],
);

Map<String, dynamic> _$ImportMatchToJson(_ImportMatch instance) =>
    <String, dynamic>{
      'raw_name': instance.rawName,
      'confidence': _$MatchConfidenceEnumMap[instance.confidence]!,
      'best': ?instance.best?.toJson(),
      'candidates': instance.candidates.map((e) => e.toJson()).toList(),
    };

const _$MatchConfidenceEnumMap = {
  MatchConfidence.high: 'high',
  MatchConfidence.medium: 'medium',
  MatchConfidence.low: 'low',
};

_ImportMatchResponse _$ImportMatchResponseFromJson(Map<String, dynamic> json) =>
    _ImportMatchResponse(
      matches: (json['matches'] as List<dynamic>)
          .map((e) => ImportMatch.fromJson(e as Map<String, dynamic>))
          .toList(),
      upstreamCalls: (json['upstream_calls'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ImportMatchResponseToJson(
  _ImportMatchResponse instance,
) => <String, dynamic>{
  'matches': instance.matches.map((e) => e.toJson()).toList(),
  'upstream_calls': instance.upstreamCalls,
};

_ImportRecord _$ImportRecordFromJson(Map<String, dynamic> json) =>
    _ImportRecord(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      source: json['source'] as String? ?? 'netflix',
      fileHash: json['file_hash'] as String?,
      rowsTotal: (json['rows_total'] as num?)?.toInt() ?? 0,
      titlesTotal: (json['titles_total'] as num?)?.toInt() ?? 0,
      titlesMatched: (json['titles_matched'] as num?)?.toInt() ?? 0,
      titlesReview: (json['titles_review'] as num?)?.toInt() ?? 0,
      titlesNew: (json['titles_new'] as num?)?.toInt() ?? 0,
      status: json['status'] as String? ?? 'running',
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
      finishedAt: json['finished_at'] == null
          ? null
          : DateTime.parse(json['finished_at'] as String),
    );

Map<String, dynamic> _$ImportRecordToJson(_ImportRecord instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'source': instance.source,
      'file_hash': ?instance.fileHash,
      'rows_total': instance.rowsTotal,
      'titles_total': instance.titlesTotal,
      'titles_matched': instance.titlesMatched,
      'titles_review': instance.titlesReview,
      'titles_new': instance.titlesNew,
      'status': instance.status,
      'created_at': ?instance.createdAt?.toIso8601String(),
      'finished_at': ?instance.finishedAt?.toIso8601String(),
    };

_ImportCandidateRow _$ImportCandidateRowFromJson(Map<String, dynamic> json) =>
    _ImportCandidateRow(
      id: json['id'] as String,
      importId: json['import_id'] as String,
      userId: json['user_id'] as String,
      rawName: json['raw_name'] as String,
      guessedType: $enumDecodeNullable(
        _$MediaTypeEnumMap,
        json['guessed_type'],
      ),
      episodesCount: (json['episodes_count'] as num?)?.toInt() ?? 1,
      lastWatchedAt: json['last_watched_at'] == null
          ? null
          : DateTime.parse(json['last_watched_at'] as String),
      candidates:
          (json['candidates'] as List<dynamic>?)
              ?.map((e) => ImportCandidate.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const <ImportCandidate>[],
      resolvedTitleId: json['resolved_title_id'] as String?,
      resolvedAt: json['resolved_at'] == null
          ? null
          : DateTime.parse(json['resolved_at'] as String),
      skipped: json['skipped'] as bool? ?? false,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$ImportCandidateRowToJson(_ImportCandidateRow instance) =>
    <String, dynamic>{
      'id': instance.id,
      'import_id': instance.importId,
      'user_id': instance.userId,
      'raw_name': instance.rawName,
      'guessed_type': ?_$MediaTypeEnumMap[instance.guessedType],
      'episodes_count': instance.episodesCount,
      'last_watched_at': ?instance.lastWatchedAt?.toIso8601String(),
      'candidates': instance.candidates.map((e) => e.toJson()).toList(),
      'resolved_title_id': ?instance.resolvedTitleId,
      'resolved_at': ?instance.resolvedAt?.toIso8601String(),
      'skipped': instance.skipped,
      'created_at': ?instance.createdAt?.toIso8601String(),
    };
