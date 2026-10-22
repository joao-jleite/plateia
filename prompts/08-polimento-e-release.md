# Fase 08 — Polimento e release
Modelo: Fable 5.1 · esforço high

## Objetivo
Deixar o app com cara de produto e pronto para a Google Play.

## Design
- Identidade visual própria, escura por padrão (é app de filme). Proponha 2 direções curtas, o João escolhe e você aplica no app inteiro.
- Onboarding em 3 telas: o que é, importar a Netflix e seguir amigos.
- Estados vazios que convidam à ação, carregamento com skeleton e transições discretas.
- Acessibilidade: contraste, tamanho de fonte do sistema e rótulos para leitor de tela.
- Performance: cache de imagem, listas longas sem engasgo e tempo de abertura medido.
- Ícone e splash.

## Release
- Build de release assinado. A keystore fica fora do git e o João guarda.
- AAB para a loja e APK para teste.
- Política de privacidade numa página simples (pode ir no GitHub Pages do João) dizendo o que é coletado e por quê, e que o CSV da Netflix não é guardado.
- Respostas do formulário "Segurança dos dados" do Play.
- Checklist da política de conteúdo gerado por usuário: denúncia, bloqueio e moderação.
- Monitoramento de crash, só se for gratuito e leve.

## Pronto quando
- Checklist do Play completo em `docs/RELEASE.md`.
- AAB gerado.
- APK na Área de Trabalho.
- O João testou no próprio celular.
- Commit feito e "Fases" do `CLAUDE.md` toda marcada.
