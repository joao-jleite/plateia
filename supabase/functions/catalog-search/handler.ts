// catalog-search · { q, page? } → { results, page, total_pages }
// TMDB /search/multi em pt-BR, região BR, sem pessoas. Não grava nada.

import { badRequest, json, readJson } from "../_shared/http.ts";
import { buildLogLine, Counter, logLine } from "../_shared/log.ts";
import { mapCatalogItem, type TmdbClient } from "../_shared/tmdb.ts";
import type { AuthUser, CatalogItem } from "../_shared/types.ts";

export interface SearchDeps {
  requireUser(req: Request): Promise<AuthUser>;
  tmdb(counter: Counter): TmdbClient;
}

export async function handleSearch(req: Request, deps: SearchDeps): Promise<Response> {
  const startedAt = Date.now();
  const user = await deps.requireUser(req);
  const body = await readJson(req);

  const q = typeof body.q === "string" ? body.q.trim() : "";
  if (!q) throw badRequest("Informe o que buscar (q).");
  if (q.length > 200) throw badRequest("Busca longa demais.");
  const page = Number.isInteger(body.page) && (body.page as number) >= 1 ? (body.page as number) : 1;

  const counter = new Counter();
  const raw = await deps.tmdb(counter).get("/search/multi", {
    query: q,
    page: String(page),
    region: "BR",
    include_adult: "false",
  });

  const results: CatalogItem[] = (Array.isArray(raw?.results) ? raw.results : [])
    .map((r: unknown) => mapCatalogItem(r))
    .filter((r: CatalogItem | null): r is CatalogItem => r !== null);

  logLine(buildLogLine("catalog-search", user.id, startedAt, counter.n, { q, results: results.length }));
  return json({ results, page: raw?.page ?? page, total_pages: raw?.total_pages ?? 1 });
}
