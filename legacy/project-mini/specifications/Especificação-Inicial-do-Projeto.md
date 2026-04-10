# Especificação-Inicial-do-Projeto.md
## Projeto: mini (Minimalist, Intelligent, Nice Interface)
## Versão: 1.0 - 2025-11-13
## Autor: Equipe de IA (PO, Arquiteto/Supervisor, Dev Sênior)

---

## Visão Geral

O projeto **mini** tem como objetivo entregar um editor de textos moderno, minimalista, amigável e robusto, com recursos visuais inspirados no VSCode, funcionamento ágil, experiência de uso refinada e programação orientada à simplicidade, produtividade e beleza. O foco é oferecer uma solução perfeita tanto para edição simples de textos `.txt` quanto para escrita de código, sem funções de IDE, mas com suporte à sintaxe, temas e interface elegante.

---

## Escopo e Requisitos Funcionais

- Editor principal com:
  - Barra de abas minimalista (no topo) para múltiplos arquivos, similar ao VSCode
  - Rodapé detalhado: encoding do arquivo, posição do cursor, local no disco, modo de edição etc.
  - Dois esquemas de fonte, definidos por extensão do arquivo:
    - Ex.: Serif (Bookman Old Style) para `.txt`
    - Ex.: Programação (JetBrains Mono) para `.java`, `.md`, `.js`, etc.
  - Suporte pleno a temas do VSCode (ex.: Github, Claude, Perplexity) e syntax highlight para múltiplas linguagens
- **Painel lateral de listagem de arquivos abertos**:
  - Modo “lista” (Notepad++): cada arquivo aberto (independente)
  - Modo “projeto”: exibe árvore (folders/subfolders) se uma pasta for aberta
  - Cada arquivo é exibido em duas linhas (caminho completo + nome)
  - Possibilidade de fixar arquivos
  - Três modos de exibição: **fixo, oculto ou hover** (exibido apenas em mouse-over)
- System tray:
  - Minimizar/fechar para bandeja do Windows
  - Abrir janela no canto inferior direito da tela ao restaurar pelo tray (configurável)
  - Salvar posição/tamanho da janela e restaurar conforme preferência
- Configuração e sincronização:
  - Preferências salvas localmente (temas, fontes, barras, modo painel lateral, etc)
  - Sincronização opcional pelo GitHub: arquivos abertos e settings exportados para repositório privado via login/token
- Outros requisitos:
  - Interface limpa, fundo claro, visual “friendly”
  - Altíssima agilidade para abrir, salvar e alternar arquivos
  - Otimizado para uso em telas grandes e setups multi-monitor

---

## Regras de Interface

- Nome “mini” sempre em minúsculo em toda a interface e documentação
- Superfícies e espaços amplos, apenas detalhes essenciais visíveis por padrão
- O painel lateral pode ser configurado pelo usuário (fixo, oculto, hover)
- Abas devem ser simples, de fácil navegação, sem excesso de detalhes
- Feedback visual imediato para ações como salvar, abrir, fechar arquivo
- Rodapé deve ser discreto, mas detalhado quanto ao status do documento aberto

---

## Notas Técnicas e Arquitetura Sugerida

- Electron para desktop (Windows)
- Monaco Editor para edição e highlighting
- Ecossistema Node.js com suporte a sincronização via API GitHub
- Styled Components ou CSS-in-JS para temas (ou mesmo suporte nativo aos temas VSCode)
- Tray e gerenciamento de janelas pela API Electron
- Estrutura de arquivos baseada em workspace para alternância entre modo lista/projeto

---

## Próximos Passos

- Aprovação desta especificação inicial pelo PO
- Detalhamento dos fluxos de uso e requisitos UX/UI
- Elaboração da arquitetura técnica detalhada (diagramas, padrões)
- Prototipação visual das telas-chave

---

*Documento sujeito a revisões e incrementos conforme evolução do projeto.*
