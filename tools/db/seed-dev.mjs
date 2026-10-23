// seed-dev.mjs · contas e dados de teste para o projeto Supabase de DEV (fase 06).
//
// Cria 3 contas pela Admin API (ana pública, bruno privado, carla pública), uns
// 20 títulos, diários (que viram atividades pelos triggers), follows (um pedido
// pendente e um aceito), curtidas, comentários, uma lista pública e um check-in,
// para o João testar as duas pontas da rede no celular com uma segunda conta.
//
// Uso (na raiz do repo; o João roda, nunca o Claude):
//   node tools/db/seed-dev.mjs --dry-run     só imprime o plano, sem rede nem .env
//   node tools/db/seed-dev.mjs               aplica no projeto de tools/db/.env
//   node tools/db/seed-dev.mjs --reset       apaga as 3 contas (cascade) e sai
//   node tools/db/seed-dev.mjs --local       mesmo plano no Postgres local do
//                                            `npm run db:test:keep` (sem Admin API:
//                                            usa tests.create_user). Serve para testar
//                                            o script sem projeto.
//
// tools/db/.env (fora do git, coberto pelo `.env` do .gitignore):
//   SUPABASE_URL=https://<ref>.supabase.co
//   SUPABASE_SERVICE_ROLE_KEY=<service_role>      ← NUNCA no app nem no chat
//   SEED_PASSWORD=<senha das 3 contas>            (opcional; padrão abaixo)
//
// Idempotente: rodar duas vezes não duplica (conflitos ignorados; follows e
// check-in "do nothing"). A chave nunca é impressa.

import { readFileSync, existsSync } from 'node:fs';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const args = new Set(process.argv.slice(2));
const dryRun = args.has('--dry-run');
const local = args.has('--local');
const reset = args.has('--reset');

// ───────────────────────────────────────────────────────────────────────────
// Plano (dados). Mudar aqui muda o que vai para o banco.
// ───────────────────────────────────────────────────────────────────────────
const DEFAULT_PASSWORD = 'plateia-dev-2026';

const users = [
  { key: 'ana',   email: 'ana.seed@example.com',   username: 'ana_seed',   name: 'Ana Souza',  bio: 'Sci-fi, anime e maratona de domingo.', isPrivate: false },
  { key: 'bruno', email: 'bruno.seed@example.com', username: 'bruno_seed', name: 'Bruno Lima', bio: 'Só vejo com legenda. Perfil privado.',  isPrivate: true },
  { key: 'carla', email: 'carla.seed@example.com', username: 'carla_seed', name: 'Carla Dias', bio: 'Terror e documentário.',                isPrivate: false },
];

