# Funcoes para notificar Slack. Requer SLACK_MINI_WEBHOOK no ambiente.
# Dot-source a partir de outros scripts em scripts/:
#   . (Join-Path $PSScriptRoot "slack-invoke.ps1")

# Pasta scripts/ (PSScriptRoot pode falhar dentro de funcoes em alguns cenarios)
$script:_slackScriptsDir = $PSScriptRoot
if ([string]::IsNullOrWhiteSpace($script:_slackScriptsDir)) {
  $script:_slackScriptsDir = Split-Path -Parent $MyInvocation.MyCommand.Path
}

function Get-SlackMiniWebhook {
  # 1) Processo atual (herdado ao abrir o terminal)
  $v = $env:SLACK_MINI_WEBHOOK
  if (-not [string]::IsNullOrWhiteSpace($v)) { return $v.Trim() }
  # 2) User (Painel Windows > Variaveis de ambiente do utilizador)
  $v = [Environment]::GetEnvironmentVariable("SLACK_MINI_WEBHOOK", "User")
  if (-not [string]::IsNullOrWhiteSpace($v)) { return $v.Trim() }
  # 3) Machine (variaveis de sistema)
  $v = [Environment]::GetEnvironmentVariable("SLACK_MINI_WEBHOOK", "Machine")
  if (-not [string]::IsNullOrWhiteSpace($v)) { return $v.Trim() }
  # 4) Ficheiro na raiz do repo (uma URL por linha; ignora linhas vazias e #)
  $repoRoot = (Resolve-Path (Join-Path $script:_slackScriptsDir "..")).Path
  $hookFile = Join-Path $repoRoot ".slack-webhook"
  if (Test-Path $hookFile) {
    foreach ($line in Get-Content -LiteralPath $hookFile -Encoding UTF8) {
      $t = $line.Trim()
      if ($t.Length -eq 0 -or $t.StartsWith("#")) { continue }
      if ($t.StartsWith("https://")) { return $t }
    }
  }
  return $null
}

function Send-SlackNotification {
  param(
    [Parameter(Mandatory = $true)]
    [string]$Text
  )
  $notify = Join-Path $script:_slackScriptsDir "slack-notify.ps1"
  $webhook = Get-SlackMiniWebhook
  if ([string]::IsNullOrWhiteSpace($webhook)) {
    Write-Warning "Slack: webhook nao encontrada (SLACK_MINI_WEBHOOK ou ficheiro .slack-webhook na raiz); notificacao nao enviada."
    return
  }
  # slack-notify.ps1 le $env:SLACK_MINI_WEBHOOK — hidratar a partir do registo se preciso
  $env:SLACK_MINI_WEBHOOK = $webhook
  if (-not (Test-Path $notify)) {
    Write-Warning "Slack: nao encontrado $notify"
    return
  }
  try {
    & $notify -Text $Text -ErrorAction Stop
    Write-Host "Slack: notificacao enviada."
  }
  catch {
    Write-Warning "Slack: falha ao enviar — $($_.Exception.Message)"
  }
}
