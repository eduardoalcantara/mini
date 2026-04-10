# SPEC: Scaffold do Projeto Wails
**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Status:** CONCLUÍDO
**Arquivo:** `project/specs/done/2026-04-10-SPEC-scaffold-wails.md`

---

## Objetivo

Inicializar o projeto Wails v2 na raiz do repositório, configurar a estrutura de pastas
definida em `00-project.md`, validar que o ambiente compila e abre uma janela vazia com
fundo escuro. Nenhuma feature de produto entra nesta spec.

---

## Pré-requisitos

Antes de iniciar, confirmar que todos os itens abaixo estão verdes:

```powershell
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Wails    = Join-Path $RepoRoot "tools\wails.exe"

go version          # go1.22.x ou superior
& $Wails version    # Wails CLI v2.x.x
& $Wails doctor     # todos os itens com ✓
node --version      # v22.x.x
pnpm --version      # 10.x.x
```

Se qualquer item falhar: **PARAR e notificar o Supervisor antes de continuar.**

---

## Tarefas

### 1. Inicializar o projeto Wails

Executar na raiz do repositório:

```powershell
$RepoRoot = "."   # raiz do repo
$Wails    = Join-Path $RepoRoot "tools\wails.exe"

& $Wails init -n "Editor Minimalista" -t vanilla -d . -q
```

Flags:
| Flag | Valor | Motivo |
|---|---|---|
| `-n` | `"Editor Minimalista"` | Nome do projeto |
| `-t` | `vanilla` | Template sem framework — usaremos HTML/CSS/JS puro |
| `-d` | `.` | Inicializar na raiz do repo (não criar subpasta) |
| `-q` | — | Modo silencioso — erros ainda aparecem |

> ⚠️ O `wails init` vai gerar alguns arquivos na raiz. Não sobrescrever `.gitignore`,
> `README.md`, `STATUS.md`, `CHANGELOG.md` ou qualquer arquivo já existente.
> Se o Wails perguntar sobre conflito: manter o arquivo existente.

Arquivos esperados após o init:
```
wails.json          ← configuração do projeto Wails
go.mod              ← módulo Go
go.sum              ← lockfile Go
main.go             ← entry point (será reorganizado no passo 3)
app.go              ← struct App gerada pelo Wails (será movida no passo 3)
build/              ← ícones e recursos de empacotamento
frontend/           ← assets web (já existia, será populada)
```

---

### 2. Configurar `wails.json`

Após o init, editar `wails.json` para refletir a stack correta:

```json
{
  "name": "Editor Minimalista",
  "outputfilename": "editor-mini",
  "frontend:install": "pnpm install",
  "frontend:build": "pnpm run build",
  "frontend:dev:watcher": "pnpm run dev",
  "frontend:dev:serverUrl": "auto",
  "wailsjsdir": "./frontend/src/bindings",
  "assetdir": "frontend",
  "version": "2"
}
```

> ⚠️ `"frontend:install": "pnpm install"` — obrigatório para usar pnpm em vez de npm.
> O Wails executa esse comando no diretório `frontend/` automaticamente no `wails dev` e `wails build`.

---

### 3. Reorganizar estrutura de pastas Go

O `wails init` gera `app.go` e `main.go` na raiz. Reorganizar conforme a arquitetura definida:

**Mover/criar:**

```
src/
├── main.go             ← mover da raiz para src/ (ajustar go.mod se necessário)
├── app/
│   └── app.go          ← mover app.go da raiz para src/app/app.go
├── services/
│   └── .gitkeep        ← criar pasta (vazia por enquanto)
└── models/
    └── .gitkeep        ← criar pasta (vazia por enquanto)
```

> ⚠️ O Wails exige que o `main.go` esteja no package `main` e seja acessível
> pelo compilador Go. Se mover para `src/`, ajustar o `go.mod` e o caminho
> em `wails.json` se necessário. Se houver qualquer complicação com o Wails
> não encontrando o `main.go` fora da raiz: **PARAR e consultar o Supervisor**.
> Alternativa aceitável: manter `main.go` na raiz e apenas `app/`, `services/`
> e `models/` dentro de `src/`.

Conteúdo mínimo de `src/app/app.go`:

```go
package app

import "context"

// App é a struct principal. Toda lógica de negócio é delegada para services/.
// Não adicionar lógica aqui — apenas bindings para o frontend.
type App struct {
    ctx context.Context
}

// New cria uma nova instância do App.
func New() *App {
    return &App{}
}

// Startup é chamado pelo Wails quando a aplicação inicia.
func (a *App) Startup(ctx context.Context) {
    a.ctx = ctx
}
```

---

### 4. Configurar o frontend mínimo

Dentro de `frontend/`, criar a estrutura definida em `00-project.md`:

```
frontend/
├── index.html
└── src/
    ├── styles/
    │   ├── tokens.css      ← variáveis CSS (cores, espaçamentos, fontes)
    │   └── base.css        ← reset e estilos base
    ├── bindings/
    │   └── index.js        ← wrappers dos bindings Wails (vazio por enquanto)
    └── main.js             ← entry point JS (vazio por enquanto)
```

