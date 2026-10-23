-- Testes de RLS da rede social (fase 06). Rodam em `npm run db:test`, numa
-- transação desfeita no fim. Convenção igual à do 0001: `tests.login_as(uid)`
-- vira o usuário; `reset role` volta a ser o superusuário.
--
-- O prompt chamava este arquivo de 0004_social.sql, mas 0004 já é o teste da
-- importação; a numeração segue as fases (ver Decisões no CLAUDE.md).
--
-- Regra desta fase: toda visibilidade é decidida aqui, no banco. Se um caso
-- destes falhar, a correção é migração nova (nunca editar a 0001).

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Bloqueio vale nos dois sentidos em curtidas, comentários, busca por @,
--    notificações, follows alheios e feed
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; c uuid;
  t uuid;
  act_a uuid; act_b uuid; act_c uuid;
  n int;
begin
  a := tests.create_user('a6@teste.local');
  b := tests.create_user('b6@teste.local');
  c := tests.create_user('c6@teste.local');
  update public.profiles set username = 'ana_social', display_name = 'Ana' where id = a;
  update public.profiles set username = 'bruno_social', display_name = 'Bruno' where id = b;
  update public.profiles set username = 'carla_social' where id = c;
  insert into public.titles (tmdb_id, media_type, title) values (1396, 'tv', 'Breaking Bad') returning id into t;

  -- todo mundo segue todo mundo (perfis públicos: aceito na hora)
  perform tests.login_as(a); insert into public.follows (follower_id, followee_id) values (a, b), (a, c); reset role;
  perform tests.login_as(b); insert into public.follows (follower_id, followee_id) values (b, a), (b, c); reset role;
  perform tests.login_as(c); insert into public.follows (follower_id, followee_id) values (c, a), (c, b); reset role;

  -- cada um registra o título: 3 atividades
  perform tests.login_as(a); insert into public.entries (user_id, title_id, status, rating, review) values (a, t, 'watched', 5, 'Obra-prima.'); reset role;
  perform tests.login_as(b); insert into public.entries (user_id, title_id, status, rating) values (b, t, 'watched', 4); reset role;
  perform tests.login_as(c); insert into public.entries (user_id, title_id, status) values (c, t, 'watched'); reset role;
  select id into act_a from public.activities where user_id = a;
  select id into act_b from public.activities where user_id = b;
  select id into act_c from public.activities where user_id = c;

  -- B e C curtem e comentam a atividade de A; A comenta a de B; B comenta a de C
  perform tests.login_as(b);
  insert into public.likes (user_id, activity_id) values (b, act_a);
  insert into public.comments (activity_id, user_id, body) values (act_a, b, 'Também achei.');
  insert into public.comments (activity_id, user_id, body) values (act_c, b, 'Finalmente!');
  reset role;
  perform tests.login_as(c);
  insert into public.likes (user_id, activity_id) values (c, act_a);
  insert into public.comments (activity_id, user_id, body) values (act_a, c, 'Melhor final.');
  reset role;
  perform tests.login_as(a);
  insert into public.likes (user_id, activity_id) values (a, act_b);
  insert into public.comments (activity_id, user_id, body) values (act_b, a, 'Só 4?');
  assert (select count(*) from public.likes where activity_id = act_a) = 2, 'antes do bloqueio A vê as 2 curtidas';
  assert (select count(*) from public.comments where activity_id = act_a) = 2, 'antes do bloqueio A vê os 2 comentários';
  assert (select count(*) from public.feed) = 3, 'feed de A tem as 3 atividades';
  assert (select count(*) from public.notifications where user_id = a and actor_id = b) = 3, 'A tem 3 notificações de B (seguiu, curtiu, comentou)';

  -- A bloqueia B
  insert into public.blocks (blocker_id, blocked_id) values (a, b);

  -- ponta de A: nada de B, mas o resto continua
  assert (select count(*) from public.likes where activity_id = act_a) = 1, 'bloqueador não vê a curtida do bloqueado';
  assert (select count(*) from public.comments where activity_id = act_a) = 1, 'bloqueador não vê o comentário do bloqueado';
  assert (select count(*) from public.comments where activity_id = act_c) = 0, 'nem o comentário do bloqueado na atividade de um terceiro';
  assert (select count(*) from public.activities where id = act_b) = 0, 'bloqueador não vê a atividade do bloqueado';
  assert (select count(*) from public.likes where activity_id = act_b) = 0, 'nem a própria curtida nela (a atividade sumiu)';
  assert (select count(*) from public.feed) = 2, 'feed de A perdeu B';
  assert (select count(*) from public.profiles where username ilike 'bruno%') = 0, 'bloqueado não aparece na busca por @';
  assert (select count(*) from public.profiles where display_name ilike '%bruno%') = 0, 'nem na busca por nome';
  assert (select count(*) from public.notifications where user_id = a and actor_id = b) = 0, 'notificações do bloqueado sumiram';
  assert (select count(*) from public.follows where follower_id = b or followee_id = b) = 0, 'follows com o bloqueado sumiram (nos dois sentidos)';
  -- A lista "seguindo" de C mostra A, não B
  assert (select count(*) from public.follows where follower_id = c) = 1, 'na lista de quem C segue, A não vê B';
  reset role;

  -- ponta de B: nada de A
  perform tests.login_as(b);
  assert (select count(*) from public.activities where id = act_a) = 0, 'bloqueado não vê a atividade do bloqueador';
  assert (select count(*) from public.likes where activity_id = act_b) = 0, 'bloqueado não vê a curtida do bloqueador na própria atividade';
  assert (select count(*) from public.comments where activity_id = act_b) = 0, 'bloqueado não vê o comentário do bloqueador na própria atividade';
  assert (select count(*) from public.comments where activity_id = act_c) = 1, 'mas vê o próprio comentário na atividade de C';
  assert (select count(*) from public.profiles where username ilike 'ana%') = 0, 'bloqueado não acha o bloqueador na busca';
  assert (select count(*) from public.notifications where actor_id = a) = 0, 'bloqueado não tem notificações do bloqueador';
  assert (select count(*) from public.follows where follower_id = c) = 1, 'na lista de quem C segue, B não vê A';
  assert (select count(*) from public.feed) = 2, 'feed de B: ele mesmo e C';
  begin
    insert into public.likes (user_id, activity_id) values (b, act_a);
    raise exception 'bloqueado curtir atividade do bloqueador deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.comments (activity_id, user_id, body) values (act_a, b, 'oi');
    raise exception 'bloqueado comentar atividade do bloqueador deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.follows (follower_id, followee_id) values (b, a);
    raise exception 'bloqueado seguir o bloqueador deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  -- terceiro (C) continua vendo os dois e tudo o que escreveram
  perform tests.login_as(c);
  assert (select count(*) from public.likes where activity_id = act_a) = 2, 'terceiro vê as 2 curtidas';
  assert (select count(*) from public.comments where activity_id = act_a) = 2, 'terceiro vê os 2 comentários';
  assert (select count(*) from public.feed) = 3, 'feed de C não muda';
  reset role;

  -- contadores desnormalizados não são por leitor: a tela mostra o que carregou
  assert (select like_count from public.activities where id = act_a) = 2, 'like_count continua 2 (não é por leitor)';

  -- desbloquear não refaz nada
  perform tests.login_as(a);
  delete from public.blocks where blocker_id = a and blocked_id = b;
  get diagnostics n = row_count;
  assert n = 1, 'A desbloqueia B';
  assert (select count(*) from public.follows where follower_id = a and followee_id = b) = 0, 'desbloquear não refaz o follow';
  assert (select count(*) from public.likes where activity_id = act_a) = 2, 'desbloqueado: curtidas voltam a aparecer';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Pedido pendente não dá acesso; ninguém mexe em follow alheio
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; c uuid; t uuid; act_b uuid; l uuid; n int;
begin
  a := tests.create_user('a7@teste.local');
  b := tests.create_user('b7@teste.local');
  c := tests.create_user('c7@teste.local');
  update public.profiles set is_private = true where id = b;
  insert into public.titles (tmdb_id, media_type, title) values (66732, 'tv', 'Stranger Things') returning id into t;

  perform tests.login_as(b);
  insert into public.entries (user_id, title_id, status, rating) values (b, t, 'watched', 4.5);
  insert into public.checkins (user_id, title_id) values (b, t);
  insert into public.lists (user_id, name) values (b, 'Favoritas') returning id into l;
  reset role;
  select id into act_b from public.activities where user_id = b and kind = 'rated';

  -- A pede para seguir B: pending
  perform tests.login_as(a);
  insert into public.follows (follower_id, followee_id) values (a, b);
  assert (select status from public.follows where follower_id = a and followee_id = b) = 'pending', 'virou pedido';
  assert (select count(*) from public.entries where user_id = b) = 0, 'pendente não vê o diário';
  assert (select count(*) from public.activities where user_id = b) = 0, 'pendente não vê atividades';
  assert (select count(*) from public.checkins where user_id = b) = 0, 'pendente não vê check-in';
  assert (select count(*) from public.lists where user_id = b) = 0, 'pendente não vê listas';
  assert (select count(*) from public.feed where user_id = b) = 0, 'pendente não recebe B no feed';
  assert public.can_view_content(b) = false, 'can_view_content diz não';
  assert (select count(*) from public.profiles where id = b) = 1, 'mas vê o cartão';
  begin
    insert into public.likes (user_id, activity_id) values (a, act_b);
    raise exception 'curtir atividade invisível deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.comments (activity_id, user_id, body) values (act_b, a, 'oi');
    raise exception 'comentar atividade invisível deveria falhar';
  exception when insufficient_privilege then null;
  end;
  -- o próprio solicitante não aceita o pedido
  update public.follows set status = 'accepted' where follower_id = a and followee_id = b;
  get diagnostics n = row_count;
  assert n = 0, 'solicitante não aceita o próprio pedido';
  assert (select status from public.follows where follower_id = a and followee_id = b) = 'pending', 'continua pendente';
  reset role;

  -- terceiro não vê o pedido nem mexe nele
  perform tests.login_as(c);
  assert (select count(*) from public.follows where follower_id = a and followee_id = b) = 0, 'terceiro não vê pedido pendente';
  update public.follows set status = 'accepted' where follower_id = a and followee_id = b;
  get diagnostics n = row_count;
  assert n = 0, 'terceiro não aceita pedido alheio';
  delete from public.follows where follower_id = a and followee_id = b;
  get diagnostics n = row_count;
  assert n = 0, 'terceiro não apaga follow alheio';
  begin
    insert into public.follows (follower_id, followee_id) values (a, c);
    raise exception 'seguir em nome de outro deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  -- B aceita; agora A vê tudo
  perform tests.login_as(b);
  assert (select count(*) from public.follows where followee_id = b and status = 'pending') = 1, 'B vê o pedido na aba de pedidos';
  update public.follows set status = 'accepted' where follower_id = a and followee_id = b;
  get diagnostics n = row_count;
  assert n = 1, 'B aceita';
  begin
    update public.follows set follower_id = c where follower_id = a and followee_id = b;
    raise exception 'trocar as pontas do follow deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  perform tests.login_as(a);
  assert (select count(*) from public.entries where user_id = b) = 1, 'aceito vê o diário';
  assert (select count(*) from public.activities where user_id = b) = 2, 'aceito vê atividades (nota + lista criada)';
  assert (select count(*) from public.checkins where user_id = b) = 1, 'aceito vê check-in';
  assert (select count(*) from public.lists where user_id = b) = 1, 'aceito vê lista pública';
  assert (select count(*) from public.feed where user_id = b) = 2, 'aceito recebe B no feed';
  insert into public.likes (user_id, activity_id) values (a, act_b);
  reset role;

  -- B recusa um pedido novo de C: apagar a linha
  perform tests.login_as(c); insert into public.follows (follower_id, followee_id) values (c, b); reset role;
  perform tests.login_as(b);
  delete from public.follows where follower_id = c and followee_id = b;
  get diagnostics n = row_count;
  assert n = 1, 'seguido recusa (apaga) o pedido';
  reset role;
  perform tests.login_as(c);
  assert (select count(*) from public.follows where follower_id = c and followee_id = b) = 0, 'para quem pediu, o pedido sumiu';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Comentário: não troca de atividade nem de autor; só o autor edita;
