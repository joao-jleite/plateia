// import-match · { items: [{ raw_name, guessed_type?, year?, alt_query? }] } (≤ 100)
//   → { matches: [{ raw_name, confidence, best, candidates }], upstream_calls }
// Casa os nomes agrupados do CSV da Netflix (o app já leu e agrupou no aparelho;
// o arquivo nunca chega aqui) com títulos do TMDB em pt-BR. Para cada candidato
// cria uma linha-esboço em `titles` (fetched_at = 1970, renova ao abrir).
// Pontuação e limiares: docs/ARQUITETURA.md §9.

import { badRequest, json, readJson } from "../_shared/http.ts";
import { buildLogLine, Counter, logLine } from "../_shared/log.ts";
import type { CatalogDb } from "../_shared/supabase.ts";
import { isAnime, type Json, type TmdbClient, yearOf } from "../_shared/tmdb.ts";
import type { AuthUser, ImportCandidate, MediaType, TitleSketch } from "../_shared/types.ts";

export const MAX_ITEMS = 100;
export const MAX_CANDIDATES = 3;

export type Confidence = "high" | "medium" | "low";

export interface ImportItem {
  raw_name: string;
  /// Palpite do agrupador: padrão de temporada ⇒ tv; título puro ⇒ movie; null = incerto.
  guessed_type: MediaType | null;
  year: number | null;
  /// Consulta alternativa (ex.: o título completo de um filme com ":" no nome).
  alt_query: string | null;
}

export interface Match {
  raw_name: string;
  confidence: Confidence;
  best: ImportCandidate | null;
  candidates: ImportCandidate[];
}

export interface ImportMatchDeps {
  requireUser(req: Request): Promise<AuthUser>;
  db: CatalogDb;
  tmdb(counter: Counter): TmdbClient;
}

// ────────────────────────────────────────────────────────────────────────────
// Normalização e pontuação (puras; testadas em tests/import_match_test.ts)
// ────────────────────────────────────────────────────────────────────────────

/// Minúsculas, sem acento nem pontuação, espaços colapsados. É a chave de
/// comparação entre o nome do CSV e `title`/`original_title` do TMDB.
export function normalizeName(s: string): string {
  return s
    .toLowerCase()
    .normalize("NFD")
    .replace(/[̀-ͯ]/g, "") // tira só os acentos latinos…
    .normalize("NFC") // …e recompõe o resto (katakana com dakuten voltaria quebrado)
    .replace(/&/g, " e ")
    .replace(/[^\p{L}\p{N}]+/gu, " ")
    .replace(/\s+/g, " ")
    .trim();
}

/// Popularidade a partir da qual um resultado conta como "relevante" para o
/// bônus de resultado único (§9). Abaixo disso é ruído do /search.
export const RELEVANT_POPULARITY = 1;

export interface Scored {
  tmdb_id: number;
  media_type: MediaType;
  title: string;
  original_title: string | null;
  year: number | null;
  poster_path: string | null;
  popularity: number;
  score: number;
  raw: Json;
}

/// O nome do CSV é igual ao título ou ao original do resultado?
export function isExactName(rawName: string, r: { title: string; original_title: string | null }): boolean {
  const wanted = normalizeName(rawName);
  if (!wanted) return false;
  return wanted === normalizeName(r.title) || (!!r.original_title && wanted === normalizeName(r.original_title));
}

/// Pontuação de um resultado do TMDB para um item (§9):
///  +0,6 nome normalizado igual ao título ou ao original; +0,3 se um contém o
///  outro (parcial: cai em medium para a pessoa ver os candidatos);
///  +0,2 tipo bate com o palpite; +0,1 ano bate (o CSV simples não traz ano);
///  +0,1 se este é o ÚNICO resultado exato com popularidade relevante
///  (`exactRelevantCount` = quantos resultados da busca casam exato e são
///  relevantes). Sem ano, é esse bônus que leva "exato + tipo" (0,8) a `high`;
///  um homônimo relevante o anula e o caso vai para a revisão.
export function scoreResult(
  item: Pick<ImportItem, "raw_name" | "guessed_type" | "year">,
  r: { title: string; original_title: string | null; media_type: MediaType; year: number | null; popularity: number },
  exactRelevantCount: number,
): number {
  const wanted = normalizeName(item.raw_name);
  const title = normalizeName(r.title);
  const original = r.original_title ? normalizeName(r.original_title) : "";
  const exact = isExactName(item.raw_name, r);
  let score = 0;
  if (exact) {
    score += 0.6;
  } else if (wanted.length >= 4 && (title.includes(wanted) || original.includes(wanted) || (title.length >= 4 && wanted.includes(title)))) {
    score += 0.3;
  }
  if (item.guessed_type && item.guessed_type === r.media_type) score += 0.2;
  if (item.year && r.year === item.year) score += 0.1;
  if (exact && exactRelevantCount === 1 && r.popularity >= RELEVANT_POPULARITY) score += 0.1;
  return Math.round(score * 100) / 100;
}

