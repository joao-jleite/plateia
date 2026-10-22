import { assert, assertEquals } from "jsr:@std/assert@1";
import { handleTitle } from "../catalog-title/handler.ts";
import { FakeDb, fakeMotn, fakeTmdb, onePieceMotn, onePieceTmdb, post, requireUserOk } from "./fakes.ts";

const DAY = 24 * 60 * 60 * 1000;
const T0 = Date.parse("2026-10-22T12:00:00Z");

/// Captura as linhas de log da função (JSON em console.log).
function captureLogs(): { lines: Array<Record<string, unknown>>; restore: () => void } {
  const lines: Array<Record<string, unknown>> = [];
  const original = console.log;
  console.log = (...args: unknown[]) => {
    try {
      lines.push(JSON.parse(String(args[0])));
    } catch {
      // não é JSON: ignora
    }
  };
  return { lines, restore: () => (console.log = original) };
}

function deps(db: FakeDb, now: number) {
  const tmdb = fakeTmdb({ "/tv/37854": onePieceTmdb });
  const motn = fakeMotn(onePieceMotn);
  return {
    deps: { requireUser: requireUserOk, db, tmdb: tmdb.factory, motn: motn.factory, now: () => now },
    tmdb,
    motn,
  };
}

Deno.test("primeira abertura: 1 chamada TMDB + 1 MOTN, grava cache e links; segunda abertura: upstream_calls 0", async () => {
  const db = new FakeDb();
  const logs = captureLogs();
  try {
    const first = deps(db, T0);
    const res1 = await handleTitle(post({ tmdb_id: 37854, media_type: "tv" }), first.deps);
    assertEquals(res1.status, 200);
    const body1 = await res1.json();

    assertEquals(first.tmdb.calls, ["/tv/37854"]);
    assertEquals(first.motn.calls, ["tv/37854"]);
    assertEquals(db.quotaCalls, 1);
    assertEquals(body1.title.title, "One Piece");
    assertEquals(body1.title.is_anime, true);
    assertEquals(body1.title.imdb_id, "tt0388629");
    assertEquals(body1.sync.links_status, "ok");

    // 4 linhas (Netflix, Crunchyroll, Novo Streaming, Netflix com anúncios); provider 9999 criado lazy
    assertEquals(body1.availability.length, 4);
    assert(db.providers.some((p) => p.id === 9999 && p.name === "Novo Streaming"));
    const netflix = body1.availability.find((a: { provider_id: number; offer_type: string }) => a.provider_id === 8 && a.offer_type === "flatrate");
    assertEquals(netflix.deep_link, "https://www.netflix.com/title/80107103");
    assertEquals(netflix.provider.name, "Netflix");
    // variante "com anúncios" recebe o link do principal (motn_id do pai) e vem com o pai na resposta
    const ads = body1.availability.find((a: { provider_id: number }) => a.provider_id === 1796);
    assertEquals(ads.deep_link, "https://www.netflix.com/title/80107103");
    assertEquals(ads.provider.parent_id, 8);
    // Globoplay não está no TMDB deste título; "Novo Streaming" sem motn_id fica sem link
    const novo = body1.availability.find((a: { provider_id: number }) => a.provider_id === 9999);
    assertEquals(novo.deep_link, null);

    assertEquals(logs.lines.at(-1)!.upstream_calls, 2);

    // Segunda abertura (1 h depois): tudo do Postgres
    const second = deps(db, T0 + 60 * 60 * 1000);
    const res2 = await handleTitle(post({ tmdb_id: 37854, media_type: "tv" }), second.deps);
    const body2 = await res2.json();
    assertEquals(second.tmdb.calls, []);
    assertEquals(second.motn.calls, []);
    assertEquals(db.quotaCalls, 1, "não consome cota de novo");
    assertEquals(body2.availability.length, 4);
    assertEquals(logs.lines.at(-1)!.upstream_calls, 0, "log mostra upstream_calls: 0");
  } finally {
    logs.restore();
  }
});

