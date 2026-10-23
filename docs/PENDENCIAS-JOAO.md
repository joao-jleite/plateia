# Pendências do João

Tudo o que só você pode fazer (contas, chaves, celular, dinheiro). Cada fase acrescenta aqui; marque `[x]` quando fizer. Chaves vão em `research/.env` (fase 01) ou em `supabase secrets set` (fase 03+), nunca no chat.

## Fase 01 · Validar APIs

- [ ] **Chave do TMDB** (grátis, ~5 min). Destrava os números do TMDB na tabela de `docs/decisoes-apis.md` e todo o catálogo da fase 03.
  1. Criar conta em https://www.themoviedb.org/signup e confirmar o e-mail.
  2. Em https://www.themoviedb.org/settings/api pedir uma chave "Developer" (tipo de uso: app pessoal/educacional por enquanto; URL pode ser o GitHub).
  3. Copiar o **API Read Access Token** (o longo, começa com `eyJ`) e colar em `research/.env` como `TMDB_API_KEY=`.
- [ ] **Chave da Streaming Availability (Movie of the Night) via RapidAPI** (grátis, 1.000 req/mês). Destrava os deep links.
  1. Conta em https://rapidapi.com (pode entrar com GitHub/Google).
  2. Abrir https://rapidapi.com/movie-of-the-night-movie-of-the-night-default/api/streaming-availability/pricing e assinar o plano **Free** (pede cartão? se pedir, prefira a alternativa abaixo).
  3. Copiar a `X-RapidAPI-Key` (aba Endpoints, canto direito) para `research/.env` como `RAPIDAPI_KEY=`.
  - Alternativa sem RapidAPI: chave direta em https://developers.movieofthenight.com (header `X-API-Key`, base `https://api.movieofthenight.com/v4`). Se escolher essa, avise na próxima fase que o script 03 precisa trocar o header e a base.
- [ ] **Chave da Watchmode** (grátis, 2.500 créditos/mês). Só para fechar a tabela comparativa; a fonte já foi descartada, então é opcional.
  1. https://api.watchmode.com → "Get a free API key" → confirmar e-mail.
  2. Colar em `research/.env` como `WATCHMODE_API_KEY=`.
- [ ] **Rodar a pesquisa com as chaves**: PowerShell em `research\` → `.\run_all.ps1`. Gasta ~40 chamadas TMDB, ~44 créditos Watchmode, ~21 req MOTN. Depois me mande "roda a fase 01 de novo" para eu atualizar os números no documento.
- [ ] **CSV da Netflix**: no navegador, Conta → Perfis → seu perfil → *Atividade de visualização* → rolar até o fim → "Baixar tudo". Salvar como `research/NetflixViewingHistory.csv` (está no `.gitignore`). Destrava o formato real para a fase 05 (passo 1 da seção "Fase 05", abaixo).
- [ ] **Testar no celular se o link abre o app** (2 min, com os apps instalados). Mande cada URL para você mesmo no Telegram/WhatsApp e toque:
  - Netflix: `https://www.netflix.com/search?q=stranger%20things`
  - HBO Max: `https://play.hbomax.com/search?q=the%20last%20of%20us`
  - Prime Video: `https://www.primevideo.com/search?phrase=the%20boys`
  - Globoplay: `https://globoplay.globo.com/busca/?q=arcanjo%20renegado`
  - Apple TV: `https://tv.apple.com/br/search?term=ruptura`
  - Paramount+: `https://www.paramountplus.com/br/search/?q=yellowstone`
  - Crunchyroll: `https://www.crunchyroll.com/pt-br/search?q=frieren`
  - Disney+ (não tem busca): `https://www.disneyplus.com/pt-br` só para ver se abre o app.
  Anote quais abriram o **app** e quais abriram o **navegador**; isso define o texto do botão na fase 03.

## Fase 02 · Spec e arquitetura

- [ ] **Ler e confirmar `docs/SPEC.md`** (10 min). Foi aprovada por procuração em 22/10 porque você deu liberdade total; se discordar de algo, avise **antes da fase 04** (diário) e **da 06** (social), porque mudar depois é migração. Os pontos marcados com ▶ na spec:
  1. Pacote Android `io.github.joaojleite.watchlog` (imutável na Play; "Plateia" fica só como rótulo visível).
  2. Diário com **uma linha por título**: reassistir soma `watch_count`; não há diário por episódio no MVP.
  3. Perfil privado esconde o **conteúdo** (diário, listas, atividades), não o **cartão** (username, foto, bio, contadores).
  4. O que entra no feed: assistiu, nota, review, começou a assistir, criou lista pública, importou histórico. "Quero ver" não entra.
  5. Preços dos streamings em `provider_prices` são **estimativas minhas**; a tela mostra "estimativa" até você corrigir (item abaixo).
