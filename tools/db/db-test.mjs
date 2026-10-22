// db-test.mjs · sobe um Postgres 17 local (sem Docker), aplica o stub do Supabase,
// aplica supabase/migrations/*.sql em ordem, confere RLS em toda tabela e roda os
// testes SQL de tools/db/tests/*.sql (cada arquivo numa transação que é desfeita).
//
// Uso (na raiz do repo):   npm run db:test            → aplica, testa, derruba
//                          npm run db:test -- --keep  → idem, mas deixa o banco de pé
//                                                       até você apertar Enter
// Variáveis: DB_TEST_PORT (padrão 54329).
// Como o Supabase: cada migração roda numa transação só; se falhar, nada dela fica.

import EmbeddedPostgres from 'embedded-postgres';
import { readdirSync, readFileSync, rmSync, existsSync } from 'node:fs';
import { join, dirname, resolve, relative } from 'node:path';
import { fileURLToPath } from 'node:url';
import { createInterface } from 'node:readline';

const here = dirname(fileURLToPath(import.meta.url));
const root = resolve(here, '..', '..');
const migrationsDir = join(root, 'supabase', 'migrations');
const testsDir = join(here, 'tests');
const stubFile = join(here, 'supabase_stub.sql');
const dataDir = join(here, '.pgdata');
const keep = process.argv.includes('--keep');
const port = Number(process.env.DB_TEST_PORT || 54329);

const c = {
  ok: (s) => `\x1b[32m${s}\x1b[0m`,
  bad: (s) => `\x1b[31m${s}\x1b[0m`,
  dim: (s) => `\x1b[2m${s}\x1b[0m`,
  bold: (s) => `\x1b[1m${s}\x1b[0m`,
};
const rel = (p) => relative(root, p).replaceAll('\\', '/');

// Converte a posição (em caracteres) que o Postgres devolve num erro para linha:coluna.
function lineOf(sql, position) {
  if (!position) return null;
  const upto = sql.slice(0, Number(position) - 1);
  const lines = upto.split('\n');
  return `${lines.length}:${lines[lines.length - 1].length + 1}`;
}

function listSql(dir) {
  if (!existsSync(dir)) return [];
  return readdirSync(dir).filter((f) => f.endsWith('.sql')).sort();
}

async function runFile(client, file, { transactional = false } = {}) {
  const sql = readFileSync(file, 'utf8');
  try {
    if (transactional) await client.query('begin');
    await client.query(sql);
    if (transactional) await client.query('rollback');
    return { ok: true };
  } catch (err) {
    if (transactional) await client.query('rollback').catch(() => {});
    const where = lineOf(sql, err.position);
    const detail = [err.message, err.detail, err.hint, err.where].filter(Boolean).join('\n      ');
    return { ok: false, message: `${rel(file)}${where ? ':' + where : ''}\n      ${detail}` };
  }
}

// Sanidade do schema, independente dos testes: RLS ligado e policies em toda tabela,
// funções SECURITY DEFINER com search_path fixo e anon sem acesso a nada.
async function checkSchema(client) {
  const problems = [];

  const { rows: tables } = await client.query(`
    select c.relname as table_name,
           c.relrowsecurity as rls,
           c.relforcerowsecurity as force_rls,
           (select count(*) from pg_policy p where p.polrelid = c.oid)::int as policies,
           coalesce(obj_description(c.oid, 'pg_class'), '') as comment,
           has_table_privilege('anon', c.oid, 'SELECT') as anon_select,
           has_table_privilege('authenticated', c.oid, 'SELECT') as auth_select
      from pg_class c
      join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public' and c.relkind in ('r', 'p')
     order by c.relname`);

  console.log(c.bold('\nTabelas em public'));
  console.log(c.dim('  tabela                     RLS  policies  anon  authenticated'));
  for (const t of tables) {
    const flags = [];
    if (!t.rls) { flags.push('SEM RLS'); problems.push(`${t.table_name}: RLS desligado`); }
    // Tabela sem policy = cliente nenhum lê nem escreve. Só é aceitável se o comentário
    // da tabela declarar isso de propósito com a marca [no-client-access].
    if (t.policies === 0 && !t.comment.includes('[no-client-access]')) {
      flags.push('SEM POLICY'); problems.push(`${t.table_name}: nenhuma policy e sem a marca [no-client-access] no comment`);
    }
    if (t.anon_select) { flags.push('ANON LÊ'); problems.push(`${t.table_name}: anon tem SELECT (app é só logado)`); }
    const line = `  ${t.table_name.padEnd(26)} ${t.rls ? ' ✓ ' : ' ✗ '}  ${String(t.policies).padStart(5)}     ${t.anon_select ? 'sim' : 'não'}   ${t.auth_select ? 'sim' : 'não'}`;
    console.log(flags.length ? c.bad(line + '   ← ' + flags.join(', ')) : line);
  }

  const { rows: fns } = await client.query(`
    select p.proname, p.prosecdef as secdef,
           coalesce(array_to_string(p.proconfig, ','), '') as config
      from pg_proc p join pg_namespace n on n.oid = p.pronamespace
     where n.nspname = 'public' and p.prosecdef
     order by 1`);
  for (const f of fns) {
    if (!f.config.includes('search_path=')) problems.push(`função ${f.proname}: SECURITY DEFINER sem "set search_path"`);
  }
  console.log(c.dim(`  ${tables.length} tabelas · ${fns.length} funções security definer (todas com search_path fixo: ${fns.every((f) => f.config.includes('search_path=')) ? 'sim' : 'NÃO'})`));

  const { rows: views } = await client.query(`
    select c.relname, coalesce(array_to_string(c.reloptions, ','), '') as opts
      from pg_class c join pg_namespace n on n.oid = c.relnamespace
     where n.nspname = 'public' and c.relkind = 'v'`);
  for (const v of views) {
    // view sem security_invoker roda com os direitos do dono (postgres) e fura a RLS
    if (!v.opts.includes('security_invoker=true')) problems.push(`view ${v.relname}: sem security_invoker=true`);
  }
  return problems;
}

