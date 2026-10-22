"""Shared helpers for the phase-01 research scripts.

Everything here is deliberately small: env loading, an HTTP wrapper that
never retries on 4xx (quota is precious), a budget guard per API and the
fixed 20-title sample from prompts/01-validar-apis.md.
"""
from __future__ import annotations

import json
import os
import re
import sys
import time
from dataclasses import dataclass, field
from pathlib import Path
from typing import Any

import requests
from dotenv import load_dotenv

ROOT = Path(__file__).resolve().parent
OUT = ROOT / "out"
RAW = OUT / "raw"
load_dotenv(ROOT / ".env")

USER_AGENT = "plateia-research/0.1 (phase-01 API validation; contact: project owner)"


# ---------------------------------------------------------------------------
# Sample: 20 titles. `expected` is the streaming the prompt groups the title
# under; it is the reference for "% da amostra com streaming certo".
# Movies have no expected provider in the prompt, so they only count for
# coverage and for the manual JustWatch check.
# ---------------------------------------------------------------------------
@dataclass(frozen=True)
class Title:
    name: str            # pt-BR name as the prompt lists it
    kind: str            # "movie" | "tv"
    year: int            # first-air / release year, used to disambiguate search
    expected: tuple[str, ...] = ()   # normalized provider keys (see PROVIDER_KEYS)
    query: str | None = None         # alternative search string when pt-BR name is ambiguous

    @property
    def slug(self) -> str:
        return re.sub(r"[^a-z0-9]+", "-", self.name.lower()).strip("-")


SAMPLE: list[Title] = [
    Title("Stranger Things", "tv", 2016, ("netflix",)),
    Title("Round 6", "tv", 2021, ("netflix",), query="Squid Game"),
    Title("Wandinha", "tv", 2022, ("netflix",), query="Wednesday"),
    Title("Sintonia", "tv", 2019, ("netflix",)),
    Title("The Last of Us", "tv", 2023, ("max",)),
    Title("A Casa do Dragão", "tv", 2022, ("max",), query="House of the Dragon"),
    Title("The Bear", "tv", 2022, ("disney",)),
    Title("Andor", "tv", 2022, ("disney",)),
    Title("The Boys", "tv", 2019, ("prime",)),
    Title("Invencível", "tv", 2021, ("prime",), query="Invincible"),
    Title("Arcanjo Renegado", "tv", 2018, ("globoplay",)),
    # Anime: the 1999 series, not the 2023 live-action. Crunchyroll is the
    # usual home in Brazil, Netflix carries part of it.
    Title("One Piece", "tv", 1999, ("crunchyroll", "netflix")),
    Title("Frieren", "tv", 2023, ("crunchyroll",), query="Frieren: Beyond Journey's End"),
    Title("Ainda Estou Aqui", "movie", 2024),
    Title("Cidade de Deus", "movie", 2002, query="City of God"),
    Title("Divertida Mente 2", "movie", 2024, query="Inside Out 2"),
    Title("Duna: Parte Dois", "movie", 2024, query="Dune: Part Two"),
    Title("Oppenheimer", "movie", 2023),
    Title("Ruptura", "tv", 2022, ("apple",), query="Severance"),
    Title("Yellowstone", "tv", 2018, ("paramount",)),
]

# Substring (lowercase) -> normalized key. Order matters: "hbo max" must hit
# "max" and "amazon prime video" must hit "prime".
PROVIDER_KEYS: list[tuple[str, str]] = [
    ("netflix", "netflix"),
    ("hbo", "max"),
    ("max", "max"),
    ("disney", "disney"),
    ("prime", "prime"),
    ("amazon", "amazon_store"),   # rent/buy store, not the subscription
    ("globoplay", "globoplay"),
    ("globo", "globoplay"),
    ("crunchyroll", "crunchyroll"),
    ("apple", "apple"),
    ("paramount", "paramount"),
    ("youtube", "youtube"),
    ("google", "google_play"),
    ("claro", "claro"),
    ("mubi", "mubi"),
    ("telecine", "telecine"),
    ("looke", "looke"),
]


def normalize_provider(name: str) -> str:
    """Map a provider display name to a short key; unknown names pass through."""
    low = name.lower()
    for needle, key in PROVIDER_KEYS:
        if needle in low:
            return key
    return re.sub(r"[^a-z0-9]+", "_", low).strip("_")


