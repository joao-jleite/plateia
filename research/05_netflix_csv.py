"""Fase 01 · Teste 5: formato do CSV de histórico da Netflix.

Se research/NetflixViewingHistory.csv existir: detecta encoding/BOM,
delimitador, cabeçalho, formato de data e os padrões de título de série
(": Temporada N:", ": Parte N:", ": Minissérie:" etc.) e grava um resumo
ANONIMIZADO em out/netflix_csv_format.json (contagens e padrões, nunca a
lista de títulos nem datas). O CSV em si está no .gitignore.

Sem o arquivo: grava o formato documentado publicamente, marcado como
"a confirmar com o CSV real".

Uso:  .venv/Scripts/python 05_netflix_csv.py [caminho.csv]
"""
from __future__ import annotations

import csv
import re
import sys
from collections import Counter
from pathlib import Path

from common import ROOT, banner, save_json

DEFAULT = ROOT / "NetflixViewingHistory.csv"

# Padrões de episódio (pt-BR, en, es), do mais ao menos específico.
PATTERNS = [
    ("temporada_num", re.compile(r"^(?P<show>.+?): (?:Temporada|Season) (?P<n>\d+): (?P<ep>.+)$")),
    ("parte_num", re.compile(r"^(?P<show>.+?): (?:Parte|Part) (?P<n>\d+): (?P<ep>.+)$")),
    ("volume_num", re.compile(r"^(?P<show>.+?): (?:Volume|Vol\.) (?P<n>\d+): (?P<ep>.+)$")),
    ("minisserie", re.compile(r"^(?P<show>.+?): (?:Minissérie|Limited Series|Miniserie): (?P<ep>.+)$")),
    ("capitulo", re.compile(r"^(?P<show>.+?): (?:Capítulo|Chapter|Episódio|Episode) (?P<n>\d+)$")),
    ("arco_nomeado", re.compile(r"^(?P<show>.+?): (?P<season>[^:]+): (?P<ep>.+)$")),   # ex.: One Piece: East Blue: ...
]
DATE_FORMATS = {
    r"^\d{1,2}/\d{1,2}/\d{2}$": "D/M/YY ou M/D/YY (ambíguo: decidir pelo maior valor >12)",
    r"^\d{1,2}/\d{1,2}/\d{4}$": "DD/MM/YYYY ou MM/DD/YYYY",
    r"^\d{4}-\d{2}-\d{2}$": "YYYY-MM-DD",
}

DOCUMENTED = {
    "status": "a confirmar com o CSV real",
    "download": ("Conta > Perfis > Atividade de visualização > 'Baixar tudo' (CSV por perfil). "
                 "Exportação completa em netflix.com/account/getmyinfo (até 30 dias; zip com ViewingActivity.csv)."),
    "file_name": "NetflixViewingHistory.csv",
    "encoding": "UTF-8 (frequentemente com BOM)",
    "delimiter": ",",
    "header": ["Title", "Date"],
    "date_format": ("depende do locale da conta: contas BR costumam vir D/M/YY (ex.: 15/07/24); contas US vêm M/D/YY. "
                    "Tratar como ambíguo e inferir pelo conjunto (algum primeiro campo >12 decide dia-primeiro)."),
    "one_row_per": "episódio ou filme assistido (uma linha por sessão; repetições aparecem de novo)",
    "title_patterns_pt_br": [
        "Série por número: 'Stranger Things: Temporada 1: Capítulo Um: O Desaparecimento de Will Byers'",
        "Série por parte: 'La Casa de Papel: Parte 2: Episódio 1'",
        "Minissérie: 'Título: Minissérie: Episódio 1'",
        "Anime com arco nomeado: 'One Piece: East Blue: Eu sou Luffy! O homem que vai ser o Rei dos Piratas!'",
        "Filme: título puro, sem dois-pontos de estrutura: 'Oppenheimer' (títulos com ':' no nome exigem heurística)",
        "Trailers/extras podem aparecer como título normal; este CSV não tem coluna de tipo (só o ViewingActivity.csv da exportação completa).",
    ],
    "full_export_columns": ["Profile Name", "Start Time", "Duration", "Attributes", "Title",
                            "Supplemental Video Type", "Device Type", "Bookmark", "Latest Bookmark", "Country"],
    "matching_strategy": ("extrair o nome da série (texto antes do primeiro ': Temporada|Parte|Minissérie|<arco>'), "
                          "deduplicar por série, buscar no TMDB em pt-BR; filmes buscam o título inteiro com fallback sem subtítulo."),
}


