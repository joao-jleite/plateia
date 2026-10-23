import { assert, assertEquals } from "jsr:@std/assert@1";
import {
  confidenceFor,
  handleImportMatch,
  normalizeName,
  scoreResult,
} from "../import-match/handler.ts";
import type { Json } from "../_shared/tmdb.ts";
import { FakeDb, fakeTmdb, post, requireUserOk } from "./fakes.ts";

// Resultados do TMDB como o /search devolve (só os campos usados).
const tv = (id: number, name: string, extra: Json = {}) => ({
  id, name, original_name: extra.original_name ?? name, first_air_date: extra.first_air_date ?? "2010-01-01",
  poster_path: extra.poster_path ?? `/${id}.jpg`, popularity: extra.popularity ?? 50, genre_ids: extra.genre_ids ?? [18],
  original_language: extra.original_language ?? "en", origin_country: extra.origin_country ?? ["US"], ...extra,
});
const movie = (id: number, title: string, extra: Json = {}) => ({
  id, title, original_title: extra.original_title ?? title, release_date: extra.release_date ?? "2020-01-01",
  poster_path: extra.poster_path ?? `/${id}.jpg`, popularity: extra.popularity ?? 50, genre_ids: extra.genre_ids ?? [18],
  original_language: extra.original_language ?? "en", ...extra,
});

/// TMDB falso que responde pelo `query` recebido (tabela nome → resultados).
function tmdbByQuery(table: Record<string, Json[]>, hint?: "movie" | "tv") {
  return fakeTmdb({
    "/search/": (params: Record<string, string>) => ({
      results: (table[params.query] ?? []).map((r) => hint && !r.media_type ? { ...r } : r),
    }),
  });
}

Deno.test("normalizeName: acento, pontuação, &, espaços", () => {
  assertEquals(normalizeName("  Minissérie: Olhos que Condenam!  "), "minisserie olhos que condenam");
  assertEquals(normalizeName("Round 6"), "round 6");
  assertEquals(normalizeName("Tom & Jerry"), "tom e jerry");
  assertEquals(normalizeName("Duna: Parte Dois"), normalizeName("duna parte dois"));
  assertEquals(normalizeName("ワンピース"), "ワンピース", "letras não latinas ficam");
});

Deno.test("scoreResult: as 4 parcelas do §9 e o parcial", () => {
  const item = { raw_name: "Stranger Things", guessed_type: "tv" as const, year: 2016 };
  const exact = { title: "Stranger Things", original_title: "Stranger Things", media_type: "tv" as const, year: 2016, popularity: 300 };
  assertEquals(scoreResult(item, exact, 1), 1.0, "nome + tipo + ano + único");
  assertEquals(scoreResult(item, exact, 3), 0.9, "sem o bônus de único");
  assertEquals(scoreResult({ ...item, year: null }, exact, 3), 0.8, "sem ano");
  assertEquals(scoreResult({ ...item, guessed_type: null, year: null }, exact, 3), 0.6, "só o nome");
  assertEquals(scoreResult(item, { ...exact, media_type: "movie" }, 3), 0.7, "tipo diferente do palpite");
  assertEquals(scoreResult(item, { ...exact, title: "Stranger Things: Os Bastidores", original_title: null }, 3), 0.6, "parcial = 0,3 + tipo + ano");
  assertEquals(scoreResult(item, { ...exact, title: "Dark", original_title: "Dark" }, 1), 0.3, "nome diferente: só tipo + ano, sem o bônus de único");
  assertEquals(scoreResult({ ...item, year: null }, exact, 1), 0.9, "sem ano, exato + tipo + único exato = high");
  assertEquals(scoreResult({ ...item, raw_name: "ワンピース" }, { ...exact, title: "One Piece", original_title: "ワンピース" }, 3), 0.9, "casa pelo original");
});

Deno.test("confidenceFor: limiares", () => {
  assertEquals(confidenceFor([{ score: 0.9 }]), "high");
  assertEquals(confidenceFor([{ score: 1 }, { score: 0.79 }]), "high");
  assertEquals(confidenceFor([{ score: 0.9 }, { score: 0.8 }]), "medium", "segundo ≥ 0,8 derruba");
  assertEquals(confidenceFor([{ score: 0.6 }]), "medium");
  assertEquals(confidenceFor([{ score: 0.59 }]), "low");
  assertEquals(confidenceFor([]), "low");
});

