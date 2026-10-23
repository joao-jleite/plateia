/// Estado da importação que a tela mostra (progresso e resumo final).
library;

enum ImportPhase { idle, reading, matching, writing, done, failed }

class ImportSummary {
  const ImportSummary({
    required this.importId,
    required this.rowsTotal,
    required this.titlesTotal,
    required this.titlesMatched,
    required this.titlesReview,
    required this.titlesNew,
    required this.titlesUpdated,
    this.skippedRows = 0,
    this.dateAmbiguous = false,
    this.profile,
  });

  final String importId;
  final int rowsTotal;
  final int titlesTotal;

  /// Casados automaticamente (`high`).
  final int titlesMatched;

  /// Foram para a revisão (`medium` + `low`).
  final int titlesReview;

  /// Entradas novas no diário (o resto já existia).
  final int titlesNew;
  final int titlesUpdated;
  final int skippedRows;
  final bool dateAmbiguous;
  final String? profile;

  /// "312 títulos importados, 9 para revisar"
  String get headline {
    final t = titlesMatched == 1 ? '1 título importado' : '$titlesMatched títulos importados';
    if (titlesReview == 0) return t;
    return '$t, $titlesReview para revisar';
  }

  int get alreadyThere => titlesMatched - titlesNew;
}

class ImportProgress {
  const ImportProgress({
    this.phase = ImportPhase.idle,
    this.done = 0,
    this.total = 0,
    this.message,
    this.summary,
    this.error,
  });

  final ImportPhase phase;
  final int done;
  final int total;
  final String? message;
  final ImportSummary? summary;
  final String? error;

  bool get isBusy => phase == ImportPhase.reading || phase == ImportPhase.matching || phase == ImportPhase.writing;

  /// Null = indeterminado (lendo o arquivo).
  double? get fraction => total == 0 ? null : (done / total).clamp(0, 1);

  ImportProgress copyWith({ImportPhase? phase, int? done, int? total, String? message}) => ImportProgress(
        phase: phase ?? this.phase,
        done: done ?? this.done,
        total: total ?? this.total,
        message: message ?? this.message,
        summary: summary,
        error: error,
      );
}
