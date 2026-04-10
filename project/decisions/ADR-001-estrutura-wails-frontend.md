# ADR-001 — Estrutura Wails e posicionamento do frontend

**Data:** 2026-04-10  
**Status:** ACEITO  
**Versão:** 1.3

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
- Nome de exibição: **Mini** (`wails.json` → `name`, `index.html` → `<title>`). O `Title` em `main.go` pode ficar vazio por spec de UI (barra nativa “invisível”); o binário continua `mini.exe` via `"outputfilename": "mini"`.
- Binário Windows: `mini.exe` via `"outputfilename": "mini"`.

---

## Decisão 4 — CodeMirror: sem meta-pacote `codemirror`

- O `package.json` do frontend **não** deve listar o pacote npm **`codemirror`** (meta-pacote que agrega reexportações e `basicSetup`).
- O código importa **apenas** pacotes **`@codemirror/*`** explícitos; o **import map** em `frontend/index.html` **não** inclui entrada `"codemirror"` — reintroduzi-la sem alinhar dependências gera erro em runtime no WebView2 ou resolução ambígua.
- Specs e alterações futuras: não voltar ao meta-pacote sem rever esta decisão e o **`ADR-002`** (hoisting pnpm + caminhos do import map).

---

## Build correto (fonte: Wails — [Manual builds](https://wails.io/docs/guides/manual-builds/))

O CLI do Wails documenta o que `wails build` e `wails dev` fazem em sequência: instalar dependências do frontend (`frontend:install` em `wails.json`), rodar o build do frontend (`frontend:build`), gerar assets de empacotamento (ícone, manifest no Windows, `.syso` via winres), e **compilar** a aplicação Go com flags próprias.

### O que o `wails build` usa (produção)

- Tags Go padrão: `-tags desktop,production` com `-ldflags "-w -s"`.
- No **Windows**, o documento indica também `-ldflags` incluindo `-H windowsgui` (janela sem console).
- Build **manual** equivalente ao de produção (mínimo citado na doc):  
  `go build -tags desktop,production -ldflags "-w -s -H windowsgui"`

### Desenvolvimento

- Mínimo para build de **dev**:  
  `go build -tags dev -gcflags "all=-N -l"`  
  (na prática o time usa `wails dev`.)

### Windows e `.syso`

- A doc exige compilar **no mesmo diretório** em que está o ficheiro **`.syso`** gerado no passo de empacotamento; o CLI do Wails cuida disso. Um `go build` isolado na raiz **sem** esse passo quebra o empacotamento ou as tags esperadas.

### Por que não usar só `go build` na raiz

Sem o pipeline do CLI (ou sem replicar tags, ldflags e assets), o binário pode até gerar, mas o **runtime Wails** pode falhar (ex.: diálogo a recomendar Manual builds). O projeto padroniza **`wails build`** via `scripts/build.ps1` a partir da raiz do repositório.

---

## Pendência

- Preencher `frontend:dev:watcher` e `frontend:dev:serverUrl` quando entrar Vite (spec futura).
