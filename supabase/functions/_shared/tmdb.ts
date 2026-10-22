// Cliente do TMDB (token v4 de leitura) e as conversões para as linhas do banco.
// Só este arquivo conhece o formato do TMDB. Conversões são puras (tests/tmdb_test.ts).

import { Counter } from "./log.ts";
import { upstream } from "./http.ts";
import type { CatalogItem, CastJson, MediaType, OfferType, ProviderRow, SeasonJson, TitleInput } from "./types.ts";

export const TMDB_BASE = "https://api.themoviedb.org/3";
const MAX_CONCURRENT = 5; // rate limit do TMDB: ≤ 5 chamadas simultâneas por função

// deno-lint-ignore no-explicit-any
export type Json = any;

export interface TmdbClient {
  get(path: string, params?: Record<string, string>): Promise<Json>;
}

/// Semáforo simples para não passar de MAX_CONCURRENT chamadas em voo.
function semaphore(limit: number) {
  let active = 0;
  const queue: Array<() => void> = [];
  return async <T>(task: () => Promise<T>): Promise<T> => {
    if (active >= limit) await new Promise<void>((resolve) => queue.push(resolve));
    active++;
    try {
      return await task();
    } finally {
      active--;
      queue.shift()?.();
    }
  };
}

export function createTmdbClient(
  token: string,
  counter: Counter,
  fetchImpl: typeof fetch = fetch,
): TmdbClient {
  const limiter = semaphore(MAX_CONCURRENT);
  return {
    get(path, params = {}) {
      return limiter(async () => {
        const url = new URL(TMDB_BASE + path);
        url.searchParams.set("language", "pt-BR");
        for (const [k, v] of Object.entries(params)) url.searchParams.set(k, v);
        counter.inc();
        let res: Response;
        try {
          res = await fetchImpl(url, { headers: { Authorization: `Bearer ${token}`, Accept: "application/json" } });
        } catch (err) {
          throw upstream(`TMDB fora do ar (${err instanceof Error ? err.message : "rede"}).`);
        }
        if (res.status === 404) return null;
        if (!res.ok) throw upstream(`TMDB respondeu ${res.status}.`);
        return await res.json();
      });
    },
  };
}

const ANIMATION_GENRE = 16;

/// Anime = Animação (16) com origem JP ou idioma japonês (decisão do schema).
export function isAnime(genreIds: number[], originalLanguage?: string | null, originCountry?: string[] | null): boolean {
  if (!genreIds.includes(ANIMATION_GENRE)) return false;
  return originalLanguage === "ja" || (originCountry ?? []).includes("JP");
}

export function yearOf(date: string | null | undefined): number | null {
  if (!date || date.length < 4) return null;
  const y = Number(date.slice(0, 4));
  return Number.isFinite(y) ? y : null;
}

/// Item de /search/multi, /trending e /discover → CatalogItem. `null` para pessoas e lixo.
export function mapCatalogItem(raw: Json, mediaTypeHint?: MediaType): CatalogItem | null {
  if (!raw || typeof raw !== "object") return null;
  const mediaType: MediaType | undefined = raw.media_type ?? mediaTypeHint;
  if (mediaType !== "movie" && mediaType !== "tv") return null;
  const title: string | undefined = mediaType === "movie" ? (raw.title ?? raw.original_title) : (raw.name ?? raw.original_name);
  if (!title || typeof raw.id !== "number") return null;
  const genreIds: number[] = Array.isArray(raw.genre_ids) ? raw.genre_ids : [];
  return {
    tmdb_id: raw.id,
    media_type: mediaType,
    title,
    year: yearOf(mediaType === "movie" ? raw.release_date : raw.first_air_date),
    poster_path: raw.poster_path ?? null,
    is_anime: isAnime(genreIds, raw.original_language, raw.origin_country),
  };
}

