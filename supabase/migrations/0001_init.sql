-- ============================================================================
-- 0001_init.sql · Plateia (codinome) · fase 02 · 2026-10-22
--
-- Schema completo do MVP. Regras desta migração (e das próximas):
--   • identificadores em inglês, comentários em PT-BR;
--   • "enums" são text + CHECK (fácil de evoluir com ALTER CONSTRAINT; enum do
--     Postgres não aceita remover valor e complica migração em transação);
--   • RLS ligado em TODA tabela; uma policy por operação, cada uma comentada;
--   • o app é só para gente logada: anon não tem nenhum privilégio aqui;
--   • service_role (Edge Functions) ignora RLS por natureza: é quem escreve nas
--     tabelas de cache (titles, title_availability, providers…);
--   • funções SECURITY DEFINER sempre com `set search_path = ''` e nomes
--     qualificados (recomendação do linter do Supabase);
--   • nunca editar esta migração depois de aplicada: criar 0002, 0003…
--
-- Ordem: tabelas-base (profiles, blocks, follows) → funções de visibilidade →
-- catálogo/cache → conteúdo do usuário → social → grants → policies → triggers →
-- seeds (providers, provider_prices).
-- ============================================================================


-- ────────────────────────────────────────────────────────────────────────────
-- 0. Utilitário: updated_at automático
-- ────────────────────────────────────────────────────────────────────────────
create or replace function public.set_updated_at() returns trigger
language plpgsql set search_path = '' as $$
begin
  new.updated_at := now();
  return new;
end $$;


-- ────────────────────────────────────────────────────────────────────────────
-- 1. profiles · um por usuário do auth.users, criado por trigger no cadastro
-- ────────────────────────────────────────────────────────────────────────────
create table public.profiles (
  id            uuid primary key references auth.users(id) on delete cascade,
  -- @ público: minúsculas, dígitos e _, 3–20 chars. O trigger cria um provisório
  -- (u_ + 10 hex do id) e o onboarding pede a troca.
  username      text not null unique check (username ~ '^[a-z0-9_]{3,20}$'),
  display_name  text check (char_length(display_name) <= 50),
  bio           text check (char_length(bio) <= 280),
  avatar_url    text,
  -- perfil privado: o cartão (username, nome, foto, bio, contadores) continua
  -- visível a todos; o CONTEÚDO (diário, listas, atividades) só para seguidores aceitos
  is_private    boolean not null default false,
  -- região usada para "onde assistir"; MVP só BR, mas a coluna evita migração depois
  region        text not null default 'BR' check (region ~ '^[A-Z]{2}$'),
  -- preenchido quando a pessoa termina o onboarding (escolheu @, importou ou pulou)
  onboarded_at  timestamptz,
  created_at    timestamptz not null default now(),
  updated_at    timestamptz not null default now()
);
comment on table public.profiles is 'Perfil público do usuário (1:1 com auth.users). Privacidade vale para o conteúdo, não para o cartão.';

-- ────────────────────────────────────────────────────────────────────────────
-- 2. blocks · bloqueio é assimétrico na escrita, simétrico no efeito
-- ────────────────────────────────────────────────────────────────────────────
create table public.blocks (
  blocker_id  uuid not null references public.profiles(id) on delete cascade,
  blocked_id  uuid not null references public.profiles(id) on delete cascade,
  created_at  timestamptz not null default now(),
  primary key (blocker_id, blocked_id),
  check (blocker_id <> blocked_id)
);
create index blocks_blocked_idx on public.blocks (blocked_id);
comment on table public.blocks is 'Quem bloqueou quem. Bloqueado não sabe que foi bloqueado (não lê a linha).';

-- ────────────────────────────────────────────────────────────────────────────
-- 3. follows · relação assimétrica (Letterboxd); perfil privado gera pedido
-- ────────────────────────────────────────────────────────────────────────────
create table public.follows (
  follower_id  uuid not null references public.profiles(id) on delete cascade,
  followee_id  uuid not null references public.profiles(id) on delete cascade,
  -- definido pelo trigger a partir de profiles.is_private do seguido; o cliente não escolhe
  status       text not null default 'pending' check (status in ('pending', 'accepted')),
  created_at   timestamptz not null default now(),
  accepted_at  timestamptz,
  primary key (follower_id, followee_id),
  check (follower_id <> followee_id)
);
create index follows_followee_accepted_idx on public.follows (followee_id) where status = 'accepted';
create index follows_followee_pending_idx  on public.follows (followee_id) where status = 'pending';
comment on table public.follows is 'A segue B. status=pending enquanto B (privado) não aceita.';


-- ────────────────────────────────────────────────────────────────────────────
-- 4. Funções de visibilidade (usadas pelas policies)
--    SECURITY DEFINER porque precisam ler blocks/follows/profiles por inteiro,
--    coisa que o usuário comum não pode (ele não vê quem o bloqueou).
-- ────────────────────────────────────────────────────────────────────────────

-- Há bloqueio em qualquer direção entre a e b?
create or replace function public.is_blocked_between(a uuid, b uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.blocks k
     where (k.blocker_id = a and k.blocked_id = b)
        or (k.blocker_id = b and k.blocked_id = a)
  )
$$;

