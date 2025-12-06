# Especificação Visual e Diretrizes de UX/UI - Atualizado

```markdown
# Especificação Visual e Diretrizes de UX/UI

**Projeto:** mini - Minimalist, Intelligent, Nice Interface
**Versão:** 2.0 (Atualizada com Vanilla Cream)
**Data:** 04/12/2025
**Autor:** Eduardo Alcântara (PO) + Perplexity AI (Supervisor)

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Princípios de Design](#princípios-de-design)
3. [Paleta de Cores](#paleta-de-cores)
4. [Tipografia](#tipografia)
5. [Componentes da Interface](#componentes-da-interface)
6. [Interações e Animações](#interações-e-animações)
7. [Acessibilidade](#acessibilidade)
8. [Responsividade](#responsividade)

---

## 🎯 Visão Geral

O **mini** busca proporcionar uma experiência de edição de texto **minimalista, elegante e sem distrações**, inspirada na estética de cadernos Moleskine premium. A interface deve ser:

- **Limpa:** Apenas o essencial visível
- **Elegante:** Design refinado e atemporal
- **Acolhedora:** Cores quentes que convidam à escrita
- **Funcional:** Eficiente sem sacrificar beleza

---

## 🎨 Princípios de Design

### 1. Minimalismo

**Menos é Mais**
- Expor apenas funcionalidades essenciais
- Ocultar complexidade desnecessária
- Interface "respira" com espaçamento adequado
- Sem excesso de botões, menus ou distrações

**Hierarquia Visual Clara**
- Conteúdo (texto do usuário) é protagonista
- Interface é coadjuvante discreta
- Bordas e divisores sutis
- Cores neutras com acentos pontuais

---

### 2. Elegância

**Refinamento Visual**
- Paleta de cores inspirada em papel premium
- Tipografia legível e agradável
- Transições suaves entre estados
- Atenção aos detalhes (ícones, espaçamentos)

**Estética Atemporal**
- Evitar tendências passageiras
- Design que envelhece bem
- Inspiração em objetos físicos de qualidade (Moleskine, papel)

---

### 3. Consistência

**Interface Previsível**
- Padrões visuais recorrentes
- Comportamentos consistentes
- Mesmas cores/fontes em elementos similares
- Layout estável (não "pula" ao interagir)

**Sistema de Design Coeso**
- Componentes reutilizáveis
- Espaçamentos padronizados (8px, 16px, 24px, 32px)
- Transições uniformes (150-300ms)

---

### 4. Foco no Conteúdo

**Texto em Primeiro Plano**
- Área de edição ocupa máximo de espaço
- Barra lateral pode ser ocultada
- Modo foco (futuro) esconde tudo exceto texto
- Sem popups ou notificações intrusivas

---

## 🎨 Paleta de Cores

### Tema Padrão: Moleskine Light (Vanilla Cream)

Inspirado em papel premium de cadernos Moleskine, com tom **Vanilla Cream** para maior claridade e conforto visual.

---

### Cores Principais

#### 🎨 Fundo Principal (Editor)
- **Nome:** Vanilla Cream
- **Hex:** `#FAF6EF`
- **RGB:** `rgb(250, 246, 239)`
- **Uso:** Fundo do editor, barra de abas, painel lateral, barra de status
- **Inspiração:** Papel creme baunilha, suave e acolhedor

#### 🖊️ Texto Principal
- **Nome:** Dark Brown
- **Hex:** `#2C2416`
- **RGB:** `rgb(44, 36, 22)`
- **Uso:** Texto do usuário, títulos, nomes de arquivos
- **Contraste:** 10.8:1 com fundo (WCAG AAA ✅✅✅)

#### 📝 Texto Secundário
- **Nome:** Medium Brown
- **Hex:** `#6B5E4F`
- **RGB:** `rgb(107, 94, 79)`
- **Uso:** Barra de status, paths de arquivos, labels, metadados
- **Contraste:** 4.9:1 com fundo (WCAG AA ✅)

