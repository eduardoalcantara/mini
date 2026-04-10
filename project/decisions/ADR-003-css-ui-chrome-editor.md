# ADR-003 — CSS da janela, chrome Wails e editor CodeMirror

**Data:** 2026-04-10  
**Status:** ACEITO  
**Versão:** 1.0

---

## Contexto

A UI combina três camadas: **barra de título nativa** (Windows, pintada via Go/Wails), **HTML mínimo** (`.titlebar` para integração Wails) e **CodeMirror 6** (gutter + área de scroll). Erros comuns são **duplicar altura** no topo e **aplicar margem só no scroller**, o que deixa a gutter colada à borda.

Este ADR fixa **decisões estéticas** e a **ordem mental dos ficheiros CSS** para quem editar o layout sem regressões.

---

## Decisões estéticas

### Paleta e tokens (`frontend/src/styles/tokens.css`)

- Fundo da app e do editor: `--color-bg: #1a1a1f` — alinhado a `BackgroundColour` e `windows.CustomTheme` em `main.go` para a barra nativa “desaparecer” na mesma cor.
- Texto: `--color-text: #d4d4d0`; estados secundários: `--color-muted`, `--color-text-muted` (scrollbar, gutter secundário).
- **Margem de página do editor:** `--editor-page-inset: 1cm` — respiro mínimo pedido em produto entre o **contorno da área útil** e o bloco gutter+conteúdo; `cm` escala com o DPI (ao contrário de um px fixo).

### Barra de título nativa + `.titlebar` HTML

- **Go:** `Title: ""`, `CustomTheme` com RGB `(26,26,31)` em barra/texto/borda — sem texto de título visível; botões de sistema preservados (`Frameless: false`).
- **CSS (`titlebar/titlebar.css`):** altura **0** no bloco HTML. Uma `.titlebar` com `height: 32px` **somava-se** à barra nativa (~dupla faixa escura). O cliente Wails já desenha a faixa; o div existe sobretudo para `--wails-draggable: drag` e encaixe futuro, sem ocupar pixels verticais extra.

### Scrollbar (WebView2 / Chromium)

- Regras `::-webkit-scrollbar-*` em `editor.css`, scoped a `.editor-container`, para não vazar para o resto da app.
- Track transparente; thumb com `--color-muted` e hover com `--color-text-muted`; ~5px de largura — discreto, alinhado à spec “fina”.

### CodeMirror — sem fold gutter

- Montagem do editor via extensões explícitas (`minimalSetup`), não `basicSetup`, para **não** mostrar seta de fold na gutter (decisão de produto; ver specs concluídas e ADR-001/002).

---

## Estrutura dos ficheiros CSS (como pensar cada um)

Ordem de carregamento em `index.html`: **tokens → base → titlebar → editor**. Quem vem depois pode sobrepor; por isso tokens primeiro, depois layout global, depois componentes.

| Ficheiro | Responsabilidade |
|----------|------------------|
| **`tokens.css`** | Variáveis semânticas: cores, espaçamentos, `--editor-page-inset`. Não contém seletores de layout da app além de `:root`. |
| **`base.css`** | Reset leve (`box-sizing`), `html`/`body`, **`#app`** (coluna flex, `100vh`, overflow hidden), **`.editor-container` em `base.css`** só com `flex: 1` + `min-height: 0` para o filho ocupar o espaço abaixo da `.titlebar`. |
| **`titlebar/titlebar.css`** | Só a classe `.titlebar` — altura zero, transparente, draggable. |
| **`editor/editor.css`** | Tudo que é **CodeMirror + scrollbar**: padding de página no **`.editor-container`** (ver abaixo), `.cm-editor`, `.cm-scroller`, pseudo-elementos de scrollbar. |

**Regra importante:** o **padding “margem da página”** (`--editor-page-inset`) aplica-se ao **`.editor-container`**, não só ao **`.cm-scroller`**.

---

## Aprendizado: DOM do CodeMirror 6 e margens

No CM6, dentro do `.cm-editor`, a **gutter** (números de linha) e o **`.cm-scroller`** são **regiões irmãs** (não está tudo dentro do scroller).

- Se se puser `padding` **apenas** em `.cm-scroller`, o texto afasta-se das bordas, mas a **gutter continua colada à esquerda** e a “caixa” do editor não fica uniformemente rodeada.
- **Solução adotada:** `padding` com `var(--editor-page-inset)` no **`.editor-container`**, que envolve o `.cm-editor` inteiro. Assim, gutter, texto e área de scroll respeitam o mesmo inset em **topo, direita, fundo e esquerda**.

Manter este invariante em specs futuras (ex.: painéis laterais): qualquer novo inset deve respeitar a mesma árvore (container por fora, não só o scroller).

---

## Relação com outros ADRs

- **ADR-001** — embed, `Title` vazio possível, binário `mini.exe`.
- **ADR-002** — importmap + pnpm; não reintroduzir meta-pacote `codemirror`.

---

## Consequências

- Alterar “margem da página” do editor: **só** `--editor-page-inset` em `tokens.css` (ou override por tema em `themes/` quando existir).
- Regressão “faixa dupla” no topo: verificar se alguém voltou a pôr **altura > 0** em `.titlebar` sem rever este ADR.
- Regressão “gutter colada”: verificar se o padding foi movido para **dentro** só do `.cm-scroller`.
