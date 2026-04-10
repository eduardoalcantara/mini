# Executa o binario gerado por wails build (nao use "go run" para o app desktop).
# Faca o build antes: .\scripts\build.ps1
#
# O executavel segue wails.json -> outputfilename "mini": build\bin\mini.exe
# (nao confundir com frontend/dist, que e' HTML/CSS/JS embutido.)
#
# Uso:
#   .\scripts\build.ps1
#   .\scripts\run.ps1

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$appExe = Join-Path $repoRoot "build\bin\mini.exe"

if (-not (Test-Path $appExe)) {
  throw "Executavel nao encontrado: $appExe`nExecute primeiro: .\scripts\build.ps1"
}

Write-Host "Executando: $appExe"
& $appExe
if ($LASTEXITCODE -ne 0) {
  throw "app retornou codigo $LASTEXITCODE"
}
