# Fase 08 — Polimento e release
Modelo: Fable 5.1 · esforço high

## O que já está decidido
- `applicationId` **`io.github.joaojleite.watchlog`** (não muda; o nome visível pode). Codinome "Plateia" pode virar o nome final ou não: a troca é só `android:label`, ícone e textos.
- Apagar conta já existe (`account-delete`); a Play exige também uma **página pública** explicando como apagar a conta e os dados. Sem domínio próprio, vai no GitHub Pages do João (`joao-jleite.github.io`), junto com a política de privacidade e os termos.
- Atribuições obrigatórias (SPEC §5.7): TMDB (logo + frase), JustWatch (fonte de "onde assistir"), Streaming Availability se os termos pedirem. Logos dos streamings só para indicar onde o título está.
- Máquina sem Docker/Deno: qualquer mudança em Edge Function sai com `supabase functions deploy --use-api`. Config do Auth (redirects, Google) espelhada em `supabase/config.toml`.
- Produção: por padrão o projeto de dev vira produção (dev solo). Criar um segundo projeto só se houver dado de usuário real para proteger; registre a escolha em "Decisões".

## Objetivo
Deixar o app com cara de produto e pronto para a Google Play.

## Design
- Identidade visual própria, escura por padrão (é app de filme). Proponha 2 direções curtas em `docs/DESIGN.md` com paleta, tipografia e um mock de 3 telas; sem o João responder, aplique a recomendada e registre.
- Onboarding em 3 telas: o que é, importar a Netflix e seguir amigos (o fluxo já existe; aqui é acabamento).
- Estados vazios que convidam à ação, carregamento com skeleton e transições discretas.
- Acessibilidade: contraste, tamanho de fonte do sistema e rótulos para leitor de tela.
- Performance: cache de imagem, listas longas sem engasgo (feed, diário) e tempo de abertura medido.
- Ícone e splash.

## Release
- Build de release assinado. A keystore fica fora do git (já no `.gitignore`) e o João guarda a senha.
- AAB para a loja e APK para teste.
- Página pública (GitHub Pages): política de privacidade (o que é coletado e por quê; o CSV da Netflix não é guardado, só títulos casados e um hash), termos de uso, como apagar a conta.
- Respostas do formulário "Segurança dos dados" do Play, coerentes com o banco (e-mail, nome, foto, diário, listas, atividade social; nada vendido; coleta por conta).
- Checklist da política de conteúdo gerado por usuário: denúncia (`reports`), bloqueio (`blocks`), remoção pelo João via dashboard, termos aceitos no cadastro.
- Antes de cobrar ou colocar anúncio: licença comercial do TMDB e Starter da Streaming Availability (fica como pendência; o MVP sai grátis e sem anúncio).
- Monitoramento de crash, só se for gratuito e leve.

## Pronto quando
- Checklist do Play completo em `docs/RELEASE.md`.
- AAB gerado; APK na Área de Trabalho.
- `npm run db:test`, `flutter analyze` e os testes passam.
- O João testou no próprio celular.
- Commit feito e "Fases" do `CLAUDE.md` toda marcada.
