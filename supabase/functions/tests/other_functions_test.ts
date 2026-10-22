import { assert, assertEquals } from "jsr:@std/assert@1";
import { handleAccountDelete } from "../account-delete/handler.ts";
import { handleSearch } from "../catalog-search/handler.ts";
import { handleHome, interleave, sectionTitle } from "../home-sections/handler.ts";
import { handleProvidersSync } from "../providers-sync/handler.ts";
import { FakeAdmin, FakeDb, fakeTmdb, post, requireUserOk, user } from "./fakes.ts";

const HOUR = 60 * 60 * 1000;
const T0 = Date.parse("2026-10-22T12:00:00Z");

Deno.test("catalog-search: pt-BR/BR, filtra pessoas, pagina e valida q", async () => {
  const tmdb = fakeTmdb({
    "/search/multi": (params: Record<string, string>) => ({
      page: Number(params.page),
      total_pages: 3,
      results: [
        { media_type: "tv", id: 37854, name: "One Piece", first_air_date: "1999-10-20", genre_ids: [16], original_language: "ja", poster_path: "/p.jpg" },
        { media_type: "person", id: 1, name: "Eiichiro Oda" },
        { media_type: "tv", id: 111110, name: "One Piece", first_air_date: "2023-08-31", genre_ids: [10759], original_language: "en" },
      ],
    }),
  });
  const res = await handleSearch(post({ q: "  One Piece ", page: 2 }), { requireUser: requireUserOk, tmdb: tmdb.factory });
  const body = await res.json();
  assertEquals(body.page, 2);
  assertEquals(body.total_pages, 3);
  assertEquals(body.results.length, 2);
  assertEquals(body.results[0].is_anime, true);
  assertEquals(body.results[1].is_anime, false);

  const empty = await handleSearch(post({ q: "   " }), { requireUser: requireUserOk, tmdb: tmdb.factory }).catch((e) => e);
  assertEquals(empty.status, 400);
});

Deno.test("home-sections: cache vazio → 17 chamadas; dentro de 6 h → 0; após 6 h → renova", async () => {
  const db = new FakeDb();
  const item = (id: number, type: "movie" | "tv") => (type === "movie"
    ? { id, title: `Filme ${id}`, release_date: "2026-09-01", genre_ids: [] }
    : { id, name: `Série ${id}`, first_air_date: "2026-09-01", genre_ids: [] });
  const tmdb = fakeTmdb({
    "/trending/all/day": { results: [{ media_type: "movie", ...item(1, "movie") }, { media_type: "person", id: 9 }] },
    "/discover/movie": (p: Record<string, string>) => ({ results: [item(Number(p.with_watch_providers) * 10, "movie")] }),
    "/discover/tv": (p: Record<string, string>) => ({ results: [item(Number(p.with_watch_providers) * 10 + 1, "tv")] }),
  });

  const first = await handleHome(post({}), { requireUser: requireUserOk, db, tmdb: tmdb.factory, now: () => T0 });
  const body = await first.json();
  // 4 destacados no fake (Netflix, Crunchyroll, HBO Max, Globoplay) → 1 + 4×2 = 9
  assertEquals(tmdb.calls.length, 9);
  assertEquals(body.sections[0], { key: "trending_all", title: "Em alta no Brasil", items: [{ tmdb_id: 1, media_type: "movie", title: "Filme 1", year: 2026, poster_path: null, is_anime: false }] });
  assertEquals(body.sections[1].title, "Novidades na Netflix");
  assertEquals(body.sections[1].items.map((i: { tmdb_id: number }) => i.tmdb_id), [80, 81]);
  assertEquals(body.sections.map((s: { key: string }) => s.key), ["trending_all", "new_on_8", "new_on_1899", "new_on_307", "new_on_283"]);

  tmdb.calls.length = 0;
  await handleHome(post({}), { requireUser: requireUserOk, db, tmdb: tmdb.factory, now: () => T0 + 5 * HOUR });
  assertEquals(tmdb.calls.length, 0, "cache de 6 h");

  await handleHome(post({}), { requireUser: requireUserOk, db, tmdb: tmdb.factory, now: () => T0 + 7 * HOUR });
  assertEquals(tmdb.calls.length, 9, "renova depois de 6 h");
});

