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
- Supabase: Auth (e-mail + Google), Postgres com RLS em **toda** tabela, Edge Functions (Deno) como proxy e cache das APIs externas, Storage para avatar.
- Gerência de estado, navegação e estrutura de pastas: decididas na fase 02 e registradas em "Decisões".

## Convenções
- Interface em PT-BR; código, tabelas e colunas em inglês.
- Comentar os trechos não óbvios.
- Toda chamada externa trata erro e tem estado vazio/erro/carregando na interface.
- Cache de disponibilidade no Postgres, com `fetched_at`; respeitar a cota da API.
- Migrações SQL em `supabase/migrations/`, numeradas. Nunca editar uma migração já aplicada: criar outra.
- Testes unitários para lógica (matching do CSV, recomendação) e testes de RLS para cada tabela com dado de usuário.
- `flutter analyze` limpo ao fim de cada fase.
- Ao fim de cada fase com app rodando, deixar o APK mais novo na Área de Trabalho (`C:\Users\joao-\Desktop`). Os antigos vão para `dist/`.
- Git local, um commit por entrega. Push só com ordem do João.

## O que só o João faz
Criar contas e chaves (TMDB, API de disponibilidade, Supabase, Google Cloud para o login Google), conta de desenvolvedor do Google Play, keystore de release, testar no celular e decidir preço. Claude nunca cria conta nem pede senha ou chave no chat. Chaves entram por `supabase secrets set` (o João roda) ou por `.env` local, que fica fora do git.

## Fases
| Fase | Prompt | Status |
|---|---|---|
| 01 Validar APIs | `prompts/01-validar-apis.md` | concluída com pendências (chaves e CSV: `docs/PENDENCIAS-JOAO.md`) |
| 02 Spec e arquitetura | `prompts/02-spec-e-arquitetura.md` | pendente |
| 03 Base e catálogo | `prompts/03-base-e-catalogo.md` | pendente |
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
