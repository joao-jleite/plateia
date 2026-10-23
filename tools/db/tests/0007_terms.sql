-- Testes da fase 08 (release): aceite dos termos (migração 0006). Rodam em
-- `npm run db:test`, numa transação desfeita no fim. A numeração segue as
-- fases (0006 = qual assinar).

-- ────────────────────────────────────────────────────────────────────────────
-- 1. A coluna existe, o dono grava o aceite no próprio perfil, outro usuário
--    não consegue, e o cartão continua legível (a coluna não vaza nada sensível)
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid;
  n int;
begin
  assert exists (
    select 1 from information_schema.columns
     where table_schema = 'public' and table_name = 'profiles' and column_name = 'terms_accepted_at'
  ), 'profiles.terms_accepted_at existe (migração 0006)';

  a := tests.create_user('t1a@teste.local');
  b := tests.create_user('t1b@teste.local');

  -- o trigger do cadastro cria o perfil sem aceite
  assert (select terms_accepted_at from public.profiles where id = a) is null, 'perfil nasce sem aceite';

  -- o app, no passo 1 do onboarding, grava @ + aceite numa só escrita
  perform tests.login_as(a);
  update public.profiles
     set username = 'ana_terms', terms_accepted_at = now()
   where id = a;
  get diagnostics n = row_count;
  assert n = 1, 'dono grava o aceite';
  assert (select terms_accepted_at from public.profiles where id = a) is not null, 'aceite gravado';
  reset role;

  -- outro usuário não mexe no aceite alheio (policy "editar só o próprio")
  perform tests.login_as(b);
  update public.profiles set terms_accepted_at = null where id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não altera o aceite de A';
  -- e continua lendo o cartão de A normalmente
  assert (select count(*) from public.profiles where id = a) = 1, 'B lê o cartão de A';
  reset role;

  -- anon: nada
  set local role anon;
  begin
    perform count(*) from public.profiles;
    raise exception 'anon leu profiles';
  exception
    when insufficient_privilege then null;
  end;
  reset role;
end $$;
