# Fase 03 — Base do app e catálogo
Modelo: Fable 5.1 · esforço xhigh

## O que a fase 02 já decidiu (não rediscutir)
- `docs/ARQUITETURA.md` manda em tudo de estrutura: Riverpod 3 com codegen, go_router com shell de 5 abas, feature-first (`lib/features/<x>/{data,domain,presentation}` + `lib/core`), modelos `freezed`. Pacote Android **`io.github.joaojleite.watchlog`**, nome Dart `watchlog`, rótulo visível "Plateia".
- O banco existe: `supabase/migrations/0001_init.sql` (22 tabelas, RLS, triggers, seeds de `providers`) e `0002_storage_avatars.sql`. Tabela ou coluna nova = migração 0003+; **nunca** editar a 0001. `npm run db:test` (Postgres local sem Docker) tem que passar antes de qualquer `supabase db push`.
- A pasta já é repo git (fases 01 e 02 commitadas). O projeto Flutter é criado **dentro** dela, sem `git init`: `flutter create --org io.github.joaojleite --project-name watchlog --platforms android .` (ou equivalente que preserve `docs/`, `prompts/`, `research/`, `supabase/`, `tools/`).
- Máquina **sem Docker e sem Deno**: `supabase start` e `supabase functions serve` não funcionam. Edge Functions vão direto para o projeto de dev com `supabase functions deploy <nome> --use-api`; o teste é pelo app e pelos logs no dashboard. Em `supabase/config.toml`, `major_version = 17` e o redirect do OAuth já estão.
- Chaves (`TMDB_API_KEY` token v4, `RAPIDAPI_KEY`) entram por `supabase secrets set`, pelo João. Se faltar algo dele (projeto, chaves, OAuth), implemente tudo, teste o que der e deixe o passo a passo exato em `docs/PENDENCIAS-JOAO.md`.

## Objetivo
App rodando com login e catálogo: buscar qualquer filme, série ou anime, ver o detalhe em PT-BR, ver onde ele está no Brasil e abrir o app oficial do streaming.

## Escopo
- Projeto Flutter nesta pasta seguindo a `docs/ARQUITETURA.md` (pastas, pacotes, `--dart-define` para `SUPABASE_URL`/`SUPABASE_ANON_KEY`; nada hardcoded).
- Login por e-mail e por Google (Supabase Auth; Google pelo fluxo nativo `google_sign_in` → `signInWithIdToken`). Deep link `io.github.joaojleite.watchlog://login-callback` no manifesto.
- Onboarding mínimo: escolher o `@` (`profiles.username`, regra `^[a-z0-9_]{3,20}$`) e gravar `onboarded_at`. As etapas "importar" e "seguir" chegam nas fases 05 e 06; deixe o fluxo com "Agora não".
- Edge Functions desta fase, com os contratos da `docs/ARQUITETURA.md` §9: `catalog-search`, `catalog-title`, `home-sections`, `providers-sync` e `account-delete` (a Play exige apagar conta; entra já). `import-match` é da fase 05. `catalog-title` chama `consume_api_quota('motn', 900)` antes de cada chamada à Streaming Availability e respeita os TTLs (título 30 d, providers 7 d, links 7 d).
- `providers-sync` na primeira execução confirma nomes e logos dos 8 destacados (ids do seed: 8, 119, 337, 1899, 307, 350, 531, 283). Se algum id estiver errado, corrija por **nova migração**, não no seed.
- Telas: **Início** (seções de `home_sections`: em alta no Brasil, novidades por streaming destacado), **Busca**, **Detalhe** (pôster, sinopse, elenco em `titles.cast_top`, temporadas, "Onde assistir"). Abas Feed e Assinar com estado vazio "em breve". Perfil mínimo (cartão, sair, apagar conta) só para o shell ficar inteiro; o perfil de verdade é a fase 04.
- **Onde assistir** (SPEC §5.7): assinatura → com anúncios → grátis → aluguel → compra; logo do streaming; botão com texto conforme o caso: "Abrir na X" (há `deep_link`), "Buscar na X" (`providers.search_url_template`), "Abrir o Disney+" (pacote `com.disney.disneyplus` ou Play Store), "Ver na JustWatch" (último recurso). HBO Max sempre `play.hbomax.com`.
- Android 11+: `<queries>` no manifesto com os pacotes de `providers.android_package` e o intent VIEW https; abrir com `LaunchMode.externalApplication`.
- Atribuição TMDB + JustWatch na seção Onde assistir e na tela Sobre (texto em SPEC §5.7).

## Restrições
- Cada título consultado de novo dentro do TTL usa o cache e não gasta cota (log da função mostra `upstream_calls: 0`).
- Estados de carregando, vazio e erro em toda tela (`AsyncView` do core).
- `supabase link` + `supabase db push` no projeto de dev assim que a URL existir; `0002` pode exigir o SQL Editor (nota no cabeçalho do arquivo).

## Precisa do João
Projeto Supabase em `sa-east-1` (URL e anon key num `.env` fora do git), `supabase login` + `supabase link`, `supabase secrets set TMDB_API_KEY=… RAPIDAPI_KEY=…`, OAuth do Google no Google Cloud (client Web + Android com o SHA-1 da keystore de debug). Passo a passo em `docs/PENDENCIAS-JOAO.md`.

## Pronto quando
- No emulador: buscar "One Piece" → abrir o detalhe → ver onde assistir → o botão abre o app ou o site oficial.
- Abrir o mesmo título de novo não chama API externa (mostre no log).
- `npm run db:test` verde; `supabase db push` aplicado no dev (ou documentado como bloqueado).
- `flutter analyze` limpo e testes de widget das telas principais.
- APK na Área de Trabalho e commit feito.
