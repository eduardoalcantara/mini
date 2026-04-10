# ADR-001 — Estrutura Wails e posicionamento do frontend

**Data:** 2026-04-10  
**Status:** ACEITO  
**Versão:** 1.1 (reaplicado após recuperação do repositório)

---

## Decisão 1 — Entrada Wails na raiz; backend em `src/`

`main.go`, `go.mod`, `wails.json` ficam na raiz do repositório. Código da aplicação em `src/app`, `src/services`, `src/models`.

---

## Decisão 2 — `frontend/` na raiz (irmao de `src/`)

`wails.json`:

```json
{
  "assetdir": "frontend",
  "wailsjsdir": "./frontend/src/bindings"
}
```

O embed em `main.go` usa `//go:embed all:frontend/dist` — o diretório correto para assets de producao é **`frontend/dist/`**, nao `dist/` na raiz nem `src/dist/`.

---

## Decisão 3 — Módulo Go e nome do binário

- Módulo: `mini` (sem espaços em `go.mod`).
- Nome de exibição: **Mini** (`wails.json` → `name`, `main.go` → `Title`, `index.html` → `<title>`).
- Binário Windows: `mini.exe` via `"outputfilename": "mini"`.

---

## Build tags (Wails)

Compilar só com `go build` / `go run` na raiz **sem** o CLI gera erro em tempo de execução. Usar `wails build` ou `wails dev`, ou seguir [Manual builds](https://wails.io/docs/guides/manual-builds/) (tags `desktop,production` em producao).

---

## Pendência

- Preencher `frontend:dev:watcher` e `frontend:dev:serverUrl` quando entrar Vite (spec futura).