/// high ≥ 0,9 sem segundo ≥ 0,8; medium 0,6–0,9; low < 0,6 (ou sem candidato).
export function confidenceFor(sorted: Array<{ score: number }>): Confidence {
  const best = sorted[0]?.score ?? 0;
  const second = sorted[1]?.score ?? 0;
  if (best >= 0.9 && second < 0.8) return "high";
  if (best >= 0.6) return "medium";
  return "low";
}

/// Resultado bruto do /search (movie, tv ou multi) → forma pontuável. null = pessoa/lixo.
export function toScorable(raw: Json, mediaTypeHint?: MediaType): Omit<Scored, "score"> | null {
  if (!raw || typeof raw !== "object" || typeof raw.id !== "number") return null;
  const mediaType: MediaType | undefined = raw.media_type ?? mediaTypeHint;
  if (mediaType !== "movie" && mediaType !== "tv") return null;
  const isMovie = mediaType === "movie";
  const title: string | undefined = isMovie ? (raw.title ?? raw.original_title) : (raw.name ?? raw.original_name);
  if (!title) return null;
  return {
    tmdb_id: raw.id,
    media_type: mediaType,
    title,
    original_title: (isMovie ? raw.original_title : raw.original_name) ?? null,
    year: yearOf(isMovie ? raw.release_date : raw.first_air_date),
    poster_path: raw.poster_path ?? null,
    popularity: typeof raw.popularity === "number" ? raw.popularity : 0,
    raw,
  };
}

/// Pontua, ordena (score, depois popularidade) e corta em MAX_CANDIDATES.
export function rankResults(item: ImportItem, results: Array<Omit<Scored, "score">>): Scored[] {
  const exactRelevantCount = results.filter((r) => r.popularity >= RELEVANT_POPULARITY && isExactName(item.raw_name, r)).length;
  return results
    .map((r) => ({ ...r, score: scoreResult(item, r, exactRelevantCount) }))
    .sort((a, b) => b.score - a.score || b.popularity - a.popularity)
    .slice(0, MAX_CANDIDATES);
}

export function toSketch(s: Scored): TitleSketch {
  const raw = s.raw;
  const genreIds: number[] = Array.isArray(raw.genre_ids) ? raw.genre_ids : [];
  const originCountry: string[] = Array.isArray(raw.origin_country) ? raw.origin_country : [];
  return {
    tmdb_id: s.tmdb_id,
    media_type: s.media_type,
    title: s.title,
    original_title: s.original_title,
    overview: raw.overview || null,
    poster_path: s.poster_path,
    backdrop_path: raw.backdrop_path ?? null,
    release_date: (s.media_type === "movie" ? raw.release_date : raw.first_air_date) || null,
    genre_ids: genreIds,
    is_anime: isAnime(genreIds, raw.original_language, originCountry),
    origin_country: originCountry,
    original_language: raw.original_language ?? null,
    vote_average: typeof raw.vote_average === "number" ? Math.round(raw.vote_average * 10) / 10 : null,
    popularity: s.popularity || null,
  };
}

// ────────────────────────────────────────────────────────────────────────────
// Busca no TMDB
// ────────────────────────────────────────────────────────────────────────────