async function main() {
  const t0 = Date.now();
  rmSync(dataDir, { recursive: true, force: true });
  const pg = new EmbeddedPostgres({
    databaseDir: dataDir,
    user: 'postgres',
    password: 'postgres',
    port,
    persistent: false,
    initdbFlags: ['--encoding=UTF8', '--locale=C', '--no-sync'],
    onLog: () => {},
    onError: (e) => {
      const s = String(e).trim();
      // ruído normal do pg_ctl; só mostra o que parece erro de verdade
      if (/FATAL|PANIC|could not/i.test(s)) console.error(c.dim('[postgres] ' + s.slice(0, 400)));
    },
  });

  let failed = false;
  try {
    console.log(c.bold(`Postgres local (embedded-postgres) na porta ${port}…`));
    await pg.initialise();
    await pg.start();
    const client = pg.getPgClient();
    await client.connect();
    const { rows: [{ version }] } = await client.query('select version()');
    console.log(c.dim('  ' + version.split(',')[0]));

    // 1) stub do Supabase
    const stub = await runFile(client, stubFile);
    if (!stub.ok) throw new Error('stub falhou:\n  ' + stub.message);
    console.log(c.ok('✓') + ' stub do Supabase aplicado (auth, storage, roles, tests)');

    // 2) migrações, em ordem, uma transação por arquivo (como o `supabase db push`)
    const migrations = listSql(migrationsDir);
    if (migrations.length === 0) throw new Error(`nenhuma migração em ${rel(migrationsDir)}`);
    for (const m of migrations) {
      const file = join(migrationsDir, m);
      const r = await runFile(client, file);
      if (!r.ok) { console.log(c.bad('✗') + ' migração falhou: ' + r.message); failed = true; break; }
      console.log(c.ok('✓') + ' migração ' + rel(file));
    }

    if (!failed) {
      // 3) sanidade do schema
      const problems = await checkSchema(client);
      if (problems.length) {
        failed = true;
        console.log(c.bad('\nProblemas de schema:'));
        for (const p of problems) console.log(c.bad('  ✗ ' + p));
      } else {
        console.log(c.ok('✓') + ' RLS ligado e com policy em toda tabela; anon sem acesso; definers com search_path');
      }

      // 4) testes SQL (cada um numa transação desfeita no fim)
      const tests = listSql(testsDir);
      console.log(c.bold(`\nTestes (${tests.length})`));
      let passed = 0;
      for (const t of tests) {
        const r = await runFile(client, join(testsDir, t), { transactional: true });
        if (r.ok) { passed++; console.log(c.ok('  ✓ ') + t); }
        else { failed = true; console.log(c.bad('  ✗ ') + t + '\n      ' + r.message.split('\n').slice(1).join('\n')); }
      }
      console.log(`${passed}/${tests.length} testes passaram`);
    }

    await client.end();

    if (keep) {
      console.log(c.bold(`\nBanco de pé: postgres://postgres:postgres@localhost:${port}/postgres`));
      console.log('Aperte Enter para derrubar.');
      await new Promise((res) => createInterface({ input: process.stdin }).once('line', res));
    }
  } catch (err) {
    failed = true;
    console.error(c.bad('\n✗ ' + (err?.message || err)));
  } finally {
    await pg.stop().catch(() => {});
    rmSync(dataDir, { recursive: true, force: true });
  }
  console.log(c.dim(`\n${((Date.now() - t0) / 1000).toFixed(1)} s`));
  process.exit(failed ? 1 : 0);
}

main();