--    dono da atividade e autor apagam; terceiro não
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; c uuid; t uuid; act_a uuid; act_b uuid; cmt uuid; n int; before_update timestamptz;
begin
  a := tests.create_user('a8@teste.local');
  b := tests.create_user('b8@teste.local');
  c := tests.create_user('c8@teste.local');
  insert into public.titles (tmdb_id, media_type, title) values (872585, 'movie', 'Oppenheimer') returning id into t;
  perform tests.login_as(a); insert into public.entries (user_id, title_id, status, rating) values (a, t, 'watched', 5); reset role;
  perform tests.login_as(b); insert into public.entries (user_id, title_id, status, rating) values (b, t, 'watched', 3); reset role;
  select id into act_a from public.activities where user_id = a;
  select id into act_b from public.activities where user_id = b;

  perform tests.login_as(b);
  insert into public.comments (activity_id, user_id, body) values (act_a, b, 'Som absurdo.') returning id into cmt;
  begin
    update public.comments set activity_id = act_b where id = cmt;
    raise exception 'mover comentário de atividade deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.comments set user_id = a where id = cmt;
    raise exception 'trocar o autor do comentário deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.comments (activity_id, user_id, body) values (act_a, b, repeat('x', 1001));
    raise exception 'comentário com 1001 caracteres deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.comments (activity_id, user_id, body) values (act_a, b, '');
    raise exception 'comentário vazio deveria falhar';
  exception when check_violation then null;
  end;
  select updated_at into before_update from public.comments where id = cmt;
  update public.comments set body = 'Som absurdo!', has_spoiler = true where id = cmt;
  get diagnostics n = row_count;
  assert n = 1, 'autor edita o próprio comentário';
  reset role;
  assert (select updated_at from public.comments where id = cmt) >= before_update, 'updated_at acompanha a edição';
  assert (select activity_id from public.comments where id = cmt) = act_a, 'comentário continua na atividade original';

  -- dono da atividade não edita, só apaga; terceiro nem um nem outro
  perform tests.login_as(a);
  update public.comments set body = 'editado pelo dono' where id = cmt;
  get diagnostics n = row_count;
  assert n = 0, 'dono da atividade não edita comentário alheio';
  reset role;
  perform tests.login_as(c);
  update public.comments set body = 'editado por terceiro' where id = cmt;
  get diagnostics n = row_count;
  assert n = 0, 'terceiro não edita comentário alheio';
  delete from public.comments where id = cmt;
  get diagnostics n = row_count;
  assert n = 0, 'terceiro não apaga comentário alheio';
  reset role;
  perform tests.login_as(a);
  delete from public.comments where id = cmt;
  get diagnostics n = row_count;
  assert n = 1, 'dono da atividade apaga comentário alheio';
  reset role;
  assert (select comment_count from public.activities where id = act_a) = 0, 'comment_count volta a 0';
  assert (select count(*) from public.notifications where comment_id = cmt) = 0, 'notificação do comentário caiu em cascata';

  -- apagar a própria atividade leva curtidas e comentários junto; ninguém apaga a alheia
  perform tests.login_as(b);
  delete from public.activities where id = act_a;
  get diagnostics n = row_count;
  assert n = 0, 'ninguém apaga atividade alheia';
  reset role;
  perform tests.login_as(c); insert into public.likes (user_id, activity_id) values (c, act_a); reset role;
  perform tests.login_as(a);
  delete from public.activities where id = act_a;
  get diagnostics n = row_count;
  assert n = 1, 'autor apaga a própria atividade';
  reset role;
  assert (select count(*) from public.likes where activity_id = act_a) = 0, 'curtidas caem em cascata';
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. Notificação: só o destinatário lê, marca e apaga; cliente não cria;
--    curtida própria não notifica; descurtir remove; só read_at é editável
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; t uuid; act_a uuid; n int;
begin
  a := tests.create_user('a9@teste.local');
  b := tests.create_user('b9@teste.local');
  insert into public.titles (tmdb_id, media_type, title) values (120, 'movie', 'O Senhor dos Anéis') returning id into t;
  perform tests.login_as(a); insert into public.entries (user_id, title_id, status, rating) values (a, t, 'watched', 5); reset role;
  select id into act_a from public.activities where user_id = a;

  perform tests.login_as(b);
  insert into public.follows (follower_id, followee_id) values (b, a);
  insert into public.likes (user_id, activity_id) values (b, act_a);
  assert (select count(*) from public.notifications) = 0, 'quem causou não vê as notificações do destinatário';
  assert (select count(*) from public.notifications where user_id = a) = 0, 'nem filtrando pelo destinatário';
  update public.notifications set read_at = now() where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'não marca notificação alheia';
  delete from public.notifications where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'não apaga notificação alheia';
  begin
    insert into public.notifications (user_id, actor_id, kind) values (b, a, 'follow');
    raise exception 'cliente criar notificação deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  perform tests.login_as(a);
  assert (select count(*) from public.notifications where user_id = a) = 2, 'destinatário vê seguiu + curtiu';
  insert into public.likes (user_id, activity_id) values (a, act_a);          -- auto-curtida
  assert (select count(*) from public.notifications where user_id = a and kind = 'like') = 1, 'auto-curtida não notifica';
  update public.notifications set read_at = now() where user_id = a and read_at is null;
  get diagnostics n = row_count;
  assert n = 2, 'marcar as minhas como lidas';
  assert (select count(*) from public.notifications where user_id = a and read_at is null) = 0, 'nenhuma não lida';
  begin
    update public.notifications set kind = 'comment' where user_id = a;
    raise exception 'destinatário trocar o tipo da notificação deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.notifications set actor_id = a where user_id = a;
    raise exception 'destinatário trocar o autor da notificação deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  perform tests.login_as(b);
  delete from public.likes where user_id = b and activity_id = act_a;
  reset role;
  assert (select count(*) from public.notifications where user_id = a and kind = 'like' and actor_id = b) = 0, 'descurtir remove a notificação';
  assert (select like_count from public.activities where id = act_a) = 1, 'like_count desce';

  perform tests.login_as(a);
  delete from public.notifications where user_id = a;
  get diagnostics n = row_count;
  assert n = 1, 'destinatário apaga as suas';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 5. Check-in: de perfil privado só para seguidor aceito; validade máxima;
