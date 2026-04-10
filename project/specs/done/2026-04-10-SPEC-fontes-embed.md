# SPEC — Embed de Fontes
**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Status:** DONE
**Arquivo:** `project/specs/done/2026-04-10-SPEC-fontes-embed.md`

**Pipeline:** pode correr **em paralelo** com `SPEC-config-service`. `SPEC-context-menu` depende desta. Ver [`2026-04-10-README-batch-specs.md`](./2026-04-10-README-batch-specs.md).

---

## Objetivo

Embutir as três fontes necessárias no executável como assets estáticos do frontend,
eliminando dependência de CDN ou fontes do sistema operacional.

---

## Fontes a embutir

| Fonte | Uso | Variantes necessárias | Licença |
|---|---|---|---|
| **EB Garamond** | `--font-editor-text` — arquivos .txt e texto corrido | Regular (400), Italic (400i), SemiBold (600) | OFL — Google Fonts |
| **JetBrains Mono** | `--font-editor-code` — arquivos de código | Regular (400), Italic (400i), Bold (700) | OFL — JetBrains |
| **Material Symbols Rounded** | Ícones do menu de contexto e UI | Variable font (único arquivo) | Apache 2.0 — Google |

---

## Tarefas

### 1. Download das fontes

#### EB Garamond
Baixar de https://fonts.google.com/specimen/EB+Garamond — formato `.woff2`:
- `EBGaramond-Regular.woff2`
- `EBGaramond-Italic.woff2`
- `EBGaramond-SemiBold.woff2`

#### JetBrains Mono
Baixar de https://www.jetbrains.com/lp/mono/ ou GitHub `JetBrains/JetBrainsMono` — formato `.woff2`:
- `JetBrainsMono-Regular.woff2`
- `JetBrainsMono-Italic.woff2`
- `JetBrainsMono-Bold.woff2`

#### Material Symbols Rounded
Baixar o variable font de https://github.com/google/material-symbols — formato `.woff2`:
- `MaterialSymbolsRounded.woff2`

> ⚠️ O arquivo variable font do Material Symbols tem ~3MB. Isso é aceitável pois
> é embutido uma única vez no binário. Documentar o tamanho no relatório.

---

### 2. Organizar em `frontend/src/styles/fonts/`

```
frontend/src/styles/fonts/
├── eb-garamond/
│   ├── EBGaramond-Regular.woff2
│   ├── EBGaramond-Italic.woff2
│   └── EBGaramond-SemiBold.woff2
├── jetbrains-mono/
│   ├── JetBrainsMono-Regular.woff2
│   ├── JetBrainsMono-Italic.woff2
│   └── JetBrainsMono-Bold.woff2
└── material-symbols/
    └── MaterialSymbolsRounded.woff2
```

---

### 3. Criar `frontend/src/styles/fonts.css`

```css
/* EB Garamond */
@font-face {
  font-family: 'EB Garamond';
  src: url('./fonts/eb-garamond/EBGaramond-Regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: block;
}
@font-face {
  font-family: 'EB Garamond';
  src: url('./fonts/eb-garamond/EBGaramond-Italic.woff2') format('woff2');
  font-weight: 400;
  font-style: italic;
  font-display: block;
}
@font-face {
  font-family: 'EB Garamond';
  src: url('./fonts/eb-garamond/EBGaramond-SemiBold.woff2') format('woff2');
  font-weight: 600;
  font-style: normal;
  font-display: block;
}

/* JetBrains Mono */
@font-face {
  font-family: 'JetBrains Mono';
  src: url('./fonts/jetbrains-mono/JetBrainsMono-Regular.woff2') format('woff2');
  font-weight: 400;
  font-style: normal;
  font-display: block;
}
@font-face {
  font-family: 'JetBrains Mono';
  src: url('./fonts/jetbrains-mono/JetBrainsMono-Italic.woff2') format('woff2');
  font-weight: 400;
  font-style: italic;
  font-display: block;
}
@font-face {
  font-family: 'JetBrains Mono';
  src: url('./fonts/jetbrains-mono/JetBrainsMono-Bold.woff2') format('woff2');
  font-weight: 700;
  font-style: normal;
  font-display: block;
}

/* Material Symbols Rounded — variable font */
@font-face {
  font-family: 'Material Symbols Rounded';
  src: url('./fonts/material-symbols/MaterialSymbolsRounded.woff2') format('woff2');
  font-weight: 100 700;
  font-style: normal;
  font-display: block;
}
```

---

### 4. Adicionar classe utilitária de ícone

Em `frontend/src/styles/fonts.css`, adicionar ao final:

```css
/* Classe utilitária para ícones Material Symbols */
.icon {
  font-family: 'Material Symbols Rounded';
  font-weight: normal;
  font-style: normal;
  font-size: 20px;
  line-height: 1;
  letter-spacing: normal;
  text-transform: none;
  display: inline-block;
  white-space: nowrap;
  word-wrap: normal;
  direction: ltr;
  -webkit-font-smoothing: antialiased;
  /* Ajuste de variação do variable font */
  font-variation-settings: 'FILL' 0, 'wght' 400, 'GRAD' 0, 'opsz' 24;
}

.icon--sm  { font-size: 16px; }
.icon--lg  { font-size: 24px; }
```

---

### 5. Referenciar em `frontend/index.html`

Adicionar link para `fonts.css` antes de `tokens.css`:

```html
<link rel="stylesheet" href="src/styles/fonts.css" />
<link rel="stylesheet" href="src/styles/tokens.css" />
```

---

### 6. Atualizar `frontend/src/styles/tokens.css`

Substituir os valores das variáveis de fonte pelos nomes exatos das famílias declaradas no `@font-face`:

```css
--font-editor-text: 'EB Garamond', Georgia, serif;
--font-editor-code: 'JetBrains Mono', Consolas, monospace;
```

---

### 7. Atualizar `frontend/scripts/copy-to-dist.cjs`

Garantir que `frontend/src/styles/fonts/` é copiado para `frontend/dist/src/styles/fonts/`.
O script já copia `src/` recursivamente — verificar se os arquivos `.woff2` são incluídos
e confirmar no relatório.

---

## Validações obrigatórias

```powershell
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
- [ ] No `wails dev`, o texto do editor renderiza em EB Garamond (serifa elegante visível)
- [ ] Nenhuma requisição de rede para fonts.googleapis.com ou CDN externo (verificar DevTools do WebView2)
- [ ] `<span class="icon">content_copy</span>` renderiza o ícone de copiar corretamente
- [ ] `<span class="icon">settings</span>` renderiza o ícone de engrenagem corretamente
- [ ] Documentar no relatório o tamanho total dos arquivos `.woff2` adicionados

---

## Bloqueios — parar e consultar o Supervisor se:

1. O `wails build` falhar por tamanho excessivo do binário após incluir as fontes
2. O `copy-to-dist.cjs` não incluir arquivos `.woff2` — verificar se há filtro de extensão no script
3. O Material Symbols variable font não renderizar no WebView2 — tentar com `font-variation-settings` explícito

---

## Arquivos a criar/modificar

| Ação | Arquivo |
|---|---|
| CRIAR | `frontend/src/styles/fonts/` — 7 arquivos `.woff2` |
| CRIAR | `frontend/src/styles/fonts.css` |
| MODIFICAR | `frontend/index.html` — link para fonts.css |
| MODIFICAR | `frontend/src/styles/tokens.css` — atualizar variáveis de fonte |
| VERIFICAR | `frontend/scripts/copy-to-dist.cjs` — confirmar cópia de `.woff2` |
| MODIFICAR | `STATUS.md` |