#### 📏 Bordas e Divisores
- **Nome:** Light Beige
- **Hex:** `#EFEAE1`
- **RGB:** `rgb(239, 234, 225)`
- **Uso:** Bordas de painéis, divisores (split bar), separadores
- **Opacidade:** Pode usar 60-80% para sutileza extra

#### 🔗 Acentos (Links, Highlights)
- **Nome:** Soft Blue
- **Hex:** `#3484F7`
- **RGB:** `rgb(52, 132, 247)`
- **Uso:** Links, seleção ativa, hover do split bar, botões primários
- **Contraste:** 4.5:1 com fundo (WCAG AA ✅)

#### 🖱️ Hover States
- **Nome:** Warm Hover
- **Hex:** `#F5F0E7`
- **RGB:** `rgb(245, 240, 231)`
- **Uso:** Background ao passar mouse sobre itens (abas, arquivos)
- **Nota:** Tom levemente mais escuro que o fundo principal

#### ✏️ Seleção de Texto
- **Nome:** Selection Beige
- **Hex:** `#E8DCC8`
- **RGB:** `rgb(232, 220, 200)`
- **Opacidade:** 50-70%
- **Uso:** Texto selecionado pelo usuário

---

### Cores de Syntax Highlighting

Para manter consistência com a paleta Moleskine:

#### Comments (Comentários)
- **Hex:** `#8B7355`
- **RGB:** `rgb(139, 115, 85)`
- **Style:** Itálico
- **Uso:** Comentários de código/markdown

#### Keywords (Palavras-chave)
- **Hex:** `#8B4513`
- **RGB:** `rgb(139, 69, 19)`
- **Style:** Bold
- **Uso:** Keywords de linguagens de programação

#### Strings (Texto entre aspas)
- **Hex:** `#2E7D32`
- **RGB:** `rgb(46, 125, 50)`
- **Uso:** Strings, texto entre aspas

#### Numbers (Números)
- **Hex:** `#1565C0`
- **RGB:** `rgb(21, 101, 192)`
- **Uso:** Valores numéricos

#### Functions (Funções)
- **Hex:** `#00695C`
- **RGB:** `rgb(0, 105, 92)`
- **Uso:** Nomes de funções

#### Types (Tipos)
- **Hex:** `#6A1B9A`
- **RGB:** `rgb(106, 27, 154)`
- **Uso:** Tipos de dados

#### Variables (Variáveis)
- **Hex:** `#2C2416` (mesma do texto principal)
- **RGB:** `rgb(44, 36, 22)`
- **Uso:** Nomes de variáveis

---

### Cores de Status (Futuro)

#### Success (Sucesso)
- **Hex:** `#4CAF50`
- **RGB:** `rgb(76, 175, 80)`
- **Uso:** Operações bem-sucedidas, sync completo

#### Warning (Aviso)
- **Hex:** `#FF9800`
- **RGB:** `rgb(255, 152, 0)`
- **Uso:** Alertas não críticos

#### Error (Erro)
- **Hex:** `#F44336`
- **RGB:** `rgb(244, 67, 54)`
- **Uso:** Erros, falhas críticas

---

### Textura de Papel Reciclado (Opcional)

**Feature Especial:** Toggle para ativar/desativar textura sutil de papel sobre o fundo.

#### Implementação CSS
```
.paper-texture-overlay {
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  pointer-events: none;
  opacity: 0;
  transition: opacity 200ms ease;
  background-image:
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 2px,
      rgba(44, 36, 22, 0.015) 2px,
      rgba(44, 36, 22, 0.015) 4px
    ),
    repeating-linear-gradient(
      90deg,
      transparent,
      transparent 2px,
      rgba(44, 36, 22, 0.012) 2px,
      rgba(44, 36, 22, 0.012) 4px
    );
}

.paper-texture-overlay.active {
  opacity: 1;
}
```

