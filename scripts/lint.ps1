# Lint backend Go usando binario local, sem PATH global.
# Envia notificacao Slack apenas em caso de falha.

$ErrorActionPreference = "Stop"

try {
  & "D:\proj\mini\tools\golangci-lint.exe" run
  if ($LASTEXITCODE -ne 0) {
    throw "golangci-lint retornou codigo $LASTEXITCODE"
  }
}
catch {
  $msg = "Falha no lint (golangci-lint) em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  & "D:\proj\mini\scripts\slack-notify.ps1" -Text $msg
  throw
}