- [ ] **Projeto Supabase** (grátis, ~5 min): https://supabase.com/dashboard → New project → região **`sa-east-1` (São Paulo)**, senha forte do banco (guarde fora do git). Depois:
  1. Project Settings → API: copiar **Project URL** e **anon key** para um arquivo `.env` na raiz do repo (já está no `.gitignore`) como `SUPABASE_URL=` e `SUPABASE_ANON_KEY=`. A `service_role` **não** vai para o app; só para `tools/db/.env` se a fase 06 pedir (seed de contas de teste).
  2. No PowerShell, na pasta do projeto: `supabase login` (abre o navegador) e `supabase link --project-ref <ref do projeto>`. Com isso a fase 03 aplica o banco com `supabase db push`.
  3. Authentication → URL Configuration → Redirect URLs: adicionar `io.github.joaojleite.watchlog://login-callback`.
- [ ] **Conferir os preços** quando quiser (dashboard → Table Editor → `provider_prices`): corrigir `price_cents` e marcar `is_estimate = false`. Fontes: página de planos de cada streaming. Fase 07 usa.
- [x] ~~**Opcional:** instalar o Deno~~ → instalei na fase 03 por `npm i -g deno` (2.9.6); `deno task check` e `deno task test` rodam em `supabase/functions/`.

## Fase 03 · Base e catálogo

O app, as 5 Edge Functions, os testes e o APK estão prontos, mas **nada foi verificado contra um projeto Supabase real** (ele ainda não existe). Abaixo, o que você roda, na ordem, e depois a lista do que eu confiro quando existir. O APK na Área de Trabalho (`plateia-fase03.apk`) roda com dados de amostra (10 títulos, "One Piece" entre eles) e não precisa de nada disso para você sentir o app.

### Passo a passo (uma vez, ~30 min)

- [ ] **1. Projeto Supabase** (item da fase 02, acima): `sa-east-1`, `.env` na raiz com `SUPABASE_URL=` e `SUPABASE_ANON_KEY=` (pode ser a publishable key `sb_publishable_…`), `supabase login` e `supabase link --project-ref <ref>`.
- [ ] **2. Banco**: no PowerShell, na pasta do projeto:
  ```powershell
  npm run db:test          # tem que ficar verde (2/2 testes) antes do push
  supabase db push
  ```
  Se a `0002_storage_avatars.sql` falhar por permissão em `storage.objects`: cole o arquivo no SQL Editor do dashboard e rode `supabase migration repair --status applied 0002`.
- [ ] **3. Segredos das funções** (as chaves da fase 01; nunca no chat nem no git):
  ```powershell
  supabase secrets set TMDB_API_KEY=<token v4 "API Read Access Token" do TMDB> RAPIDAPI_KEY=<X-RapidAPI-Key>
  ```
- [ ] **4. Deploy das 5 funções** (sem Docker, pela Management API):
  ```powershell
  supabase functions deploy catalog-search --use-api
  supabase functions deploy catalog-title --use-api
  supabase functions deploy home-sections --use-api
  supabase functions deploy providers-sync --use-api
  supabase functions deploy account-delete --use-api
  ```
- [ ] **5. Auth por e-mail**: dashboard → Authentication → Providers → Email. Para testar sem caixa de entrada, desligue "Confirm email" no projeto de dev (o app já trata os dois casos). Em URL Configuration, confirme `io.github.joaojleite.watchlog://login-callback` em Redirect URLs.
- [ ] **6. Login Google** (opcional para testar o resto; obrigatório antes da loja):
  1. Google Cloud → APIs e serviços → Credenciais → "ID do cliente OAuth" tipo **Aplicativo da Web** (nome livre). Guarde o Client ID e o Client Secret.
  2. Outro "ID do cliente OAuth" tipo **Android**: pacote `io.github.joaojleite.watchlog` e o SHA-1 da keystore de debug, que sai de:
     ```powershell
     keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
     ```
     (na fase 08 você adiciona também o SHA-1 da keystore de release).
  3. Supabase → Authentication → Providers → Google: ligar, colar Client ID e Secret do cliente **Web**.
  4. O Client ID **Web** vai para o app por `--dart-define=GOOGLE_WEB_CLIENT_ID=…` (passo 7). Nada de `google-services.json`.
