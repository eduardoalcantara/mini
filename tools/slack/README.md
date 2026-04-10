# Slack — App de notificações (mini)

Este diretório contém o **manifesto** para criar um app Slack focado em **Incoming Webhooks**, usado por scripts locais (por exemplo `scripts/slack-notify.ps1`) para enviar mensagens a um canal ou DM.

## Arquivos

| Arquivo | Uso |
|--------|-----|
| `slack-app-manifest.yaml` | Colar no fluxo **Create New App → From an app manifest** (recomendado). |
| `slack-app-manifest.json` | Mesmo conteúdo em JSON, se a interface pedir JSON. |

## Conformidade com o schema (importante)

O manifesto segue a referência oficial ([App manifest reference](https://docs.slack.dev/reference/app-manifest)):

- `display_information.name`: no máximo **35** caracteres.
- `display_information.description`: no máximo **140** caracteres (descrição curta).
- `display_information.long_description`: opcional; texto longo (até 4000 caracteres).
- **Incoming Webhooks** não ficam em `features`: usam `settings.incoming_webhooks.incoming_webhooks_enabled` (ver [Incoming webhooks no manifest](https://docs.slack.dev/reference/app-manifest)).

Guia geral: [Configuring apps with app manifests](https://docs.slack.dev/app-manifests/configuring-apps-with-app-manifests/).

## Passos no Slack

1. Abra [Your Apps](https://api.slack.com/apps).
2. **Create New App** → **From an app manifest**.
3. Escolha o **workspace** onde as notificações devem aparecer.
4. Cole o conteúdo de `slack-app-manifest.yaml` (ou o JSON).
5. Revise e **Create**.
6. No app criado, vá em **Incoming Webhooks** → ative se necessário → **Add New Webhook to Workspace** → escolha o canal (ou conversa).
7. Copie a **Webhook URL** (`https://hooks.slack.com/services/...`).

## Segurança

- **Nunca** commite a Webhook URL no repositório.
- Guarde em variável de ambiente (neste projeto: `SLACK_MINI_WEBHOOK`) ou em `.env.local` fora do Git.
- Trate a URL como credencial: quem a tiver pode postar no canal configurado.

## Script local de envio

- Script oficial: `scripts/slack-notify.ps1`
- Variável usada pelo script: `SLACK_MINI_WEBHOOK`

Exemplo:

```powershell
.\scripts\slack-notify.ps1 -Text "Teste de notificacao do mini"
```

## Referências

- [App manifest](https://api.slack.com/reference/manifests)
- [Incoming webhooks](https://api.slack.com/messaging/webhooks)