Deno.test("import-match: série única → high, 1 chamada, esboço criado com fetched_at 1970", async () => {
  const db = new FakeDb();
  const tmdb = tmdbByQuery({
    "Stranger Things": [tv(66732, "Stranger Things", { first_air_date: "2016-07-15", popularity: 400, media_type: "tv" })],
  });
  const res = await handleImportMatch(post({ items: [{ raw_name: "Stranger Things", guessed_type: "tv" }] }), { requireUser: requireUserOk, db, tmdb: tmdb.factory });
  const body = await res.json();
  assertEquals(tmdb.calls, ["/search/tv"]);
  assertEquals(body.upstream_calls, 1);
  const m = body.matches[0];
  assertEquals(m.confidence, "high");
  assertEquals(m.best.tmdb_id, 66732);
  assertEquals(m.best.score, 0.9, "nome + tipo + único (sem ano no CSV)");
  assertEquals(m.candidates.length, 1);
  const sketch = db.titles.find((t) => t.tmdb_id === 66732)!;
  assertEquals(sketch.fetched_at, "1970-01-01T00:00:00.000Z");
  assertEquals(sketch.title, "Stranger Things");
  assertEquals(m.best.title_id, sketch.id);
});

Deno.test("import-match: homônimo filme×série e anime×live action → medium com candidatos", async () => {
  const db = new FakeDb();
  const tmdb = tmdbByQuery({
    "One Piece": [
      tv(37854, "One Piece", { original_name: "ワンピース", first_air_date: "1999-10-20", popularity: 300, genre_ids: [16, 10759], original_language: "ja", origin_country: ["JP"] }),
      tv(111110, "One Piece", { first_air_date: "2023-08-31", popularity: 200 }),
      tv(999, "One Piece: Especial", { popularity: 0.3 }),
    ],
  });
  const res = await handleImportMatch(post({ items: [{ raw_name: "One Piece", guessed_type: "tv" }] }), { requireUser: requireUserOk, db, tmdb: tmdb.factory });
  const m = (await res.json()).matches[0];
  assertEquals(m.confidence, "medium");
  assertEquals(m.candidates.map((c: { tmdb_id: number }) => c.tmdb_id), [37854, 111110, 999], "ordem por score, depois popularidade");
  assertEquals(m.candidates[0].score, 0.8);
  assertEquals(m.candidates[1].score, 0.8);
  assertEquals(m.best.tmdb_id, 37854, "empate decidido pela popularidade");
  assert(m.candidates[2].score < 0.6, "parcial pouco popular fica baixo");
  assertEquals(db.titles.filter((t) => t.fetched_at.startsWith("1970")).length, 3, "um esboço por candidato");
  assertEquals(db.titles.find((t) => t.tmdb_id === 37854)!.is_anime, true);
});

Deno.test("import-match: filme com ':' sem resultado → busca de novo sem o subtítulo", async () => {
  const db = new FakeDb();
  const tmdb = tmdbByQuery({
    "Duna: Parte Dois": [],
    "Duna": [movie(693134, "Duna: Parte Dois", { release_date: "2024-02-27", popularity: 500 }), movie(438631, "Duna", { release_date: "2021-09-15", popularity: 300 })],
  });
  const res = await handleImportMatch(post({ items: [{ raw_name: "Duna: Parte Dois", guessed_type: "movie" }] }), { requireUser: requireUserOk, db, tmdb: tmdb.factory });
  const body = await res.json();
  assertEquals(body.upstream_calls, 2);
  const m = body.matches[0];
  assertEquals(m.confidence, "high", "o título completo bate exato na 2ª busca; 'Duna' é só parcial e não anula o bônus de único");
  assertEquals(m.best.tmdb_id, 693134);
  assertEquals(m.best.score, 0.9);
  assertEquals(m.candidates.length, 2);
  assertEquals(m.candidates[1].score, 0.5, "parcial + tipo");
});

