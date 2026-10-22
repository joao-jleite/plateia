# Fase 01 · Decisão: de onde vem "onde assistir no Brasil" e o link que abre o app

Data: 2026-10-22 · Status: **concluída com pendências** (as três chaves de API não existiam em `research/.env`; os números por título da amostra ficam pendentes e estão marcados com ⏳).

## Resposta curta

| Pergunta | Resposta |
|---|---|
| Qual fonte usar | **TMDB `watch/providers` (região BR)** para dizer *em quais streamings* o título está. **Streaming Availability (Movie of the Night)** para o *link que abre o app* de cada streaming. |
| Plano B | Streaming Availability sozinha para as duas coisas, aceitando que ela **não cobre Globoplay**; para Globoplay, link de busca. Watchmode descartada. |
| Quanto custa ao virar comercial | Licença comercial do TMDB (sob consulta; terceiros citam ~US$ 149/mês) + Streaming Availability Starter US$ 49/mês (25 mil req). Ordem de grandeza: **~US$ 200/mês**. Até lá: US$ 0. |
| Sem link direto | Abrir a **URL de busca do streaming no domínio verificado por assetlinks** (o Android abre o app, não o navegador). Disney+ não tem URL de busca: abrir o app pelo pacote `com.disney.disneyplus` (ou a Play Store se não estiver instalado). |

## Tabela fonte × critério

Testado em 22/10/2026 com `research/*.py` (ver `research/out/`). "⏳" = depende da chave que só o João cria.

| Fonte | Cobre BR | % da amostra com streaming certo | Tem deep link | Cota grátis | Plano comercial | Termos que importam |
|---|---|---|---|---|---|---|
| **TMDB watch/providers** | Sim (dados da JustWatch; inclui Globoplay, Telecine, Claro etc.) | ⏳ (esperado alto: os 5 títulos conferidos na JustWatch BR batem com a amostra) | **Não.** O campo `link` é a página `themoviedb.org/.../watch?locale=BR`, que redireciona para a JustWatch. A doc diz que a API "não vai devolver deep links". | Sem cota mensal; rate limit ~50 req/s. Só **não comercial**. | Sob consulta (`sales@themoviedb.org`, assunto "Commercial API Use"); sem tabela pública. | Atribuir **TMDB** (logo + frase "This product uses the TMDB API but is not endorsed or certified by TMDB") **e JustWatch** como fonte dos provedores; descumprir revoga a chave. |
| **Watchmode** | Sim (Brasil na lista do site; `/v1/regions` exige chave: ⏳ confirmar `plan_enabled` no grátis) | ⏳ | Só nos planos pagos. A tabela de preços marca "App and episode deep links" como **não incluído no Developer**; no grátis os campos de link vêm com "available for paid plans only". | 2.500 créditos/mês, **até 3 países**, não comercial, atribuição obrigatória. | Startup **US$ 349/mês** (40 mil créditos) · Business US$ 599/mês (100 mil). | Cache máx. 30 dias no grátis; proibido revender/compartilhar; lookup por id do TMDB custa +1 crédito. |
| **Streaming Availability (MOTN, via RapidAPI)** | Sim: `br` com **11 serviços** (Netflix, Prime Video, Disney+, HBO Max, Apple TV, Paramount+, Mubi, Curiosity, Pluto TV, Crunchyroll, Zee5). **Sem Globoplay.** | ⏳ | **Sim.** `streamingOptions.br[].link` é "deep link para a página da opção no web app do serviço", sempre preenchido; `videoLink` quando há link do vídeo. | **1.000 req/mês, uso comercial permitido** (FAQ: "all subscription plans, including the free tier, allows commercial usage"). | Starter **US$ 49/mês** (25 mil) · Growth US$ 99 (100 mil) · Scale US$ 299 (1 milhão). Cota é limite duro, sem excedente. | Atribuição se os dados forem públicos; cache livre ("as long as you need"); dados atualizados diariamente. |

### Sem chave, o que foi testado de verdade
- Os três endpoints respondem **401** sem chave (`/v1/regions`, `/v1/sources`, TMDB, `/countries`). Nada é público; a Streaming Availability ainda devolve 429 no segundo request anônimo.
- Conferência manual na **JustWatch Brasil** (5 títulos, só leitura): Stranger Things → Netflix; The Last of Us → HBO Max (+ canal na Amazon; compra na Amazon Video); The Bear → Disney+; The Boys → Prime Video; Arcanjo Renegado → Globoplay. **5/5 iguais ao esperado da amostra.** Como o TMDB usa os dados da JustWatch, a expectativa é que o TMDB bata nesses 5.

