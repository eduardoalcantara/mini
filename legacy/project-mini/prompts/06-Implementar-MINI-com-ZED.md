# PROMPT DE INSTRUÇÃO PARA IMPLEMENTAÇÃO DO MINI EDITOR

## Para: Cursor IDE IA (Dev Sênior Full Stack)

## De: Arquiteto/Supervisor IA (Perplexity)

## Projeto: MINI - Editor Minimalista baseado no Zed

## Data: 2025-12-06


***

## 🎯 MISSÃO

Você é o **Dev Sênior Full Stack** responsável pela implementação completa do **MINI Editor**, um editor de textos minimalista construído sobre o **Zed Editor** (Rust + GPUI). Sua missão é implementar **TODAS as 9 fases** de desenvolvimento de forma sequencial, sem interrupções, seguindo rigorosamente as especificações técnicas fornecidas.

***

## ⚠️ REGRAS OBRIGATÓRIAS

### 1. Execução Contínua

- Execute **TODAS as fases de uma só vez**, sem pausas para perguntas
- Ao concluir cada fase, **notifique via cast.exe** e **gere relatório**
- Siga **imediatamente** para a próxima fase após documentação


### 2. Código Completo

- **NUNCA deixe TODOs no código**, exceto nas Fases 7 e 8
- Se algo é complexo, divida em sub-tarefas menores
- Se falta informação, use defaults sensatos e documente a decisão
- Todo código deve compilar e passar nos testes


### 3. Padrões Rust

- Use idiomas nativos de Rust (não force DDD ou padrões OOP)
- `Result<T, E>` para error handling
- `Option<T>` para valores opcionais
- Traits para abstração e polimorfismo
- Pattern matching extensivo
- Async/await com Tokio para operações assíncronas


### 4. Qualidade

- `cargo clippy --all -- -D warnings` deve passar sem erros
- `cargo test --all` deve passar 100%
- `cargo fmt --all` para formatação consistente
- Documentar funções públicas com `///`


### 5. Testes Automatizados

- Cada fase DEVE ter testes unitários (`#[cfg(test)]`)
- Testes devem ser executáveis **sem intervenção humana**
- Cobertura mínima: 70%

***

## 📁 ESTRUTURA DO PROJETO

**Localização:** `D:\proj\mini`

**Estrutura de Crates a Criar:**

```
D:\proj\mini\
├── crates/
│   ├── mini/                    # Aplicação principal (binary)
│   │   └── src/
│   │       ├── main.rs
│   │       └── app.rs
│   │
│   ├── mini_core/               # Lógica de negócio (library)
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── config.rs
│   │       ├── file_manager.rs
│   │       ├── session.rs
│   │       ├── task_manager.rs
│   │       ├── editor_config.rs
│   │       ├── mini_config_file.rs
│   │       ├── ai_client.rs
│   │       ├── inline_ai.rs
│   │       └── autocomplete.rs
│   │
│   ├── mini_ui/                 # Componentes de UI (library)
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── tray_icon.rs
│   │       ├── window_manager.rs
│   │       ├── window_state.rs
│   │       ├── sidebar.rs
│   │       ├── statusbar.rs
│   │       ├── tabs.rs
│   │       ├── welcome_screen.rs
│   │       ├── task_panel.rs
│   │       ├── ai_panel.rs
│   │       ├── ai_search_bar.rs
│   │       └── help_system.rs
│   │
│   ├── mini_theme/              # Temas customizados (library)
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── moleskine.rs
│   │       ├── github_light.rs
│   │       └── vscode_dark.rs
│   │
│   ├── mini_sync/               # Sincronização (library)
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── git/
│   │       │   ├── mod.rs
│   │       │   ├── embedded.rs
│   │       │   ├── github.rs
│   │       │   └── gitlab.rs
│   │       ├── gdrive/
│   │       │   ├── mod.rs
│   │       │   ├── oauth.rs
│   │       │   └── api.rs
│   │       ├── sync_manager.rs
│   │       └── conflict.rs
│   │
│   ├── mini_updater/            # Sistema de atualização (library)
│   │   └── src/
│   │       ├── lib.rs
│   │       ├── checker.rs
│   │       ├── downloader.rs
│   │       └── installer.rs
│   │
│   └── mini_os/                 # Integração com SO (library)
│       └── src/
│           ├── lib.rs
│           ├── windows/
│           │   ├── mod.rs
│           │   ├── context_menu.rs
│           │   ├── startup.rs
│           │   └── registry.rs
│           └── i18n.rs
│
├── project-mini/
│   └── reports/                 # Relatórios de cada fase
│       ├── FASE-00-Setup.md
│       ├── FASE-01-TrayIcon.md
│       └── ...
│
└── Cargo.toml                   # Workspace root
```


