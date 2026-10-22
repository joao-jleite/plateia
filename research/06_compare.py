"""Fase 01 · Consolida os resumos em out/*.json numa tabela fonte × critério.

Lê o que existir (tmdb_br.json, watchmode_br.json, streaming_availability_br.json,
assetlinks.json, netflix_csv_format.json) e grava out/summary.md. Fonte sem
resumo aparece como "bloqueado (sem chave)". Não faz chamada de rede.

Uso:  .venv/Scripts/python 06_compare.py
"""
from __future__ import annotations

import sys

from common import OUT, SAMPLE, banner, load_summary

# Dados que não vêm de teste e sim da página de preços/termos de cada fornecedor (22/10/2026).
PRICING = {
    "tmdb": {"free": "sem cota mensal; rate limit ~50 req/s; grátis só não comercial, com atribuição",
             "paid": "licença comercial sob consulta (sales@themoviedb.org); terceiros citam ~US$ 149/mês",
             "terms": "atribuir TMDB e JustWatch; `link` leva à página do TMDB, não ao streaming"},
    "watchmode": {"free": "2.500 créditos/mês, até 3 países, não comercial, SEM deep link de app",
                  "paid": "Startup US$ 349/mês (40k) · Business US$ 599/mês (100k)",
                  "terms": "cache máx. 30 dias no grátis; não revender; atribuição conforme plano"},
    "streaming_availability": {"free": "1.000 req/mês, uso comercial permitido, deep link incluso",
                               "paid": "Starter US$ 49/mês (25k) · Growth US$ 99 (100k) · Scale US$ 299 (1M)",
                               "terms": "atribuição se os dados forem públicos; cache livre; sem Globoplay"},
}


def blocked(name: str) -> dict:
    return {"_blocked": True, "name": name}


def row(label: str, s: dict) -> str:
    if s.get("_blocked"):
        return f"| {label} | bloqueado (sem chave) | — | — | — | {PRICING[s['name']]['free']} | {PRICING[s['name']]['paid']} | {PRICING[s['name']]['terms']} |"
    src = s["source"]
    covers = {"tmdb": f"sim ({s['with_br_providers']}/{s['sample']} com provedores BR)",
              "watchmode": f"{'sim' if s['br_in_regions'] else 'NÃO'} ({s['with_br_sources']}/{s['sample']} com sources BR)",
              "streaming_availability": f"{'sim' if s['br_covered'] else 'NÃO'} ({s['with_br_options']}/{s['sample']} com opções BR; Globoplay: {'sim' if s['globoplay_in_services'] else 'não'})"}[src]
    deep = {"tmdb": "não (link para página do TMDB)",
            "watchmode": f"android_url real em {s['with_android_url']}/{s['sample']}",
            "streaming_availability": f"link em {s['with_link']}/{s['sample']}; em domínio com assetlinks: {s['with_link_on_assetlinks_domain']}"}[src]
    return (f"| {label} | {covers} | {s['expected_found']}/{s['expected_checked']} ({s['expected_pct']}) | {deep} | "
            f"{s['calls_used']} | {PRICING[src]['free']} | {PRICING[src]['paid']} | {PRICING[src]['terms']} |")


def main() -> int:
    tmdb = load_summary("tmdb_br.json") or blocked("tmdb")
    wm = load_summary("watchmode_br.json") or blocked("watchmode")
    sa = load_summary("streaming_availability_br.json") or blocked("streaming_availability")
    al = load_summary("assetlinks.json")
    csvf = load_summary("netflix_csv_format.json")

    lines = ["# Resumo da fase 01 (gerado por 06_compare.py)", "",
             f"Amostra: {len(SAMPLE)} títulos · {sum(1 for t in SAMPLE if t.expected)} com streaming esperado.", "",
             "| Fonte | Cobre BR | % amostra com streaming certo | Deep link | Chamadas gastas | Plano grátis | Plano comercial | Termos |",
             "|---|---|---|---|---|---|---|---|",
             row("TMDB watch/providers", tmdb), row("Watchmode", wm), row("Streaming Availability (MOTN)", sa), ""]

    if al:
        lines += [f"## Links que abrem o app (assetlinks) — {al['services_with_applink']}/{al['services_total']} streamings", "",
                  "| Streaming | Pacote Android | Busca (plano B) | Status busca | Status título |", "|---|---|---|---|---|"]
        for svc, s in al["services"].items():
            pk = ", ".join(p for p in s["packages"] if "debug" not in p and "internal" not in p) or "nenhum"
            lines.append(f"| {svc} | {pk} | {s['search'] or '—'} | {s.get('search_status') or '—'} | {s.get('title_status')} |")
        lines.append("")

    # Lado a lado por título (só as fontes que rodaram)
    lines += ["## Por título (assinatura em BR)", "", "| Título | Esperado | TMDB | Watchmode | MOTN |", "|---|---|---|---|---|"]
    by = lambda s: {t["slug"]: t for t in s.get("titles", [])} if not s.get("_blocked") else {}
    tm, wmm, sam = by(tmdb), by(wm), by(sa)
    for t in SAMPLE:
        a = tm.get(t.slug); b = wmm.get(t.slug); c = sam.get(t.slug)
        ca = ", ".join(a["providers"].get("flatrate", [])) if a else "—"
        cb = ", ".join(sorted({x["name"] for x in b["sources"] if x["type"] == "sub"})) if b else "—"
        cc = ", ".join(sorted({x["service_name"] or "" for x in c["options"] if x["type"] == "subscription"})) if c else "—"
        lines.append(f"| {t.name} | {', '.join(t.expected) or '—'} | {ca or '(nenhum)'} | {cb or '(nenhum)'} | {cc or '(nenhum)'} |")
    lines.append("")

    if csvf:
        lines += ["## CSV da Netflix", "", f"- Status: {csvf.get('status')}",
                  f"- Cabeçalho: {csvf.get('header')} · encoding: {csvf.get('encoding')}",
                  f"- Datas: {csvf.get('date_format') or csvf.get('date_shapes')}", ""]

    path = OUT / "summary.md"
    path.write_text("\n".join(lines), encoding="utf-8")
    banner(f"resumo em {path}")
    print("\n".join(lines[:9]))
    return 0


if __name__ == "__main__":
    sys.exit(main())
