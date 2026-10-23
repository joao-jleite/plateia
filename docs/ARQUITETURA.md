# Arquitetura · Plateia (codinome) · fase 02 (2026-10-22)

Decisões técnicas que todas as fases herdam. Produto e regras: `docs/SPEC.md`. APIs externas: `docs/decisoes-apis.md`. Banco: `supabase/migrations/`. Cada decisão também está na seção "Decisões" do `CLAUDE.md`.

## 1. Visão

```
┌──────────────────────── Android (Flutter) ────────────────────────┐
│ UI (Material 3, PT-BR) ── Riverpod (estado) ── go_router (rotas)  │
│ Repositórios → supabase_flutter (PostgREST + Auth + Storage)       │
│             → Edge Functions (fetch com o JWT do usuário)          │
│ Lógica pura: parser do CSV · matching local · "qual assinar"       │
└─────────────────────────────┬──────────────────────────────────────┘
                              │ https
┌─────────────────────────── Supabase (sa-east-1) ───────────────────┐
│ Auth (e-mail, Google)   Postgres 17 + RLS em toda tabela           │
│ Storage: bucket avatars  Edge Functions (Deno): proxy + cache      │
│   catalog-search · catalog-title · home-sections · import-match    │
│   providers-sync · account-delete                                  │
└───────────┬─────────────────────────────┬──────────────────────────┘
            │ TMDB (catálogo, pt-BR,      │ Streaming Availability
            │ watch/providers BR)         │ (link que abre o app, cache 7 d)
```

Regras fixas: chave de API só nos secrets das Edge Functions; o app fala com o banco **sempre** como o usuário (RLS decide); `service_role` só dentro das funções; nada de vídeo, nada de scraping.

## 2. Identidade do app

| Item | Valor | Porquê |
|---|---|---|
| `applicationId` (Android) | **`io.github.joaojleite.watchlog`** | Imutável na Play Store, então não leva o codinome "Plateia". `io.github.<usuário>` é o padrão para quem não tem domínio (GitHub do João: `joao-jleite`, hífen não vale em pacote Java). `watchlog` descreve a função e sobrevive a qualquer nome de produto. |
| `name` no `pubspec.yaml` | `watchlog` | Mesmo radical; identificador Dart válido. |
| Nome visível (`android:label`) | Plateia | Só um rótulo; muda sem consequência. |
| Scheme de deep link (OAuth, reset de senha) | `io.github.joaojleite.watchlog://login-callback` | Mesmo prefixo do pacote; configurado em `supabase/config.toml` (`additional_redirect_urls`) e no dashboard do Supabase. |
| `minSdk` / `targetSdk` | 24 / o mais novo do SDK instalado | Android 7+ cobre praticamente toda a base ativa e simplifica App Links e notificações locais. |
| Links de convite | `https://joao-jleite.github.io/...` (depois) | Sem domínio próprio, App Links verificados ficam para quando houver; no MVP o link abre o site estático e o app por scheme. |

## 3. Stack e versões

Flutter 3.44.8 · Dart 3.12.2 (os da máquina). Versões fixadas na fase 03 (`pubspec.yaml`): supabase_flutter 2.18, flutter_riverpod 3.4 + riverpod_annotation 4.0 / riverpod_generator 4.0, go_router 18, freezed 4.0.0-dev.3 (única compatível com o analyzer do Dart 3.12) + freezed_annotation 3.1, json_serializable 6.15, google_sign_in 7.2, url_launcher 6.3, android_intent_plus 6.1, cached_network_image 4.0, intl 0.20, http 1.6, mocktail 1.0. Os arquivos gerados (`*.g.dart`, `*.freezed.dart`) ficam no git; `build.yaml` põe `field_rename: snake` em todo `fromJson`. Como rodar: `docs/DEV.md`.

