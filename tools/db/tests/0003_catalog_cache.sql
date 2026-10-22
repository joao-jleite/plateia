-- Testes da fase 03: o SQL que as Edge Functions `catalog-title`, `home-sections`
-- e `providers-sync` executam como service_role (superusuário aqui), e o que o
-- app (authenticated) pode e não pode fazer com o cache. Roda em `npm run db:test`.

-- ────────────────────────────────────────────────────────────────────────────
-- 1. catalog-title: upsert do título, troca da disponibilidade preservando
--    deep_link, carimbo em title_sync, provider "lazy", cota da MOTN
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  t uuid;
  n int;
  v_link text;
  v_status text;
begin
  -- 1ª abertura: TMDB devolveu detalhe + onde assistir (Netflix, Crunchyroll, provider novo 9999)
  insert into public.titles (tmdb_id, media_type, title, original_title, genre_ids, genres, is_anime,
                             origin_country, original_language, episode_run_time, number_of_seasons,
                             seasons, cast_top, vote_average, imdb_id, fetched_at)
  values (37854, 'tv', 'One Piece', 'ワンピース', '{16,10759}', '{Animação,"Action & Adventure"}', true,
          '{JP}', 'ja', 24, 22,
          '[{"season_number":1,"name":"East Blue","episode_count":61}]'::jsonb,
          '[{"name":"Mayumi Tanaka","character":"Luffy"}]'::jsonb, 8.7, 'tt0388629', now())
  on conflict (tmdb_id, media_type) do update set title = excluded.title, fetched_at = excluded.fetched_at
  returning id into t;
  assert (select year from public.titles where id = t) is null, 'sem release_date o year fica null';
  update public.titles set release_date = '1999-10-20' where id = t;
  assert (select year from public.titles where id = t) = 1999, 'year é gerado da release_date';

  -- provider desconhecido entra "lazy" sem mexer nos conhecidos (ignoreDuplicates)
  insert into public.providers (id, name, logo_path, display_order) values
    (8, 'NOME ERRADO', '/x.jpg', 99), (9999, 'Novo Streaming', '/novo.jpg', 40)
  on conflict (id) do nothing;
  assert (select name from public.providers where id = 8) = 'Netflix', 'seed não é sobrescrito pelo lazy';
  assert (select name from public.providers where id = 9999) = 'Novo Streaming', 'provider novo criado';

  delete from public.title_availability where title_id = t and region = 'BR';
  insert into public.title_availability (title_id, region, provider_id, offer_type) values
    (t, 'BR', 8, 'flatrate'), (t, 'BR', 1796, 'ads'), (t, 'BR', 283, 'flatrate'), (t, 'BR', 9999, 'flatrate');
  insert into public.title_sync (title_id, region, providers_fetched_at)
  values (t, 'BR', now())
  on conflict (title_id, region) do update set providers_fetched_at = excluded.providers_fetched_at;

  -- links da MOTN (cota ok)
  assert public.consume_api_quota('motn', 900) = true, 'cota do mês tem espaço';
  update public.title_availability set deep_link = 'https://www.netflix.com/title/80107103', deep_link_source = 'motn', link_fetched_at = now()
   where title_id = t and region = 'BR' and provider_id in (8, 1796);
  update public.title_sync set links_fetched_at = now(), links_status = 'ok' where title_id = t and region = 'BR';
  assert (select calls from public.api_usage where api = 'motn' and period = date_trunc('month', now())::date) = 1, 'api_usage conta 1';

  -- renovação dos providers 8 dias depois: troca as linhas preservando o deep_link por (provider, tipo)
  create temp table prev on commit drop as
    select provider_id, offer_type, deep_link, deep_link_source, link_fetched_at
      from public.title_availability where title_id = t and region = 'BR';
  delete from public.title_availability where title_id = t and region = 'BR';
  insert into public.title_availability (title_id, region, provider_id, offer_type, deep_link, deep_link_source, link_fetched_at)
  select t, 'BR', n.provider_id, n.offer_type, p.deep_link, p.deep_link_source, p.link_fetched_at
    from (values (8, 'flatrate'), (283, 'flatrate')) as n(provider_id, offer_type)   -- 1796 e 9999 saíram
    left join prev p on p.provider_id = n.provider_id and p.offer_type = n.offer_type;
  select deep_link into v_link from public.title_availability where title_id = t and provider_id = 8 and offer_type = 'flatrate';
  assert v_link = 'https://www.netflix.com/title/80107103', 'deep_link preservado na renovação';
  assert (select count(*) from public.title_availability where title_id = t) = 2, 'linhas que saíram do TMDB somem';

  -- links_status aceita só os 4 valores
  begin
    update public.title_sync set links_status = 'maybe' where title_id = t;
    raise exception 'links_status inválido deveria falhar';
  exception when check_violation then null;
  end;
  update public.title_sync set links_status = 'quota' where title_id = t;
  select links_status into v_status from public.title_sync where title_id = t;
  assert v_status = 'quota', 'quota é status válido';

  -- deep_link_source só motn|tmdb
  begin
    update public.title_availability set deep_link_source = 'justwatch' where title_id = t and provider_id = 8;
    raise exception 'deep_link_source inválido deveria falhar';
  exception when check_violation then null;
  end;

  -- apagar o título leva disponibilidade e sync junto
  delete from public.titles where id = t;
  select count(*) into n from public.title_availability where title_id = t;
  assert n = 0, 'cascade em title_availability';
  select count(*) into n from public.title_sync where title_id = t;
  assert n = 0, 'cascade em title_sync';
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. home-sections e providers-sync: upsert por chave; o app só lê
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  u uuid;
  n int;
  v_fetched timestamptz;