- [ ] **7. Rodar o app contra o projeto** (emulador `lume34` ou celular com depuração USB):
  ```powershell
  flutter run --dart-define=SUPABASE_URL=https://<ref>.supabase.co --dart-define=SUPABASE_ANON_KEY=<anon ou publishable key> --dart-define=GOOGLE_WEB_CLIENT_ID=<client id web>
  ```
  Cadastre-se, escolha o @, busque "One Piece", abra o detalhe e toque em "Abrir na Netflix". Depois me mande "verifica a fase 03" que eu confiro a lista abaixo pelos logs.
- [ ] **8. Logo do TMDB** (a atribuição exige o logo, não só o texto): baixe o SVG azul em https://www.themoviedb.org/about/logos-attribution e salve como `assets/tmdb/logo.svg`. Eu ligo na tela Sobre e na seção Onde assistir na fase 08 (ou antes, se você pedir).

### O que eu verifico quando o projeto existir (não dá para fazer sem ele)

- [ ] `supabase db push` aplicou `0001` e `0002` (`supabase migration list` mostra as duas como remotas).
- [ ] As 5 funções aparecem no dashboard (Edge Functions) e respondem `401 unauthorized` sem JWT.
- [ ] `supabase secrets list` mostra `TMDB_API_KEY` e `RAPIDAPI_KEY`.
- [ ] `providers-sync` devolve `missing: []` e os nomes do TMDB batem com o seed (1899 deve vir como "Max"/"HBO Max"; se algum id vier ausente, migração `0003` corrige). `providers.logo_path` preenchido para os 8.
- [ ] Fluxo real: buscar "One Piece" → detalhe em pt-BR → Onde assistir com Netflix e Crunchyroll → botão "Abrir na Netflix" (link da Streaming Availability) abre o app ou o site.
- [ ] Abrir o mesmo título de novo: log de `catalog-title` com `upstream_calls: 0`; `api_usage` (`motn`) subiu só 1 na primeira abertura.
- [ ] Início: `home-sections` com `upstream_calls: 17` na primeira chamada e `0` nas seguintes por 6 h; as 9 seções preenchidas.
- [ ] Login por e-mail (com e sem "Confirm email"), "Esqueci a senha" abre o app pelo deep link e troca a senha, Google entra e cria o perfil com nome e foto, "Apagar conta" some do `auth.users` e devolve ao login.
- [ ] No celular, com os apps instalados: o botão abre o app oficial (não o navegador) para Netflix, HBO Max (`play.hbomax.com`), Prime Video, Globoplay (busca), Crunchyroll, Disney+ (pelo pacote). Os 8 links de busca da fase 01 continuam pendentes do seu teste.

## Fase 04 · Perfil e diário

Folha Registrar, listas, perfil com abas e contadores, estatísticas e configurações estão prontos e testados (74 testes Dart, `npm run db:test` 3/3), mas, como na fase 03, **nada rodou contra um projeto Supabase real**. O `plateia-fase04.apk` na Área de Trabalho roda com dados de amostra: você já entra com um diário cheio (One Piece assistindo, Oppenheimer 2×, Duna 2…), duas listas e pode abrir `@foxer` (público) e `@camila` (privado) pela rota `/profile/<username>`.

### O que você roda (depois dos passos da fase 03)

- [ ] **1. Migração 0003**: `npm run db:test` (3/3 verde) e depois `supabase db push`. A `0003_diary_stats.sql` cria a view `entry_stats_rows` e um índice; não mexe em tabela. `supabase migration list` deve mostrar 0001, 0002 e 0003 remotas.
- [ ] **2. Bucket de avatar**: dashboard → Storage → `avatars` existe, público, 2 MB, só imagem (veio da 0002). Se a 0002 tiver sido aplicada pelo SQL Editor, confira as 4 policies em `storage.objects`.
- [ ] **3. Fluxo real no emulador/celular** (`flutter run --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…`): abrir "One Piece" → **Registrar** → **Assisti** (tem que ficar marcado na hora) → nota 4,5 → review com "contém spoiler" → Salvar → aba Perfil: pôster na grade, contador "Assistidos 1", aba Reviews com a review borrada → ícone de estatísticas → horas aparecem. Depois Configurações → Editar perfil → trocar a foto (galeria) → a foto aparece no cartão. Me mande "verifica a fase 04" e eu confiro pelos logs e pelo dashboard.