Deno.test("import-match: tipo incerto usa /search/multi, ignora pessoas e tenta alt_query", async () => {
  const db = new FakeDb();
  const tmdb = tmdbByQuery({
    "Star Wars": [{ media_type: "person", id: 1, name: "Mark Hamill" }],
    "Star Wars: Episódio IV: Uma Nova Esperança": [
      { media_type: "movie", ...movie(11, "Star Wars: Episódio IV - Uma Nova Esperança", { original_title: "Star Wars", release_date: "1977-05-25", popularity: 90 }) },
    ],
  });
  const res = await handleImportMatch(
    post({ items: [{ raw_name: "Star Wars", guessed_type: null, alt_query: "Star Wars: Episódio IV: Uma Nova Esperança" }] }),
    { requireUser: requireUserOk, db, tmdb: tmdb.factory },
  );
  const body = await res.json();
  assertEquals(tmdb.calls, ["/search/multi", "/search/multi"]);
  const m = body.matches[0];
  assertEquals(m.candidates.length, 1);
  assertEquals(m.candidates[0].media_type, "movie");
  // nome do CSV ("Star Wars") = original_title → 0,6; sem tipo (incerto); único relevante +0,1
  assertEquals(m.candidates[0].score, 0.7);
  assertEquals(m.confidence, "medium", "incerto nunca entra direto: a pessoa confirma");
});

Deno.test("import-match: sem resultado → low sem candidatos; TMDB fora do ar num item não derruba o lote", async () => {
  const db = new FakeDb();
  const tmdb = fakeTmdb({
    "/search/": (params: Record<string, string>) => {
      if (params.query === "quebra") throw new Error("rede");
      return { results: params.query === "Oppenheimer" ? [movie(872585, "Oppenheimer", { release_date: "2023-07-19", popularity: 800 })] : [] };
    },
  });
  const res = await handleImportMatch(
    post({ items: [{ raw_name: "Trailer: Round 6", guessed_type: "movie" }, { raw_name: "quebra", guessed_type: "movie" }, { raw_name: "Oppenheimer", guessed_type: "movie" }] }),
    { requireUser: requireUserOk, db, tmdb: tmdb.factory },
  );
  const body = await res.json();
  assertEquals(body.matches.map((m: { confidence: string }) => m.confidence), ["low", "low", "high"]);
  assertEquals(body.matches[0].candidates, []);
  assertEquals(body.matches[0].best, null);
  assertEquals(body.matches[2].best.tmdb_id, 872585);
  assertEquals(tmdb.calls.length, 4, "2 para o trailer (nome e sem subtítulo), 1 que falhou, 1 do filme");
});

Deno.test("import-match: título já completo não vira esboço; nomes repetidos respondem uma vez", async () => {
  const db = new FakeDb();
  db.titles.push({
    id: "t-full", tmdb_id: 872585, media_type: "movie", title: "Oppenheimer", original_title: "Oppenheimer", overview: "x", poster_path: "/p.jpg",
    backdrop_path: null, release_date: "2023-07-19", genre_ids: [18], genres: ["Drama"], is_anime: false, origin_country: ["US"], original_language: "en",
    runtime_minutes: 180, episode_run_time: null, number_of_seasons: null, number_of_episodes: null, seasons: null, cast_top: null, status: "Released",
    vote_average: 8.1, popularity: 800, imdb_id: "tt15398776", fetched_at: "2026-10-22T00:00:00.000Z",
  });
  const tmdb = tmdbByQuery({ "Oppenheimer": [movie(872585, "Oppenheimer", { release_date: "2023-07-19", popularity: 800 })] });
  const res = await handleImportMatch(
    post({ items: [{ raw_name: "Oppenheimer", guessed_type: "movie" }, { raw_name: " Oppenheimer ", guessed_type: "movie" }] }),
    { requireUser: requireUserOk, db, tmdb: tmdb.factory },
  );
  const body = await res.json();
  assertEquals(body.matches.length, 1, "duplicata no lote colapsa");
  assertEquals(body.matches[0].best.title_id, "t-full", "usa o id do título existente");
  assertEquals(db.titles.find((t) => t.id === "t-full")!.fetched_at, "2026-10-22T00:00:00.000Z", "não rebaixa para esboço");
  assertEquals(db.titles.find((t) => t.id === "t-full")!.runtime_minutes, 180);
});

Deno.test("import-match: valida o corpo (vazio, > 100, sem raw_name)", async () => {
  const db = new FakeDb();
  const tmdb = tmdbByQuery({});
  const deps = { requireUser: requireUserOk, db, tmdb: tmdb.factory };
  const empty = await handleImportMatch(post({ items: [] }), deps).catch((e) => e);
  assertEquals(empty.status, 400);
  const many = await handleImportMatch(post({ items: Array.from({ length: 101 }, (_, i) => ({ raw_name: `n${i}` })) }), deps).catch((e) => e);
  assertEquals(many.status, 400);
  const blank = await handleImportMatch(post({ items: [{ raw_name: "   " }] }), deps).catch((e) => e);
  assertEquals(blank.status, 400);
  assertEquals(tmdb.calls.length, 0);
});