--    só o dono cria/encerra; faixa dos amigos (friends_checkins) só de quem sigo
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; c uuid; d uuid; t uuid; ck uuid; n int;
begin
  a := tests.create_user('a10@teste.local');
  b := tests.create_user('b10@teste.local');
  c := tests.create_user('c10@teste.local');
  d := tests.create_user('d10@teste.local');
  update public.profiles set is_private = true where id = b;
  insert into public.titles (tmdb_id, media_type, title) values (37854, 'tv', 'One Piece') returning id into t;

  perform tests.login_as(b);
  insert into public.checkins (user_id, title_id, season, episode, note) values (b, t, 21, 1050, 'Wano!') returning id into ck;
  begin
    insert into public.checkins (user_id, title_id, expires_at) values (b, t, now() + interval '13 hours');
    raise exception 'check-in de 13 h deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.checkins (user_id, title_id, note) values (b, t, repeat('x', 141));
    raise exception 'nota de 141 caracteres deveria falhar';
  exception when check_violation then null;
  end;
  reset role;
  perform tests.login_as(d); insert into public.checkins (user_id, title_id) values (d, t); reset role;   -- D é público

  -- A: estranho → pedido pendente → aceito
  perform tests.login_as(a);
  assert (select count(*) from public.checkins where user_id = b) = 0, 'estranho não vê check-in de perfil privado';
  assert (select count(*) from public.checkins where user_id = d) = 1, 'estranho vê check-in de perfil público na tabela';
  assert (select count(*) from public.friends_checkins) = 0, 'mas a faixa dos amigos só traz quem eu sigo';
  insert into public.follows (follower_id, followee_id) values (a, b);
  assert (select count(*) from public.checkins where user_id = b) = 0, 'pedido pendente não vê check-in';
  begin
    insert into public.checkins (user_id, title_id) values (b, t);
    raise exception 'check-in em nome de outro deveria falhar';
  exception when insufficient_privilege then null;
  end;
  delete from public.checkins where id = ck;
  get diagnostics n = row_count;
  assert n = 0, 'não encerra check-in alheio';
  update public.checkins set expires_at = now() + interval '1 minute' where id = ck;
  get diagnostics n = row_count;
  assert n = 0, 'não edita check-in alheio';
  reset role;
  perform tests.login_as(b); update public.follows set status = 'accepted' where follower_id = a and followee_id = b; reset role;
  perform tests.login_as(a);
  assert (select count(*) from public.checkins where user_id = b) = 1, 'seguidor aceito vê o check-in do privado';
  assert (select count(*) from public.friends_checkins where user_id = b) = 1, 'e ele entra na faixa dos amigos';
  assert (select count(*) from public.friends_checkins where user_id = d) = 0, 'D continua fora da faixa (não sigo)';
  insert into public.checkins (user_id, title_id) values (a, t);
  assert (select count(*) from public.friends_checkins where user_id = a) = 1, 'meu próprio check-in entra na faixa';
  reset role;

  -- C (estranho) nunca vê B
  perform tests.login_as(c);
  assert (select count(*) from public.checkins where user_id = b) = 0, 'estranho continua sem ver o check-in do privado';
  reset role;

  -- expirado: some para o seguidor, o dono ainda vê o seu
  update public.checkins set expires_at = now() - interval '1 minute' where id = ck;
  perform tests.login_as(a);
  assert (select count(*) from public.checkins where user_id = b) = 0, 'check-in expirado some para o seguidor';
  assert (select count(*) from public.friends_checkins where user_id = b) = 0, 'e sai da faixa';
  reset role;
  perform tests.login_as(b);
  assert (select count(*) from public.checkins where id = ck) = 1, 'dono vê o próprio check-in expirado';
  delete from public.checkins where id = ck;
  get diagnostics n = row_count;
  assert n = 1, 'dono encerra o próprio check-in';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 6. Denúncia só do autor; curtir duas vezes não duplica; lista que vira
