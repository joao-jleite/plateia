/// Regra do `@` (SPEC §5.1 e check de `profiles.username`): `^[a-z0-9_]{3,20}$`.
/// Lógica pura, sem Flutter, para testar unitariamente.
library;

final usernamePattern = RegExp(r'^[a-z0-9_]{3,20}$');

/// Tira espaços, `@` inicial e maiúsculas antes de validar/salvar.
String normalizeUsername(String raw) {
  var s = raw.trim().toLowerCase();
  if (s.startsWith('@')) s = s.substring(1);
  return s;
}

/// Mensagem de erro em pt-BR, ou null quando válido.
String? validateUsername(String raw) {
  final s = normalizeUsername(raw);
  if (s.isEmpty) return 'Escolha um @.';
  if (s.length < 3) return 'Pelo menos 3 caracteres.';
  if (s.length > 20) return 'No máximo 20 caracteres.';
  if (!usernamePattern.hasMatch(s)) return 'Só letras minúsculas, números e _.';
  return null;
}

/// Sugestão a partir do nome ou e-mail ("Ana Souza" → "ana_souza").
String suggestUsername(String? displayName, String? email) {
  final source = (displayName != null && displayName.trim().isNotEmpty)
      ? displayName
      : (email ?? '').split('@').first;
  var s = source
      .toLowerCase()
      .replaceAll(RegExp(r'[áàâãä]'), 'a')
      .replaceAll(RegExp(r'[éèêë]'), 'e')
      .replaceAll(RegExp(r'[íìîï]'), 'i')
      .replaceAll(RegExp(r'[óòôõö]'), 'o')
      .replaceAll(RegExp(r'[úùûü]'), 'u')
      .replaceAll('ç', 'c')
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
  if (s.length > 20) s = s.substring(0, 20);
  return s;
}
