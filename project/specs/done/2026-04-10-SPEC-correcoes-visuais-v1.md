# SPEC — Correções Visuais e UX v1
**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Status:** DONE
**Arquivo:** `project/specs/done/2026-04-10-SPEC-correcoes-visuais-v1.md`

---

## Objetivo

Corrigir 7 problemas visuais e de UX identificados pelo PO após validação manual.

---

## Correção 1 — Indicador de item ativo no menu: remover "." e usar ícone check

**Problema:** O CSS `::before` com `content: '●'` aparece como ponto vermelho-rosco
empurrando o texto para a direita.

**Solução:** Substituir o `::before` por um elemento `.icon` dentro do item,
que exibe `check` quando ativo e fica vazio (mas ocupa o espaço) quando inativo.
Isso mantém o alinhamento estável em todos os itens.

Em `context-menu.js`, alterar a renderização de cada item com `checked`:

```javascript
// Coluna de ícone de estado — sempre presente, visível só se checked
const checkEl = document.createElement('span');
checkEl.className = 'icon context-menu-item__check';
checkEl.textContent = item.checked ? 'check' : '';
itemEl.prepend(checkEl);
```

Em `context-menu.css`:

```css
/* REMOVER a regra ::before existente */
/* .context-menu-item--checked::before { ... } */   /* <- DELETAR */

.context-menu-item__check {
  font-family: 'Material Symbols Rounded';
  font-size: 14px;
  width: 18px;
  flex-shrink: 0;
  color: var(--color-accent);
  display: inline-block;
  text-align: center;
}
```

---

## Correção 2 — Cor da barra de título acompanha o tema

**Problema:** `windows.CustomTheme` em `main.go` tem a cor hardcodada `#1a1a1f`
(tema escuro). Ao trocar para tema claro, a barra de título não acompanha.

**Solução:** Usar `runtime.WindowSetBackgroundColour` via binding Wails para
atualizar a cor da janela dinamicamente quando o tema mudar. A barra de título
nativa do Windows não pode ser recolorida em runtime via CSS — mas a cor de fundo
da WebView sim, e a titlebar CSS acompanha automaticamente via `var(--color-bg)`.

Para a barra nativa (botões de sistema), a abordagem correta é usar
`runtime.WindowSetBackgroundColour` com a cor de fundo do tema ativo:

**Em `src/app/app.go`, adicionar binding:**

```go
// SetThemeColour atualiza a cor de fundo da janela nativa para o tema ativo.
// r, g, b são os componentes da cor de fundo do tema (0–255).
func (a *App) SetWindowBackground(r, g, b uint8) {
    runtime.WindowSetBackgroundColour(a.ctx, r, g, b, 255)
}
```

**Em `frontend/src/bindings/index.js`:**

```javascript
import { SetWindowBackground } from './wailsjs/go/app/App.js';
export const setWindowBackground = (r, g, b) => SetWindowBackground(r, g, b);
```

**Em `context-menu.js`, ao aplicar tema:**

```javascript
// Mapa de cor de fundo por tema (componentes RGB)
const THEME_BG = {
  'perplexity-dark':       [26,  26,  31],
  'github-light-default':  [255, 255, 255],
  'claude-code-light':     [250, 248, 242],
  'moleskine-light':       [245, 242, 232],
};

async function applyTheme(themeSlug) {
  document.documentElement.setAttribute('data-theme', themeSlug);
  const [r, g, b] = THEME_BG[themeSlug] ?? [26, 26, 31];
  await setWindowBackground(r, g, b);
  // ... setConfig
}
```

---

## Correção 3 — Título da janela: "nome do arquivo — Mini" ou "Mini"

**Problema:** `Title: ""` remove o texto da barra de tarefas e da taskbar do Windows,
deixando apenas o ícone — comportamento estranho.

**Solução:** Definir título inicial `"Mini"` no `main.go` e atualizá-lo dinamicamente
via `runtime.WindowSetTitle` quando um arquivo for aberto.

**Em `main.go`:**
```go
Title: "Mini",
```

**Em `src/app/app.go`, adicionar binding:**
```go
// SetWindowTitle atualiza o título da janela.
func (a *App) SetWindowTitle(title string) {
    runtime.WindowSetTitle(a.ctx, title)
}
```

**Em `frontend/src/bindings/index.js`:**
```javascript
import { SetWindowTitle } from './wailsjs/go/app/App.js';
export const setWindowTitle = (title) => SetWindowTitle(title);
```

O frontend chama `setWindowTitle("Mini")` na inicialização.
Quando um arquivo for aberto (spec futura), chamará `setWindowTitle("nome.txt — Mini")`.

> ⚠️ O texto "Mini" aparecerá na barra de título nativa. Como a barra está pintada
> na mesma cor do fundo (`CustomTheme`), o texto ficará invisível — mas presente
> na taskbar do Windows. Isso é o comportamento correto e esperado.

---

## Correção 4 — Submenu de tamanhos com scroll

**Problema:** O submenu de tamanho de fonte (10–18, 9 itens) fica maior que a
janela quando o app não está maximizado.

**Solução:** Limitar a altura máxima do submenu e adicionar `overflow-y: auto`
com scrollbar customizada.

Em `context-menu.css`:

```css
.context-submenu {
  max-height: 320px;
  overflow-y: auto;
  overflow-x: hidden;
}

/* Scrollbar fina no submenu */
.context-submenu::-webkit-scrollbar       { width: 4px; }
.context-submenu::-webkit-scrollbar-track { background: transparent; }
.context-submenu::-webkit-scrollbar-thumb {
  background-color: var(--color-muted);
  border-radius: 9999px;
}
```

