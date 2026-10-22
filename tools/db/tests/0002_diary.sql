-- Testes de RLS da fase 04 (perfil e diário). Rodam em `npm run db:test`, numa
-- transação desfeita no fim. Cobrem: posse do diário, privacidade do perfil
-- (diário e listas), lista privada, validações de nota/review, reassistir,
-- a view `entry_stats_rows` (migração 0003) e o tempo dela com 2 mil entradas.

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Outro usuário não lê diário privado nem altera/apaga/cria registro alheio
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid;
  t1 uuid; t2 uuid;
  n int;
begin
  a := tests.create_user('d1a@teste.local');
  b := tests.create_user('d1b@teste.local');
  insert into public.titles (tmdb_id, media_type, title) values (37854, 'tv', 'One Piece') returning id into t1;
  insert into public.titles (tmdb_id, media_type, title) values (598, 'movie', 'Cidade de Deus') returning id into t2;

  perform tests.login_as(a);
  insert into public.entries (user_id, title_id, status, rating, review, has_spoiler)
    values (a, t1, 'watched', 4.5, 'Luffy vira rei no fim', true);
  reset role;

  -- B (perfil de A é público) lê, mas não mexe
  perform tests.login_as(b);
  assert (select count(*) from public.entries where user_id = a) = 1, 'B lê o diário público de A';
  update public.entries set rating = 1, review = 'troll' where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não altera registro de A (RLS esconde a linha)';
  delete from public.entries where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não apaga registro de A';
  begin
    insert into public.entries (user_id, title_id, status) values (a, t2, 'want');
    raise exception 'inserir em nome de A deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  -- A fecha o perfil: B deixa de ver o diário, mas o cartão e os contadores continuam
  update public.profiles set is_private = true where id = a;
  perform tests.login_as(b);
  assert (select count(*) from public.entries where user_id = a) = 0, 'perfil privado esconde o diário de não seguidor';
  assert (select count(*) from public.profiles where id = a) = 1, 'o cartão do perfil privado continua visível';
  assert (select watched from public.profile_counts(a)) = 1, 'contadores aparecem mesmo em perfil privado';
  assert (select reviews from public.profile_counts(a)) = 1, 'contador de reviews conta a review de A';
  assert public.can_view_content(a) = false, 'can_view_content(a) é false para não seguidor';
  reset role;

  -- A continua vendo e editando o próprio diário
  perform tests.login_as(a);
  assert public.can_view_content(a) = true, 'dono sempre vê o próprio conteúdo';
  update public.entries set rating = 5 where user_id = a and title_id = t1;
  get diagnostics n = row_count;
  assert n = 1, 'A edita o próprio registro';
  delete from public.entries where user_id = a and title_id = t1;
  get diagnostics n = row_count;
  assert n = 1, 'A apaga o próprio registro (desmarcar)';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Perfil privado não vaza diário nem listas para não seguidor; seguidor
--    aceito vê o diário e as listas públicas, nunca a lista privada
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  v_owner uuid; v_follower uuid; v_stranger uuid;
  t1 uuid;
  l_pub uuid; l_priv uuid;
  n int;