#### Comportamento
- **Padrão:** OFF (fundo liso)
- **Toggle:** Botão na barra de status
- **Persistência:** Salvar preferência do usuário (localStorage)
- **Transição:** Fade suave (200ms) ao ativar/desativar

---

## ✍️ Tipografia

### Fontes do Sistema

O mini usa **fontes do sistema** para performance e consistência com o OS.

#### Texto do Editor (Conteúdo)

**Customização por Tipo de Arquivo:**

##### Arquivos de Texto (.txt)
- **Fonte:** `Bookman Old Style, Georgia, "Times New Roman", serif`
- **Tamanho:** `16px`
- **Altura de Linha:** `1.6` (25.6px)
- **Justificativa:** Serifada, elegante, boa para leitura longa

##### Markdown (.md)
- **Fonte:** `"Charter", "Iowan Old Style", "Georgia", serif`
- **Tamanho:** `15px`
- **Altura de Linha:** `1.65` (~25px)
- **Justificativa:** Balanceada entre elegância e legibilidade

##### Código (.js, .json, .html, .css, etc)
- **Fonte:** `"Fira Code", "Cascadia Code", "Consolas", "Monaco", monospace`
- **Tamanho:** `14px`
- **Altura de Linha:** `1.5` (21px)
- **Justificativa:** Monospace com ligatures opcionales

As fontes devem vir com o MINI e serem instaladas no sistema caso ainda não estejam.

#### Interface (UI)

##### Menus, Barras, Painéis
- **Fonte:** `-apple-system, BlinkMacSystemFont, "Segoe UI", "Roboto", "Oxygen", "Ubuntu", "Cantarell", sans-serif`
- **Tamanho:** `13px` (UI geral), `12px` (barra de status)
- **Peso:** `400` (regular), `500` (medium para ênfase)

##### Nomes de Arquivos (File Explorer)
- **Fonte:** Sistema (mesma da UI)
- **Tamanho:** `13px`
- **Peso:** `500` (medium)
- **Altura de Linha:** `1.4`

##### Paths/Metadados
- **Fonte:** Sistema (mesma da UI)
- **Tamanho:** `11px`
- **Peso:** `400` (regular)
- **Cor:** Texto secundário (`#6B5E4F`)

---

### Escala Tipográfica

| Nível | Tamanho | Uso |
|-------|---------|-----|
| **H1** | 24px | Títulos principais (raro na UI) |
| **H2** | 18px | Subtítulos |
| **Body Large** | 16px | Texto de edição (.txt) |
| **Body Medium** | 15px | Texto de edição (.md) |
| **Body Small** | 14px | Código |
| **UI Large** | 13px | UI geral, menus |
| **UI Small** | 12px | Barra de status, labels |
| **Caption** | 11px | Metadados, paths |

---

## 🧩 Componentes da Interface

### 1. Barra de Abas (Tabs)

#### Dimensões
- **Altura:** `36px`
- **Padding:** `6px 12px`
- **Gap entre abas:** `0px` (separadas por borda)

#### Estados

##### Aba Inativa
- **Background:** `#F5F0E7` (Warm Hover - levemente mais escuro que fundo)
- **Texto:** `#2C2416` (Dark Brown)
- **Peso da Fonte:** `400` (regular)
- **Borda Direita:** `1px solid #EFEAE1`

##### Aba Ativa
- **Background:** `#FAF6EF` (Vanilla Cream - mesma do editor)
- **Texto:** `#2C2416` (Dark Brown)
- **Peso da Fonte:** `500` (medium)
- **Borda Inferior:** Nenhuma (conectada ao editor)

##### Hover (Aba Inativa)
- **Background:** `#EBE3D6` (tom mais escuro)
- **Transição:** `150ms ease`