### Decisões de spec que merecem o seu olhar (▶ também no `CLAUDE.md`, Decisões de 22/10)

- ▶ **Nota sem estado marca "Assisti"** (como no Letterboxd). Se preferir que a nota exija escolher o estado antes, é uma linha na folha.
- ▶ **Série em "Assisti" sem progresso conta todos os episódios nas horas**; "Assistindo" conta até a T/E informada. Alternativa: não contar nada até a pessoa informar (horas menores, porém "certas").
- ▶ **Review, spoiler e progresso gravam ao tocar em Salvar ou ao fechar a folha**; estado e nota gravam na hora. Se quiser tudo na hora, dá para ligar o salvamento com debounce na review.
- ▶ **Estatísticas no cliente** (view `entry_stats_rows`), não por RPC. Com 2 mil entradas são ~4 chamadas de 500 linhas; se no projeto real a tela demorar mais de 1 s, eu crio a RPC `profile_stats(uuid)` numa migração 0004.

### O que eu verifico quando o projeto existir

- [ ] `entry_stats_rows` responde para `authenticated` e devolve vazio para perfil privado de quem não sigo (mesma regra do teste SQL, agora via PostgREST).
- [ ] Upsert de `entries` com `on_conflict=user_id,title_id` devolve `title:titles(*)` embutido (o app usa o pôster que volta).
- [ ] `can_view_content` e `profile_counts` chamáveis por RPC com o JWT do app (grants padrão); contadores aparecem no perfil privado.
- [ ] Upload do avatar: `uploadBinary` com `upsert: true` na pasta `<uid>/`; `getPublicUrl` + `?v=` fura o cache do `cached_network_image`; `profiles.avatar_url` atualizado.
- [ ] Reordenar lista: um `upsert` em lote em `list_items` com `on_conflict=list_id,title_id` passa pela policy de update (dono).
- [ ] `lists!inner(user_id)` com `eq('lists.user_id', uid)` filtra só as minhas listas em `myListIdsContaining`.
- [ ] Trigger `entries_log_activity`: registrar pela folha cria `activities` (`watched`/`rated`/`reviewed`); "quero ver" não cria; desmarcar apaga em cascata.
- [ ] Perfil privado ligado em Configurações: o trigger `profiles_before_update` continua aceitando pendentes ao voltar para público (fase 06 testa de verdade).

## Fase 05 · Importar Netflix

Parser, agrupador, regra de merge, Edge Function `import-match`, migração `0004`, telas de importar/revisar e o backend de fixtures estão prontos e testados (135+ testes Dart, `npm run db:test` 4/4, `deno task test` 30/30), e o fluxo rodou no emulador com um CSV sintético de 23 linhas (capturas em `docs/capturas/fase05/`). O que **não** foi possível: o seu CSV real (`research/NetflixViewingHistory.csv` não existe) e o projeto Supabase. O `plateia-fase05.apk` na Área de Trabalho roda com dados de amostra: no onboarding (ou em Perfil → ⚙ → Importar histórico da Netflix) toque em "Usar CSV de exemplo (fixtures)" ou escolha um CSV seu pelo seletor; o resumo, a revisão e o aviso de "já importado" funcionam sem servidor.

### O que você roda (depois dos passos das fases 03 e 04)

- [ ] **1. CSV real, ensaio sem servidor** (1 min): baixe o histórico (Conta → Perfis → seu perfil → Atividade de visualização → "Baixar tudo"), salve como `research/NetflixViewingHistory.csv` (já no `.gitignore`) e rode na raiz do repo:
  ```powershell
  dart run tool/import_dry_run.dart research/NetflixViewingHistory.csv
  ```
  Ele imprime só contagens (linhas, grupos, padrões, datas, incertos). Me mande a saída: é o que confirma o formato real (ordem da data, padrões `Temporada`/`Parte`/arco) e o número de chamadas à função. `--names` lista os nomes agrupados no seu terminal, se quiser conferir o agrupamento.
