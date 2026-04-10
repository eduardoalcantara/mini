# Verifica ambiente Wails sem depender de PATH global.

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$wailsExe = Join-Path $repoRoot "tools\wails.exe"

if (-not (Test-Path $wailsExe)) {
  throw "Nao encontrei Wails em: $wailsExe`nExecute: .\scripts\install-tools.ps1"
}

Set-Location $repoRoot
& $wailsExe doctor