## Links que abrem o app (assetlinks.json) — 8/8 streamings

`research/04_assetlinks.py` leu `/.well-known/assetlinks.json` de cada domínio. Pacote declarado = Android App Links verificado: o sistema abre o app em vez do navegador, **desde que o intent-filter do app cubra o caminho** (só dá para confirmar no celular; pendência do João).

| Streaming | Domínio que declara | Pacote Android (celular) | URL de busca (plano B) | Observação |
|---|---|---|---|---|
| Netflix | `www.netflix.com`, `netflix.com` | `com.netflix.mediaclient` | `https://www.netflix.com/search?q={q}` | No navegador a busca cai no login; no app abre a busca. `/title/{id}` é o link canônico. |
| HBO Max | `play.hbomax.com` (`play.max.com` redireciona 301) | `com.wbd.stream` (atual), `com.hbo.hbonow` | `https://play.hbomax.com/search?q={q}` | `www.hbomax.com`/`max.com` declaram `[]`: usar sempre `play.`. |
| Disney+ | `www.disneyplus.com` | `com.disney.disneyplus` | **nenhuma** (busca dá 404 real) | Link só por `entity-{id}`, que vem da Streaming Availability. Sem link: abrir o app pelo pacote. |
| Prime Video | `www.primevideo.com`, `app.primevideo.com` | `com.amazon.avod.thirdpartyclient` | `https://www.primevideo.com/search?phrase={q}` | `/detail/{asin}` é o link de título. |
| Globoplay | `globoplay.globo.com` | `com.globo.globotv` | `https://globoplay.globo.com/busca/?q={q}` | Nenhuma das três APIs dá o id do título no Globoplay (TMDB diz *que* está lá; link só pela busca). |
| Apple TV+ | `tv.apple.com` | `com.apple.atve.androidtv.appletv` (também Fire TV/Sony) | `https://tv.apple.com/br/search?term={q}` | `/br/show/{slug}/{umc.id}` é o link de título. |
| Paramount+ | `paramountplus.com` (o `www.` devolve 406 a robôs) | `com.cbs.app` | `https://www.paramountplus.com/br/search/?q={q}` | 406 é bloqueio de cliente não-navegador; a busca abre no navegador (conferido). |
| Crunchyroll | `www.crunchyroll.com`, `crunchyroll.com` | `com.crunchyroll.crunchyroid` | `https://www.crunchyroll.com/pt-br/search?q={q}` | `/pt-br/series/{id}/{slug}` é o link de título. |

## Por que esta combinação

1. **TMDB já é obrigatório** para catálogo, pôsteres e busca em PT-BR; usar o mesmo `watch/providers` para "onde está" é uma chamada a mais no mesmo cliente, sem segunda cota para gerenciar. É a única das três que cobre **Globoplay**, serviço que não pode faltar num app brasileiro (JustWatch confirma a cobertura).
2. **Streaming Availability** é a única com deep link no plano grátis e com **uso comercial permitido desde US$ 0**. Entra só para transformar "está na Netflix" em "abrir este título na Netflix" (campo `link`), e seus 1.000 req/mês duram porque o link de um título muda raramente: cache no Postgres com `fetched_at` de 7 dias.
3. **Watchmode perde nos dois eixos**: o deep link, que seria o motivo de usá-la, começa em US$ 349/mês, e o grátis é não comercial e limitado a 3 países.
4. Risco aceito: a Streaming Availability não cobre Globoplay, e o TMDB não dá link. Para Globoplay o app abre a busca no domínio verificado, que é o comportamento do plano B para qualquer streaming sem link.

### Fluxo no app (vai para a fase 02)
```
título → TMDB watch/providers (BR)  → lista de streamings (flatrate/ads/rent/buy) + atribuição JustWatch
       → Streaming Availability     → link por serviço (cache 7 dias)        [se faltar: busca no domínio]
       → url_launcher abre https://… → Android abre o app (assetlinks) ou o navegador se não instalado
       → Disney+ sem link: abrir pacote com.disney.disneyplus; sem app: Play Store
```
Tudo passa por Edge Function do Supabase (chave nunca no app) e cai na tabela de cache `title_availability` com `fetched_at`.

