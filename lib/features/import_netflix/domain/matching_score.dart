/// Espelho em Dart da pontuação da Edge Function `import-match`
/// (`supabase/functions/import-match/handler.ts`, docs/ARQUITETURA.md §9).
/// A regra de produção é a da função; esta cópia existe para o backend de
/// fixtures produzir high/medium/low com a mesma lógica no emulador e nos
/// testes de widget. Se mudar lá, mude aqui.
library;

import '../../../core/model/media_type.dart';
import 'text_normalize.dart';

/// Popularidade mínima para um resultado contar como relevante.
const relevantPopularity = 1.0;

bool isExactName(String rawName, {required String title, String? originalTitle}) {
  final wanted = normalizeName(rawName);
  if (wanted.isEmpty) return false;
  return wanted == normalizeName(title) || (originalTitle != null && wanted == normalizeName(originalTitle));
}

/// +0,6 exato · +0,3 parcial · +0,2 tipo · +0,1 ano · +0,1 único exato relevante.
double scoreCandidate({
  required String rawName,
  MediaType? guessedType,
  int? year,
  required String title,
  String? originalTitle,
  required MediaType mediaType,
  int? resultYear,
  double popularity = 0,
  required int exactRelevantCount,
}) {
  final wanted = normalizeName(rawName);
  final t = normalizeName(title);
  final o = originalTitle == null ? '' : normalizeName(originalTitle);
  final exact = isExactName(rawName, title: title, originalTitle: originalTitle);
  var score = 0.0;
  if (exact) {
    score += 0.6;
  } else if (wanted.length >= 4 && (t.contains(wanted) || o.contains(wanted) || (t.length >= 4 && wanted.contains(t)))) {
    score += 0.3;
  }
  if (guessedType != null && guessedType == mediaType) score += 0.2;
  if (year != null && resultYear == year) score += 0.1;
  if (exact && exactRelevantCount == 1 && popularity >= relevantPopularity) score += 0.1;
  return (score * 100).round() / 100;
}

/// high ≥ 0,9 sem segundo ≥ 0,8; medium ≥ 0,6; low abaixo (ou sem candidato).
String confidenceFor(List<double> sortedScores) {
  final best = sortedScores.isEmpty ? 0.0 : sortedScores.first;
  final second = sortedScores.length > 1 ? sortedScores[1] : 0.0;
  if (best >= 0.9 && second < 0.8) return 'high';
  if (best >= 0.6) return 'medium';
  return 'low';
}
