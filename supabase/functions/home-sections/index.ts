import { env } from "../_shared/env.ts";
import { serve } from "../_shared/http.ts";
import { requireUser, serviceClient, SupabaseCatalogDb } from "../_shared/supabase.ts";
import { createTmdbClient } from "../_shared/tmdb.ts";
import { handleHome } from "./handler.ts";

Deno.serve(serve((req) =>
  handleHome(req, {
    requireUser,
    db: new SupabaseCatalogDb(serviceClient()),
    tmdb: (counter) => createTmdbClient(env.tmdbToken(), counter),
  })
));
