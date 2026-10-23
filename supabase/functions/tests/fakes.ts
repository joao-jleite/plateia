// Fakes em memória para testar os handlers sem Supabase nem rede.

import type { AccountAdmin, CatalogDb } from "../_shared/supabase.ts";
import type { Counter } from "../_shared/log.ts";
import type { MotnClient } from "../_shared/motn.ts";
import type { Json, TmdbClient } from "../_shared/tmdb.ts";
import type { AuthUser, AvailabilityRow, HomeSectionRow, MediaType, OfferType, ProviderRow, SyncRow, TitleInput, TitleRow, TitleSketch } from "../_shared/types.ts";

export const user: AuthUser = { id: "00000000-0000-4000-8000-000000000001", email: "a@teste.local" };
export const requireUserOk = (_req: Request) => Promise.resolve(user);

export function post(body: unknown): Request {
  return new Request("http://local/fn", {
    method: "POST",
    headers: { "Content-Type": "application/json", Authorization: "Bearer x" },
    body: JSON.stringify(body),
  });
}

export const seedProviders: ProviderRow[] = [
  { id: 8, slug: "netflix", name: "Netflix", logo_path: null, motn_id: "netflix", android_package: "com.netflix.mediaclient", web_domain: "www.netflix.com", search_url_template: "https://www.netflix.com/search?q={q}", is_featured: true, display_order: 1, parent_id: null, active: true },
  { id: 283, slug: "crunchyroll", name: "Crunchyroll", logo_path: null, motn_id: "crunchyroll", android_package: "com.crunchyroll.crunchyroid", web_domain: "www.crunchyroll.com", search_url_template: "https://www.crunchyroll.com/pt-br/search?q={q}", is_featured: true, display_order: 8, parent_id: null, active: true },
  { id: 1899, slug: "max", name: "HBO Max", logo_path: null, motn_id: "hbo", android_package: "com.wbd.stream", web_domain: "play.hbomax.com", search_url_template: "https://play.hbomax.com/search?q={q}", is_featured: true, display_order: 4, parent_id: null, active: true },
  { id: 307, slug: "globoplay", name: "Globoplay", logo_path: null, motn_id: null, android_package: "com.globo.globotv", web_domain: "globoplay.globo.com", search_url_template: "https://globoplay.globo.com/busca/?q={q}", is_featured: true, display_order: 5, parent_id: null, active: true },
  { id: 1796, slug: null, name: "Netflix com anúncios", logo_path: null, motn_id: null, android_package: null, web_domain: null, search_url_template: null, is_featured: false, display_order: null, parent_id: 8, active: true },
];

export class FakeDb implements CatalogDb {
  titles: TitleRow[] = [];
  syncs: SyncRow[] = [];
  availability: AvailabilityRow[] = [];
  providers: ProviderRow[] = seedProviders.map((p) => ({ ...p }));
  home: HomeSectionRow[] = [];
  quotaCalls = 0;
  quotaAllowed = true;
  private seq = 1;

