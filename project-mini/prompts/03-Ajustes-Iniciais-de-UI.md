# Tarefa: Refinamento de Interface e Experiência do Usuário

**Data:** 04/12/2025
**Prompt:** #003
**Dependências:** Relatório do Prompt #002 + Especificações em `/specifications/Especificação-Visual-e-Diretrizes-de-UX-UI.md`

---

## Contexto

A aplicação está funcional, mas a interface atual não condiz com as especificações de UX/UI definidas no brainstorming do projeto. Esta tarefa focará em implementar o design minimalista e elegante conforme documentado, incluindo a paleta de cores customizada inspirada em Moleskine.

**⚠️ IMPORTANTE:** Consulte constantemente o arquivo `/specifications/Especificação-Visual-e-Diretrizes-de-UX-UI.md` para garantir conformidade com os padrões estabelecidos.

---

## Princípios de Design a Seguir

Conforme especificação do projeto:

- ✅ **Minimalismo:** Interface limpa, menos é mais. Expor somente o necessário.
- ✅ **Consistência:** Elementos visuais recorrentes, interações previsíveis.
- ✅ **Acessibilidade:** Altos contrastes, teclas de atalho, navegação via teclado.
- ✅ **Elegância:** Layout espaçado, tipografia agradável, foco na legibilidade.

---

## Problemas Identificados pelo PO

### 1. ❌ Split Bar (Divisor de Painéis) Muito Grosso
- Barra entre File Explorer e área de edição está excessivamente grossa
- Não condiz com o estilo minimalista desejado (similar ao VSCode/Cursor IDE)
- Ícone do divisor está pixelado

### 2. ❌ Barra de Status Cortada
- Textos da barra de status estão encostados no bottom da janela
- Falta padding/margin adequado
- **Especificação:** Altura mínima, fundo sutil, informações agrupadas

### 3. ❌ Funcionalidades Inadequadas ao Escopo
- Botões/textos "COMPILE", "RUN", "EXIT" não fazem sentido para um editor de texto
- mini é focado em **edição**, não em execução de código

### 4. ❌ Tema Visual Inadequado
- Tema atual não reflete a identidade visual do mini
- Necessário implementar paleta Moleskine com opção de textura

### 5. ❌ Ícones de Pastas/Arquivos Inadequados
- **Especificação:** SVG line icons, estética "outlined", baixa saturação
- Ícones atuais não são modernos ou bonitos

---

## PALETA DE CORES CUSTOMIZADA (ESTILO MOLESKINE)

### Cores de Fundo Aprovadas pelo PO

O tema padrão será **GitHub Light Default** com adaptações de cor de fundo inspiradas em papel Moleskine:

#### Opção 1: Moleskine Ivory (⭐ PADRÃO RECOMENDADO)
- **Hex:** `#F6EEE3`
- **RGB:** `rgb(246, 238, 227)`
- **Descrição:** Tom marfim suave, acolhedor, amarelo pálido quase imperceptível
- **Uso:** Cor de fundo principal do editor

#### Opção 2: Perplexity Inspired
- **Hex:** `#FCFCF9`
- **RGB:** `rgb(252, 252, 249)`
- **Descrição:** Off-white muito sutil, clean

#### Opção 3: Claude Inspired
- **Hex:** `#FAF9F5`
- **RGB:** `rgb(250, 249, 245)`
- **Descrição:** Bege muito claro, elegante

#### Opção 4: Midori Paper
- **Hex:** `#EFEBD F`
- **RGB:** `rgb(239, 235, 223)`
- **Descrição:** Tom médio entre Moleskine e papel comum

#### Opção 5: Vintage Paper
- **Hex:** `#E0D3AF`
- **RGB:** `rgb(224, 211, 175)`
- **Descrição:** Tom de papel envelhecido, mais escuro

### Cores Complementares (para uso com fundo Moleskine)

**Texto principal:**
- Cor: `#2C2416` (marrom escuro quente, bom contraste)
- Fallback: `#1F2937` (cinza escuro neutro)

**Texto secundário (rodapé, paths):**
- Cor: `#6B5E4F` (marrom médio)
- Fallback: `#6B7280` (cinza médio)

