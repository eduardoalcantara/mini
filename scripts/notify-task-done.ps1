# Notificacao Slack ao concluir spec/tarefa (Protocolo em .cursor/rules/02-workflow.md).
# Usa slack-invoke.ps1: SLACK_MINI_WEBHOOK, registo User/Machine ou .slack-webhook na raiz.
#
# Uso:
#   .\scripts\notify-task-done.ps1 -Summary "SPEC CodeMirror 6 concluida"

param(
  [Parameter(Mandatory = $true)]
  [string]$Summary
)

$ErrorActionPreference = "Stop"

. (Join-Path $PSScriptRoot "slack-invoke.ps1")

$msg = "Mini — tarefa concluida: $Summary ($(Get-Date -Format 'yyyy-MM-dd HH:mm:ss'))"
Send-SlackNotification -Text $msg
