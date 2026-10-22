-- Testes de RLS da migração 0001 (fase 02). Rodam em `npm run db:test`, numa
-- transação que é desfeita no fim. Cada bloco DO é um cenário; `assert` falha
-- com a mensagem. Convenção: `tests.login_as(uid)` vira o usuário (role
-- authenticated + claims); `reset role` volta a ser o superusuário (service).

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Cadastro, privacidade do diário, pedido de seguir, posse e bloqueio
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; c uuid;
  t1 uuid; t2 uuid;
  n int;
  v_status text;
begin
  a := tests.create_user('a1@teste.local', '{"full_name": "Ana"}');
  b := tests.create_user('b1@teste.local');
  c := tests.create_user('c1@teste.local');
  assert (select count(*) from public.profiles where id in (a, b, c)) = 3, 'trigger do cadastro criou 3 perfis';
  assert (select display_name from public.profiles where id = a) = 'Ana', 'display_name veio do metadata';
  assert (select username from public.profiles where id = b) ~ '^u_[0-9a-f]{10}$', 'username provisório no padrão';
  update public.profiles set is_private = true where id = b;

  insert into public.titles (tmdb_id, media_type, title) values (1399, 'tv', 'Game of Thrones') returning id into t1;
  insert into public.titles (tmdb_id, media_type, title) values (872585, 'movie', 'Oppenheimer') returning id into t2;

  -- A (público) e B (privado) registram
  perform tests.login_as(a);
  insert into public.entries (user_id, title_id, status, rating, review) values (a, t1, 'watched', 4.5, 'Ótima');
  reset role;
  perform tests.login_as(b);
  insert into public.entries (user_id, title_id, status) values (b, t2, 'watched');
  reset role;

  -- C vê o diário de A, não o de B; vê o cartão de B
  perform tests.login_as(c);
  assert (select count(*) from public.entries where user_id = a) = 1, 'C vê diário do perfil público';
  assert (select count(*) from public.entries where user_id = b) = 0, 'C não vê diário do perfil privado';
  assert (select count(*) from public.profiles where id = b) = 1, 'C vê o cartão do perfil privado';

  -- C não altera nem cria em nome de A
  update public.entries set rating = 1 where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'C não altera registro de A';
  begin
    insert into public.entries (user_id, title_id, status) values (a, t2, 'want');
    raise exception 'inserir em nome de A deveria falhar';
  exception when insufficient_privilege then null;
  end;

  -- seguir: privado vira pedido, público aceita na hora
  insert into public.follows (follower_id, followee_id) values (c, b);
  select status into v_status from public.follows where follower_id = c and followee_id = b;
  assert v_status = 'pending', 'seguir perfil privado vira pedido';
  insert into public.follows (follower_id, followee_id, status) values (c, a, 'pending');  -- cliente tenta forçar
  select status into v_status from public.follows where follower_id = c and followee_id = a;
  assert v_status = 'accepted', 'seguir perfil público é aceito na hora (trigger ignora o status do cliente)';
  reset role;

  -- B recebeu o pedido e aceita
  perform tests.login_as(b);
  assert (select count(*) from public.notifications where user_id = b and kind = 'follow_request' and actor_id = c) = 1, 'B recebeu notificação do pedido';
  update public.follows set status = 'accepted' where follower_id = c and followee_id = b;
  get diagnostics n = row_count;
  assert n = 1, 'B aceitou o pedido';
  reset role;

  perform tests.login_as(c);
  assert (select count(*) from public.entries where user_id = b) = 1, 'seguidor aceito vê o diário privado';
  assert (select count(*) from public.notifications where user_id = c and kind = 'follow_accepted') = 1, 'C foi avisado da aceitação';
  -- C não aceita pedido em nome de outro (não há linha visível para atualizar)
  reset role;

  -- A bloqueia C
  perform tests.login_as(a);
  insert into public.blocks (blocker_id, blocked_id) values (a, c);
  reset role;
  assert (select count(*) from public.follows where follower_id = c and followee_id = a) = 0, 'bloqueio desfez o follow';

  perform tests.login_as(c);
  assert (select count(*) from public.profiles where id = a) = 0, 'bloqueado não vê o perfil';
  assert (select count(*) from public.entries where user_id = a) = 0, 'bloqueado não vê o diário';
  assert (select count(*) from public.activities where user_id = a) = 0, 'bloqueado não vê atividades';
  assert (select count(*) from public.blocks) = 0, 'bloqueado não descobre que foi bloqueado';
  begin
    insert into public.follows (follower_id, followee_id) values (c, a);
    raise exception 'seguir quem me bloqueou deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  perform tests.login_as(a);
  assert (select count(*) from public.profiles where id = c) = 0, 'quem bloqueou não vê o bloqueado nas tabelas';
  assert (select count(*) from public.list_blocked_users()) = 1, 'mas vê na lista de bloqueados (RPC)';
  assert (select count(*) from public.profile_counts(c)) = 0, 'contadores não respondem entre bloqueados';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Feed, atividades por trigger, curtidas, comentários, cota, anon
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; c uuid; t uuid; act uuid; n int;
begin
  a := tests.create_user('a2@teste.local');
  c := tests.create_user('c2@teste.local');
  insert into public.titles (tmdb_id, media_type, title) values (1396, 'tv', 'Breaking Bad') returning id into t;

  perform tests.login_as(c);
  insert into public.follows (follower_id, followee_id) values (c, a);
  reset role;

  perform tests.login_as(a);
  insert into public.entries (user_id, title_id, status, rating) values (a, t, 'watched', 5);
  select id into act from public.activities where user_id = a;
  assert (select kind from public.activities where id = act) = 'rated', 'assistiu com nota gera atividade rated';
  update public.entries set rating = 4 where user_id = a and title_id = t;
  assert (select count(*) from public.activities where user_id = a) = 1, 'editar a nota em seguida não duplica (rajada)';
  assert (select (payload ->> 'rating')::numeric from public.activities where id = act) = 4, 'payload da atividade acompanha a edição';
  update public.entries set review = 'Melhor série.' where user_id = a and title_id = t;
  assert (select count(*) from public.activities where user_id = a and kind = 'reviewed') = 1, 'review gera atividade reviewed';
  begin
    insert into public.activities (user_id, kind) values (a, 'watched');
    raise exception 'cliente forjar atividade deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  perform tests.login_as(c);
  assert (select count(*) from public.feed) = 2, 'feed de C traz as 2 atividades de A';
  insert into public.likes (user_id, activity_id) values (c, act);
  insert into public.comments (activity_id, user_id, body) values (act, c, 'Concordo!');
  reset role;
  assert (select like_count from public.activities where id = act) = 1, 'like_count atualizado';
  assert (select comment_count from public.activities where id = act) = 1, 'comment_count atualizado';

  perform tests.login_as(a);
  assert (select count(*) from public.notifications where user_id = a and kind in ('follow', 'like', 'comment')) = 3, 'A tem 3 notificações (seguiu, curtiu, comentou)';
  delete from public.comments where activity_id = act;      -- dono da atividade modera
  get diagnostics n = row_count;
  assert n = 1, 'dono da atividade apaga comentário alheio';
  reset role;
  assert (select comment_count from public.activities where id = act) = 0, 'comment_count volta a 0';

  -- anon não lê nada
  perform tests.login_anon();
  begin
    perform count(*) from public.titles;
    raise exception 'anon ler titles deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  -- cota: teto 2 → terceira chamada recusa
  assert public.consume_api_quota('motn', 2) = true, 'cota 1/2';
  assert public.consume_api_quota('motn', 2) = true, 'cota 2/2';
  assert public.consume_api_quota('motn', 2) = false, 'cota estourada recusa';
  perform tests.login_as(a);
  begin
    perform count(*) from public.api_usage;
    raise exception 'cliente ler api_usage deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.consume_api_quota('motn', 10);
    raise exception 'cliente chamar consume_api_quota deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Listas, itens, check-ins e assinaturas
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; c uuid; t1 uuid; t2 uuid; l_pub uuid; l_priv uuid;
begin
  a := tests.create_user('a3@teste.local');
  c := tests.create_user('c3@teste.local');
  insert into public.titles (tmdb_id, media_type, title) values (155, 'movie', 'Batman: O Cavaleiro das Trevas') returning id into t1;
  insert into public.titles (tmdb_id, media_type, title) values (27205, 'movie', 'A Origem') returning id into t2;

  perform tests.login_as(a);
  insert into public.lists (user_id, name) values (a, 'Favoritos') returning id into l_pub;
  insert into public.lists (user_id, name, is_private) values (a, 'Secreta', true) returning id into l_priv;
  insert into public.list_items (list_id, title_id) values (l_pub, t1), (l_priv, t1);
  insert into public.checkins (user_id, title_id) values (a, t1);
  insert into public.user_subscriptions (user_id, provider_id, plan) values (a, 8, 'standard');
  reset role;
  assert (select count(*) from public.activities where user_id = a and kind = 'list_created') = 1, 'só lista pública gera atividade';

  perform tests.login_as(c);
  assert (select count(*) from public.lists where user_id = a) = 1, 'C vê só a lista pública';
  assert (select count(*) from public.list_items where list_id = l_priv) = 0, 'itens da lista privada escondidos';
  assert (select count(*) from public.list_items where list_id = l_pub) = 1, 'itens da lista pública visíveis';
  begin
    insert into public.list_items (list_id, title_id) values (l_pub, t2);
    raise exception 'C adicionar na lista de A deveria falhar';
  exception when insufficient_privilege then null;
  end;
  assert (select count(*) from public.checkins where user_id = a) = 1, 'check-in ativo visível';
  assert (select count(*) from public.user_subscriptions where user_id = a) = 0, 'assinaturas são só do dono';
  reset role;

  update public.checkins set expires_at = now() - interval '1 minute' where user_id = a;
  perform tests.login_as(c);
  assert (select count(*) from public.checkins where user_id = a) = 0, 'check-in expirado some';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. Virar público aceita pedidos; regras de formato (username, nota)
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid; t uuid; r record;
begin
  a := tests.create_user('a4@teste.local');
  b := tests.create_user('b4@teste.local');
  update public.profiles set is_private = true where id = b;
  insert into public.titles (tmdb_id, media_type, title) values (120, 'movie', 'O Senhor dos Anéis') returning id into t;

  perform tests.login_as(a);
  insert into public.follows (follower_id, followee_id) values (a, b);
  reset role;
  perform tests.login_as(b);
  update public.profiles set is_private = false where id = b;
  reset role;
  assert (select status from public.follows where follower_id = a and followee_id = b) = 'accepted', 'virar público aceita os pedidos pendentes';

  perform tests.login_as(a);
  select * into r from public.profile_counts(b);
  assert r.followers = 1, 'profile_counts conta o seguidor';
  begin
    update public.profiles set username = 'Ana Maria' where id = a;
    raise exception 'username com espaço/maiúscula deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.entries (user_id, title_id, status, rating) values (a, t, 'watched', 4.3);
    raise exception 'nota fora da meia estrela deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.entries (user_id, title_id, status, rating) values (a, t, 'want', 4);
    raise exception 'nota em "quero ver" deveria falhar';
  exception when check_violation then null;
  end;
  insert into public.entries (user_id, title_id, status, rating) values (a, t, 'watched', 4.5);
  insert into public.reports (reporter_id, target_type, target_id, reason) values (a, 'profile', b, 'spam');
  begin
    update public.reports set status = 'actioned' where reporter_id = a;
    raise exception 'denunciante alterar denúncia deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;
end $$;
