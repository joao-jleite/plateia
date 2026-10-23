/// Normalização de nomes para comparar o CSV da Netflix com o TMDB. Espelha
/// `normalizeName` da Edge Function `import-match` (minúsculas, sem acento nem
/// pontuação, `&` → "e", espaços colapsados). O Dart não tem NFD nativo, então
/// os acentos latinos saem por tabela; letras não latinas (katakana, hangul)
/// ficam como estão.
library;

const _accentFold = <String, String>{
  'á': 'a', 'à': 'a', 'â': 'a', 'ã': 'a', 'ä': 'a', 'å': 'a', 'ª': 'a',
  'ç': 'c',
  'é': 'e', 'è': 'e', 'ê': 'e', 'ë': 'e',
  'í': 'i', 'ì': 'i', 'î': 'i', 'ï': 'i',
  'ñ': 'n',
  'ó': 'o', 'ò': 'o', 'ô': 'o', 'õ': 'o', 'ö': 'o', 'ø': 'o', 'º': 'o',
  'ú': 'u', 'ù': 'u', 'û': 'u', 'ü': 'u',
  'ý': 'y', 'ÿ': 'y',
  'ß': 'ss', 'œ': 'oe', 'æ': 'ae',
};

final _notLetterOrDigit = RegExp(r'[^\p{L}\p{N}]+', unicode: true);
final _spaces = RegExp(r'\s+');

String normalizeName(String s) {
  final sb = StringBuffer();
  for (final rune in s.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    sb.write(_accentFold[ch] ?? ch);
  }
  return sb
      .toString()
      .replaceAll('&', ' e ')
      .replaceAll(_notLetterOrDigit, ' ')
      .replaceAll(_spaces, ' ')
      .trim();
}
