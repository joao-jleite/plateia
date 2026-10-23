-- Testes de RLS e idempotência da fase 05 (importar Netflix). Rodam em
-- `npm run db:test`, numa transação desfeita no fim. Cobrem: só o dono lê
-- `imports`/`import_candidates`; reimportar não duplica `entries` nem o evento
-- `imported`; edição manual não é sobrescrita; um nome bruto por usuário na
-- revisão; resolver/pular tira o candidato da fila.
-- O SQL aqui é o que o app executa pelo PostgREST (RLS do usuário), não a
-- Edge Function: `import-match` só escreve esboços em `titles` (service_role).

-- ────────────────────────────────────────────────────────────────────────────
-- 1. Importação é dado pessoal: outro usuário não lê, não altera, não cria em
--    nome do dono; anon não lê nada
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid;
  imp uuid;
  n int;
begin
  a := tests.create_user('i1a@teste.local');
  b := tests.create_user('i1b@teste.local');

  perform tests.login_as(a);
  insert into public.imports (user_id, file_hash, rows_total, titles_total)
    values (a, 'sha256-arquivo-a', 120, 3) returning id into imp;
  insert into public.import_candidates (user_id, import_id, raw_name, guessed_type, episodes_count, candidates)
    values (a, imp, 'One Piece', 'tv', 12, '[{"tmdb_id":37854,"media_type":"tv","score":0.8}]'::jsonb);
  reset role;

  perform tests.login_as(b);
  assert (select count(*) from public.imports) = 0, 'B não vê importações de A';
  assert (select count(*) from public.import_candidates) = 0, 'B não vê candidatos de A';
  update public.imports set status = 'done' where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não altera importação de A';
  update public.import_candidates set skipped = true where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não resolve candidato de A';
  delete from public.import_candidates where user_id = a;
  get diagnostics n = row_count;
  assert n = 0, 'B não apaga candidato de A';
  begin
    insert into public.imports (user_id) values (a);
    raise exception 'criar importação em nome de A deveria falhar';
  exception when insufficient_privilege then null;
  end;
  reset role;

  perform tests.login_as(a);
  assert (select count(*) from public.imports where id = imp) = 1, 'A vê a própria importação';
  assert (select count(*) from public.import_candidates where import_id = imp) = 1, 'A vê o próprio candidato';
  reset role;

  perform tests.login_anon();
  begin
    perform count(*) from public.imports;
    raise exception 'anon não deveria ler imports';
  exception when insufficient_privilege then null;
  end;
  begin
    perform count(*) from public.import_candidates;
    raise exception 'anon não deveria ler import_candidates';
  exception when insufficient_privilege then null;
  end;
  reset role;
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 2. Importar duas vezes: `entries` não duplica (unique + do nothing), um só
--    evento `imported` (titles_new = 0 na segunda), nenhum evento por título,
--    e a edição manual (nota, review, status) sobrevive à reimportação
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid;
  t_op uuid; t_opp uuid; t_st uuid;
  imp1 uuid; imp2 uuid;
  n int;