***

## 📋 FASES DE IMPLEMENTAÇÃO

### FASE 0: Setup e Rebranding Zed → mini

**Objetivo:** Preparar base do projeto com nome "mini"

**Tarefas:**

1. Renomear crate `zed` para `mini`
2. Criar novos crates: `mini_core`, `mini_ui`, `mini_theme`, `mini_sync`, `mini_updater`, `mini_os`
3. Atualizar `Cargo.toml` do workspace
4. Busca e substituição global de "Zed" por "mini"
5. Configurar build para Windows (`x86_64-pc-windows-msvc`)
6. Primeira compilação bem-sucedida

**Critérios de Aceitação:**

- [ ] `cargo build --release` compila sem erros
- [ ] Executável `mini.exe` gerado
- [ ] Janela abre com título "mini"
- [ ] Configurações salvam em `%APPDATA%/mini/`

**Notificação:**

```bash
cast.exe send tg me "FASE 0 CONCLUÍDA: Setup e Rebranding - Compilação bem-sucedida, executável mini.exe gerado"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-00-Setup.md`

***

### FASE 1: TrayIcon e Gerenciamento de Janela ⭐ PRIORIDADE

**Objetivo:** Implementar tray icon e controle de janela (BASE para outras funcionalidades)

**Dependências a adicionar:**

```toml
[dependencies]
windows = { version = "0.52", features = [
    "Win32_UI_Shell",
    "Win32_UI_WindowsAndMessaging",
    "Win32_Foundation",
    "Win32_System_LibraryLoader",
    "Win32_Graphics_Gdi",
]}
```

**Tarefas:**

1. **TrayIcon (`mini_ui/src/tray_icon.rs`):**
    - Ícone na bandeja do sistema
    - Clique esquerdo: toggle mostrar/ocultar janela
    - Clique direito: menu de contexto (Abrir, Posicionamento, Sincronizar, Fechar)
    - Detectar monitor onde tray foi clicado
    - Notificação ao minimizar pela primeira vez (com opção "não mostrar novamente")
2. **Window State (`mini_ui/src/window_state.rs`):**
    - Struct `WindowState` com: x, y, width, height, monitor_id, is_maximized
    - Persistência em `%APPDATA%/mini/window_state.json`
    - Load/Save automático
3. **Window Manager (`mini_ui/src/window_manager.rs`):**
    - Modos de dimensionamento:
        - Bloqueado (último tamanho)
        - Livre
        - Personalizado (X/Y em PX ou %)
        - Presets: Centralizado 50%, Retrato Esquerda/Direita, Quadrante 25%
    - Modos de movimento:
        - Bloqueado
        - Livre
        - Assistido (Ctrl=eixo Y, Shift=eixo X)
    - Margem de 10px das bordas do monitor
    - Animação fade-in/fade-out ao mostrar/ocultar
    - NUNCA salvar posição quando maximizado (apenas flag `was_maximized`)

**Testes Obrigatórios:**

```rust
#[test] fn test_window_position_with_margins() { }
#[test] fn test_position_restoration_after_minimize() { }
#[test] fn test_maximized_state_not_saved_as_position() { }
#[test] fn test_multi_monitor_position_save() { }
#[test] fn test_preset_sizes_calculate_correctly() { }
#[test] fn test_locked_movement_prevents_drag() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 1 CONCLUÍDA: TrayIcon e Window Management - Tray funcional, posicionamento implementado, fade-in/out OK"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-01-TrayIcon.md`

***

### FASE 2: UI/UX Foundation

**Objetivo:** Implementar tema Moleskine, fontes por extensão, estrutura visual

**Tarefas:**

1. **Tema Moleskine Light (`mini_theme/src/moleskine.rs`):**
    - Background: `#FAF6EF` (creme papel)
    - Foreground: `#2C2416` (marrom escuro)
    - Accent: `#3484F7` (azul)
    - Secundário: `#6B5E4F` (marrom médio)
    - Borders: `#EFEAe1`
