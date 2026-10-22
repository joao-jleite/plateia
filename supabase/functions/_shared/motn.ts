// Streaming Availability (Movie of the Night, via RapidAPI): só o link que abre
// o app, por serviço. Uma chamada por título a cada 7 dias, dentro da cota
// (consume_api_quota('motn', 900) é chamado por quem usa este cliente).

import { Counter } from "./log.ts";
import { upstream } from "./http.ts";
import type { MediaType, OfferType } from "./types.ts";
import type { Json } from "./tmdb.ts";

export const MOTN_HOST = "streaming-availability.p.rapidapi.com";

export interface MotnClient {
  /// `null` quando a API não conhece o título (404).
  show(mediaType: MediaType, tmdbId: number, country?: string): Promise<Json | null>;
}

export function createMotnClient(apiKey: string, counter: Counter, fetchImpl: typeof fetch = fetch): MotnClient {
  return {
    async show(mediaType, tmdbId, country = "br") {
      // v4: /shows/{id} aceita "tv/37854" e "movie/872585" (ids do TMDB)
      const url = new URL(`https://${MOTN_HOST}/shows/${mediaType}/${tmdbId}`);
      url.searchParams.set("country", country);
      counter.inc();
      let res: Response;
      try {
        res = await fetchImpl(url, {
          headers: { "X-RapidAPI-Key": apiKey, "X-RapidAPI-Host": MOTN_HOST, Accept: "application/json" },
        });
      } catch (err) {
        throw upstream(`Streaming Availability fora do ar (${err instanceof Error ? err.message : "rede"}).`);
      }
      if (res.status === 404) return null;
      if (!res.ok) throw upstream(`Streaming Availability respondeu ${res.status}.`);
      return await res.json();
    },
  };
}

/// HBO Max: só `play.hbomax.com` declara o pacote Android no assetlinks (fase 01).
const HBO_WRONG_HOSTS = new Set(["play.max.com", "max.com", "www.max.com", "www.hbomax.com", "hbomax.com"]);

export function normalizeLink(link: string): string {
  try {
    const u = new URL(link);
    if (HBO_WRONG_HOSTS.has(u.hostname)) {
      u.hostname = "play.hbomax.com";
      return u.toString();
    }
    return link;
  } catch {
    return link;
  }
}

/// Tipo de oferta da MOTN → nosso offer_type. `addon` (canal dentro de outro
/// serviço) não casa com nenhuma linha do TMDB e é ignorado.
export function motnTypeToOffer(type: string): OfferType | null {
  switch (type) {
    case "subscription":
      return "flatrate";
    case "free":
      return "free";
    case "rent":
      return "rent";
    case "buy":
      return "buy";
    default:
      return null;
  }
}

export interface MotnLink {
  service_id: string; // ex.: "netflix", "hbo", "disney"
  offer_type: OfferType;
  link: string;
}

/// `streamingOptions[country]` → links por (serviço, tipo), já normalizados.
export function extractLinks(show: Json, country = "br"): MotnLink[] {
  const options: Json[] = Array.isArray(show?.streamingOptions?.[country]) ? show.streamingOptions[country] : [];
  const out: MotnLink[] = [];
  const seen = new Set<string>();
  for (const o of options) {
    const serviceId: string | undefined = o?.service?.id;
    const offer = motnTypeToOffer(o?.type);
    const link: string | undefined = o?.link;
    if (!serviceId || !offer || !link) continue;
    const key = `${serviceId}:${offer}`;
    if (seen.has(key)) continue;
    seen.add(key);
    out.push({ service_id: serviceId, offer_type: offer, link: normalizeLink(link) });
  }
  return out;
}

/// Casa os links da MOTN com as linhas de disponibilidade do TMDB.
/// Assinatura cobre `flatrate` e `ads` (variante "com anúncios" do mesmo serviço).
export function matchLinks(
  links: MotnLink[],
  rows: Array<{ provider_id: number; offer_type: OfferType }>,
  motnIdOf: (providerId: number) => string | null,
): Array<{ provider_id: number; offer_type: OfferType; deep_link: string }> {
  const byKey = new Map<string, string>();
  for (const l of links) byKey.set(`${l.service_id}:${l.offer_type}`, l.link);
  const out: Array<{ provider_id: number; offer_type: OfferType; deep_link: string }> = [];
  for (const row of rows) {
    const motnId = motnIdOf(row.provider_id);
    if (!motnId) continue;
    const wanted: OfferType = row.offer_type === "ads" ? "flatrate" : row.offer_type;
    const link = byKey.get(`${motnId}:${wanted}`);
    if (link) out.push({ provider_id: row.provider_id, offer_type: row.offer_type, deep_link: link });
  }
  return out;
}
