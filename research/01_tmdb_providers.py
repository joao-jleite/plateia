"""Fase 01 · Fonte 1: TMDB watch/providers (região BR).

Para cada título da amostra: busca o id no TMDB (pt-BR, com ano) e lê
/watch/providers. Guarda os provedores de BR por tipo (flatrate/rent/buy/
free/ads), o campo `link` e se o streaming esperado apareceu.

Uso:  .venv/Scripts/python 01_tmdb_providers.py
Precisa: TMDB_API_KEY em research/.env (token v4 "eyJ..." ou chave v3).
Custo: ~2 chamadas por título (40 no total). TMDB não tem cota mensal,
só rate limit (~50 req/s); cap local de 100 para proteger de bug.
"""
from __future__ import annotations

import sys

from common import (SAMPLE, BudgetExceeded, BudgetGuard, banner, http_get,
                    normalize_provider, pct, require_env, save_json, save_raw)

BASE = "https://api.themoviedb.org/3"
guard = BudgetGuard("tmdb", cap=100)


def auth(token: str) -> tuple[dict, dict]:
    """TMDB accepts the v4 read token as Bearer or the v3 key as ?api_key=."""
    if token.startswith("eyJ"):
        return {"Authorization": f"Bearer {token}"}, {}
    return {}, {"api_key": token}


def search(title, headers, params) -> dict | None:
    q = dict(params, query=title.query or title.name, language="pt-BR", include_adult="false")
    if title.kind == "tv":
        q["first_air_date_year"] = title.year
    else:
        q["year"] = title.year
    r = http_get(f"{BASE}/search/{title.kind}", params=q, headers=headers, guard=guard)
    save_raw("tmdb", f"search-{title.slug}", r.data)
    if not r.ok or not isinstance(r.data, dict):
        print(f"  [erro] search {title.name}: HTTP {r.status} {str(r.data)[:120]}")
        return None
    results = r.data.get("results") or []
    if not results:
        # Retry without the year: TMDB years are strict and a wrong one hides the title.
        q.pop("first_air_date_year", None); q.pop("year", None)
        r = http_get(f"{BASE}/search/{title.kind}", params=q, headers=headers, guard=guard)
        results = (r.data or {}).get("results") or [] if r.ok else []
    return results[0] if results else None


def providers(title, tmdb_id, headers, params) -> dict | None:
    r = http_get(f"{BASE}/{title.kind}/{tmdb_id}/watch/providers", params=params,
                 headers=headers, guard=guard)
    save_raw("tmdb", f"providers-{title.slug}", r.data)
    if not r.ok or not isinstance(r.data, dict):
        print(f"  [erro] providers {title.name}: HTTP {r.status} {str(r.data)[:120]}")
        return None
    return (r.data.get("results") or {}).get("BR")


def main() -> int:
    token = require_env("TMDB_API_KEY")
    headers, params = auth(token)
    banner("TMDB watch/providers · BR")
    rows, found, with_br, expected_hit, expected_total = [], 0, 0, 0, 0
    for t in SAMPLE:
        row = {"slug": t.slug, "name": t.name, "kind": t.kind, "expected": list(t.expected),
               "tmdb_id": None, "tmdb_title": None, "br": None, "link": None,
               "providers": {}, "expected_found": None, "error": None}
        try:
            hit = search(t, headers, params)
            if not hit:
                row["error"] = "não encontrado na busca"
                rows.append(row); print(f"- {t.name}: NÃO ENCONTRADO"); continue
            found += 1
            row["tmdb_id"] = hit["id"]
            row["tmdb_title"] = hit.get("name") or hit.get("title")
            br = providers(t, hit["id"], headers, params)
            if br:
                with_br += 1
                row["br"] = True
                row["link"] = br.get("link")
                for kind in ("flatrate", "free", "ads", "rent", "buy"):
                    names = [p["provider_name"] for p in br.get(kind, [])]
                    if names:
                        row["providers"][kind] = names
            else:
                row["br"] = False
            # "streaming certo" = algum provedor de assinatura (flatrate/ads) bate com o esperado
            if t.expected:
                expected_total += 1
                sub = row["providers"].get("flatrate", []) + row["providers"].get("ads", [])
                keys = {normalize_provider(n) for n in sub}
                row["expected_found"] = any(e in keys for e in t.expected)
                expected_hit += int(row["expected_found"])
            flat = ", ".join(row["providers"].get("flatrate", [])) or "—"
            print(f"- {t.name} (tmdb {hit['id']}): assinatura BR = {flat}"
                  + ("" if row["expected_found"] in (None, True) else "   <-- esperado não apareceu"))
        except BudgetExceeded as exc:
            row["error"] = str(exc); print(f"[parado] {exc}")
            rows.append(row); break
        rows.append(row)

    summary = {
        "source": "tmdb", "region": "BR", "calls_used": guard.used,
        "sample": len(SAMPLE), "found": found, "with_br_providers": with_br,
        "expected_checked": expected_total, "expected_found": expected_hit,
        "expected_pct": pct(expected_hit, expected_total),
        "deep_link": False,
        "deep_link_note": "campo `link` aponta para a página /watch do TMDB (redireciona para a JustWatch), não para o streaming",
        "titles": rows,
    }
    path = save_json("tmdb_br.json", summary)
    banner(f"TMDB: {found}/{len(SAMPLE)} encontrados · {with_br} com provedores BR · "
           f"esperado certo em {expected_hit}/{expected_total} ({summary['expected_pct']}) · "
           f"{guard.used} chamadas · {path.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