- [ ] **2. Migração 0004**: `npm run db:test` (4/4 verde) e `supabase db push`. A `0004_import_idempotency.sql` acrescenta `imports.titles_new`, a unique `(user_id, raw_name)` em `import_candidates` e troca o trigger do evento `imported`. `supabase migration list` deve mostrar 0001–0004 remotas.
- [ ] **3. Deploy da função**: `supabase functions deploy import-match --use-api` (usa o mesmo `TMDB_API_KEY` já configurado).
- [ ] **4. Medir a % de casamento com o CSV real** (é a meta da fase: ≥ 90% automático): rode o app contra o projeto (`flutter run --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…`), vá em Perfil → ⚙ → Importar histórico da Netflix → escolha o CSV. O resumo diz "N títulos importados, M para revisar"; a % é N / (N + M). O log do app (`adb logcat -s flutter`) imprime a mesma conta pronta: `[import] rows=… groups=… high=… review=… auto_match=NN%`. Me mande essa linha e, se ficar abaixo de 90%, os nomes da tela de revisão que você achar que deveriam ter casado sozinhos: a correção é na pontuação da função (`supabase/functions/import-match/handler.ts`) ou nos padrões do parser (`lib/features/import_netflix/domain/title_patterns.dart`), e vale para todo mundo.
- [ ] **5. Rate limit e tempo da função com 5 mil linhas**: um histórico de 5 mil linhas vira ~500–800 nomes, ou seja, 5–8 chamadas de até 100 nomes, cada uma com até ~100–200 buscas no TMDB (concorrência 5, ~10–20 s). Se o dashboard mostrar `import-match` estourando o tempo limite da Edge Function, baixe `matchBatchSize` de 100 para 50 em `lib/features/import_netflix/presentation/import_providers.dart` (o servidor não muda). Se o TMDB responder 429 nos logs, aí sim é o rate limit: me avise que eu adiciono espera/retry no cliente da função.

### Decisões de spec que merecem o seu olhar (▶ também no `CLAUDE.md`, Decisões de 22/10)

- ▶ **Editar à mão marca o registro como `manual`**, e a importação passa a só preencher o que estiver vazio nele; um registro ainda "só importado" tem data e episódios atualizados a cada reimportação (nunca para trás). Alternativa: a importação nunca mais tocar num título que já está no diário.
- ▶ **Status diferente de "assisti" nunca é alterado pela importação** (se você pôs "quero ver" e o CSV diz que assistiu, fica "quero ver"). Alternativa: o CSV ganhar e virar "assisti".
- ▶ **Filme repetido em dias diferentes não vira reassistir** (`watch_count` fica 1), porque a Netflix grava uma linha por dia de reprodução, não por sessão inteira. Alternativa: contar como reassistido quando as datas tiverem mais de 30 dias de distância.
- ▶ **Sem ano no CSV, "exato + tipo" só vira automático se for o único casamento exato relevante**; homônimos (One Piece anime × live action) vão sempre para a revisão. É o que segura a precisão; se a % ficar baixa por isso, dá para aceitar o mais popular quando a diferença de popularidade for grande.
- ▶ **`ViewingActivity.csv`: trailers/prévias (coluna `Supplemental Video Type`) e reproduções com menos de 2 min ficam de fora.** O limite de 2 min é chute; o seu arquivo real diz se está bom.
- ▶ **Data ambígua (nenhum campo > 12 no arquivo inteiro) é lida como dia/mês** com aviso no resumo. Conta brasileira exporta `D/M/AA` segundo os relatos; o seu CSV confirma.

### O que eu verifico quando o projeto existir

- [ ] `import-match` responde `401` sem JWT e, com JWT, devolve `matches` com `title_id` preenchido; `titles` ganha linhas com `fetched_at = 1970-01-01` que o `catalog-title` renova ao abrir.
- [ ] Upsert de `entries` com `ignoreDuplicates` devolve só as linhas inseridas (é como o app conta `titles_new`); `patchEntries` passa pela policy de update.
- [ ] `imports` → `done` com `titles_new > 0` cria **um** evento `imported` no feed; reimportar o mesmo arquivo (hash igual) não cria outro.
- [ ] `import_candidates` com `on_conflict=user_id,raw_name` ignora os repetidos; a fila (`resolved_at is null and not skipped`) some ao resolver/pular; resolver grava a entrada.
- [ ] Log da função numa importação real: `{fn: import-match, …, upstream_calls: N, items, high, medium, low}` por lote e o tempo por lote de 100.

