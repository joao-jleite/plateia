# Plateia (codinome provisório)

App Android em Flutter que junta num lugar só o que a pessoa assiste em todos os streamings, com uma rede social em volta. Ele **não toca vídeo**: mostra onde cada título está no Brasil e abre o app oficial do streaming.

**Em uma frase:** o Letterboxd de filmes, séries e anime, em português, que sabe onde cada título passa no Brasil e diz qual streaming vale assinar este mês.

## Por que o produto é assim
- Netflix, Disney+, Max, Prime e Globoplay não têm API pública. Não dá para entrar na conta da pessoa, ler o histórico nem tocar vídeo. A "integração" possível tem três partes:
  1. um link que abre o app oficial;
  2. a importação do CSV de histórico que a própria Netflix deixa baixar;
  3. o registro manual.
- Referência: o Letterboxd passou de 30 milhões de membros (jul/2026) só com registro manual. O que segura a pessoa é registrar, dar nota, montar lista e ver o que os amigos assistem. A integração é um bônus.
- Diferenciais: séries, filmes e anime juntos; PT-BR; "onde assistir no Brasil" com botão para o app; "qual assinar este mês" a partir da lista da pessoa e dos amigos.

## Linhas que não se cruzam
- Nunca hospedar, transmitir, embutir ou linkar vídeo que não seja do streaming oficial. Nada de addon, torrent, IPTV ou extração de player.
- Nunca raspar site de streaming. A disponibilidade vem de uma API com termos claros (a fase 01 decide qual).
- Respeitar os termos das APIs: mostrar a atribuição exigida (TMDB/JustWatch etc.). Plano grátis costuma ser não comercial; antes de cobrar qualquer coisa, migrar para o plano comercial.
- Logos dos streamings só para indicar onde o título está, nunca sugerindo parceria.
- Chaves de API nunca vão no app nem no git. Ficam nos secrets das Edge Functions do Supabase, e o app chama a Edge Function.
- O CSV da Netflix é dado pessoal: processar e descartar. Guardar só o resultado (títulos casados).

## Stack
- Flutter (Android primeiro), Dart com null safety.
- Supabase: Auth (e-mail + Google), Postgres 17 com RLS em **toda** tabela, Edge Functions (Deno) como proxy e cache das APIs externas, Storage para avatar.
- Riverpod 3 (codegen) para estado, go_router para navegação, pastas feature-first, modelos `freezed`. Pacote Android `io.github.joaojleite.watchlog` (imutável; "Plateia" é só o rótulo). Tudo em `docs/ARQUITETURA.md`; produto e regras em `docs/SPEC.md`.
- Máquina sem Docker: banco validado em Postgres local com `npm run db:test` (`tools/db/`); Edge Functions sobem com `supabase functions deploy --use-api` e são checadas/testadas localmente com o Deno (`npm i -g deno`; `deno task check` e `deno task test` em `supabase/functions/`).
- Rodar o app: `docs/DEV.md`. Sem backend, `--dart-define=BACKEND=fixtures` (dados de amostra; nunca em release).

## Convenções
- Interface em PT-BR; código, tabelas e colunas em inglês.
- Comentar os trechos não óbvios.
- Toda chamada externa trata erro e tem estado vazio/erro/carregando na interface.
- Cache de disponibilidade no Postgres, com `fetched_at`; respeitar a cota da API.
- Migrações SQL em `supabase/migrations/`, numeradas. Nunca editar uma migração já aplicada: criar outra. "Enums" são `text + check`.
- `npm run db:test` precisa passar antes de qualquer `supabase db push`: aplica as migrações num Postgres 17 local, confere RLS/policy/grants e roda `tools/db/tests/*.sql`.
- Testes unitários para lógica (matching do CSV, recomendação) e testes de RLS em SQL (`tools/db/tests/`) para cada tabela com dado de usuário.
- `flutter analyze` limpo ao fim de cada fase.
- Ao fim de cada fase com app rodando, deixar o APK mais novo na Área de Trabalho (`C:\Users\joao-\Desktop`). Os antigos vão para `dist/`.
- Git local, um commit por entrega. Push só com ordem do João.

