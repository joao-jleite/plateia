-- ============================================================================
-- 0004_import_idempotency.sql · fase 05 (importar o histórico da Netflix)
-- Três ajustes para a importação ser idempotente de ponta a ponta:
--   1. `imports.titles_new`: quantas entradas a importação CRIOU no diário.
--      É esse número que vai para o feed; reimportar o mesmo arquivo cria 0 e
--      não gera um segundo evento `imported` (regra da SPEC §5.8).
--   2. Um nome bruto por usuário em `import_candidates`: reimportar não repete
--      a pergunta já respondida ou pulada, nem duplica o pendente. O app grava
--      com `on_conflict (user_id, raw_name) do nothing`.
--   3. Trigger do evento `imported` passa a olhar `titles_new`.
-- Nenhuma tabela nova; o CSV continua nunca chegando ao banco.
-- ============================================================================

alter table public.imports
  add column titles_new integer not null default 0 check (titles_new >= 0);
comment on column public.imports.titles_new is
  'Entradas novas criadas no diário por esta importação (as já existentes só são atualizadas). O feed usa este número.';

-- `raw_name` é determinístico (sai do agrupador do app), então a unicidade
-- simples basta; o PostgREST usa esta constraint em `on_conflict=user_id,raw_name`.
alter table public.import_candidates
  add constraint import_candidates_user_raw_uq unique (user_id, raw_name);

-- Importação concluída → um evento só, e só se trouxe título novo.
-- payload: {source, count (novos), matched (casados automaticamente)}.
create or replace function public.imports_log_activity() returns trigger
language plpgsql security definer set search_path = '' as $$
begin
  if old.status <> 'done' and new.status = 'done' and new.titles_new > 0 then
    insert into public.activities (user_id, kind, payload)
    values (new.user_id, 'imported',
            jsonb_build_object('source', new.source, 'count', new.titles_new, 'matched', new.titles_matched));
  end if;
  return new;
end $$;
revoke execute on function public.imports_log_activity() from public, anon, authenticated;
