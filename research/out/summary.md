# Resumo da fase 01 (gerado por 06_compare.py)

Amostra: 20 títulos · 15 com streaming esperado.

| Fonte | Cobre BR | % amostra com streaming certo | Deep link | Chamadas gastas | Plano grátis | Plano comercial | Termos |
|---|---|---|---|---|---|---|---|
| TMDB watch/providers | bloqueado (sem chave) | — | — | — | sem cota mensal; rate limit ~50 req/s; grátis só não comercial, com atribuição | licença comercial sob consulta (sales@themoviedb.org); terceiros citam ~US$ 149/mês | atribuir TMDB e JustWatch; `link` leva à página do TMDB, não ao streaming |
| Watchmode | bloqueado (sem chave) | — | — | — | 2.500 créditos/mês, até 3 países, não comercial, SEM deep link de app | Startup US$ 349/mês (40k) · Business US$ 599/mês (100k) | cache máx. 30 dias no grátis; não revender; atribuição conforme plano |
| Streaming Availability (MOTN) | bloqueado (sem chave) | — | — | — | 1.000 req/mês, uso comercial permitido, deep link incluso | Starter US$ 49/mês (25k) · Growth US$ 99 (100k) · Scale US$ 299 (1M) | atribuição se os dados forem públicos; cache livre; sem Globoplay |

## Links que abrem o app (assetlinks) — 8/8 streamings

| Streaming | Pacote Android | Busca (plano B) | Status busca | Status título |
|---|---|---|---|---|
| netflix | com.netflix.NGP.Pandora, com.netflix.bheem, com.netflix.kids, com.netflix.mediaclient, com.netflix.ninja, com.netflix.robin, com.netflix.starfire | https://www.netflix.com/search?q={q} | 200 | 0 |
| max | com.hbo.hbonow, com.wbd.hbomax, com.wbd.stream | https://play.hbomax.com/search?q={q} | 200 | 200 |
| disney | com.disney.disneyplus | — | — | None |
| prime | com.amazon.amazonvideo.livingroom, com.amazon.avod, com.amazon.avod.thirdpartyclient, com.amazon.avod.thirdpartyclient.xiaomi, com.amazon.pvandroidauto | https://www.primevideo.com/search?phrase={q} | 200 | 200 |
| globoplay | com.globo.globotv | https://globoplay.globo.com/busca/?q={q} | 200 | None |
| apple | com.apple.atve.amazon.appletv, com.apple.atve.androidtv.appletv, com.apple.atve.sony.appletv | https://tv.apple.com/br/search?term={q} | 200 | 200 |
| paramount | com.cbs.app, com.cbs.ca, com.cbs.ott | https://www.paramountplus.com/br/search/?q={q} | 406 | 406 |
| crunchyroll | com.crunchyroll.crunchyroid, com.crunchyroll.manga | https://www.crunchyroll.com/pt-br/search?q={q} | 200 | 200 |

## Por título (assinatura em BR)

| Título | Esperado | TMDB | Watchmode | MOTN |
|---|---|---|---|---|
| Stranger Things | netflix | — | — | — |
| Round 6 | netflix | — | — | — |
| Wandinha | netflix | — | — | — |
| Sintonia | netflix | — | — | — |
| The Last of Us | max | — | — | — |
| A Casa do Dragão | max | — | — | — |
| The Bear | disney | — | — | — |
| Andor | disney | — | — | — |
| The Boys | prime | — | — | — |
| Invencível | prime | — | — | — |
| Arcanjo Renegado | globoplay | — | — | — |
| One Piece | crunchyroll, netflix | — | — | — |
| Frieren | crunchyroll | — | — | — |
| Ainda Estou Aqui | — | — | — | — |
| Cidade de Deus | — | — | — | — |
| Divertida Mente 2 | — | — | — | — |
| Duna: Parte Dois | — | — | — | — |
| Oppenheimer | — | — | — | — |
| Ruptura | apple | — | — | — |
| Yellowstone | paramount | — | — | — |

## CSV da Netflix

- Status: a confirmar com o CSV real
- Cabeçalho: ['Title', 'Date'] · encoding: UTF-8 (frequentemente com BOM)
- Datas: depende do locale da conta: contas BR costumam vir D/M/YY (ex.: 15/07/24); contas US vêm M/D/YY. Tratar como ambíguo e inferir pelo conjunto (algum primeiro campo >12 decide dia-primeiro).
