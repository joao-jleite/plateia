-- Testes de RLS da fase 07 (qual assinar). Rodam em `npm run db:test`, numa
-- transação desfeita no fim. Não há migração 0006: o schema da 0001 já tinha
-- `provider_prices` e `user_subscriptions`; o que muda é que o app passa a
-- ESCREVER em `user_subscriptions` (upsert, update, delete) e a ler
-- `provider_prices`, `title_availability` e `title_sync` para a conta. Este
-- arquivo é o que o app faz pelo PostgREST, com o JWT do usuário.
--
-- A numeração segue as fases (0005 = social), como nas anteriores.

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Minhas assinaturas: só eu leio, crio, edito e apago; upsert idempotente;
--    `updated_at` sobe por trigger; outro usuário não vê nem mexe; anon nada
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid;
  n int;
  before_ts timestamptz;
  after_ts timestamptz;
begin
  a := tests.create_user('s1a@teste.local');
  b := tests.create_user('s1b@teste.local');

  perform tests.login_as(a);
  -- marcar: Netflix padrão, renova em 10 dias, lembrete ligado (padrão)
  insert into public.user_subscriptions (user_id, provider_id, plan, renews_on)
    values (a, 8, 'standard', current_date + 10);
  -- upsert do app: mesma chave (user_id, provider_id) → vira update, não duplica
  insert into public.user_subscriptions (user_id, provider_id, plan, price_cents, renews_on, remind_before_renewal)
    values (a, 8, 'ads', 2090, current_date + 12, false)
    on conflict (user_id, provider_id) do update
      set plan = excluded.plan, price_cents = excluded.price_cents,
          renews_on = excluded.renews_on, remind_before_renewal = excluded.remind_before_renewal;
  assert (select count(*) from public.user_subscriptions where user_id = a) = 1, 'upsert não duplica a assinatura';
  assert (select plan from public.user_subscriptions where user_id = a and provider_id = 8) = 'ads', 'upsert atualizou o plano';
  assert (select remind_before_renewal from public.user_subscriptions where user_id = a and provider_id = 8) = false, 'upsert desligou o lembrete';
  assert (select remind_before_renewal from public.user_subscriptions where user_id = a) is not null, 'remind_before_renewal nunca é null';

  -- segunda assinatura e `updated_at` por trigger (dentro de uma transação
  -- `now()` é fixo, então aqui só dá para conferir que o trigger existe e que
  -- a coluna acompanha; o `>` real aparece entre requisições do app)
  insert into public.user_subscriptions (user_id, provider_id, plan, renews_on) values (a, 283, 'standard', current_date + 21);
  select updated_at into before_ts from public.user_subscriptions where user_id = a and provider_id = 283;
  update public.user_subscriptions set renews_on = current_date + 25 where user_id = a and provider_id = 283;
  select updated_at into after_ts from public.user_subscriptions where user_id = a and provider_id = 283;
  assert after_ts >= before_ts and after_ts is not null, 'updated_at acompanha a edição';
  assert exists (select 1 from pg_trigger where tgname = 'user_subscriptions_set_updated_at'), 'trigger de updated_at existe';

  -- embed que o app usa: a linha traz o streaming (FK para providers legível por authenticated)
  assert (select count(*) from public.user_subscriptions s join public.providers p on p.id = s.provider_id where s.user_id = a) = 2,
    'join com providers funciona para o dono';
  reset role;

  -- B não vê, não edita, não apaga e não cria em nome de A
  perform tests.login_as(b);
  assert (select count(*) from public.user_subscriptions) = 0, 'B não vê assinaturas de A';
  update public.user_subscriptions set plan = 'premium' where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não edita assinatura de A';
  delete from public.user_subscriptions where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não apaga assinatura de A';
  begin
    insert into public.user_subscriptions (user_id, provider_id, plan) values (a, 119, 'standard');
    raise exception 'B criar assinatura em nome de A deveria falhar';
  exception when insufficient_privilege then null;
  end;
  -- B marca a dele normalmente
  insert into public.user_subscriptions (user_id, provider_id, plan) values (b, 119, 'standard');
  assert (select count(*) from public.user_subscriptions) = 1, 'B vê só a dele';
  reset role;

  -- A apaga a própria (desmarcar)
  perform tests.login_as(a);
  delete from public.user_subscriptions where user_id = a and provider_id = 283;
  get diagnostics n = row_count;
  assert n = 1, 'dono apaga a própria assinatura';
  assert (select count(*) from public.user_subscriptions where user_id = a) = 1, 'sobrou só a Netflix';
  reset role;

  -- anon: nada
  set local role anon;
  begin
    perform count(*) from public.user_subscriptions;
    raise exception 'anon ler user_subscriptions deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Regras de formato: plano fora da lista, preço negativo e streaming
