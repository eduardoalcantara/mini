# Especificação-Visual-e-Diretrizes-de-UX-UI.md
## Projeto: mini (Minimalist, Intelligent, Nice Interface)
## Versão: 1.0 - 2025-11-13
## Autor: Equipe de IA (PO, Arquiteto/Supervisor, Dev Sênior)

---

## Princípios de Design

- **Minimalismo:** Interface limpa, menos é mais. Expor somente o necessário, sem ruído visual.
- **Consistência:** Elementos visuais recorrentes, interações previsíveis, padrões sólidos.
- **Acessibilidade:** Altos contrastes, teclas de atalho, navegação eficiente via teclado.
- **Elegância:** Layout espaçado, tipografia agradável, foco na legibilidade.

---

## Layout Geral

- **Barra de abas no topo:** Altura reduzida (~36px), abas com formato retangular e espaçamento. Exibe título, ícone opcional, close visível ao hover.
- **Painel lateral (fixo, oculto ou hover):** Largura configurável (~240–320px). Nas opções “oculto” e “hover”, transições suaves baseadas em movimento do mouse na borda. Exibe lista ou árvore de arquivos, duas linhas por item (nome em destaque, caminho menor).
- **Área central (editor):** Ocupa sempre o máximo possível, bordas bem definidas. Linhas/colunas/espacamento respeitam os padrões do Monaco para clareza.
- **Rodapé:** Altura mínima, fundo sutil (cinza claro), informações agrupadas (encoding, posição, status, caminho do arquivo).
- **Tray e menus contextuais:** Ícone amigável, menus acessíveis, temas respeitados.

---

## Temas, Cores e Tipografia

- **Tema padrão:** Claro, leve, inspirado em GitHub, Claude ou Perplexity.
- **Cores principais:** Branco (#FFFFFF), cinza claro (#F7F8FA), azul suave (#3484F7), detalhes em cinzas intermediários e ícones suaves.
- **Tipografia:** 
  - `.txt`: Serif (Bookman Old Style, fallback Georgia/Times New Roman)
  - Códigos: JetBrains Mono, fallback Consolas/Fira Mono
  - Tamanhos: 15–17px para texto, 13–14px para código
- **Ícones:** SVG line icons, estética “outlined”, baixa saturação.

---

## Interação e Navegabilidade

- **Barra de abas:** 
  - Abas reordenáveis por drag-and-drop
  - Close ao passar o mouse, highlight suave na aba ativa
  - Botão de “nova aba” e menu extra opcional (somente quando janela >4 abas)
- **Painel lateral:**
  - Permite busca rápida/destaque de arquivos
  - Responde a atalhos (Ctrl+B para ocultar/exibir)
  - Hover com fade-in/out animado em 200ms
- **Editor:**
  - Syntax highlight suave, cores fiéis aos temas VSCode selecionados
  - Seleção com borda/fundo sutil
  - Números de linha opcionais e com baixo contraste
  - Scrollbar estilizada (fina, leve)

---

## Feedback Visual e Estados

- **Salvo/modificado:** Ponto indicador na aba e transição rápida ao salvar
- **Seleção de modo do painel lateral:** Feedback visual direto (animação suave em estado ativo)
- **Erro/alerta:** Mensagens leves, backgrounds tons pastéis com ícone neutro
- **Ações do tray:** Animação de entrada e saída do editor a partir da bandeja, feedback visual ao restaurar

---

## Acessibilidade e Usabilidade

- Navegação por teclado total (atalhos customizáveis)
- Alto contraste disponível via configuração
- Foco visível em todos componentes interativos
- Tooltips breves e explicativos ao passar mouse em funções principais

---

## Animações e Microinterações

- Fade-in/out para todas as transições do painel lateral
- Bounce discreto no botão de nova aba
- Delays mínimos para não comprometerperformance (todas animações <300ms)
- Animações respeitam preferências do usuário por “reduzir movimento”

---

## Responsividade e Multi-Tela

- Layout se adapta para tamanhos de janela compactos sem perder legibilidade
- Informação relevante sempre visível mesmo em modo janela pequena (barra de status encolhe, painel lateral expande/oculta)
- Suporte a múltiplos monitores sem bugs visuais

---

## Observações Finais

- Visual sempre prioriza clareza e produtividade
- Documentação de estilos mantida separada, baseada em tokens para facilitar alterações rápidas de temas e fontes
- Interface preparada para receber temas adicionais e expandir pontos de personalização

---

*Documento sujeito a revisões e incrementos conforme evolução do projeto.*
