# Build de producao via Wails CLI (obrigatorio: injeta tags desktop,production).
# Nao substitua por "go build" na raiz — veja:
# https://wails.io/docs/guides/manual-builds/
#
# Onde fica o dist:
#   - wails.json: "assetdir": "frontend"  ->  saida em frontend/dist/
#   - main.go:    //go:embed all:frontend/dist
# Ter src/ (Go) e frontend/ como pastas irmaas na raiz e' o layout deste repo;
# o erro de "build tags" aparece ao compilar sem wails build, nao por causa dessa separacao.
#
# Uso:
#   .\scripts\build.ps1
#
# Envia notificacao Slack apenas em caso de falha (se slack-notify.ps1 existir).

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$wailsExe = Join-Path $repoRoot "tools\wails.exe"
$slackNotify = Join-Path $PSScriptRoot "slack-notify.ps1"
$frontendDist = Join-Path $repoRoot "frontend\dist"
$outExe = Join-Path $repoRoot "build\bin\mini.exe"

if (-not (Test-Path $wailsExe)) {
  throw "Nao encontrei o Wails em: $wailsExe"
}

try {
  Set-Location $repoRoot
  & $wailsExe build
  if ($LASTEXITCODE -ne 0) {
    throw "wails build retornou codigo $LASTEXITCODE"
  }

  $distIndex = Join-Path $frontendDist "index.html"
  if (-not (Test-Path $distIndex)) {
    throw "Esperado apos o build: $distIndex (pnpm run build no frontend nao populou frontend/dist)."
  }

  Write-Host "Build OK: $outExe"
  Write-Host "Assets embarcados (embed): $frontendDist"
}
catch {
  if (Test-Path $slackNotify) {
    $msg = "Falha no build (wails build) em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    & $slackNotify -Text $msg
  }
  throw
}
