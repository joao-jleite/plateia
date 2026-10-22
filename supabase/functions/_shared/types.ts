// Linhas das tabelas que as funções leem e escrevem (supabase/migrations/0001_init.sql).

export type MediaType = "movie" | "tv";
export type OfferType = "flatrate" | "ads" | "free" | "rent" | "buy";

export interface TitleRow {
  id: string;
  tmdb_id: number;
  media_type: MediaType;
  title: string;
  original_title: string | null;
  overview: string | null;
  poster_path: string | null;
  backdrop_path: string | null;
  release_date: string | null;
  year?: number | null;
  genre_ids: number[];
  genres: string[];
  is_anime: boolean;
  origin_country: string[];
  original_language: string | null;
  runtime_minutes: number | null;
  episode_run_time: number | null;
  number_of_seasons: number | null;
  number_of_episodes: number | null;
  seasons: SeasonJson[] | null;
  cast_top: CastJson[] | null;
  status: string | null;
  vote_average: number | null;
  popularity: number | null;
  imdb_id: string | null;
  fetched_at: string;
}

/// O que o TMDB devolve, sem o `id` (o banco gera) e sem `fetched_at`.
export type TitleInput = Omit<TitleRow, "id" | "fetched_at" | "year">;

export interface SeasonJson {
  season_number: number;
  name: string;
  episode_count: number;
  air_date: string | null;
  poster_path: string | null;
}

export interface CastJson {
  name: string;
  character: string | null;
  profile_path: string | null;
}

export interface ProviderRow {
  id: number;
  slug: string | null;
  name: string;
  logo_path: string | null;
  motn_id: string | null;
  android_package: string | null;
  web_domain: string | null;
  search_url_template: string | null;
  is_featured: boolean;
  display_order: number | null;
  parent_id: number | null;
  active: boolean;
}

export interface AvailabilityRow {
  title_id: string;
  region: string;
  provider_id: number;
  offer_type: OfferType;
  deep_link: string | null;
  deep_link_source: "motn" | "tmdb" | null;
  price_cents: number | null;
  fetched_at: string;
  link_fetched_at: string | null;
}

export type LinksStatus = "ok" | "not_found" | "quota" | "error";

export interface SyncRow {
  title_id: string;
  region: string;
  providers_fetched_at: string | null;
  links_fetched_at: string | null;
  links_status: LinksStatus | null;
}

export interface CatalogItem {
  tmdb_id: number;
  media_type: MediaType;
  title: string;
  year: number | null;
  poster_path: string | null;
  is_anime: boolean;
}

export interface HomeSectionRow {
  key: string;
  region: string;
  payload: CatalogItem[];
  fetched_at: string;
}

export interface AuthUser {
  id: string;
  email: string | null;
}
