# Build desktop via Wails usando caminho absoluto do binario local.
# Envia notificacao Slack apenas em caso de falha.

$ErrorActionPreference = "Stop"

try {
  & "D:\proj\mini\tools\wails.exe" build
  if ($LASTEXITCODE -ne 0) {
    throw "wails build retornou codigo $LASTEXITCODE"
  }
}
catch {
  $msg = "Falha no build (wails build) em $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')"
  & "D:\proj\mini\scripts\slack-notify.ps1" -Text $msg
  throw
}