// Ids reais do TMDB; pôster fica null e fetched_at em 1970 para o catalog-title renovar ao abrir.
const titles = [
  { tmdb_id: 872585, media_type: 'movie', title: 'Oppenheimer',                            original_title: 'Oppenheimer',               release_date: '2023-07-19' },
  { tmdb_id: 693134, media_type: 'movie', title: 'Duna: Parte Dois',                       original_title: 'Dune: Part Two',            release_date: '2024-02-27' },
  { tmdb_id: 598,    media_type: 'movie', title: 'Cidade de Deus',                         original_title: 'Cidade de Deus',            release_date: '2002-08-30' },
  { tmdb_id: 155,    media_type: 'movie', title: 'Batman: O Cavaleiro das Trevas',         original_title: 'The Dark Knight',           release_date: '2008-07-16' },
  { tmdb_id: 27205,  media_type: 'movie', title: 'A Origem',                               original_title: 'Inception',                 release_date: '2010-07-15' },
  { tmdb_id: 120,    media_type: 'movie', title: 'O Senhor dos Anéis: A Sociedade do Anel', original_title: 'The Lord of the Rings: The Fellowship of the Ring', release_date: '2001-12-18' },
  { tmdb_id: 496243, media_type: 'movie', title: 'Parasita',                               original_title: '기생충',                      release_date: '2019-05-30' },
  { tmdb_id: 324857, media_type: 'movie', title: 'Homem-Aranha no Aranhaverso',            original_title: 'Spider-Man: Into the Spider-Verse', release_date: '2018-12-06' },
  { tmdb_id: 438631, media_type: 'movie', title: 'Duna',                                   original_title: 'Dune',                      release_date: '2021-09-15' },
  { tmdb_id: 346698, media_type: 'movie', title: 'Barbie',                                 original_title: 'Barbie',                    release_date: '2023-07-19' },
  { tmdb_id: 37854,  media_type: 'tv',    title: 'One Piece',                              original_title: 'ONE PIECE',                 release_date: '1999-10-20' },
  { tmdb_id: 66732,  media_type: 'tv',    title: 'Stranger Things',                        original_title: 'Stranger Things',           release_date: '2016-07-15' },
  { tmdb_id: 100088, media_type: 'tv',    title: 'The Last of Us',                         original_title: 'The Last of Us',            release_date: '2023-01-15' },
  { tmdb_id: 136315, media_type: 'tv',    title: 'O Urso',                                 original_title: 'The Bear',                  release_date: '2022-06-23' },
  { tmdb_id: 209867, media_type: 'tv',    title: 'Frieren e a Jornada para o Além',        original_title: '葬送のフリーレン',              release_date: '2023-09-29' },
  { tmdb_id: 1396,   media_type: 'tv',    title: 'Breaking Bad',                           original_title: 'Breaking Bad',              release_date: '2008-01-20' },
  { tmdb_id: 1399,   media_type: 'tv',    title: 'Game of Thrones',                        original_title: 'Game of Thrones',           release_date: '2011-04-17' },
  { tmdb_id: 95557,  media_type: 'tv',    title: 'Arcanjo Renegado',                       original_title: 'Arcanjo Renegado',          release_date: '2020-01-14' },
  { tmdb_id: 73586,  media_type: 'tv',    title: 'Yellowstone',                            original_title: 'Yellowstone',               release_date: '2018-06-20' },
  { tmdb_id: 94997,  media_type: 'tv',    title: 'A Casa do Dragão',                       original_title: 'House of the Dragon',       release_date: '2022-08-21' },
];

// Diários. Cada linha vira uma atividade pelo trigger (review > nota > status).
const entries = [
  { user: 'ana',   tmdb: 209867, status: 'watched',  rating: 5,   review: 'Melhor anime de 2023, fácil. A trilha é absurda.', watched_at: '2026-10-01' },
  { user: 'ana',   tmdb: 872585, status: 'watched',  rating: 4.5, watched_at: '2026-09-20' },
  { user: 'ana',   tmdb: 693134, status: 'watched',  rating: 4.5, review: 'O verme no IMAX é outra coisa. O final deixa a Parte Três obrigatória.', has_spoiler: true, watched_at: '2026-10-18' },
  { user: 'ana',   tmdb: 598,    status: 'watched',  rating: 5,   watched_at: '2026-08-15' },
  { user: 'ana',   tmdb: 155,    status: 'watched',  rating: 4.5, watched_at: '2026-07-02', watch_count: 3 },
  { user: 'ana',   tmdb: 496243, status: 'watched',  rating: 4,   watched_at: '2026-06-11' },
  { user: 'ana',   tmdb: 136315, status: 'watched',  rating: 4,   watched_at: '2026-10-10' },
  { user: 'ana',   tmdb: 324857, status: 'watched',  rating: 4.5, watched_at: '2026-05-05' },
  { user: 'ana',   tmdb: 37854,  status: 'watching', rating: 4.5, current_season: 21, current_episode: 1050, watched_at: '2026-10-20' },
  { user: 'ana',   tmdb: 66732,  status: 'want' },
  { user: 'bruno', tmdb: 100088, status: 'watched',  rating: 5,   review: 'Chorei no episódio 3.', watched_at: '2026-10-03' },
  { user: 'bruno', tmdb: 136315, status: 'watched',  rating: 4,   watched_at: '2026-09-09' },
  { user: 'bruno', tmdb: 1396,   status: 'watched',  rating: 5,   watched_at: '2026-03-12' },
  { user: 'bruno', tmdb: 27205,  status: 'watched',  rating: 4,   watched_at: '2026-04-01' },
  { user: 'bruno', tmdb: 94997,  status: 'watching', current_season: 2, current_episode: 4, watched_at: '2026-10-19' },
  { user: 'carla', tmdb: 95557,  status: 'watched',  rating: 4,   watched_at: '2026-10-12' },
  { user: 'carla', tmdb: 120,    status: 'watched',  rating: 5,   review: 'Revi pela décima vez e segue perfeito.', watched_at: '2026-10-15', watch_count: 10 },
  { user: 'carla', tmdb: 438631, status: 'watched',  rating: 4,   watched_at: '2026-02-20' },
  { user: 'carla', tmdb: 346698, status: 'watched',  rating: 3.5, watched_at: '2026-01-30' },
  { user: 'carla', tmdb: 73586,  status: 'watching', current_season: 3, current_episode: 1, watched_at: '2026-10-21' },
  { user: 'carla', tmdb: 1399,   status: 'want' },
  { user: 'carla', tmdb: 209867, status: 'want' },
];

