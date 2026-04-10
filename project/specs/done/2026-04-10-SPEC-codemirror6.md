# SPEC — Integração CodeMirror 6
**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Status:** CONCLUÍDO
**Arquivo:** `project/specs/done/2026-04-10-SPEC-codemirror6.md`

---

## Objetivo

Integrar o CodeMirror 6 ao frontend existente, resultando em um editor de texto
funcional dentro da janela Wails — sem bundler, sem TypeScript, sem dependências
além das necessárias do próprio CodeMirror.

---

## Contexto e estado atual

- `frontend/index.html` existe com `<div id="app">` e carrega `tokens.css`, `base.css`, `bindings/index.js` e `main.js`
- `frontend/src/styles/tokens.css` tem tokens de cor e tipografia definidos
- `frontend/package.json` usa pnpm 10.33.0 com script `build` = `node scripts/copy-to-dist.cjs`
- `frontend/scripts/copy-to-dist.cjs` copia `index.html` e `src/` para `frontend/dist/`
- Não há bundler (Vite/Webpack) — o frontend opera com ES modules via `<script type="module">`
- O `wails.json` tem `"frontend:dev:watcher": ""` e `"frontend:dev:serverUrl": ""` — sem hot reload nesta fase

---

## Decisão técnica — sem bundler

O CodeMirror 6 é distribuído como ES modules. Sem bundler, há duas opções:

| Opção | Vantagem | Desvantagem |
|---|---|---|
| **A — importmap via CDN (esm.sh)** | Zero configuração, sem build step | Requer internet no `wails dev`; não funciona offline no `wails build` |
| **B — pacotes instalados via pnpm + importmap local** | Funciona offline, sem bundler | Requer copiar `node_modules/` para `dist/` ou usar importmap apontando para `node_modules` |
| **C — bundle manual com `esbuild`** | Bundle único, sem importmap | Adiciona ferramenta ao projeto |

**Decisão: Opção B** — instalar via pnpm, servir via importmap apontando para
`frontend/node_modules/` durante `wails dev`, e copiar os módulos necessários
para `frontend/dist/` no build de produção.

> Se o Cursor encontrar problemas irresolvíveis com importmaps no WebView2,
> **PARAR e consultar o Supervisor antes de usar CDN ou bundler.**

---

## Pacotes a instalar

```bash
cd frontend
pnpm add codemirror @codemirror/state @codemirror/view @codemirror/commands @codemirror/language @codemirror/lang-markdown @lezer/highlight
```

Versões mínimas esperadas (março 2026):
- `codemirror`: 6.x
- `@codemirror/state`: 6.x
- `@codemirror/view`: 6.x
- `@codemirror/commands`: 6.x
- `@codemirror/language`: 6.x
- `@codemirror/lang-markdown`: 6.x
- `@lezer/highlight`: 1.x

---

## Tarefas

### 1. Instalar dependências

```bash
cd frontend
pnpm add codemirror @codemirror/state @codemirror/view @codemirror/commands @codemirror/language @codemirror/lang-markdown @lezer/highlight
```

Verificar que `frontend/pnpm-lock.yaml` foi atualizado.

---

### 2. Criar `frontend/src/components/editor/editor.js`

Componente responsável por instanciar e gerenciar o `EditorView`.

Requisitos obrigatórios:
- Instanciar `EditorView` **somente** dentro deste componente — nunca em `main.js` ou em qualquer outro lugar
- Usar `basicSetup` do meta-pacote `codemirror`
- Ativar `EditorView.lineWrapping` por padrão
- Aplicar tema via `EditorView.theme({})` usando os tokens CSS via `getComputedStyle` — **nunca hardcodar cores**
- Expor função `createEditor(parentEl, initialContent)` que retorna a instância do `EditorView`
- Expor função `getContent(view)` que retorna o texto atual do editor
- Expor função `setContent(view, text)` que substitui o conteúdo sem perder o histórico de undo quando possível

Estrutura do arquivo:

```javascript
// frontend/src/components/editor/editor.js
import { EditorView, basicSetup } from 'codemirror';
import { EditorState } from '@codemirror/state';
import { markdown } from '@codemirror/lang-markdown';

function resolveToken(name) {
  return getComputedStyle(document.documentElement)
    .getPropertyValue(name).trim();
}

const editorTheme = EditorView.theme({
  '&': {
    height: '100%',
    backgroundColor: 'var(--color-bg)',
    color: 'var(--color-text)',
    fontFamily: 'var(--font-editor-text)',
    fontSize: 'var(--text-editor)',
    lineHeight: 'var(--line-height-editor)',
  },
  '.cm-content': { caretColor: 'var(--color-accent)' },
  '.cm-cursor': { borderLeftColor: 'var(--color-accent)' },
  '.cm-focused .cm-selectionBackground, ::selection': {
    backgroundColor: 'var(--color-surface-2)',
  },
  '.cm-gutters': {
    backgroundColor: 'var(--color-bg)',
    color: 'var(--color-text-muted)',
    border: 'none',
  },
  '.cm-activeLineGutter': { backgroundColor: 'var(--color-surface)' },
  '.cm-activeLine': { backgroundColor: 'var(--color-surface)' },
}, { dark: true });

export function createEditor(parentEl, initialContent = '') {
  const state = EditorState.create({
    doc: initialContent,
    extensions: [
      basicSetup,
      markdown(),
      EditorView.lineWrapping,
      editorTheme,
    ],
  });
  return new EditorView({ state, parent: parentEl });
}

export function getContent(view) {
  return view.state.doc.toString();
}

export function setContent(view, text) {
  view.dispatch({
    changes: { from: 0, to: view.state.doc.length, insert: text },
  });
}
```

---

### 3. Criar `frontend/src/components/editor/editor.css`

Estilos de layout do container do editor — **apenas layout**, nenhuma cor hardcodada.

```css
/* frontend/src/components/editor/editor.css */
.editor-container {
  display: flex;
  flex-direction: column;
  height: 100%;
  width: 100%;
  overflow: hidden;
}

.editor-container .cm-editor {
  height: 100%;
  outline: none;
}

.editor-container .cm-scroller {
  overflow: auto;
  padding: var(--space-4) var(--space-4);
}
```

---

### 4. Atualizar `frontend/index.html`

Adicionar:
- `<link>` para `editor.css`
- `<importmap>` apontando os módulos do CodeMirror para `./node_modules/`
- Container `<div class="editor-container" id="editor-mount"></div>` dentro de `#app`

```html
<!DOCTYPE html>
<html lang="pt-BR" data-theme="dark">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />
  <title>Mini</title>
  <link rel="stylesheet" href="src/styles/tokens.css" />
  <link rel="stylesheet" href="src/styles/base.css" />
  <link rel="stylesheet" href="src/components/editor/editor.css" />
  <script type="importmap">
  {
    "imports": {
      "codemirror": "./node_modules/codemirror/dist/index.js",
      "@codemirror/state": "./node_modules/@codemirror/state/dist/index.js",
      "@codemirror/view": "./node_modules/@codemirror/view/dist/index.js",
      "@codemirror/commands": "./node_modules/@codemirror/commands/dist/index.js",
      "@codemirror/language": "./node_modules/@codemirror/language/dist/index.js",
      "@codemirror/lang-markdown": "./node_modules/@codemirror/lang-markdown/dist/index.js",
      "@lezer/common": "./node_modules/@lezer/common/dist/index.js",
      "@lezer/highlight": "./node_modules/@lezer/highlight/dist/index.js",
      "@lezer/lr": "./node_modules/@lezer/lr/dist/index.js",
      "@lezer/markdown": "./node_modules/@lezer/markdown/dist/index.js"
    }
  }
  </script>
</head>
<body>
  <div id="app">
    <div class="editor-container" id="editor-mount"></div>
  </div>
  <script src="src/bindings/index.js" type="module"></script>
  <script src="src/main.js" type="module"></script>
</body>
</html>
```

> ⚠️ Os caminhos do importmap assumem que os pacotes pnpm geram `dist/index.js`.
> Verificar os caminhos reais em `node_modules/` após o `pnpm install` e ajustar se necessário.
> Se o WebView2 não suportar importmap com caminhos relativos para `node_modules/`:
> **PARAR e consultar o Supervisor.**

---

### 5. Atualizar `frontend/src/main.js`

Importar e inicializar o editor no mount point:

```javascript
// frontend/src/main.js
import { createEditor } from './components/editor/editor.js';

const mountEl = document.getElementById('editor-mount');

if (!mountEl) {
  console.error('[mini] #editor-mount não encontrado');
} else {
  const view = createEditor(mountEl, '');
  // Expor globalmente apenas para debugging — remover antes de produção
  window.__editorView = view;
}
```

---

### 6. Atualizar `frontend/scripts/copy-to-dist.cjs`

O script de build precisa copiar também os módulos do CodeMirror para `dist/`:

```javascript
// Adicionar ao copy-to-dist.cjs após as cópias existentes:
const nodeModulesDeps = [
  'codemirror',
  '@codemirror/state',
  '@codemirror/view',
  '@codemirror/commands',
  '@codemirror/language',
  '@codemirror/lang-markdown',
  '@lezer/common',
  '@lezer/highlight',
  '@lezer/lr',
  '@lezer/markdown',
];

const nmSrc  = path.join(root, 'node_modules');
const nmDist = path.join(dist, 'node_modules');

for (const dep of nodeModulesDeps) {
  const src  = path.join(nmSrc, dep);
  const dest = path.join(nmDist, dep);
  fs.mkdirSync(path.dirname(dest), { recursive: true });
  fs.cpSync(src, dest, { recursive: true });
}
```

---

## Validações obrigatórias — executar nesta ordem

```powershell
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Wails    = Join-Path $RepoRoot "tools\wails.exe"
$Lint     = Join-Path $RepoRoot "tools\golangci-lint.exe"

# 1. Build Go — não deve ter sido alterado, mas confirmar
go build ./...

# 2. Lint Go
& $Lint run

# 3. Build Wails completo (executa pnpm install + pnpm run build + empacota)
& $Wails build

# 4. Modo dev — validação visual
& $Wails dev
```

---

## Critérios de aceitação

- [x] `pnpm install` executa sem erros dentro de `frontend/`
- [x] `go build ./...` passa sem erros
- [x] `golangci-lint run` passa com 0 issues
- [x] `wails build` gera `build/bin/mini.exe` sem erros
- [x] `wails dev` abre a janela com o editor CodeMirror visível e funcional *(validação manual pelo PO recomendada)*
- [x] O editor ocupa 100% da janela (sem margens externas visíveis além do padding interno)
- [x] O fundo do editor usa `var(--color-bg)` — `#1a1a1f` — sem cor hardcodada
- [x] O cursor do editor pisca na cor `var(--color-accent)` — `#5aafdf`
- [x] É possível digitar texto e ver o conteúdo renderizado
- [x] Line wrapping está ativo por padrão
- [x] Nenhum erro no console do WebView2 durante `wails dev` *(confirmar localmente)*
- [x] Nenhuma cor hardcodada em `editor.js` ou `editor.css`
- [x] `window.__editorView` acessível no console durante dev (para debugging)

---

## Bloqueios — parar e consultar o Supervisor se:

1. O importmap com caminhos para `node_modules/` não funcionar no WebView2
2. Os pacotes do CodeMirror não tiverem `dist/index.js` — verificar o campo `"main"` ou `"exports"` em cada `package.json`
3. `wails build` falhar ao empacotar `frontend/dist/node_modules/` (tamanho ou permissões)
4. Qualquer erro de lint introduzido por esta task
5. O editor renderizar mas com cores incorretas (tokens CSS não resolvendo)

---

## Arquivos a criar/modificar

| Ação | Ficheiro |
|---|---|
| CRIAR | `frontend/src/components/editor/editor.js` |
| CRIAR | `frontend/src/components/editor/editor.css` |
| MODIFICAR | `frontend/index.html` — adicionar importmap e editor-container |
| MODIFICAR | `frontend/src/main.js` — inicializar editor |
| MODIFICAR | `frontend/scripts/copy-to-dist.cjs` — copiar node_modules do CM6 |
| MODIFICAR | `STATUS.md` — atualizar ao concluir |

---

## Relatório

Criado: `project/specs/done/RELATORIO-codemirror6-2026-04-10.md`

Incluir obrigatoriamente nas observações:
- Caminhos reais dos `dist/index.js` de cada pacote (podem divergir do importmap acima)
- Se o importmap funcionou sem ajustes ou se precisou de adaptações
- Tamanho total de `frontend/dist/node_modules/` após o build