Deno.test("force dentro de 24 h é ignorado; depois de 24 h renova; TTL de 7 d renova sozinho", async () => {
  const db = new FakeDb();
  await handleTitle(post({ tmdb_id: 37854, media_type: "tv" }), deps(db, T0).deps);

  const soon = deps(db, T0 + 2 * 60 * 60 * 1000);
  await handleTitle(post({ tmdb_id: 37854, media_type: "tv", force: true }), soon.deps);
  assertEquals(soon.tmdb.calls, [], "force < 24 h não chama");
  assertEquals(soon.motn.calls, []);

  const later = deps(db, T0 + 25 * 60 * 60 * 1000);
  await handleTitle(post({ tmdb_id: 37854, media_type: "tv", force: true }), later.deps);
  assertEquals(later.tmdb.calls, ["/tv/37854"]);
  assertEquals(later.motn.calls, ["tv/37854"]);

  const week = deps(db, T0 + 25 * 60 * 60 * 1000 + 8 * DAY);
  await handleTitle(post({ tmdb_id: 37854, media_type: "tv" }), week.deps);
  assertEquals(week.tmdb.calls, ["/tv/37854"], "providers > 7 d renova sem force");
  assertEquals(week.motn.calls, ["tv/37854"]);
});

Deno.test("cota estourada: não chama a MOTN, links_status = quota, deep_link preservado", async () => {
  const db = new FakeDb();
  await handleTitle(post({ tmdb_id: 37854, media_type: "tv" }), deps(db, T0).deps);

  db.quotaAllowed = false;
  const d = deps(db, T0 + 8 * DAY);
  const res = await handleTitle(post({ tmdb_id: 37854, media_type: "tv" }), d.deps);
  const body = await res.json();
  assertEquals(d.motn.calls, []);
  assertEquals(body.sync.links_status, "quota");
  const netflix = body.availability.find((a: { provider_id: number; offer_type: string }) => a.provider_id === 8 && a.offer_type === "flatrate");
  assertEquals(netflix.deep_link, "https://www.netflix.com/title/80107103", "link antigo continua valendo");
});

Deno.test("MOTN sem o título: links_status = not_found; links=false não gasta cota", async () => {
  const db = new FakeDb();
  const tmdb = fakeTmdb({ "/tv/37854": onePieceTmdb });
  const motn = fakeMotn(null);
  const res = await handleTitle(post({ tmdb_id: 37854, media_type: "tv" }), { requireUser: requireUserOk, db, tmdb: tmdb.factory, motn: motn.factory, now: () => T0 });
  assertEquals((await res.json()).sync.links_status, "not_found");

  const db2 = new FakeDb();
  const motn2 = fakeMotn(onePieceMotn);
  await handleTitle(post({ tmdb_id: 37854, media_type: "tv", links: false }), { requireUser: requireUserOk, db: db2, tmdb: fakeTmdb({ "/tv/37854": onePieceTmdb }).factory, motn: motn2.factory, now: () => T0 });
  assertEquals(motn2.calls, []);
  assertEquals(db2.quotaCalls, 0);
});

Deno.test("HBO Max: link play.max.com é gravado como play.hbomax.com", async () => {
  const db = new FakeDb();
  const tmdb = fakeTmdb({
    "/tv/1": {
      ...onePieceTmdb,
      id: 1,
      "watch/providers": { results: { BR: { flatrate: [{ provider_id: 1899, provider_name: "HBO Max", logo_path: null, display_priority: 2 }] } } },
    },
  });
  const res = await handleTitle(post({ tmdb_id: 1, media_type: "tv" }), { requireUser: requireUserOk, db, tmdb: tmdb.factory, motn: fakeMotn(onePieceMotn).factory, now: () => T0 });
  const body = await res.json();
  assertEquals(body.availability[0].deep_link, "https://play.hbomax.com/show/urn:hbo:series:X");
});

Deno.test("validação: tmdb_id e media_type; 404 quando o TMDB não conhece; 401 sem usuário", async () => {
  const db = new FakeDb();
  const base = { db, tmdb: fakeTmdb({}).factory, motn: fakeMotn(null).factory };

  const bad = await handleTitle(post({ tmdb_id: "x", media_type: "tv" }), { ...base, requireUser: requireUserOk }).catch((e) => e);
  assertEquals(bad.status, 400);
  const badType = await handleTitle(post({ tmdb_id: 1, media_type: "anime" }), { ...base, requireUser: requireUserOk }).catch((e) => e);
  assertEquals(badType.status, 400);
  const missing = await handleTitle(post({ tmdb_id: 1, media_type: "tv" }), { ...base, requireUser: requireUserOk }).catch((e) => e);
  assertEquals(missing.status, 404);
  const noUser = await handleTitle(post({ tmdb_id: 1, media_type: "tv" }), { ...base, requireUser: () => Promise.reject(Object.assign(new Error("x"), { status: 401 })) }).catch((e) => e);
  assertEquals(noUser.status, 401);
});