| Papel | Pacote | Nota |
|---|---|---|
| Backend | `supabase_flutter` | Auth, PostgREST, Storage, `functions.invoke` |
| Estado | `flutter_riverpod`, `riverpod_annotation` + `riverpod_generator` | ver §5 |
| Navegação | `go_router` | ver §6 |
| Modelos | `freezed` + `json_serializable` | imutáveis, `fromJson` das linhas do PostgREST |
| Login Google | `google_sign_in` → `auth.signInWithIdToken` | fluxo nativo; exige client ID Web + Android no Google Cloud (João) |
| Abrir app externo | `url_launcher` (modo externo), `android_intent_plus` (pacote do Disney+) | `<queries>` no manifesto para os 8 pacotes (Android 11+) |
| Imagens | `cached_network_image` | pôsteres do TMDB (`image.tmdb.org/t/p/w342`) |
| CSV | `file_picker`, `csv`, `compute` (isolate) | parser puro em `domain/` |
| Avatar | `image_picker` + redimensionar antes de subir | bucket `avatars/<uid>/avatar.jpg` |
| Lembrete | `flutter_local_notifications` | fase 07 |
| Formatação | `intl` (`pt_BR`) | datas e moeda |
| Testes | `flutter_test`, `mocktail` | widget e unitário |

Não usar: Firebase, Hive/Isar (sem offline-first no MVP), Realtime do Supabase, GetX.

## 4. Estrutura de pastas

Feature-first. Cada feature tem `data/` (repositório que fala com o Supabase e converte linha → modelo), `domain/` (modelos `freezed` e lógica pura, sem Flutter) e `presentation/` (telas, widgets, providers).

```
lib/
  main.dart                 Supabase.initialize + ProviderScope + runApp
  app.dart                  MaterialApp.router, tema, locale pt_BR
  core/
    config/                 env (SUPABASE_URL/ANON_KEY via --dart-define), constantes, URLs do TMDB
    supabase/               supabaseProvider, authStateProvider, functionsClient (invoke + erro padrão)
    router/                 app_router.dart (go_router), redirect (logado? onboarded?)
    theme/                  cores, tipografia (fase 08 refina)
    widgets/                AsyncView (carregando/vazio/erro), PosterTile, RatingStars, SpoilerBlur
    utils/                  datas pt-BR, moeda, slugs, imagens do TMDB
  dev/fixtures/             backend de amostra (BACKEND=fixtures): auth/perfil/catálogo em memória, 10 títulos; recusado em release
  features/
    auth/                   login, cadastro, Google, reset
    catalog/                domain: modelos do catálogo (Title, Availability, StreamingProvider…) · data: CatalogRepository (Edge Functions) · providers Riverpod usados por home/search/title
    onboarding/             username, importar, seguir
    home/                   seções do Início (home_sections)
    search/                 títulos (catalog-search) e pessoas (profiles)
    title/                  detalhe (catalog-title), onde assistir, abrir app do streaming
    diary/                  folha Registrar, EntriesRepository, otimista + rollback
    lists/
    profile/                perfil, abas, estatísticas, configurações de perfil
    import_netflix/         domain: parser + agrupador (puro) · data: import-match · review screen
    social/                 feed, follows, likes, comments, blocks, reports, checkins
    notifications/
    subscribe/              domain: recomendador puro · telas Assinar e Meus streamings
    settings/               privacidade, bloqueados, apagar conta, sobre/atribuições
test/                       espelha lib/ (unitário em domain/, widget em presentation/)
supabase/
  config.toml               Postgres 17, redirect URLs, auth
  migrations/               0001_init.sql, 0002_storage_avatars.sql, …
  functions/_shared/        tmdb.ts, motn.ts, supabase.ts (clientes), http.ts (erro padrão, CORS)
  functions/<nome>/index.ts
tools/db/                   Postgres local + stub do Supabase + testes de RLS (§13)
docs/  prompts/  research/
```

Regras: `domain/` não importa Flutter nem Supabase (é o que se testa unitariamente). Nome de arquivo em snake_case; classe em PascalCase; strings da interface em PT-BR, concentradas por feature num `strings.dart` (sem i18n formal no MVP).

## 5. Gerência de estado: Riverpod 3 (com codegen)

