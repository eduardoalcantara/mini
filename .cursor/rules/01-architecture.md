# 01 — Arquitetura e Padrões de Código
**Projeto:** Editor Minimalista | **Versão:** 1.0 | **Data:** 2026-04-10

---

## Separação Obrigatória de Camadas

```
Frontend (HTML/CSS/JS)
    ↓  SOMENTE via bindings/index.js
app/app.go  ← DUMB: recebe chamada, delega ao service, retorna resultado
    ↓
services/   ← TODA a lógica de negócio vive aqui
    ↓
Sistema de arquivos / APIs externas
```

Nunca há exceções a esse fluxo. Se parecer necessário furar uma camada, **PARAR e consultar o Supervisor**.

---

## Regras de Backend — Go

### Proibições absolutas

| Proibido | Correto |
|---|---|
| `panic()` em services | Retornar `error` |
| Variáveis globais de estado | Usar struct `App` em `app/app.go` |
| `os.*` fora de `services/` | Encapsular no service responsável |
| `fmt.Println` em produção | `log/slog` |
| Ignorar `error` com `_ =` | Tratar ou propagar com `?` equivalente |
| Goroutines sem `context.Context` | Usar ctx com ciclo de vida controlado |
| Lógica de negócio em `app/app.go` | Mover para `services/` |

### Princípios

- **SoC**: separação clara de responsabilidades entre `app/`, `services/` e `models/`
- **SOLID** adaptado para Go: interfaces pequenas, injeção via structs, uma responsabilidade por pacote
- **DRY**: nunca duplicar código — criar funções/pacotes reutilizáveis
- **KISS**: preferir solução simples e legível sobre solução inteligente e opaca
- Tratamento de erros com `error` e retorno explícito — nunca `panic` em fluxo normal
- Nomes descritivos e auto-explicativos para funções, structs e interfaces

---

## Regras de Frontend

| Proibido | Correto |
|---|---|
| `window.go.[...]` diretamente | Usar `bindings/index.js` |
| Hardcode de cor/tamanho no CSS | Tokens CSS (`var(--color-bg)`) |
| `localStorage` / `sessionStorage` | Estado persistente via backend Go |
| `alert()` / `confirm()` nativos | Componente `ui/dialog` próprio |
| Lógica de negócio no componente JS | Delegar ao backend via binding |
| Monaco Editor | CodeMirror 6 |
| TypeScript | JavaScript vanilla (salvo aprovação explícita) |

### Design

- Todos os valores visuais (cores, espaçamentos, fontes) via variáveis CSS em `styles/tokens.css`
- Componentes em `frontend/src/components/` — um diretório por componente
- Nenhum componente acessa o backend diretamente — sempre via `bindings/index.js`

---

## Binários Locais em `tools/`

Os executáveis em `tools/` são referenciados pelos scripts com **caminho relativo ao repo**, nunca absoluto.

Padrão obrigatório em todo script PowerShell em `scripts/`:

```powershell
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Wails    = Join-Path $RepoRoot "tools\wails.exe"
$Lint     = Join-Path $RepoRoot "tools\golangci-lint.exe"
```

**NUNCA** use `D:\proj\[repo-root]\...` ou qualquer caminho absoluto nos scripts.
