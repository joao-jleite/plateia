"""Fase 01 · Fonte 3: Streaming Availability (Movie of the Night) via RapidAPI.

Responde: o BR está em /countries? Quais serviços? Para cada título,
/shows/{tv|movie}/{tmdb_id}?country=br devolve `link` (deep link web do
serviço) e `videoLink`? O domínio do link está entre os que declaram
assetlinks (ou seja, tende a abrir o app Android)?

Uso:  .venv/Scripts/python 03_streaming_availability.py
Precisa: RAPIDAPI_KEY em research/.env. Roda melhor DEPOIS do 01 (usa ids
do TMDB; senão /shows/search/title) e do 04 (domínios com assetlinks).
Custo: 1 + 20 ~ 21 requisições. Plano grátis = 1.000/mês; cap local 60 (6%).
"""
from __future__ import annotations

import sys
from urllib.parse import urlparse

from common import (SAMPLE, BudgetExceeded, BudgetGuard, banner, http_get,
                    load_summary, normalize_provider, pct, require_env, save_json,
                    save_raw, tmdb_ids_from_summary)

BASE = "https://streaming-availability.p.rapidapi.com"
HOST = "streaming-availability.p.rapidapi.com"
guard = BudgetGuard("streaming_availability", cap=60)


def get(path: str, key: str, **params):
    r = http_get(f"{BASE}/{path}", params=params, guard=guard,
                 headers={"X-RapidAPI-Key": key, "X-RapidAPI-Host": HOST})
    if r.status in (401, 403):
        print(f"[erro] chave RapidAPI recusada ({r.status}): {str(r.data)[:120]}")
        sys.exit(3)
    if r.status == 429:
        print(f"[erro] cota/rate limit (429): {str(r.data)[:120]}")
        sys.exit(4)
    return r


def applink_domains() -> set[str]:
    """Domínios que declaram pacote Android no assetlinks (saída do 04_assetlinks.py)."""
    data = load_summary("assetlinks.json") or {}
    return {d["domain"] for d in data.get("domains", []) if d.get("packages")}


def host_is_applink(host: str, domains: set[str]) -> bool:
    return host in domains or any(host.endswith("." + d) for d in domains)


def main() -> int:
    key = require_env("RAPIDAPI_KEY")
    tmdb_ids = tmdb_ids_from_summary()
    app_domains = applink_domains()

    banner("Streaming Availability · /countries/br")
    r = get("countries/br", key)
    save_raw("streaming_availability", "countries-br", r.data)
    services = []
    if r.ok and isinstance(r.data, dict):
        services = [s.get("id") for s in r.data.get("services", [])]
        print(f"- BR coberto · {len(services)} serviços: {', '.join(services)}")
    else:
        print(f"  [erro] countries/br: HTTP {r.status} {str(r.data)[:160]}")

    banner("Streaming Availability · shows (country=br)")
    rows, found, with_br, exp_hit, exp_total, with_link, with_applink = [], 0, 0, 0, 0, 0, 0
    for t in SAMPLE:
        row = {"slug": t.slug, "name": t.name, "expected": list(t.expected), "id": None,
               "options": [], "expected_found": None, "error": None}
        try:
            if t.slug in tmdb_ids:
                kind, tid = tmdb_ids[t.slug]
                r = get(f"shows/{kind}/{tid}", key, country="br", series_granularity="show")
                show = r.data if r.ok and isinstance(r.data, dict) else None
            else:
                r = get("shows/search/title", key, title=t.query or t.name, country="br",
                        show_type="series" if t.kind == "tv" else "movie", series_granularity="show")
                hits = r.data if r.ok and isinstance(r.data, list) else []
                hits.sort(key=lambda h: abs((h.get("firstAirYear") or h.get("releaseYear") or 0) - t.year))
                show = hits[0] if hits else None
            save_raw("streaming_availability", f"show-{t.slug}", r.data)
            if not show:
                row["error"] = f"não encontrado (HTTP {r.status})"
                rows.append(row)
                print(f"- {t.name}: NÃO ENCONTRADO ({r.status} {str(r.data)[:80]})")
                continue
            found += 1
            row["id"] = show.get("id")
            opts = (show.get("streamingOptions") or {}).get("br") or []
            if opts:
                with_br += 1
            for o in opts:
                link = o.get("link") or ""
                host = urlparse(link).netloc.lower()
                svc = o.get("service") or {}
                row["options"].append({"service": svc.get("id"), "service_name": svc.get("name"),
                                       "type": o.get("type"), "addon": (o.get("addon") or {}).get("id"),
                                       "link": link, "videoLink": o.get("videoLink"),
                                       "link_host": host,
                                       "host_has_assetlinks": host_is_applink(host, app_domains)})
            if any(o["link"] for o in row["options"]):
                with_link += 1
            if any(o["host_has_assetlinks"] for o in row["options"]):
                with_applink += 1
            if t.expected:
                exp_total += 1
                keys = {normalize_provider(o["service_name"] or o["service"] or "")
                        for o in row["options"] if o["type"] in ("subscription", "free", "addon")}
                row["expected_found"] = any(e in keys for e in t.expected)
                exp_hit += int(row["expected_found"])
            subs = ", ".join(sorted({o["service_name"] or "" for o in row["options"]
                                     if o["type"] == "subscription"})) or "—"
            n_links = sum(1 for o in row["options"] if o["link"])
            print(f"- {t.name}: assinatura BR = {subs} · links={n_links}")
        except BudgetExceeded as exc:
            row["error"] = str(exc)
            rows.append(row)
            print(f"[parado] {exc}")
            break
        rows.append(row)

    summary = {
        "source": "streaming_availability", "region": "BR", "calls_used": guard.used,
        "br_covered": bool(services), "services_br": services,
        "globoplay_in_services": any("globo" in (s or "") for s in services),
        "sample": len(SAMPLE), "found": found, "with_br_options": with_br,
        "expected_checked": exp_total, "expected_found": exp_hit, "expected_pct": pct(exp_hit, exp_total),
        "with_link": with_link, "with_link_on_assetlinks_domain": with_applink, "titles": rows,
    }
    path = save_json("streaming_availability_br.json", summary)
    banner(f"Streaming Availability: BR={bool(services)} · Globoplay={summary['globoplay_in_services']} · "
           f"{found}/{len(SAMPLE)} encontrados · {with_br} com opções BR · esperado certo {exp_hit}/{exp_total} "
           f"({summary['expected_pct']}) · link em {with_link}, em domínio com assetlinks em {with_applink} · "
           f"{guard.used} req · {path.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