Por quê, em três linhas: (1) injeção de dependência sem `BuildContext`, verificada em compilação, o que deixa repositório, notifier e widget testáveis isoladamente com `ProviderContainer`; (2) `AsyncNotifier`/`AsyncValue` mapeiam 1:1 as chamadas ao Supabase e entregam de graça os três estados que a convenção exige (carregando/erro/dado); (3) é o padrão dominante da comunidade Flutter em 2026, com codegen (`@riverpod`) que elimina boilerplate para um dev solo. Rejeitados: Bloc (cerimônia demais para CRUD), Provider (sem primitivas async; legado), GetX (estado global implícito).

Padrões:
- `Repository` (data) → `AsyncNotifier` (presentation) → widget com `ref.watch(...)`. Um notifier por tela ou por agregado (ex.: `entryForTitleProvider(titleId)`).
- **Otimista com desfazer:** o notifier atualiza o estado local, chama o repositório e, em erro, restaura e emite um `SnackBar` ("não deu para salvar"). Nunca esperar o servidor para refletir um toque.
- Família de providers com `keepAlive` só para cache de catálogo (`titleProvider(type, id)`); o resto `autoDispose`.
- Sessão: `authStateProvider` (stream do Supabase) alimenta o `redirect` do router.

## 6. Navegação: go_router

Por quê: declarativa e oficial; `StatefulShellRoute` mantém o estado de cada aba da barra inferior; `redirect` central resolve "não logado → login" e "logado sem onboarding → onboarding"; rotas tipadas por caminho dão deep link de graça (`/u/:username`, `/title/tv/1399`, callback do OAuth). Rejeitados: `auto_route` (codegen pesado e acoplado), Navigator 1.0 (sem deep link nem estado por aba).

Rotas: as da tabela em `docs/SPEC.md` §4. Abas: Início, Buscar, Feed, Assinar, Perfil. Detalhe de título e perfil abrem **por cima** da aba atual (sub-rota da shell), para o botão voltar manter o contexto.

## 7. Modelos

- Uma classe `freezed` por tabela consultada (`Profile`, `Title`, `Entry`, `ListModel`, `Activity`, `Provider`, …) com `fromJson` em snake_case (`@JsonKey(name: 'poster_path')` ou `fieldRename: FieldRename.snake`).
- Enums de domínio em Dart (`EntryStatus.watched`) convertidos para o `text` do banco por `@JsonValue`.
- Joins do PostgREST (`select('*, title:titles(*)')`) viram campos aninhados opcionais.
- Nada de `Map<String, dynamic>` atravessando camadas: o repositório converte na borda.

## 8. Dados: como o app fala com o Supabase

- **Leitura e escrita de dado do usuário:** direto via PostgREST com o JWT da sessão. A RLS é a regra; o app não re-implementa permissão, só esconde botões.
- **Catálogo e cache:** só leitura direta (`titles`, `title_availability`, `providers`, `home_sections`). Escrever nessas tabelas é papel das Edge Functions.
- **Edge Functions:** `supabase.functions.invoke('nome', body: {...})` manda o JWT automaticamente. Resposta de erro sempre `{ "error": { "code": "...", "message": "pt-BR" } }` (§9).
- **Storage:** upload do avatar em `avatars/<uid>/avatar.jpg` (upsert); a URL pública vai para `profiles.avatar_url` com `?v=<timestamp>` para furar cache.
- **Sem offline-first:** sem rede, telas mostram estado de erro com "tentar de novo". Cache de imagens é o único cache local.
- **Paginação:** `range()` de 30 em 30 em feed e listas (diário do perfil: 60, com "Mostrar mais"); cursor por `created_at` quando a lista cresce (fase 06).
- **Estatísticas do perfil (fase 04):** view `entry_stats_rows` (migração 0003, `security_invoker`) entrega uma linha magra por entrada; o app pagina de 500 em 500 e agrega em `computeProfileStats` (função pura). RPC `profile_stats` só se o p95 real passar de 1 s.

## 9. Edge Functions (Deno) · contratos