// Follows: o trigger decide pending/accepted pela privacidade do seguido.
const follows = [
  { follower: 'carla', followee: 'ana' },
  { follower: 'ana',   followee: 'carla' },
  { follower: 'bruno', followee: 'ana' },
  { follower: 'ana',   followee: 'bruno', acceptAfter: true },   // bruno é privado: vira pedido; aceitamos em seguida
  { follower: 'carla', followee: 'bruno' },                      // fica pendente: aparece na aba de pedidos do bruno
];

// Interações nas atividades (reviewed) de cada autor.
const likes = [
  { user: 'bruno', onReviewOf: 'ana', tmdb: 209867 },
  { user: 'carla', onReviewOf: 'ana', tmdb: 209867 },
  { user: 'ana',   onReviewOf: 'bruno', tmdb: 100088 },
];
const comments = [
  { user: 'carla', onReviewOf: 'ana', tmdb: 209867, body: 'Concordo. Trilha de outro planeta.' },
  { user: 'ana',   onReviewOf: 'bruno', tmdb: 100088, body: 'O 3 destrói qualquer um.', has_spoiler: true },
];

const lists = [
  { user: 'ana', name: 'Favoritos de 2024', is_ranked: true, items: [693134, 872585, 209867] },
];

const checkins = [
  { user: 'ana', tmdb: 37854, season: 21, episode: 1051, note: 'Wano chegando no fim!' },
];

