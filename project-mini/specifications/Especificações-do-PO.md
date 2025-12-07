<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# Estou criando um editor de textos minimalista focado em praticidade, sem necessariamente focar em desenvolvimento de sistemas. Ele é baseado no ZED. Já compilamos o ZED no Windows 11 usando o Cursor IDE como desenvolvedor, e você fará o papel do Supervisor de Desenvolvimento do Projeto e Engenheiro de Especificações. Inicialmente, leia o arquivo dos meus requisitos iniciais para esse aplicativo, e gere um documento de especificações para instruir o programador Cursor IDE na implementação desses requisitos com excelência e empenho, de forma real, sem simulacros e sem deixar TODOs pelo código. Especifique que o programador deverá executar as tarefas na forma de FASES, começando pelas tarefas de UI/UX e terminando nas tarefas de sincronização. O programador deve executar todas as tarefas de uma só vez, sem interrupções, e ao finalizar cada FASE, ele deve me notificar através do comando cast.exe que ele já conhece e sabe operar `cast.exe send tg me "message". Depois disso deve produzir a documentação de resultado da fase em `D:\proj\mini\project-mini\reports` e então seguir imediatamente para a próxima fase.

A implementação da funcionalidade de trayicon deve ser uma das primeiras a serem implementadas, para dar vazão às funcionalidades de alinhamento de tela. As fases de sincronização e atualização são as únicas que podem conter TODOs, pois precisam de configurações externas e que se crie um servidor de atualização e contas de serviços no Google. Todas as fazes devem ter testes automatizados que possam ser feitos sem minha presença. Vou te passar as especificações anteriores para que analise, MAS, OS REQUISITOS DO PO SE SOBREPÕE A QUALQUER ESPECIFICAÇÃO CONFLITANTE NESSES DOCUMENTOS, até porque o projeto considerava o uso de fork do VSCode ou Electron, mas isso já foi descartado.

Se DDD não for o forte de Rust, pode instruir o programador a usar as boas práticas de Rust e modelos de design próprios do Rust, sem problemas.

Faça esse documento de especificações em um único arquivo.

Agora tenho todos os requisitos e especificações anteriores. Vou gerar o documento de especificações técnicas consolidado para o Cursor IDE, respeitando os requisitos do PO e organizando a implementação em fases.

***

# Especificação Técnica Consolidada para Implementação do MINI

## Projeto: MINI (Editor Minimalista baseado no Zed)

## Versão: 2.0 - 2025-12-06

## Autor: Arquiteto/Supervisor IA (Perplexity)


***

## Contexto do Projeto