Comuns a todas: `POST` com JSON; exigem `Authorization: Bearer <jwt do usuário>` (a função chama `auth.getUser()` e recusa com `401 unauthorized` se inválido); escrevem com um cliente `service_role`; nunca devolvem chave; CORS liberado só para o app (sem origem web no MVP). Erros: `400 bad_request`, `401 unauthorized`, `404 not_found`, `429 quota_exceeded`, `502 upstream`, `500 internal`. Secrets (`supabase secrets set`, João): `TMDB_API_KEY` (token v4 de leitura), `RAPIDAPI_KEY`. `SUPABASE_URL`, `SUPABASE_ANON_KEY` e `SUPABASE_SERVICE_ROLE_KEY` já existem no ambiente.

| Função | Entrada | Saída | Escreve | Chama fora |
|---|---|---|---|---|
| `catalog-search` | `{ q: string, page?: number }` | `{ results: [{ tmdb_id, media_type, title, year, poster_path, is_anime }], page, total_pages }` | nada | TMDB `/search/multi` (`language=pt-BR&region=BR`), filtra `person` |
| `catalog-title` | `{ tmdb_id, media_type, force?: boolean, links?: boolean }` | `{ title: Title, availability: [Availability & { provider: Provider }], sync: TitleSync }` | `titles`, `title_availability`, `title_sync`, `providers` (lazy) | TMDB `/{type}/{id}?append_to_response=credits,external_ids,watch/providers` se detalhe > 30 d ou providers > 7 d; MOTN `/shows/{type}/{tmdb_id}?country=br` se links > 7 d e cota ok |
| `home-sections` | `{}` | `{ sections: [{ key, title, items: [...] }], fetched_at }` | `home_sections` | TMDB `/trending/all/day` + `/discover/{movie,tv}` por streaming destacado, se > 6 h (17 chamadas por renovação) |
| `import-match` | `{ items: [{ raw_name, guessed_type?: 'movie'\|'tv'\|null, year?, alt_query? }] }` (≤ 100 por chamada; `guessed_type` null = incerto, `alt_query` = título completo para tentar se o nome não achar) | `{ matches: [{ raw_name, confidence: 'high'\|'medium'\|'low', best: Candidate\|null, candidates: Candidate[] }], upstream_calls }` com `Candidate = { title_id, tmdb_id, media_type, title, year, poster_path, score }` (até 3; `best` null em `low`) | `titles` (linhas-esboço dos candidatos, `fetched_at = '1970-01-01'` para renovar ao abrir; nunca rebaixa um título já completo) | TMDB `/search/{tv,movie}` (tipo conhecido) ou `/search/multi` (incerto), pt-BR, concorrência 5; sem resultado e com ":" no nome, tenta sem o subtítulo; falha do TMDB num item vira `low` sem derrubar o lote |
| `providers-sync` | `{}` | `{ upserted: number }` | `providers` (nome, logo, `display_order` dos não destacados) | TMDB `/watch/providers/{movie,tv}?watch_region=BR` |
| `account-delete` | `{}` | `{ ok: true }` | apaga `auth.users` do próprio chamador (cascade) e os objetos em `avatars/<uid>/` | nada |

Pontuação do `import-match` (fase 05, `supabase/functions/import-match/handler.ts`, espelhada em Dart para as fixtures em `features/import_netflix/domain/matching_score.dart`): nome normalizado (minúsculas, sem acento e pontuação, `&` → "e") igual ao `name`/`title` ou ao original → +0,6; um contém o outro (parcial) → +0,3; tipo bate com o palpite (padrão de temporada ⇒ `tv`) → +0,2; ano bate (quando houver; o CSV simples não traz) → +0,1; **único casamento exato** com popularidade ≥ 1 → +0,1 (um homônimo exato relevante anula o bônus e o caso vai para a revisão). `high` ≥ 0,9 e sem segundo candidato ≥ 0,8; `medium` 0,6–0,9; `low` < 0,6 (ou sem candidato). `medium` e `low` vão para `import_candidates`. Sem ano, `high` só sai de exato + tipo + único exato (0,9): é o caminho normal de uma série bem nomeada; tipo incerto nunca passa de 0,7.

