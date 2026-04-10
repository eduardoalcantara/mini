# SPEC — Menu de Contexto
**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Status:** TO-DO
**Arquivo:** `project/specs/to-do/2026-04-10-SPEC-context-menu.md`

**Pipeline:** executar **depois** de `SPEC-config-service` e `SPEC-fontes-embed`. Ver [`2026-04-10-README-batch-specs.md`](./2026-04-10-README-batch-specs.md).

---

## Objetivo

Implementar menu de contexto customizado em HTML/CSS/JS vanilla com Material Symbols Rounded,
integrado ao `ConfigService` via bindings Wails. O menu deve aparecer ao clique direito
em qualquer área da janela, com itens diferentes dentro e fora da área do editor.

---

## Dependências

- `SPEC-config-service` concluída — bindings `getConfig`, `setConfig`, `resolveFont` disponíveis
- `SPEC-fontes-embed` concluída — Material Symbols Rounded disponível via classe `.icon`

---

## Estrutura do menu

### Itens comuns (ambas as zonas)

```
📄 Arquivo
    Novo                    Ctrl+N
    Abrir...                Ctrl+O
    Salvar                  Ctrl+S
    Salvar Como...          Ctrl+Shift+S
─────────────────────────
⚙️ Configurações
    Tema ›
        ● Perplexity Dark
          GitHub Light Default
          Claude Code Light
          Moleskine Light
        ─────────────────
          Novo tema...
          Importar tema...
    Fonte ›
        ● De acordo com o tipo de arquivo
          EB Garamond
          JetBrains Mono
        ─────────────────
          Outra...
    Tamanho da Fonte ›
        10  11  12  13  14
        ● 15  16  17  18
    Quebra de Linha ›
        ● Quebrar linha
          Não quebrar linha
    Números de Linha ›
        ● Visível
          Invisível
```

### Itens exclusivos da zona do editor (acrescentados no topo)

```
✂️  Recortar                Ctrl+X
📋 Copiar                  Ctrl+C
📌 Colar                   Ctrl+V
─────────────────────────
🔠 Selecionar tudo         Ctrl+A
─────────────────────────
```

---

## Tarefas

### 1. Criar `frontend/src/components/ui/context-menu/context-menu.js`

Responsabilidades:
- Registrar listener de `contextmenu` no `document`
- Detectar se o clique foi dentro de `.cm-editor` (zona editor) ou fora
- Renderizar o menu na posição do cursor, dentro dos limites da janela
- Fechar ao clicar fora, ao pressionar `Escape`, ou ao abrir outro menu
- Suportar submenus com abertura no hover após 150ms
- Executar a ação correspondente ao item clicado
- Marcar o item ativo conforme o estado atual do `config` (• bullet)

Estrutura de dados do menu:

```javascript
// Cada item segue este formato:
// { icon, label, shortcut?, action?, submenu?, separator?, checked? }

const MENU_EDITOR_ITEMS = [
  { icon: 'content_cut',   label: 'Recortar',      shortcut: 'Ctrl+X', action: () => document.execCommand('cut') },
  { icon: 'content_copy',  label: 'Copiar',        shortcut: 'Ctrl+C', action: () => document.execCommand('copy') },
  { icon: 'content_paste', label: 'Colar',         shortcut: 'Ctrl+V', action: () => document.execCommand('paste') },
  { separator: true },
  { icon: 'select_all',    label: 'Selecionar tudo', shortcut: 'Ctrl+A', action: () => document.execCommand('selectAll') },
  { separator: true },
];

// buildMenuItems(config) — retorna array completo baseado no estado atual
```

---

### 2. Criar `frontend/src/components/ui/context-menu/context-menu.css`

```css
.context-menu {
  position: fixed;
  z-index: 9999;
  min-width: 220px;
  background: var(--color-surface);
  border: 1px solid var(--color-border);
  border-radius: 8px;
  padding: var(--space-1) 0;
  box-shadow: 0 8px 24px rgba(0,0,0,0.4);
  animation: menu-in 120ms ease;
}

@keyframes menu-in {
  from { opacity: 0; transform: scale(0.97) translateY(-4px); }
  to   { opacity: 1; transform: scale(1)    translateY(0); }
}

.context-menu-item {
  display: flex;
  align-items: center;
  gap: var(--space-2);
  padding: var(--space-2) var(--space-3);
  cursor: pointer;
  color: var(--color-text);
  font-family: var(--font-ui);
  font-size: var(--text-ui-base);
  user-select: none;
  position: relative;
  border-radius: 4px;
  margin: 0 var(--space-1);
}

.context-menu-item:hover,
.context-menu-item--active {
  background: var(--color-surface-2);
}

.context-menu-item .icon {
  color: var(--color-text-muted);
  font-size: 16px;
  width: 20px;
  flex-shrink: 0;
}

.context-menu-item__label {
  flex: 1;
}

.context-menu-item__shortcut {
  color: var(--color-text-faint);
  font-size: var(--text-ui-sm);
  margin-left: var(--space-4);
}

.context-menu-item__arrow {
  color: var(--color-text-faint);
  font-size: 14px;
}

.context-menu-item--checked::before {
  content: '●';
  position: absolute;
  left: 6px;
  font-size: 6px;
  color: var(--color-accent);
}

.context-menu-separator {
  height: 1px;
  background: var(--color-border);
  margin: var(--space-1) var(--space-2);
}

/* Submenu */
.context-submenu {
  position: absolute;
  left: 100%;
  top: -4px;
  /* herda estilos de .context-menu */
}
```

