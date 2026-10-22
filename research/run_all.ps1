# Fase 01 · roda toda a pesquisa. Uso (PowerShell, nesta pasta):
#   .\run_all.ps1
# Cria o venv se faltar, instala dependências e roda os scripts na ordem.
# Os que precisam de chave param sozinhos com "[bloqueado]" se o .env não tiver a variável.
$ErrorActionPreference = "Stop"
Set-Location $PSScriptRoot

if (-not (Test-Path ".venv\Scripts\python.exe")) {
    python -m venv .venv
}
$py = ".\.venv\Scripts\python.exe"
& $py -m pip install -q -r requirements.txt

if (-not (Test-Path ".env")) {
    Write-Host "[aviso] research\.env não existe: copie .env.example e preencha as chaves. Rodando só o que não precisa de chave." -ForegroundColor Yellow
}

# Ordem importa: 04 antes do 03 (domínios com assetlinks), 01 antes de 02/03 (ids do TMDB).
$scripts = @("04_assetlinks.py", "05_netflix_csv.py", "01_tmdb_providers.py",
             "02_watchmode.py", "03_streaming_availability.py", "06_compare.py")
foreach ($s in $scripts) {
    Write-Host "`n##### $s" -ForegroundColor Cyan
    & $py $s
    if ($LASTEXITCODE -eq 2) { Write-Host "[pulado] $s (chave ausente)" -ForegroundColor Yellow }
    elseif ($LASTEXITCODE -ne 0) { Write-Host "[falhou] $s (código $LASTEXITCODE)" -ForegroundColor Red }
}
Write-Host "`nResumo: out\summary.md" -ForegroundColor Green