Conteúdo de `frontend/src/styles/tokens.css`:

```css
:root {
  /* Cores */
  --color-bg:       #1a1a1f;
  --color-surface:  #212127;
  --color-text:     #d4d4d0;
  --color-accent:   #5aafdf;
  --color-muted:    #555560;

  /* Tipografia */
  --font-mono: "JetBrains Mono", "Fira Code", "Cascadia Code", monospace;
  --font-size-base: 14px;
  --line-height-base: 1.6;

  /* Espaçamentos */
  --space-xs: 4px;
  --space-sm: 8px;
  --space-md: 16px;
  --space-lg: 32px;
}
```

Conteúdo de `frontend/src/styles/base.css`:

```css
*, *::before, *::after {
  box-sizing: border-box;
  margin: 0;
  padding: 0;
}

html, body {
  height: 100%;
  background-color: var(--color-bg);
  color: var(--color-text);
  font-family: var(--font-mono);
  font-size: var(--font-size-base);
  line-height: var(--line-height-base);
  -webkit-font-smoothing: antialiased;
}
```

Conteúdo de `frontend/index.html`:

```html
<!DOCTYPE html>
<html lang="pt-BR">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Editor Minimalista</title>
  <link rel="stylesheet" href="/src/styles/tokens.css" />
  <link rel="stylesheet" href="/src/styles/base.css" />
</head>
<body>
  <div id="app"></div>
  <script src="/src/bindings/index.js" type="module"></script>
  <script src="/src/main.js" type="module"></script>
</body>
</html>
```

---

### 5. Configurar `package.json` no frontend

Criar `frontend/package.json`:

```json
{
  "name": "editor-mini-frontend",
  "version": "0.1.0",
  "private": true,
  "packageManager": "pnpm@10.33.0",
  "scripts": {
    "dev": "echo \"frontend dev server not configured yet\"",
    "build": "echo \"frontend build not configured yet\" && exit 0"
  }
}
```

> Esta é a versão mínima — sem bundler ainda. O objetivo agora é apenas
> fazer o `wails build` passar. Vite ou outro bundler entra em spec futura.

---

### 6. Validação — Executar na ordem

```powershell
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Wails    = Join-Path $RepoRoot "tools\wails.exe"
$Lint     = Join-Path $RepoRoot "tools\golangci-lint.exe"

# 1. Verificar módulo Go
go build ./...
# Esperado: sem erros

# 2. Lint
& $Lint run
# Esperado: sem erros (warnings são aceitáveis nesta fase)

# 3. Build completo
& $Wails build
# Esperado: binário gerado em build/bin/ sem erros

# 4. Executar em modo dev (validação visual)
& $Wails dev
# Esperado: janela abre com fundo escuro (#1a1a1f), sem conteúdo, sem erros no console
```

---

### 7. Notificação e relatório

Ao concluir (ou ao encontrar erro em qualquer passo):

```powershell
$RepoRoot = Split-Path -Parent $PSScriptRoot
& "$RepoRoot\scripts\slack-notify.ps1" -Text "Scaffold Wails: [CONCLUÍDO/ERRO] — [resumo]"
```

Criar relatório em:
```
project/specs/done/RELATORIO-scaffold-wails-2026-04-10.md
```

Mover esta spec de `project/specs/doing/` para `project/specs/done/`.
Atualizar `STATUS.md`.

---

## Critérios de Aceitação

Para esta spec ser considerada **CONCLUÍDA**, todos os itens abaixo devem ser verdadeiros:

- [ ] `wails doctor` — todos os itens ✓
- [ ] `go build ./...` — passa sem erros
- [ ] `golangci-lint run` — passa sem erros (warnings documentados no relatório)
- [ ] `wails build` — gera binário em `build/bin/` sem erros
- [ ] `wails dev` — janela abre com fundo `#1a1a1f`, sem conteúdo, sem erros no console
- [ ] Estrutura de pastas (`src/app/`, `src/services/`, `src/models/`, `frontend/src/`) criada
- [ ] `wails.json` configurado com `pnpm install` e `pnpm run build`
- [ ] `frontend/package.json` com `"packageManager": "pnpm@10.33.0"`
- [ ] `tokens.css` com as variáveis CSS de cor, tipografia e espaçamento
- [ ] Relatório criado em `project/specs/done/`
- [ ] `STATUS.md` atualizado
- [ ] Slack notificado

---

## Bloqueios Conhecidos

| Situação | Ação |
|---|---|
| `wails init` conflita com arquivos existentes | Manter arquivos existentes, reportar ao Supervisor |
| `main.go` fora da raiz causa erro no Wails | Manter `main.go` na raiz, ajustar apenas `app/`, `services/`, `models/` dentro de `src/` |
| `wails doctor` falha em algum item | PARAR — não avançar sem ambiente validado |
| `pnpm install` falha no build | Verificar versão do pnpm e a chave `"frontend:install"` no `wails.json` |

---

*Spec gerada pelo Arquiteto/Supervisor IA. Aprovação do PO necessária antes de mover para `doing/`.*
