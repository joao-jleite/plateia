import { env } from "../_shared/env.ts";
import { serve } from "../_shared/http.ts";
import { requireUser, serviceClient, SupabaseCatalogDb } from "../_shared/supabase.ts";
import { createTmdbClient } from "../_shared/tmdb.ts";
import { handleProvidersSync } from "./handler.ts";

Deno.serve(serve((req) =>
  handleProvidersSync(req, {
    requireUser,
    db: new SupabaseCatalogDb(serviceClient()),
    tmdb: (counter) => createTmdbClient(env.tmdbToken(), counter),
  })
));