## O que acontece quando não há link direto
1. Monta a URL de busca do streaming (tabela acima) com o título em PT-BR e abre com `url_launcher` em modo externo. Nos 7 streamings com busca, o Android entrega ao app oficial (App Links verificados); sem o app, abre o site.
2. Disney+: tenta abrir o app pelo pacote (`android_intent_plus`, `com.disney.disneyplus`); se não estiver instalado, abre a Play Store do pacote.
3. Em último caso, botão "Ver na JustWatch" com o `link` do TMDB (que é o atalho que o próprio TMDB pede para usar e ainda cumpre a atribuição).
4. Na interface o botão muda de texto: "Abrir na Netflix" (link direto) vs. "Buscar na Netflix" (plano B), para não prometer o que não dá.

## Cota e custo

| Cenário | TMDB | Streaming Availability | Total |
|---|---|---|---|
| Pesquisa (esta fase) | ~40 chamadas, sem cota | ~21 req de 1.000 (2%) | US$ 0 |
| Beta fechado (até ~200 pessoas), sem cobrar | grátis não comercial | grátis: 1.000 req/mês ≈ 33 títulos novos/dia com cache de 7 dias | US$ 0 |
| Comercial (qualquer cobrança/anúncio) | licença comercial, sob consulta (~US$ 149/mês citado por terceiros, **a confirmar com o TMDB**) | Starter US$ 49/mês = 25 mil req ≈ 800 títulos/dia | **~US$ 200/mês** |

Regra do projeto: nenhum script ou função pode gastar mais de 20% da cota mensal; os scripts têm `BudgetGuard` (TMDB 100, Watchmode 120, MOTN 60).

## Formato do CSV da Netflix (⏳ a confirmar com o CSV real)

Fonte: documentação da Netflix e relatos públicos; `research/05_netflix_csv.py` analisa o arquivo real assim que ele existir em `research/NetflixViewingHistory.csv` e grava só um resumo anonimizado.

- **Download:** Conta → Perfis → *Atividade de visualização* → "Baixar tudo". Um CSV **por perfil**. A exportação completa (`netflix.com/account/getmyinfo`, até 30 dias) traz `ViewingActivity.csv` com `Profile Name, Start Time, Duration, Attributes, Title, Supplemental Video Type, Device Type, Bookmark, Latest Bookmark, Country`; o app vai aceitar os dois.
- **Arquivo simples:** `NetflixViewingHistory.csv`, UTF-8 (geralmente com BOM), vírgula, cabeçalho `Title,Date`, uma linha por reprodução (repetições aparecem de novo).
- **Data:** depende do locale da conta. Contas BR: `D/M/YY` (ex.: `15/07/24`); contas US: `M/D/YY`. O parser trata como ambíguo e decide dia-primeiro quando qualquer primeiro campo é > 12.
- **Padrões de título (PT-BR), anonimizados:**
  - `Stranger Things: Temporada 1: Capítulo Um: O Desaparecimento de Will Byers` → série: temporada numerada.
  - `La Casa de Papel: Parte 2: Episódio 1` → série dividida em partes.
  - `Título: Minissérie: Episódio 1` → minissérie.
  - `One Piece: East Blue: Eu sou Luffy! …` → anime com arco nomeado no lugar do número.
  - `Oppenheimer` → filme (sem `:` estrutural; títulos com `:` no nome exigem fallback de busca).
- **Estratégia de casamento:** extrair o nome da série (antes do primeiro `: Temporada|Parte|Minissérie|<arco>`), deduplicar por série, buscar no TMDB em `pt-BR`; filmes buscam o título inteiro e, se falhar, sem o subtítulo. Processar e descartar o CSV; guardar só os títulos casados (regra do CLAUDE.md).

## Bloqueado nesta fase (depende do João; passo a passo em `docs/PENDENCIAS-JOAO.md`)
- Números por título das três fontes (coluna "% da amostra" e "deep link" medidos): precisa das chaves em `research/.env`. Rodar `research\run_all.ps1` depois preenche `research/out/summary.md` sozinho.
- Confirmar no celular que os links de busca abrem o app (8 URLs na pendência).
- Formato real do CSV: colocar o arquivo em `research/NetflixViewingHistory.csv` e rodar o script 05.
- Confirmar `plan_enabled` do BR no plano grátis da Watchmode (só por curiosidade; a fonte foi descartada).