--    privada sai do feed; feed segue só aceitos
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; c uuid; t uuid; act_a uuid; l uuid; n int;
begin
  a := tests.create_user('a11@teste.local');
  b := tests.create_user('b11@teste.local');
  c := tests.create_user('c11@teste.local');
  update public.profiles set is_private = true where id = c;
  insert into public.titles (tmdb_id, media_type, title) values (693134, 'movie', 'Duna: Parte Dois') returning id into t;
  perform tests.login_as(a); insert into public.entries (user_id, title_id, status, rating) values (a, t, 'watched', 4.5); reset role;
  perform tests.login_as(c); insert into public.entries (user_id, title_id, status, rating) values (c, t, 'watched', 4); reset role;
  select id into act_a from public.activities where user_id = a;

  -- denúncias
  perform tests.login_as(a);
  insert into public.reports (reporter_id, target_type, target_id, reason, details) values (a, 'profile', b, 'harassment', 'Mensagens ofensivas');
  insert into public.reports (reporter_id, target_type, target_id, reason) values (a, 'activity', act_a, 'spoiler');
  begin
    insert into public.reports (reporter_id, target_type, target_id, reason) values (b, 'profile', a, 'spam');
    raise exception 'denunciar em nome de outro deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.reports (reporter_id, target_type, target_id, reason, status) values (a, 'profile', b, 'spam', 'actioned');
    raise exception 'denúncia já resolvida deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.reports (reporter_id, target_type, target_id, reason) values (a, 'profile', b, 'ugly');
    raise exception 'motivo fora da lista deveria falhar';
  exception when check_violation then null;
  end;
  assert (select count(*) from public.reports) = 2, 'denunciante vê as suas';
  begin
    delete from public.reports where reporter_id = a;
    raise exception 'denunciante apagar denúncia deveria falhar (grant revogado)';
  exception when insufficient_privilege then null;
  end;
  reset role;
  perform tests.login_as(b);
  assert (select count(*) from public.reports) = 0, 'denunciado não vê a denúncia';
  reset role;
  perform tests.login_as(c);
  assert (select count(*) from public.reports) = 0, 'terceiro não vê denúncias';
  reset role;

  -- curtir duas vezes
  perform tests.login_as(b);
  insert into public.likes (user_id, activity_id) values (b, act_a);
  begin
    insert into public.likes (user_id, activity_id) values (b, act_a);
    raise exception 'curtir duas vezes deveria violar a chave';
  exception when unique_violation then null;
  end;
  insert into public.likes (user_id, activity_id) values (b, act_a) on conflict do nothing;   -- o app usa upsert com ignoreDuplicates
  reset role;
  assert (select like_count from public.activities where id = act_a) = 1, 'like_count não duplica';
  assert (select count(*) from public.notifications where user_id = a and kind = 'like') = 1, 'uma notificação só';

  -- lista pública → privada: a atividade "criou a lista" sai do feed
  perform tests.login_as(a);
  insert into public.lists (user_id, name) values (a, 'Sci-fi') returning id into l;
  assert (select count(*) from public.activities where list_id = l) = 1, 'lista pública gera atividade';
  update public.lists set name = 'Sci-fi brasileira' where id = l;
  assert (select payload ->> 'name' from public.activities where list_id = l) = 'Sci-fi brasileira', 'renomear atualiza o payload';
  update public.lists set is_private = true where id = l;
  assert (select count(*) from public.activities where list_id = l) = 0, 'lista que virou privada sai do feed';
  update public.lists set is_private = false where id = l;
  assert (select count(*) from public.activities where list_id = l) = 0, 'voltar a público não recria o evento';
  reset role;

  -- feed: só aceitos (B segue A público e C privado)
  perform tests.login_as(b);
  insert into public.follows (follower_id, followee_id) values (b, a), (b, c);
  assert (select count(*) from public.feed where user_id = a) = 1, 'feed traz A (aceito)';
  assert (select count(*) from public.feed where user_id = c) = 0, 'feed não traz C (pendente)';
  reset role;
  perform tests.login_as(c); update public.follows set status = 'accepted' where follower_id = b and followee_id = c; reset role;
  perform tests.login_as(b);
  assert (select count(*) from public.feed where user_id = c) = 1, 'aceito: C entra no feed';
  reset role;
end $$;
