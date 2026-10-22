// Variáveis de ambiente. SUPABASE_* existem em toda Edge Function; as chaves
// das APIs entram por `supabase secrets set` (João). Nomes novos do Supabase
// (publishable/secret key) aceitos como alternativa.

export function requireEnv(...names: string[]): string {
  for (const n of names) {
    const v = Deno.env.get(n);
    if (v && v.trim()) return v;
  }
  throw new Error(`Variável de ambiente ausente: ${names.join(" ou ")}. Rode: supabase secrets set ${names[0]}=…`);
}

export const env = {
  supabaseUrl: () => requireEnv("SUPABASE_URL"),
  anonKey: () => requireEnv("SUPABASE_ANON_KEY", "SUPABASE_PUBLISHABLE_KEY"),
  serviceRoleKey: () => requireEnv("SUPABASE_SERVICE_ROLE_KEY", "SUPABASE_SECRET_KEY"),
  tmdbToken: () => requireEnv("TMDB_API_KEY"),
  rapidApiKey: () => requireEnv("RAPIDAPI_KEY"),
};