Lado do app (fase 05, `features/import_netflix/`): `domain/netflix_csv.dart` (tokenizador RFC 4180, BOM/latin-1, `Title,Date` ou `ViewingActivity.csv`, ordem da data decidida pelo arquivo), `title_patterns.dart` (Temporada/Parte/Volume/Minissérie/Episódio N/arco nomeado), `grouper.dart` (uma linha por série ou filme: `rawName`, `guessedType`, episódios distintos, última reprodução, `altQuery`), `merge.dart` (regra de não sobrescrever a edição manual; produz inserts `on conflict do nothing` + patches de `watched_at`/`episodes_watched`), `import_pipeline.dart` (pontos de entrada do `compute`: `prepareCsv` = decodificar + sha-256 + interpretar; `groupPrepared`). `data/import_repository.dart` fala com a função e com `imports`/`import_candidates`/`entries` pelo PostgREST; `presentation/import_providers.dart` tem o `ImportController` (ler → agrupar → casar em lotes de `matchBatchSize` → merge → candidatos → resumo) e a fila de revisão otimista (`PendingReview`). Editar à mão grava `source = 'manual'` (decisão da fase 05).

**Estrutura (fase 03):** cada função é `handler.ts` + `index.ts`. O handler recebe as dependências por parâmetro (`requireUser`, `db: CatalogDb`, `tmdb(counter)`, `motn(counter)`, `now`) e é o que os testes exercitam com fakes (`supabase/functions/tests/`); o `index.ts` só liga `Deno.serve` às implementações reais de `_shared/` (`supabase.ts` = clientes + `SupabaseCatalogDb`; `tmdb.ts`/`motn.ts` = clientes HTTP e conversões puras; `ttl.ts` = regras de cache; `http.ts` = envelope e erro padrão; `log.ts` = a linha `{fn, user, ms, upstream_calls}`). Provider desconhecido que apareça no `watch/providers` entra "lazy" em `providers` só com nome e logo do TMDB.

**Deploy sem Docker** (a máquina não tem Docker): `supabase functions deploy <nome> --use-api` empacota pela Management API. `functions serve` não funciona aqui; o teste de integração é no projeto de dev, lendo os logs no dashboard. O Deno está instalado (`npm i -g deno`): em `supabase/functions/`, `deno task check` tipa as 5 funções (resolve `npm:@supabase/supabase-js@2` pela rede) e `deno task test` roda os testes unitários dos handlers (cache quente = `upstream_calls: 0`, cota, force < 24 h, casamento de links, HBO Max, home 6 h, providers-sync, account-delete).

## 10. Cache e cota

| Dado | Onde | TTL | Renova |
|---|---|---|---|
| Detalhe do título | `titles.fetched_at` | 30 dias | `catalog-title` ao abrir |
| Onde está (TMDB) | `title_sync.providers_fetched_at` | 7 dias | `catalog-title` ao abrir (mesma chamada do detalhe) |
| Link que abre o app (MOTN) | `title_sync.links_fetched_at` | 7 dias | `catalog-title`, só se `consume_api_quota('motn', 900)` permitir |
| Início | `home_sections.fetched_at` | 6 h | `home-sections` |
| Lista de streamings | `providers.updated_at` | manual | `providers-sync` (João) ou lazy ao achar id desconhecido |

Fluxo de "onde assistir" ao abrir um título:
1. Cache quente (tudo dentro do TTL): zero chamada externa; resposta só do Postgres. É o caso do "Pronto quando" da fase 03.
2. Detalhe ou providers vencidos: 1 chamada TMDB (detalhe + providers juntos via `append_to_response`).
3. Links vencidos e cota ok: 1 chamada MOTN; grava `deep_link` por streaming casando `service.id` com `providers.motn_id`; `links_status = ok|not_found`.
4. Cota estourada (`consume_api_quota` devolve `false`): `links_status = quota`, `deep_link` fica como estava; a interface mostra "Buscar na X". No mês seguinte o contador zera sozinho (chave `period`).
5. Puxar para atualizar: `force = true` renova se a última atualização tiver mais de 24 h; antes disso é ignorado (evita gastar cota com toques repetidos).