begin
  v_owner    := tests.create_user('d2o@teste.local');
  v_follower := tests.create_user('d2f@teste.local');
  v_stranger := tests.create_user('d2s@teste.local');
  update public.profiles set is_private = true where id = v_owner;
  insert into public.titles (tmdb_id, media_type, title) values (872585, 'movie', 'Oppenheimer') returning id into t1;

  perform tests.login_as(v_owner);
  insert into public.entries (user_id, title_id, status, rating) values (v_owner, t1, 'watched', 4);
  insert into public.lists (user_id, name, is_private) values (v_owner, 'Favoritos', false) returning id into l_pub;
  insert into public.lists (user_id, name, is_private) values (v_owner, 'Segredos', true) returning id into l_priv;
  insert into public.list_items (list_id, title_id, position) values (l_pub, t1, 0), (l_priv, t1, 0);
  reset role;

  -- estranho: nada
  perform tests.login_as(v_stranger);
  assert (select count(*) from public.entries where user_id = v_owner) = 0, 'estranho não vê o diário privado';
  assert (select count(*) from public.lists where user_id = v_owner) = 0, 'estranho não vê lista nenhuma do perfil privado';
  assert (select count(*) from public.list_items where list_id in (l_pub, l_priv)) = 0, 'estranho não vê itens de lista do perfil privado';
  assert (select count(*) from public.entry_stats_rows where user_id = v_owner) = 0, 'estranho não vê estatísticas do perfil privado';
  assert (select lists from public.profile_counts(v_owner)) = 1, 'contador de listas só conta a pública para terceiros';
  reset role;

  -- seguidor pede e o dono aceita
  perform tests.login_as(v_follower);
  insert into public.follows (follower_id, followee_id) values (v_follower, v_owner);
  reset role;
  perform tests.login_as(v_owner);
  update public.follows set status = 'accepted' where follower_id = v_follower and followee_id = v_owner;
  get diagnostics n = row_count;
  assert n = 1, 'dono aceitou o pedido';
  assert (select lists from public.profile_counts(v_owner)) = 2, 'dono conta as próprias listas privadas';
  reset role;

  perform tests.login_as(v_follower);
  assert (select count(*) from public.entries where user_id = v_owner) = 1, 'seguidor aceito vê o diário privado';
  assert (select count(*) from public.entry_stats_rows where user_id = v_owner) = 1, 'seguidor aceito vê as estatísticas';
  assert (select count(*) from public.lists where user_id = v_owner) = 1, 'seguidor vê só a lista pública';
  assert (select count(*) from public.lists where id = l_priv) = 0, 'lista privada não vaza nem para seguidor';
  assert (select count(*) from public.list_items where list_id = l_pub) = 1, 'seguidor vê itens da lista pública';
  assert (select count(*) from public.list_items where list_id = l_priv) = 0, 'itens da lista privada não vazam para seguidor';
  -- seguidor não mexe na lista alheia
  begin
    insert into public.list_items (list_id, title_id, position) values (l_pub, t1, 1);
    raise exception 'adicionar item na lista de outro deveria falhar';
  exception when insufficient_privilege or unique_violation then null;
  end;
  update public.lists set name = 'hackeada' where id = l_pub;
  get diagnostics n = row_count;
  assert n = 0, 'seguidor não renomeia lista alheia';
  delete from public.list_items where list_id = l_pub;
  get diagnostics n = row_count;
  assert n = 0, 'seguidor não remove item de lista alheia';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Validações do diário: nota 4,3, nota/review em "quero ver", limites;
--    reassistir soma watch_count; uma linha por usuário×título
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; t1 uuid; t2 uuid;
  e uuid;
  n int;
begin
  a := tests.create_user('d3a@teste.local');
  insert into public.titles (tmdb_id, media_type, title) values (693134, 'movie', 'Duna: Parte Dois') returning id into t1;
  insert into public.titles (tmdb_id, media_type, title) values (66732, 'tv', 'Stranger Things') returning id into t2;
  perform tests.login_as(a);

  begin
    insert into public.entries (user_id, title_id, status, rating) values (a, t1, 'watched', 4.3);
    raise exception 'nota 4,3 deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.entries (user_id, title_id, status, rating) values (a, t1, 'watched', 0);
    raise exception 'nota 0 deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.entries (user_id, title_id, status, rating) values (a, t1, 'watched', 5.5);
    raise exception 'nota 5,5 deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.entries (user_id, title_id, status, rating) values (a, t1, 'want', 4);
    raise exception 'nota em "quero ver" deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.entries (user_id, title_id, status, review) values (a, t1, 'want', 'ainda não vi');
    raise exception 'review em "quero ver" deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.entries (user_id, title_id, status, review) values (a, t1, 'watched', repeat('x', 5001));
    raise exception 'review com 5.001 caracteres deveria falhar';
  exception when check_violation then null;
  end;

  -- meias estrelas válidas nos extremos
  insert into public.entries (user_id, title_id, status, rating) values (a, t1, 'watched', 0.5) returning id into e;
  update public.entries set rating = 5 where id = e;
  get diagnostics n = row_count;
  assert n = 1, 'nota 5 aceita';

  -- "quero ver" → "assisti" com nota, mesma linha (upsert pela unique)
  insert into public.entries (user_id, title_id, status) values (a, t2, 'want');
  insert into public.entries (user_id, title_id, status, rating, watched_at)
    values (a, t2, 'watched', 3.5, current_date)
    on conflict (user_id, title_id) do update
      set status = excluded.status, rating = excluded.rating, watched_at = excluded.watched_at;
  assert (select count(*) from public.entries where user_id = a and title_id = t2) = 1, 'uma linha por usuário×título';
  assert (select status from public.entries where user_id = a and title_id = t2) = 'watched', 'upsert trocou o status';

  -- reassistir: watch_count sobe e a data atualiza
  update public.entries set watch_count = watch_count + 1, watched_at = current_date where id = e;
  assert (select watch_count from public.entries where id = e) = 2, 'reassistir soma watch_count';
  begin
    update public.entries set watch_count = 0 where id = e;
    raise exception 'watch_count 0 deveria falhar';
  exception when check_violation then null;
  end;

  -- voltar para "quero ver" com nota guardada é recusado: o app limpa nota e review antes
  begin
    update public.entries set status = 'want' where id = e;
    raise exception 'quero ver com nota deveria falhar';
  exception when check_violation then null;
  end;
  update public.entries set status = 'want', rating = null, review = null where id = e;
  get diagnostics n = row_count;
  assert n = 1, 'quero ver sem nota/review aceito';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. entry_stats_rows: linha magra por entrada, providers agrupados pela marca,
