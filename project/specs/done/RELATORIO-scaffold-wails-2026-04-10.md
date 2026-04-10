# Relatório de Implementação — Scaffold Wails
**Data:** 2026-04-10
**Spec de origem:** `2026-04-10-SPEC-scaffold-wails.md`
**Status:** CONCLUÍDO COM RESSALVAS

## Checklist de implementação
- [x] Prechecks de ambiente executados (Go, Wails, Doctor, Node, pnpm)
- [x] Scaffold Wails inicial gerado sem sobrescrever arquivos protegidos
- [x] Estrutura backend criada em `src/app`, `src/services`, `src/models`
- [x] Estrutura frontend mínima criada em `frontend/` com tokens/base/index/main/bindings
- [x] `wails.json` configurado para pnpm e `assetdir` em `frontend`
- [x] Build/lint/dev validados na ordem
- [x] `STATUS.md` atualizado
- [x] Spec movida para `project/specs/done/`

## Arquivos criados
- `go.mod` — módulo Go do projeto com dependência Wails v2
- `go.sum` — lockfile de dependências Go
- `main.go` — entry point Wails (`package main`) com bind de `src/app`
- `wails.json` — configuração Wails com frontend em `frontend/`
- `src/app/app.go` — struct `App` (camada DUMB de bindings)
- `src/services/.gitkeep` — placeholder da camada de serviços
- `src/models/.gitkeep` — placeholder da camada de modelos
- `frontend/index.html` — shell HTML mínima
- `frontend/package.json` — package manager pnpm 10.33.0 + scripts mínimos
- `frontend/src/styles/tokens.css` — tokens visuais mínimos
- `frontend/src/styles/base.css` — reset/base com fundo escuro
- `frontend/src/bindings/index.js` — wrapper de bindings (fase inicial)
- `frontend/src/main.js` — entrypoint JS mínimo
- `frontend/dist/gitkeep` — diretório dist para embed inicial

## Arquivos modificados
- `wails.json` — ajuste de `frontend:dev:watcher` e `frontend:dev:serverUrl` para permitir `wails dev` sem bundler nessa fase

## Arquivos removidos
- `src/frontend/` — removida duplicidade gerada por scaffold indevido
- `src/.gitignore`, `src/app.go`, `src/go.mod`, `src/go.sum`, `src/main.go`, `src/README.md`, `src/wails.json`, `src/build/` — remoção do scaffold duplicado que ficou dentro de `src`

## Validações executadas
- [x] `tools/wails.exe doctor` → PASSOU
- [x] `go build ./...` → PASSOU
- [x] `tools/golangci-lint.exe run` → PASSOU (`0 issues`)
- [x] `tools/wails.exe build` → PASSOU (binário em `build/bin/mini.exe` após ajuste de `outputfilename`)
- [x] `tools/wails.exe dev` → PASSOU (ambiente WebView2 criado e app em execução de desenvolvimento)

## Observações para o supervisor
- O comando literal da spec (`wails init -d .`) falhou por diretório não vazio (comportamento do Wails CLI atual).
- Também houve falha de módulo com nome contendo espaço durante geração automática.
- Decisão aplicada com aprovação do PO: manter prática correta com backend em `src/` e frontend oficial em `frontend/` (raiz), removendo duplicidades.
- Para viabilizar `wails dev` sem introduzir bundler nesta fase, foi necessário ajustar o `wails.json` (watcher/serverUrl vazios), mantendo foco no scaffold mínimo.

---

## Atualização para o Supervisor — reaplicação pós-`git clone` (2026-04-10)

**Contexto:** parte do trabalho local (scripts, cópia para `frontend/dist`, ADR, ajustes de branding) não estava no último commit remoto; o estado foi **reaplicado** a partir do histórico da implementação.

**Itens restaurados:**

| Área | Ação |
|------|------|
| `wails.json` | Nome de exibição **Mini** (`"name"`), saída **`mini.exe`** (`"outputfilename": "mini"`). |
| `main.go` / `frontend/index.html` | Título da janela e `<title>` alinhados a **Mini**. |
| `frontend/package.json` | `pnpm run build` passa a executar `node scripts/copy-to-dist.cjs` (copia `index.html` + `src/` para `frontend/dist/`). |
| `.gitignore` | `/build/bin/` (binário local); `frontend/node_modules/`. |
| `scripts/build.ps1` | Caminhos relativos ao repo (`$PSScriptRoot`), `wails build`, verificação de `frontend/dist/index.html`, Slack só em falha. |
| `scripts/run.ps1` | Executa `build\bin\mini.exe` após build prévio (sem parâmetros). |
| `STATUS.md` | Seção sobre `frontend/dist` vs `build/bin`, scripts e link para manual builds. |
| `project/decisions/ADR-001-estrutura-wails-frontend.md` | ADR recriado com decisões de layout e build tags. |

**Notas técnicas para auditoria:**

- O erro de diálogo do Wails sobre **build tags** ocorre ao usar `go build`/`go run` sem o pipeline do CLI; não é causado por separar `src/` e `frontend/`. Referência: [Manual builds](https://wails.io/docs/guides/manual-builds/).
- Binário de referência: `build/bin/mini.exe` (não mais `editor-mini.exe` onde aplicável).
