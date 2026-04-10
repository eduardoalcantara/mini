# Relatório — Config Service, Fontes embed, Menu de contexto
**Data:** 2026-04-10  
**Specs de origem:** `2026-04-10-SPEC-config-service.md`, `2026-04-10-SPEC-fontes-embed.md`, `2026-04-10-SPEC-context-menu.md`  
**Status:** CONCLUÍDO

## Checklist (resumo)
- [x] `go build ./...` — sem erros
- [x] `golangci-lint run` — 0 issues
- [x] `wails build` — `build/bin/mini.exe` gerado
- [x] `config.json` ao lado do executável (via `os.Executable()`); em `wails dev` o exe é temporário — o ficheiro é criado junto a esse binário
- [x] Bindings `GetConfig`, `SetConfig`, `ResolveFont`
- [x] Fontes EB Garamond + JetBrains Mono (latin woff2 de `@fontsource/*`) + Material Symbols Rounded (`material-symbols` npm, ficheiro **~5,27 MB** — maior que a estimativa ~3 MB da spec; documentado aqui)
- [x] `fonts.css`, classe `.icon`, tokens `--font-editor-text` / `--font-editor-code` / temas light
- [x] Menu de contexto com submenus (hover 150ms), `config-changed`, `execCommand` para edição
- [ ] Itens Arquivo (Novo/Abrir/Salvar) — stubs (fecham o menu); “Novo tema…”, “Importar…”, “Outra…” — stubs

## Tamanho aproximado dos `.woff2` versionados
| Origem | Ficheiros | Total ~ |
|--------|-----------|---------|
| EB Garamond latin | 3 | 67 KB |
| JetBrains Mono latin | 3 | 65 KB |
| Material Symbols Rounded | 1 | **5,27 MB** |

## Arquivos principais criados
- `src/models/config.go`, `src/models/font_result.go`
- `src/services/config_service.go`
- `frontend/src/styles/fonts.css`, `frontend/src/styles/fonts/**`
- `frontend/src/components/ui/context-menu/context-menu.js`, `context-menu.css`

## Validações executadas
- `go build ./...` — PASSOU  
- `golangci-lint run` — PASSOU  
- `wails build` — PASSOU  

## Observações
- **CodeMirror:** `line_numbers` e `line_wrap` via `Compartment`; fonte/tamanho via variáveis CSS no `#editor-mount`.
- **`execCommand` no WebView2:** não houve falha em build; validação manual de cortar/copiar/colar recomendada.
- **Temas claros:** variáveis em `:root[data-theme=...]`; realce de sintaxe CM6 mantém `{ dark: true }` — pode afinar numa spec de UX.