--    inexistente são recusados pelo banco (o app valida antes, o banco garante)
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid;
begin
  a := tests.create_user('s2a@teste.local');
  perform tests.login_as(a);
  begin
    insert into public.user_subscriptions (user_id, provider_id, plan) values (a, 8, 'familia');
    raise exception 'plano fora de ads/standard/premium deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.user_subscriptions (user_id, provider_id, plan, price_cents) values (a, 8, 'standard', -1);
    raise exception 'preço negativo deveria falhar';
  exception when check_violation then null;
  end;
  begin
    insert into public.user_subscriptions (user_id, provider_id, plan) values (a, 999999, 'standard');
    raise exception 'streaming inexistente deveria falhar';
  exception when foreign_key_violation then null;
  end;
  -- plano e preço são opcionais: dá para marcar só "assino"
  insert into public.user_subscriptions (user_id, provider_id) values (a, 337);
  assert (select plan from public.user_subscriptions where user_id = a and provider_id = 337) is null, 'plano opcional';
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Preços de tabela: todo logado lê (com a flag de estimativa e a data), mas
--    ninguém escreve pelo app (só o João, pelo dashboard = service_role/superuser)
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid;
  n int;
begin
  a := tests.create_user('s3a@teste.local');
  perform tests.login_as(a);
  assert (select count(*) from public.provider_prices) >= 15, 'logado lê os preços do seed';
  assert (select count(*) from public.provider_prices where is_estimate) >= 15, 'seed nasce como estimativa';
  assert (select count(*) from public.provider_prices where updated_at is null) = 0, 'todo preço tem data';
  -- um preço por (streaming, plano): a conta do app escolhe standard ou ads
  assert (select count(*) from public.provider_prices where provider_id = 8 and plan = 'standard') = 1, 'Netflix padrão existe';
  assert (select count(*) from public.provider_prices where provider_id = 8 and plan = 'ads') = 1, 'Netflix com anúncios existe';
  begin
    update public.provider_prices set price_cents = 1 where provider_id = 8 and plan = 'standard';
    raise exception 'logado alterar preço deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.provider_prices (provider_id, plan, plan_label, price_cents) values (8, 'premium', 'x', 1);
    raise exception 'logado inserir preço deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    delete from public.provider_prices where provider_id = 8;
    raise exception 'logado apagar preço deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  -- o João corrige pelo dashboard: a flag some e updated_at sobe sozinho
  update public.provider_prices set price_cents = 4490, is_estimate = false where provider_id = 8 and plan = 'standard';
  get diagnostics n = row_count;
  assert n = 1, 'superusuário (dashboard) corrige o preço';
  assert (select is_estimate from public.provider_prices where provider_id = 8 and plan = 'standard') = false, 'flag zerada';
  assert (select updated_at from public.provider_prices where provider_id = 8 and plan = 'standard') >= now() - interval '1 minute',
    'updated_at acompanha a correção (é a data que a tela mostra)';
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. A conta lê o cache: `title_sync` diz se "onde assistir" foi consultado
--    (sem linha = "sem dados"), `title_availability` dá as ofertas, e a variante
--    ("Netflix com anúncios") resolve para o principal pelo `parent_id`
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid;
  t_cached uuid; t_none uuid; t_nodata uuid;
begin
  a := tests.create_user('s4a@teste.local');
  -- a Edge Function (service_role) escreveu o cache
  insert into public.titles (tmdb_id, media_type, title) values (37854, 'tv', 'One Piece') returning id into t_cached;
  insert into public.titles (tmdb_id, media_type, title) values (598, 'movie', 'Cidade de Deus') returning id into t_none;
  insert into public.titles (tmdb_id, media_type, title, fetched_at) values (241259, 'tv', 'Bebê Rena', '1970-01-01') returning id into t_nodata;
  insert into public.title_sync (title_id, region, providers_fetched_at) values (t_cached, 'BR', now()), (t_none, 'BR', now());
  insert into public.title_availability (title_id, region, provider_id, offer_type) values
    (t_cached, 'BR', 8, 'flatrate'),
    (t_cached, 'BR', 1796, 'ads'),        -- Netflix com anúncios → parent 8
    (t_cached, 'BR', 283, 'flatrate');

  perform tests.login_as(a);
  -- quem foi consultado: 2 (One Piece e Cidade de Deus); Bebê Rena não tem linha → "sem dados"
  assert (select count(*) from public.title_sync where title_id in (t_cached, t_none, t_nodata) and providers_fetched_at is not null) = 2,
    'title_sync diz quem foi consultado';
  assert (select count(*) from public.title_sync where title_id = t_nodata) = 0, 'título importado e nunca aberto não tem title_sync';
  -- ofertas com o streaming principal resolvido
  assert (
    select count(distinct coalesce(p.parent_id, ta.provider_id))
    from public.title_availability ta join public.providers p on p.id = ta.provider_id
    where ta.title_id = t_cached and ta.offer_type in ('flatrate', 'ads')
  ) = 2, 'One Piece resolve para Netflix (8, com a variante 1796 agrupada) e Crunchyroll (283)';
  assert (select count(*) from public.title_availability where title_id = t_none) = 0, 'consultado e em nenhum streaming: zero ofertas';
  -- o app não escreve cache
  begin
    insert into public.title_sync (title_id, region, providers_fetched_at) values (t_nodata, 'BR', now());
    raise exception 'logado escrever title_sync deveria falhar';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.title_availability (title_id, region, provider_id, offer_type) values (t_nodata, 'BR', 8, 'flatrate');
    raise exception 'logado escrever title_availability deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;
end $$;
