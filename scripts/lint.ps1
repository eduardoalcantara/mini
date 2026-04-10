# Lint backend Go usando binario local em tools/, sem PATH global.
# Envia notificacao Slack apenas em caso de falha.

$ErrorActionPreference = "Stop"

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$lintExe = Join-Path $repoRoot "tools\golangci-lint.exe"
$slackNotify = Join-Path $PSScriptRoot "slack-notify.ps1"

if (-not (Test-Path $lintExe)) {
  throw "Nao encontrei golangci-lint em: $lintExe`nExecute: .\scripts\install-tools.ps1"
}

try {
  Set-Location $repoRoot
  & $lintExe run
  if ($LASTEXITCODE -ne 0) {
    throw "golangci-lint retornou codigo $LASTEXITCODE"
  }
}
catch {
  if (Test-Path $slackNotify) {
    $msg = "Falha no lint (golangci-lint) em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
    & $slackNotify -Text $msg
  }
  throw
}
