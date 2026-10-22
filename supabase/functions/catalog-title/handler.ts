// catalog-title · { tmdb_id, media_type, force?, links? }
//   → { title, availability: [{...row, provider}], sync }
//
// Fluxo (docs/ARQUITETURA.md §10):
//   1. cache quente: zero chamada externa (log: upstream_calls: 0);
//   2. detalhe > 30 d ou providers > 7 d: 1 chamada TMDB (detalhe + watch/providers);
//   3. links > 7 d e cota ok (consume_api_quota('motn', 900)): 1 chamada MOTN;
//   4. cota estourada: links_status = 'quota', deep_link fica como estava;
//   5. force só renova se a última tiver mais de 24 h.

import { badRequest, json, notFound, readJson } from "../_shared/http.ts";
import { buildLogLine, Counter, logLine } from "../_shared/log.ts";
import { extractLinks, matchLinks, type MotnClient } from "../_shared/motn.ts";
import type { CatalogDb } from "../_shared/supabase.ts";
import { mapTitleInput, mapWatchProviders, type TmdbClient } from "../_shared/tmdb.ts";
import { decideRefresh, MOTN_MONTHLY_CAP } from "../_shared/ttl.ts";
import type { AuthUser, AvailabilityRow, LinksStatus, MediaType, ProviderRow, SyncRow, TitleRow } from "../_shared/types.ts";

export interface TitleDeps {
  requireUser(req: Request): Promise<AuthUser>;
  db: CatalogDb;
  tmdb(counter: Counter): TmdbClient;
  motn(counter: Counter): MotnClient;
  now?: () => number;
}

const REGION = "BR";

export async function handleTitle(req: Request, deps: TitleDeps): Promise<Response> {
  const startedAt = Date.now();
  const now = deps.now ? deps.now() : Date.now();
  const nowIso = new Date(now).toISOString();
  const user = await deps.requireUser(req);
  const body = await readJson(req);

  const tmdbId = body.tmdb_id;
  const mediaType = body.media_type;
  if (!Number.isInteger(tmdbId) || (tmdbId as number) <= 0) throw badRequest("tmdb_id inválido.");
  if (mediaType !== "movie" && mediaType !== "tv") throw badRequest("media_type deve ser movie ou tv.");
  const force = body.force === true;
  const wantLinks = body.links !== false;

  const counter = new Counter();
  const db = deps.db;

  let title: TitleRow | null = await db.getTitle(tmdbId as number, mediaType as MediaType);
  let sync: SyncRow | null = title ? await db.getSync(title.id, REGION) : null;

  const decision = decideRefresh({
    titleFetchedAt: title?.fetched_at,
    providersFetchedAt: sync?.providers_fetched_at,
    linksFetchedAt: sync?.links_fetched_at,
    force,
    wantLinks,
    now,
  });

  // 2. TMDB: detalhe + créditos + ids externos + onde assistir, numa chamada só.
  if (decision.fetchTmdb) {
    const raw = await deps.tmdb(counter).get(`/${mediaType}/${tmdbId}`, {
      append_to_response: "credits,external_ids,watch/providers",
    });
    if (!raw) throw notFound();

    title = await db.upsertTitle(mapTitleInput(raw, mediaType as MediaType), nowIso);

    const { offers } = mapWatchProviders(raw["watch/providers"], REGION);
    // providers desconhecidos (fora do seed) entram "lazy" com nome e logo do TMDB
    await db.ensureProviders(offers.map((o) => ({ ...o.provider })));

    // preserva deep_link ainda válido por (provider, tipo) ao trocar as linhas
    const previous = await db.getAvailability(title.id, REGION);
    const prevLink = new Map(previous.map((p) => [`${p.provider_id}:${p.offer_type}`, p]));
    const rows: AvailabilityRow[] = offers.map((o) => {
      const old = prevLink.get(`${o.provider.id}:${o.offer_type}`);
      return {
        title_id: title!.id,
        region: REGION,
        provider_id: o.provider.id,
        offer_type: o.offer_type,
        deep_link: old?.deep_link ?? null,
        deep_link_source: old?.deep_link_source ?? null,
        price_cents: old?.price_cents ?? null,
        fetched_at: nowIso,
        link_fetched_at: old?.link_fetched_at ?? null,
      };
    });
    await db.replaceAvailability(title.id, REGION, rows);
    sync = await db.upsertSync(title.id, REGION, { providers_fetched_at: nowIso });
  }

  if (!title) throw notFound();

  // 3–4. Links que abrem o app (gasta cota). Sem linhas de disponibilidade não há o que ligar.
  let availability = await db.getAvailability(title.id, REGION);
  if (decision.fetchLinks && availability.length > 0) {
    let status: LinksStatus;
    const allowed = await db.consumeQuota("motn", MOTN_MONTHLY_CAP);
    if (!allowed) {
      status = "quota";
    } else {
      try {
        const show = await deps.motn(counter).show(mediaType as MediaType, tmdbId as number, "br");
        if (!show) {
          status = "not_found";
        } else {
          const providerIds = [...new Set(availability.map((a) => a.provider_id))];
          const providers = await db.getProviders(providerIds);
          const byId = new Map(providers.map((p) => [p.id, p]));
          // variante (ex.: Netflix com anúncios) usa o motn_id do principal
          const motnIdOf = (id: number): string | null => {
            const p = byId.get(id);
            if (!p) return null;
            if (p.motn_id) return p.motn_id;
            return p.parent_id ? (byId.get(p.parent_id)?.motn_id ?? null) : null;
          };
          const matched = matchLinks(extractLinks(show, "br"), availability, motnIdOf);
          if (matched.length) await db.updateLinks(title.id, REGION, matched, nowIso);
          status = matched.length ? "ok" : "not_found";
        }
      } catch (err) {
        // erro na MOTN não derruba a tela: a interface cai no "Buscar na X"
        console.error("motn", err instanceof Error ? err.message : err);
        status = "error";
      }
    }
    sync = await db.upsertSync(title.id, REGION, { links_fetched_at: nowIso, links_status: status });
    availability = await db.getAvailability(title.id, REGION);
  }

  // Resposta com o streaming embutido em cada linha.
  const providers = await db.getProviders([...new Set(availability.map((a) => a.provider_id))]);
  const byId = new Map<number, ProviderRow>(providers.map((p) => [p.id, p]));
  // Variantes precisam do pai para a interface agrupar: inclui os pais faltantes.
  const parentIds = providers.map((p) => p.parent_id).filter((id): id is number => id != null && !byId.has(id));
  if (parentIds.length) for (const p of await db.getProviders(parentIds)) byId.set(p.id, p);

  const payload = availability
    .filter((a) => byId.has(a.provider_id))
    .map((a) => ({ ...a, provider: byId.get(a.provider_id) }));

  logLine(buildLogLine("catalog-title", user.id, startedAt, counter.n, {
    tmdb_id: tmdbId,
    media_type: mediaType,
    tmdb: decision.fetchTmdb,
    links: decision.fetchLinks,
    links_status: sync?.links_status ?? null,
  }));

  return json({
    title,
    availability: payload,
    sync: {
      providers_fetched_at: sync?.providers_fetched_at ?? null,
      links_fetched_at: sync?.links_fetched_at ?? null,
      links_status: sync?.links_status ?? null,
    },
  });
}
