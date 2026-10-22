# Como usar estes prompts

São 8 fases. Cada uma é um prompt curto que depende do `CLAUDE.md` da raiz (o contexto do produto) e do que as fases anteriores deixaram em `docs/`.

## Rodando uma fase
1. Abra uma sessão nova do Claude Code na pasta `app-streaming-social`. Uma fase por sessão: o contexto fica limpo, e o que passa de uma fase para outra fica no `CLAUDE.md` e em `docs/`.
2. Escolha o modelo e o esforço da tabela abaixo.
3. Ligue o modo de planejamento e cole:

   > Leia o CLAUDE.md e o prompts/0X-nome.md e execute essa fase. Me mostre o plano antes de editar.

4. Aprove o plano, deixe rodar e confira o "Pronto quando" antes de passar para a próxima.

> Desde 22/10/2026 as fases rodam em série por uma sessão orquestradora, sem aprovação por etapa (liberdade total dada pelo João). O que só ele faz fica em `docs/PENDENCIAS-JOAO.md`; o que cada fase decide fica na seção "Decisões" do `CLAUDE.md`.

## Modelo e esforço
**Recomendação: Claude Fable 5.1**, o modelo mais capaz da Anthropic. Esforço `xhigh` nas fases difíceis e `high` nas mais mecânicas.

| Fase | Modelo | Esforço | Por quê |
|---|---|---|---|
| 01 Validar APIs | Fable 5.1 | high | Pesquisa com teste real: muita chamada de ferramenta, pouco raciocínio pesado |
| 02 Spec e arquitetura | Fable 5.1 | xhigh | Todas as fases herdam essas decisões. Gasta pouco e pesa muito |
| 03 Base e catálogo | Fable 5.1 | xhigh | Proxy, cache e estrutura do app: um erro aqui contamina o resto |
| 04 Perfil e diário | Fable 5.1 | high | CRUD já bem definido pela spec |
| 05 Importar Netflix | Fable 5.1 | xhigh | Casar títulos do CSV com o TMDB é o problema mais traiçoeiro do app |
| 06 Rede social | Fable 5.1 | xhigh | RLS e privacidade: um erro aqui vira vazamento de dado |
| 07 Qual assinar | Fable 5.1 | xhigh | Algoritmo com testes de caso |
| 08 Polimento e release | Fable 5.1 | high | Design e checklist da loja |

- **`max`:** não use por padrão. Ele pensa mais do que essas tarefas pedem e queima limite. Só vale se uma fase travar num bug que o `xhigh` não resolveu.
- **Se o limite semanal apertar:** troque para Claude Opus 5.5 com o mesmo esforço nas fases 01, 04 e 08, que são as menos sensíveis. Na API, o Fable custa 2,5x o Opus 5.5 por token ($10/$50 contra $4/$20 por milhão).
- **Sonnet e Haiku:** não use neste projeto.

## Por que os prompts são curtos
Eles dizem o objetivo, as restrições e quando a fase está pronta, mas não ditam o passo a passo. Com o Fable 5.1, prompt prescritivo demais piora o resultado: ele decide melhor o "como" quando sabe o "para quê".

## O que você (João) precisa fazer, por fase
- **01:** criar as chaves grátis do TMDB, da Watchmode e da Streaming Availability (RapidAPI) e colocar em `research/.env`. Baixar o seu CSV da Netflix (Conta → Perfil → Atividade de visualização → Baixar tudo) e salvar em `research/NetflixViewingHistory.csv`.
- **02:** criar um projeto no Supabase (região `sa-east-1`) e ler/confirmar o `docs/SPEC.md` (aprovado por procuração em 22/10; os pontos marcados com ▶ são os que pedem sua atenção).
- **03:** `supabase login` + `supabase link`, rodar os `supabase secrets set` que a sessão indicar e configurar o login Google no Google Cloud. A máquina não tem Docker: o banco é validado com `npm run db:test` (Postgres local) e as Edge Functions sobem com `--use-api`.
- **06:** testar com uma segunda conta, sua ou de alguém próximo.
- **08:** criar a conta de desenvolvedor do Google Play e guardar a keystore de release.