# ---------------------------------------------------------------------------
# Budget guard: hard cap per API so a bug can never burn the monthly quota.
# ---------------------------------------------------------------------------
class BudgetExceeded(RuntimeError):
    pass


@dataclass
class BudgetGuard:
    api: str
    cap: int
    used: int = 0

    def spend(self, n: int = 1) -> None:
        if self.used + n > self.cap:
            raise BudgetExceeded(f"{self.api}: cap de {self.cap} chamadas atingido ({self.used} usadas)")
        self.used += n


# ---------------------------------------------------------------------------
# HTTP wrapper. One retry only on network errors / 5xx; never on 4xx, because
# a 401/403/429 retried is quota thrown away.
# ---------------------------------------------------------------------------
@dataclass
class Response:
    status: int
    data: Any                 # parsed JSON, or raw text when not JSON
    headers: dict[str, str]   # only the x-* / ratelimit headers we care about
    url: str
    elapsed_ms: int

    @property
    def ok(self) -> bool:
        return 200 <= self.status < 300


INTERESTING_HEADERS = ("x-ratelimit", "x-requests", "x-account", "ratelimit", "retry-after", "x-rapidapi")


def http_get(url: str, *, params: dict | None = None, headers: dict | None = None,
             guard: BudgetGuard | None = None, timeout: float = 20.0,
             allow_redirects: bool = True) -> Response:
    if guard is not None:
        guard.spend()
    hdrs = {"User-Agent": USER_AGENT, "Accept": "application/json"}
    if headers:
        hdrs.update(headers)
    last_exc: Exception | None = None
    for attempt in (1, 2):
        try:
            t0 = time.perf_counter()
            r = requests.get(url, params=params, headers=hdrs, timeout=timeout,
                             allow_redirects=allow_redirects)
            elapsed = int((time.perf_counter() - t0) * 1000)
            try:
                data = r.json()
            except ValueError:
                data = r.text[:2000]
            kept = {k.lower(): v for k, v in r.headers.items()
                    if any(k.lower().startswith(p) for p in INTERESTING_HEADERS)}
            resp = Response(r.status_code, data, kept, r.url, elapsed)
            if r.status_code >= 500 and attempt == 1:
                time.sleep(1.5)
                continue
            return resp
        except requests.RequestException as exc:   # DNS, timeout, connection reset
            last_exc = exc
            if attempt == 1:
                time.sleep(1.5)
                continue
    return Response(0, f"network error: {last_exc}", {}, url, 0)


# ---------------------------------------------------------------------------
# Env + output helpers
# ---------------------------------------------------------------------------
def require_env(name: str) -> str:
    """Exit with a clear message when a key is missing. Never prints the value."""
    value = os.getenv(name, "").strip()
    if not value:
        print(f"[bloqueado] variável {name} ausente em research/.env (veja .env.example)", file=sys.stderr)
        sys.exit(2)
    return value


def save_json(relpath: str, payload: Any) -> Path:
    path = OUT / relpath
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(payload, ensure_ascii=False, indent=2), encoding="utf-8")
    return path


def save_raw(source: str, name: str, payload: Any) -> None:
    """Raw API responses go to out/raw/<source>/ (gitignored)."""
    save_json(f"raw/{source}/{name}.json", payload)


def pct(part: int, whole: int) -> str:
    return "n/a" if whole == 0 else f"{100 * part / whole:.0f}%"


def banner(text: str) -> None:
    print(f"\n=== {text} ===")


def env_present(name: str) -> bool:
    """True when the key exists in research/.env; never prints the value."""
    return bool(os.getenv(name, "").strip())


def load_summary(relpath: str) -> Any | None:
    """Read a previous script's summary (e.g. tmdb_br.json) or None if it is missing/corrupt."""
    path = OUT / relpath
    if not path.exists():
        return None
    try:
        return json.loads(path.read_text(encoding="utf-8"))
    except (OSError, ValueError) as exc:
        print(f"[aviso] não consegui ler {path.name}: {exc}", file=sys.stderr)
        return None


def tmdb_ids_from_summary() -> dict[str, tuple[str, int]]:
    """slug -> (kind, tmdb_id) from out/tmdb_br.json, so Watchmode/MOTN skip name search."""
    data = load_summary("tmdb_br.json") or {}
    ids: dict[str, tuple[str, int]] = {}
    for row in data.get("titles", []):
        if row.get("tmdb_id"):
            ids[row["slug"]] = (row["kind"], int(row["tmdb_id"]))
    return ids
