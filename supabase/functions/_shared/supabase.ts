// Clientes do Supabase dentro das Edge Functions e o acesso ao banco usado
// pelas funções. O handler de cada função recebe só a interface (CatalogDb,
// AccountAdmin) e é testado com fakes; esta é a implementação real.

import { createClient, type SupabaseClient } from "npm:@supabase/supabase-js@2";
import { env } from "./env.ts";
import { unauthorized, upstream } from "./http.ts";
import type {
  AuthUser,
  AvailabilityRow,
  CatalogItem,
  HomeSectionRow,
  LinksStatus,
  MediaType,
  OfferType,
  ProviderRow,
  SyncRow,
  TitleInput,
  TitleRow,
} from "./types.ts";

/// Cliente com o JWT do usuário: só para `auth.getUser()`.
export function userClient(req: Request): SupabaseClient {
  const auth = req.headers.get("Authorization") ?? "";
  return createClient(env.supabaseUrl(), env.anonKey(), {
    global: { headers: { Authorization: auth } },
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

/// Cliente service_role: ignora RLS. Nunca sai da função.
export function serviceClient(): SupabaseClient {
  return createClient(env.supabaseUrl(), env.serviceRoleKey(), {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

/// Exige um usuário logado; 401 se o JWT faltar ou for inválido.
export async function requireUser(req: Request): Promise<AuthUser> {
  const header = req.headers.get("Authorization") ?? "";
  if (!header.toLowerCase().startsWith("bearer ")) throw unauthorized();
  const { data, error } = await userClient(req).auth.getUser();
  if (error || !data.user) throw unauthorized();
  return { id: data.user.id, email: data.user.email ?? null };
}

// ────────────────────────────────────────────────────────────────────────────
// Banco (service_role)
// ────────────────────────────────────────────────────────────────────────────

export interface CatalogDb {
  getTitle(tmdbId: number, mediaType: MediaType): Promise<TitleRow | null>;
  upsertTitle(input: TitleInput, fetchedAt: string): Promise<TitleRow>;
  getSync(titleId: string, region: string): Promise<SyncRow | null>;
  upsertSync(titleId: string, region: string, patch: Partial<Omit<SyncRow, "title_id" | "region">>): Promise<SyncRow>;
  getAvailability(titleId: string, region: string): Promise<AvailabilityRow[]>;
  /// Troca todas as linhas do título na região, preservando deep_link ainda válido por (provider, tipo).
  replaceAvailability(titleId: string, region: string, rows: AvailabilityRow[]): Promise<void>;
  updateLinks(titleId: string, region: string, links: Array<{ provider_id: number; offer_type: OfferType; deep_link: string }>, fetchedAt: string): Promise<void>;
  getProviders(ids: number[]): Promise<ProviderRow[]>;
  /// Cria os que não existem (lazy); não mexe nos conhecidos.
  ensureProviders(rows: Array<{ id: number; name: string; logo_path: string | null; display_priority: number | null }>): Promise<void>;
  upsertProviderCatalog(rows: Array<{ id: number; name: string; logo_path: string | null; display_priority: number | null }>): Promise<number>;
  getFeaturedProviders(): Promise<ProviderRow[]>;
  consumeQuota(api: "tmdb" | "motn", cap: number): Promise<boolean>;
  getHomeSections(region: string): Promise<HomeSectionRow[]>;
  upsertHomeSections(rows: HomeSectionRow[]): Promise<void>;
}

export class SupabaseCatalogDb implements CatalogDb {
  constructor(private readonly db: SupabaseClient) {}

  private fail(ctx: string, error: { message: string } | null): never {
    throw upstream(`Banco: ${ctx}: ${error?.message ?? "erro"}`);
  }

  async getTitle(tmdbId: number, mediaType: MediaType): Promise<TitleRow | null> {
    const { data, error } = await this.db.from("titles").select("*").eq("tmdb_id", tmdbId).eq("media_type", mediaType).maybeSingle();
    if (error) this.fail("ler titles", error);
    return data as TitleRow | null;
  }

  async upsertTitle(input: TitleInput, fetchedAt: string): Promise<TitleRow> {
    const { data, error } = await this.db
      .from("titles")
      .upsert({ ...input, fetched_at: fetchedAt }, { onConflict: "tmdb_id,media_type" })
      .select("*")
      .single();
    if (error) this.fail("gravar titles", error);
    return data as TitleRow;
  }

  async getSync(titleId: string, region: string): Promise<SyncRow | null> {
    const { data, error } = await this.db.from("title_sync").select("*").eq("title_id", titleId).eq("region", region).maybeSingle();
    if (error) this.fail("ler title_sync", error);
    return data as SyncRow | null;
  }

  async upsertSync(titleId: string, region: string, patch: Partial<Omit<SyncRow, "title_id" | "region">>): Promise<SyncRow> {
    const { data, error } = await this.db
      .from("title_sync")
      .upsert({ title_id: titleId, region, ...patch }, { onConflict: "title_id,region" })
      .select("*")
      .single();
    if (error) this.fail("gravar title_sync", error);
    return data as SyncRow;
  }

  async getAvailability(titleId: string, region: string): Promise<AvailabilityRow[]> {
    const { data, error } = await this.db.from("title_availability").select("*").eq("title_id", titleId).eq("region", region);
    if (error) this.fail("ler title_availability", error);
    return (data ?? []) as AvailabilityRow[];
  }

  async replaceAvailability(titleId: string, region: string, rows: AvailabilityRow[]): Promise<void> {
    const del = await this.db.from("title_availability").delete().eq("title_id", titleId).eq("region", region);
    if (del.error) this.fail("limpar title_availability", del.error);
    if (rows.length === 0) return;
    const ins = await this.db.from("title_availability").insert(rows);
    if (ins.error) this.fail("gravar title_availability", ins.error);
  }

  async updateLinks(titleId: string, region: string, links: Array<{ provider_id: number; offer_type: OfferType; deep_link: string }>, fetchedAt: string): Promise<void> {
    for (const l of links) {
      const { error } = await this.db
        .from("title_availability")
        .update({ deep_link: l.deep_link, deep_link_source: "motn", link_fetched_at: fetchedAt })
        .eq("title_id", titleId).eq("region", region).eq("provider_id", l.provider_id).eq("offer_type", l.offer_type);
      if (error) this.fail("gravar deep_link", error);
    }
  }

  async getProviders(ids: number[]): Promise<ProviderRow[]> {
    if (ids.length === 0) return [];
    const { data, error } = await this.db.from("providers").select("*").in("id", ids);
    if (error) this.fail("ler providers", error);
    return (data ?? []) as ProviderRow[];
  }

  async ensureProviders(rows: Array<{ id: number; name: string; logo_path: string | null; display_priority: number | null }>): Promise<void> {
    if (rows.length === 0) return;
    const { error } = await this.db
      .from("providers")
      .upsert(rows.map((r) => ({ id: r.id, name: r.name, logo_path: r.logo_path, display_order: r.display_priority })), { onConflict: "id", ignoreDuplicates: true });
    if (error) this.fail("criar providers", error);
  }

  /// providers-sync: atualiza logo de todos; nome e ordem só dos não destacados
  /// (os destacados têm nome/slug nossos e display_order do seed).
  async upsertProviderCatalog(rows: Array<{ id: number; name: string; logo_path: string | null; display_priority: number | null }>): Promise<number> {
    if (rows.length === 0) return 0;
    const ids = rows.map((r) => r.id);
    const { data: existing, error: readErr } = await this.db.from("providers").select("id,is_featured").in("id", ids);
    if (readErr) this.fail("ler providers", readErr);
    const featured = new Set((existing ?? []).filter((p) => p.is_featured).map((p) => p.id as number));
    let count = 0;
    for (const r of rows) {
      const patch: Record<string, unknown> = featured.has(r.id)
        ? { id: r.id, logo_path: r.logo_path }
        : { id: r.id, name: r.name, logo_path: r.logo_path, display_order: r.display_priority };
      const { error } = await this.db.from("providers").upsert(patch, { onConflict: "id" });
      if (error) this.fail("gravar providers", error);
      count++;
    }
    return count;
  }

  async getFeaturedProviders(): Promise<ProviderRow[]> {
    const { data, error } = await this.db.from("providers").select("*").eq("is_featured", true).eq("active", true).order("display_order");
    if (error) this.fail("ler providers destacados", error);
    return (data ?? []) as ProviderRow[];
  }

  async consumeQuota(api: "tmdb" | "motn", cap: number): Promise<boolean> {
    const { data, error } = await this.db.rpc("consume_api_quota", { p_api: api, p_cap: cap });
    if (error) this.fail("consume_api_quota", error);
    return data === true;
  }

  async getHomeSections(region: string): Promise<HomeSectionRow[]> {
    const { data, error } = await this.db.from("home_sections").select("*").eq("region", region);
    if (error) this.fail("ler home_sections", error);
    return (data ?? []) as HomeSectionRow[];
  }

  async upsertHomeSections(rows: HomeSectionRow[]): Promise<void> {
    if (rows.length === 0) return;
    const { error } = await this.db.from("home_sections").upsert(rows, { onConflict: "key" });
    if (error) this.fail("gravar home_sections", error);
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Conta (account-delete)
// ────────────────────────────────────────────────────────────────────────────

export interface AccountAdmin {
  listAvatarPaths(uid: string): Promise<string[]>;
  removeAvatars(paths: string[]): Promise<void>;
  deleteUser(uid: string): Promise<void>;
}

export class SupabaseAccountAdmin implements AccountAdmin {
  constructor(private readonly db: SupabaseClient) {}

  async listAvatarPaths(uid: string): Promise<string[]> {
    const { data, error } = await this.db.storage.from("avatars").list(uid, { limit: 100 });
    if (error) throw upstream(`Storage: listar avatares: ${error.message}`);
    return (data ?? []).map((o) => `${uid}/${o.name}`);
  }

  async removeAvatars(paths: string[]): Promise<void> {
    if (paths.length === 0) return;
    const { error } = await this.db.storage.from("avatars").remove(paths);
    if (error) throw upstream(`Storage: apagar avatares: ${error.message}`);
  }

  async deleteUser(uid: string): Promise<void> {
    const { error } = await this.db.auth.admin.deleteUser(uid);
    if (error) throw upstream(`Auth: apagar usuário: ${error.message}`);
  }
}

export type { CatalogItem, LinksStatus };