Tetos em `api_usage` (função `consume_api_quota(api, cap)`, atômica): `motn` 900/mês (grátis é 1.000); `tmdb` só medição (sem cota mensal; rate limit respeitado com ≤ 5 chamadas simultâneas por função). Ao virar comercial, subir o teto junto com o plano (`Starter` 25.000 → teto 22.000).

## 11. Feed: como é montado e quando muda

**Agora: fan-out na leitura.** A view `feed` (security_invoker) seleciona `activities` de quem eu sigo (aceito) e minhas, ordenadas por `created_at desc`, paginadas por `range`. A RLS de `activities` ainda filtra bloqueio e perfil privado. Custo por requisição: 1 índice em `follows(follower_id)` + 1 índice em `activities(user_id, created_at desc)` por seguido, mesclados. Para o alvo do MVP (até ~10 mil usuários, cada um seguindo ≤ 500) isso responde em dezenas de milissegundos.

Dedup e rajada: o trigger de `entries` reaproveita o evento do mesmo tipo da mesma entrada na última hora; o cliente agrupa visualmente eventos consecutivos do mesmo autor no mesmo dia. `imported` é um evento só.

**Quando muda (gatilhos medidos, não data):**
- p95 da consulta do feed > 200 ms ou > ~10 mil usuários ativos/mês → **fan-out na escrita**: tabela `feed_items(user_id, activity_id, created_at)` preenchida por trigger em `activities` para cada seguidor (limite de seguidores por escrita; contas com > 5 mil seguidores continuam na leitura, modelo híbrido). A view `feed` passa a ler `feed_items`.
- > 100 mil usuários → cursor `(created_at, id)` em vez de `range`, retenção de 90 dias em `feed_items`, contadores desnormalizados já existem (`like_count`, `comment_count`).

Nada disso exige fila nem serviço fora do Supabase.

## 12. Privacidade e segurança (resumo do que está no banco)

- Quatro funções `security definer` decidem tudo: `is_blocked_between(a, b)`, `is_following(a, b)`, `can_view_profile(target)` (cartão: sim, salvo bloqueio) e `can_view_content(owner)` (conteúdo: dono, ou público, ou seguidor aceito; nunca com bloqueio). Toda policy social usa uma delas.
- Atividades e notificações só nascem por trigger; `activities`/`notifications` não têm policy de insert e os clientes perderam o `GRANT` de insert. Não há como forjar.
- `anon` não tem privilégio em nenhuma tabela (app só logado). Cache e referência (`titles`, `providers`, …) são somente leitura para `authenticated`. `api_usage` é invisível a clientes.
- Bloquear desfaz follows e limpa notificações nos dois sentidos (trigger). O bloqueado não lê `blocks`.
- O app nunca recebe `service_role`; o CSV da Netflix nunca sai do aparelho; segredos nunca vão para o git (`.gitignore` já cobre `.env`, keystore).
- Lint do Supabase: toda `security definer` com `set search_path = ''`; views com `security_invoker = true`. O `db:test` falha se isso regredir.

## 13. Testes

Pirâmide: **RLS em SQL** (tudo que é permissão) → **unitário em Dart** (`domain/`: parser do CSV, agrupador, pontuação do matching no cliente, recomendador) → **widget** (telas principais com repositórios falsos) → **manual no emulador/celular** ("Pronto quando" de cada fase).

### 13.1 Banco local sem Docker: `npm run db:test`

A máquina não tem Docker, `psql` nem Deno, então `supabase start` não funciona. Em vez disso, `tools/db/db-test.mjs` usa o pacote npm `embedded-postgres` (binários reais do **PostgreSQL 17.10**, a mesma major do projeto, `major_version = 17` em `supabase/config.toml`) e, a cada execução:

