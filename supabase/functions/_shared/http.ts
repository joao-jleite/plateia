// Resposta e erro padrão das Edge Functions (docs/ARQUITETURA.md §9):
// sucesso = JSON; erro = { error: { code, message } } com a mensagem em pt-BR.

export class HttpError extends Error {
  constructor(
    public readonly status: number,
    public readonly code: string,
    message: string,
  ) {
    super(message);
    this.name = "HttpError";
  }
}

export const badRequest = (message: string) => new HttpError(400, "bad_request", message);
export const unauthorized = (message = "Sessão inválida. Entre de novo.") =>
  new HttpError(401, "unauthorized", message);
export const notFound = (message = "Não encontramos esse título.") =>
  new HttpError(404, "not_found", message);
export const quotaExceeded = (message = "Limite de consultas do mês atingido.") =>
  new HttpError(429, "quota_exceeded", message);
export const upstream = (message = "O serviço de catálogo não respondeu.") =>
  new HttpError(502, "upstream", message);

// Sem origem web no MVP: o app nativo não manda Origin. Os cabeçalhos ficam
// para o preflight não quebrar se um dia houver web.
export const corsHeaders: Record<string, string> = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers": "authorization, x-client-info, apikey, content-type",
  "Access-Control-Allow-Methods": "POST, OPTIONS",
};

export function json(data: unknown, status = 200): Response {
  return new Response(JSON.stringify(data), {
    status,
    headers: { ...corsHeaders, "Content-Type": "application/json; charset=utf-8" },
  });
}

export function errorResponse(err: unknown): Response {
  if (err instanceof HttpError) {
    return json({ error: { code: err.code, message: err.message } }, err.status);
  }
  console.error("internal", err instanceof Error ? (err.stack ?? err.message) : err);
  return json({ error: { code: "internal", message: "Erro interno. Tente de novo." } }, 500);
}

/// Lê o corpo JSON (objeto). Corpo vazio vale como `{}`.
export async function readJson(req: Request): Promise<Record<string, unknown>> {
  const text = await req.text();
  if (!text.trim()) return {};
  try {
    const parsed = JSON.parse(text);
    if (parsed && typeof parsed === "object" && !Array.isArray(parsed)) return parsed;
  } catch {
    // cai no erro abaixo
  }
  throw badRequest("Corpo da requisição inválido (esperado um objeto JSON).");
}

/// Envelope comum: OPTIONS, só POST, erro padronizado.
export function serve(handler: (req: Request) => Promise<Response>): (req: Request) => Promise<Response> {
  return async (req) => {
    if (req.method === "OPTIONS") return new Response("ok", { headers: corsHeaders });
    if (req.method !== "POST") {
      return errorResponse(new HttpError(405, "bad_request", "Use POST."));
    }
    try {
      return await handler(req);
    } catch (err) {
      return errorResponse(err);
    }
  };
}