## Fase 06 · Rede social

Seguir (público aceita na hora; privado vira pedido, com aba de pedidos), feed agrupado por autor e dia, curtir e comentar (com spoiler), check-in "Assistindo agora", busca de pessoas e link de convite, bloquear/denunciar e notificações estão prontos e testados (164 testes Dart, `npm run db:test` 5/5, `deno task test` 30/30), e o fluxo das duas pontas rodou no emulador com os três perfis de amostra (capturas em `docs/capturas/fase06/`). Como nas fases anteriores, **nada rodou contra um projeto Supabase real**. O `plateia-fase06.apk` na Área de Trabalho roda com dados de amostra: na tela de login, "Entrar como" escolhe `@foxer` (público), `@camila` (privado) ou `@vini` (público); sair e entrar com outro mantém o que o anterior fez (a memória é do processo: fechar o app zera tudo).

### O que você roda (depois dos passos das fases 03–05)

- [ ] **1. Migração 0005**: `npm run db:test` (5/5 verde) e `supabase db push`. A `0005_social.sql` cria a view `friends_checkins`, o trigger `lists_sync_activity`, restringe o update de `notifications` à coluna `read_at` e cria um índice em `profiles.username`. `supabase migration list` deve mostrar 0001–0005 remotas.
- [ ] **2. Contas de teste (seed)**: crie `tools/db/.env` (já no `.gitignore`; a `service_role` **nunca** vai para o app nem para o chat) com:
  ```
  SUPABASE_URL=https://<ref>.supabase.co
  SUPABASE_SERVICE_ROLE_KEY=<service_role: dashboard → Project Settings → API>
  SEED_PASSWORD=<senha para as 3 contas>      # opcional; sem ela usa "plateia-dev-2026"
  ```
  e rode na raiz do repo:
  ```powershell
  npm run db:seed-dev:dry          # só imprime o plano, sem rede e sem .env
  npm run db:seed-dev              # cria ana.seed@example.com (@ana_seed, pública), bruno.seed@example.com (@bruno_seed, privado), carla.seed@example.com (@carla_seed, pública), 20 títulos, 22 registros de diário, 5 follows (carla→bruno fica pendente), 3 curtidas, 2 comentários, 1 lista pública e 1 check-in
  npm run db:seed-dev -- --reset   # apaga as 3 contas (cascade) para recomeçar
  ```
  É idempotente (rodar de novo não duplica) e nunca imprime a chave. Foi testado de ponta a ponta só no Postgres local (`npm run db:test:keep` num terminal e `npm run db:seed-dev:local` noutro: 3 perfis, 20 títulos, 22 entradas → 20 atividades, 10 notificações), não na Admin API real: se `POST /auth/v1/admin/users` devolver um erro que não seja "já existe", me mande a linha. Os títulos entram com `fetched_at = 1970`, então o `catalog-title` renova pôster e dados na primeira abertura (precisa do deploy e do `TMDB_API_KEY`).
- [ ] **3. Segunda conta no celular** (`flutter run --dart-define=SUPABASE_URL=… --dart-define=SUPABASE_ANON_KEY=…` ou um APK release com os mesmos defines): a sua conta no celular, `carla.seed@example.com` no emulador. Roteiro: carla busca o seu @ (Feed → ícone de pessoas) → Seguir; você recebe a notificação; no seu Feed, curta e comente uma review dela; ela vê as notificações e abre a atividade; no detalhe de um título toque em "Assistindo agora" e veja a faixa aparecer no Início dela; por fim, Perfil dela → ⋮ → Bloquear e confira que ela não acha mais você na busca nem vê suas atividades. Me mande "verifica a fase 06" que eu confiro pelos logs e pelo dashboard.
- [ ] **4. Link de convite** (`https://joao-jleite.github.io/plateia/u/<username>`, o que "Compartilhar perfil" manda): o app já responde a esse caminho (intent-filter sem `autoVerify`; o Android pergunta "Abrir com"). Para quem não tem o app, crie o repositório `joao-jleite/plateia` com GitHub Pages e uma página em `u/index.html` que leia o `@` do caminho e mostre "Baixe o Plateia" (uma página estática, sem build). Quando houver domínio próprio, troque `Routes.inviteUrl` e publique `/.well-known/assetlinks.json` para o link abrir direto no app.

