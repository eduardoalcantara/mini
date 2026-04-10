# STATUS

## Situação atual

- Fase: janela Windows com barra de título “invisível” (`CustomTheme` + titlebar HTML sem altura extra), editor CodeMirror sem fold gutter, margem de página `--editor-page-inset`, scrollbar temática
- Estado: `wails build`, `go build` e `golangci-lint` validados; validação visual em `wails dev` recomendada ao PO
- Escopo atual: próximas specs funcionais (ficheiros, abas, persistência, etc.)

## Decisão vigente

- Stack oficial: Go + WebView (Wails v2)
- Decisão estratégica: descontinuar a base ativa em Rust/Zed para este novo ciclo
- Arquivos legados: preservados em `legacy/` para consulta histórica
- Estrutura Wails + frontend: `project/decisions/ADR-001-estrutura-wails-frontend.md`
- CodeMirror + importmap + pnpm hoisted: `project/decisions/ADR-002-codemirror-importmap-pnpm.md`
- CSS janela + editor (tokens, base, titlebar, inset CM6): `project/decisions/ADR-003-css-ui-chrome-editor.md`
- Frontend JS: ES modules sem bundler; CodeMirror 6 via `pnpm` + importmap; `frontend/.npmrc` com `node-linker=hoisted` (crítico — ver `00-project.md`)

## Build, pastas e o que não confundir

- **`frontend/dist/`** — saída do `pnpm run build` (HTML/CSS/JS) embutida via `//go:embed all:frontend/dist` em `main.go`.
- **`frontend/dist/node_modules/`** — cópia completa de `frontend/node_modules/` para o embed (CodeMirror e dependências).
- **`build/` na raiz** — recursos de empacotamento Wails (ícone, manifest Windows), não é o mesmo que `frontend/dist/`.
- **`build/bin/`** — saída do `wails build` (`mini.exe`). Entrada no `.gitignore`; regenere com `.\scripts\build.ps1`.
- **`go build` sozinho** não substitui `wails build` para o app desktop (tags e pipeline do CLI). Ver [Manual builds](https://wails.io/docs/guides/manual-builds/).

## Scripts locais

- `.\scripts\install-tools.ps1` — instala `tools\wails.exe` e `tools\golangci-lint.exe` via `go install` (após clone; binários não vão ao Git). Ver `tools/README.md`.
- `.\scripts\build.ps1` — `wails build` a partir da raiz; confere `frontend/dist/index.html` após o build.
- `.\scripts\run.ps1` — executa `build\bin\mini.exe` (exige build prévio).

## Pendências imediatas

- Definir próxima spec em `project/specs/doing/` (ex.: gestão de ficheiros, abas, config)
- Temas adicionais em `frontend/src/styles/themes/` quando a spec de UX avançar
