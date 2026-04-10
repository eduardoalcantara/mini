# STATUS

## Situação atual

- Fase: scaffold técnico da stack Go + Wails concluído
- Estado: base executável inicial validada (build, lint e dev)
- Escopo atual: preparar próxima spec funcional (editor e fluxos de UI)

## Decisão vigente

- Stack oficial: Go + WebView (Wails v2)
- Decisão estratégica: descontinuar a base ativa em Rust/Zed para este novo ciclo
- Arquivos legados: preservados em `legacy/` para consulta histórica
- Estrutura Wails + frontend: `project/decisions/ADR-001-estrutura-wails-frontend.md`

## Build, pastas e o que não confundir

- **`frontend/dist/`** — saída do `pnpm run build` (HTML/CSS/JS) embutida via `//go:embed all:frontend/dist` em `main.go`.
- **`build/` na raiz** — recursos de empacotamento Wails (ícone, manifest Windows), não é o mesmo que `frontend/dist/`.
- **`build/bin/`** — saída do `wails build` (`mini.exe`). Entrada no `.gitignore`; regenere com `.\scripts\build.ps1`.
- **`go build` sozinho** não substitui `wails build` para o app desktop (tags e pipeline do CLI). Ver [Manual builds](https://wails.io/docs/guides/manual-builds/).

## Scripts locais

- `.\scripts\install-tools.ps1` — instala `tools\wails.exe` e `tools\golangci-lint.exe` via `go install` (após clone; binários não vão ao Git). Ver `tools/README.md`.
- `.\scripts\build.ps1` — `wails build` a partir da raiz; confere `frontend/dist/index.html` após o build.
- `.\scripts\run.ps1` — executa `build\bin\mini.exe` (exige build prévio).

## Pendências imediatas

- Definir próxima spec em `project/specs/doing/` para iniciar features de produto
- Evoluir frontend de scaffold mínimo para estrutura funcional de editor