2. **Temas adicionais:**
    - GitHub Light (`github_light.rs`)
    - VSCode Dark (`vscode_dark.rs`)
    - Aproveitar temas existentes do Zed
3. **Fontes por extensão (`mini_core/src/editor_config.rs`):**
    - `.txt`: Bookman Old Style, 16px, line-height 1.6
    - Código (.rs, .js, .java, .md, etc): JetBrains Mono, 14px
    - Fallbacks configurados
    - Instalar fontes automaticamente se não existirem
4. **Margem superior do editor:**
    - Adicionar padding-top equivalente a 1 linha de texto antes da linha 1
5. **Welcome Screen (`mini_ui/src/welcome_screen.rs`):**
    - Botões: Abrir Arquivo, Abrir Pasta, Abrir Painel de Tarefas
    - Links: Configurações, Ajuda
6. **Menu Principal:**
    - Arquivo, Editar, Ferramentas, Visual, Janelas, Ajuda

**Testes Obrigatórios:**

```rust
#[test] fn test_theme_moleskine_colors() { }
#[test] fn test_font_mapping_txt_returns_bookman() { }
#[test] fn test_font_mapping_code_returns_jetbrains() { }
#[test] fn test_font_fallback_chain() { }
#[test] fn test_welcome_screen_renders() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 2 CONCLUÍDA: UI/UX Foundation - Temas implementados, fontes por extensão, welcome screen funcional"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-02-UI-UX.md`

***

### FASE 3: Sistema de Arquivos e Navegação

**Objetivo:** Implementar modos Pasta/Solto, painel lateral, arquivo .mini

**Tarefas:**

1. **Modo Pasta (`mini_core/src/file_manager.rs`):**
    - Painel lateral com árvore de arquivos/subpastas
    - Leitura de arquivo `.mini` para configurações da pasta
2. **Modo Solto:**
    - Arquivos de diferentes locais/discos
    - Modos de visualização: TABS, LIST, BOTH
    - Tooltip com caminho completo após 2s de hover
3. **Transição entre modos:**
    - Pilha de sessão para preservar estado anterior
    - Ao fechar pasta, restaurar arquivos soltos anteriores
4. **Sidebar (`mini_ui/src/sidebar.rs`):**
    - Modo fixo, oculto ou hover
    - Fade-in/out animado em 200ms
    - Atalho `Ctrl+B` para toggle
5. **Arquivo .mini (`mini_core/src/mini_config_file.rs`):**
    - sync_repo, gdrive_folder, theme, font_override, ignore_patterns

**Testes Obrigatórios:**

```rust
#[test] fn test_folder_mode_shows_tree() { }
#[test] fn test_loose_mode_displays_multiple_sources() { }
#[test] fn test_mode_transition_preserves_session() { }
#[test] fn test_mini_config_file_parsing() { }
#[test] fn test_sidebar_toggle() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 3 CONCLUÍDA: Arquivos e Navegação - Modos Pasta/Solto, sidebar, arquivo .mini implementados"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-03-Arquivos.md`

***

### FASE 4: Editor e Funcionalidades de Texto

**Objetivo:** Sistema de ajuda, pesquisa global, autocompletar básico

**Tarefas:**

1. **Sistema de Ajuda (`mini_ui/src/help_system.rs`):**
    - Ícones (?) próximos às funcionalidades
    - Tooltip com resumo + link "Saiba mais..."
    - Clicar abre aba de ajuda completa (arquivo editável)
2. **Pesquisa Global (`Ctrl+Shift+F`):**
    - Em modo pasta: busca no projeto
    - Em modo solto: busca no SO (Home, Documentos)
    - Máximo 50 resultados para performance
    - Opção de buscar texto dentro de arquivos
3. **Autocompletar (`mini_core/src/autocomplete.rs`):**
    - Ativar APENAS com `Ctrl+Espaço` (não automático)
    - 3 modos: IA, palavras do arquivo, dicionário
    - Modo palavras: extrair palavras únicas do arquivo atual

**Dependências:**

```toml
walkdir = "2.4"
dirs = "5.0"
```

**Testes Obrigatórios:**

```rust
#[test] fn test_help_tooltip_renders() { }
#[test] fn test_help_opens_in_editable_tab() { }
#[test] fn test_global_search_finds_files() { }
#[test] fn test_autocomplete_words_mode() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 4 CONCLUÍDA: Editor e Funcionalidades - Ajuda, pesquisa global, autocompletar implementados"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-04-Editor.md`

