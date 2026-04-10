# Lint backend Go usando binario local em tools/, sem PATH global.
# Slack: notifica falhas se SLACK_MINI_WEBHOOK estiver definida (ver slack-invoke.ps1).

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "slack-invoke.ps1")

$repoRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
$lintExe = Join-Path $repoRoot "tools\golangci-lint.exe"

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
  $msg = "Falha no lint (golangci-lint) em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  Send-SlackNotification -Text $msg
  throw
}