// ───────────────────────────────────────────────────────────────────────────
// Executores: REST (PostgREST + Admin API com service_role) e Postgres local.
// Os dois têm a mesma interface: insert/update/select/createUser/deleteUser.
// ───────────────────────────────────────────────────────────────────────────
function readEnv() {
  const file = join(here, '.env');
  if (!existsSync(file)) {
    throw new Error(`tools/db/.env não existe. Crie com SUPABASE_URL= e SUPABASE_SERVICE_ROLE_KEY= (ver docs/PENDENCIAS-JOAO.md, fase 06).`);
  }
  const env = {};
  for (const line of readFileSync(file, 'utf8').split('\n')) {
    const m = line.match(/^\s*([A-Z0-9_]+)\s*=\s*(.*?)\s*$/);
    if (m) env[m[1]] = m[2].replace(/^["']|["']$/g, '');
  }
  if (!env.SUPABASE_URL || !env.SUPABASE_SERVICE_ROLE_KEY) {
    throw new Error('tools/db/.env precisa de SUPABASE_URL e SUPABASE_SERVICE_ROLE_KEY.');
  }
  return env;
}

class RestExecutor {
  constructor(url, key) {
    this.url = url.replace(/\/$/, '');
    this.headers = { apikey: key, Authorization: `Bearer ${key}`, 'Content-Type': 'application/json' };
  }

  async _call(path, { method = 'GET', body, prefer } = {}) {
    const res = await fetch(`${this.url}${path}`, {
      method,
      headers: { ...this.headers, ...(prefer ? { Prefer: prefer } : {}) },
      body: body === undefined ? undefined : JSON.stringify(body),
    });
    const text = await res.text();
    if (!res.ok) {
      // nunca ecoa headers (a chave está neles); só status e corpo
      throw new Error(`${method} ${path} → ${res.status}: ${text.slice(0, 300)}`);
    }
    return text ? JSON.parse(text) : null;
  }

  static _filters(filters) {
    return Object.entries(filters).map(([k, v]) => `${k}=eq.${encodeURIComponent(v)}`).join('&');
  }

  /** insert com on conflict do nothing (se onConflict) e devolve as linhas inseridas */
  insert(table, rows, { onConflict } = {}) {
    const q = onConflict ? `?on_conflict=${onConflict}` : '';
    const prefer = ['return=representation', ...(onConflict ? ['resolution=ignore-duplicates'] : [])].join(',');
    return this._call(`/rest/v1/${table}${q}`, { method: 'POST', body: rows, prefer });
  }

  update(table, patch, filters) {
    return this._call(`/rest/v1/${table}?${RestExecutor._filters(filters)}`, { method: 'PATCH', body: patch, prefer: 'return=representation' });
  }

  select(table, columns, filters = {}) {
    const f = RestExecutor._filters(filters);
    return this._call(`/rest/v1/${table}?select=${columns}${f ? '&' + f : ''}`);
  }

  async createUser({ email, password, name }) {
    try {
      const u = await this._call('/auth/v1/admin/users', {
        method: 'POST',
        body: { email, password, email_confirm: true, user_metadata: { full_name: name } },
      });
      return { id: u.id, created: true };
    } catch (e) {
      if (!/422|already|exists/i.test(e.message)) throw e;
      const found = await this.findUser(email);
      if (!found) throw e;
      return { id: found, created: false };
    }
  }

  async findUser(email) {
    const page = await this._call('/auth/v1/admin/users?page=1&per_page=1000');
    const list = Array.isArray(page) ? page : page?.users ?? [];
    return list.find((u) => u.email?.toLowerCase() === email.toLowerCase())?.id ?? null;
  }

  async deleteUser(id) {
    await this._call(`/auth/v1/admin/users/${id}`, { method: 'DELETE' });
  }

  async count(table) {
    const res = await fetch(`${this.url}/rest/v1/${table}?select=id`, { headers: { ...this.headers, Prefer: 'count=exact', Range: '0-0' } });
    const range = res.headers.get('content-range') || '';
    return Number(range.split('/')[1] ?? 0);
  }
}

class PgExecutor {
  constructor(client) {
    this.client = client;
  }

  static _cols(rows) {
    return [...new Set(rows.flatMap((r) => Object.keys(r)))];
  }

  async insert(table, rows, { onConflict } = {}) {
    if (rows.length === 0) return [];
    const cols = PgExecutor._cols(rows);
    const values = [];
    const tuples = rows.map((r) => `(${cols.map((c) => { values.push(r[c] === undefined ? null : r[c]); return `$${values.length}`; }).join(', ')})`);
    const conflict = onConflict ? ` on conflict (${onConflict}) do nothing` : '';
    const sql = `insert into public.${table} (${cols.join(', ')}) values ${tuples.join(', ')}${conflict} returning *`;
    return (await this.client.query(sql, values)).rows;
  }

  async update(table, patch, filters) {
    const values = [];
    const set = Object.entries(patch).map(([k, v]) => { values.push(v); return `${k} = $${values.length}`; }).join(', ');
    const where = Object.entries(filters).map(([k, v]) => { values.push(v); return `${k} = $${values.length}`; }).join(' and ');
    return (await this.client.query(`update public.${table} set ${set} where ${where} returning *`, values)).rows;
  }

  async select(table, columns, filters = {}) {
    const values = [];
    const where = Object.entries(filters).map(([k, v]) => { values.push(v); return `${k} = $${values.length}`; }).join(' and ');
    return (await this.client.query(`select ${columns} from public.${table}${where ? ' where ' + where : ''}`, values)).rows;
  }

  async createUser({ email, name }) {
    const found = await this.findUser(email);
    if (found) return { id: found, created: false };
    const { rows } = await this.client.query('select tests.create_user($1, $2::jsonb) as id', [email, JSON.stringify({ full_name: name })]);
    return { id: rows[0].id, created: true };
  }

  async findUser(email) {
    const { rows } = await this.client.query('select id from auth.users where email = $1', [email]);
    return rows[0]?.id ?? null;
  }

  async deleteUser(id) {
    await this.client.query('delete from auth.users where id = $1', [id]);
  }

  async count(table) {
    return Number((await this.client.query(`select count(*)::int as n from public.${table}`)).rows[0].n);
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Aplicação do plano
// ───────────────────────────────────────────────────────────────────────────
async function apply(x, { password, log }) {
  const ids = {};
  for (const u of users) {
    const r = await x.createUser({ email: u.email, password, name: u.name });
    ids[u.key] = r.id;
    log(`${r.created ? 'criou' : 'já existia'} ${u.email} → ${r.id}`);
    await x.update('profiles', { username: u.username, display_name: u.name, bio: u.bio, is_private: u.isPrivate, onboarded_at: new Date().toISOString() }, { id: r.id });
  }

  // títulos (cache do TMDB): fetched_at antigo faz o catalog-title renovar na primeira abertura
  await x.insert('titles', titles.map((t) => ({ ...t, fetched_at: '1970-01-01T00:00:00Z' })), { onConflict: 'tmdb_id,media_type' });
  const titleRows = await x.select('titles', 'id,tmdb_id,media_type');
  const titleId = (tmdb) => {
    const row = titleRows.find((t) => Number(t.tmdb_id) === tmdb);
    if (!row) throw new Error(`título ${tmdb} não encontrado depois do insert`);
    return row.id;
  };
  log(`${titles.length} títulos garantidos (${titleRows.length} no cache)`);

  const inserted = await x.insert('entries', entries.map((e) => ({
    user_id: ids[e.user], title_id: titleId(e.tmdb), status: e.status,
    rating: e.rating ?? null, review: e.review ?? null, has_spoiler: e.has_spoiler ?? false,
    watched_at: e.watched_at ?? null, current_season: e.current_season ?? null, current_episode: e.current_episode ?? null,
    watch_count: e.watch_count ?? 1, source: 'manual',
  })), { onConflict: 'user_id,title_id' });
  log(`${inserted.length} registros de diário novos (atividades nascem pelo trigger)`);

  for (const f of follows) {
    const rows = await x.insert('follows', [{ follower_id: ids[f.follower], followee_id: ids[f.followee] }], { onConflict: 'follower_id,followee_id' });
    const status = rows[0]?.status ?? '(já existia)';
    log(`follow ${f.follower} → ${f.followee}: ${status}`);
    if (f.acceptAfter) {
      await x.update('follows', { status: 'accepted' }, { follower_id: ids[f.follower], followee_id: ids[f.followee], status: 'pending' });
    }
  }

  const reviewActivity = async (authorKey, tmdb) => {
    const rows = await x.select('activities', 'id', { user_id: ids[authorKey], kind: 'reviewed', title_id: titleId(tmdb) });
    if (!rows[0]) throw new Error(`atividade reviewed de ${authorKey} em ${tmdb} não existe (o trigger não rodou?)`);
    return rows[0].id;
  };
  for (const l of likes) {
    const act = await reviewActivity(l.onReviewOf, l.tmdb);
    await x.insert('likes', [{ user_id: ids[l.user], activity_id: act }], { onConflict: 'user_id,activity_id' });
  }
  log(`${likes.length} curtidas`);
  const existingComments = await x.select('comments', 'user_id,activity_id,body');
  let newComments = 0;
  for (const c of comments) {
    const act = await reviewActivity(c.onReviewOf, c.tmdb);
    if (existingComments.some((e) => e.user_id === ids[c.user] && e.activity_id === act && e.body === c.body)) continue;
    await x.insert('comments', [{ user_id: ids[c.user], activity_id: act, body: c.body, has_spoiler: c.has_spoiler ?? false }]);
    newComments++;
  }
  log(`${newComments} comentários novos`);

  for (const l of lists) {
    const existing = await x.select('lists', 'id', { user_id: ids[l.user], name: l.name });
    const listId = existing[0]?.id ?? (await x.insert('lists', [{ user_id: ids[l.user], name: l.name, is_ranked: l.is_ranked ?? false, is_private: false }]))[0].id;
    await x.insert('list_items', l.items.map((tmdb, i) => ({ list_id: listId, title_id: titleId(tmdb), position: i })), { onConflict: 'list_id,title_id' });
    log(`lista "${l.name}" com ${l.items.length} títulos`);
  }

  for (const c of checkins) {
    const active = await x.select('checkins', 'id', { user_id: ids[c.user] });
    if (active.length) continue;
    await x.insert('checkins', [{ user_id: ids[c.user], title_id: titleId(c.tmdb), season: c.season, episode: c.episode, note: c.note }]);
    log(`check-in de ${c.user}`);
  }

  const counts = {};
  for (const t of ['profiles', 'titles', 'entries', 'activities', 'follows', 'likes', 'comments', 'notifications', 'lists', 'checkins']) {
    counts[t] = await x.count(t);
  }
  return { ids, counts };
}

async function resetAll(x, log) {
  for (const u of users) {
    const id = await x.findUser(u.email);
    if (!id) { log(`${u.email}: não existe`); continue; }
    await x.deleteUser(id);
    log(`apagou ${u.email} (cascade em perfil, diário, follows, atividades…)`);
  }
}

function printPlan() {
  console.log('Plano (nada foi executado):');
  for (const u of users) console.log(`  conta ${u.email} → @${u.username} ${u.isPrivate ? '(privado)' : '(público)'}`);
  console.log(`  ${titles.length} títulos (${titles.filter((t) => t.media_type === 'movie').length} filmes, ${titles.filter((t) => t.media_type === 'tv').length} séries)`);
  for (const u of users) {
    const mine = entries.filter((e) => e.user === u.key);
    console.log(`  diário de ${u.key}: ${mine.length} registros (${mine.filter((e) => e.review).length} reviews, ${mine.filter((e) => e.status === 'watching').length} assistindo, ${mine.filter((e) => e.status === 'want').length} quero ver)`);
  }
  console.log(`  follows: ${follows.map((f) => `${f.follower}→${f.followee}${f.acceptAfter ? ' (pedido aceito)' : ''}`).join(', ')}`);
  console.log(`  ${likes.length} curtidas, ${comments.length} comentários, ${lists.length} lista pública, ${checkins.length} check-in`);
  console.log(`  senha das 3 contas: ${process.env.SEED_PASSWORD ? '(SEED_PASSWORD do ambiente)' : `"${DEFAULT_PASSWORD}" (troque com SEED_PASSWORD no .env)`}`);
  console.log('\nEsperado no banco depois: 3 perfis, ~20 títulos, 22 entradas → 20 atividades (19 do diário, quero ver não entra, + 1 da lista), 5 follows (1 pendente), 3 curtidas, 2 comentários, notificações para os autores, 1 lista, 1 check-in.');
}

async function main() {
  const log = (s) => console.log('  ' + s);
  if (dryRun) {
    printPlan();
    return;
  }

  let executor;
  let close = async () => {};
  let password;
  if (local) {
    const { default: pg } = await import('pg');
    const port = Number(process.env.DB_TEST_PORT || 54329);
    const client = new pg.Client({ connectionString: `postgres://postgres:postgres@localhost:${port}/postgres` });
    try {
      await client.connect();
    } catch (e) {
      throw new Error(`Postgres local não respondeu em localhost:${port}. Rode \`npm run db:test:keep\` em outro terminal antes. (${e.message})`);
    }
    executor = new PgExecutor(client);
    close = () => client.end();
    password = '(local: sem senha, login só por tests.login_as)';
    console.log(`Postgres local (localhost:${port})`);
  } else {
    const env = readEnv();
    executor = new RestExecutor(env.SUPABASE_URL, env.SUPABASE_SERVICE_ROLE_KEY);
    password = env.SEED_PASSWORD || process.env.SEED_PASSWORD || DEFAULT_PASSWORD;
    console.log(`Projeto ${env.SUPABASE_URL}`);
  }

  try {
    if (reset) {
      await resetAll(executor, log);
      return;
    }
    const { ids, counts } = await apply(executor, { password, log });
    console.log('\nContagens no banco:');
    for (const [t, n] of Object.entries(counts)) console.log(`  ${t.padEnd(14)} ${n}`);
    console.log('\nContas de teste (DEV; nunca use estas senhas em conta real):');
    for (const u of users) console.log(`  ${u.email.padEnd(26)} @${u.username.padEnd(11)} ${local ? '' : `senha: ${password}`}  id ${ids[u.key]}`);
    if (!local) {
      console.log('\nNo celular: entre como carla.seed (pública) e siga @bruno_seed → vira pedido; depois entre como bruno.seed e aceite em Perfil → Pedidos.');
    }
  } finally {
    await close();
  }
}

main().catch((e) => {
  console.error('✗ ' + (e?.message || e));
  process.exit(1);
});
