# Fase 06 — Rede social
Modelo: Fable 5.1 · esforço xhigh

## O que a fase 02 já decidiu (está no banco; esta fase constrói a interface em cima)
- Tabelas e triggers prontos na 0001: `follows` (pending/accepted decidido por trigger pela privacidade do seguido), `blocks` (trigger desfaz follows e limpa notificações nos dois sentidos), `activities` (só triggers escrevem; rajada de 1 h atualiza em vez de duplicar), `likes` e `comments` (contadores em `activities`, notificação ao autor), `notifications`, `checkins` (expiram), `reports`. View `feed` (quem eu sigo + eu). RPCs `profile_counts` e `list_blocked_users`.
- Regras de visibilidade em `docs/SPEC.md` §5.3–5.6 e `docs/ARQUITETURA.md` §12: bloqueio vale nos dois sentidos e no banco; perfil privado esconde conteúdo, não cartão; atividades só por trigger; o dono da atividade pode apagar comentário alheio.
- `tools/db/tests/0001_rls_smoke.sql` já prova bloqueio, pedido de seguir, feed, curtida, comentário e cota. Esta fase acrescenta o que faltar em `0004_social.sql`, rodando com `npm run db:test`.
- Feed por fan-out na leitura; o agrupamento visual ("assistiu 4 títulos hoje") é no cliente. Quando trocar: ARQUITETURA §11.

## Objetivo
Ver o que os amigos estão assistindo e conversar sobre isso, com privacidade e segurança desde o primeiro dia.

## Escopo
- **Seguir:** botão no perfil com os estados seguir / pedido enviado / seguindo; aba de pedidos recebidos para perfil privado (aceitar = `update follows set status = 'accepted'`; recusar = delete).
- **Feed** (`/feed`): itens de `feed` com avatar, frase ("@ana assistiu *The Bear* ★★★★½"), pôster, review (borrada se spoiler), contadores. Agrupar eventos consecutivos do mesmo autor no mesmo dia. Paginação por `range` de 30.
- **Interações:** curtir e comentar (`/activity/:id`); comentário com chave de spoiler; dono da atividade apaga comentário alheio.
- **Assistindo agora:** check-in manual (`checkins`, 3 h) com faixa no topo do feed e no Início.
- **Descobrir amigos:** busca por `@` (`/search/users`), compartilhar perfil (link `/u/:username`) e a etapa do onboarding.
- **Bloquear e denunciar** usuário e conteúdo (perfil, review, lista, comentário) com os motivos de `reports.reason`; Configurações → Bloqueados usa `list_blocked_users`.
- **Notificações** (`/notifications`): seguiu, pediu, aceitou, curtiu, comentou; marcar como lidas. Push fica para depois (SPEC §6).

## Restrições
- Toda regra de visibilidade fica no banco (RLS). A interface só esconde botões; se algo "vaza" na tela, o bug é na policy, e a correção é migração + teste.
- Interface otimista com desfazer.

## Testes
- `tools/db/tests/0004_social.sql`: bloqueado não vê comentários nem curtidas do bloqueador (e vice-versa); pedido pendente não dá acesso; comentário não pode trocar de atividade; notificação só do destinatário; check-in de perfil privado só para seguidor.
- **Usuários de teste:** no local, `tests.create_user` dentro dos testes SQL. No projeto de dev, `tools/db/seed-dev.mjs` (Node) cria 3 contas pela Admin API com a `service_role` lida de um `.env` fora do git (o João roda; nunca a chave no chat) e carrega uns 20 títulos e atividades.
- Widget: feed com repositório falso (estados vazio/erro/lista), item com spoiler.

## Pronto quando
- Dois usuários de teste seguem um ao outro, interagem no feed e um bloqueia o outro, com o comportamento certo nas duas pontas (João testa com uma segunda conta).
- `npm run db:test` verde com os testes novos.
- `flutter analyze` limpo, APK na Área de Trabalho e commit feito.