***

### FASE 5: Gerenciador de Tarefas

**Objetivo:** Sistema completo de tarefas com 5 tipos

**Tarefas:**

1. **Modelo de Tarefas (`mini_core/src/task_manager.rs`):**
    - **Simples:** descrição + ENTER, status: pending/stale/completed
    - **Agendada:** + data/hora (ou HOJE/AMANHÃ), status: imminent/overdue/completed
    - **Recorrente:** diária/semanal/quinzenal/mensal + dia
    - **Compras:** como simples + tag "compras" + tags opcionais
    - **Complexa:** abre aba para descrição, status: not_started/started/completed
2. **Painel de Tarefas (`mini_ui/src/task_panel.rs`):**
    - Posição configurável: esquerda ou direita
    - Botão (+) para adicionar
    - Filtros por texto, tag, tipo
    - Botão limpeza de concluídas
    - Histórico de concluídas/excluídas
3. **Persistência:**
    - `%APPDATA%/mini/tasks.json`
    - `%APPDATA%/mini/tasks_completed.json`
    - Configuração de retenção (dias)
4. **Notificações SMTP (`mini_core/src/email_notifier.rs`):**
    - Configurável (server, port, username, password, from, to)
    - Digest diário opcional

**Dependências:**

```toml
uuid = { version = "1.6", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
lettre = { version = "0.11", features = ["smtp-transport", "builder"] }
```

**Testes Obrigatórios:**

```rust
#[test] fn test_create_simple_task() { }
#[test] fn test_scheduled_task_status_transition() { }
#[test] fn test_recurring_task_generates_instances() { }
#[test] fn test_task_filtering_by_tag() { }
#[test] fn test_task_persistence() { }
#[test] fn test_complete_task_moves_to_history() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 5 CONCLUÍDA: Gerenciador de Tarefas - 5 tipos de tarefa, painel, filtros, SMTP implementados"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-05-Tarefas.md`

***

### FASE 6: Integração com IA

**Objetivo:** Claude API, painel, barra de pesquisa, modo inline ///

**Tarefas:**

1. **Cliente Claude (`mini_core/src/ai_client.rs`):**
    - API Anthropic (claude-sonnet-4-20250514)
    - Configuração: api_key, model, max_tokens
    - Método `send_prompt()` async
2. **Painel IA (`mini_ui/src/ai_panel.rs`):**
    - Lateral, conversação scrollável
    - Input, loading state
    - Histórico de mensagens
3. **Barra de Pesquisa IA (`mini_ui/src/ai_search_bar.rs`):**
    - Toggle com atalho
    - Resposta inserida no cursor do arquivo em foreground
4. **Modo Inline /// (`mini_core/src/inline_ai.rs`):**
    - Detectar `/// [prompt]` + ENTER
    - Resposta na linha seguinte
5. **Autocompletar com IA:**
    - Integrar modo IA no autocomplete da Fase 4

**Dependências:**

```toml
reqwest = { version = "0.11", features = ["json"] }
tokio = { version = "1.0", features = ["full"] }
regex = "1.10"
```

**Testes Obrigatórios:**

```rust
#[test] fn test_inline_detector_valid_prompt() { }
#[test] fn test_inline_detector_normal_comment() { }
#[test] fn test_claude_client_requires_key() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 6 CONCLUÍDA: Integração IA - Painel, barra de pesquisa, modo inline /// implementados"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-06-IA.md`

***

### FASE 7: Sincronização ⚠️ TODOs PERMITIDOS

**Objetivo:** Git embutido, GitHub/GitLab, Google Drive

**Tarefas:**

1. **Git Embutido (`mini_sync/src/git/embedded.rs`):**
    - libgit2 bindings
    - init_or_open, add_all, commit, push
    - Detectar Git no SO, usar embutido se ausente
2. **Sync Manager (`mini_sync/src/sync_manager.rs`):**
    - SyncProvider enum: None, GitHub, GitLab, GoogleDrive
    - Auto-sync configurável (intervalo em minutos)
3. **OAuth Google (`mini_sync/src/gdrive/oauth.rs`):**
    - PKCE flow
    - Scopes: drive.file
    - **TODO permitido:** client_id/client_secret do GCP