### Decisões de spec que merecem o seu olhar (▶ também no `CLAUDE.md`, Decisões de 23/10)

- ▶ **Contadores de curtidas e comentários não são por visualizador**: quem bloqueou (ou foi bloqueado) continua contando no número; o conteúdo dele some, o número fica. Instagram e Letterboxd fazem igual; recalcular por visualizador custaria uma consulta por item do feed.
- ▶ **Bloquear desfaz os follows nos dois sentidos e desbloquear não refaz nada** (quem quiser segue de novo).
- ▶ **Dono da atividade apaga comentário alheio** (e o autor apaga o seu); ninguém edita comentário de outro.
- ▶ **Lista que vira privada some do feed; voltar a público não recria o evento** (senão quem alterna infla o feed).
- ▶ **Check-in dura 3 h (até 12 h, escolha na folha), um ativo por pessoa, e só aparece na faixa de quem segue você** (view `friends_checkins`); no seu Início aparece sempre, com "Encerrar".
- ▶ **Denúncias só entram** (`reports`): sem fila de moderação no app. Você lê pelo dashboard (Table Editor → `reports`) e age à mão; se a loja exigir, uma tela de moderação entra depois.
- ▶ **Feed por fan-out na leitura** (view `feed`), página de 30, agrupado no app por autor + dia, atualizado por puxar para baixo (sem "novos itens" automático).

### O que eu verifico quando o projeto existir

- [ ] PostgREST aceita os embeds com dica de FK usados no app: `follower:profiles!follows_follower_id_fkey(*)`, `actor:profiles!notifications_actor_id_fkey(*)` e `user:profiles(*)`, `title:titles(*)`, `list:lists(*)` na view `feed` (embed em view depende das FKs das tabelas base; se falhar, vira RPC numa `0006` sem mexer na tela).
- [ ] `feed` com `order(created_at desc)` + `range(0,29)` devolve só atividades de quem sigo (aceito) e minhas, sem bloqueados; `likes.inFilter` marca as minhas curtidas.
- [ ] `follows` insert devolve o `status` decidido pelo trigger (`pending` para privado); seguir duas vezes (`23505`) relê o estado; seguir quem me bloqueou (`42501`) vira "Não é possível seguir este perfil."
- [ ] `likes` upsert com `ignoreDuplicates` não gera segunda notificação; apagar a curtida apaga a notificação (trigger).
- [ ] `notifications`: update só de `read_at` passa pelo grant por coluna; `unreadCount` por `count(exact)` com `range(0,0)`.
- [ ] `checkins`: o app apaga o anterior e insere o novo (duas chamadas); `friends_checkins` devolve só de quem sigo + eu; `expires_at` até 12 h.
- [ ] RPC `list_blocked_users` com o JWT do app; bloquear some com follows, curtidas e notificações entre os dois (o teste SQL cobre; confirmar pelo app).
- [x] ~~O intent-filter de `/plateia/u/<username>` abre o app em `/profile/<username>`~~ → conferido no emulador (`adb shell am start -a android.intent.action.VIEW -d https://joao-jleite.github.io/plateia/u/foxer`); a rota precisou do prefixo `/plateia`. Falta só o `share_plus` abrir a folha nativa no celular (no emulador aparece o seletor do Android).
- [ ] Ao trocar de conta no mesmo aparelho (sair e entrar com outra), o sino e as listas vêm da conta nova (corrigido no `unreadCount`; confirmar os outros providers `keepAlive` no app real).

## Para as próximas fases (já dá para adiantar)

- [x] ~~**Supabase**: criar projeto~~ → movido para a fase 02, acima.
- [x] ~~**Google Cloud**: credencial OAuth para o login Google~~ → detalhado no passo 6 da fase 03, acima.
- [ ] **Conta Google Play Console** (US$ 25 uma vez) e **keystore de release** (guardar senha fora do git). Fase 08.
- [ ] **Antes de cobrar qualquer coisa ou colocar anúncio**: pedir licença comercial do TMDB (e-mail para `sales@themoviedb.org`, assunto "Commercial API Use", informando o país) e assinar o Starter da Streaming Availability (US$ 49/mês). Fase 08.
- [ ] **Decidir preço** do plano premium (se houver). Fase 07/08.