---

### 3. Adicionar tokens faltantes ao `tokens.css`

Verificar e adicionar se não existirem:

```css
--color-surface-2:   #2a2a32;
--color-border:      #35353f;
--color-text-faint:  #55555f;
```

---

### 4. Integração com ConfigService

O menu deve:
1. Chamar `getConfig()` ao abrir para saber os valores atuais e marcar o item ativo
2. Chamar `setConfig({...cfg, campo: novoValor})` ao selecionar uma opção de configuração
3. Emitir evento customizado `config-changed` no `document` para que outros componentes
   (editor) possam reagir sem acoplamento direto

```javascript
// Após setConfig bem-sucedido:
document.dispatchEvent(new CustomEvent('config-changed', { detail: newConfig }));
```

---

### 5. Reagir ao `config-changed` no editor

Em `frontend/src/main.js`, adicionar listener:

```javascript
document.addEventListener('config-changed', (e) => {
  const cfg = e.detail;
  applyConfigToEditor(view, cfg);
});

function applyConfigToEditor(view, cfg) {
  // line wrap
  // line numbers
  // font e font-size via CSS variables no elemento pai
}
```

> A aplicação de fonte e tamanho no editor é feita via CSS no elemento container —
> não via reconfiguração do EditorView — para manter simplicidade:
> ```javascript
> mountEl.style.setProperty('--font-editor-active', fontName);
> mountEl.style.setProperty('--text-editor-active', cfg.font_size + 'px');
> ```
> E no `editor.css`:
> ```css
> .editor-container { --font-editor-active: var(--font-editor-text); }
> .cm-content { font-family: var(--font-editor-active) !important; }
> ```

---

### 6. Inicializar menu em `frontend/src/main.js`

```javascript
import { initContextMenu } from './components/ui/context-menu/context-menu.js';
initContextMenu();
```

---

### 7. Incluir CSS no `index.html`

```html
<link rel="stylesheet" href="src/components/ui/context-menu/context-menu.css" />
```

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
- [ ] Clique direito fora do editor abre menu com itens de Arquivo e Configurações
- [ ] Clique direito dentro do editor abre menu com itens de edição + Arquivo + Configurações
- [ ] Submenu de Tema exibe os 4 temas com bullet no tema ativo
- [ ] Submenu de Fonte exibe as 4 opções com bullet na fonte ativa
- [ ] Submenu de Tamanho da Fonte exibe 10–18 com bullet no tamanho ativo
- [ ] Submenu de Quebra de Linha e Números de Linha funcionam corretamente
- [ ] Selecionar Fonte → EB Garamond altera a fonte do editor visualmente e persiste no `config.json`
- [ ] Selecionar Tamanho → 14 altera o tamanho e persiste
- [ ] Menu fecha ao clicar fora ou pressionar Escape
- [ ] Submenus abrem no hover após 150ms e fecham ao mover para outro item
- [ ] Ícones Material Symbols visíveis e alinhados ao texto
- [ ] Animação de abertura (fade + translateY) funcionando
- [ ] Nenhuma cor hardcodada em `context-menu.css`

---

## Bloqueios — parar e consultar o Supervisor se:

1. `document.execCommand` não funcionar no WebView2 para cut/copy/paste — reportar e aguardar orientação
2. O posicionamento do submenu sair da janela (overflow) — implementar lógica de inversão de lado
3. O evento `config-changed` não propagar corretamente entre módulos ES

---

## Arquivos a criar/modificar

| Ação | Arquivo |
|---|---|
| CRIAR | `frontend/src/components/ui/context-menu/context-menu.js` |
| CRIAR | `frontend/src/components/ui/context-menu/context-menu.css` |
| MODIFICAR | `frontend/index.html` — link para context-menu.css |
| MODIFICAR | `frontend/src/main.js` — initContextMenu + listener config-changed |
| MODIFICAR | `frontend/src/styles/tokens.css` — tokens surface-2, border, text-faint |
| MODIFICAR | `STATUS.md` |
