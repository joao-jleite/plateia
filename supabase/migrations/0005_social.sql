-- ============================================================================
-- 0005_social.sql · Plateia · fase 06 · 2026-10-23
--
-- O que o teste tools/db/tests/0005_social.sql pediu além do que a 0001 já
-- garante (bloqueio, pedido pendente, comentário imutável e notificação só do
-- destinatário já passavam sem mexer em policy):
--   1. view `friends_checkins`: a faixa "assistindo agora" só de quem eu sigo
--      (a tabela `checkins` mostra qualquer perfil público visível);
--   2. lista que vira privada sai do feed (e renomear atualiza o payload);
--   3. `notifications`: cliente só edita `read_at` (grant por coluna);
--   4. índice para a busca por `@` (prefixo) e por nome.
-- Nunca editar esta migração depois de aplicada: criar 0006.
-- ============================================================================

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Faixa "assistindo agora": check-ins ativos meus e de quem eu sigo (aceito).
--    security_invoker: a RLS de checkins continua valendo (privado só para
--    seguidor; bloqueio nunca). Espelha a view `feed`.
-- ────────────────────────────────────────────────────────────────────────────
create view public.friends_checkins with (security_invoker = true) as
  select c.*
    from public.checkins c
   where c.expires_at > now()
     and (c.user_id = auth.uid()
          or c.user_id in (
               select f.followee_id from public.follows f
                where f.follower_id = auth.uid() and f.status = 'accepted'));
comment on view public.friends_checkins is 'Check-ins ativos meus e de quem eu sigo (faixa do feed e do Início).';

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Lista: virar privada apaga a atividade "criou a lista" (o nome da lista é
--    conteúdo privado); renomear atualiza o payload. Voltar a público não
--    recria o evento (o "criou" ficou no passado; evita spam no feed).
-- ────────────────────────────────────────────────────────────────────────────
create or replace function public.lists_sync_activity() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if new.is_private and not old.is_private then
    delete from public.activities where list_id = new.id and kind = 'list_created';
  elsif new.name <> old.name then
    update public.activities
       set payload = payload || jsonb_build_object('name', new.name)
     where list_id = new.id and kind = 'list_created';
  end if;
  return new;
end $$;
revoke execute on function public.lists_sync_activity() from public, anon, authenticated;

create trigger lists_sync_activity
  after update on public.lists
  for each row execute function public.lists_sync_activity();

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Notificações: o destinatário só marca como lida. Sem isto a policy de
--    update (que é por linha) deixaria trocar kind/actor_id da própria notificação.
-- ────────────────────────────────────────────────────────────────────────────
revoke update on public.notifications from authenticated;
grant update (read_at) on public.notifications to authenticated;

-- ────────────────────────────────────────────────────────────────────────────
-- 4. Busca de pessoas (`/search/users`): `username ilike 'q%'` usa o índice de
--    padrão; `display_name ilike '%q%'` fica sequencial (base pequena; se
--    pesar, pg_trgm numa migração nova).
-- ────────────────────────────────────────────────────────────────────────────
create index profiles_username_pattern_idx on public.profiles (username text_pattern_ops);
