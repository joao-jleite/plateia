// account-delete · {} → { ok: true }
// Apaga o próprio usuário em auth.users (cascade em profiles e em tudo que é
// dele) e os arquivos em avatars/<uid>/. Exigência da Play para apps com conta.

import { json } from "../_shared/http.ts";
import { buildLogLine, logLine } from "../_shared/log.ts";
import type { AccountAdmin } from "../_shared/supabase.ts";
import type { AuthUser } from "../_shared/types.ts";

export interface DeleteDeps {
  requireUser(req: Request): Promise<AuthUser>;
  admin: AccountAdmin;
}

export async function handleAccountDelete(req: Request, deps: DeleteDeps): Promise<Response> {
  const startedAt = Date.now();
  const user = await deps.requireUser(req); // só o próprio chamador; não há "apagar outro"

  // Storage primeiro: se falhar, a conta continua existindo e dá para tentar de novo.
  const paths = await deps.admin.listAvatarPaths(user.id);
  await deps.admin.removeAvatars(paths);
  await deps.admin.deleteUser(user.id);

  logLine(buildLogLine("account-delete", user.id, startedAt, 0, { avatars_removed: paths.length }));
  return json({ ok: true });
}