**Bordas e divisores:**
- Cor: `#E5DDD0` (bege suave)
- Fallback: `#E5E7EB` (cinza claro)

**Acentos (links, highlights):**
- Manter: `#3484F7` (azul suave - contrasta bem com marfim)

**Hover states:**
- Background: `#eceadf` (um tom mais escuro que o fundo Moleskine)

---

## Objetivos desta Tarefa

### 1. Refinar Split Bar (Divisor de Painéis)

**Ações:**

- Reduzir largura da barra divisória para **1-2px** (padrão minimalista)
- Usar ícone sutil ou nativo do Windows para resize handle
- Aplicar hover state: aumentar para 3-4px ou mudança de cor ao passar mouse
- **Cor do divisor:** `#E5DDD0` (bege suave), hover com `#3484F7` (azul)
- Cursor apropriado: `col-resize`

**Código CSS sugerido:**
```
.Resizer {
  background: #E5DDD0;
  width: 1px;
  cursor: col-resize;
  transition: all 150ms ease;
}

.Resizer:hover {
  background: #3484F7;
  width: 2px;
}
```

**Resultado Esperado:**
- Divisor fino, discreto e elegante
- Transição suave (<300ms conforme especificação)
- Resposta visual imediata ao hover

---

### 2. Corrigir Barra de Status (Rodapé)

**Ações:**

Implementar conforme especificação do projeto:
- **Altura:** Mínima, sem excesso
- **Fundo:** Usar cor Moleskine `#F6EEE3`
- **Padding:** `4px 12px` (garantir que textos não toquem bordas)
- **Conteúdo:** Encoding, posição do cursor (linha/coluna), caminho do arquivo, status
- **Tipografia:** 12-13px, fonte do sistema
- **Cor do texto:** `#6B5E4F` (marrom médio)

**Código CSS sugerido:**
```
.status-bar {
  background: #F6EEE3;
  border-top: 1px solid #E5DDD0;
  padding: 4px 12px;
  min-height: 24px;
  display: flex;
  align-items: center;
  gap: 16px;
  font-size: 12px;
  color: #6B5E4F;
}
```

**Resultado Esperado:**
- Barra de status discreta e funcional
- Informações essenciais bem organizadas
- Sem textos cortados ou encostados

---

### 3. Remover Funcionalidades Fora do Escopo

**Ações:**

- **Remover completamente:**
  - Botão/menu/texto "COMPILE"
  - Botão/menu/texto "RUN"
  - Botão/menu/texto "EXIT" (fechar pode ficar no menu Window padrão)
  - Qualquer referência a execução/compilação de scripts

- **Manter apenas (conforme especificação):**
  - File Explorer (painel lateral)
  - Editor de texto (área central com Monaco)
  - Barra de abas (no topo, ~36px altura)
  - Barra de status (rodapé)
  - Menus padrão: File, Edit, View, Window, Help

**Resultado Esperado:**
- Interface focada exclusivamente em edição de texto
- Sem referências a IDE ou execução de código
- Experiência limpa e direta

---

### 4. Implementar Tema Moleskine Light

**Ações:**

**A. Instalar dependências:**
```
npm install monaco-themes
```

**B. Criar tema customizado Moleskine Light:**

```
import * as monaco from 'monaco-editor';

monaco.editor.defineTheme('moleskine-light', {
  base: 'vs',
  inherit: true,
  rules: [
    { token: 'comment', foreground: '6B5E4F', fontStyle: 'italic' },
    { token: 'keyword', foreground: '8B4513', fontStyle: 'bold' },
    { token: 'string', foreground: '2E7D32' },
    { token: 'number', foreground: '1565C0' },
    { token: 'type', foreground: '6A1B9A' },
    { token: 'function', foreground: '00695C' },
    { token: 'variable', foreground: '2C2416' },
  ],
  colors: {
    'editor.background': '#F6EEE3',
    'editor.foreground': '#2C2416',
    'editor.lineHighlightBackground': '#F0E8DB',
    'editorLineNumber.foreground': '#A89A89',
    'editorLineNumber.activeForeground': '#6B5E4F',
    'editorCursor.foreground': '#3484F7',
    'editor.selectionBackground': '#D4C4B088',
    'editor.inactiveSelectionBackground': '#D4C4B044',
    'scrollbarSlider.background': '#D4C4B088',
    'scrollbarSlider.hoverBackground': '#D4C4B0BB',
    'scrollbarSlider.activeBackground': '#D4C4B0DD',
    'editorWidget.background': '#F6EEE3',
    'editorWidget.border': '#E5DDD0',
  }
});

monaco.editor.setTheme('moleskine-light');
```

