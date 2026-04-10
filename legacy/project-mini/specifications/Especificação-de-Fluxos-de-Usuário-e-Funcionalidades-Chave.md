# Especificação-de-Fluxos-de-Usuário-e-Funcionalidades-Chave.md
## Projeto: mini (Minimalist, Intelligent, Nice Interface)
## Versão: 1.0 - 2025-11-13
## Autor: Equipe de IA (PO, Arquiteto/Supervisor, Dev Sênior)

---

## Principais Fluxos de Usuário

### 1. Fluxo de Inicialização
- mini inicia em modo padrão: barra de abas no topo, painel lateral configurado conforme último uso.
- Limitado visualmente, apenas áreas essenciais são exibidas por padrão.

### 2. Abrir Arquivo(s)
- Usuário pode arrastar ou selecionar múltiplos arquivos.
- Cada arquivo é aberto em uma nova aba, aparece na barra e na lista lateral.
- Arquivo `.txt`: fonte serifada (Bookman Old Style, configurável).
- Arquivo de código (.java, .md, .js): fonte monoespaçada (JetBrains Mono, configurável).
- Arquivo pode ser fixado no painel lateral.

### 3. Abrir Pasta/Projeto
- Usuário seleciona uma pasta (“Open Folder”).
- Painel lateral muda de modo lista para modo árvore, exibindo arquivos e subpastas.
- Opcional: arquivos mais abertos/recentes podem ser fixados no topo da árvore.

### 4. Alternar Painel Lateral
- Usuário pode escolher exibição fixa, oculta ou hover do painel lateral.
- Mudança é refletida imediatamente na UI e salva nas configurações.
- Hover: painel lateral aparece apenas em mouse-over na borda.

### 5. Edição de Texto e Navegação
- Barra de abas permite alternância rápida entre arquivos.
- Rodapé sempre mostra encoding, posição do cursor, caminho completo do arquivo.
- Feedback visual para salvar, modificar, fechar.

### 6. Salvar Posição/Tamanho da Janela
- Ao fechar ou minimizar, posição/tamanho da janela padrão é salvo localmente.
- Se restaurado pelo trayicon, janela aparece no canto inferior direito da tela.
- Opção pode ser habilitada/desabilitada nas configurações.

### 7. System Tray
- mini pode ser minimizado/fechado para o tray do Windows.
- Ao restaurar, configuração de posição/tamanho/estado é aplicada.

### 8. Sincronização e Continuidade
- Configurações (temas, fontes, painel lateral, etc) e arquivos abertos podem ser sincronizados via GitHub.
- Usuário fornece login/token, URL de repositório.
- Ao abrir em outro PC, usuário restaura estado anterior com poucos cliques.

---

## Funcionalidades-Chave

- **Interface minimalista:** Oculta elementos não essenciais, exibe apenas o necessário.
- **Painel de arquivos lateral:** Configurável (fixo, oculto, hover), lista arquivos abertos com duas linhas, modo árvore em projetos.
- **Barra de abas:** Navegação simples, mantém histórico e status dos arquivos.
- **Rodapé:** Detalhes técnicos essenciais, feedback direto ao usuário.
- **Duas configurações de fonte:** Por extensão/categoria do arquivo.
- **Temas VSCode e syntax highlight robusto:** Experiência visual consistente.
- **Salvamento local e remoto:** Continuidade total entre ambientes.
- **Trayicon e comportamento de janela:** Foco em agilidade para fluxos de escrita rápida ou consulta.

---

## Observações

- Todas interações devem ser claras, rápidas e responsivas.
- A cada ação importante (abrir, salvar, fixar, configurar) o sistema deve notificar o usuário de modo discreto.
- O projeto deve ser compatível com futuras expansões (plugins, snippets, markdown preview, etc).

---

*Documento sujeito a revisões e incrementos conforme evolução do projeto.*