begin
  a := tests.create_user('i2a@teste.local');
  -- esboços como a Edge Function grava (fetched_at antigo renova ao abrir)
  insert into public.titles (tmdb_id, media_type, title, fetched_at) values (37854, 'tv', 'One Piece', '1970-01-01') returning id into t_op;
  insert into public.titles (tmdb_id, media_type, title, fetched_at) values (872585, 'movie', 'Oppenheimer', '1970-01-01') returning id into t_opp;
  insert into public.titles (tmdb_id, media_type, title, fetched_at) values (66732, 'tv', 'Stranger Things', '1970-01-01') returning id into t_st;

  -- 1ª importação: 3 casamentos "high" viram entradas
  perform tests.login_as(a);
  insert into public.imports (user_id, file_hash, rows_total, titles_total) values (a, 'sha-1', 120, 3) returning id into imp1;
  insert into public.entries (user_id, title_id, status, watched_at, episodes_watched, source) values
    (a, t_op,  'watched', '2024-07-15', 61,   'netflix_import'),
    (a, t_opp, 'watched', '2024-01-02', null, 'netflix_import'),
    (a, t_st,  'watched', '2023-05-05', 34,   'netflix_import')
  on conflict (user_id, title_id) do nothing;
  get diagnostics n = row_count;
  assert n = 3, '1ª importação cria 3 entradas';
  update public.imports set status = 'done', titles_matched = 3, titles_review = 1, titles_new = n, finished_at = now() where id = imp1;
  reset role;

  assert (select count(*) from public.entries where user_id = a) = 3, '3 entradas no diário';
  assert (select count(*) from public.activities where user_id = a and kind = 'imported') = 1, 'um evento imported';
  assert (select count(*) from public.activities where user_id = a and kind <> 'imported') = 0, 'importação não gera evento por título';
  assert (select payload->>'count' from public.activities where user_id = a and kind = 'imported') = '3', 'payload.count = títulos novos';

  -- a pessoa edita à mão: nota e review no One Piece (o app marca source = manual)
  -- e muda Stranger Things para "assistindo"
  perform tests.login_as(a);
  update public.entries set rating = 4.5, review = 'Wano é o melhor arco.', source = 'manual'
   where user_id = a and title_id = t_op;
  update public.entries set status = 'watching', current_season = 2, current_episode = 3, source = 'manual'
   where user_id = a and title_id = t_st;
  reset role;
  assert (select count(*) from public.activities where user_id = a and kind = 'reviewed') = 1,
    'editar à mão um registro importado volta a gerar evento no feed (source = manual)';

  -- 2ª importação do MESMO arquivo: insert não cria nada; o app só atualiza
  -- watched_at/episodes_watched dos registros ainda `netflix_import` e em `watched`
  perform tests.login_as(a);
  insert into public.imports (user_id, file_hash, rows_total, titles_total) values (a, 'sha-1', 120, 3) returning id into imp2;
  insert into public.entries (user_id, title_id, status, watched_at, episodes_watched, source) values
    (a, t_op,  'watched', '2025-01-10', 70,   'netflix_import'),
    (a, t_opp, 'watched', '2025-01-02', null, 'netflix_import'),
    (a, t_st,  'watched', '2023-05-05', 34,   'netflix_import')
  on conflict (user_id, title_id) do nothing;
  get diagnostics n = row_count;
  assert n = 0, 'reimportar não cria entrada';
  update public.entries set watched_at = '2025-01-02'
   where user_id = a and title_id = t_opp and status = 'watched' and source = 'netflix_import'
     and (watched_at is null or watched_at < '2025-01-02');
  get diagnostics n = row_count;
  assert n = 1, 'registro importado e não editado atualiza a data da última reprodução';
  update public.imports set status = 'done', titles_matched = 3, titles_review = 0, titles_new = 0, finished_at = now() where id = imp2;
  reset role;

  assert (select count(*) from public.entries where user_id = a) = 3, 'continua com 3 entradas';
  assert (select count(*) from public.activities where user_id = a and kind = 'imported') = 1, 'reimportar não duplica o evento imported';
  assert (select rating from public.entries where user_id = a and title_id = t_op) = 4.5, 'nota manual preservada';
  assert (select review from public.entries where user_id = a and title_id = t_op) = 'Wano é o melhor arco.', 'review manual preservada';
  assert (select watched_at from public.entries where user_id = a and title_id = t_op) = '2024-07-15', 'data do registro editado à mão não muda';
  assert (select status from public.entries where user_id = a and title_id = t_st) = 'watching', 'status manual preservado';
  assert (select watched_at from public.entries where user_id = a and title_id = t_opp) = '2025-01-02', 'data atualizada no registro só importado';
  assert (select count(*) from public.imports where user_id = a and file_hash = 'sha-1' and status = 'done') = 2,
    'o histórico guarda as duas importações (o app avisa "já importado em DD/MM" pelo hash)';
end $$;

-- ────────────────────────────────────────────────────────────────────────────
-- 3. Revisão: um nome bruto por usuário (reimportar não repete a pergunta);
--    resolver grava a entrada e sai da fila; pular sai da fila; a fila é só
--    o que está pendente
-- ────────────────────────────────────────────────────────────────────────────
do $$
declare
  a uuid; b uuid;
  t1 uuid; t2 uuid;
  imp1 uuid; imp2 uuid;
  c1 uuid; c2 uuid;
  n int;
