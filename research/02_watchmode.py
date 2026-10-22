"""Fase 01 · Fonte 2: Watchmode.

Responde: o BR está em /v1/regions (e está habilitado no plano grátis)?
Quais sources existem para BR? Para cada título, /title/{id}/sources/ em BR
devolve android_url preenchido ou a mensagem "paid plans only"?

Uso:  .venv/Scripts/python 02_watchmode.py
Precisa: WATCHMODE_API_KEY em research/.env. Roda melhor DEPOIS do
01_tmdb_providers.py (usa os ids do TMDB; senão busca por nome).
Custo: regions 1 + sources 1 + por título (search 1 + sources 1) ~ 44
créditos. Plano grátis = 2.500/mês; cap local 120 (<5%).
"""
from __future__ import annotations

import sys

from common import (SAMPLE, BudgetExceeded, BudgetGuard, banner, http_get,
                    normalize_provider, pct, require_env, save_json, save_raw,
                    tmdb_ids_from_summary)

BASE = "https://api.watchmode.com/v1"
guard = BudgetGuard("watchmode", cap=120)
PAID_ONLY = "paid plans only"   # texto que o plano grátis devolve no lugar dos links de TV/app


def get(path: str, key: str, **params):
    r = http_get(f"{BASE}/{path}", params={"apiKey": key, **params}, guard=guard)
    if r.status == 401:
        print("[erro] chave Watchmode recusada (401)")
        sys.exit(3)
    return r


def find_title_id(t, key, tmdb_ids) -> int | None:
    """Watchmode id via TMDB id (preciso) ou por nome (ordenando pelo ano mais próximo)."""
    if t.slug in tmdb_ids:
        kind, tid = tmdb_ids[t.slug]
        field = "tmdb_tv_id" if kind == "tv" else "tmdb_movie_id"
        r = get("search/", key, search_field=field, search_value=tid)
    else:
        r = get("search/", key, search_field="name", search_value=t.query or t.name,
                types="tv" if t.kind == "tv" else "movie")
    save_raw("watchmode", f"search-{t.slug}", r.data)
    if not r.ok or not isinstance(r.data, dict):
        print(f"  [erro] search {t.name}: HTTP {r.status} {str(r.data)[:120]}")
        return None
    hits = r.data.get("title_results") or []
    if not hits:
        return None
    if t.slug not in tmdb_ids:
        hits.sort(key=lambda h: abs((h.get("year") or 0) - t.year))
    return hits[0]["id"]


def main() -> int:
    key = require_env("WATCHMODE_API_KEY")
    tmdb_ids = tmdb_ids_from_summary()

    banner("Watchmode · regions")
    r = get("regions/", key)
    save_raw("watchmode", "regions", r.data)
    br = None
    if r.ok and isinstance(r.data, list):
        br = next((x for x in r.data if x.get("country") == "BR"), None)
        print(f"- {len(r.data)} regiões; BR = {br}")
    else:
        print(f"  [erro] regions: HTTP {r.status} {str(r.data)[:160]}")

    banner("Watchmode · sources em BR")
    r = get("sources/", key, regions="BR")
    save_raw("watchmode", "sources-BR", r.data)
    sources_br = []
    if r.ok and isinstance(r.data, list):
        sources_br = [{"id": s.get("id"), "name": s.get("name"), "type": s.get("type"),
                       "android_scheme": s.get("android_scheme"),
                       "android_appstore_url": s.get("android_appstore_url")} for s in r.data]
        print(f"- {len(sources_br)} sources: " + ", ".join(s["name"] for s in sources_br[:25]) + " ...")
    else:
        print(f"  [erro] sources: HTTP {r.status} {str(r.data)[:160]}")

    banner("Watchmode · sources por título (BR)")
    rows, found, with_br, exp_hit, exp_total, with_android = [], 0, 0, 0, 0, 0
    for t in SAMPLE:
        row = {"slug": t.slug, "name": t.name, "expected": list(t.expected), "watchmode_id": None,
               "sources": [], "android_url_sample": None, "android_url_paid_only": None,
               "expected_found": None, "error": None}
        try:
            wid = find_title_id(t, key, tmdb_ids)
            if not wid:
                row["error"] = "não encontrado"
                rows.append(row)
                print(f"- {t.name}: NÃO ENCONTRADO")
                continue
            found += 1
            row["watchmode_id"] = wid
            r = get(f"title/{wid}/sources/", key, regions="BR")
            save_raw("watchmode", f"sources-{t.slug}", r.data)
            if not r.ok or not isinstance(r.data, list):
                row["error"] = f"HTTP {r.status}"
                rows.append(row)
                print(f"  [erro] sources {t.name}: HTTP {r.status} {str(r.data)[:120]}")
                continue
            srcs = [s for s in r.data if s.get("region") == "BR"]
            if srcs:
                with_br += 1
            for s in srcs:
                row["sources"].append({"name": s.get("name"), "type": s.get("type"),
                                       "web_url": s.get("web_url"), "android_url": s.get("android_url"),
                                       "ios_url": s.get("ios_url"), "price": s.get("price")})
            androids = [s.get("android_url") or "" for s in srcs]
            real = [a for a in androids if a and PAID_ONLY not in a.lower()]
            row["android_url_paid_only"] = any(PAID_ONLY in a.lower() for a in androids) or None
            if real:
                with_android += 1
                row["android_url_sample"] = real[0]
            if t.expected:
                exp_total += 1
                keys = {normalize_provider(s.get("name", "")) for s in srcs if s.get("type") in ("sub", "free")}
                row["expected_found"] = any(e in keys for e in t.expected)
                exp_hit += int(row["expected_found"])
            subs = ", ".join(sorted({s["name"] for s in srcs if s.get("type") == "sub"})) or "—"
            state = "ok" if real else ("paid only" if row["android_url_paid_only"] else "vazio")
            print(f"- {t.name} (wm {wid}): sub BR = {subs} · android_url: {state}")
        except BudgetExceeded as exc:
            row["error"] = str(exc)
            rows.append(row)
            print(f"[parado] {exc}")
            break
        rows.append(row)

    summary = {
        "source": "watchmode", "region": "BR", "calls_used": guard.used,
        "br_in_regions": br is not None, "br_region": br, "sources_br_count": len(sources_br),
        "sources_br": sources_br, "sample": len(SAMPLE), "found": found, "with_br_sources": with_br,
        "expected_checked": exp_total, "expected_found": exp_hit, "expected_pct": pct(exp_hit, exp_total),
        "with_android_url": with_android, "titles": rows,
    }
    path = save_json("watchmode_br.json", summary)
    banner(f"Watchmode: BR nas regiões={br is not None} · {found}/{len(SAMPLE)} encontrados · "
           f"{with_br} com sources BR · esperado certo {exp_hit}/{exp_total} ({summary['expected_pct']}) · "
           f"android_url real em {with_android} · {guard.used} créditos · {path.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