**C. Aplicar cores em outros componentes:**
- File Explorer: background `#F6EEE3`
- Barra de abas: background `#F6EEE3`
- Barra de status: background `#F6EEE3`
- Divisores/bordas: `#E5DDD0`

**D. Verificar contraste WCAG AA:**
- Usar ferramentas: WebAIM Contrast Checker ou Chrome DevTools Lighthouse
- Garantir contraste mínimo 4.5:1 entre fundo (#F6EEE3) e texto (#2C2416)

**Resultado Esperado:**
- Tema claro, acolhedor e elegante
- Cores consistentes em toda interface
- Boa legibilidade e contraste conforme WCAG AA

---

### 5. Implementar Feature: Textura de Papel Reciclado (Toggle ON/OFF)

**Requisito:** Criar um botão toggle que permita ativar/desativar textura de papel reciclado sobre o fundo, **independente do tema escolhido**.

**Ações:**

**A. Criar overlay de textura CSS:**

```
/* Textura sutil de papel reciclado */
.paper-texture-overlay {
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  pointer-events: none;
  opacity: 0;
  transition: opacity 200ms ease;
  background-image:
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 2px,
      rgba(44, 36, 22, 0.02) 2px,
      rgba(44, 36, 22, 0.02) 4px
    ),
    repeating-linear-gradient(
      90deg,
      transparent,
      transparent 2px,
      rgba(44, 36, 22, 0.015) 2px,
      rgba(44, 36, 22, 0.015) 4px
    );
  /* Adicionar ruído sutil */
  background-blend-mode: multiply;
}

.paper-texture-overlay.active {
  opacity: 1;
}

/* Alternativa com imagem PNG de textura */
.paper-texture-image {
  background-image: url('./assets/paper-texture.png');
  background-repeat: repeat;
  background-size: 200px 200px;
  opacity: 0.25;
}
```

**B. Implementar toggle na barra de status:**

- **Posição:** Barra de status (rodapé), canto direito
- **Ícone:** Pequeno ícone de textura/papel (SVG)
- **Tooltip:** "Ativar/Desativar textura de papel"
- **Estado:** Salvo nas preferências do usuário (localStorage/config)

**C. Lógica JavaScript/React:**

```
const [paperTextureEnabled, setPaperTextureEnabled] = useState(false);

// Carregar preferência salva
useEffect(() => {
  const saved = localStorage.getItem('paperTexture');
  if (saved !== null) {
    setPaperTextureEnabled(JSON.parse(saved));
  }
}, []);

// Salvar preferência
const togglePaperTexture = () => {
  const newState = !paperTextureEnabled;
  setPaperTextureEnabled(newState);
  localStorage.setItem('paperTexture', JSON.stringify(newState));
};
```

**D. Aplicar classe condicionalmente:**

```
<div className={`editor-container ${paperTextureEnabled ? 'paper-texture-overlay active' : ''}`}>
  {/* Conteúdo do editor */}
</div>
```

**Resultado Esperado:**
- Toggle funcional e intuitivo
- Textura sutil e elegante quando ativada
- Transição suave (200ms)
- Preferência persistida entre sessões
- Funciona com qualquer tema

---

### 6. Atualizar Ícones de Arquivos e Pastas

**Ações:**

Conforme especificação: **SVG line icons, estética "outlined", baixa saturação**

**A. Instalar biblioteca:**
```
npm install @vscode/codicons
# OU
npm install vscode-icons-js
```

**B. Implementar mapeamento:**
- Ícones SVG (não pixelados)
- Tamanho: **16x16px**
- Estilo: outlined, line icons
- Baixa saturação de cores

**C. Mapeamento sugerido:**
- Pastas: ícone de pasta outlined
- `.txt`: ícone de documento
- `.md`: ícone Markdown
- `.js`, `.jsx`: ícone JavaScript
- `.json`: ícone JSON
- `.css`: ícone CSS
- `.html`: ícone HTML
- `.py`: ícone Python
- `.java`: ícone Java
- Outros: ícone genérico de arquivo

**D. Exemplo de implementação:**

```
import { Codicon } from '@vscode/codicons';

const getFileIcon = (fileName) => {
  const ext = fileName.split('.').pop().toLowerCase();

  const iconMap = {
    'txt': 'file-text',
    'md': 'markdown',
    'js': 'javascript',
    'jsx': 'react',
    'json': 'json',
    'css': 'css',
    'html': 'html',
    'py': 'python',
    'java': 'java',
  };

  return iconMap[ext] || 'file';
};
```

**Resultado Esperado:**
- Ícones nítidos, modernos e consistentes
- Fácil identificação visual
- Visual profissional e minimalista

---

### 7. Implementar Barra de Abas Conforme Especificação

**Ações:**

- **Altura:** ~36px
- **Formato:** Retangular com espaçamento
- **Fundo:** Moleskine `#F6EEE3`
- **Conteúdo:** Título do arquivo + ícone opcional
- **Close:** Visível apenas ao hover
- **Aba ativa:** Highlight suave
- **Interação:** Drag-and-drop para reordenar (futuro)

**Visual CSS:**
```
.tab-bar {
  height: 36px;
  background: #F6EEE3;
  border-bottom: 1px solid #E5DDD0;
  display: flex;
  align-items: center;
  padding: 0 4px;
}

.tab {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 6px 12px;
  border-right: 1px solid #E5DDD0;
  background: #F0E8DB;
  color: #2C2416;
  cursor: pointer;
  transition: background 150ms ease;
  font-size: 13px;
}

.tab.active {
  background: #F6EEE3;
  font-weight: 500;
}

.tab:hover {
  background: #EBE3D6;
}

.tab-icon {
  width: 16px;
  height: 16px;
}

.tab-close {
  opacity: 0;
  width: 16px;
  height: 16px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 3px;
  transition: opacity 150ms ease, background 150ms ease;
}

.tab:hover .tab-close {
  opacity: 0.6;
}

.tab-close:hover {
  opacity: 1 !important;
  background: #D4C4B0;
}
```

**Resultado Esperado:**
- Barra de abas minimalista e funcional
- Transições suaves (<300ms)
- Visual consistente com tema Moleskine

---

### 8. Ajustar Painel Lateral (File Explorer)

**Ações:**

Conforme especificação:
- **Largura:** 240-320px (configurável)
- **Fundo:** Moleskine `#F6EEE3`
- **Modo:** Fixo (implementar hover/oculto em tarefas futuras)
- **Conteúdo:** Lista ou árvore de arquivos
- **Exibição:** Duas linhas por item (nome em destaque + caminho menor)
- **Busca:** Implementar campo de busca rápida (se viável)

**Visual CSS:**
```
.file-explorer {
  width: 280px;
  background: #F6EEE3;
  border-right: 1px solid #E5DDD0;
  overflow-y: auto;
  padding: 8px 0;
}

.file-explorer-header {
  padding: 8px 12px;
  font-size: 11px;
  font-weight: 600;
  color: #6B5E4F;
  text-transform: uppercase;
  letter-spacing: 0.5px;
}

.file-item {
  padding: 6px 12px;
  cursor: pointer;
  transition: background 150ms ease;
  display: flex;
  align-items: center;
  gap: 8px;
}

.file-item:hover {
  background: #F0E8DB;
}

.file-item.selected {
  background: #EBE3D6;
}

.file-icon {
  width: 16px;
  height: 16px;
  flex-shrink: 0;
}

.file-info {
  flex: 1;
  min-width: 0;
}

.file-name {
  font-size: 13px;
  font-weight: 500;
  color: #2C2416;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
}

.file-path {
  font-size: 11px;
  color: #6B5E4F;
  white-space: nowrap;
  overflow: hidden;
  text-overflow: ellipsis;
  margin-top: 2px;
}

/* Scrollbar customizada */
.file-explorer::-webkit-scrollbar {
  width: 8px;
}

.file-explorer::-webkit-scrollbar-track {
  background: transparent;
}

.file-explorer::-webkit-scrollbar-thumb {
  background: #D4C4B0;
  border-radius: 4px;
}

.file-explorer::-webkit-scrollbar-thumb:hover {
  background: #C4B4A0;
}
```

**Resultado Esperado:**
- Painel lateral limpo e organizado
- Duas linhas por arquivo (nome + caminho)
- Fácil navegação e identificação
- Visual minimalista e elegante

---

## Paleta de Temas Futuros (Roadmap)

Para implementação futura, preparar suporte a múltiplos temas mantendo sempre a opção de textura:

1. **Moleskine Light** (⭐ padrão) - #F6EEE3
2. **Perplexity Clean** - #FCFCF9
3. **Claude Warm** - #FAF9F5
4. **Pure White** - #FFFFFF
5. **Midori Paper** - #EFEBD F
6. **Vintage Paper** - #E0D3AF
7. **Dark Mode** (futuro) - #1E1E1E

Todos devem permitir toggle de textura de papel reciclado.

---

## Checklist de Execução

Marque cada item após completar:

### Split Bar
- [ ] Largura reduzida para 1-2px
- [ ] Cor #E5DDD0, hover #3484F7
- [ ] Cursor col-resize aplicado
- [ ] Transição suave (<300ms)

### Barra de Status
- [ ] Padding 4px 12px aplicado
- [ ] Fundo #F6EEE3
- [ ] Cor de texto #6B5E4F
- [ ] Informações organizadas (encoding, posição, caminho)
- [ ] Textos não encostam nas bordas
- [ ] Toggle de textura adicionado

### Remoção de Funcionalidades
- [ ] "COMPILE" removido
- [ ] "RUN" removido
- [ ] "EXIT" removido ou movido para menu Window
- [ ] Interface focada em edição

### Tema Visual Moleskine
- [ ] Monaco themes instalado
- [ ] Tema 'moleskine-light' definido
- [ ] Cor de fundo #F6EEE3 aplicada
- [ ] Cores de texto ajustadas (#2C2416, #6B5E4F)
- [ ] Bordas #E5DDD0 aplicadas
- [ ] Acentos #3484F7 aplicados
- [ ] Tema aplicado ao Monaco Editor
- [ ] Tema aplicado ao File Explorer
- [ ] Tema aplicado à barra de abas
- [ ] Tema aplicado à barra de status
- [ ] Contraste WCAG AA verificado

### Textura de Papel
- [ ] CSS de textura criado
- [ ] Toggle implementado na barra de status
- [ ] Ícone do toggle adicionado
- [ ] Tooltip "Ativar/Desativar textura de papel"
- [ ] Estado salvo em localStorage
- [ ] Transição fade 200ms implementada
- [ ] Funciona independente do tema

### Ícones
- [ ] Biblioteca @vscode/codicons instalada
- [ ] Ícones SVG outlined implementados
- [ ] Tamanho 16x16px
- [ ] Mapeamento por tipo de arquivo
- [ ] Baixa saturação

### Barra de Abas
- [ ] Altura ~36px
- [ ] Fundo #F6EEE3
- [ ] Close visível ao hover
- [ ] Highlight na aba ativa
- [ ] Visual minimalista
- [ ] Transições suaves

### Painel Lateral
- [ ] Largura 240-320px
- [ ] Fundo #F6EEE3
- [ ] Duas linhas por item (nome + caminho)
- [ ] Hover state implementado
- [ ] Scrollbar customizada
- [ ] Visual limpo

---

## Estrutura do Relatório

Crie o arquivo `/reports/report-prompt-003-YYYYMMDD.md` com:

1. **Resumo Executivo**
2. **Conformidade com Especificação UX/UI** (checklist de cada item da spec)
3. **Paleta de Cores Implementada** (cores usadas, código hex/rgb)
4. **Tema Moleskine Light** (código do tema Monaco, configuração)
5. **Mudanças no Split Bar** (código CSS, screenshots antes/depois)
6. **Mudanças na Barra de Status** (código CSS, screenshots, toggle de textura)
7. **Funcionalidades Removidas** (lista completa)
8. **Implementação da Textura de Papel** (código CSS/JS, screenshots ON/OFF)
9. **Ícones Atualizados** (biblioteca, mapeamento, exemplos)
10. **Barra de Abas** (implementação, visual, screenshots)
11. **Painel Lateral** (ajustes, visual, screenshots)
12. **Testes de Contraste WCAG** (resultados, ferramentas usadas)
13. **Screenshots Comparativos** (**OBRIGATÓRIO** - antes e depois de CADA mudança)
14. **Problemas Encontrados**
15. **Comandos Executados**
16. **Próximos Passos Sugeridos**

---

## Screenshots Obrigatórios

Incluir no relatório (TODOS obrigatórios):

1. Interface completa ANTES das mudanças
2. Interface completa DEPOIS das mudanças
3. Editor com fundo Moleskine (#F6EEE3) **SEM** textura
4. Editor com fundo Moleskine (#F6EEE3) **COM** textura de papel
5. Comparação lado a lado: antes (fundo original) vs depois (Moleskine)
6. Toggle de textura em ação (estado ON e OFF)
7. Diferentes tipos de arquivos (.txt, .md, .js) com o novo tema
8. Split bar antes e depois (close-up)
9. Barra de status antes e depois
10. Barra de abas com múltiplos arquivos abertos
11. Painel lateral (File Explorer) com ícones novos
12. Hover states (split bar, abas, painel lateral)

---

## Observações Importantes

- **SEMPRE** consulte `/specifications/Especificação-Visual-e-Diretrizes-de-UX-UI.md`
- **DOCUMENTE** todas mudanças com screenshots comparativos (antes/depois)
- **TESTE** em diferentes resoluções (mínimo 1366x768 e 1920x1080)
- **MANTENHA** animações <300ms conforme especificação
- **GARANTA** navegação por teclado funcional
- **VERIFIQUE** contraste WCAG AA com ferramentas apropriadas
- **TESTE** toggle de textura em diferentes situações
- **TESTE** tema Moleskine com diferentes tipos de arquivos
- **NÃO** adicione features além das solicitadas
- **PAUSE** se encontrar conflitos com a especificação

---

## Critérios de Aceitação

✅ Split bar fino (1-2px) com hover suave (#E5DDD0 → #3484F7)
✅ Barra de status com padding adequado, fundo #F6EEE3, toggle de textura
✅ COMPILE/RUN/EXIT removidos completamente
✅ Tema Moleskine Light (#F6EEE3) aplicado em toda interface
✅ Cores complementares aplicadas (#2C2416, #6B5E4F, #E5DDD0)
✅ Textura de papel reciclado implementada com toggle ON/OFF
✅ Toggle salvo em preferências do usuário
✅ Ícones SVG outlined, 16x16px implementados
✅ Barra de abas ~36px com close ao hover, fundo Moleskine
✅ Painel lateral 240-320px com duas linhas por item, fundo Moleskine
✅ Contraste WCAG AA verificado e aprovado
✅ **100% de conformidade com especificação UX/UI**
✅ Screenshots completos documentados (mínimo 12 imagens)

---

## Referências Técnicas

- **Especificação Principal:** `/specifications/Especificação-Visual-e-Diretrizes-de-UX-UI.md`
- **Monaco Themes:** https://github.com/brijeshb42/monaco-themes
- **VSCode Codicons:** https://microsoft.github.io/vscode-codicons/dist/codicon.html
- **React-Split:** Customizar via props e CSS
- **WCAG Contrast Checker:** https://webaim.org/resources/contrastchecker/
- **Moleskine Colors Reference:** RGB(246, 238, 227) / #F6EEE3

---

**Boa sorte! Aguardo relatório completo com conformidade 100% à especificação UX/UI e paleta Moleskine implementada.**