def classify(title: str) -> str:
    for name, rx in PATTERNS:
        if rx.match(title):
            return name
    return "filme_ou_sem_padrao"


def analyze(path: Path) -> dict:
    raw = path.read_bytes()
    bom = raw.startswith(b"\xef\xbb\xbf")
    try:
        text = raw.decode("utf-8-sig")
        encoding = "utf-8" + (" com BOM" if bom else "")
    except UnicodeDecodeError:
        text = raw.decode("latin-1")
        encoding = "latin-1 (fallback)"
    try:
        delimiter = csv.Sniffer().sniff(text[:4096], delimiters=",;\t").delimiter
    except csv.Error:
        delimiter = ","
    rows = list(csv.reader(text.splitlines(), delimiter=delimiter))
    if not rows:
        return {"status": "arquivo vazio"}
    header, body = rows[0], [r for r in rows[1:] if len(r) >= 2]
    date_shapes, title_kinds, shows = Counter(), Counter(), set()
    day_first_proof = False
    for r in body:
        title, date = r[0].strip(), r[-1].strip()
        shape = next((d for rx, d in DATE_FORMATS.items() if re.match(rx, date)), "desconhecido")
        date_shapes[shape] += 1
        m = re.match(r"^(\d{1,2})/(\d{1,2})/", date)
        if m and int(m.group(1)) > 12:
            day_first_proof = True   # primeiro campo >12 só pode ser dia
        kind = classify(title)
        title_kinds[kind] += 1
        if kind != "filme_ou_sem_padrao":
            shows.add(title.split(":")[0])
    n_series_rows = sum(v for k, v in title_kinds.items() if k != "filme_ou_sem_padrao")
    return {
        "status": "analisado a partir do CSV real (resumo anonimizado)",
        "file_name": path.name, "encoding": encoding, "delimiter": delimiter, "header": header,
        "rows": len(body), "date_shapes": dict(date_shapes),
        "date_order": "dia primeiro (confirmado por valor >12)" if day_first_proof else "ambíguo na amostra",
        "title_kinds": dict(title_kinds), "distinct_series": len(shows),
        "series_share": f"{100 * n_series_rows / max(1, len(body)):.0f}%",
        "example_shapes": [
            "Série: '<Série>: Temporada <n>: <episódio>'", "Parte: '<Série>: Parte <n>: <episódio>'",
            "Arco: '<Série>: <nome do arco>: <episódio>'", "Filme: '<Título>'",
        ],
    }


def main() -> int:
    path = Path(sys.argv[1]) if len(sys.argv) > 1 else DEFAULT
    banner("CSV da Netflix")
    if path.exists():
        try:
            result = analyze(path)
        except (OSError, csv.Error) as exc:
            print(f"[erro] não consegui ler {path.name}: {exc}")
            return 1
        print(f"- {result.get('rows')} linhas · cabeçalho {result.get('header')} · datas {result.get('date_shapes')}")
        print(f"- tipos de título: {result.get('title_kinds')} · {result.get('distinct_series')} séries distintas")
    else:
        result = DOCUMENTED
        print(f"- {path.name} não existe; gravando o formato documentado (a confirmar com o CSV real)")
    out = save_json("netflix_csv_format.json", result)
    print(f"-> {out.name}")
    return 0


if __name__ == "__main__":
    sys.exit(main())
