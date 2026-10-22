# research/ — fase 01 (validar fontes de "onde assistir")

Scripts Python standalone (venv) que testam, com chamadas reais, as três fontes de
disponibilidade e os links que abrem o app. O documento de decisão está em
`../docs/decisoes-apis.md`.

## Rodar

```powershell
cd research
Copy-Item .env.example .env   # preencher as chaves (fica fora do git)
.\run_all.ps1
```

Ou um por vez com `.\.venv\Scripts\python.exe <script>`.

| Script | Precisa de chave | Saída |
|---|---|---|
| `04_assetlinks.py` | não | `out/assetlinks.json` — pacotes Android por streaming + links de busca |
| `05_netflix_csv.py` | não (usa o CSV se existir) | `out/netflix_csv_format.json` — formato, sem dados pessoais |
| `01_tmdb_providers.py` | `TMDB_API_KEY` | `out/tmdb_br.json` |
| `02_watchmode.py` | `WATCHMODE_API_KEY` | `out/watchmode_br.json` |
| `03_streaming_availability.py` | `RAPIDAPI_KEY` | `out/streaming_availability_br.json` |
| `06_compare.py` | não | `out/summary.md` — tabela fonte × critério |

Ordem: 04 → 05 → 01 → 02 → 03 → 06 (02 e 03 reaproveitam os ids do TMDB; 03 usa os domínios do 04).

## Regras embutidas
- `BudgetGuard` em cada API: TMDB 100 chamadas, Watchmode 120 créditos (<5% dos 2.500), MOTN 60 req (6% dos 1.000). Nunca passa de 20% da cota.
- Sem retry em 4xx (401/403/429 repetido é cota jogada fora); um retry em erro de rede/5xx.
- Scripts com chave ausente saem com código 2 e a mensagem `[bloqueado]`, sem imprimir valores.
- `out/raw/` (respostas brutas) e `NetflixViewingHistory.csv` ficam fora do git; os resumos em `out/*.json` entram.