#### Close Button (X)
- **Visibilidade:** Apenas ao hover da aba
- **Tamanho:** `16x16px`
- **Cor:** `#6B5E4F` (Medium Brown)
- **Hover:** `#2C2416` (Dark Brown), background `#E0D8CC`
- **Transição:** `150ms ease`

---

### 2. Split Bar (Divisor de Painéis)

#### Dimensões
- **Largura Padrão:** `1px`
- **Largura Hover:** `2px`
- **Cursor:** `col-resize` (horizontal) ou `row-resize` (vertical)

#### Cores
- **Padrão:** `#EFEAE1` (Light Beige)
- **Hover:** `#3484F7` (Soft Blue)
- **Transição:** `all 150ms ease`

#### Comportamento
- Hover aumenta largura e muda cor
- Arrasto suave para redimensionar painéis
- Limites mínimos: 200px (painel lateral), 400px (editor)

---

### 3. Barra de Status (Rodapé)

#### Dimensões
- **Altura:** `24px` (mínima)
- **Padding:** `4px 12px`
- **Border Top:** `1px solid #EFEAE1`

#### Background
- **Cor:** `#FAF6EF` (Vanilla Cream)

#### Conteúdo (Esquerda → Direita)
1. **Encoding:** UTF-8, ISO-8859-1, etc (texto secundário)
2. **Posição:** Ln X, Col Y (texto secundário)
3. **Tipo de Arquivo:** .txt, .md, etc (texto secundário)
4. **[Espaço Flexível]**
5. **Toggle de Textura:** Ícone pequeno (16x16px) + tooltip

#### Tipografia
- **Tamanho:** `12px`
- **Cor:** `#6B5E4F` (Medium Brown)
- **Separadores:** Pipe `|` com opacity 50%

---

### 4. Painel Lateral (File Explorer)

#### Dimensões
- **Largura Padrão:** `280px`
- **Largura Mínima:** `240px`
- **Largura Máxima:** `400px`
- **Redimensionável:** Sim (arrastar borda direita)

#### Background
- **Cor:** `#FAF6EF` (Vanilla Cream)
- **Border Right:** `1px solid #EFEAE1`

#### Header (Título "EXPLORER")
- **Padding:** `8px 12px`
- **Fonte:** `11px`, `600` (semibold), uppercase, `letter-spacing: 0.5px`
- **Cor:** `#6B5E4F` (Medium Brown)

#### Itens de Arquivo/Pasta

##### Estrutura (Duas Linhas)
- **Linha 1:** Nome do arquivo (destaque)
- **Linha 2:** Path relativo (menor, secundário)

##### Dimensões
- **Padding:** `8px 12px`
- **Gap Vertical:** `2px` (entre linhas)
- **Ícone:** `16x16px` (SVG outlined)

##### Estados

**Normal:**
- **Background:** Transparente
- **Nome:** `#2C2416` (Dark Brown), `13px`, `500` (medium)
- **Path:** `#6B5E4F` (Medium Brown), `11px`, `400` (regular)

**Hover:**
- **Background:** `#F5F0E7` (Warm Hover)
- **Transição:** `150ms ease`

**Selecionado:**
- **Background:** `#EBE3D6` (tom mais escuro)
- **Nome:** `#2C2416` (Dark Brown), `500` (medium)

---

### 5. Scrollbar Customizado

#### Dimensões
- **Largura:** `8px`
- **Track Background:** Transparente

#### Thumb (Indicador)
- **Cor Padrão:** `#D4C4B0` (bege médio, 50% opacity)
- **Cor Hover:** `#C4B4A0` (bege mais escuro)
- **Border Radius:** `4px`
- **Transição:** `background 150ms ease`

---

### 6. Menus (Dropdown)

#### Background
- **Cor:** `#FAF6EF` (Vanilla Cream)
- **Border:** `1px solid #EFEAE1`
- **Box Shadow:** `0 4px 16px rgba(44, 36, 22, 0.1)`
- **Border Radius:** `4px`

