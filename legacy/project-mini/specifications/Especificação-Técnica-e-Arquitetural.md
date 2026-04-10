# Especificação-Técnica-e-Arquitetural.md
## Projeto: mini (Minimalist, Intelligent, Nice Interface)
## Versão: 1.0 - 2025-11-13
## Autor: Equipe de IA (PO, Arquiteto/Supervisor, Dev Sênior)

---

## Stack Tecnológica

- **Electron**: Shell de desktop para integração web/native no Windows.
- **React**: UI modular, gerência de estado com hooks/context.
- **Monaco Editor**: Componente de edição de texto/código com suporte a temas VSCode e syntax highlight.
- **Recoil**: Gerência de estado global para arquivos abertos, configurações, etc.
- **@emotion/react**: Styled Components (temas, personalização visual reativa).
- **Material-UI**: Componentes ready-made para partes onde cabível.
- **Node.js**: Backend local, integração com APIs (como GitHub).
- **Electron APIs**: Manipulação de janela, tray, file system e nativo do SO.
- **GitHub API**: Sincronização segura de arquivos/settings, via OAuth/token pessoal.

---

## Estrutura Sugerida de Pastas

```
/mini
 |--/public              # Assets estáticos, ícones, imagens, manifest
 |--/src
 |    |--/components     # Componentes React (Abas, Painel lateral, Rodapé, Editor, etc)
 |    |--/editor         # Monaco configuration, themes, fontes customizadas
 |    |--/hooks          # Hooks customizados para UX, configurações, sincronização
 |    |--/state          # Árvore e contexto do Recoil
 |    |--/utils          # Funções de integração com Electron, GitHub, File IO
 |    |--/styles         # Temas, CSS customizados
 |    |--/main           # Entrypoint Electron (main.js, app initialization)
 |--package.json
 |--README.md
 |--LICENSE
```

---

## Componentes Principais

- **Barra de abas:** Lista, alterna e fecha arquivos abertos de maneira minimalista.
- **Painel lateral:** Modo lista/árvore, exibição dois níveis, modo fixo/oculto/hover.
- **Editor Monaco:** Ajuste dinâmico de fonte por extensão, tema, highlight por linguagem.
- **Rodapé:** Display de encoding, linha/coluna, path, modo edição.
- **Trayicon:** Login/logout, ação para restaurar janela, contexto de opções rápidas.
- **Configurações:** Preferências salvas local/GitHub, painel modal para ajustes.

---

## Integrações e APIs

- **Electron window management:** Posição/tamanho da janela, minimização/restauração, eventos para tray.
- **Electron tray:** Context menu, restauração do editor no canto da tela, ícone customizado.
- **File System:** Abertura/mapeamento de arquivos e pastas, monitoração.
- **GitHub OAuth:** Autenticação via token/login, push/pull de arquivos/settings em repositório privado.
- **Monaco Editor:** Carregamento de temas, associações de syntax highlight, customização de fontes.

---

## Padrões e Diretrizes de Código

- Utilizar **hooks** para lógica de UI/estado.
- Separação clara de responsabilidade entre os componentes React.
- Estrutura “container/presenter” para componentes complexos.
- APIs devem ser testadas e desacopladas do front-end.
- Testes unitários obrigatórios para hooks e funções utilitárias.
- Documentação de componentes e funções em JSDoc.

---

## Evolução e Testes

- **Testes unitários:** Jest para funções lógicas e hooks.
- **Testes de integração:** Cypress para validação dos fluxos principais do editor.
- **Lint:** ESLint e Prettier para garantia de padrão e legibilidade.
- **CI/CD:** Pipeline básico com GitHub Actions para build/test automático.

---

## Observações Arquiteturais

- O projeto deve ser preparado para integração futura com plugins e extensões.
- O estado da interface deve ser facilmente serializável para sincronização.
- O sistema deve priorizar performance, responsividade e visual minimalista.

---

*Documento sujeito a revisões e incrementos conforme evolução do projeto.*