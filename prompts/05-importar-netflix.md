# Fase 05 — Importar o histórico da Netflix
Modelo: Fable 5.1 · esforço xhigh

## O que as fases 01 e 02 já decidiram
- Formato do CSV e padrões de título em `docs/decisoes-apis.md` (seção "Formato do CSV da Netflix"); regexes reaproveitáveis em `research/05_netflix_csv.py`. Se o CSV real do João ainda não existir em `research/NetflixViewingHistory.csv`, trabalhe com fixtures sintéticas de cada padrão e deixe a medição de % como pendência.
- Divisão de trabalho (SPEC §5.8, ARQUITETURA §9): o CSV é lido **no aparelho** (isolate), agrupado por série/filme; só os **nomes agrupados** vão para a Edge Function `import-match` (≤ 100 por chamada), que devolve `confidence` high/medium/low, `best` e até 3 `candidates` (com `title_id` já criado como linha-esboço em `titles`). O arquivo nunca sai do celular nem é guardado.
- Tabelas: `imports` (resumo + `file_hash`), `import_candidates` (duvidosos), `entries` com `source = 'netflix_import'`. Um evento de feed `imported` por importação concluída (trigger em `imports`), nenhum por título.
- Idempotência já tem base no banco: unique `(user_id, title_id)`. A regra "reimportar não sobrescreve nota, review ou status editados à mão" é sua: upsert que só preenche o que está vazio ou veio da importação anterior.
- Pontuação do matching: ARQUITETURA §9 (nome normalizado +0,6; tipo +0,2; ano +0,1; único relevante +0,1; `high` ≥ 0,9 sem segundo ≥ 0,8).

## Objetivo
O perfil nasce cheio. A pessoa sobe o `NetflixViewingHistory.csv`, o app casa cada linha com um título do TMDB, mostra só os casos duvidosos para revisão e grava tudo como "Assisti".

## O que torna isso difícil
- Uma série aparece uma vez por episódio, com títulos como "Série: Temporada 2: Nome do episódio", "Parte 1", "Minissérie", "Volume" e arcos nomeados (anime). É preciso agrupar por série.
- Data em formato BR ou US, dependendo da conta. O encoding (BOM) e as aspas variam. O `ViewingActivity.csv` da exportação completa tem outras colunas.
- Títulos traduzidos, homônimos (filme e série com o mesmo nome), especiais e trailers que aparecem como título.
- Um histórico pode passar de 5 mil linhas. Não pode travar o app nem passar do rate limit do TMDB (a função usa concorrência 5).

## Escopo
- Upload do CSV no onboarding (`/onboarding/import`) e no perfil (`/import`).
- Parser e agrupador em `features/import_netflix/domain/` (puro, sem Flutter), rodando em `compute`.
- Matching com confiança: `high` entra direto como `watched` (data = última reprodução; `episodes_watched` = linhas da série); `medium`/`low` vão para `import_candidates` e para a tela `/import/review` com 2–3 candidatos e "nenhum destes".
- Importação idempotente, inclusive o `file_hash` ("você já importou este arquivo em DD/MM; importar de novo?").
- Progresso visível durante a importação e resumo ao final: "312 títulos importados, 9 para revisar".

## Testes
- Unitários do parser e do agrupador: um caso por padrão de título, datas D/M e M/D, BOM, aspas, `ViewingActivity.csv`.
- Unitários da regra de merge (reimportar não sobrescreve edição manual).
- `tools/db/tests/0003_import.sql`: só o dono lê `imports`/`import_candidates`; reimportar não duplica `entries` nem o evento `imported`.
- O CSV real do João como fixture **anonimizada e fora do git**, ou reduzida a títulos sem dado pessoal.

## Pronto quando
- O CSV real importa com a % de casamento automático medida e informada. Meta ≥ 90%; se não bater, diga onde está o erro. Sem o CSV real, as fixtures passam e a medição fica em `docs/PENDENCIAS-JOAO.md`.
- Os duvidosos aparecem na tela de revisão e resolver um grava a entrada.
- Rodar a importação duas vezes não duplica nada.
- `npm run db:test` e `flutter analyze` limpos, APK na Área de Trabalho e commit feito.