begin
  insert into public.home_sections (key, region, payload, fetched_at) values
    ('trending_all', 'BR', '[{"tmdb_id":37854,"media_type":"tv","title":"One Piece"}]'::jsonb, now() - interval '7 hours'),
    ('new_on_8', 'BR', '[]'::jsonb, now() - interval '7 hours');
  -- renovação: upsert pela chave
  insert into public.home_sections (key, region, payload, fetched_at)
  values ('trending_all', 'BR', '[]'::jsonb, now())
  on conflict (key) do update set payload = excluded.payload, fetched_at = excluded.fetched_at;
  select fetched_at into v_fetched from public.home_sections where key = 'trending_all';
  assert v_fetched > now() - interval '1 minute', 'fetched_at renovado';

  -- providers-sync: logo de todos; nome só dos não destacados
  update public.providers set logo_path = '/netflix.jpg' where id = 8;
  insert into public.providers (id, name, logo_path, display_order) values (2, 'Apple TV', '/apple.jpg', 9)
  on conflict (id) do update set name = excluded.name, logo_path = excluded.logo_path, display_order = excluded.display_order;
  assert (select logo_path from public.providers where id = 8) = '/netflix.jpg', 'logo do destacado atualizado';
  assert (select updated_at from public.providers where id = 8) > now() - interval '1 minute', 'trigger set_updated_at';
  assert (select name from public.providers where id = 2) = 'Apple TV', 'provider não destacado entra com o nome do TMDB';

  -- o app lê tudo isso, mas não escreve
  u := tests.create_user('cache@teste.local');
  perform tests.login_as(u);
  select count(*) into n from public.home_sections;
  assert n = 2, 'authenticated lê home_sections';
  select count(*) into n from public.providers where is_featured;
  assert n = 8, 'authenticated lê os 8 destacados';
  begin
    insert into public.home_sections (key, payload) values ('hack', '[]'::jsonb);
    raise exception 'authenticated inserir em home_sections deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.providers set name = 'x' where id = 8;
    raise exception 'authenticated alterar providers deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.titles (tmdb_id, media_type, title) values (1, 'movie', 'x');
    raise exception 'authenticated inserir em titles deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    perform public.consume_api_quota('motn', 900);
    raise exception 'authenticated chamar consume_api_quota deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 3. onboarding: trocar o @ e fechar o onboarding (o que a tela de username faz)
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid;
  n int;
begin
  a := tests.create_user('ana@teste.local', '{"full_name": "Ana Souza"}');
  b := tests.create_user('bia@teste.local');
  perform tests.login_as(a);
  update public.profiles set username = 'ana_souza', display_name = 'Ana' where id = a;
  assert (select username from public.profiles where id = a) = 'ana_souza', 'troca de @';
  begin
    update public.profiles set username = 'Ana Souza' where id = a;
    raise exception '@ com maiúscula/espaço deveria falhar';
  exception when check_violation then null;
  end;
  -- checagem de disponibilidade: dá para ver que o @ de outra pessoa existe
  select count(*) into n from public.profiles where username = 'ana_souza';
  assert n = 1, 'busca por @ enxerga o cartão';
  update public.profiles set onboarded_at = now() where id = a;
  assert (select onboarded_at from public.profiles where id = a) is not null, 'onboarding fechado';
  reset role;

  perform tests.login_as(b);
  begin
    update public.profiles set username = 'ana_souza' where id = b;
    raise exception '@ repetido deveria falhar';
  exception when unique_violation then null;
  end;
  update public.profiles set username = 'roubado' where id = a;   -- RLS: 0 linhas
  get diagnostics n = row_count;
  assert n = 0, 'B não altera o perfil de A';
  reset role;
end $$;
