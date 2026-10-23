/// Páginas públicas exigidas pela Google Play (política de privacidade, termos
/// e "como apagar a conta"). Moram em `docs/site/` e são publicadas no GitHub
/// Pages do João (docs/RELEASE.md). Quando houver domínio próprio, troca-se
/// só a base aqui e em `Routes.inviteUrl`.
abstract final class Legal {
  static const siteBase = 'https://joao-jleite.github.io/plateia';
  static const privacyUrl = '$siteBase/privacidade.html';
  static const termsUrl = '$siteBase/termos.html';
  static const deleteAccountUrl = '$siteBase/apagar-conta.html';

  /// E-mail de contato nas páginas e na ficha da loja (o João confirma).
  static const contactEmail = 'joao.jleite3@gmail.com';
}