begin
  a := tests.create_user('i3a@teste.local');
  b := tests.create_user('i3b@teste.local');
  -- esboços como `ensureTitleSketches` grava: não mexe em título que já existe
  insert into public.titles (tmdb_id, media_type, title, fetched_at) values (37854, 'tv', 'One Piece', '1970-01-01')
    on conflict (tmdb_id, media_type) do update set title = public.titles.title returning id into t1;
  insert into public.titles (tmdb_id, media_type, title, fetched_at) values (111110, 'tv', 'One Piece', '1970-01-01')
    on conflict (tmdb_id, media_type) do update set title = public.titles.title returning id into t2;

  perform tests.login_as(a);
  insert into public.imports (user_id, file_hash) values (a, 'sha-3') returning id into imp1;
  insert into public.import_candidates (user_id, import_id, raw_name, guessed_type, episodes_count, last_watched_at, candidates) values
    (a, imp1, 'One Piece', 'tv', 12, '2024-07-15',
     jsonb_build_array(jsonb_build_object('title_id', t1, 'tmdb_id', 37854, 'media_type', 'tv', 'score', 0.8),
                       jsonb_build_object('title_id', t2, 'tmdb_id', 111110, 'media_type', 'tv', 'score', 0.8))),
    (a, imp1, 'Trailer: Round 6', null, 1, '2024-01-01', '[]'::jsonb)
  on conflict (user_id, raw_name) do nothing;
  select id into c1 from public.import_candidates where user_id = a and raw_name = 'One Piece';
  select id into c2 from public.import_candidates where user_id = a and raw_name = 'Trailer: Round 6';

  -- reimportação manda os mesmos nomes: nada duplica
  insert into public.imports (user_id, file_hash) values (a, 'sha-3') returning id into imp2;
  insert into public.import_candidates (user_id, import_id, raw_name, guessed_type, episodes_count, candidates) values
    (a, imp2, 'One Piece', 'tv', 12, '[]'::jsonb),
    (a, imp2, 'Trailer: Round 6', null, 1, '[]'::jsonb)
  on conflict (user_id, raw_name) do nothing;
  get diagnostics n = row_count;
  assert n = 0, 'mesmo raw_name não entra duas vezes';
  assert (select count(*) from public.import_candidates where user_id = a) = 2, '2 candidatos, não 4';
  assert (select count(*) from public.import_candidates where user_id = a and resolved_at is null and not skipped) = 2, '2 pendentes';

  -- resolver: grava a entrada (idempotente) e marca o candidato
  insert into public.entries (user_id, title_id, status, watched_at, episodes_watched, source)
    values (a, t1, 'watched', '2024-07-15', 12, 'netflix_import')
  on conflict (user_id, title_id) do nothing;
  update public.import_candidates set resolved_title_id = t1, resolved_at = now() where id = c1;
  -- pular
  update public.import_candidates set skipped = true where id = c2;
  reset role;

  assert (select count(*) from public.import_candidates where user_id = a and resolved_at is null and not skipped) = 0, 'fila vazia';
  assert (select count(*) from public.entries where user_id = a and title_id = t1) = 1, 'resolver gravou a entrada';
  assert (select count(*) from public.activities where user_id = a) = 0, 'resolver na revisão não gera evento (import)';

  -- outro usuário pode ter o mesmo raw_name (a unicidade é por usuário)
  perform tests.login_as(b);
  insert into public.imports (user_id, file_hash) values (b, 'sha-b') returning id into imp2;
  insert into public.import_candidates (user_id, import_id, raw_name, candidates) values (b, imp2, 'One Piece', '[]'::jsonb);
  assert (select count(*) from public.import_candidates) = 1, 'B só vê o seu';
  reset role;
  assert (select count(*) from public.import_candidates where raw_name = 'One Piece' and user_id in (a, b)) = 2, 'mesmo nome em usuários diferentes';
end $$;