O **MINI** é um editor de textos minimalista, focado em praticidade e uso pessoal, não exclusivo para desenvolvimento de software. O projeto é um fork do [Zed Editor](https://github.com/zed-industries/zed), já compilado com sucesso no Windows 11. O repositório de desenvolvimento encontra-se em `D:\proj\mini`.[^1]

> **NOTA IMPORTANTE:** Este documento substitui especificações anteriores que consideravam Electron/React/Monaco. O stack tecnológico agora é **Rust** (base Zed).[^2][^3]

***

## Stack Tecnológica

| Componente | Tecnologia |
| :-- | :-- |
| Linguagem Principal | Rust |
| Base do Editor | Fork do Zed |
| GUI Framework | GPUI (Zed's GPU-accelerated UI framework) |
| Sistema Operacional Alvo | Windows 11 (primário) |
| Persistência Local | JSON/TOML (arquivos de configuração) |
| Sincronização | Git (embutido), GitHub API, Google Drive API |


***

## Padrões de Código e Arquitetura

O programador **deve utilizar boas práticas idiomáticas de Rust** em vez de DDD clássico:[^1]

- **Ownership e Borrowing:** Garantir segurança de memória sem garbage collector
- **Error Handling:** Usar `Result<T, E>` e `Option<T>` consistentemente, evitar `unwrap()` em produção
- **Modularização:** Organizar código em crates e módulos coesos
- **Traits:** Usar traits para polimorfismo e extensibilidade
- **Testes:** Cada módulo deve ter testes unitários inline (`#[cfg(test)]`)
- **Documentação:** Usar `///` para documentar funções públicas
- **Clippy:** Todo código deve passar sem warnings do clippy

***

## Instruções Gerais para o Programador

### Regras de Execução

1. **Executar todas as tarefas de uma só vez, sem interrupções**[^1]
2. **Ao finalizar cada FASE**, executar:

```bash
cast.exe send tg me "FASE X concluída - [Nome da Fase]"
```

3. **Produzir relatório** da fase em: `D:\proj\mini\project-mini\reports\FASE-XX-[nome].md`
4. **Seguir imediatamente** para a próxima fase após documentação
5. **NÃO deixar TODOs no código** (exceto Fases 7 e 8 - Sincronização e Atualização)
6. **Testes automatizados obrigatórios** em cada fase, executáveis sem intervenção humana

### Estrutura dos Relatórios de Fase

Cada relatório em `D:\proj\mini\project-mini\reports\` deve conter:

```markdown
# Relatório da Fase X - [Nome]
## Data: YYYY-MM-DD HH:MM
## Status: CONCLUÍDA / PARCIAL

### Arquivos Modificados/Criados
- caminho/arquivo.rs - descrição da mudança

### Funcionalidades Implementadas
- [x] funcionalidade 1
- [x] funcionalidade 2

### Testes Criados
- teste_nome_1 - descrição
- teste_nome_2 - descrição

### Resultado dos Testes
cargo test [módulo] -- resultado

### Observações Técnicas
Notas relevantes sobre decisões de implementação

### Próxima Fase
Breve descrição do que será feito a seguir
```


***

## FASE 1: System Tray e Gerenciamento de Janela

**Prioridade: CRÍTICA** — Base para funcionalidades de alinhamento[^1]

### 1.1 Funcionalidade de TrayIcon

**Requisitos do PO:**[^1]

- O MINI deve inicializar com o SO e abrir mostrando a aba de tarefas
- Configurável para minimizar para trayicon (padrão) ou barra de tarefas
- Ao minimizar para tray pela primeira vez, exibir notificação informando o usuário (com opção "não mostrar novamente")
- **Clique direito** no trayicon: menu de contexto com:
    - Abrir/Restaurar janela
    - Submenu de posicionamento (tamanho, posição, monitor)
    - Sincronizar (quando disponível)
    - Fechar aplicativo
- **Clique esquerdo** no trayicon: mostrar/ocultar janela (toggle)
- O trayicon deve detectar em qual monitor foi clicado para abrir o MINI nesse monitor
- Janela deve aparecer/desaparecer com animação **fade-in/fade-out**


### 1.2 Dimensionamento e Posicionamento da Janela

**Requisitos do PO:**[^1]


| Modo | Comportamento |
| :-- | :-- |
| Bloqueado | Último tamanho definido pelo usuário, não permite resize |
| Livre | Redimensionamento livre pelo usuário |
| Personalizado | X e Y em PX ou % da tela, definidos pelo usuário |
| Centralizado 50% | Centro da tela, 50% largura e 50% altura |
| Retrato Esquerda/Direita | Lateral ocupando 50% da tela |
| Quadrante | 25% da tela em cima/baixo + esquerda/direita (padrão: direita-baixo) |

**Regras de Margens e Salvamento:**

- Em modo normal (não maximizado), manter **10px de margem** de todas as bordas do monitor e barra de tarefas do SO
- **Sempre salvar** posição/tamanho quando em modo normal
- **Nunca salvar** posição quando maximizado (perde referência do modo normal)
- **Salvar** flag `was_maximized` para restaurar estado ao reabrir
- **Salvar** identificador do monitor onde estava aberto


### 1.3 Movimento da Janela

**Requisitos do PO:**[^1]


| Modo | Comportamento |
| :-- | :-- |
| Bloqueado | Posição fixa, alterável apenas via configurações/tray |
| Livre | Arrastar livremente |
| Assistido | Ctrl pressionado: desliza apenas no eixo Y; Shift: apenas eixo X |

### 1.4 Estrutura de Arquivos Sugerida

```
crates/
├── mini_tray/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── tray_icon.rs      # Gerenciamento do ícone na bandeja
│   │   ├── context_menu.rs   # Menu de contexto do tray
│   │   └── monitor.rs        # Detecção de monitor ativo
│   └── Cargo.toml
├── mini_window/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── positioning.rs    # Lógica de posicionamento
│   │   ├── sizing.rs         # Lógica de dimensionamento
│   │   ├── animation.rs      # Fade-in/fade-out
│   │   └── persistence.rs    # Salvar/restaurar estado
│   └── Cargo.toml
```


### 1.5 Testes da Fase 1

```rust
#[cfg(test)]
mod tests {
    // Testes de posicionamento
    #[test]
    fn test_window_position_with_margins() { }
    
    #[test]
    fn test_position_restoration_after_minimize() { }
    
    #[test]
    fn test_maximized_state_not_saved_as_position() { }
    
    #[test]
    fn test_multi_monitor_position_save() { }
    
    // Testes de dimensionamento
    #[test]
    fn test_preset_sizes_calculate_correctly() { }
    
    #[test]
    fn test_percentage_sizing() { }
    
    // Testes de movimento
    #[test]
    fn test_locked_movement_prevents_drag() { }
    
    #[test]
    fn test_assisted_movement_axis_constraint() { }
}
```


***

## FASE 2: Tela de Boas-Vindas e Estrutura de UI Base

### 2.1 Tela de Boas-Vindas (Welcome Screen)

**Requisitos do PO:**[^1]

A primeira execução deve exibir uma tela de boas-vindas ocupando uma aba de edição, com:

- Botão **Abrir Arquivo** — abre diálogo para selecionar arquivo(s)
- Botão **Abrir Pasta** — abre diálogo para selecionar pasta (modo projeto)
- Botão **Abrir Painel de Tarefas** — abre o gerenciador de tarefas
- Acesso às **Configurações**
- Acesso à **Ajuda**


### 2.2 Menu Principal

**Requisitos do PO:**[^1]

Implementar barra de menu padrão com itens:


| Menu | Funcionalidades Principais |
| :-- | :-- |
| Arquivo | Novo, Abrir Arquivo, Abrir Pasta, Salvar, Salvar Como, Fechar, Sair |
| Editar | Desfazer, Refazer, Recortar, Copiar, Colar, Selecionar Tudo, Buscar |
| Ferramentas | Tarefas, Sincronização, Assistente de IA |
| Visual | Temas, Fontes, Painel Lateral, Zoom |
| Janelas | Posicionamento, Monitor, Comportamento de Minimização |
| Ajuda | Documentação, Atalhos, Sobre |

### 2.3 Margem Superior do Editor

**Requisito do PO:**[^1]

> "Atualmente o Editor do Zed mostra a primeira linha do editor de texto imediatamente abaixo da barra de ferramentas. Deve haver um espaço (margem) de pelo menos a altura de uma linha de texto antes da linha 1 do editor."

Implementar padding-top no componente de edição equivalente à altura de uma linha de texto.

### 2.4 Estrutura de Arquivos Sugerida

```
crates/
├── mini_ui/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── welcome_screen.rs  # Tela de boas-vindas
│   │   ├── main_menu.rs       # Barra de menu
│   │   └── editor_margin.rs   # Ajuste de margem do editor
│   └── Cargo.toml
```


### 2.5 Testes da Fase 2

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_welcome_screen_renders_all_buttons() { }
    
    #[test]
    fn test_open_file_button_triggers_dialog() { }
    
    #[test]
    fn test_menu_items_present() { }
    
    #[test]
    fn test_editor_top_margin_equals_line_height() { }
}
```


***

## FASE 3: Modos de Operação (Pasta vs Solto) e Painel Lateral

### 3.1 Modo Pasta (Projeto/Repositório)

**Requisitos do PO:**[^1]

- Ao abrir uma pasta, exibir painel lateral esquerdo com árvore de arquivos e subpastas
- Comportamento similar a um repositório/projeto IDE
- Arquivo `.mini` na raiz da pasta pode conter configurações específicas do projeto


### 3.2 Modo Solto (Arquivos Avulsos)

**Requisitos do PO:**[^1]

- Arquivos de diferentes locais/discos abertos simultaneamente
- Configuração de visualização da lista de arquivos:

| Modo | Descrição |
| :-- | :-- |
| TABS | Abas no topo do editor, tooltip com caminho completo após 2s de hover |
| LIST | Painel lateral com nome em negrito + caminho completo abaixo |
| BOTH | Exibe ambas as formas simultaneamente |

### 3.3 Transição Entre Modos

**Requisito do PO:**[^1]

> "Se o usuário fechar a pasta, o MINI deve voltar ao modo Solto, reabrindo as abas de arquivos que estavam abertos antes de se abrir o MINI no modo pasta"

Implementar pilha de sessão para preservar estado anterior ao modo pasta.

### 3.4 Estrutura de Arquivos Sugerida

```
crates/
├── mini_workspace/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── folder_mode.rs     # Modo pasta/projeto
│   │   ├── loose_mode.rs      # Modo arquivos avulsos
│   │   ├── session_stack.rs   # Pilha de sessões
│   │   ├── sidebar.rs         # Painel lateral
│   │   └── mini_config.rs     # Parser de .mini
│   └── Cargo.toml
```


### 3.5 Testes da Fase 3

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_folder_mode_shows_tree() { }
    
    #[test]
    fn test_loose_mode_displays_multiple_sources() { }
    
    #[test]
    fn test_mode_transition_preserves_session() { }
    
    #[test]
    fn test_mini_config_file_parsing() { }
    
    #[test]
    fn test_tab_tooltip_shows_full_path() { }
}
```


***

## FASE 4: Temas e Fontes Personalizadas

### 4.1 Temas Embutidos

**Requisitos do PO:**[^1]


| Tema | Inspiração |
| :-- | :-- |
| Claro | GitHub Light Default |
| Escuro | VSCode Dark |
| Pastel | Cadernos Moleskine |
| Zed Themes | Aproveitar temas existentes do Zed |

- Permitir criação de temas novos (funcionalidade já disponível no Zed)


### 4.2 Fontes por Tipo de Arquivo

**Requisitos do PO:**[^1]


| Extensão | Fonte Padrão | Fallback | Tamanho | Line-height |
| :-- | :-- | :-- | :-- | :-- |
| .txt | Bookman Old Style | Literata, EB Garamond, serif, Times New Roman | 16px | 1.6 |
| Código (.java, .js, .md, etc) | JetBrains Mono | Fira Code, Cascadia Code, Consolas, monospace | Padrão Zed | Padrão Zed |

**Comportamento de Fontes:**[^1]

- Instalar automaticamente fontes padrão se não existirem no SO
- Usuário pode:
    - Aceitar comportamento padrão do MINI
    - Escolher suas próprias fontes
    - Delegar ao tema a escolha de fontes
- Tamanho e espaçamento de linha configuráveis independentemente
- Permitir mapeamento de fontes customizadas para outras extensões


### 4.3 Estrutura de Arquivos Sugerida

```
crates/
├── mini_themes/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── builtin_themes.rs  # Temas embutidos
│   │   ├── theme_loader.rs    # Carregamento de temas
│   │   └── theme_creator.rs   # Criação de novos temas
│   └── Cargo.toml
├── mini_fonts/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── font_mapping.rs    # Mapeamento extensão -> fonte
│   │   ├── font_installer.rs  # Instalação automática
│   │   └── font_config.rs     # Configuração de usuário
│   ├── assets/
│   │   ├── BookmanOldStyle.ttf
│   │   └── JetBrainsMono.ttf
│   └── Cargo.toml
```


### 4.4 Testes da Fase 4

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_theme_claro_loads_correctly() { }
    
    #[test]
    fn test_theme_escuro_loads_correctly() { }
    
    #[test]
    fn test_font_mapping_txt_returns_bookman() { }
    
    #[test]
    fn test_font_mapping_code_returns_jetbrains() { }
    
    #[test]
    fn test_font_fallback_chain() { }
    
    #[test]
    fn test_custom_font_mapping_persistence() { }
}
```


***

## FASE 5: Sistema de Ajuda e Pesquisa Avançada

### 5.1 Ajuda Inteligente

**Requisitos do PO:**[^1]

- **Menu Ajuda** — acesso tradicional à documentação
- **Ícones (?)** — próximos a funcionalidades, com:
    - Hover por 1-2s: tooltip resumido
    - Link "Saiba mais..." no tooltip
    - Clique no (?) ou "Saiba mais": abre aba de edição com ajuda completa (como arquivo editável)
- **QA integrado** — busca na documentação


### 5.2 Pesquisa de Arquivos Global (`Ctrl+Shift+F`)

**Requisitos do PO:**[^1]

- Usar base do `Project Search` do Zed
- **Em modo pasta:** busca no projeto atual
- **Em modo solto:** busca em todo o sistema de arquivos do SO
- Opção para buscar texto dentro dos arquivos (grep-like)


### 5.3 Estrutura de Arquivos Sugerida

```
crates/
├── mini_help/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── help_tooltips.rs   # Sistema de tooltips (?)
│   │   ├── help_viewer.rs     # Visualizador de ajuda em aba
│   │   └── help_content.rs    # Conteúdo da ajuda
│   ├── content/
│   │   ├── pt-BR/
│   │   ├── en/
│   │   └── zh/
│   └── Cargo.toml
├── mini_search/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── project_search.rs  # Busca em projeto
│   │   ├── global_search.rs   # Busca global no SO
│   │   └── content_search.rs  # Busca dentro de arquivos
│   └── Cargo.toml
```


### 5.4 Testes da Fase 5

```rust
#[cfg(test)]
mod tests {
    #[test]
    fn test_help_tooltip_renders() { }
    
    #[test]
    fn test_help_opens_in_editable_tab() { }
    
    #[test]
    fn test_global_search_finds_files() { }
    
    #[test]
    fn test_content_search_finds_text() { }
}
```


***

## FASE 6: Gerenciador de Tarefas e Agente de IA

### 6.1 Gerenciador de Tarefas

**Requisitos do PO:**[^1]

**Posicionamento:**

- Painel configurável: esquerda (substituindo lista de arquivos) ou direita do editor
- Pode coexistir com painel de arquivos

**Tipos de Tarefas:**


| Tipo | Criação | Status Possíveis |
| :-- | :-- | :-- |
| Simples | Descrição + ENTER | normal, antiga (se muito tempo sem realizar) |
| Agendada | Descrição + ENTER + Data/Hora (ou HOJE/AMANHÃ) + ENTER | iminente, atrasada, realizada |
| Recorrente | Tipo de recorrência (diária, semanal, quinzenal, mensal) + dia/semana | automático |
| Lista de Compras | Como simples, mas com tag `compras` + tags opcionais (casa, carro, etc) | normal, realizada |
| Complexa | Abre aba de texto para descrição detalhada + subtarefas | não iniciada, iniciada, realizada |

**Funcionalidades:**

- Botão (+) para adicionar tarefas
- Botão de limpeza de tarefas concluídas
- Histórico de tarefas concluídas e excluídas
- Configuração de tempo de retenção no histórico (dias/horas)
- Sistema de tags (filtráveis)
- Filtro por texto, tag e tipo
- Configuração de SMTP para notificações por email


### 6.2 Agente de IA

**Requisitos do PO:**[^1]

- Aproveitar suporte a APIs de IA já existente no Zed
- **Modos de interação:**

| Modo | Descrição |
| :-- | :-- |
| Painel | Painel dedicado (já existente no Zed) |
| Barra de Pesquisa | Como a barra de busca, resposta inserida no arquivo em foreground na posição do cursor |
| Inline `///` | Digitar `///[prompt]` + ENTER, resposta na linha seguinte |
| Inline Assistant | Já disponível no Zed |

**Autocomplete:**[^1]

- Ativar via `Ctrl+Espaço` (não automático)
- Modos de sugestão:
    - Via agente de IA
    - Via palavras do próprio arquivo
    - Via dicionário da língua selecionada


### 6.3 Estrutura de Arquivos Sugerida

```
crates/
├── mini_tasks/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── task.rs            # Modelo de tarefa
│   │   ├── task_types.rs      # Tipos de tarefa
│   │   ├── task_panel.rs      # UI do painel
│   │   ├── task_storage.rs    # Persistência
│   │   ├── task_filter.rs     # Filtros e busca
│   │   ├── recurrence.rs      # Lógica de recorrência
│   │   └── notifications.rs   # SMTP/notificações
│   └── Cargo.toml
├── mini_ai/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── search_bar_mode.rs # Modo barra de pesquisa
│   │   ├── inline_mode.rs     # Modo ///
│   │   └── autocomplete.rs    # Sistema de autocomplete
│   └── Cargo.toml
```


### 6.4 Testes da Fase 6

```rust
#[cfg(test)]
mod tests {
    // Tarefas
    #[test]
    fn test_simple_task_creation() { }
    
    #[test]
    fn test_scheduled_task_status_transition() { }
    
    #[test]
    fn test_recurring_task_generates_instances() { }
    
    #[test]
    fn test_task_filtering_by_tag() { }
    
    #[test]
    fn test_task_history_cleanup() { }
    
    // IA
    #[test]
    fn test_inline_prompt_detection() { }
    
    #[test]
    fn test_autocomplete_mode_switching() { }
}
```


***

## FASE 7: Sincronização (GitHub/GitLab/Google Drive)

**⚠️ TODOs PERMITIDOS — Requer configurações externas**

### 7.1 Sincronização via Git

**Requisitos do PO:**[^1]

- Sincronizar arquivos abertos com repositório remoto (GitHub/GitLab)
- Suporte a arquivo `.mini` para configuração por pasta
- Detectar dispositivo/pasta/nome original do arquivo para sincronização correta
- Incluir **versão interna do Git** caso não detectado no SO
- Ajuda completa para usuários leigos em Git


### 7.2 Sincronização via Google Drive

**Requisitos do PO:**[^4][^1]

- Login OAuth2 na conta Google
- Arquivos soltos: sincronizar em pasta do Drive configurável (padrão: `mini`)
- Modo pasta: respeitar configuração do `.mini` para nome da pasta no Drive
- Suporte a pasta dedicada (`/Apps/mini-backup`) ou acesso total ao Drive


### 7.3 Estrutura de Arquivos Sugerida

```
crates/
├── mini_sync/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── git_sync.rs        # Sincronização Git
│   │   ├── github_api.rs      # API GitHub
│   │   ├── gitlab_api.rs      # API GitLab
│   │   ├── gdrive_sync.rs     # Sincronização GDrive
│   │   ├── oauth.rs           # OAuth2
│   │   ├── conflict.rs        # Resolução de conflitos
│   │   └── embedded_git.rs    # Git embutido
│   └── Cargo.toml
```


### 7.4 TODOs Esperados

```rust
// TODO: Configurar OAuth2 client_id e client_secret no GCP Console
// TODO: Criar repositório de teste para validação
// TODO: Definir estratégia de merge para conflitos
```


***

## FASE 8: Sistema de Atualização e Integração com SO

**⚠️ TODOs PERMITIDOS — Requer servidor de atualização**

### 8.1 Atualizações Transparentes

**Requisitos do PO:**[^1]

- Atualização sem necessidade de instalador
- Download em background, aplicação ao reiniciar


### 8.2 Integração com SO

**Requisitos do PO:**[^1]

- Registrar no menu de contexto do Windows Explorer:
    - "Abrir com MINI" para arquivos
    - "Abrir pasta com MINI" para diretórios
- Iniciar com o SO (opcional, configurável)


### 8.3 Internacionalização

**Requisitos do PO:**[^1]

Idiomas obrigatórios:

- Português do Brasil (pt-BR)
- Inglês (en)
- Chinês (zh)

Sistema de arquivos de tradução para idiomas adicionais.

### 8.4 Estrutura de Arquivos Sugerida

```
crates/
├── mini_updater/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── update_checker.rs  # Verificação de atualizações
│   │   ├── downloader.rs      # Download em background
│   │   └── installer.rs       # Aplicação da atualização
│   └── Cargo.toml
├── mini_os_integration/
│   ├── src/
│   │   ├── lib.rs
│   │   ├── context_menu.rs    # Menu de contexto Windows
│   │   ├── startup.rs         # Iniciar com SO
│   │   └── registry.rs        # Manipulação do registro
│   └── Cargo.toml
├── mini_i18n/
│   ├── src/
│   │   ├── lib.rs
│   │   └── loader.rs          # Carregamento de traduções
│   ├── locales/
│   │   ├── pt-BR.json
│   │   ├── en.json
│   │   └── zh.json
│   └── Cargo.toml
```


### 8.5 TODOs Esperados

```rust
// TODO: Implementar servidor de atualização
// TODO: Definir URL do servidor de atualizações
// TODO: Assinar binários para Windows SmartScreen
```


***

## Persistência Local de Configurações

### Local de Armazenamento

**Caminho Windows:** `%APPDATA%\mini\`[^5]

### Arquivos de Configuração

| Arquivo | Conteúdo |
| :-- | :-- |
| `config.json` | Preferências gerais, temas, fontes, UI, comportamento |
| `session.json` | Arquivos abertos, abas, posição/tamanho da janela, estado dos painéis |
| `tasks.json` | Lista de tarefas do gerenciador |
| `backup-YYYY-MM-DD-HH-MM.json` | Backups automáticos/manuais |

### Estrutura de `config.json`

```json
{
  "configVersion": 1,
  "theme": "claro",
  "fonts": {
    "txt": {
      "family": "Bookman Old Style",
      "size": 16,
      "lineHeight": 1.6
    },
    "code": {
      "family": "JetBrains Mono",
      "size": 14,
      "lineHeight": 1.4
    },
    "customMappings": {}
  },
  "window": {
    "sizingMode": "preset_centered_50",
    "movementMode": "free",
    "position": { "x": 100, "y": 100 },
    "size": { "width": 960, "height": 540 },
    "monitor": 0,
    "wasMaximized": false,
    "minimizeTo": "tray"
  },
  "sidebar": {
    "mode": "fixed",
    "width": 280,
    "fileListMode": "BOTH"
  },
  "language": "pt-BR",
  "tasks": {
    "panelPosition": "right",
    "historyRetentionDays": 30,
    "smtp": null
  },
  "ai": {
    "mode": "panel",
    "autocompleteSource": "file_words"
  },
  "sync": {
    "github": null,
    "gdrive": null
  }
}
```


***

## Sumário de Fases e Comandos de Notificação

| Fase | Nome | Comando de Notificação |
| :-- | :-- | :-- |
| 1 | System Tray e Gerenciamento de Janela | `cast.exe send tg me "FASE 1 concluída - TrayIcon e Window Management"` |
| 2 | Tela de Boas-Vindas e UI Base | `cast.exe send tg me "FASE 2 concluída - Welcome Screen e Menu"` |
| 3 | Modos de Operação e Painel Lateral | `cast.exe send tg me "FASE 3 concluída - Folder/Loose Modes"` |
| 4 | Temas e Fontes | `cast.exe send tg me "FASE 4 concluída - Themes e Fonts"` |
| 5 | Ajuda e Pesquisa | `cast.exe send tg me "FASE 5 concluída - Help e Search"` |
| 6 | Tarefas e IA | `cast.exe send tg me "FASE 6 concluída - Tasks e AI"` |
| 7 | Sincronização | `cast.exe send tg me "FASE 7 concluída - Sync (com TODOs)"` |
| 8 | Atualização e SO | `cast.exe send tg me "FASE 8 concluída - Updater e OS Integration (com TODOs)"` |


***

## Checklist Final para o Programador

- [ ] Executar `cargo clippy` sem warnings em cada fase
- [ ] Executar `cargo test` com todos os testes passando
- [ ] Documentar funções públicas com `///`
- [ ] Gerar relatório em `D:\proj\mini\project-mini\reports\`
- [ ] Notificar via `cast.exe` ao concluir cada fase
- [ ] Seguir imediatamente para próxima fase
- [ ] **Nenhum TODO** exceto nas Fases 7 e 8
- [ ] Testes devem ser executáveis sem intervenção humana

***

*Documento elaborado pelo Arquiteto/Supervisor IA (Perplexity) para o Dev Sênior Full Stack (Cursor IDE IA).*
<span style="display:none">[^6][^7][^8]</span>

<div align="center">⁂</div>

[^1]: Requisitos-do-PO.md

[^2]: Especificacao-Tecnica-e-Arquitetural.md

[^3]: Especificacao-Visual-e-Diretrizes-de-UX-UI.md

[^4]: Especificacao-de-Sincronizacao-de-Dados-e-Backup-via-GDrive.md

[^5]: Especificacao-de-Configuracao-Local-e-Persistencia.md

[^6]: Especificacao-de-Testes-e-Garantia-de-Qualidade.md

[^7]: Especificacao-de-Fluxos-de-Usuario-e-Funcionalidades-Chave.md

[^8]: Especificacao-de-Sincronizacao-de-Dados-e-Backup-via-GitHub.md

