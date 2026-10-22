import { env } from "../_shared/env.ts";
import { serve } from "../_shared/http.ts";
import { requireUser } from "../_shared/supabase.ts";
import { createTmdbClient } from "../_shared/tmdb.ts";
import { handleSearch } from "./handler.ts";

Deno.serve(serve((req) =>
  handleSearch(req, {
    requireUser,
    tmdb: (counter) => createTmdbClient(env.tmdbToken(), counter),
  })
));
