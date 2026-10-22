// Regras de cache e cota (docs/ARQUITETURA.md §10). Lógica pura, testada em
// tests/ttl_test.ts.

const HOUR = 60 * 60 * 1000;
const DAY = 24 * HOUR;

export const TTL = {
  title: 30 * DAY, // titles.fetched_at
  providers: 7 * DAY, // title_sync.providers_fetched_at
  links: 7 * DAY, // title_sync.links_fetched_at
  home: 6 * HOUR, // home_sections.fetched_at
  forceMin: 24 * HOUR, // `force` só renova se a última tiver mais de 24 h
} as const;

export const MOTN_MONTHLY_CAP = 900; // cota grátis é 1.000; o app para em 900

export function ageMs(fetchedAt: string | Date | null | undefined, now: number): number {
  if (!fetchedAt) return Number.POSITIVE_INFINITY;
  const t = typeof fetchedAt === "string" ? Date.parse(fetchedAt) : fetchedAt.getTime();
  if (Number.isNaN(t)) return Number.POSITIVE_INFINITY;
  return now - t;
}

export function isStale(fetchedAt: string | Date | null | undefined, ttl: number, now: number): boolean {
  return ageMs(fetchedAt, now) > ttl;
}

/// `force` vale só quando a última atualização tem mais de 24 h (evita gastar
/// cota com toques repetidos em "puxar para atualizar").
export function forceAllowed(fetchedAt: string | Date | null | undefined, now: number): boolean {
  return ageMs(fetchedAt, now) > TTL.forceMin;
}

export interface RefreshInput {
  titleFetchedAt: string | null | undefined;
  providersFetchedAt: string | null | undefined;
  linksFetchedAt: string | null | undefined;
  force: boolean;
  wantLinks: boolean;
  now: number;
}

export interface RefreshDecision {
  /// Uma chamada ao TMDB traz detalhe + watch/providers juntos (append_to_response).
  fetchTmdb: boolean;
  /// Chamada à Streaming Availability (gasta cota).
  fetchLinks: boolean;
}

export function decideRefresh(i: RefreshInput): RefreshDecision {
  const titleStale = isStale(i.titleFetchedAt, TTL.title, i.now);
  const providersStale = isStale(i.providersFetchedAt, TTL.providers, i.now);
  const linksStale = isStale(i.linksFetchedAt, TTL.links, i.now);

  const forceTmdb = i.force && forceAllowed(i.providersFetchedAt, i.now);
  const forceLinks = i.force && forceAllowed(i.linksFetchedAt, i.now);

  return {
    fetchTmdb: titleStale || providersStale || forceTmdb,
    fetchLinks: i.wantLinks && (linksStale || forceLinks),
  };
}