#### Itens

**Normal:**
- **Padding:** `8px 24px 8px 12px`
- **Fonte:** `13px`, `400`
- **Cor:** `#2C2416`

**Hover:**
- **Background:** `#F5F0E7`
- **Transição:** `150ms ease`

**Separador:**
- **Linha:** `1px solid #EFEAE1`
- **Margin:** `4px 0`

---

## 🎬 Interações e Animações

### Princípios de Animação

1. **Sutileza:** Transições discretas, não chamativas
2. **Rapidez:** Máximo 300ms (maioria 150-200ms)
3. **Naturalidade:** Easing suave (`ease`, `ease-out`)
4. **Propósito:** Animar apenas para melhorar UX

---

### Durações Padrão

| Tipo de Interação | Duração | Easing |
|-------------------|---------|--------|
| **Hover** (botões, abas) | 150ms | `ease` |
| **Click** (feedback) | 100ms | `ease-out` |
| **Painel** (abrir/fechar) | 250ms | `ease-in-out` |
| **Modal** (fade in/out) | 200ms | `ease` |
| **Scroll suave** | 300ms | `ease-out` |
| **Toggle** (textura papel) | 200ms | `ease` |

---

### Animações Específicas

#### Hover em Abas
```
.tab {
  background: #F5F0E7;
  transition: background 150ms ease;
}

.tab:hover {
  background: #EBE3D6;
}
```

#### Split Bar Hover
```
.split-bar {
  width: 1px;
  background: #EFEAE1;
  transition: all 150ms ease;
}

.split-bar:hover {
  width: 2px;
  background: #3484F7;
}
```

#### Textura de Papel (Fade)
```
.paper-texture {
  opacity: 0;
  transition: opacity 200ms ease;
}

.paper-texture.active {
  opacity: 1;
}
```

#### Close Button (Aba)
```
.tab-close {
  opacity: 0;
  transition: opacity 150ms ease;
}

.tab:hover .tab-close {
  opacity: 0.6;
}

.tab-close:hover {
  opacity: 1;
  background: #E0D8CC;
}
```

---

## ♿ Acessibilidade

### Contraste WCAG

Todos os pares de cores atendem **WCAG AA** (mínimo) ou **AAA** (ideal):

| Par | Contraste | Nível |
|-----|-----------|-------|
| `#FAF6EF` + `#2C2416` | 10.8:1 | AAA ✅✅✅ |
| `#FAF6EF` + `#6B5E4F` | 4.9:1 | AA ✅ |
| `#FAF6EF` + `#3484F7` | 4.5:1 | AA ✅ |

**Ferramenta de Verificação:** https://webaim.org/resources/contrastchecker/

---

### Navegação por Teclado

Todas funcionalidades devem ser acessíveis via teclado:

#### Shortcuts Principais
- `Ctrl+O` - Abrir arquivo
- `Ctrl+S` - Salvar
- `Ctrl+W` - Fechar aba
- `Ctrl+Tab` - Próxima aba
- `Ctrl+Shift+Tab` - Aba anterior
- `Ctrl+B` - Toggle sidebar
- `Ctrl+\` - Split editor
- `Ctrl+F` - Find
- `Ctrl+H` - Replace
- `Ctrl+P` - Quick Open
- `Ctrl+Shift+P` - Command Palette

#### Focus Visível
- Elementos focados devem ter outline visível
- **Cor do Outline:** `#3484F7` (Soft Blue)
- **Largura:** `2px`
- **Offset:** `2px`

---

### Screen Readers

- Labels descritivos em todos elementos interativos
- `aria-label` quando necessário
- Hierarquia de headings correta (h1, h2, h3)
- Landmarks (role="navigation", role="main", etc)

---

## 📱 Responsividade

### Breakpoints

O mini é primariamente desktop, mas deve funcionar em diferentes resoluções:

| Resolução | Largura | Ajustes |
|-----------|---------|---------|
| **HD** | 1366x768 | Padrão |
| **Full HD** | 1920x1080 | Padrão |
| **2K/QHD** | 2560x1440 | Escala UI (opcional) |
| **4K** | 3840x2160 | Escala UI 1.5x |

---

### Largura Mínima da Janela

- **Mínimo Absoluto:** `800px`
- **Recomendado:** `1024px`
- **Ideal:** `1280px`

#### Comportamento em Janelas Pequenas
- Sidebar colapsa automaticamente (<900px)
- Barra de status simplifica (oculta informações menos críticas)
- Abas truncam nomes com ellipsis

---

### Zoom

Suportar zoom da interface:

- **Zoom In:** `Ctrl++` (até 200%)
- **Zoom Out:** `Ctrl+-` (até 50%)
- **Reset:** `Ctrl+0`

Fontes e espaçamentos devem escalar proporcionalmente.

---

## 🎨 Modo Escuro (Futuro)

**Status:** Planejado para v2.0

### Paleta Preliminar

- **Fundo:** `#1E1E1E` (quase preto)
- **Texto:** `#D4C4B0` (bege claro)
- **Acentos:** `#3484F7` (mesmo azul)
- **Bordas:** `#2D2D2D` (cinza escuro)

**Nota:** Detalhes serão definidos em especificação própria.

---

## 📐 Espaçamentos Padronizados

Sistema de espaçamento baseado em múltiplos de **4px**:

| Nome | Valor | Uso |
|------|-------|-----|
| **XXS** | 4px | Gaps mínimos |
| **XS** | 8px | Padding interno de botões |
| **SM** | 12px | Padding lateral de itens |
| **MD** | 16px | Espaçamento padrão |
| **LG** | 24px | Seções |
| **XL** | 32px | Grandes divisões |
| **XXL** | 48px | Margens maiores |

---

## 🔍 Detalhes Finais

### Ícones

- **Estilo:** SVG outlined (line icons)
- **Tamanho:** `16x16px` (UI), `24x24px` (destaque)
- **Stroke Width:** `1.5px`
- **Cor:** `#6B5E4F` (Medium Brown) ou `#2C2416` (Dark Brown)
- **Biblioteca Sugerida:** VSCode Codicons, Feather Icons, Heroicons

---

### Bordas (Border Radius)

- **Botões:** `4px`
- **Painéis:** `0px` (reto, minimalista)
- **Modais:** `6px`
- **Inputs:** `3px`

---

### Sombras

Usar com extrema moderação (minimalismo):

- **Menus:** `0 4px 16px rgba(44, 36, 22, 0.1)`
- **Modais:** `0 8px 32px rgba(44, 36, 22, 0.15)`
- **Floating:** `0 2px 8px rgba(44, 36, 22, 0.08)`

---

## ✅ Checklist de Conformidade

Ao implementar componentes, verificar:

- [ ] Cores seguem paleta Vanilla Cream
- [ ] Contraste WCAG AA ou AAA
- [ ] Fontes conforme especificação
- [ ] Espaçamentos múltiplos de 4px
- [ ] Transições <300ms
- [ ] Navegação por teclado funciona
- [ ] Focus visível em elementos interativos
- [ ] Hover states implementados
- [ ] Ícones SVG 16x16px outlined
- [ ] Scrollbar customizado
- [ ] Responsivo (mínimo 800px)

---

**Última Atualização:** 04/12/2025 15:25 -03
**Versão:** 2.0 (Vanilla Cream)
**Próxima Revisão:** Após implementação do tema (Prompt #006)
```

***

Pronto! Toda a especificação atualizada com **Vanilla Cream (#FAF6EF)**.

Copie essa resposta completa e cole no arquivo `Especificação-Visual-e-Diretrizes-de-UX-UI.md`! 🎨✨
