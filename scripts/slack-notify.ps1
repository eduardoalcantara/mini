# Envia uma mensagem para o Slack via Incoming Webhook.
# Requer SLACK_MINI_WEBHOOK no processo (slack-invoke.ps1 hidrata a partir de
# variavel User/Machine ou ficheiro .slack-webhook na raiz do repo).
#
# Os scripts build.ps1 e lint.ps1 usam slack-invoke.ps1, que so chama este script
# quando o webhook esta definido (evita exit 1 por webhook ausente).
#
# Exemplos:
#   .\scripts\slack-notify.ps1 -Text "Build concluido com sucesso"
#   .\scripts\slack-notify.ps1 -Text "Lint falhou" -Username "TED Bot"

param(
  [Parameter(Mandatory = $true)]
  [string]$Text,
  [string]$Username = "TED Notifier"
)

$webhook = $env:SLACK_MINI_WEBHOOK
if ([string]::IsNullOrWhiteSpace($webhook)) {
  Write-Error "Variavel SLACK_MINI_WEBHOOK nao definida."
  exit 1
}

$payload = @{
  text = $Text
  username = $Username
} | ConvertTo-Json -Compress

try {
  Invoke-RestMethod `
    -Uri $webhook `
    -Method Post `
    -ContentType "application/json; charset=utf-8" `
    -Body $payload | Out-Null
  Write-Output "Slack notification: OK"
}
catch {
  Write-Error "Falha ao enviar notificacao para o Slack: $($_.Exception.Message)"
  exit 1
}
