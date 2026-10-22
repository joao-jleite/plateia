// providers-sync · {} → { upserted, featured: [...], missing: [...] }
// Lê a lista de streamings do TMDB para o Brasil (filmes + séries), atualiza
// nome/logo/ordem em `providers` e confere os 8 destacados do seed: a resposta
// (e o log) mostram o nome que o TMDB dá a cada id. Id errado = nova migração.

import { json } from "../_shared/http.ts";
import { buildLogLine, Counter, logLine } from "../_shared/log.ts";
import type { CatalogDb } from "../_shared/supabase.ts";
import { mapProviderList, type TmdbClient } from "../_shared/tmdb.ts";
import type { AuthUser } from "../_shared/types.ts";

export interface SyncDeps {
  requireUser(req: Request): Promise<AuthUser>;
  db: CatalogDb;
  tmdb(counter: Counter): TmdbClient;
}

export interface FeaturedCheck {
  id: number;
  slug: string | null;
  seed_name: string;
  tmdb_name: string | null;
  found: boolean;
}

export async function handleProvidersSync(req: Request, deps: SyncDeps): Promise<Response> {
  const startedAt = Date.now();
  const user = await deps.requireUser(req);
  const counter = new Counter();
  const tmdb = deps.tmdb(counter);

  const [movies, tv] = await Promise.all([
    tmdb.get("/watch/providers/movie", { watch_region: "BR" }),
    tmdb.get("/watch/providers/tv", { watch_region: "BR" }),
  ]);
  const merged = new Map<number, { id: number; name: string; logo_path: string | null; display_priority: number | null }>();
  for (const p of [...mapProviderList(movies), ...mapProviderList(tv)]) {
    if (!merged.has(p.id)) merged.set(p.id, p);
  }

  const upserted = await deps.db.upsertProviderCatalog([...merged.values()]);

  const featured = await deps.db.getFeaturedProviders();
  const checks: FeaturedCheck[] = featured.map((f) => ({
    id: f.id,
    slug: f.slug,
    seed_name: f.name,
    tmdb_name: merged.get(f.id)?.name ?? null,
    found: merged.has(f.id),
  }));
  const missing = checks.filter((c) => !c.found).map((c) => c.id);

  logLine(buildLogLine("providers-sync", user.id, startedAt, counter.n, { upserted, missing, featured: checks }));
  return json({ upserted, featured: checks, missing });
}