## O que só o João faz
Criar contas e chaves (TMDB, API de disponibilidade, Supabase, Google Cloud para o login Google), conta de desenvolvedor do Google Play, keystore de release, testar no celular e decidir preço. Claude nunca cria conta nem pede senha ou chave no chat. Chaves entram por `supabase secrets set` (o João roda) ou por `.env` local, que fica fora do git.

## Fases
| Fase | Prompt | Status |
|---|---|---|
| 01 Validar APIs | `prompts/01-validar-apis.md` | concluída com pendências (chaves e CSV: `docs/PENDENCIAS-JOAO.md`) |
| 02 Spec e arquitetura | `prompts/02-spec-e-arquitetura.md` | concluída (spec aprovada por procuração; projeto Supabase e confirmação do João: `docs/PENDENCIAS-JOAO.md`) |
| 03 Base e catálogo | `prompts/03-base-e-catalogo.md` | concluída sem o projeto Supabase (app, 5 Edge Functions e testes prontos; `db push`, deploy, secrets, OAuth e o fluxo real ficam para verificar: `docs/PENDENCIAS-JOAO.md`) |
| 04 Perfil e diário | `prompts/04-perfil-e-diario.md` | pendente |
| 05 Importar Netflix | `prompts/05-importar-netflix.md` | pendente |
| 06 Rede social | `prompts/06-rede-social.md` | pendente |
| 07 Qual assinar | `prompts/07-qual-assinar.md` | pendente |
| 08 Polimento e release | `prompts/08-polimento-e-release.md` | pendente |

Ao terminar uma fase: marcar o status aqui, registrar as decisões abaixo e listar o que ficou pendente.