/// Detalhe (/movie/{id} ou /tv/{id} com credits,external_ids) → linha de `titles`.
export function mapTitleInput(raw: Json, mediaType: MediaType): TitleInput {
  const genres: Array<{ id: number; name: string }> = Array.isArray(raw.genres) ? raw.genres : [];
  const genreIds = genres.map((g) => g.id);
  const originCountry: string[] = Array.isArray(raw.origin_country) ? raw.origin_country : [];
  const cast: Json[] = Array.isArray(raw.credits?.cast) ? raw.credits.cast : [];
  const castTop: CastJson[] = cast
    .slice()
    .sort((a, b) => (a.order ?? 0) - (b.order ?? 0))
    .slice(0, 10)
    .map((c) => ({ name: c.name, character: c.character ?? c.roles?.[0]?.character ?? null, profile_path: c.profile_path ?? null }));

  const isMovie = mediaType === "movie";
  const runTimes: number[] = Array.isArray(raw.episode_run_time) ? raw.episode_run_time : [];
  const episodeRunTime = runTimes.length ? Math.round(runTimes.reduce((a, b) => a + b, 0) / runTimes.length) : (raw.last_episode_to_air?.runtime ?? null);
  const seasons: SeasonJson[] | null = Array.isArray(raw.seasons)
    ? raw.seasons.map((s: Json) => ({
      season_number: s.season_number,
      name: s.name,
      episode_count: s.episode_count ?? 0,
      air_date: s.air_date ?? null,
      poster_path: s.poster_path ?? null,
    }))
    : null;

  return {
    tmdb_id: raw.id,
    media_type: mediaType,
    title: (isMovie ? raw.title : raw.name) || (isMovie ? raw.original_title : raw.original_name) || `#${raw.id}`,
    original_title: (isMovie ? raw.original_title : raw.original_name) ?? null,
    overview: raw.overview || null,
    poster_path: raw.poster_path ?? null,
    backdrop_path: raw.backdrop_path ?? null,
    release_date: (isMovie ? raw.release_date : raw.first_air_date) || null,
    genre_ids: genreIds,
    genres: genres.map((g) => g.name),
    is_anime: isAnime(genreIds, raw.original_language, originCountry),
    origin_country: originCountry,
    original_language: raw.original_language ?? null,
    runtime_minutes: isMovie ? (raw.runtime || null) : null,
    episode_run_time: isMovie ? null : episodeRunTime,
    number_of_seasons: isMovie ? null : (raw.number_of_seasons ?? null),
    number_of_episodes: isMovie ? null : (raw.number_of_episodes ?? null),
    seasons: isMovie ? null : seasons,
    cast_top: castTop,
    status: raw.status ?? null,
    vote_average: typeof raw.vote_average === "number" ? Math.round(raw.vote_average * 10) / 10 : null,
    popularity: typeof raw.popularity === "number" ? raw.popularity : null,
    imdb_id: raw.imdb_id ?? raw.external_ids?.imdb_id ?? null,
  };
}

export interface ProviderOffer {
  provider: Pick<ProviderRow, "id" | "name" | "logo_path"> & { display_priority: number | null };
  offer_type: OfferType;
}

const OFFER_KEYS: OfferType[] = ["flatrate", "ads", "free", "rent", "buy"];

/// `watch/providers.results.BR` → ofertas por streaming (sem duplicar provider×tipo).
export function mapWatchProviders(raw: Json, region = "BR"): { offers: ProviderOffer[]; link: string | null } {
  const country = raw?.results?.[region];
  if (!country) return { offers: [], link: null };
  const seen = new Set<string>();
  const offers: ProviderOffer[] = [];
  for (const key of OFFER_KEYS) {
    const list: Json[] = Array.isArray(country[key]) ? country[key] : [];
    for (const p of list) {
      if (typeof p?.provider_id !== "number") continue;
      const dedup = `${p.provider_id}:${key}`;
      if (seen.has(dedup)) continue;
      seen.add(dedup);
      offers.push({
        provider: {
          id: p.provider_id,
          name: p.provider_name ?? `#${p.provider_id}`,
          logo_path: p.logo_path ?? null,
          display_priority: typeof p.display_priority === "number" ? p.display_priority : null,
        },
        offer_type: key,
      });
    }
  }
  return { offers, link: typeof country.link === "string" ? country.link : null };
}

/// `/watch/providers/{movie,tv}` → linhas de `providers` (só nome, logo, prioridade BR).
export function mapProviderList(raw: Json, region = "BR"): Array<{ id: number; name: string; logo_path: string | null; display_priority: number | null }> {
  const results: Json[] = Array.isArray(raw?.results) ? raw.results : [];
  return results
    .filter((p) => typeof p?.provider_id === "number")
    .map((p) => ({
      id: p.provider_id,
      name: p.provider_name ?? `#${p.provider_id}`,
      logo_path: p.logo_path ?? null,
      display_priority: typeof p.display_priorities?.[region] === "number"
        ? p.display_priorities[region]
        : (typeof p.display_priority === "number" ? p.display_priority : null),
    }));
}
