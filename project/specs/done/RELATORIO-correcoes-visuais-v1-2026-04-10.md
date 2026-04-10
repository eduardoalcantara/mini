# Relatório — Correções visuais e UX v1
**Data:** 2026-04-10  
**Spec:** `2026-04-10-SPEC-correcoes-visuais-v1.md`  
**Status:** CONCLUÍDO

## Implementado
1. Menu: ícone Material `check` em `.context-menu-item__check` (sem `::before` ●).
2. Tema claro: `SetWindowBackground` (binding) + `syncNativeWindowBackground` em `theme/native-chrome.js` no boot e em `config-changed`.
3. `Title: "Mini"` em `main.go`; `SetWindowTitle` + `setAppWindowTitle("Mini")` no arranque.
4. `.context-submenu` com `max-height: 320px`, scroll e scrollbar fina.
5–6. Tokens `--color-selection`, `--color-selection-inactive`, `--color-text-on-selection` por tema; `::selection` em `base.css`; tema CM6 em `editor.js`.
7. `.cm-scroller` com `padding-right: calc(var(--space-4) + var(--space-2))`.

## Validações
- `go build ./...`, `golangci-lint run`, `wails build` — OK.

## Bloqueio (supervisor)
- Se `WindowSetBackgroundColour` **não** atualizar a barra nativa no Windows, reportar ao Supervisor antes de alternativas — não testado automaticamente neste ambiente.