  getTitle(tmdbId: number, mediaType: MediaType) {
    return Promise.resolve(this.titles.find((t) => t.tmdb_id === tmdbId && t.media_type === mediaType) ?? null);
  }
  upsertTitle(input: TitleInput, fetchedAt: string) {
    const existing = this.titles.find((t) => t.tmdb_id === input.tmdb_id && t.media_type === input.media_type);
    if (existing) {
      Object.assign(existing, input, { fetched_at: fetchedAt });
      return Promise.resolve(existing);
    }
    const row: TitleRow = { ...input, id: `t-${this.seq++}`, fetched_at: fetchedAt };
    this.titles.push(row);
    return Promise.resolve(row);
  }
  getSync(titleId: string, region: string) {
    return Promise.resolve(this.syncs.find((s) => s.title_id === titleId && s.region === region) ?? null);
  }
  upsertSync(titleId: string, region: string, patch: Partial<SyncRow>) {
    let s = this.syncs.find((x) => x.title_id === titleId && x.region === region);
    if (!s) {
      s = { title_id: titleId, region, providers_fetched_at: null, links_fetched_at: null, links_status: null };
      this.syncs.push(s);
    }
    Object.assign(s, patch);
    return Promise.resolve({ ...s });
  }
  getAvailability(titleId: string, region: string) {
    return Promise.resolve(this.availability.filter((a) => a.title_id === titleId && a.region === region).map((a) => ({ ...a })));
  }
  replaceAvailability(titleId: string, region: string, rows: AvailabilityRow[]) {
    this.availability = this.availability.filter((a) => !(a.title_id === titleId && a.region === region)).concat(rows.map((r) => ({ ...r })));
    return Promise.resolve();
  }
  updateLinks(titleId: string, region: string, links: Array<{ provider_id: number; offer_type: OfferType; deep_link: string }>, fetchedAt: string) {
    for (const l of links) {
      const row = this.availability.find((a) => a.title_id === titleId && a.region === region && a.provider_id === l.provider_id && a.offer_type === l.offer_type);
      if (row) Object.assign(row, { deep_link: l.deep_link, deep_link_source: "motn", link_fetched_at: fetchedAt });
    }
    return Promise.resolve();
  }
  getProviders(ids: number[]) {
    return Promise.resolve(this.providers.filter((p) => ids.includes(p.id)).map((p) => ({ ...p })));
  }
  ensureProviders(rows: Array<{ id: number; name: string; logo_path: string | null; display_priority: number | null }>) {
    for (const r of rows) {
      if (!this.providers.some((p) => p.id === r.id)) {
        this.providers.push({ id: r.id, slug: null, name: r.name, logo_path: r.logo_path, motn_id: null, android_package: null, web_domain: null, search_url_template: null, is_featured: false, display_order: r.display_priority, parent_id: null, active: true });
      }
    }
    return Promise.resolve();
  }
  upsertProviderCatalog(rows: Array<{ id: number; name: string; logo_path: string | null; display_priority: number | null }>) {
    for (const r of rows) {
      const p = this.providers.find((x) => x.id === r.id);
      if (p) {
        p.logo_path = r.logo_path;
        if (!p.is_featured) {
          p.name = r.name;
          p.display_order = r.display_priority;
        }
      } else {
        this.providers.push({ id: r.id, slug: null, name: r.name, logo_path: r.logo_path, motn_id: null, android_package: null, web_domain: null, search_url_template: null, is_featured: false, display_order: r.display_priority, parent_id: null, active: true });
      }
    }
    return Promise.resolve(rows.length);
  }
  getFeaturedProviders() {
    return Promise.resolve(this.providers.filter((p) => p.is_featured && p.active).sort((a, b) => (a.display_order ?? 99) - (b.display_order ?? 99)));
  }
  consumeQuota(_api: "tmdb" | "motn", _cap: number) {
    this.quotaCalls++;
    return Promise.resolve(this.quotaAllowed);
  }
  getHomeSections(region: string) {
    return Promise.resolve(this.home.filter((h) => h.region === region).map((h) => ({ ...h })));
  }
  upsertHomeSections(rows: HomeSectionRow[]) {
    for (const r of rows) {
      const i = this.home.findIndex((h) => h.key === r.key);
      if (i >= 0) this.home[i] = { ...r };
      else this.home.push({ ...r });
    }
    return Promise.resolve();
  }
  ensureTitleSketches(rows: TitleSketch[]) {
    const out: Array<Pick<TitleRow, "id" | "tmdb_id" | "media_type">> = [];
    for (const r of rows) {
      let t = this.titles.find((x) => x.tmdb_id === r.tmdb_id && x.media_type === r.media_type);
      if (!t) {
        t = {
          ...r,
          id: `t-${this.seq++}`,
          runtime_minutes: null, episode_run_time: null, number_of_seasons: null, number_of_episodes: null,
          seasons: null, cast_top: null, status: null, imdb_id: null, genres: [],
          fetched_at: "1970-01-01T00:00:00.000Z",
        };
        this.titles.push(t);
      }
      if (!out.some((o) => o.id === t!.id)) out.push({ id: t.id, tmdb_id: t.tmdb_id, media_type: t.media_type });
    }
    return Promise.resolve(out);
  }
}

