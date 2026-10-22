import { assertEquals, assertStrictEquals } from "jsr:@std/assert@1";
import { errorResponse, HttpError, readJson, serve } from "../_shared/http.ts";
import { extractLinks, matchLinks, motnTypeToOffer, normalizeLink } from "../_shared/motn.ts";
import { isAnime, mapCatalogItem, mapProviderList, mapTitleInput, mapWatchProviders } from "../_shared/tmdb.ts";
import { decideRefresh, forceAllowed, isStale, TTL } from "../_shared/ttl.ts";
import { onePieceMotn, onePieceTmdb, post } from "./fakes.ts";

const DAY = 24 * 60 * 60 * 1000;
const T0 = Date.parse("2026-10-22T12:00:00Z");
const iso = (ms: number) => new Date(ms).toISOString();

Deno.test("ttl: isStale / forceAllowed", () => {
  assertEquals(isStale(null, TTL.providers, T0), true);
  assertEquals(isStale(iso(T0 - 6 * DAY), TTL.providers, T0), false);
  assertEquals(isStale(iso(T0 - 8 * DAY), TTL.providers, T0), true);
  assertEquals(isStale(iso(T0 - 29 * DAY), TTL.title, T0), false);
  assertEquals(isStale(iso(T0 - 31 * DAY), TTL.title, T0), true);
  assertEquals(forceAllowed(iso(T0 - 23 * 60 * 60 * 1000), T0), false);
  assertEquals(forceAllowed(iso(T0 - 25 * 60 * 60 * 1000), T0), true);
  assertEquals(isStale("lixo", TTL.home, T0), true);
});

Deno.test("ttl: decideRefresh cobre os 5 casos do §10", () => {
  const fresh = { titleFetchedAt: iso(T0 - DAY), providersFetchedAt: iso(T0 - DAY), linksFetchedAt: iso(T0 - DAY), force: false, wantLinks: true, now: T0 };
  assertEquals(decideRefresh(fresh), { fetchTmdb: false, fetchLinks: false }); // 1. cache quente
  assertEquals(decideRefresh({ ...fresh, titleFetchedAt: null }), { fetchTmdb: true, fetchLinks: false }); // 2. sem detalhe
  assertEquals(decideRefresh({ ...fresh, providersFetchedAt: iso(T0 - 8 * DAY) }), { fetchTmdb: true, fetchLinks: false });
  assertEquals(decideRefresh({ ...fresh, linksFetchedAt: iso(T0 - 8 * DAY) }), { fetchTmdb: false, fetchLinks: true }); // 3. links vencidos
  assertEquals(decideRefresh({ ...fresh, linksFetchedAt: null, wantLinks: false }), { fetchTmdb: false, fetchLinks: false });
  assertEquals(decideRefresh({ ...fresh, force: true }), { fetchTmdb: false, fetchLinks: false }); // 5. force < 24 h ignorado
  assertEquals(decideRefresh({ ...fresh, force: true, providersFetchedAt: iso(T0 - 2 * DAY), linksFetchedAt: iso(T0 - 2 * DAY) }), { fetchTmdb: true, fetchLinks: true });
});

Deno.test("tmdb: isAnime = Animação + JP/ja", () => {
  assertEquals(isAnime([16, 10759], "ja", ["JP"]), true);
  assertEquals(isAnime([16], "en", ["JP"]), true);
  assertEquals(isAnime([16], "en", ["US"]), false, "Animação ocidental não é anime");
  assertEquals(isAnime([18], "ja", ["JP"]), false, "drama japonês não é anime");
});

Deno.test("tmdb: mapCatalogItem filtra pessoa e usa title/name", () => {
  assertEquals(mapCatalogItem({ media_type: "person", id: 1, name: "Ator" }), null);
  assertEquals(mapCatalogItem({ media_type: "movie", id: 872585, title: "Oppenheimer", release_date: "2023-07-20", poster_path: "/o.jpg", genre_ids: [18] }), {
    tmdb_id: 872585, media_type: "movie", title: "Oppenheimer", year: 2023, poster_path: "/o.jpg", is_anime: false,
  });
  assertEquals(mapCatalogItem({ id: 37854, name: "One Piece", first_air_date: "1999-10-20", genre_ids: [16], original_language: "ja" }, "tv")?.is_anime, true);
  assertEquals(mapCatalogItem({ media_type: "tv", id: 5, name: "Sem data" })?.year, null);
});

