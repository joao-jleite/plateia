# Plateia (codinome provisório)

App Android em Flutter + Supabase que junta num lugar só o que a pessoa assiste em todos os streamings, com uma rede social em volta. Ele **não toca vídeo**: mostra onde cada título está no Brasil, abre o app oficial do streaming e diz qual streaming vale assinar este mês. Pacote Android `io.github.joaojleite.watchlog`.

## Estado (23/10/2026)

As 8 fases de `prompts/` estão concluídas e commitadas (`b2ab068` … `25ef73a`). Tudo foi testado localmente: 217 testes Flutter, 7 testes SQL de RLS num Postgres 17 embutido, 30 testes Deno das Edge Functions, `flutter analyze` limpo.

**Nada rodou ainda contra um projeto Supabase real**: ele, as chaves de API, a keystore de release e a conta do Google Play são do João. O caminho do zero ao teste interno (15 passos, ~4 h) está em [`docs/PENDENCIAS-JOAO.md`](docs/PENDENCIAS-JOAO.md).

## Mapa do repositório

| Onde | O que |
|---|---|
| [`CLAUDE.md`](CLAUDE.md) | Contexto do produto, linhas que não se cruzam, stack, convenções, tabela de fases e todas as decisões (com o porquê) |
| [`docs/SPEC.md`](docs/SPEC.md) | Personas, as 5 jornadas do MVP, telas, regras de negócio, o que ficou fora |
| [`docs/ARQUITETURA.md`](docs/ARQUITETURA.md) | Pastas do Flutter, Riverpod 3 + go_router, Edge Functions e contratos, cache e cota, feed |
| [`docs/DEV.md`](docs/DEV.md) | Como rodar e testar, com e sem backend |
| [`docs/DESIGN.md`](docs/DESIGN.md) | As 2 direções visuais e a aplicada ("Sala escura") |
| [`docs/RELEASE.md`](docs/RELEASE.md) | Checklist completo da Google Play (ficha, Segurança dos dados, UGC, apagar conta) |
| [`docs/decisoes-apis.md`](docs/decisoes-apis.md) | Fase 01: por que TMDB + Streaming Availability, assetlinks dos streamings, formato do CSV da Netflix |
| [`docs/site/`](docs/site/) | Páginas públicas para o GitHub Pages: privacidade, termos, apagar conta |
| [`docs/capturas/`](docs/capturas/) | Capturas do emulador de cada fase |
| `prompts/` | Os 8 prompts de fase e [`00-COMO-USAR.md`](prompts/00-COMO-USAR.md) |
| `lib/`, `test/` | App Flutter (feature-first) e testes; `lib/dev/fixtures` é o backend de amostra |
| `supabase/` | `config.toml`, migrações 0001–0006 (RLS em toda tabela) e 6 Edge Functions com testes |
| `tools/db/` | Postgres local sem Docker (`npm run db:test`), testes SQL de RLS e `seed-dev.mjs` |
| `research/` | Scripts Python da fase 01 (`.env` e CSV ficam fora do git) |

## Rodar e testar

```powershell
flutter pub get
flutter analyze
flutter test
npm run db:test
cd supabase/functions; deno task test
```

Sem backend, com dados de amostra (nunca em release):

```powershell
flutter run --dart-define=BACKEND=fixtures
```

Com o projeto Supabase: ver [`docs/DEV.md`](docs/DEV.md). APK mais recente para testar no celular: `plateia-fase08.apk` na Área de Trabalho (build profile com fixtures).

## Regras que não mudam

- Nunca hospedar, transmitir ou linkar vídeo fora do streaming oficial; nunca raspar site de streaming.
- Dados de "onde assistir" vêm do TMDB (fonte JustWatch) e o link que abre o app, da Streaming Availability; a atribuição exigida aparece no app. Plano grátis é não comercial: antes de cobrar ou anunciar, licença comercial do TMDB e plano Starter da Streaming Availability.
- Chaves nunca vão no app nem no git: ficam em `supabase secrets` ou em `.env` local.
- O CSV da Netflix é processado no aparelho e descartado; só os títulos casados e um hash são guardados.
- Migração aplicada nunca se edita: cria-se outra. `npm run db:test` antes de qualquer `supabase db push`.