/// TMDB falso: responde por prefixo de path e conta as chamadas no Counter.
export function fakeTmdb(routes: Record<string, Json | ((params: Record<string, string>) => Json)>) {
  const calls: string[] = [];
  const factory = (counter: Counter): TmdbClient => ({
    get(path, params = {}) {
      counter.inc();
      calls.push(path);
      for (const [prefix, value] of Object.entries(routes)) {
        if (path.startsWith(prefix)) return Promise.resolve(typeof value === "function" ? value(params) : value);
      }
      return Promise.resolve(null);
    },
  });
  return { factory, calls };
}

export function fakeMotn(show: Json | null) {
  const calls: string[] = [];
  const factory = (counter: Counter): MotnClient => ({
    show(mediaType, tmdbId) {
      counter.inc();
      calls.push(`${mediaType}/${tmdbId}`);
      return Promise.resolve(show);
    },
  });
  return { factory, calls };
}

export class FakeAdmin implements AccountAdmin {
  avatars: Record<string, string[]> = {};
  deleted: string[] = [];
  removed: string[] = [];
  listAvatarPaths(uid: string) {
    return Promise.resolve((this.avatars[uid] ?? []).map((n) => `${uid}/${n}`));
  }
  removeAvatars(paths: string[]) {
    this.removed.push(...paths);
    return Promise.resolve();
  }
  deleteUser(uid: string) {
    this.deleted.push(uid);
    return Promise.resolve();
  }
}

/// Resposta do TMDB para One Piece (tv 37854) com créditos e onde assistir.
export const onePieceTmdb: Json = {
  id: 37854,
  name: "One Piece",
  original_name: "ワンピース",
  overview: "Monkey D. Luffy quer ser o Rei dos Piratas…",
  poster_path: "/cMD9Ygz11zjJzAovURpO75Qg7rT.jpg",
  backdrop_path: "/x.jpg",
  first_air_date: "1999-10-20",
  genres: [{ id: 10759, name: "Action & Adventure" }, { id: 16, name: "Animação" }],
  origin_country: ["JP"],
  original_language: "ja",
  episode_run_time: [24],
  number_of_seasons: 22,
  number_of_episodes: 1140,
  seasons: [{ season_number: 1, name: "East Blue", episode_count: 61, air_date: "1999-10-20", poster_path: null }],
  status: "Returning Series",
  vote_average: 8.73,
  popularity: 300.5,
  credits: { cast: [{ name: "Mayumi Tanaka", character: "Luffy (voice)", profile_path: null, order: 0 }] },
  external_ids: { imdb_id: "tt0388629" },
  "watch/providers": {
    results: {
      BR: {
        link: "https://www.themoviedb.org/tv/37854/watch?locale=BR",
        flatrate: [
          { provider_id: 8, provider_name: "Netflix", logo_path: "/n.jpg", display_priority: 0 },
          { provider_id: 283, provider_name: "Crunchyroll", logo_path: "/c.jpg", display_priority: 10 },
          { provider_id: 9999, provider_name: "Novo Streaming", logo_path: "/novo.jpg", display_priority: 40 },
        ],
        ads: [{ provider_id: 1796, provider_name: "Netflix basic with Ads", logo_path: "/n.jpg", display_priority: 1 }],
      },
    },
  },
};

export const onePieceMotn: Json = {
  id: "1234",
  tmdbId: "tv/37854",
  streamingOptions: {
    br: [
      { service: { id: "netflix", name: "Netflix" }, type: "subscription", link: "https://www.netflix.com/title/80107103" },
      { service: { id: "crunchyroll", name: "Crunchyroll" }, type: "subscription", link: "https://www.crunchyroll.com/pt-br/series/GRMG8ZQZR/one-piece" },
      { service: { id: "hbo", name: "HBO Max" }, type: "subscription", link: "https://play.max.com/show/urn:hbo:series:X" },
      { service: { id: "prime", name: "Prime Video" }, type: "addon", link: "https://www.primevideo.com/x" },
    ],
  },
};
