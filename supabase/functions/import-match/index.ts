import { env } from "../_shared/env.ts";
import { serve } from "../_shared/http.ts";
import { requireUser, serviceClient, SupabaseCatalogDb } from "../_shared/supabase.ts";
import { createTmdbClient } from "../_shared/tmdb.ts";
import { handleImportMatch } from "./handler.ts";

const db = new SupabaseCatalogDb(serviceClient());

Deno.serve(serve((req) =>
  handleImportMatch(req, {
    requireUser,
    db,
    tmdb: (counter) => createTmdbClient(env.tmdbToken(), counter),
  })
));
