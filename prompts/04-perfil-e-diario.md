# Fase 04 — Perfil e diário
Modelo: Fable 5.1 · esforço high

## O que a fase 02 já decidiu
- Diário é a tabela `entries`: **uma linha por (usuário, título)**; `status` watched/watching/want; nota 0,5–5 em meias estrelas; review até 5.000 caracteres com `has_spoiler`; `watch_count` para reassistir; `current_season`/`current_episode`/`episodes_watched` para séries. "Quero ver" não tem nota nem review (o banco recusa). Regras completas em `docs/SPEC.md` §5.2.
- Listas: `lists` (privacidade própria, `is_ranked`) e `list_items` (`position`, `note`).
- Privacidade (SPEC §5.3): perfil privado esconde o **conteúdo**, não o cartão. Já está na RLS; a interface só reflete.
- Atividades do feed já nascem por trigger quando a pessoa registra; esta fase não mexe nisso.
- `profile_counts(uuid)` (RPC) devolve seguidores/seguindo/assistidos/reviews/listas. Avatar vai para o bucket `avatars/<uid>/avatar.jpg` (migração 0002).
- Testes de RLS vivem em `tools/db/tests/*.sql` e rodam com `npm run db:test` (sem Docker). Modelo de teste em `docs/ARQUITETURA.md` §13.2.

## Objetivo
A pessoa registra o que vê em no máximo 2 toques a partir do detalhe do título, e o perfil mostra isso de um jeito que dá vontade de mostrar.

## Escopo
- **Folha Registrar** no detalhe: Assisti / Assistindo / Quero ver (um toque marca; o mesmo toque desmarca), nota em meias estrelas, data (padrão hoje), review com chave de spoiler; em série, temporada e episódio. Reassistir incrementa `watch_count`. "Adicionar à lista" na mesma folha.
- **Listas:** criar, renomear, ordenar (arrastar), ranqueada ou não, pública ou privada.
- **Perfil** (`/profile/:username`): foto (upload redimensionado), nome, `@`, bio; grade de pôsteres; abas Assisti / Quero ver / Listas / Reviews; contadores via `profile_counts`.
- **Estatísticas** (`/profile/:username/stats`): horas assistidas (`runtime_minutes` ou `episodes_watched × episode_run_time`), por streaming (`title_availability` em BR, só assinatura), por gênero (`titles.genres`), por ano (`titles.year`). Calcule no cliente a partir de uma consulta paginada ou crie uma RPC `profile_stats(uuid)` em migração 0003 se a consulta passar de 1 s com 2 mil entradas; registre a escolha em "Decisões".
- **Configurações de perfil:** editar cartão, perfil privado (`is_private`), apagar conta (já existe a função `account-delete`).
- Spoiler: review marcada aparece borrada no perfil e no detalhe até tocar (SPEC §5.6).

## Restrições
- Interface otimista: atualiza na hora e desfaz com aviso se o servidor recusar (padrão da `docs/ARQUITETURA.md` §5).
- Regras de nota, spoiler e privacidade são as do `docs/SPEC.md`. Buraco na spec: registre em "Decisões" antes de inventar.
- Schema novo só por migração 0003+, validada por `npm run db:test` antes do `db push`.

## Testes
- `tools/db/tests/0002_diary.sql`: outro usuário não lê nem altera registro alheio; perfil privado não vaza diário nem listas para não seguidor; lista privada não vaza nem para seguidor; nota 4,3 e nota em "quero ver" são recusadas.
- Unitários: cálculo das estatísticas (função pura em `features/profile/domain/`).
- Widget: folha Registrar e grade do perfil com repositório falso.

## Pronto quando
- O fluxo completo funciona no emulador, em até 2 toques do detalhe ao registro.
- `npm run db:test` verde com os novos testes de RLS.
- `flutter analyze` limpo, APK na Área de Trabalho e commit feito.