--    privacidade herdada; 2.000 entradas lidas em menos de 1 s
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid;
  t_anime uuid; t_movie uuid;
  v_providers integer[];
  t0 timestamptz; ms numeric;
  n int;
begin
  a := tests.create_user('d4a@teste.local');
  b := tests.create_user('d4b@teste.local');
  insert into public.titles (tmdb_id, media_type, title, genres, release_date, episode_run_time, number_of_episodes)
    values (31910, 'tv', 'Naruto Shippuden', '{Animação,"Action & Adventure"}', '2007-02-15', 24, 500) returning id into t_anime;
  insert into public.titles (tmdb_id, media_type, title, genres, release_date, runtime_minutes)
    values (155, 'movie', 'Batman: O Cavaleiro das Trevas', '{Drama,Ação}', '2008-07-16', 152) returning id into t_movie;
  -- Netflix (8) + Netflix com anúncios (1796, parent 8) + Crunchyroll (283) + Apple só aluguel (não conta)
  insert into public.title_availability (title_id, region, provider_id, offer_type) values
    (t_anime, 'BR', 8, 'flatrate'), (t_anime, 'BR', 1796, 'ads'), (t_anime, 'BR', 283, 'flatrate'),
    (t_movie, 'BR', 350, 'rent'), (t_movie, 'US', 8, 'flatrate');

  perform tests.login_as(a);
  insert into public.entries (user_id, title_id, status, episodes_watched, watch_count) values (a, t_anime, 'watching', 100, 1);
  insert into public.entries (user_id, title_id, status, watch_count) values (a, t_movie, 'watched', 2);

  select provider_ids into v_providers from public.entry_stats_rows where user_id = a and media_type = 'tv';
  assert v_providers = '{8,283}'::integer[], format('providers da série agrupados pela marca, veio %s', v_providers);
  select provider_ids into v_providers from public.entry_stats_rows where user_id = a and media_type = 'movie';
  assert v_providers = '{}'::integer[], 'aluguel e outra região não contam como streaming';
  assert (select episode_run_time * episodes_watched from public.entry_stats_rows where user_id = a and media_type = 'tv') = 2400,
    'a view traz o que o app precisa para as horas (24 min × 100 ep)';
  assert (select year from public.entry_stats_rows where user_id = a and media_type = 'movie') = 2008, 'year vem do título';
  reset role;

  -- privacidade herdada de entries
  update public.profiles set is_private = true where id = a;
  perform tests.login_as(b);
  assert (select count(*) from public.entry_stats_rows where user_id = a) = 0, 'view não vaza estatística de perfil privado';
  begin
    insert into public.entry_stats_rows (user_id, entry_id, status, watch_count) values (b, gen_random_uuid(), 'watched', 1);
    raise exception 'escrever na view deveria falhar';
  exception when insufficient_privilege or feature_not_supported or object_not_in_prerequisite_state then null;
  end;
  reset role;

  -- 2.000 entradas (importação, para não gerar 2.000 atividades) e o tempo da leitura
  insert into public.titles (tmdb_id, media_type, title, genres, release_date, runtime_minutes)
    select 9000000 + g, 'movie', 'Filme ' || g, '{Drama}', date '2000-01-01' + (g % 9000)::int, 90 + (g % 60)
      from generate_series(1, 2000) g;
  insert into public.title_availability (title_id, region, provider_id, offer_type)
    select t.id, 'BR', (array[8, 119, 337, 1899, 307])[1 + (t.tmdb_id % 5)], 'flatrate'
      from public.titles t where t.tmdb_id >= 9000000;
  insert into public.entries (user_id, title_id, status, source, watched_at)
    select b, t.id, 'watched', 'netflix_import', date '2024-01-01' + (t.tmdb_id % 700)::int
      from public.titles t where t.tmdb_id >= 9000000;

  perform tests.login_as(b);
  t0 := clock_timestamp();
  select count(*) into n from public.entry_stats_rows where user_id = b;
  ms := extract(epoch from clock_timestamp() - t0) * 1000;
  assert n = 2000, format('2.000 linhas na view, veio %s', n);
  assert ms < 1000, format('leitura da view com 2.000 entradas levou %s ms (limite 1.000)', round(ms));
  raise notice '[0002_diary] entry_stats_rows com 2.000 entradas: % ms', round(ms);
  reset role;
end $$;
