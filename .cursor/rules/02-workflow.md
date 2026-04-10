# 02 — Fluxo de Trabalho e Protocolo
**Projeto:** Editor Minimalista | **Versão:** 1.0 | **Data:** 2026-04-10

---

## Ordem de Leitura Obrigatória — Antes de Qualquer Tarefa

1. `IMPLEMENTATION-RULES-v1.0.md` (regras gerais)
2. `STATUS.md` (o que já foi feito, o que está pendente, bloqueadores)
3. A spec em `project/specs/doing/` (a tarefa atual)
4. Specs relacionadas em `project/specs/done/` se a tarefa tocar em área já implementada

**Não há tarefa pequena o suficiente para pular essa ordem.**

---

## Ciclo de Vida de uma Spec

```
project/specs/to-do/     ← spec aguardando
        ↓  (PO move para doing ao iniciar)
project/specs/doing/     ← spec em execução (máximo 1 por vez)
        ↓  (Cursor move para done ao concluir)
project/specs/done/      ← spec concluída + relatório (imutável)
```

---

## Antes de Gerar Qualquer Código

1. Listar **todas** as mudanças planejadas
2. Aguardar **confirmação explícita** do PO ou Supervisor
3. Verificar a regra correspondente em `IMPLEMENTATION-RULES-v1.0.md`
4. Se em **modo ASK** no Cursor: não gerar código — pedir para o PO trocar para modo **Agent**

---

## Comandos Principais

```powershell
# Caminhos (sempre relativos — ver 01-architecture.md)
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Wails    = Join-Path $RepoRoot "tools\wails.exe"
$Lint     = Join-Path $RepoRoot "tools\golangci-lint.exe"

# Desenvolvimento (hot reload)
& $Wails dev

# Build de produção
& $Wails build

# Build apenas backend Go
go build ./...

# Testes Go
go test ./...

# Lint Go (completo)
& $Lint run

# Lint rápido (sem instalação separada)
go vet ./...
```

**NUNCA execute comandos destrutivos** (`rm -rf`, `Remove-Item -Recurse -Force`, etc.) sem confirmação explícita do PO.
**NUNCA execute builds em modo silencioso** sem verificar a saída de erros.

---

## Ao Finalizar Qualquer Tarefa

Execute na ordem — só avance se o passo anterior passar:

1. `go build ./...` — sem erros
2. `& $Lint run` — corrigir todos os erros antes de reportar
3. `& $Wails build` — build completo sem erros
4. Criar relatório em `project/specs/done/RELATORIO-[TAREFA]-[YYYY-MM-DD].md`
5. Atualizar `STATUS.md`
6. Mover spec de `project/specs/doing/` para `project/specs/done/`

---

## Template de Relatório

```markdown
# Relatório — [Nome da Tarefa]
**Data:** YYYY-MM-DD
**Spec de origem:** [nome do arquivo]
**Status:** CONCLUÍDO | CONCLUÍDO COM RESSALVAS | PARCIALMENTE CONCLUÍDO

## Checklist da spec
- [x] Item 1
- [x] Item 2
- [ ] Item 3 — não implementado: [motivo]

## Arquivos criados
- `caminho/arquivo.go` — descrição

## Arquivos modificados
- `caminho/arquivo.go` — o que mudou e por quê

## Validações executadas
- `go build ./...` — PASSOU / FALHOU
- `golangci-lint run` — PASSOU / FALHOU
- `wails build` — PASSOU / FALHOU

## Erros de lint corrigidos
- [descrever cada um]

## Observações para o Supervisor
[Desvios da spec, decisões técnicas tomadas, dúvidas, riscos identificados]
```

---

## Protocolo de Comunicação

- **SEMPRE** termine cada resposta com: `**Resposta Nº** x` (incremental na sessão)
- **SEMPRE** termine cada resposta com: `**Modelo:** [modelo atual]`
- Ao finalizar qualquer tarefa, execute obrigatoriamente:
  ```powershell
  $RepoRoot = Split-Path -Parent $PSScriptRoot
  & "$RepoRoot\scripts\slack-notify.ps1" -Text "Tarefa nº XX concluída: RR"
  ```
  Onde XX = número do prompt, RR = resumo em até 4000 caracteres
- Em caso de erro no lint ou build, execute imediatamente:
  ```powershell
  & "$RepoRoot\scripts\slack-notify.ps1" -Text "⚠️ ERRO — Tarefa nº XX: [descrição do erro]"
  ```
- A variável de ambiente `SLACK_MINI_WEBHOOK` deve estar configurada na máquina — **NUNCA** hardcode da URL no código ou scripts
- Se `slack-notify.ps1` não estiver disponível ou `SLACK_MINI_WEBHOOK` não estiver definida: reportar no chat e continuar a tarefa — a notificação não é bloqueante

---

## Gerenciamento de Contexto

- **Seja conciso** — evite repetição desnecessária
- **Não repita código já mostrado** — use "mantido como está"
- **Não explique conceitos óbvios** ao PO ou Supervisor
- Ao listar mudanças: use **bullets curtos**, não parágrafos
- Se a resposta passar de **500 linhas**: perguntar se deve dividir
