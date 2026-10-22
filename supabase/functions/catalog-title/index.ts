import { env } from "../_shared/env.ts";
import { serve } from "../_shared/http.ts";
import { createMotnClient } from "../_shared/motn.ts";
import { requireUser, serviceClient, SupabaseCatalogDb } from "../_shared/supabase.ts";
import { createTmdbClient } from "../_shared/tmdb.ts";
import { handleTitle } from "./handler.ts";

Deno.serve(serve((req) =>
  handleTitle(req, {
    requireUser,
    db: new SupabaseCatalogDb(serviceClient()),
    tmdb: (counter) => createTmdbClient(env.tmdbToken(), counter),
    motn: (counter) => createMotnClient(env.rapidApiKey(), counter),
  })
));
