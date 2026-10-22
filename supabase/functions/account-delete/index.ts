import { serve } from "../_shared/http.ts";
import { requireUser, serviceClient, SupabaseAccountAdmin } from "../_shared/supabase.ts";
import { handleAccountDelete } from "./handler.ts";

Deno.serve(serve((req) =>
  handleAccountDelete(req, {
    requireUser,
    admin: new SupabaseAccountAdmin(serviceClient()),
  })
));