Deno.test("tmdb: mapTitleInput de série e de filme", () => {
  const tv = mapTitleInput(onePieceTmdb, "tv");
  assertEquals(tv.title, "One Piece");
  assertEquals(tv.original_title, "ワンピース");
  assertEquals(tv.genres, ["Action & Adventure", "Animação"]);
  assertEquals(tv.genre_ids, [10759, 16]);
  assertEquals(tv.is_anime, true);
  assertEquals(tv.episode_run_time, 24);
  assertEquals(tv.runtime_minutes, null);
  assertEquals(tv.number_of_seasons, 22);
  assertEquals(tv.seasons?.[0].name, "East Blue");
  assertEquals(tv.cast_top?.[0], { name: "Mayumi Tanaka", character: "Luffy (voice)", profile_path: null });
  assertEquals(tv.vote_average, 8.7);
  assertEquals(tv.imdb_id, "tt0388629");
  assertEquals(tv.release_date, "1999-10-20");

  const movie = mapTitleInput({ id: 1, title: "Filme", original_title: "Film", runtime: 95, genres: [], release_date: "2024-01-02", imdb_id: "tt1", credits: { cast: [] } }, "movie");
  assertEquals(movie.runtime_minutes, 95);
  assertEquals(movie.episode_run_time, null);
  assertEquals(movie.seasons, null);
  assertEquals(movie.imdb_id, "tt1");
});

Deno.test("tmdb: mapWatchProviders dedup e ordem dos tipos; mapProviderList com prioridade BR", () => {
  const { offers, link } = mapWatchProviders(onePieceTmdb["watch/providers"]);
  assertEquals(offers.map((o) => `${o.provider.id}:${o.offer_type}`), ["8:flatrate", "283:flatrate", "9999:flatrate", "1796:ads"]);
  assertEquals(link, "https://www.themoviedb.org/tv/37854/watch?locale=BR");
  assertEquals(mapWatchProviders({ results: {} }), { offers: [], link: null });

  const list = mapProviderList({ results: [{ provider_id: 8, provider_name: "Netflix", logo_path: "/n.jpg", display_priorities: { BR: 0, US: 5 }, display_priority: 5 }, { provider_name: "sem id" }] });
  assertEquals(list, [{ id: 8, name: "Netflix", logo_path: "/n.jpg", display_priority: 0 }]);
});

Deno.test("motn: tipos, normalização do HBO Max, extração e casamento com variantes", () => {
  assertEquals(motnTypeToOffer("subscription"), "flatrate");
  assertEquals(motnTypeToOffer("addon"), null);
  assertEquals(normalizeLink("https://play.max.com/show/x"), "https://play.hbomax.com/show/x");
  assertEquals(normalizeLink("https://www.netflix.com/title/1"), "https://www.netflix.com/title/1");
  assertEquals(normalizeLink("não é url"), "não é url");

  const links = extractLinks(onePieceMotn);
  assertEquals(links.map((l) => l.service_id), ["netflix", "crunchyroll", "hbo"], "addon ignorado");
  assertEquals(links[2].link, "https://play.hbomax.com/show/urn:hbo:series:X");

  const matched = matchLinks(links, [
    { provider_id: 8, offer_type: "flatrate" },
    { provider_id: 1796, offer_type: "ads" },
    { provider_id: 307, offer_type: "flatrate" },
    { provider_id: 8, offer_type: "buy" },
  ], (id) => ({ 8: "netflix", 1796: "netflix", 307: null }[id] ?? null));
  assertEquals(matched, [
    { provider_id: 8, offer_type: "flatrate", deep_link: "https://www.netflix.com/title/80107103" },
    { provider_id: 1796, offer_type: "ads", deep_link: "https://www.netflix.com/title/80107103" },
  ]);
});

Deno.test("http: erro padrão, corpo inválido, OPTIONS e método", async () => {
  const res = errorResponse(new HttpError(429, "quota_exceeded", "Limite."));
  assertEquals(res.status, 429);
  assertEquals(await res.json(), { error: { code: "quota_exceeded", message: "Limite." } });

  const internal = errorResponse(new Error("boom"));
  assertEquals(internal.status, 500);
  assertEquals((await internal.json()).error.code, "internal");

  const bad = await readJson(new Request("http://x", { method: "POST", body: "[1,2]" })).catch((e) => e);
  assertStrictEquals(bad.status, 400);
  assertEquals(await readJson(new Request("http://x", { method: "POST", body: "" })), {});

  const handler = serve((_req) => Promise.resolve(new Response("ok")));
  assertEquals((await handler(new Request("http://x", { method: "OPTIONS" }))).status, 200);
  assertEquals((await handler(new Request("http://x", { method: "GET" }))).status, 405);
  assertEquals((await handler(post({}))).status, 200);
});
