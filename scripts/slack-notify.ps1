# Envia uma mensagem para o Slack via Incoming Webhook.
# Requer a variavel de ambiente: SLACK_MINI_WEBHOOK
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