-- follower segue followee (aceito)?
create or replace function public.is_following(follower uuid, followee uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select exists (
    select 1 from public.follows f
     where f.follower_id = follower and f.followee_id = followee and f.status = 'accepted'
  )
$$;

-- Posso ver o CARTÃO do perfil (username, foto, bio)? Sim, salvo bloqueio.
create or replace function public.can_view_profile(target uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select auth.uid() is not null
     and (target = auth.uid() or not public.is_blocked_between(auth.uid(), target))
$$;

-- Posso ver o CONTEÚDO de owner (diário, listas públicas, atividades, check-ins)?
-- Dono sempre; bloqueio nunca; perfil público sim; perfil privado só seguidor aceito.
create or replace function public.can_view_content(owner uuid) returns boolean
language sql stable security definer set search_path = '' as $$
  select case
    when auth.uid() is null then false
    when owner = auth.uid() then true
    when public.is_blocked_between(auth.uid(), owner) then false
    else exists (
      select 1 from public.profiles p
       where p.id = owner
         and (not p.is_private or public.is_following(auth.uid(), owner))
    )
  end
$$;


-- ────────────────────────────────────────────────────────────────────────────
-- 5. Catálogo e cache (escrita só pelas Edge Functions / service_role)
-- ────────────────────────────────────────────────────────────────────────────

-- Streamings. id = provider_id do TMDB, porque "onde está" vem do TMDB.
create table public.providers (
  id                   integer primary key,
  -- slug estável só para os destacados (netflix, max, disney, prime, globoplay, apple, paramount, crunchyroll)
  slug                 text unique check (slug ~ '^[a-z0-9_]{2,30}$'),
  name                 text not null,
  logo_path            text,            -- logo_path do TMDB (prefixar com a base de imagens)
  motn_id              text,            -- id do serviço na Streaming Availability (fonte do deep link)
  android_package      text,            -- pacote do app no celular (assetlinks, fase 01)
  web_domain           text,            -- domínio que declara assetlinks.json
  search_url_template  text,            -- URL de busca com {q}; null = sem busca (Disney+)
  is_featured          boolean not null default false,  -- entra nos filtros e em "qual assinar"
  display_order        smallint,
  -- variantes ("Netflix com anúncios") apontam para o principal, para a interface agrupar
  parent_id            integer references public.providers(id),
  active               boolean not null default true,
  updated_at           timestamptz not null default now()
);
comment on table public.providers is 'Streamings (id do TMDB). Os destacados vêm no seed; o resto a Edge Function providers-sync preenche.';

-- Preços de assinatura, editados pelo João no dashboard. updated_at aparece na tela.
create table public.provider_prices (
  provider_id  integer not null references public.providers(id) on delete cascade,
  plan         text not null check (plan in ('ads', 'standard', 'premium')),
  plan_label   text not null,                     -- "Padrão com anúncios"
  price_cents  integer not null check (price_cents >= 0),
  currency     text not null default 'BRL' check (currency ~ '^[A-Z]{3}$'),
  is_estimate  boolean not null default true,     -- true até o João conferir no site do streaming
  source_url   text,
  updated_at   timestamptz not null default now(),
  primary key (provider_id, plan)
);
comment on table public.provider_prices is 'Preço mensal por plano. is_estimate=true enquanto não conferido.';

-- Cache do TMDB. Um título é (tmdb_id, media_type); o id interno é uuid para as FKs.
create table public.titles (
  id                  uuid primary key default gen_random_uuid(),
  tmdb_id             bigint not null,
  media_type          text not null check (media_type in ('movie', 'tv')),
  title               text not null,            -- nome em pt-BR (ou original, se o TMDB não tiver)
  original_title      text,
  overview            text,
  poster_path         text,
  backdrop_path       text,
  release_date        date,
  year                smallint generated always as (extract(year from release_date)::smallint) stored,
  genre_ids           smallint[] not null default '{}',
  genres              text[] not null default '{}',   -- nomes em pt-BR, para estatísticas por gênero
  -- anime = Animação (16) + origem JP / idioma ja; decidido pela Edge Function
  is_anime            boolean not null default false,
  origin_country      text[] not null default '{}',
  original_language   text,
  runtime_minutes     smallint,                 -- filme
  episode_run_time    smallint,                 -- série: duração média do episódio (horas assistidas)
  number_of_seasons   smallint,
  number_of_episodes  smallint,
  -- [{season_number, name, episode_count, air_date, poster_path}] para progresso de série
  seasons             jsonb,
  -- elenco principal, até 10: [{name, character, profile_path}] (tela de detalhe)
  cast_top            jsonb,
  status              text,                     -- status do TMDB (Returning Series, Ended, Released…)
  vote_average        numeric(3,1),
  popularity          real,
  imdb_id             text,
  fetched_at          timestamptz not null default now(),   -- detalhe renovado a cada 30 dias
  created_at          timestamptz not null default now(),
  unique (tmdb_id, media_type)
);
create index titles_title_lower_idx on public.titles (lower(title));
comment on table public.titles is 'Cache de títulos do TMDB (pt-BR). Só a Edge Function escreve.';

-- "Onde assistir": uma linha por (título, região, streaming, tipo de oferta).
create table public.title_availability (
  title_id          uuid not null references public.titles(id) on delete cascade,
  region            text not null default 'BR' check (region ~ '^[A-Z]{2}$'),
  provider_id       integer not null references public.providers(id),
  -- flatrate = assinatura; ads = assinatura com anúncios; free = grátis; rent/buy = à parte
  offer_type        text not null check (offer_type in ('flatrate', 'ads', 'free', 'rent', 'buy')),
  deep_link         text,                    -- link que abre o app (Streaming Availability); null = plano B (busca)
  deep_link_source  text check (deep_link_source in ('motn', 'tmdb')),
  price_cents       integer check (price_cents >= 0),   -- aluguel/compra, quando a fonte informa
  fetched_at        timestamptz not null default now(),
  link_fetched_at   timestamptz,
  primary key (title_id, region, provider_id, offer_type)
);
create index title_availability_provider_idx on public.title_availability (provider_id, region)
  where offer_type in ('flatrate', 'ads');
comment on table public.title_availability is 'Cache de disponibilidade por título/região/streaming. TMDB diz onde; MOTN dá o link.';

-- Quando cada título foi consultado nas APIs externas (mesmo que a resposta tenha vindo vazia).
create table public.title_sync (
  title_id              uuid not null references public.titles(id) on delete cascade,
  region                text not null default 'BR' check (region ~ '^[A-Z]{2}$'),
  providers_fetched_at  timestamptz,       -- TMDB watch/providers (TTL 7 dias)
  links_fetched_at      timestamptz,       -- Streaming Availability (TTL 7 dias)
  links_status          text check (links_status in ('ok', 'not_found', 'quota', 'error')),
  primary key (title_id, region)
);
comment on table public.title_sync is 'Carimbo de atualização do cache de disponibilidade, por título e região.';

-- Seções da tela Início ("em alta", "novidades na Netflix"…), renovadas a cada 6 h.
create table public.home_sections (
  key         text primary key,                          -- trending_all, new_on_8 (provider id)…
  region      text not null default 'BR' check (region ~ '^[A-Z]{2}$'),
  payload     jsonb not null,                            -- [{tmdb_id, media_type, title, poster_path, year}]
  fetched_at  timestamptz not null default now()
);
comment on table public.home_sections is 'Cache das listas da tela Início. Só a Edge Function escreve.';

-- Contador mensal de chamadas às APIs externas (cota). Nenhum cliente acessa.
create table public.api_usage (
  api         text not null check (api in ('tmdb', 'motn')),
  period      date not null,                 -- primeiro dia do mês
  calls       integer not null default 0,
  updated_at  timestamptz not null default now(),
  primary key (api, period)
);
comment on table public.api_usage is 'Cota mensal por API externa. Só as Edge Functions (service_role) usam. [no-client-access]';

-- Consome 1 chamada da cota do mês se ainda couber em p_cap; devolve false quando estourou.
-- Atômico (um UPSERT), para várias Edge Functions concorrentes não passarem do teto.
create or replace function public.consume_api_quota(p_api text, p_cap integer) returns boolean
language plpgsql security definer set search_path = '' as $$
declare v_calls integer;
begin
  insert into public.api_usage (api, period, calls)
  values (p_api, date_trunc('month', now())::date, 1)
  on conflict (api, period) do update
     set calls = public.api_usage.calls + 1, updated_at = now()
   where public.api_usage.calls < p_cap
  returning calls into v_calls;
  return v_calls is not null;
end $$;


-- ────────────────────────────────────────────────────────────────────────────
-- 6. Conteúdo do usuário
-- ────────────────────────────────────────────────────────────────────────────

-- Diário: UMA linha por (usuário, título). Status é o estado atual; nota e review
-- ficam aqui; reassistir incrementa watch_count. Isso torna a importação idempotente
-- (upsert na unique) e simplifica perfil e estatísticas.
create table public.entries (
  id                uuid primary key default gen_random_uuid(),
  user_id           uuid not null references public.profiles(id) on delete cascade,
  title_id          uuid not null references public.titles(id) on delete cascade,
  status            text not null check (status in ('watched', 'watching', 'want')),
  -- 0,5 a 5 em meias estrelas
  rating            numeric(2,1) check (rating >= 0.5 and rating <= 5 and (rating * 2) = floor(rating * 2)),
  review            text check (char_length(review) <= 5000),
  has_spoiler       boolean not null default false,
  watched_at        date,                       -- data que a pessoa informou (ou a do CSV)
  current_season    smallint check (current_season >= 0),     -- série em andamento
  current_episode   smallint check (current_episode >= 0),
  episodes_watched  smallint check (episodes_watched >= 0),   -- para horas assistidas (importação preenche)
  watch_count       smallint not null default 1 check (watch_count >= 1),
  source            text not null default 'manual' check (source in ('manual', 'netflix_import')),
  created_at        timestamptz not null default now(),
  updated_at        timestamptz not null default now(),
  unique (user_id, title_id),
  -- "quero ver" não tem nota nem review
  check (status <> 'want' or (rating is null and review is null))
);
create index entries_user_status_idx  on public.entries (user_id, status, updated_at desc);
create index entries_title_idx        on public.entries (title_id);
create index entries_user_watched_idx on public.entries (user_id, watched_at desc) where status = 'watched';
comment on table public.entries is 'Diário: assisti / assistindo / quero ver, com nota e review. Uma linha por usuário×título.';

create table public.lists (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,
  name         text not null check (char_length(name) between 1 and 100),
  description  text check (char_length(description) <= 1000),
  is_private   boolean not null default false,
  is_ranked    boolean not null default false,  -- mostra a posição (1., 2., 3.)
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index lists_user_idx on public.lists (user_id, updated_at desc);
comment on table public.lists is 'Listas do usuário. Privada = só o dono vê; pública segue a privacidade do perfil.';

create table public.list_items (
  list_id   uuid not null references public.lists(id) on delete cascade,
  title_id  uuid not null references public.titles(id) on delete cascade,
  position  integer not null default 0,
  note      text check (char_length(note) <= 500),
  added_at  timestamptz not null default now(),
  primary key (list_id, title_id)
);
comment on table public.list_items is 'Títulos de uma lista. Visibilidade herdada da lista.';

-- Check-in "assistindo agora": expira sozinho (default 3 h).
create table public.checkins (
  id          uuid primary key default gen_random_uuid(),
  user_id     uuid not null references public.profiles(id) on delete cascade,
  title_id    uuid not null references public.titles(id) on delete cascade,
  season      smallint check (season >= 0),
  episode     smallint check (episode >= 0),
  note        text check (char_length(note) <= 140),
  created_at  timestamptz not null default now(),
  expires_at  timestamptz not null default now() + interval '3 hours'
);
create index checkins_user_idx on public.checkins (user_id, expires_at desc);
comment on table public.checkins is 'Check-in "assistindo agora", temporário.';

-- Importações do histórico da Netflix. O CSV NÃO é guardado; só contagens e o hash
-- (para avisar "este arquivo já foi importado").
create table public.imports (
  id              uuid primary key default gen_random_uuid(),
  user_id         uuid not null references public.profiles(id) on delete cascade,
  source          text not null default 'netflix' check (source in ('netflix')),
  file_hash       text,                               -- sha-256 do arquivo
  rows_total      integer not null default 0,         -- linhas do CSV
  titles_total    integer not null default 0,         -- séries/filmes distintos
  titles_matched  integer not null default 0,         -- casados automaticamente
  titles_review   integer not null default 0,         -- foram para revisão
  status          text not null default 'running' check (status in ('running', 'done', 'failed')),
  created_at      timestamptz not null default now(),
  finished_at     timestamptz
);
create index imports_user_idx on public.imports (user_id, created_at desc);
comment on table public.imports is 'Resumo de cada importação (sem o CSV).';

-- Casos duvidosos da importação: a pessoa escolhe entre 2–3 candidatos ou pula.
create table public.import_candidates (
  id                 uuid primary key default gen_random_uuid(),
  import_id          uuid not null references public.imports(id) on delete cascade,
  user_id            uuid not null references public.profiles(id) on delete cascade,
  raw_name           text not null,                      -- nome da série/filme extraído (sem episódio, sem data)
  guessed_type       text check (guessed_type in ('movie', 'tv')),
  episodes_count     integer not null default 1,
  last_watched_at    date,
  -- [{tmdb_id, media_type, title, year, poster_path, score}]
  candidates         jsonb not null default '[]'::jsonb,
  resolved_title_id  uuid references public.titles(id) on delete set null,
  resolved_at        timestamptz,
  skipped            boolean not null default false,
  created_at         timestamptz not null default now()
);
create index import_candidates_pending_idx on public.import_candidates (user_id)
  where resolved_at is null and not skipped;
comment on table public.import_candidates is 'Linhas da importação que precisam de revisão humana.';

-- Streamings que a pessoa assina (para "qual assinar" e o lembrete de cancelamento).
create table public.user_subscriptions (
  user_id                uuid not null references public.profiles(id) on delete cascade,
  provider_id            integer not null references public.providers(id) on delete cascade,
  plan                   text check (plan in ('ads', 'standard', 'premium')),
  price_cents            integer check (price_cents >= 0),  -- o que ela paga, se quiser informar
  started_on             date,
  renews_on              date,                              -- lembrete local 3 dias antes
  remind_before_renewal  boolean not null default true,
  created_at             timestamptz not null default now(),
  updated_at             timestamptz not null default now(),
  primary key (user_id, provider_id)
);
comment on table public.user_subscriptions is 'Assinaturas declaradas pelo usuário. Só o dono vê.';


-- ────────────────────────────────────────────────────────────────────────────
-- 7. Social: atividades (feed), curtidas, comentários, notificações, denúncias
-- ────────────────────────────────────────────────────────────────────────────

-- Feed. Linhas criadas SÓ por trigger (security definer): cliente não insere nem edita.
create table public.activities (
  id             uuid primary key default gen_random_uuid(),
  user_id        uuid not null references public.profiles(id) on delete cascade,
  -- watched = marcou assistido; rated = deu nota; reviewed = escreveu review;
  -- watching = começou a assistir; list_created = criou lista pública; imported = importou histórico
  kind           text not null check (kind in ('watched', 'rated', 'reviewed', 'watching', 'list_created', 'imported')),
  title_id       uuid references public.titles(id) on delete cascade,
  entry_id       uuid references public.entries(id) on delete cascade,
  list_id        uuid references public.lists(id) on delete cascade,
  payload        jsonb not null default '{}'::jsonb,   -- {rating, has_review, has_spoiler, status, count…}
  like_count     integer not null default 0,
  comment_count  integer not null default 0,
  created_at     timestamptz not null default now()
);
create index activities_user_idx    on public.activities (user_id, created_at desc);
create index activities_created_idx on public.activities (created_at desc);
create index activities_entry_idx   on public.activities (entry_id) where entry_id is not null;
comment on table public.activities is 'Eventos do feed, gerados por trigger. Visibilidade = conteúdo do autor.';

create table public.likes (
  user_id      uuid not null references public.profiles(id) on delete cascade,
  activity_id  uuid not null references public.activities(id) on delete cascade,
  created_at   timestamptz not null default now(),
  primary key (user_id, activity_id)
);
create index likes_activity_idx on public.likes (activity_id);
comment on table public.likes is 'Curtidas em atividades (reviews, notas, listas).';

create table public.comments (
  id           uuid primary key default gen_random_uuid(),
  activity_id  uuid not null references public.activities(id) on delete cascade,
  user_id      uuid not null references public.profiles(id) on delete cascade,
  body         text not null check (char_length(body) between 1 and 1000),
  has_spoiler  boolean not null default false,
  created_at   timestamptz not null default now(),
  updated_at   timestamptz not null default now()
);
create index comments_activity_idx on public.comments (activity_id, created_at);
comment on table public.comments is 'Comentários em atividades.';

-- Notificações dentro do app (push fica para depois). Criadas por trigger.
create table public.notifications (
  id           uuid primary key default gen_random_uuid(),
  user_id      uuid not null references public.profiles(id) on delete cascade,   -- destinatário
  actor_id     uuid references public.profiles(id) on delete cascade,            -- quem causou
  kind         text not null check (kind in ('follow', 'follow_request', 'follow_accepted', 'like', 'comment')),
  activity_id  uuid references public.activities(id) on delete cascade,
  comment_id   uuid references public.comments(id) on delete cascade,
  read_at      timestamptz,
  created_at   timestamptz not null default now()
);
create index notifications_user_idx   on public.notifications (user_id, created_at desc);
create index notifications_unread_idx on public.notifications (user_id) where read_at is null;
comment on table public.notifications is 'Notificações in-app. Só o destinatário lê e marca como lida.';

-- Denúncias (exigência da política de conteúdo gerado por usuário do Google Play).
create table public.reports (
  id           uuid primary key default gen_random_uuid(),
  reporter_id  uuid not null references public.profiles(id) on delete cascade,
  target_type  text not null check (target_type in ('profile', 'entry', 'list', 'comment', 'activity')),
  target_id    uuid not null,
  reason       text not null check (reason in ('spam', 'harassment', 'hate', 'sexual', 'violence', 'spoiler', 'copyright', 'other')),
  details      text check (char_length(details) <= 1000),
  status       text not null default 'open' check (status in ('open', 'reviewing', 'actioned', 'dismissed')),
  created_at   timestamptz not null default now(),
  resolved_at  timestamptz
);
create index reports_status_idx on public.reports (status, created_at);
comment on table public.reports is 'Denúncias. O João trata pelo dashboard; o denunciante só cria e vê as suas.';


-- ────────────────────────────────────────────────────────────────────────────
-- 8. Views e RPCs
-- ────────────────────────────────────────────────────────────────────────────

-- Feed de quem eu sigo (+ eu). security_invoker: a RLS de activities continua valendo.
create view public.feed with (security_invoker = true) as
  select a.*
    from public.activities a
   where a.user_id = auth.uid()
      or a.user_id in (
           select f.followee_id from public.follows f
            where f.follower_id = auth.uid() and f.status = 'accepted');
comment on view public.feed is 'Atividades minhas e de quem eu sigo (aceito), mais novas primeiro.';

-- Contadores do perfil (aparecem também em perfil privado, como no Letterboxd).
-- Devolve nulo se houver bloqueio entre quem pergunta e o perfil.
create or replace function public.profile_counts(p_profile uuid)
returns table (followers integer, following integer, watched integer, reviews integer, lists integer)
language sql stable security definer set search_path = '' as $$
  select
    (select count(*) from public.follows f where f.followee_id = p_profile and f.status = 'accepted')::integer,
    (select count(*) from public.follows f where f.follower_id = p_profile and f.status = 'accepted')::integer,
    (select count(*) from public.entries e where e.user_id = p_profile and e.status = 'watched')::integer,
    (select count(*) from public.entries e where e.user_id = p_profile and e.review is not null and e.review <> '')::integer,
    (select count(*) from public.lists l where l.user_id = p_profile and (not l.is_private or p_profile = auth.uid()))::integer
  where auth.uid() is not null
    and not public.is_blocked_between(auth.uid(), p_profile)
$$;

-- Quem eu bloqueei (a RLS de profiles esconde essas linhas de mim; aqui é o único lugar que as mostra).
create or replace function public.list_blocked_users()
returns table (id uuid, username text, display_name text, avatar_url text, blocked_at timestamptz)
language sql stable security definer set search_path = '' as $$
  select p.id, p.username, p.display_name, p.avatar_url, k.created_at
    from public.blocks k
    join public.profiles p on p.id = k.blocked_id
   where k.blocker_id = auth.uid()
   order by k.created_at desc
$$;


-- ────────────────────────────────────────────────────────────────────────────
-- 9. Grants · defesa em profundidade além da RLS
--    O Supabase dá GRANT ALL a anon/authenticated/service_role em toda tabela nova.
--    Aqui: anon fica sem nada (app só logado) e os clientes perdem o que nunca
--    devem fazer (escrever em cache, forjar atividade/notificação, mexer em denúncia).
-- ────────────────────────────────────────────────────────────────────────────
revoke all on all tables    in schema public from anon;
revoke all on all sequences in schema public from anon;
revoke all on all functions in schema public from anon;
alter default privileges in schema public revoke all on tables    from anon;
alter default privileges in schema public revoke all on sequences from anon;
alter default privileges in schema public revoke all on functions from anon;

-- cache e referência: cliente só lê
revoke insert, update, delete on public.providers, public.provider_prices, public.titles,
  public.title_availability, public.title_sync, public.home_sections from authenticated;
-- cota: ninguém além das Edge Functions
revoke all on public.api_usage from authenticated;
-- feed e notificações: criados por trigger
revoke insert, update on public.activities from authenticated;
revoke insert on public.notifications from authenticated;
-- denúncias: quem denuncia não edita nem apaga
revoke update, delete on public.reports from authenticated;
-- funções que só as Edge Functions ou os triggers chamam
revoke execute on function public.consume_api_quota(text, integer) from public, authenticated;
revoke execute on function public.set_updated_at() from public, authenticated;


-- ────────────────────────────────────────────────────────────────────────────
-- 10. RLS · ligada em toda tabela; uma policy por operação, comentada
-- ────────────────────────────────────────────────────────────────────────────
alter table public.profiles            enable row level security;
alter table public.blocks              enable row level security;
alter table public.follows             enable row level security;
alter table public.providers           enable row level security;
alter table public.provider_prices     enable row level security;
alter table public.titles              enable row level security;
alter table public.title_availability  enable row level security;
alter table public.title_sync          enable row level security;
alter table public.home_sections       enable row level security;
alter table public.api_usage           enable row level security;   -- sem policy: só service_role
alter table public.entries             enable row level security;
alter table public.lists               enable row level security;
alter table public.list_items          enable row level security;
alter table public.checkins            enable row level security;
alter table public.imports             enable row level security;
alter table public.import_candidates   enable row level security;
alter table public.user_subscriptions  enable row level security;
alter table public.activities          enable row level security;
alter table public.likes               enable row level security;
alter table public.comments            enable row level security;
alter table public.notifications       enable row level security;
alter table public.reports             enable row level security;

-- profiles ------------------------------------------------------------------
-- Cartão do perfil é visível a qualquer logado, exceto entre bloqueados (nos dois sentidos).
create policy "profiles: ler cartão salvo bloqueio" on public.profiles
  for select to authenticated using (public.can_view_profile(id));
-- O trigger do cadastro cria o perfil; este insert é só reserva (ex.: perfil apagado à mão).
create policy "profiles: criar só o próprio" on public.profiles
  for insert to authenticated with check (id = auth.uid());
-- Só o dono edita o próprio perfil (e não pode trocar o id).
create policy "profiles: editar só o próprio" on public.profiles
  for update to authenticated using (id = auth.uid()) with check (id = auth.uid());
-- Sem delete: apagar conta passa por auth.users (cascade), via Edge Function/dashboard.

-- blocks --------------------------------------------------------------------
-- Só quem bloqueou vê, cria e desfaz o bloqueio; o bloqueado não descobre.
create policy "blocks: ver os meus" on public.blocks
  for select to authenticated using (blocker_id = auth.uid());
create policy "blocks: bloquear em meu nome" on public.blocks
  for insert to authenticated with check (blocker_id = auth.uid());
create policy "blocks: desbloquear os meus" on public.blocks
  for delete to authenticated using (blocker_id = auth.uid());

-- follows -------------------------------------------------------------------
-- Vejo as relações em que estou; dos outros, só follows aceitos de quem posso ver o
-- conteúdo (a lista "seguindo" de um perfil privado é conteúdo dele) e sem bloqueio com o seguido.
create policy "follows: ver as minhas e as públicas" on public.follows
  for select to authenticated
  using (follower_id = auth.uid()
      or followee_id = auth.uid()
      or (status = 'accepted' and public.can_view_content(follower_id) and public.can_view_profile(followee_id)));
-- Só eu peço para seguir em meu nome (o trigger decide pending/accepted e barra bloqueio).
create policy "follows: seguir em meu nome" on public.follows
  for insert to authenticated with check (follower_id = auth.uid());
-- Só o seguido aceita um pedido; o trigger impede trocar as pontas da relação.
create policy "follows: aceitar pedido recebido" on public.follows
  for update to authenticated using (followee_id = auth.uid())
  with check (followee_id = auth.uid() and status = 'accepted');
-- Qualquer das pontas desfaz: deixar de seguir, remover seguidor ou recusar pedido.
create policy "follows: desfazer de qualquer ponta" on public.follows
  for delete to authenticated using (follower_id = auth.uid() or followee_id = auth.uid());

-- providers / provider_prices / titles / title_availability / title_sync / home_sections
-- Catálogo e cache: leitura para qualquer logado; escrita só pela Edge Function (service_role).
create policy "providers: leitura" on public.providers
  for select to authenticated using (true);
create policy "provider_prices: leitura" on public.provider_prices
  for select to authenticated using (true);
create policy "titles: leitura" on public.titles
  for select to authenticated using (true);
create policy "title_availability: leitura" on public.title_availability
  for select to authenticated using (true);
create policy "title_sync: leitura" on public.title_sync
  for select to authenticated using (true);
create policy "home_sections: leitura" on public.home_sections
  for select to authenticated using (true);
-- api_usage: nenhuma policy de propósito (ver comment da tabela).

-- entries -------------------------------------------------------------------
-- Meu diário sempre; o dos outros se o perfil for público ou eu for seguidor aceito, sem bloqueio.
create policy "entries: ver conforme privacidade do dono" on public.entries
  for select to authenticated using (public.can_view_content(user_id));
-- Só escrevo no meu diário.
create policy "entries: criar as minhas" on public.entries
  for insert to authenticated with check (user_id = auth.uid());
create policy "entries: editar as minhas" on public.entries
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "entries: apagar as minhas" on public.entries
  for delete to authenticated using (user_id = auth.uid());

-- lists ---------------------------------------------------------------------
-- Lista privada só o dono; pública segue a privacidade do perfil do dono.
create policy "lists: ver minhas e públicas visíveis" on public.lists
  for select to authenticated using (user_id = auth.uid() or (not is_private and public.can_view_content(user_id)));
create policy "lists: criar as minhas" on public.lists
  for insert to authenticated with check (user_id = auth.uid());
create policy "lists: editar as minhas" on public.lists
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "lists: apagar as minhas" on public.lists
  for delete to authenticated using (user_id = auth.uid());

-- list_items ----------------------------------------------------------------
-- Item visível se a lista for visível (a RLS de lists vale dentro do subselect).
create policy "list_items: ver se a lista é visível" on public.list_items
  for select to authenticated using (exists (select 1 from public.lists l where l.id = list_id));
-- Só o dono da lista mexe nos itens.
create policy "list_items: adicionar na minha lista" on public.list_items
  for insert to authenticated with check (exists (select 1 from public.lists l where l.id = list_id and l.user_id = auth.uid()));
create policy "list_items: editar na minha lista" on public.list_items
  for update to authenticated
  using (exists (select 1 from public.lists l where l.id = list_id and l.user_id = auth.uid()))
  with check (exists (select 1 from public.lists l where l.id = list_id and l.user_id = auth.uid()));
create policy "list_items: remover da minha lista" on public.list_items
  for delete to authenticated using (exists (select 1 from public.lists l where l.id = list_id and l.user_id = auth.uid()));

-- checkins ------------------------------------------------------------------
-- Os meus sempre; os dos outros só enquanto valem e conforme a privacidade do dono.
create policy "checkins: ver ativos de quem posso ver" on public.checkins
  for select to authenticated using (user_id = auth.uid() or (expires_at > now() and public.can_view_content(user_id)));
-- Check-in meu, com validade máxima de 12 h (não dá para "ficar assistindo" para sempre).
create policy "checkins: criar o meu" on public.checkins
  for insert to authenticated with check (user_id = auth.uid() and expires_at <= now() + interval '12 hours');
create policy "checkins: editar o meu" on public.checkins
  for update to authenticated using (user_id = auth.uid())
  with check (user_id = auth.uid() and expires_at <= now() + interval '12 hours');
create policy "checkins: encerrar o meu" on public.checkins
  for delete to authenticated using (user_id = auth.uid());

-- imports / import_candidates -----------------------------------------------
-- Importação é dado pessoal: só o dono, em tudo.
create policy "imports: ver as minhas" on public.imports
  for select to authenticated using (user_id = auth.uid());
create policy "imports: criar as minhas" on public.imports
  for insert to authenticated with check (user_id = auth.uid());
create policy "imports: atualizar as minhas" on public.imports
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "imports: apagar as minhas" on public.imports
  for delete to authenticated using (user_id = auth.uid());
create policy "import_candidates: ver os meus" on public.import_candidates
  for select to authenticated using (user_id = auth.uid());
create policy "import_candidates: criar os meus" on public.import_candidates
  for insert to authenticated with check (user_id = auth.uid());
create policy "import_candidates: resolver os meus" on public.import_candidates
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "import_candidates: apagar os meus" on public.import_candidates
  for delete to authenticated using (user_id = auth.uid());

-- user_subscriptions --------------------------------------------------------
-- O que a pessoa assina é só dela (nem seguidor vê).
create policy "user_subscriptions: ver as minhas" on public.user_subscriptions
  for select to authenticated using (user_id = auth.uid());
create policy "user_subscriptions: criar as minhas" on public.user_subscriptions
  for insert to authenticated with check (user_id = auth.uid());
create policy "user_subscriptions: editar as minhas" on public.user_subscriptions
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "user_subscriptions: apagar as minhas" on public.user_subscriptions
  for delete to authenticated using (user_id = auth.uid());

-- activities ----------------------------------------------------------------
-- Atividade segue a visibilidade do conteúdo do autor (público / seguidor / bloqueio).
create policy "activities: ver conforme privacidade do autor" on public.activities
  for select to authenticated using (public.can_view_content(user_id));
-- Sem insert/update para cliente: só os triggers criam (impede forjar atividade).
-- O autor pode apagar uma atividade sua (tirar do feed).
create policy "activities: apagar as minhas" on public.activities
  for delete to authenticated using (user_id = auth.uid());

-- likes ---------------------------------------------------------------------
-- Vejo curtidas de atividades que posso ver, menos as de gente bloqueada.
create policy "likes: ver em atividades visíveis" on public.likes
  for select to authenticated
  using (not public.is_blocked_between(auth.uid(), user_id)
         and exists (select 1 from public.activities a where a.id = activity_id));
-- Curto em meu nome, só o que posso ver.
create policy "likes: curtir em meu nome" on public.likes
  for insert to authenticated
  with check (user_id = auth.uid() and exists (select 1 from public.activities a where a.id = activity_id));
create policy "likes: descurtir as minhas" on public.likes
  for delete to authenticated using (user_id = auth.uid());

-- comments ------------------------------------------------------------------
-- Vejo comentários de atividades visíveis, menos os de gente bloqueada.
create policy "comments: ver em atividades visíveis" on public.comments
  for select to authenticated
  using (not public.is_blocked_between(auth.uid(), user_id)
         and exists (select 1 from public.activities a where a.id = activity_id));
-- Comento em meu nome, só no que posso ver.
create policy "comments: comentar em meu nome" on public.comments
  for insert to authenticated
  with check (user_id = auth.uid() and exists (select 1 from public.activities a where a.id = activity_id));
-- Edito só o meu (o trigger impede mover o comentário de atividade ou de autor).
create policy "comments: editar o meu" on public.comments
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
-- Apaga quem escreveu ou o dono da atividade (moderação do próprio espaço).
create policy "comments: apagar meu ou na minha atividade" on public.comments
  for delete to authenticated
  using (user_id = auth.uid() or exists (select 1 from public.activities a where a.id = activity_id and a.user_id = auth.uid()));

-- notifications -------------------------------------------------------------
-- Só o destinatário lê; notificações de quem virou bloqueado somem.
create policy "notifications: ver as minhas" on public.notifications
  for select to authenticated using (user_id = auth.uid() and not public.is_blocked_between(auth.uid(), actor_id));
-- Marcar como lida (sem insert para cliente: só triggers criam).
create policy "notifications: marcar as minhas" on public.notifications
  for update to authenticated using (user_id = auth.uid()) with check (user_id = auth.uid());
create policy "notifications: apagar as minhas" on public.notifications
  for delete to authenticated using (user_id = auth.uid());

-- reports -------------------------------------------------------------------
-- Denuncio em meu nome e sempre como "open"; só vejo as minhas; não edito nem apago.
create policy "reports: denunciar em meu nome" on public.reports
  for insert to authenticated with check (reporter_id = auth.uid() and status = 'open');
create policy "reports: ver as minhas" on public.reports
  for select to authenticated using (reporter_id = auth.uid());


-- ────────────────────────────────────────────────────────────────────────────
-- 11. Triggers
-- ────────────────────────────────────────────────────────────────────────────

-- Cadastro: cria o perfil com @ provisório e dados que o Google/e-mail trouxerem.
create or replace function public.handle_new_user() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_meta jsonb := coalesce(new.raw_user_meta_data, '{}'::jsonb);
begin
  insert into public.profiles (id, username, display_name, avatar_url)
  values (
    new.id,
    'u_' || left(replace(new.id::text, '-', ''), 10),       -- único o bastante; o onboarding troca
    left(coalesce(v_meta ->> 'full_name', v_meta ->> 'name', split_part(new.email, '@', 1)), 50),
    coalesce(v_meta ->> 'avatar_url', v_meta ->> 'picture')
  )
  on conflict (id) do nothing;
  return new;
end $$;
revoke execute on function public.handle_new_user() from public, anon, authenticated;

create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- Perfil: id imutável; ao deixar de ser privado, aceita os pedidos pendentes.
create or replace function public.profiles_before_update() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.id <> old.id then
    raise exception 'profiles.id é imutável' using errcode = '42501';
  end if;
  if old.is_private and not new.is_private then
    update public.follows set status = 'accepted', accepted_at = now()
     where followee_id = new.id and status = 'pending';
  end if;
  new.updated_at := now();
  return new;
end $$;
revoke execute on function public.profiles_before_update() from public, anon, authenticated;

create trigger profiles_before_update
  before update on public.profiles
  for each row execute function public.profiles_before_update();

-- Seguir: barra bloqueio e decide pending/accepted pela privacidade do seguido.
create or replace function public.follows_before_insert() returns trigger
language plpgsql security definer set search_path = '' as $$
declare v_private boolean;
begin
  if public.is_blocked_between(new.follower_id, new.followee_id) then
    raise exception 'não é possível seguir este perfil' using errcode = '42501';
  end if;
  select p.is_private into v_private from public.profiles p where p.id = new.followee_id;
  if v_private is null then
    raise exception 'perfil não encontrado' using errcode = '42501';
  end if;
  new.status := case when v_private then 'pending' else 'accepted' end;
  new.accepted_at := case when v_private then null else now() end;
  return new;
end $$;
revoke execute on function public.follows_before_insert() from public, anon, authenticated;

create trigger follows_before_insert
  before insert on public.follows
  for each row execute function public.follows_before_insert();

-- Aceitar: as pontas não mudam; accepted_at marca a aceitação.
create or replace function public.follows_before_update() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.follower_id <> old.follower_id or new.followee_id <> old.followee_id then
    raise exception 'as pontas de um follow são imutáveis' using errcode = '42501';
  end if;
  if old.status = 'pending' and new.status = 'accepted' then
    new.accepted_at := now();
  end if;
  return new;
end $$;
revoke execute on function public.follows_before_update() from public, anon, authenticated;

create trigger follows_before_update
  before update on public.follows
  for each row execute function public.follows_before_update();

-- Notifica: novo seguidor / pedido recebido / pedido aceito.
create or replace function public.follows_notify() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    insert into public.notifications (user_id, actor_id, kind)
    values (new.followee_id, new.follower_id, case when new.status = 'accepted' then 'follow' else 'follow_request' end);
  elsif tg_op = 'UPDATE' and old.status = 'pending' and new.status = 'accepted' then
    insert into public.notifications (user_id, actor_id, kind) values (new.follower_id, new.followee_id, 'follow_accepted');
    -- o pedido deixa de ser pendente para quem aceitou
    delete from public.notifications
     where user_id = new.followee_id and actor_id = new.follower_id and kind = 'follow_request';
  end if;
  return new;
end $$;
revoke execute on function public.follows_notify() from public, anon, authenticated;

create trigger follows_notify
  after insert or update on public.follows
  for each row execute function public.follows_notify();

-- Bloquear: desfaz follows e pedidos nos dois sentidos e limpa notificações entre os dois.
create or replace function public.blocks_after_insert() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  delete from public.follows
   where (follower_id = new.blocker_id and followee_id = new.blocked_id)
      or (follower_id = new.blocked_id and followee_id = new.blocker_id);
  delete from public.notifications
   where (user_id = new.blocker_id and actor_id = new.blocked_id)
      or (user_id = new.blocked_id and actor_id = new.blocker_id);
  return new;
end $$;
revoke execute on function public.blocks_after_insert() from public, anon, authenticated;

create trigger blocks_after_insert
  after insert on public.blocks
  for each row execute function public.blocks_after_insert();

-- Diário → feed. Escolhe o evento mais significativo da mudança (review > nota > status)
-- e, se o mesmo tipo para a mesma entrada aconteceu na última hora, atualiza em vez de
-- duplicar (editar a review 5 vezes vira 1 item). Importação não gera evento aqui.
create or replace function public.entries_log_activity() returns trigger
language plpgsql security definer set search_path = '' as $$
declare
  v_kind text;
  v_payload jsonb;
  v_old_review text := case when tg_op = 'UPDATE' then old.review end;
  v_old_rating numeric := case when tg_op = 'UPDATE' then old.rating end;
  v_old_status text := case when tg_op = 'UPDATE' then old.status end;
begin
  if new.source = 'netflix_import' then
    return new;
  end if;
  if new.review is distinct from v_old_review and new.review is not null and new.review <> '' then
    v_kind := 'reviewed';
  elsif new.rating is distinct from v_old_rating and new.rating is not null then
    v_kind := 'rated';
  elsif new.status is distinct from v_old_status and new.status = 'watched' then
    v_kind := 'watched';
  elsif new.status is distinct from v_old_status and new.status = 'watching' then
    v_kind := 'watching';
  else
    return new;   -- "quero ver" e edições menores não entram no feed
  end if;

  v_payload := jsonb_build_object(
    'status', new.status,
    'rating', new.rating,
    'has_review', new.review is not null and new.review <> '',
    'has_spoiler', new.has_spoiler,
    'is_rewatch', new.watch_count > 1
  );

  update public.activities
     set payload = v_payload, created_at = now()
   where entry_id = new.id and kind = v_kind and created_at > now() - interval '1 hour';
  if not found then
    insert into public.activities (user_id, kind, title_id, entry_id, payload)
    values (new.user_id, v_kind, new.title_id, new.id, v_payload);
  end if;
  return new;
end $$;
revoke execute on function public.entries_log_activity() from public, anon, authenticated;

create trigger entries_log_activity
  after insert or update on public.entries
  for each row execute function public.entries_log_activity();

-- Lista pública criada → feed.
create or replace function public.lists_log_activity() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if not new.is_private then
    insert into public.activities (user_id, kind, list_id, payload)
    values (new.user_id, 'list_created', new.id, jsonb_build_object('name', new.name));
  end if;
  return new;
end $$;
revoke execute on function public.lists_log_activity() from public, anon, authenticated;

create trigger lists_log_activity
  after insert on public.lists
  for each row execute function public.lists_log_activity();

-- Importação concluída → um evento só ("importou 312 títulos da Netflix").
create or replace function public.imports_log_activity() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if old.status <> 'done' and new.status = 'done' and new.titles_matched > 0 then
    insert into public.activities (user_id, kind, payload)
    values (new.user_id, 'imported', jsonb_build_object('source', new.source, 'count', new.titles_matched));
  end if;
  return new;
end $$;
revoke execute on function public.imports_log_activity() from public, anon, authenticated;

create trigger imports_log_activity
  after update on public.imports
  for each row execute function public.imports_log_activity();

-- Curtida: contador na atividade + notificação ao autor (não para auto-curtida).
create or replace function public.likes_after_change() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    update public.activities set like_count = like_count + 1 where id = new.activity_id;
    insert into public.notifications (user_id, actor_id, kind, activity_id)
    select a.user_id, new.user_id, 'like', a.id
      from public.activities a where a.id = new.activity_id and a.user_id <> new.user_id;
    return new;
  else
    update public.activities set like_count = greatest(like_count - 1, 0) where id = old.activity_id;
    delete from public.notifications
     where kind = 'like' and activity_id = old.activity_id and actor_id = old.user_id;
    return old;
  end if;
end $$;
revoke execute on function public.likes_after_change() from public, anon, authenticated;

create trigger likes_after_change
  after insert or delete on public.likes
  for each row execute function public.likes_after_change();

-- Comentário: contador + notificação ao autor da atividade; colunas de vínculo imutáveis.
create or replace function public.comments_before_update() returns trigger
language plpgsql set search_path = '' as $$
begin
  if new.activity_id <> old.activity_id or new.user_id <> old.user_id then
    raise exception 'comentário não pode mudar de atividade ou de autor' using errcode = '42501';
  end if;
  new.updated_at := now();
  return new;
end $$;
revoke execute on function public.comments_before_update() from public, anon, authenticated;

create trigger comments_before_update
  before update on public.comments
  for each row execute function public.comments_before_update();

create or replace function public.comments_after_change() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if tg_op = 'INSERT' then
    update public.activities set comment_count = comment_count + 1 where id = new.activity_id;
    insert into public.notifications (user_id, actor_id, kind, activity_id, comment_id)
    select a.user_id, new.user_id, 'comment', a.id, new.id
      from public.activities a where a.id = new.activity_id and a.user_id <> new.user_id;
    return new;
  else
    update public.activities set comment_count = greatest(comment_count - 1, 0) where id = old.activity_id;
    return old;   -- a notificação cai pelo on delete cascade de comment_id
  end if;
end $$;
revoke execute on function public.comments_after_change() from public, anon, authenticated;

create trigger comments_after_change
  after insert or delete on public.comments
  for each row execute function public.comments_after_change();

-- updated_at automático
create trigger entries_set_updated_at before update on public.entries
  for each row execute function public.set_updated_at();
create trigger lists_set_updated_at before update on public.lists
  for each row execute function public.set_updated_at();
create trigger user_subscriptions_set_updated_at before update on public.user_subscriptions
  for each row execute function public.set_updated_at();
create trigger providers_set_updated_at before update on public.providers
  for each row execute function public.set_updated_at();
create trigger provider_prices_set_updated_at before update on public.provider_prices
  for each row execute function public.set_updated_at();


-- ────────────────────────────────────────────────────────────────────────────
-- 12. Seeds · dados de referência (não de usuário)
--     Ids do TMDB conforme a base pública em 2026-10; `providers-sync` (fase 03)
--     confirma nomes/logos com a chave. Pacotes, domínios e buscas: fase 01
--     (research/out/assetlinks.json). motn_id: ids de serviço da Streaming Availability.
-- ────────────────────────────────────────────────────────────────────────────
insert into public.providers
  (id, slug, name, motn_id, android_package, web_domain, search_url_template, is_featured, display_order) values
  (8,    'netflix',     'Netflix',      'netflix',     'com.netflix.mediaclient',           'www.netflix.com',        'https://www.netflix.com/search?q={q}',               true, 1),
  (119,  'prime',       'Prime Video',  'prime',       'com.amazon.avod.thirdpartyclient',  'www.primevideo.com',     'https://www.primevideo.com/search?phrase={q}',       true, 2),
  (337,  'disney',      'Disney+',      'disney',      'com.disney.disneyplus',             'www.disneyplus.com',     null,                                                 true, 3),
  (1899, 'max',         'HBO Max',      'hbo',         'com.wbd.stream',                    'play.hbomax.com',        'https://play.hbomax.com/search?q={q}',               true, 4),
  (307,  'globoplay',   'Globoplay',    null,          'com.globo.globotv',                 'globoplay.globo.com',    'https://globoplay.globo.com/busca/?q={q}',           true, 5),
  (350,  'apple',       'Apple TV+',    'apple',       'com.apple.atve.androidtv.appletv',  'tv.apple.com',           'https://tv.apple.com/br/search?term={q}',            true, 6),
  (531,  'paramount',   'Paramount+',   'paramount',   'com.cbs.app',                       'www.paramountplus.com',  'https://www.paramountplus.com/br/search/?q={q}',     true, 7),
  (283,  'crunchyroll', 'Crunchyroll',  'crunchyroll', 'com.crunchyroll.crunchyroid',       'www.crunchyroll.com',    'https://www.crunchyroll.com/pt-br/search?q={q}',     true, 8);

-- Variantes conhecidas: agrupam no principal na interface.
insert into public.providers (id, name, parent_id, is_featured) values
  (1796, 'Netflix com anúncios', 8, false),
  (2100, 'Prime Video com anúncios', 119, false);

-- Preços de referência (BRL/mês). ESTIMATIVAS para a fase 07 ter com o que trabalhar;
-- o João confere e zera is_estimate pelo dashboard (pendência).
insert into public.provider_prices (provider_id, plan, plan_label, price_cents, is_estimate) values
  (8,    'ads',      'Padrão com anúncios',  2090, true),
  (8,    'standard', 'Padrão',               4490, true),
  (8,    'premium',  'Premium',              5990, true),
  (119,  'standard', 'Prime (mensal)',       1990, true),
  (337,  'ads',      'Padrão com anúncios',  2790, true),
  (337,  'standard', 'Padrão',               4390, true),
  (337,  'premium',  'Premium',              6690, true),
  (1899, 'ads',      'Básico com anúncios',  2990, true),
  (1899, 'standard', 'Padrão',               3990, true),
  (1899, 'premium',  'Platinum',             5590, true),
  (307,  'standard', 'Padrão',               2490, true),
  (350,  'standard', 'Apple TV+',            2190, true),
  (531,  'standard', 'Padrão',               1990, true),
  (283,  'standard', 'Fan',                  1699, true),
  (283,  'premium',  'Mega Fan',             2299, true);