## Decisões
<!-- formato: AAAA-MM-DD · decisão · porquê -->
- 2026-10-22 · "Onde assistir" vem do TMDB `watch/providers` (região BR) · única das três fontes que cobre Globoplay (dados da JustWatch), sem cota mensal e já obrigatória para catálogo; exige atribuição a TMDB e JustWatch. Detalhes em `docs/decisoes-apis.md`.
- 2026-10-22 · O link que abre o app vem da Streaming Availability (Movie of the Night, via RapidAPI), campo `link` por serviço, com cache de 7 dias no Postgres · única com deep link no plano grátis e com uso comercial permitido desde US$ 0 (1.000 req/mês; Starter US$ 49 por 25 mil). Não cobre Globoplay.
- 2026-10-22 · Watchmode descartada · deep link só a partir de US$ 349/mês; plano grátis não comercial e limitado a 3 países.
- 2026-10-22 · Sem link direto, o app abre a URL de busca do streaming no domínio que declara `assetlinks.json` (8/8 declaram pacote Android; o botão vira "Buscar na X") · App Links verificados abrem o app em vez do navegador. Disney+ não tem busca: abrir o pacote `com.disney.disneyplus` ou a Play Store. Último recurso: o `link` do TMDB (JustWatch).
- 2026-10-22 · Para HBO Max usar sempre `play.hbomax.com` · `max.com`/`www.hbomax.com` declaram `[]` no assetlinks e `play.max.com` redireciona.
- 2026-10-22 · Custo ao virar comercial: licença TMDB (sob consulta, ~US$ 149/mês citado por terceiros) + Streaming Availability Starter US$ 49/mês, ~US$ 200/mês · ambos antes de qualquer cobrança ou anúncio; até lá US$ 0.
- 2026-10-22 · Parser do CSV da Netflix por padrões `: Temporada N:`, `: Parte N:`, `: Minissérie:` e arco nomeado; data ambígua D/M vs M/D decidida pelo conjunto (campo > 12) · formato documentado publicamente, a confirmar com o CSV real (script `research/05_netflix_csv.py`).
- 2026-10-22 · Scripts de pesquisa com `BudgetGuard` por API (TMDB 100, Watchmode 120, MOTN 60) e sem retry em 4xx · regra de nunca gastar mais de 20% da cota mensal.
- 2026-10-22 · Fase 01 fechada sem as chaves (não existiam em `research/.env`) · tudo o que não depende delas foi testado de verdade; os números por título entram quando o João rodar `research/run_all.ps1`. O que só ele faz está em `docs/PENDENCIAS-JOAO.md`.
- 2026-10-22 · `docs/SPEC.md` aprovada por procuração (liberdade total dada pelo João em 22/10) · ele não acompanha o chat; os pontos que pedem a leitura dele estão marcados com ▶ na spec e em `docs/PENDENCIAS-JOAO.md`.
- 2026-10-22 · Pacote Android `io.github.joaojleite.watchlog`, nome Dart `watchlog`, rótulo "Plateia" · o id é imutável na Play, então não leva o codinome; `io.github.<usuário>` é o padrão para quem não tem domínio.
- 2026-10-22 · Estado com Riverpod 3 + `riverpod_generator` · DI sem BuildContext e checada em compilação, `AsyncValue` dá os três estados exigidos pela convenção, testável sem widget. Rejeitados Bloc (cerimônia), Provider (sem async), GetX (estado global implícito).
- 2026-10-22 · Navegação com go_router · `StatefulShellRoute` para as 5 abas, `redirect` central para login/onboarding, deep link por caminho (`/u/:username`, callback do OAuth). Rejeitado auto_route.
- 2026-10-22 · Pastas feature-first (`lib/features/<x>/{data,domain,presentation}` + `lib/core`), modelos `freezed` · `domain/` sem Flutter nem Supabase é o que se testa unitariamente.
- 2026-10-22 · Postgres local sem Docker: `embedded-postgres` (npm, PG 17.10) + stub do Supabase (`tools/db/supabase_stub.sql`) · a máquina não tem Docker, psql nem Deno; mesma major do projeto (`config.toml` 17); `npm run db:test` aplica as migrações como o `db push` (uma transação por arquivo), confere RLS e roda os testes SQL em ~7 s.
- 2026-10-22 · "Enums" como `text + check` · evoluem com `alter constraint` dentro de transação; enum do Postgres não remove valor.
- 2026-10-22 · Diário com uma linha por usuário×título (`entries`, unique); reassistir = `watch_count` · importação idempotente por upsert e estatísticas simples; diário por episódio fica para depois.
- 2026-10-22 · Perfil privado esconde o conteúdo, não o cartão; seguir privado vira pedido (trigger decide); virar público aceita pendentes · tem que dar para achar e pedir; Letterboxd e Instagram fazem igual.
- 2026-10-22 · Bloqueio simétrico no efeito via `is_blocked_between()` em toda policy social; bloqueado não lê `blocks`; lista de bloqueados por RPC · regra no banco, não na tela; o bloqueado não descobre.
- 2026-10-22 · Atividades e notificações nascem só por trigger (security definer); clientes sem `insert` · impossível forjar; o trigger escolhe review > nota > status e reaproveita o evento da última hora (rajada).
- 2026-10-22 · Feed por fan-out na leitura (view `feed` com `security_invoker`) · basta até ~10 mil usuários ativos ou p95 > 200 ms; depois `feed_items` por trigger (ARQUITETURA §11).
- 2026-10-22 · Curtidas e comentários pertencem à atividade; dono da atividade apaga comentário alheio · a atividade é a unidade social do feed.
- 2026-10-22 · `anon` sem privilégio; cache e referência somente leitura para `authenticated`; `api_usage` sem policy · app só logado; grants são a segunda camada além da RLS.
- 2026-10-22 · Cache: título 30 d, "onde está" 7 d, link 7 d, Início 6 h; teto da Streaming Availability 900/mês via `consume_api_quota()` · cota grátis é 1.000; estourou = plano B (busca) até virar o mês.
- 2026-10-22 · Edge Functions: `catalog-search`, `catalog-title`, `home-sections`, `import-match`, `providers-sync`, `account-delete`; deploy com `--use-api` · sem Docker/Deno local; `account-delete` porque a Play exige apagar conta.
- 2026-10-22 · Bucket `avatars` público (pasta = uid) em migração separada (`0002`) · isola um possível erro de permissão em `storage.objects` no `db push`.
- 2026-10-22 · Preços dos streamings seedados como estimativa (`provider_prices.is_estimate`) · a fase 07 precisa de dado; o João confere pelo dashboard e a tela mostra data e "estimativa".
- 2026-10-22 · Ids de providers do TMDB no seed (8, 119, 337, 1899, 307, 350, 531, 283) sem conferência com a chave · `providers-sync` (fase 03) confirma nomes e logos; id errado se corrige por nova migração.
- 2026-10-22 · Backend de fixtures (`lib/dev/fixtures`, ligado por `--dart-define=BACKEND=fixtures`) para emulador e testes de widget; recusado em release (`kReleaseMode`) · não havia projeto Supabase; o fluxo Busca → Detalhe → Onde assistir → botão precisava rodar de ponta a ponta mesmo assim.
- 2026-10-22 · APK da fase 03 (`plateia-fase03.apk`) é build **profile** com fixtures · release recusa fixtures e sem URL do Supabase não há como buildar contra o backend real; profile é AOT e roda no celular sem a faixa de debug.
- 2026-10-22 · Deno instalado por `npm i -g deno` (2.9.6), não pelo winget · não pede aceite de licença no terminal; `deno task check` e `deno task test` (20 testes) rodam em `supabase/functions/`.
- 2026-10-22 · Cada Edge Function é `handler.ts` (recebe `requireUser`, `db`, `tmdb`, `motn` por parâmetro) + `index.ts` (`Deno.serve` com as implementações reais de `_shared/`) · dá para testar cache, cota e casamento de links com fakes, sem Supabase nem rede; `_shared/supabase.ts` implementa a interface `CatalogDb`.
- 2026-10-22 · freezed `4.0.0-dev.3` · única versão compatível com o analyzer do Dart 3.12 (a 3.2.x para no analyzer 10); quando a 4.0 estável sair, subir.
- 2026-10-22 · Arquivos gerados (`*.g.dart`, `*.freezed.dart`) ficam no git · `flutter analyze` e `flutter test` funcionam logo após o clone, sem `build_runner`; ao mudar um modelo/provider, rodar `dart run build_runner build` e commitar junto.
- 2026-10-22 · "Novidades na X" = `discover` por streaming com lançamento (filme) ou episódio (série) nos últimos 90 dias, por popularidade, `vote_count ≥ 5` · o TMDB não sabe quando um título entrou no catálogo de um streaming; "popular entre os recentes" é o mais próximo de novidade.
- 2026-10-22 · Página "onde assistir" do TMDB calculada no cliente (`themoviedb.org/{type}/{id}/watch?locale=BR`) em vez de guardar o `link` da API · URL determinística; evita coluna nova para o último recurso "Ver na JustWatch".
- 2026-10-22 · Rota do detalhe (`/title/:type/:tmdbId`) é raiz, por cima da shell, em vez de sub-rota das 5 abas · uma rota só; voltar devolve à aba de origem; deep link funciona.
- 2026-10-22 · `SUPABASE_ANON_KEY` (dart-define) aceita a anon key legada ou a publishable key nova · o supabase_flutter 2.18 trata as duas como `publishableKey`.
- 2026-10-22 · Login Google exige `GOOGLE_WEB_CLIENT_ID` por dart-define (client **Web** do Google Cloud como `serverClientId`); sem ele o botão mostra erro claro em vez de quebrar · o app roda antes de o João configurar o Google Cloud.
- 2026-10-22 · Links do HBO Max normalizados para `play.hbomax.com` nas duas pontas (Edge Function ao gravar e app ao abrir) · defesa dupla contra a MOTN devolver `play.max.com`.
- 2026-10-22 · "Onde assistir" agrupa variantes pelo `parent_id` (Netflix com anúncios some dentro de Netflix) e a variante herda o `motn_id` do principal na função · um cartão por marca, como a SPEC pede.
- 2026-10-22 · `providers-sync` atualiza logo de todos, nome e ordem só dos não destacados, e devolve `featured[]`/`missing[]` · os 8 do seed têm nome e slug nossos; a resposta é a conferência dos ids (1899 = "Max" no TMDB, mantido "HBO Max" no app).
- 2026-10-22 · Atribuição ao TMDB como texto (badge "TMDB" + frase obrigatória) até o João baixar o logo oficial · Claude não baixa arquivo sem o João; pendência em `docs/PENDENCIAS-JOAO.md`.
- 2026-10-22 · Retry automático do Riverpod 3 desligado para `AppException` que não seja rede/upstream · 4xx das funções (cota, not_found) não se resolvem tentando de novo; rede e 5xx seguem o backoff padrão.