---

## Correção 5 — Cor de seleção de texto distinguível do highlight de linha

**Problema:** A cor de fundo da seleção de texto é a mesma do highlight da linha
ativa, tornando a seleção invisível.

**Solução:** Diferenciar as cores no tema do CodeMirror em `editor.js`:

```javascript
const editorTheme = EditorView.theme({
  // ...existente...
  '&.cm-focused .cm-selectionBackground': {
    backgroundColor: 'var(--color-selection) !important',
  },
  '.cm-selectionBackground': {
    backgroundColor: 'var(--color-selection-inactive) !important',
  },
  '.cm-activeLine': {
    backgroundColor: 'var(--color-surface)',
  },
}, { dark: true });
```

Adicionar tokens em `tokens.css`:

```css
/* Tema escuro (padrão) */
--color-selection:          rgba(90, 175, 223, 0.35);  /* accent com opacidade */
--color-selection-inactive: rgba(90, 175, 223, 0.15);
```

Para temas claros, redefinir nos arquivos de tema correspondentes:
```css
/* Ex: data-theme="github-light-default" */
--color-selection:          rgba(0, 92, 197, 0.25);
--color-selection-inactive: rgba(0, 92, 197, 0.12);
```

---

## Correção 6 — Texto legível sobre seleção (clique triplo / seleção total)

**Problema:** Ao selecionar toda a linha (clique triplo), o fundo muda mas a
fonte permanece escura — ilegível sobre fundo escuro de seleção.

**Causa:** A `color` do texto não é sobrescrita na seleção — o navegador/WebView2
não aplica inversão automática.

**Solução:** Forçar a cor do texto na seleção via CSS global em `base.css`:

```css
::selection {
  background-color: var(--color-selection);
  color: var(--color-text-on-selection);
}
```

Adicionar token em `tokens.css`:

```css
--color-text-on-selection: #ffffff;   /* tema escuro */
```

Para temas claros:
```css
--color-text-on-selection: #1a1a1f;
```

E no tema do CodeMirror em `editor.js`, garantir que o texto na seleção
também use a cor correta:

```javascript
'& .cm-line ::selection, & .cm-line.cm-selectionBackground': {
  color: 'var(--color-text-on-selection) !important',
},
```

---

## Correção 7 — Scrollbar afastada do conteúdo (padding direito no scroller)

**Problema:** A scrollbar fica colada ao texto nas linhas que chegam até o fim
da área visível.

**Solução:** Adicionar `padding-right` no `.cm-scroller` para criar espaço entre
o conteúdo e a scrollbar. O valor de ~8px (equivalente a `--space-2`) é suficiente.

Em `editor.css`:

```css
.editor-container .cm-scroller {
  padding: var(--space-4) var(--space-4);
  padding-right: calc(var(--space-4) + 8px); /* espaço extra antes da scrollbar */
  scroll-padding-right: 8px;
}
```

Ou alternativamente, via tema do CodeMirror em `editor.js`:

```javascript
'.cm-scroller': {
  paddingRight: 'calc(var(--space-4) + 8px)',
},
```

Usar apenas uma das duas abordagens — **não duplicar**. Preferir o CSS externo
em `editor.css` para manter consistência com o padrão já estabelecido.

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
- [ ] `wails build` — sem erros
- [ ] Item de menu ativo exibe ícone `check` alinhado — sem ponto vermelho, sem desalinhamento
- [ ] Ao trocar para tema claro, a cor de fundo da janela (barra nativa) acompanha
- [ ] Janela exibe "Mini" na taskbar do Windows
- [ ] Submenu de tamanho de fonte tem scroll quando necessário — nenhum item fica fora da tela
- [ ] Texto selecionado tem fundo visualmente distinto do highlight de linha ativa
- [ ] Texto selecionado com clique triplo é legível (cor de texto sobre seleção)
- [ ] Scrollbar mantém distância mínima de 8px do texto mais longo
- [ ] Nenhuma cor hardcodada introduzida — tudo via tokens CSS

---

## Bloqueios — parar e consultar o Supervisor se:

1. `runtime.WindowSetBackgroundColour` não afetar a barra de título nativa no Windows
2. `::selection` não funcionar no WebView2 — reportar versão do WebView2 instalado
3. O padding extra no `.cm-scroller` causar offset visual indesejado no conteúdo

---

## Arquivos a modificar

| Arquivo | O que muda |
|---|---|
| `main.go` | `Title: "Mini"` |
| `src/app/app.go` | + `SetWindowBackground`, + `SetWindowTitle` |
| `frontend/src/bindings/index.js` | + `setWindowBackground`, + `setWindowTitle` |
| `frontend/src/components/ui/context-menu/context-menu.js` | check icon + applyTheme com setWindowBackground |
| `frontend/src/components/ui/context-menu/context-menu.css` | remover `::before`, + `.icon__check`, + scroll no submenu |
| `frontend/src/components/editor/editor.js` | cores de seleção no EditorView.theme |
| `frontend/src/components/editor/editor.css` | padding-right no cm-scroller |
| `frontend/src/styles/tokens.css` | + `--color-selection`, `--color-selection-inactive`, `--color-text-on-selection` |
| `frontend/src/styles/base.css` | + `::selection` global |
| `STATUS.md` | atualizar |
