-- ============================================================================
-- 0003_diary_stats.sql · fase 04 (perfil e diário)
-- Uma view enxuta para as estatísticas do perfil e um índice para a aba Reviews.
-- O cálculo (horas, por streaming, por gênero, por ano) fica no app, em função
-- pura testada unitariamente; o banco só entrega uma linha magra por entrada,
-- já com o título e os streamings (assinatura, BR) resolvidos, em vez de o app
-- baixar `entries` + `titles` + `title_availability` inteiros.
-- ============================================================================

-- security_invoker: a RLS de `entries` vale aqui (quem não vê o diário não vê
-- a estatística). provider_ids agrupa a variante pela marca (Netflix com
-- anúncios → Netflix), como a seção "Onde assistir" faz.
create view public.entry_stats_rows with (security_invoker = true) as
  select e.user_id,
         e.id              as entry_id,
         e.status,
         e.watch_count,
         e.episodes_watched,
         t.media_type,
         t.runtime_minutes,
         t.episode_run_time,
         t.number_of_episodes,
         t.genres,
         t.year,
         coalesce((
           select array_agg(distinct coalesce(p.parent_id, p.id))
             from public.title_availability a
             join public.providers p on p.id = a.provider_id
            where a.title_id = t.id
              and a.region = 'BR'
              and a.offer_type in ('flatrate', 'ads')
         ), '{}'::integer[]) as provider_ids
    from public.entries e
    join public.titles  t on t.id = e.title_id;
comment on view public.entry_stats_rows is
  'Uma linha magra por entrada do diário para as estatísticas do perfil (app agrega). Herda a RLS de entries.';

-- Mesma regra das tabelas: anon não lê nada; o app só lê.
revoke all on public.entry_stats_rows from anon;
revoke insert, update, delete on public.entry_stats_rows from authenticated;
grant select on public.entry_stats_rows to authenticated;

-- Aba Reviews do perfil: só as entradas com texto, mais recentes primeiro.
create index entries_user_review_idx on public.entries (user_id, updated_at desc)
  where review is not null;
