"""Fase 01 · Teste 4: os links https abrem o app Android?

Sem chave. Para cada streaming: lê /.well-known/assetlinks.json dos domínios
candidatos e extrai os pacotes Android declarados (Digital Asset Links =
App Links verificados; com isso o Android abre o app em vez do navegador,
desde que o intent-filter do app cubra o caminho). Depois testa o formato
de link de busca (plano B quando não há link direto do título) e um link de
título de exemplo, só pelo status HTTP.

Nota: Disney+ não tem URL de busca pública (404 real) e a Paramount+
devolve 406 para clientes não-navegador, mas a página abre no navegador
(conferido manualmente em 22/10/2026).

Uso:  .venv/Scripts/python 04_assetlinks.py   ->  out/assetlinks.json
"""
from __future__ import annotations

import datetime as dt
import sys
from urllib.parse import quote

from common import banner, http_get, save_json, save_raw

BROWSER_UA = ("Mozilla/5.0 (Linux; Android 14; Pixel 8) AppleWebKit/537.36 "
              "(KHTML, like Gecko) Chrome/128.0.0.0 Mobile Safari/537.36")
HDR = {"User-Agent": BROWSER_UA, "Accept": "text/html,application/json;q=0.9,*/*;q=0.8",
       "Accept-Language": "pt-BR,pt;q=0.9"}

# service -> domínios candidatos, padrão de busca ({q}) e um link de título de exemplo
SERVICES: dict[str, dict] = {
    "netflix": {
        "domains": ["www.netflix.com", "netflix.com"],
        "search": "https://www.netflix.com/search?q={q}",
        "title_example": "https://www.netflix.com/title/80057281",   # Stranger Things
        "note": "search redireciona para login no navegador; no app abre a busca. /title/{id} é o deep link canônico.",
    },
    "max": {
        "domains": ["play.hbomax.com", "play.max.com", "www.hbomax.com", "max.com"],
        "search": "https://play.hbomax.com/search?q={q}",
        "title_example": "https://play.hbomax.com/show/urn:hbo:series:GYdGMQQ7H8kgGvwEAAAAK",   # TLOU
        "note": "Marca voltou a HBO Max em 2025; play.max.com redireciona (301) para play.hbomax.com. Só play.* declara pacotes.",
    },
    "disney": {
        "domains": ["www.disneyplus.com", "disneyplus.com"],
        "search": None,
        "title_example": None,   # entity-id real só vem da API de disponibilidade (fase 03)
        "note": "Sem URL de busca pública (404). Deep link só por entity-id, que vem da API de disponibilidade.",
    },
    "prime": {
        "domains": ["www.primevideo.com", "app.primevideo.com", "primevideo.com"],
        "search": "https://www.primevideo.com/search?phrase={q}",
        "title_example": "https://www.primevideo.com/detail/0KRGHGZCHKS920ZQGY5LBRF7MA",   # The Boys
        "note": "",
    },
    "globoplay": {
        "domains": ["globoplay.globo.com"],
        "search": "https://globoplay.globo.com/busca/?q={q}",
        "title_example": None,   # formato /{slug}/t/{id}/; id real só pela página do título
        "note": "Streaming Availability não cobre Globoplay; TMDB cobre. Link de título só pela busca ou pela URL da página.",
    },
    "apple": {
        "domains": ["tv.apple.com"],
        "search": "https://tv.apple.com/br/search?term={q}",
        "title_example": "https://tv.apple.com/br/show/ruptura/umc.cmc.1srk2goyh2q2zdxcx605w8vtx",
        "note": "Pacotes declarados são do app Apple TV para Android/Android TV/Fire TV/Sony.",
    },
    "paramount": {
        "domains": ["www.paramountplus.com", "paramountplus.com"],
        "search": "https://www.paramountplus.com/br/search/?q={q}",
        "title_example": "https://www.paramountplus.com/br/shows/yellowstone/",
        "note": "Servidor responde 406 a clientes não-navegador; no navegador a busca abre (conferido).",
    },
    "crunchyroll": {
        "domains": ["www.crunchyroll.com", "crunchyroll.com"],
        "search": "https://www.crunchyroll.com/pt-br/search?q={q}",
        "title_example": "https://www.crunchyroll.com/pt-br/series/GG5H5XQ0D/one-piece",
        "note": "",
    },
}


def packages_from(data) -> list[str]:
    """Pacotes Android (namespace android_app) de um assetlinks.json; lista vazia se não for JSON válido."""
    pk = set()
    if isinstance(data, list):
        for st in data:
            target = (st or {}).get("target") or {}
            if target.get("namespace") == "android_app" and target.get("package_name"):
                pk.add(target["package_name"])
    return sorted(pk)


def main() -> int:
    banner("assetlinks.json por domínio")
    domain_rows, service_rows = [], {}
    for svc, cfg in SERVICES.items():
        svc_pk: set[str] = set()
        for d in cfg["domains"]:
            url = f"https://{d}/.well-known/assetlinks.json"
            r = http_get(url, headers={"User-Agent": BROWSER_UA, "Accept": "application/json"})
            save_raw("assetlinks", d, r.data)
            pk = packages_from(r.data)
            svc_pk.update(pk)
            domain_rows.append({"service": svc, "domain": d, "status": r.status, "final_url": r.url,
                                "packages": pk})
            print(f"- {d:26} {r.status:>3}  {pk if pk else '(nenhum pacote)'}")
        service_rows[svc] = {"packages": sorted(svc_pk), "has_applink": bool(svc_pk), **cfg}

    banner("formato de link de busca (plano B) e link de título")
    for svc, cfg in SERVICES.items():
        out = service_rows[svc]
        if cfg["search"]:
            r = http_get(cfg["search"].format(q=quote("teste")), headers=HDR)
            out["search_status"] = r.status
            out["search_final_url"] = r.url
            print(f"- {svc:12} busca  {r.status:>3} -> {r.url[:80]}")
        else:
            out["search_status"] = None
            print(f"- {svc:12} busca  (sem URL de busca pública)")
        if cfg["title_example"]:
            r = http_get(cfg["title_example"], headers=HDR, timeout=30)
            out["title_status"] = r.status   # 0 = erro de rede/timeout (Netflix demora com UA de navegador)
            out["title_final_url"] = r.url
            print(f"- {svc:12} título {r.status:>3} -> {r.url[:80]}")
        else:
            out["title_status"] = None
            print(f"- {svc:12} título (sem exemplo verificável sem a API)")

    n_app = sum(1 for s in service_rows.values() if s["has_applink"])
    summary = {"checked_at": dt.date.today().isoformat(),
               "services_with_applink": n_app, "services_total": len(SERVICES),
               "services": service_rows, "domains": domain_rows}
    path = save_json("assetlinks.json", summary)
    banner(f"{n_app}/{len(SERVICES)} streamings declaram pacote Android via assetlinks · {path.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