1. cria um cluster novo em `tools/db/.pgdata` (apagado no fim);
2. aplica `tools/db/supabase_stub.sql`: roles `anon`/`authenticated`/`service_role`, schema `auth` (`auth.users`, `auth.uid()`, `auth.jwt()`, `auth.role()` com a mesma implementação do Supabase), schema `storage` (`buckets`, `objects`, `foldername()`), `extensions` e os privilégios padrão do Supabase;
3. aplica `supabase/migrations/*.sql` em ordem, **cada arquivo numa transação** (igual ao `supabase db push`); erro mostra `arquivo:linha:coluna`;
4. checa o schema: RLS ligado em toda tabela de `public`; toda tabela com ≥ 1 policy (ou `[no-client-access]` no `comment`); `anon` sem SELECT em nada; toda `security definer` com `search_path`; toda view com `security_invoker`;
5. roda `tools/db/tests/*.sql`, cada arquivo em `BEGIN … ROLLBACK`.

```bash
npm run db:test
```

`npm run db:test -- --keep` deixa o banco de pé (`postgres://postgres:postgres@localhost:54329/postgres`) até apertar Enter, para inspecionar com qualquer cliente. Leva ~7 s. Node ≥ 20; a primeira execução baixa ~100 MB de binários para `tools/db/node_modules` (fora do git).

### 13.2 Como escrever um teste de RLS

Um arquivo por fase/feature em `tools/db/tests/00NN_<tema>.sql`, com um bloco `do $$ … $$` por cenário:

```sql
do $$
declare a uuid; b uuid;
begin
  a := tests.create_user('a@teste.local');      -- cria auth.users + profile (trigger)
  b := tests.create_user('b@teste.local');
  perform tests.login_as(a);                     -- vira o usuário: role authenticated + claims
  insert into public.entries (user_id, title_id, status) values (a, ..., 'watched');
  reset role;                                    -- volta a ser superusuário
  perform tests.login_as(b);
  assert (select count(*) from public.entries where user_id = a) = 1, 'B vê diário público de A';
  begin                                          -- erro esperado: subtransação
    update public.entries set rating = 1 where user_id = a;  -- 0 linhas: RLS esconde
    insert into public.entries (user_id, title_id, status) values (a, ..., 'want');
    raise exception 'deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;
end $$;
```

Regras: `assert` com mensagem; `reset role` antes de trocar de usuário; nunca depender de dado de outro bloco (a transação é desfeita, mas a ordem dos blocos no mesmo arquivo é sequencial); dado de catálogo (`titles`) é inserido como superusuário, simulando a Edge Function. O que a 0001 já cobre está em `tools/db/tests/0001_rls_smoke.sql` (4 cenários: cadastro/privacidade/bloqueio; feed/curtidas/comentários/cota/anon; listas/check-ins/assinaturas; virar público/validações).

Limites do stub: não há GoTrue, PostgREST nem API de Storage; o que se testa é o Postgres (policies, triggers, grants, funções), que é onde mora a regra. Se o Supabase mudar algo que o stub reproduz, ajuste o stub, nunca a migração.

