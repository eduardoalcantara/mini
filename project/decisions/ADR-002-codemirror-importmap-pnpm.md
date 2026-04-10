# ADR-002 — CodeMirror 6 no frontend sem bundler (importmap + pnpm)

**Data:** 2026-04-10  
**Status:** ACEITO  
**Versão:** 1.1

---

## Contexto

A stack exige CodeMirror 6 com HTML/CSS/JS vanilla, **sem** Vite/Webpack na fase atual. O CM6 distribui ES modules; no WebView2 resolve-se com **import map** apontando para ficheiros em `node_modules/`.

---

## Decisão 1 — `frontend/.npmrc` com `node-linker=hoisted`

Com o layout **isolado** predefinido do pnpm, muitas dependências transitivas (ex.: `@codemirror/autocomplete`) **não** aparecem em `frontend/node_modules/<pacote>/` na raiz, pelo que o **import map** não consegue resolver os bare specifiers no browser. O projeto **não** usa o meta-pacote `codemirror` no `package.json` — apenas `@codemirror/*` explícitos; ver **ADR-001, Decisão 4**.

**Decisão:** usar `node-linker=hoisted` em `frontend/.npmrc` para um `node_modules` plano compatível com os caminhos do import map.

**Consequência:** este ficheiro é **crítico** — removê-lo ou mudar o linker sem substituto documentado **quebra** o carregamento do editor. Ver `00-project.md` (configuração frontend crítica).

---

## Decisão 2 — Import map e caminhos não standard

A maioria dos pacotes usa `dist/index.js` em `exports.import`. Três pacotes usam **outros** caminhos:

| Pacote | Entry usado no import map |
|--------|---------------------------|
| `crelt` | `index.js` (raiz) |
| `w3c-keyname` | `index.js` (raiz) |
| `@marijn/find-cluster-break` | `src/index.js` |
| `style-mod` | `src/style-mod.js` |

**Risco:** ao atualizar versões destes pacotes, o `package.json` pode alterar `exports` — o import map deixa de apontar para o ficheiro certo **sem erro de build Go** (falha só em runtime no WebView2). Após upgrades de dependências no `frontend/`, validar **`wails dev`** e consola.

---

## Decisão 3 — Cópia de `node_modules` para `dist/`

O script `frontend/scripts/copy-to-dist.cjs` copia **`node_modules/` completo** para `frontend/dist/node_modules/` para o embed Wails incluir todos os módulos.

**Tamanho observado:** ~4,3 MiB (fase inicial). **Monitorizar** se ultrapassar ~15 MiB (ajustar escopo ou estratégia numa spec futura).

---

## Relação com ADR-001

O ADR-001 define `assetdir: "frontend"` e embed `frontend/dist/`. Este ADR-002 detalha **como** o frontend CM6 é servido **dentro** dessa pasta, sem alterar a decisão de estrutura Wails.