4. **Arquivo .mini:**
    - Configuração de sync por pasta

**Dependências:**

```toml
git2 = "0.18"
oauth2 = "4.4"
```

**TODOs Esperados:**

```rust
// TODO: Configurar OAuth2 client_id/client_secret no GCP Console
// TODO: Criar repositório de teste para validação
// TODO: Implementar pull completo (fetch + merge + conflitos)
```

**Testes Obrigatórios:**

```rust
#[test] fn test_embedded_git_init() { }
#[test] fn test_sync_config_default() { }
#[test] fn test_mini_config_file_save_load() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 7 CONCLUÍDA: Sincronização (com TODOs) - Git embutido, OAuth estruturado, arquivo .mini OK"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-07-Sync.md`

***

### FASE 8: Atualizações e Ambiente SO ⚠️ TODOs PERMITIDOS

**Objetivo:** Auto-update, menu de contexto Windows, startup, i18n

**Tarefas:**

1. **Update Checker (`mini_updater/src/checker.rs`):**
    - Verificar versão disponível
    - **TODO:** URL do servidor de atualizações
2. **Menu de Contexto (`mini_os/src/windows/context_menu.rs`):**
    - "Abrir com mini" para arquivos
    - "Abrir pasta com mini" para diretórios
    - Registro no HKEY_CURRENT_USER
3. **Startup (`mini_os/src/windows/startup.rs`):**
    - Habilitar/desabilitar inicialização com Windows
    - Flag `--minimized` ao iniciar
4. **Internacionalização (`mini_os/src/i18n.rs`):**
    - pt-BR (padrão), en, zh
    - HashMap de traduções
    - Método `t(key)` para tradução

**Dependências:**

```toml
winreg = "0.52"
```

**Testes Obrigatórios:**

```rust
#[test] fn test_i18n_all_languages() { }
#[test] fn test_context_menu_registrar() { }
#[test] fn test_startup_manager() { }
```

**Notificação:**

```bash
cast.exe send tg me "FASE 8 CONCLUÍDA: Atualizações e SO (com TODOs) - Menu contexto, startup, i18n implementados"
```

**Relatório:** `D:\proj\mini\project-mini\reports\FASE-08-OS.md`

***

## 📝 FORMATO DOS RELATÓRIOS

Cada relatório em `D:\proj\mini\project-mini\reports\FASE-XX-Nome.md` deve seguir:

```markdown
# Relatório da Fase X - [Nome]
## Data: YYYY-MM-DD HH:MM
## Status: CONCLUÍDA

### Arquivos Criados/Modificados
- `crates/mini_xxx/src/arquivo.rs` - descrição

### Funcionalidades Implementadas
- [x] Funcionalidade 1
- [x] Funcionalidade 2

### Testes Criados
| Teste | Resultado |
|-------|-----------|
| test_xxx | ✅ PASS |

### Comandos de Verificação Executados
```

cargo clippy --all -- -D warnings  \# OK
cargo test --all                    \# X passed, 0 failed
cargo fmt --all -- --check          \# OK

```

### Decisões Técnicas
- Decisão 1: motivo
- Decisão 2: motivo

### Próxima Fase
Breve descrição do que será feito
```


***

## 🚀 INICIAR IMPLEMENTAÇÃO

**Comando para começar:**

```bash
cd D:\proj\mini
git checkout -b feature/mini-implementation
```

**Sequência de execução:**

1. FASE 0 → Notificar → Relatório → FASE 1
2. FASE 1 → Notificar → Relatório → FASE 2
3. ... (continuar até FASE 8)

**Ao finalizar TODAS as fases:**

```bash
cast.exe send tg me "🎉 IMPLEMENTAÇÃO COMPLETA DO MINI - Todas as 8 fases concluídas com sucesso!"
```


***

## 📚 REFERÊNCIAS

Os documentos de especificação completos estão disponíveis no Space "Editor Minimalista" do Perplexity:

1. **Requisitos-do-PO.md** - Requisitos originais do Product Owner
2. **Especificação Principal** - Documento consolidado com todas as fases
3. **Especificacoes-Incompletas.md** - Código Rust detalhado (Fases 0-6)
4. **Especificação Complementar** - Código Rust para Fases 6-8

***

**INICIE AGORA A IMPLEMENTAÇÃO PELA FASE 0.**
