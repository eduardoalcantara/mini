# Instala wails.exe e golangci-lint.exe em tools/ via go install (GOBIN).
# Os .exe nao sao versionados (.gitignore); rode este script apos clone.
#
# Requisito: Go instalado e acessivel no PATH.
#
# Uso:
#   .\scripts\install-tools.ps1

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$toolsDir = Join-Path $repoRoot "tools"

if (-not (Get-Command go -ErrorAction SilentlyContinue)) {
  throw "Go nao encontrado no PATH. Instale Go e tente de novo."
}

New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null

$prevGobin = $env:GOBIN
$env:GOBIN = $toolsDir

try {
  Write-Host "GOBIN=$toolsDir"
  Write-Host "Instalando Wails v2.12.0..."
  go install github.com/wailsapp/wails/v2/cmd/wails@v2.12.0
  if ($LASTEXITCODE -ne 0) { throw "go install wails falhou com codigo $LASTEXITCODE" }

  # v2.x — alinhado a .cursor/rules/ENVIRONMENT-RULES-v1.0.md (nao usar import path v1)
  Write-Host "Instalando golangci-lint v2.11.4..."
  go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@v2.11.4
  if ($LASTEXITCODE -ne 0) { throw "go install golangci-lint falhou com codigo $LASTEXITCODE" }
}
finally {
  $env:GOBIN = $prevGobin
}

$wails = Join-Path $toolsDir "wails.exe"
$lint = Join-Path $toolsDir "golangci-lint.exe"
if (-not (Test-Path $wails)) { throw "Esperado apos install: $wails" }
if (-not (Test-Path $lint)) { throw "Esperado apos install: $lint" }

Write-Host "OK: $wails"
Write-Host "OK: $lint"
& $wails version
& $lint version