/// Estratégia por item (docs/decisoes-apis.md): tipo conhecido → /search/{tipo};
/// incerto → /search/multi (sem pessoas). Sem resultado e com ":" no nome →
/// tenta de novo sem o subtítulo; ainda nada e há alt_query → tenta a alternativa.
export async function searchCandidates(item: ImportItem, tmdb: TmdbClient): Promise<Array<Omit<Scored, "score">>> {
  const path = item.guessed_type ? `/search/${item.guessed_type}` : "/search/multi";
  const run = async (query: string) => {
    const raw = await tmdb.get(path, { query, include_adult: "false", page: "1" });
    const list: Json[] = Array.isArray(raw?.results) ? raw.results : [];
    return list.map((r) => toScorable(r, item.guessed_type ?? undefined)).filter((r): r is Omit<Scored, "score"> => r !== null);
  };

  let results = await run(item.raw_name);
  if (results.length === 0 && item.raw_name.includes(":")) {
    const short = item.raw_name.split(":")[0].trim();
    if (short.length >= 2 && normalizeName(short) !== normalizeName(item.raw_name)) results = await run(short);
  }
  if (results.length === 0 && item.alt_query && normalizeName(item.alt_query) !== normalizeName(item.raw_name)) {
    results = await run(item.alt_query);
  }
  return results;
}

// ────────────────────────────────────────────────────────────────────────────
// Handler
// ────────────────────────────────────────────────────────────────────────────

function parseItems(body: Record<string, unknown>): ImportItem[] {
  const raw = body.items;
  if (!Array.isArray(raw) || raw.length === 0) throw badRequest("Informe items (lista de nomes).");
  if (raw.length > MAX_ITEMS) throw badRequest(`Até ${MAX_ITEMS} nomes por chamada.`);
  const seen = new Set<string>();
  const items: ImportItem[] = [];
  for (const r of raw) {
    if (!r || typeof r !== "object") throw badRequest("Item inválido.");
    const o = r as Record<string, unknown>;
    const name = typeof o.raw_name === "string" ? o.raw_name.trim() : "";
    if (!name) throw badRequest("Item sem raw_name.");
    if (name.length > 200) throw badRequest("Nome longo demais.");
    if (seen.has(name)) continue; // o app não deveria repetir; se repetir, respondemos uma vez
    seen.add(name);
    const type = o.guessed_type === "movie" || o.guessed_type === "tv" ? (o.guessed_type as MediaType) : null;
    const year = Number.isInteger(o.year) && (o.year as number) > 1800 ? (o.year as number) : null;
    const alt = typeof o.alt_query === "string" && o.alt_query.trim() ? o.alt_query.trim().slice(0, 200) : null;
    items.push({ raw_name: name, guessed_type: type, year, alt_query: alt });
  }
  return items;
}

export async function handleImportMatch(req: Request, deps: ImportMatchDeps): Promise<Response> {
  const startedAt = Date.now();
  const user = await deps.requireUser(req);
  const items = parseItems(await readJson(req));

  const counter = new Counter();
  const tmdb = deps.tmdb(counter); // o cliente real limita a 5 chamadas em voo

  // Busca e pontua tudo em paralelo (o semáforo do cliente segura o rate limit).
  const ranked: Scored[][] = await Promise.all(items.map(async (item) => {
    try {
      return rankResults(item, await searchCandidates(item, tmdb));
    } catch (err) {
      // TMDB fora do ar para um nome não derruba a importação: vira "low" sem candidatos
      console.error("import-match item", item.raw_name, err instanceof Error ? err.message : err);
      return [];
    }
  }));

  // Um esboço por candidato distinto, numa ida só ao banco.
  const byKey = new Map<string, Scored>();
  for (const list of ranked) for (const s of list) byKey.set(`${s.tmdb_id}:${s.media_type}`, s);
  const ids = await deps.db.ensureTitleSketches([...byKey.values()].map(toSketch));
  const idByKey = new Map(ids.map((t) => [`${t.tmdb_id}:${t.media_type}`, t.id]));

  const matches: Match[] = items.map((item, i) => {
    const candidates: ImportCandidate[] = ranked[i]
      .map((s) => ({
        title_id: idByKey.get(`${s.tmdb_id}:${s.media_type}`) ?? "",
        tmdb_id: s.tmdb_id,
        media_type: s.media_type,
        title: s.title,
        year: s.year,
        poster_path: s.poster_path,
        score: s.score,
      }))
      .filter((c) => c.title_id !== "");
    const confidence = confidenceFor(candidates);
    return { raw_name: item.raw_name, confidence, best: confidence === "low" ? null : candidates[0] ?? null, candidates };
  });

  const tally = { high: 0, medium: 0, low: 0 };
  for (const m of matches) tally[m.confidence]++;
  logLine(buildLogLine("import-match", user.id, startedAt, counter.n, { items: items.length, ...tally }));
  return json({ matches, upstream_calls: counter.n });
}
