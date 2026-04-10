# SPEC — Janela e UI Chrome
**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Status:** DONE
**Arquivo:** `project/specs/done/2026-04-10-SPEC-janela-ui-chrome.md`

---

## Objetivo

Remover a barra de título nativa do Windows e substituir por uma área de arrasto
invisível com os 3 botões de sistema nativos (estilo macOS/Numi), além de:
- Barra de rolagem customizada — fina, com bordas suaves
- Remoção do fold gutter (seta de code folding) do CodeMirror

---

## Referência visual

- App de referência: **Numi** — barra de topo na mesma cor do fundo do editor,
  3 botões de sistema nativos visíveis, sem título de janela, sem decoração nativa.
- Barra de rolagem: fina (~4-6px), cor `var(--color-muted)`, bordas arredondadas,
  aparece apenas no hover, sem track visível.

---

## Tarefas

### 1. Configurar `Frameless: false` + ocultar título via Wails

O Wails no Windows não suporta manter os botões nativos com `Frameless: true` —
ao ativar frameless, os controles nativos somem completamente.

**Solução correta para Windows + botões nativos:** usar a opção de **ocultar apenas
o título** via configuração de janela no `main.go`, mantendo a barra de título
nativa porém com altura reduzida ao mínimo e cor de fundo sobreposta pelo frontend.

Isso é feito com:
- `Frameless: false` (padrão, não mudar)
- `HideWindowOnClose: false`
- No frontend: área de `height: 32px` no topo com `--wails-draggable: drag`
  que **visualmente sobrepõe** a barra nativa quando a janela está maximizada
  ou em tamanho padrão

> ⚠️ **ATENÇÃO:** No Windows, `Frameless: true` + botões nativos **não é possível**
> nativamente pelo Wails v2. Se o Cursor encontrar forma de manter os 3 botões
> com frameless: **PARAR e consultar o Supervisor antes de implementar**.
> A solução aprovada é a descrita acima.

**Alterações em `main.go`:**

```go
err := wails.Run(&options.App{
    Title:  "",                    // título vazio — sem texto na barra
    Width:  1100,
    Height: 700,
    MinWidth:  600,
    MinHeight: 400,
    AssetServer: &assetserver.Options{
        Assets: assets,
    },
    BackgroundColour: &options.RGBA{R: 26, G: 26, B: 31, A: 255}, // #1a1a1f
    OnStartup:        app.Startup,
    Bind: []interface{}{
        app,
    },
    Windows: &windows.Options{
        WebviewIsTransparent:              false,
        WindowIsTranslucent:               false,
        DisableWindowIcon:                 true,
        Theme:                             windows.Dark,
        CustomTheme: &windows.ThemeSettings{
            DarkModeTitleBar:   windows.RGB(26, 26, 31),   // #1a1a1f
            DarkModeTitleText:  windows.RGB(26, 26, 31),   // texto invisível
            DarkModeBorder:     windows.RGB(26, 26, 31),   // sem borda visível
            LightModeTitleBar:  windows.RGB(26, 26, 31),
            LightModeTitleText: windows.RGB(26, 26, 31),
            LightModeBorder:    windows.RGB(26, 26, 31),
        },
    },
})
```

Isso pinta a barra de título nativa na mesma cor do fundo (`#1a1a1f`),
tornando-a invisível — os 3 botões de sistema ficam visíveis mas o título some.

---

### 2. Adicionar área de arrasto no frontend

Criar `frontend/src/components/titlebar/titlebar.css`:

```css
/* frontend/src/components/titlebar/titlebar.css */
.titlebar {
  height: 32px;
  width: 100%;
  background-color: var(--color-bg);
  --wails-draggable: drag;
  flex-shrink: 0;
  display: flex;
  align-items: center;
  /* sem conteúdo visível — apenas área de drag */
}
```

Atualizar `frontend/index.html` para incluir a titlebar antes do editor:

```html
<div id="app">
  <div class="titlebar" id="titlebar"></div>
  <div class="editor-container" id="editor-mount"></div>
</div>
```

Atualizar `frontend/src/styles/base.css`:

```css
#app {
  display: flex;
  flex-direction: column;
  height: 100vh;
  overflow: hidden;
}

.editor-container {
  flex: 1;
  overflow: hidden;
}
```

---

### 3. Remover fold gutter do CodeMirror

O `basicSetup` do CodeMirror inclui por padrão o `foldGutter()` — a seta de
collapse visível na primeira linha. Precisa ser removido.

**Solução:** substituir `basicSetup` por uma lista explícita de extensões,
excluindo `foldGutter` e `foldKeymap`.

Em `frontend/src/components/editor/editor.js`, substituir:

```javascript
// ANTES
import { EditorView, basicSetup } from 'codemirror';
// ...
extensions: [
  basicSetup,
  ...
]
```

Por:

```javascript
// DEPOIS
import { EditorView } from '@codemirror/view';
import { EditorState } from '@codemirror/state';
import {
  lineNumbers,
  highlightActiveLineGutter,
  highlightSpecialChars,
  drawSelection,
  dropCursor,
  rectangularSelection,
  crosshairCursor,
  highlightActiveLine,
  keymap,
} from '@codemirror/view';
import {
  history,
  defaultKeymap,
  historyKeymap,
  indentWithTab,
} from '@codemirror/commands';
import {
  indentOnInput,
  bracketMatching,
  foldable,
  syntaxHighlighting,
  defaultHighlightStyle,
} from '@codemirror/language';
import { closeBrackets, closeBracketsKeymap } from '@codemirror/autocomplete';
import { highlightSelectionMatches, searchKeymap } from '@codemirror/search';

// basicSetup SEM foldGutter e SEM foldKeymap
const minimalSetup = [
  lineNumbers(),
  highlightActiveLineGutter(),
  highlightSpecialChars(),
  history(),
  drawSelection(),
  dropCursor(),
  EditorState.allowMultipleSelections.of(true),
  indentOnInput(),
  syntaxHighlighting(defaultHighlightStyle, { fallback: true }),
  bracketMatching(),
  closeBrackets(),
  rectangularSelection(),
  crosshairCursor(),
  highlightActiveLine(),
  highlightSelectionMatches(),
  keymap.of([
    ...closeBracketsKeymap,
    ...defaultKeymap,
    ...searchKeymap,
    ...historyKeymap,
    indentWithTab,
  ]),
];
```

Adicionar `@codemirror/autocomplete` e `@codemirror/search` ao importmap e ao
`copy-to-dist.cjs` caso ainda não estejam (verificar se foram instalados pelo
`basicSetup` como dependência transitiva — provavelmente sim).

---

### 4. Barra de rolagem customizada

Em `frontend/src/components/editor/editor.css`, adicionar:

```css
/* Scrollbar customizada — WebKit (WebView2 usa Chromium) */
.editor-container ::-webkit-scrollbar {
  width: 5px;
  height: 5px;
}

.editor-container ::-webkit-scrollbar-track {
  background: transparent;
}

.editor-container ::-webkit-scrollbar-thumb {
  background-color: var(--color-muted);
  border-radius: 9999px;
  border: none;
}

.editor-container ::-webkit-scrollbar-thumb:hover {
  background-color: var(--color-text-muted);
}

.editor-container ::-webkit-scrollbar-corner {
  background: transparent;
}
```

---

### 5. Adicionar tokens faltantes ao `tokens.css`

As regras acima referenciam `--color-text-muted` e `--color-muted`.
Verificar se existem em `tokens.css` e adicionar se faltarem:

```css
--color-muted:      #555560;
--color-text-muted: #888893;
```

---

## Validações obrigatórias

```powershell
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Wails    = Join-Path $RepoRoot "tools\wails.exe"
$Lint     = Join-Path $RepoRoot "tools\golangci-lint.exe"

go build ./...
& $Lint run
& $Wails build
& $Wails dev
```

---

## Critérios de aceitação

- [ ] `go build ./...` — sem erros
- [ ] `golangci-lint run` — 0 issues
- [ ] `wails build` — `build/bin/mini.exe` gerado sem erros
- [ ] A barra de título nativa está pintada em `#1a1a1f` — invisível, mesclada com o editor
- [ ] Os 3 botões de sistema (minimizar, maximizar, fechar) estão visíveis e funcionais
- [ ] Nenhum texto de título visível na barra
- [ ] A janela pode ser arrastada pela área de titlebar no topo
- [ ] A seta de fold (code folding) não aparece mais na gutter do editor
- [ ] A barra de rolagem é fina (~5px), com thumb arredondado na cor `var(--color-muted)`
- [ ] O track da scrollbar é transparente — sem faixa de fundo visível
- [ ] O editor ainda ocupa 100% da área restante abaixo da titlebar

---

## Bloqueios — parar e consultar o Supervisor se:

1. `windows.CustomTheme` não estiver disponível na versão atual do Wails v2 — verificar importação correta de `github.com/wailsapp/wails/v2/pkg/options/windows`
2. A coloração da barra de título não funcionar via `CustomTheme` — reportar comportamento exato
3. O `foldGutter` não sumir após substituir `basicSetup` — verificar se há outra extensão ativando-o
4. A scrollbar customizada não funcionar no WebView2 — `::-webkit-scrollbar` tem suporte no Chromium >= 88 (WebView2 atual suporta)

---

## Arquivos a criar/modificar

| Ação | Arquivo |
|---|---|
| CRIAR | `frontend/src/components/titlebar/titlebar.css` |
| MODIFICAR | `main.go` — opções de janela Windows + título vazio |
| MODIFICAR | `frontend/index.html` — adicionar `.titlebar` antes do editor |
| MODIFICAR | `frontend/src/styles/base.css` — layout flex coluna |
| MODIFICAR | `frontend/src/components/editor/editor.js` — substituir `basicSetup` por `minimalSetup` |
| MODIFICAR | `frontend/src/components/editor/editor.css` — scrollbar customizada |
| MODIFICAR | `frontend/src/styles/tokens.css` — tokens `--color-muted` e `--color-text-muted` se faltarem |
| MODIFICAR | `STATUS.md` — atualizar ao concluir |
