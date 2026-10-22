-- ============================================================================
-- Stub LOCAL do ambiente Supabase (só para `npm run db:test`; nunca vai para o
-- projeto real). Reproduz o mínimo que as migrações e os testes de RLS usam:
--   • roles anon / authenticated / service_role (+ authenticator)
--   • schema auth com auth.users, auth.uid(), auth.jwt(), auth.role()
--   • schema storage com buckets/objects e storage.foldername()
--   • schema extensions com pgcrypto e uuid-ossp
--   • privilégios padrão iguais aos do Supabase (grant all para os 3 roles)
--   • schema tests com helpers para "logar" como um usuário dentro de um teste
-- Fonte: supabase/postgres (init scripts) e docs de RLS. Mantido enxuto de
-- propósito; se uma migração futura usar algo do Supabase que falte aqui,
-- acrescente aqui, não na migração.
-- ============================================================================

-- ---------- roles ----------
do $$
begin
  if not exists (select 1 from pg_roles where rolname = 'anon') then
    create role anon nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticated') then
    create role authenticated nologin noinherit;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'service_role') then
    -- service_role ignora RLS, como no Supabase (é o que as Edge Functions usam)
    create role service_role nologin noinherit bypassrls;
  end if;
  if not exists (select 1 from pg_roles where rolname = 'authenticator') then
    create role authenticator noinherit login password 'postgres';
  end if;
end $$;
grant anon, authenticated, service_role to authenticator;
-- o superusuário local precisa poder "virar" os roles nos testes (SET ROLE)
grant anon, authenticated, service_role to postgres;

-- ---------- schemas ----------
create schema if not exists auth;
create schema if not exists storage;
create schema if not exists extensions;
grant usage on schema public, auth, storage, extensions to anon, authenticated, service_role;

create extension if not exists pgcrypto with schema extensions;
create extension if not exists "uuid-ossp" with schema extensions;

-- search_path igual ao do Supabase (public e extensions visíveis sem prefixo)
alter database postgres set search_path = "$user", public, extensions;
set search_path = "$user", public, extensions;

-- ---------- privilégios padrão (como o Supabase faz para o role postgres) ----------
alter default privileges in schema public grant all on tables    to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges in schema public grant all on sequences to postgres, anon, authenticated, service_role;

-- ---------- auth ----------
create table if not exists auth.users (
  id                 uuid primary key default gen_random_uuid(),
  email              text unique,
  phone              text,
  raw_user_meta_data jsonb not null default '{}'::jsonb,   -- Google manda full_name, avatar_url, picture…
  raw_app_meta_data  jsonb not null default '{}'::jsonb,
  created_at         timestamptz not null default now(),
  updated_at         timestamptz not null default now()
);
grant select on auth.users to service_role;

-- Implementação igual à do Supabase: lê o claim 'sub' do JWT (settings da sessão).
create or replace function auth.uid() returns uuid
language sql stable as $$
  select nullif(
    coalesce(
      current_setting('request.jwt.claim.sub', true),
      (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'sub')
    ),
    ''
  )::uuid
$$;

create or replace function auth.role() returns text
language sql stable as $$
  select nullif(
    coalesce(
      current_setting('request.jwt.claim.role', true),
      (nullif(current_setting('request.jwt.claims', true), '')::jsonb ->> 'role')
    ),
    ''
  )::text
$$;

create or replace function auth.jwt() returns jsonb
language sql stable as $$
  select coalesce(
    nullif(current_setting('request.jwt.claim', true), ''),
    nullif(current_setting('request.jwt.claims', true), '')
  )::jsonb
$$;
grant execute on function auth.uid(), auth.role(), auth.jwt() to anon, authenticated, service_role;

-- ---------- storage ----------
create table if not exists storage.buckets (
  id                 text primary key,
  name               text not null unique,
  owner              uuid,
  public             boolean default false,
  file_size_limit    bigint,
  allowed_mime_types text[],
  created_at         timestamptz default now(),
  updated_at         timestamptz default now()
);
create table if not exists storage.objects (
  id               uuid primary key default gen_random_uuid(),
  bucket_id        text references storage.buckets(id),
  name             text,
  owner            uuid,
  owner_id         text,
  metadata         jsonb,
  path_tokens      text[] generated always as (string_to_array(name, '/')) stored,
  version          text,
  created_at       timestamptz default now(),
  updated_at       timestamptz default now(),
  last_accessed_at timestamptz default now()
);
-- No Supabase as duas tabelas já vêm com RLS ligado e sem policy.
alter table storage.buckets enable row level security;
alter table storage.objects enable row level security;
grant all on storage.buckets, storage.objects to anon, authenticated, service_role;

-- pastas do caminho, sem o nome do arquivo: 'uid/avatar.png' -> {uid}
create or replace function storage.foldername(name text) returns text[]
language plpgsql immutable as $$
declare parts text[];
begin
  select string_to_array(name, '/') into parts;
  return parts[1 : array_length(parts, 1) - 1];
end $$;
create or replace function storage.filename(name text) returns text
language plpgsql immutable as $$
declare parts text[];
begin
  select string_to_array(name, '/') into parts;
  return parts[array_length(parts, 1)];
end $$;
create or replace function storage.extension(name text) returns text
language plpgsql immutable as $$
declare fname text; parts text[];
begin
  fname := storage.filename(name);
  select string_to_array(fname, '.') into parts;
  return parts[array_length(parts, 1)];
end $$;

-- ---------- helpers de teste (só existem aqui) ----------
create schema if not exists tests;
grant usage on schema tests to anon, authenticated, service_role;
alter default privileges in schema tests grant execute on functions to anon, authenticated, service_role;

-- Cria um usuário no auth.users (dispara o trigger que cria o profile).
create or replace function tests.create_user(p_email text, p_meta jsonb default '{}'::jsonb) returns uuid
language plpgsql as $$
declare v_id uuid;
begin
  insert into auth.users (email, raw_user_meta_data) values (p_email, p_meta) returning id into v_id;
  return v_id;
end $$;

-- "Loga" como o usuário dentro da transação atual: claims do JWT + role authenticated.
-- Volte ao superusuário com `reset role;` antes de logar como outro.
create or replace function tests.login_as(p_user uuid) returns void
language plpgsql as $$
begin
  perform set_config('request.jwt.claims',
                     json_build_object('sub', p_user, 'role', 'authenticated')::text, true);
  perform set_config('role', 'authenticated', true);
end $$;

-- Como anon (sem usuário).
create or replace function tests.login_anon() returns void
language plpgsql as $$
begin
  perform set_config('request.jwt.claims', json_build_object('role', 'anon')::text, true);
  perform set_config('role', 'anon', true);
end $$;
