# Relatório — Integração CodeMirror 6

**Data:** 2026-04-10  
**Spec:** `2026-04-10-SPEC-codemirror6.md`  
**Status:** CONCLUÍDO

## Resumo

- Editor CodeMirror 6 integrado com `basicSetup`, Markdown, `EditorView.lineWrapping`, tema via `EditorView.theme` usando **apenas** variáveis CSS (`var(--...)`), sem cores literais em `editor.js` / `editor.css`.
- **Importmap** no `index.html` com caminhos `./node_modules/<pacote>/...` conforme `exports.import` de cada `package.json` (maioria `dist/index.js`; exceções: `crelt` → `index.js`, `style-mod` → `src/style-mod.js`, `w3c-keyname` → `index.js`, `@marijn/find-cluster-break` → `src/index.js`).
- **pnpm:** adicionado `frontend/.npmrc` com `node-linker=hoisted` para que dependências transitivas do meta-pacote `codemirror` fiquem em `node_modules/<nome>/`, permitindo resolver módulos no WebView2 com importmap (sem hoisting, `@codemirror/autocomplete` e outros não existiam na raiz de `node_modules`).
- **Build:** `copy-to-dist.cjs` copia `node_modules/` completo para `frontend/dist/node_modules/` (garante todos os imports transitivos).

## Observações obrigatórias (spec)

### Caminhos reais dos entry points (importmap)

| Módulo | Caminho relativo a `frontend/` |
|--------|----------------------------------|
| `codemirror` | `node_modules/codemirror/dist/index.js` |
| `@codemirror/*` (state, view, commands, language, lang-*, autocomplete, lint, search) | `node_modules/@codemirror/<pkg>/dist/index.js` |
| `@lezer/*` (common, highlight, lr, markdown, html, css, javascript) | `node_modules/@lezer/<pkg>/dist/index.js` |
| `@marijn/find-cluster-break` | `node_modules/@marijn/find-cluster-break/src/index.js` |
| `crelt` | `node_modules/crelt/index.js` |
| `style-mod` | `node_modules/style-mod/src/style-mod.js` |
| `w3c-keyname` | `node_modules/w3c-keyname/index.js` |

### Importmap

- Funcionou após **hoisted** + lista alargada (inclui `@codemirror/lang-html`, `lang-css`, `lang-javascript` e `@lezer/html`, `css`, `javascript` exigidos por `@codemirror/lang-markdown` → `lang-html`).

### Tamanho

- `frontend/dist/node_modules/` após `wails build`: ~**4,3 MiB** (aproximado neste ambiente).

## Validações executadas (automáticas)

- `go build ./...` — OK  
- `golangci-lint run` — 0 issues  
- `wails build` — `build/bin/mini.exe` gerado sem erros  

**Validação visual (`wails dev`):** a cargo do PO (janela, consola WebView2, digitação).

## Ficheiros entregues

- `frontend/.npmrc` — `node-linker=hoisted`  
- `frontend/src/components/editor/editor.js`  
- `frontend/src/components/editor/editor.css`  
- `frontend/index.html` — importmap + `#editor-mount`  
- `frontend/src/main.js` — `createEditor`, `window.__editorView`  
- `frontend/scripts/copy-to-dist.cjs` — cópia de `node_modules`  
- `frontend/src/styles/tokens.css` / `base.css` — tokens alinhados às regras + layout `#app`

---

## Revisão do Supervisor (2026-04-10)

**Veredicto:** aprovado — entrega alinhada à spec (cores via tokens, importmap opção B, validações Go/Wails, `.npmrc` hoisted documentado).

**Registos para o projeto:** `frontend/.npmrc` como ficheiro crítico; risco de entry points não standard no import map; tamanho `dist/node_modules` ~4,3 MiB (monitorizar crescimento). Ver `project/decisions/ADR-002-codemirror-importmap-pnpm.md` e `00-project.md` (secção configuração frontend crítica).