Deno.test("home-sections: TMDB fora do ar com cache velho → serve o velho", async () => {
  const db = new FakeDb();
  db.home = [{ key: "trending_all", region: "BR", payload: [], fetched_at: new Date(T0 - 10 * HOUR).toISOString() }];
  const tmdb = (counter: { inc(): void }) => ({ get: () => { counter.inc(); return Promise.reject(new Error("rede")); } });
  const res = await handleHome(post({}), { requireUser: requireUserOk, db, tmdb, now: () => T0 });
  assertEquals(res.status, 200);
  assertEquals((await res.json()).sections[0].key, "trending_all");
});

Deno.test("home-sections: interleave e títulos de seção", () => {
  const m = (id: number) => ({ tmdb_id: id, media_type: "movie" as const, title: "m", year: null, poster_path: null, is_anime: false });
  const t = (id: number) => ({ tmdb_id: id, media_type: "tv" as const, title: "t", year: null, poster_path: null, is_anime: false });
  assertEquals(interleave([m(1), m(2), m(3)], [t(1)]).map((i) => `${i.media_type}${i.tmdb_id}`), ["movie1", "tv1", "movie2", "movie3"]);
  assertEquals(interleave([m(1), m(1)], [], 5).length, 1, "dedup");
  assertEquals(sectionTitle({ slug: "prime", name: "Prime Video" }), "Novidades no Prime Video");
  assertEquals(sectionTitle({ slug: null, name: "Telecine" }), "Novidades em Telecine");
});

Deno.test("providers-sync: atualiza logos, mantém nome dos destacados, aponta id ausente", async () => {
  const db = new FakeDb();
  const tmdb = fakeTmdb({
    "/watch/providers/movie": { results: [
      { provider_id: 8, provider_name: "Netflix", logo_path: "/netflix.jpg", display_priorities: { BR: 0 } },
      { provider_id: 1899, provider_name: "Max", logo_path: "/max.jpg", display_priorities: { BR: 3 } },
      { provider_id: 2, provider_name: "Apple TV", logo_path: "/apple.jpg", display_priorities: { BR: 9 } },
    ] },
    "/watch/providers/tv": { results: [
      { provider_id: 8, provider_name: "Netflix", logo_path: "/netflix.jpg", display_priorities: { BR: 0 } },
      { provider_id: 283, provider_name: "Crunchyroll", logo_path: "/cr.jpg", display_priorities: { BR: 12 } },
    ] },
  });
  const res = await handleProvidersSync(post({}), { requireUser: requireUserOk, db, tmdb: tmdb.factory });
  const body = await res.json();
  assertEquals(tmdb.calls.length, 2);
  assertEquals(body.upserted, 4);
  assertEquals(body.missing, [307], "Globoplay não veio na lista falsa");
  const max = body.featured.find((f: { id: number }) => f.id === 1899);
  assertEquals(max.seed_name, "HBO Max");
  assertEquals(max.tmdb_name, "Max");
  assertEquals(db.providers.find((p) => p.id === 1899)!.name, "HBO Max", "nome do seed preservado");
  assertEquals(db.providers.find((p) => p.id === 1899)!.logo_path, "/max.jpg", "logo atualizado");
  assert(db.providers.some((p) => p.id === 2 && p.name === "Apple TV"), "provider novo entra");
});

Deno.test("account-delete: apaga só o próprio usuário e seus avatares", async () => {
  const admin = new FakeAdmin();
  admin.avatars[user.id] = ["avatar.jpg"];
  admin.avatars["outro"] = ["x.jpg"];
  const res = await handleAccountDelete(post({}), { requireUser: requireUserOk, admin });
  assertEquals(await res.json(), { ok: true });
  assertEquals(admin.deleted, [user.id]);
  assertEquals(admin.removed, [`${user.id}/avatar.jpg`]);
});