### 13.3 Dart
- `test/features/title/domain/`: `resolveWatchAction` (texto e destino do botão), `groupAvailability` (um cartão por streaming, ordem, variantes), HBO Max. `test/features/onboarding/domain/`: regra do @. `test/core/router/`: `gateFrom` + `computeRedirect`.
- `test/features/import_netflix/domain/` (fase 05): parser (tokenizador, BOM/latin-1, `;`, datas D/M vs M/D vs ISO e ambíguas, `ViewingActivity.csv` com perfis e trailers), padrões de título (um caso por padrão), agrupador (fixture `test/fixtures/netflix/simple_br.csv`: 22 linhas → 12 grupos), merge (reimportar não muda nada; importado avança data/episódios; manual só preenche vazio; status manual intocado; dedupe), espelho da pontuação, `prepareCsv`. Widget: `presentation/` (importar o CSV de exemplo e reimportar sem duplicar entradas, candidatos nem evento; cancelar o aviso; formato inválido; dois perfis; onboarding com "Revisar depois"; servidor recusando) e a revisão (candidatos, resolver grava, "Nenhum destes"/"Pular", desfazer). Banco: `tools/db/tests/0004_import.sql` (só o dono lê; reimportar não duplica `entries` nem o evento `imported`; edição manual sobrevive; unique por nome; resolver/pular).
- `test/features/subscribe/domain/` (fase 07): recomendador com os casos fixos (lista vazia, empate, título em vários, em nenhum, preço desatualizado).
- `test/features/profile/domain/` (fase 04): `computeProfileStats`, `minutesFor`, `hoursLabel` (horas por filme/série, "assisti" sem progresso, por streaming/gênero/década, empates, sem duração). `test/features/diary/domain/`: `isValidRating`, `episodesWatchedFor`, `EntryDraft.normalized`, `optimisticEntry`, `Entry.fromJson` com título embutido.
- Widget: `test/helpers/pump_app.dart` sobe a tela com `fixtureOverrides()` (repositórios de amostra sem latência), imagens de rede desligadas (`imagesEnabledProvider`), launcher falso (`streamingLauncherProvider`) e `retry: null` no `ProviderScope` (erro proposital não pode deixar timer pendente). Telas cobertas na fase 03: login, username + "Agora não", Início (dado/erro/retry), Busca (debounce, vazio, acento), Detalhe (ordem, botão por caso, vazio, erro, cache do repositório). Fase 04 (`diary: FixtureDiaryStore(seed: false)` e `failWrites: true` no helper): folha Registrar (2 toques, desmarcar, nota implica Assisti, review com spoiler borrada no detalhe, T/E → episódios, servidor recusa → desfaz com SnackBar, reassistir), perfil (cartão, contadores, grade com nota/progresso/reassistido, abas, lista ranqueada, reviews borradas, perfil público × privado × inexistente, estatísticas, diário vazio).
- Fase 04, banco: `tools/db/tests/0002_diary.sql` (posse do diário, privacidade de diário/listas/view, lista privada nem para seguidor, nota 4,3 / nota e review em "quero ver" / limites, reassistir, `entry_stats_rows` com 2 mil entradas < 1 s).

## 14. Migrações e ambientes

- Local: `npm run db:test` **antes de qualquer push**.
- Dev (quando o João criar o projeto em `sa-east-1`): `supabase link --project-ref <ref>` uma vez; `supabase db push` aplica o que falta e registra em `supabase_migrations.schema_migrations`. Se a `0002_storage_avatars.sql` falhar por permissão em `storage.objects`, rodar o arquivo no SQL Editor e `supabase migration repair --status applied 0002`.
- Produção: o projeto de dev vira produção no lançamento (dev solo, um projeto); um segundo projeto só se houver dado de usuário real a proteger (fase 08 decide).
- Nunca editar migração aplicada; criar `000N_<tema>.sql`. "Enums" são `text + check` para evoluir com `alter table … drop constraint / add constraint`.
- Seeds de referência (`providers`, `provider_prices`) moram na migração; correções por nova migração ou pelo dashboard (preços).
- Config do Auth (redirect URLs, Google) no dashboard e espelhada em `supabase/config.toml`; `supabase config push` sincroniza quando o CLI suportar o campo.

## 15. Observabilidade mínima
- Logs das Edge Functions no dashboard; cada função loga `{fn, user, ms, upstream_calls}` em uma linha.
- `api_usage` responde "quanto da cota já foi" (consulta no dashboard).
- Crash do app: só na fase 08, se houver opção gratuita e leve; caso contrário, `FlutterError.onError` → log local.

## 16. O que foi considerado e descartado
- Bloc / Provider / GetX (§5); auto_route (§6).
- Enum do Postgres (não remove valor; `alter type … add value` fora de transação).
- Diário com várias linhas por título (complica importação idempotente e estatísticas; fica para depois com `watch_logs`).
- Esconder o cartão do perfil privado (impede pedir para seguir; Letterboxd/Instagram também mostram).
- Fan-out na escrita desde o início (custo sem benefício até ~10 mil usuários).
- Firebase (duplicaria auth/push; Supabase resolve), Realtime (feed por puxar basta), offline-first (sem valor para catálogo que muda e com RLS no servidor).
- Guardar o CSV da Netflix "para reprocessar" (dado pessoal; só hash e resumo).
