// home-sections · {} → { sections: [{ key, title, items }], fetched_at }
// Cache de 6 h em `home_sections`. Renovação = 1 chamada de trending + 2 por
// streaming destacado (discover movie + tv): 17 com os 8 do seed.

import { json } from "../_shared/http.ts";
import { buildLogLine, Counter, logLine } from "../_shared/log.ts";
import type { CatalogDb } from "../_shared/supabase.ts";
import { mapCatalogItem, type TmdbClient } from "../_shared/tmdb.ts";
import { isStale, TTL } from "../_shared/ttl.ts";
import type { AuthUser, CatalogItem, HomeSectionRow, ProviderRow } from "../_shared/types.ts";

export interface HomeDeps {
  requireUser(req: Request): Promise<AuthUser>;
  db: CatalogDb;
  tmdb(counter: Counter): TmdbClient;
  now?: () => number;
}

const REGION = "BR";
const TRENDING_KEY = "trending_all";
const ITEMS_PER_SECTION = 20;

/// "na Netflix", "no Prime Video"… (mesma tabela do app).
export function sectionTitle(p: Pick<ProviderRow, "slug" | "name">): string {
  const na = new Set(["netflix", "max", "apple", "crunchyroll"]);
  const no = new Set(["prime", "disney", "globoplay", "paramount"]);
  const prep = p.slug && na.has(p.slug) ? "na" : p.slug && no.has(p.slug) ? "no" : "em";
  return `Novidades ${prep} ${p.name}`;
}

export const providerKey = (id: number) => `new_on_${id}`;

function isoDaysAgo(now: number, days: number): string {
  return new Date(now - days * 24 * 60 * 60 * 1000).toISOString().slice(0, 10);
}

/// Intercala filmes e séries (f, s, f, s…) e corta no limite.
export function interleave(a: CatalogItem[], b: CatalogItem[], limit = ITEMS_PER_SECTION): CatalogItem[] {
  const out: CatalogItem[] = [];
  const seen = new Set<string>();
  for (let i = 0; out.length < limit && (i < a.length || i < b.length); i++) {
    for (const item of [a[i], b[i]]) {
      if (!item) continue;
      const k = `${item.media_type}:${item.tmdb_id}`;
      if (seen.has(k)) continue;
      seen.add(k);
      if (out.length < limit) out.push(item);
    }
  }
  return out;
}

async function refresh(deps: HomeDeps, counter: Counter, now: number, featured: ProviderRow[]): Promise<HomeSectionRow[]> {
  const tmdb = deps.tmdb(counter);
  const nowIso = new Date(now).toISOString();
  const toItems = (raw: unknown, hint?: "movie" | "tv"): CatalogItem[] => {
    // deno-lint-ignore no-explicit-any
    const list: unknown[] = Array.isArray((raw as any)?.results) ? (raw as any).results : [];
    return list.map((r) => mapCatalogItem(r, hint)).filter((r): r is CatalogItem => r !== null);
  };

  // "Novidades na X" = o que é popular entre títulos lançados (filme) ou com
  // episódio novo (série) nos últimos 90 dias, disponível na assinatura de X.
  const since = isoDaysAgo(now, 90);
  const common = { watch_region: REGION, with_watch_monetization_types: "flatrate|ads|free", sort_by: "popularity.desc", include_adult: "false" };

  const [trending, ...perProvider] = await Promise.all([
    tmdb.get("/trending/all/day"),
    ...featured.map(async (p) => {
      const [movies, tv] = await Promise.all([
        tmdb.get("/discover/movie", { ...common, with_watch_providers: String(p.id), "primary_release_date.gte": since, "vote_count.gte": "5" }),
        tmdb.get("/discover/tv", { ...common, with_watch_providers: String(p.id), "air_date.gte": since, "vote_count.gte": "5" }),
      ]);
      return { provider: p, items: interleave(toItems(movies, "movie"), toItems(tv, "tv")) };
    }),
  ]);

  const rows: HomeSectionRow[] = [
    { key: TRENDING_KEY, region: REGION, payload: toItems(trending).slice(0, ITEMS_PER_SECTION), fetched_at: nowIso },
    ...perProvider.map(({ provider, items }) => ({ key: providerKey(provider.id), region: REGION, payload: items, fetched_at: nowIso })),
  ];
  await deps.db.upsertHomeSections(rows);
  return rows;
}

export async function handleHome(req: Request, deps: HomeDeps): Promise<Response> {
  const now = deps.now ? deps.now() : Date.now();
  const startedAt = Date.now();
  const user = await deps.requireUser(req);
  const counter = new Counter();

  const featured = await deps.db.getFeaturedProviders();
  const wanted = [TRENDING_KEY, ...featured.map((p) => providerKey(p.id))];
  let rows = await deps.db.getHomeSections(REGION);
  const byKey = new Map(rows.map((r) => [r.key, r]));
  const stale = wanted.some((k) => !byKey.has(k) || isStale(byKey.get(k)!.fetched_at, TTL.home, now));

  if (stale) {
    try {
      rows = await refresh(deps, counter, now, featured);
    } catch (err) {
      // Com cache velho na mão, melhor servir o velho do que erro na tela Início.
      if (rows.length === 0) throw err;
      console.error("home-sections refresh", err instanceof Error ? err.message : err);
    }
  }

  const byKeyFinal = new Map(rows.map((r) => [r.key, r]));
  const sections = [
    { key: TRENDING_KEY, title: "Em alta no Brasil", items: byKeyFinal.get(TRENDING_KEY)?.payload ?? [] },
    ...featured.map((p) => ({ key: providerKey(p.id), title: sectionTitle(p), items: byKeyFinal.get(providerKey(p.id))?.payload ?? [] })),
  ];
  const fetchedAt = rows.map((r) => r.fetched_at).sort()[0] ?? new Date(now).toISOString();

  logLine(buildLogLine("home-sections", user.id, startedAt, counter.n, { refreshed: stale && counter.n > 0 }));
  return json({ sections, fetched_at: fetchedAt });
}
