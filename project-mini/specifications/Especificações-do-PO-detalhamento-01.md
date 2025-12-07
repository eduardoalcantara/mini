    fn suggest_dictionary(&self, text: &str) -> Vec<String> {
        // Carregar dicionário da língua (arquivo externo)
        // Por simplicidade, retornar lista vazia (expandir depois)
        Vec::new()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_suggest_words() {
        let engine = AutocompleteEngine::new(AutocompleteMode::Words);
        let suggestions = engine.suggest_words("hello world hello");
        assert!(suggestions.contains(&"hello".to_string()));
        assert!(suggestions.contains(&"world".to_string()));
    }
}
```

### Testes

**`crates/mini_core/tests/editor_config_test.rs`:**
```rust
use mini_core::editor_config::EditorConfig;
use std::path::PathBuf;

#[test]
fn test_font_for_txt_file() {
    let config = EditorConfig::new();
    let font = config.font_for_file(&PathBuf::from("test.txt"));
    assert_eq!(font.size, 16.0);
}

#[test]
fn test_font_for_code_file() {
    let config = EditorConfig::new();
    let font = config.font_for_file(&PathBuf::from("test.rs"));
    assert_eq!(font.size, 14.0);
}
```

**Adicionar ao `Cargo.toml`:**
```toml
[dependencies]
walkdir = "2.4"
dirs = "5.0"
```

### Critérios de Aceitação

- [ ] Fontes aplicadas automaticamente por extensão
- [ ] Help icons (?) aparecem nas funcionalidades
- [ ] Tooltip mostra resumo + link "Saiba mais"
- [ ] Clicar em "Saiba mais" abre aba de ajuda completa
- [ ] Pesquisa de arquivos (Ctrl+Shift+F) funcional
- [ ] Pesquisa busca em Home e Documentos
- [ ] Máximo 50 resultados para performance
- [ ] Autocompletar com Ctrl+Espaço (modo Words funcional)
- [ ] Todos os testes passam

### Notificação

```bash
cast.exe notify "FASE 4 CONCLUÍDA: Editor e Funcionalidades" "Fontes aplicadas por extensão. Sistema de ajuda implementado. Pesquisa global funcional. Autocompletar básico. Próxima fase: Gerenciador de Tarefas."
```

---

## FASE 5: GERENCIADOR DE TAREFAS

### Objetivos

1. Sistema completo de tarefas (simples, agendadas, recorrentes, compras, complexas)
2. Painel de tarefas (esquerda ou direita)
3. Filtros por texto, tag, tipo
4. Notificações por email (SMTP configurável)
5. Histórico de tarefas concluídas

### Modelo de Dados

**`crates/mini_core/src/task_manager.rs`:**

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use chrono::{DateTime, Local, NaiveDate, Weekday};

/// Tipo de tarefa.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum TaskType {
    /// Tarefa simples (descrição + ENTER)
    Simple,
    /// Tarefa agendada (data/hora específica)
    Scheduled { due_date: DateTime<Local> },
    /// Tarefa recorrente
    Recurring { recurrence: Recurrence },
    /// Item de compras
    Shopping,
    /// Tarefa complexa (com subtarefas)
    Complex { subtasks: Vec<Task> },
}

/// Padrão de recorrência.
#[derive(Debug, Clone, Serialize, Deserialize, PartialEq)]
pub enum Recurrence {
    Daily,
    Weekly { day: Weekday },
    Biweekly { day: Weekday },
    Monthly { day: u8 }, // 1-31
}

/// Status da tarefa.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum TaskStatus {
    /// Tarefa simples não realizada
    Pending,
    /// Tarefa agendada iminente
    Imminent,
    /// Tarefa agendada atrasada
    Overdue,
    /// Tarefa antiga (muitos dias sem realizar)
    Stale,
    /// Tarefa não iniciada (complexa)
    NotStarted,
    /// Tarefa iniciada (complexa)
    Started,
    /// Tarefa concluída
    Completed,
}

/// Tarefa individual.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct Task {
    pub id: String,
    pub description: String,
    pub task_type: TaskType,
    pub status: TaskStatus,
    pub tags: Vec<String>,
    pub created_at: DateTime<Local>,
    pub completed_at: Option<DateTime<Local>>,
    pub notes: String, // Para tarefas complexas
}

impl Task {
    pub fn new_simple(description: String) -> Self {
        Self {
            id: uuid::Uuid::new_v4().to_string(),
            description,
            task_type: TaskType::Simple,
            status: TaskStatus::Pending,
            tags: Vec::new(),
            created_at: Local::now(),
            completed_at: None,
            notes: String::new(),
        }
    }
    
    pub fn new_scheduled(description: String, due_date: DateTime<Local>) -> Self {
        let mut task = Self::new_simple(description);
        task.task_type = TaskType::Scheduled { due_date };
        task.status = TaskStatus::Pending;
        task
    }
    
    pub fn new_shopping(description: String) -> Self {
        let mut task = Self::new_simple(description);
        task.task_type = TaskType::Shopping;
        task.tags.push("compras".to_string());
        task
    }
    
    pub fn new_complex(description: String) -> Self {
        let mut task = Self::new_simple(description);
        task.task_type = TaskType::Complex { subtasks: Vec::new() };
        task.status = TaskStatus::NotStarted;
        task
    }
    
    /// Marca tarefa como concluída.
    pub fn complete(&mut self) {
        self.status = TaskStatus::Completed;
        self.completed_at = Some(Local::now());
    }
    
    /// Verifica se tarefa está atrasada.
    pub fn is_overdue(&self) -> bool {
        if let TaskType::Scheduled { due_date } = &self.task_type {
            Local::now() > *due_date && self.status != TaskStatus::Completed
        } else {
            false
        }
    }
    
    /// Verifica se tarefa está antiga (>30 dias sem completar).
    pub fn is_stale(&self) -> bool {
        let days = (Local::now() - self.created_at).num_days();
        days > 30 && self.status == TaskStatus::Pending
    }
}

/// Gerenciador de tarefas.
pub struct TaskManager {
    tasks: HashMap<String, Task>,
    completed_tasks: HashMap<String, Task>,
    auto_cleanup_days: u32,
}

impl TaskManager {
    pub fn new() -> Self {
        Self {
            tasks: HashMap::new(),
            completed_tasks: HashMap::new(),
            auto_cleanup_days: 30, // Remover completadas após 30 dias
        }
    }
    
    /// Adiciona nova tarefa.
    pub fn add_task(&mut self, task: Task) -> String {
        let id = task.id.clone();
        self.tasks.insert(id.clone(), task);
        id
    }
    
    /// Completa uma tarefa.
    pub fn complete_task(&mut self, id: &str) -> anyhow::Result<()> {
        if let Some(mut task) = self.tasks.remove(id) {
            task.complete();
            self.completed_tasks.insert(id.to_string(), task);
            Ok(())
        } else {
            anyhow::bail!("Tarefa não encontrada")
        }
    }
    
    /// Remove tarefas completadas antigas.
    pub fn cleanup_completed(&mut self) {
        let cutoff = Local::now() - chrono::Duration::days(self.auto_cleanup_days as i64);
        
        self.completed_tasks.retain(|_, task| {
            if let Some(completed_at) = task.completed_at {
                completed_at > cutoff
            } else {
                true
            }
        });
    }
    
    /// Filtra tarefas por texto.
    pub fn filter_by_text(&self, query: &str) -> Vec<&Task> {
        let query_lower = query.to_lowercase();
        self.tasks.values()
            .filter(|t| t.description.to_lowercase().contains(&query_lower))
            .collect()
    }
    
    /// Filtra tarefas por tag.
    pub fn filter_by_tag(&self, tag: &str) -> Vec<&Task> {
        self.tasks.values()
            .filter(|t| t.tags.contains(&tag.to_string()))
            .collect()
    }
    
    /// Filtra tarefas por tipo.
    pub fn filter_by_type(&self, task_type: &str) -> Vec<&Task> {
        self.tasks.values()
            .filter(|t| match (&t.task_type, task_type) {
                (TaskType::Simple, "simple") => true,
                (TaskType::Scheduled { .. }, "scheduled") => true,
                (TaskType::Shopping, "shopping") => true,
                (TaskType::Complex { .. }, "complex") => true,
                _ => false,
            })
            .collect()
    }
    
    /// Retorna todas as tarefas pendentes.
    pub fn pending_tasks(&self) -> Vec<&Task> {
        self.tasks.values()
            .filter(|t| t.status != TaskStatus::Completed)
            .collect()
    }
    
    /// Retorna tarefas completadas.
    pub fn completed_tasks(&self) -> Vec<&Task> {
        self.completed_tasks.values().collect()
    }
    
    /// Salva tarefas no disco.
    pub fn save(&self) -> anyhow::Result<()> {
        let path = Self::data_path()?;
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        
        let data = serde_json::to_string_pretty(&self.tasks)?;
        std::fs::write(&path, data)?;
        
        // Salvar completadas separadamente
        let completed_path = Self::completed_data_path()?;
        let completed_data = serde_json::to_string_pretty(&self.completed_tasks)?;
        std::fs::write(&completed_path, completed_data)?;
        
        Ok(())
    }
    
    /// Carrega tarefas do disco.
    pub fn load() -> anyhow::Result<Self> {
        let mut manager = Self::new();
        
        let path = Self::data_path()?;
        if path.exists() {
            let data = std::fs::read_to_string(&path)?;
            manager.tasks = serde_json::from_str(&data)?;
        }
        
        let completed_path = Self::completed_data_path()?;
        if completed_path.exists() {
            let data = std::fs::read_to_string(&completed_path)?;
            manager.completed_tasks = serde_json::from_str(&data)?;
        }
        
        Ok(manager)
    }
    
    fn data_path() -> anyhow::Result<std::path::PathBuf> {
        let mut path = dirs::config_dir()
            .ok_or_else(|| anyhow::anyhow!("Config dir não encontrado"))?;
        path.push("mini");
        path.push("tasks.json");
        Ok(path)
    }
    
    fn completed_data_path() -> anyhow::Result<std::path::PathBuf> {
        let mut path = dirs::config_dir()
            .ok_or_else(|| anyhow::anyhow!("Config dir não encontrado"))?;
        path.push("mini");
        path.push("tasks_completed.json");
        Ok(path)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_create_simple_task() {
        let task = Task::new_simple("Comprar leite".to_string());
        assert_eq!(task.status, TaskStatus::Pending);
        assert!(matches!(task.task_type, TaskType::Simple));
    }

    #[test]
    fn test_complete_task() {
        let mut manager = TaskManager::new();
        let id = manager.add_task(Task::new_simple("Test".to_string()));
        
        manager.complete_task(&id).unwrap();
        assert_eq!(manager.tasks.len(), 0);
        assert_eq!(manager.completed_tasks.len(), 1);
    }

    #[test]
    fn test_filter_by_tag() {
        let mut manager = TaskManager::new();
        let mut task = Task::new_simple("Test".to_string());
        task.tags.push("urgent".to_string());
        manager.add_task(task);
        
        let filtered = manager.filter_by_tag("urgent");
        assert_eq!(filtered.len(), 1);
    }
}
```

**Adicionar ao `Cargo.toml`:**
```toml
[dependencies]
uuid = { version = "1.6", features = ["v4", "serde"] }
chrono = { version = "0.4", features = ["serde"] }
```

### UI do Painel de Tarefas

**`crates/mini_ui/src/task_panel.rs`:**

```rust
use gpui::*;
use mini_core::{Task, TaskManager, TaskStatus};

/// Posição do painel de tarefas.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum TaskPanelPosition {
    Left,
    Right,
}

/// Painel de tarefas.
pub struct TaskPanel {
    manager: TaskManager,
    position: TaskPanelPosition,
    filter_text: String,
    show_completed: bool,
}

impl TaskPanel {
    pub fn new(cx: &mut ViewContext<Self>) -> Self {
        Self {
            manager: TaskManager::load().unwrap_or_else(|_| TaskManager::new()),
            position: TaskPanelPosition::Right,
            filter_text: String::new(),
            show_completed: false,
        }
    }
    
    pub fn add_simple_task(&mut self, description: String, cx: &mut ViewContext<Self>) {
        let task = Task::new_simple(description);
        self.manager.add_task(task);
        let _ = self.manager.save();
        cx.notify();
    }
    
    pub fn toggle_completed(&mut self, cx: &mut ViewContext<Self>) {
        self.show_completed = !self.show_completed;
        cx.notify();
    }
}

impl Render for TaskPanel {
    fn render(&mut self, cx: &mut ViewContext<Self>) -> impl IntoElement {
        let tasks = if self.show_completed {
            self.manager.completed_tasks()
        } else {
            self.manager.pending_tasks()
        };
        
        div()
            .w_80()
            .h_full()
            .bg(rgb(0xFAF6EF))
            .border_l_1()
            .border_color(rgb(0xEFEAE1))
            .flex()
            .flex_col()
            // Header
            .child(
                div()
                    .p_3()
                    .border_b_1()
                    .border_color(rgb(0xEFEAE1))
                    .child("TAREFAS")
            )
            // Botão adicionar
            .child(
                div()
                    .p_2()
                    .child(
                        button()
                            .w_full()
                            .p_2()
                            .bg(rgb(0x3484F7))
                            .text_color(rgb(0xFFFFFF))
                            .rounded_md()
                            .child("+ Nova Tarefa")
                    )
            )
            // Lista de tarefas
            .child(
                div()
                    .flex_1()
                    .overflow_y_auto()
                    .p_2()
                    .children(tasks.iter().map(|task| {
                        self.render_task_item(task, cx)
                    }))
            )
            // Footer
            .child(
                div()
                    .p_2()
                    .border_t_1()
                    .border_color(rgb(0xEFEAE1))
                    .flex()
                    .justify_between()
                    .child(
                        button()
                            .child("Completadas")
                            .on_click(cx.listener(|panel, _, cx| {
                                panel.toggle_completed(cx);
                            }))
                    )
                    .child(
                        button()
                            .child("Limpar")
                    )
            )
    }
    
    fn render_task_item(&self, task: &Task, cx: &mut ViewContext<Self>) -> impl IntoElement {
        let status_color = match task.status {
            TaskStatus::Pending => rgb(0x6B5E4F),
            TaskStatus::Overdue => rgb(0xF44336),
            TaskStatus::Stale => rgb(0xFF9800),
            TaskStatus::Completed => rgb(0x4CAF50),
            _ => rgb(0x2C2416),
        };
        
        div()
            .w_full()
            .p_2()
            .mb_1()
            .bg(rgb(0xF5F0E7))
            .rounded_md()
            .hover(|style| style.bg(rgb(0xEBE3D6)))
            .child(
                div()
                    .flex()
                    .gap_2()
                    // Checkbox
                    .child(
                        div()
                            .w_4()
                            .h_4()
                            .border_1()
                            .border_color(status_color)
                            .rounded_sm()
                    )
                    // Descrição
                    .child(
                        div()
                            .flex_1()
                            .text_sm()
                            .child(&task.description)
                    )
            )
            // Tags
            .when(!task.tags.is_empty(), |div| {
                div.child(
                    div()
                        .mt_1()
                        .flex()
                        .gap_1()
                        .children(task.tags.iter().map(|tag| {
                            div()
                                .px_2()
                                .py_0p5()
                                .bg(rgb(0xE8DCC8))
                                .text_xs()
                                .rounded_full()
                                .child(tag)
                        }))
                )
            })
    }
}
```

### Notificações por Email (SMTP)

**`crates/mini_core/src/email_notifier.rs`:**

```rust
use serde::{Deserialize, Serialize};
use lettre::{Message, SmtpTransport, Transport};
use lettre::transport::smtp::authentication::Credentials;

/// Configuração SMTP.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SmtpConfig {
    pub enabled: bool,
    pub server: String,
    pub port: u16,
    pub username: String,
    pub password: String, // ⚠️ Criptografar em produção
    pub from_email: String,
    pub to_email: String,
}

impl Default for SmtpConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            server: "smtp.gmail.com".to_string(),
            port: 587,
            username: String::new(),
            password: String::new(),
            from_email: String::new(),
            to_email: String::new(),
        }
    }
}

pub struct EmailNotifier {
    config: SmtpConfig,
}

impl EmailNotifier {
    pub fn new(config: SmtpConfig) -> Self {
        Self { config }
    }
    
    /// Envia notificação de tarefas pendentes.
    pub async fn send_daily_digest(&self, tasks: &[&super::task_manager::Task]) -> anyhow::Result<()> {
        if !self.config.enabled {
            return Ok(());
        }
        
        let body = self.format_digest(tasks);
        
        let email = Message::builder()
            .from(self.config.from_email.parse()?)
            .to(self.config.to_email.parse()?)
            .subject("mini - Tarefas Pendentes")
            .body(body)?;
        
        let creds = Credentials::new(
            self.config.username.clone(),
            self.config.password.clone(),
        );
        
        let mailer = SmtpTransport::relay(&self.config.server)?
            .credentials(creds)
            .build();
        
        mailer.send(&email)?;
        Ok(())
    }
    
    fn format_digest(&self, tasks: &[&super::task_manager::Task]) -> String {
        let mut body = String::from("Suas tarefas pendentes:\n\n");
        
        for task in tasks {
            body.push_str(&format!("• {}\n", task.description));
        }
        
        body.push_str("\n\nEnviado pelo mini editor.");
        body
    }
}
```

**Adicionar ao `Cargo.toml`:**
```toml
[dependencies]
lettre = { version = "0.11", features = ["smtp-transport", "builder"] }
```

### Testes

**`crates/mini_core/tests/task_integration.rs`:**
```rust
use mini_core::{Task, TaskManager, TaskType};

#[test]
fn test_full_task_workflow() {
    let mut manager = TaskManager::new();
    
    // Adicionar tarefas
    let simple_id = manager.add_task(Task::new_simple("Task 1".to_string()));
    let shopping_id = manager.add_task(Task::new_shopping("Comprar pão".to_string()));
    
    assert_eq!(manager.pending_tasks().len(), 2);
    
    // Filtrar por tag
    let shopping_tasks = manager.filter_by_tag("compras");
    assert_eq!(shopping_tasks.len(), 1);
    
    // Completar tarefa
    manager.complete_task(&simple_id).unwrap();
    assert_eq!(manager.pending_tasks().len(), 1);
    assert_eq!(manager.completed_tasks().len(), 1);
    
    // Salvar e carregar
    manager.save().unwrap();
    let loaded = TaskManager::load().unwrap();
    assert_eq!(loaded.pending_tasks().len(), 1);
}
```

### Critérios de Aceitação

- [ ] Todos os 5 tipos de tarefa funcionam (simples, agendada, recorrente, compras, complexa)
- [ ] Painel pode ficar à esquerda ou direita
- [ ] Filtros por texto, tag e tipo funcionam
- [ ] Tarefas completadas movem para histórico
- [ ] Limpeza automática após N dias configurável
- [ ] Tags customizadas podem ser adicionadas
- [ ] SMTP configurável (mas não obrigatório)
- [ ] Notificação diária opcional por email
- [ ] Persistência funcional (salva/carrega do disco)
- [ ] Todos os testes passam

### Notificação

```bash
cast.exe notify "FASE 5 CONCLUÍDA: Gerenciador de Tarefas" "Sistema completo de tarefas implementado. 5 tipos de tarefa. Filtros funcionais. Notificações SMTP opcionais. Próxima fase: Integração com IA."
```

---

## FASE 6: INTEGRAÇÃO COM IA

### Objetivos

1. Integração com Claude API (Anthropic)
2. Painel exclusivo de IA (lateral)
3. Barra de pesquisa inline
4. Prompt com `///` + ENTER
5. Inline Assistant
6. Autocompletar com IA (integrar com FASE 4)

### Dependências

**Adicionar ao `crates/mini_core/Cargo.toml`:**
```toml
[dependencies]
reqwest = { version = "0.11", features = ["json"] }
tokio = { version = "1.0", features = ["full"] }
serde_json = "1.0"
```

### Cliente Claude API

**`crates/mini_core/src/ai_client.rs`:**

```rust
use serde::{Deserialize, Serialize};
use anyhow::Result;

const CLAUDE_API_URL: &str = "https://api.anthropic.com/v1/messages";
const CLAUDE_MODEL: &str = "claude-sonnet-4-20250514";

/// Configuração da API Claude.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct ClaudeConfig {
    pub api_key: String,
    pub model: String,
    pub max_tokens: u32,
}

impl Default for ClaudeConfig {
    fn default() -> Self {
        Self {
            api_key: String::new(),
            model: CLAUDE_MODEL.to_string(),
            max_tokens: 1024,
        }
    }
}

/// Request para API Claude.
#[derive(Debug, Serialize)]
struct ClaudeRequest {
    model: String,
    max_tokens: u32,
    messages: Vec<Message>,
}

#[derive(Debug, Serialize, Deserialize, Clone)]
struct Message {
    role: String,
    content: String,
}

/// Response da API Claude.
#[derive(Debug, Deserialize)]
struct ClaudeResponse {
    content: Vec<ContentBlock>,
}

#[derive(Debug, Deserialize)]
struct ContentBlock {
    #[serde(rename = "type")]
    content_type: String,
    text: Option<String>,
}

/// Cliente para API Claude.
pub struct ClaudeClient {
    config: ClaudeConfig,
    client: reqwest::Client,
}

impl ClaudeClient {
    pub fn new(config: ClaudeConfig) -> Self {
        Self {
            config,
            client: reqwest::Client::new(),
        }
    }
    
    /// Envia prompt para Claude e retorna resposta.
    pub async fn send_prompt(&self, prompt: String) -> Result<String> {
        if self.config.api_key.is_empty() {
            anyhow::bail!("API key não configurada");
        }
        
        let request = ClaudeRequest {
            model: self.config.model.clone(),
            max_tokens: self.config.max_tokens,
            messages: vec![Message {
                role: "user".to_string(),
                content: prompt,
            }],
        };
        
        let response = self.client
            .post(CLAUDE_API_URL)
            .header("x-api-key", &self.config.api_key)
            .header("anthropic-version", "2023-06-01")
            .header("content-type", "application/json")
            .json(&request)
            .send()
            .await?;
        
        if !response.status().is_success() {
            let status = response.status();
            let body = response.text().await?;
            anyhow::bail!("Erro na API Claude ({}): {}", status, body);
        }
        
        let claude_response: ClaudeResponse = response.json().await?;
        
        // Extrair texto da resposta
        let text = claude_response.content
            .into_iter()
            .filter_map(|block| block.text)
            .collect::<Vec<_>>()
            .join("\n");
        
        Ok(text)
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_claude_client_without_key() {
        let client = ClaudeClient::new(ClaudeConfig::default());
        let result = client.send_prompt("test".to_string()).await;
        assert!(result.is_err());
    }
}
```

### Painel de IA

**`crates/mini_ui/src/ai_panel.rs`:**

```rust
use gpui::*;
use mini_core::{ClaudeClient, ClaudeConfig};

/// Painel lateral de IA.
pub struct AiPanel {
    client: ClaudeClient,
    conversation: Vec<ConversationMessage>,
    input_text: String,
    is_loading: bool,
}

#[derive(Debug, Clone)]
struct ConversationMessage {
    role: String, // "user" ou "assistant"
    content: String,
}

impl AiPanel {
    pub fn new(config: ClaudeConfig, cx: &mut ViewContext<Self>) -> Self {
        Self {
            client: ClaudeClient::new(config),
            conversation: Vec::new(),
            input_text: String::new(),
            is_loading: false,
        }
    }
    
    pub fn send_message(&mut self, message: String, cx: &mut ViewContext<Self>) {
        if message.is_empty() || self.is_loading {
            return;
        }
        
        // Adicionar mensagem do usuário
        self.conversation.push(ConversationMessage {
            role: "user".to_string(),
            content: message.clone(),
        });
        
        self.input_text.clear();
        self.is_loading = true;
        cx.notify();
        
        // Enviar para Claude
        let client = self.client.clone();
        cx.spawn(|ai_panel, mut cx| async move {
            match client.send_prompt(message).await {
                Ok(response) => {
                    ai_panel.update(&mut cx, |panel, cx| {
                        panel.conversation.push(ConversationMessage {
                            role: "assistant".to_string(),
                            content: response,
                        });
                        panel.is_loading = false;
                        cx.notify();
                    }).ok();
                }
                Err(e) => {
                    ai_panel.update(&mut cx, |panel, cx| {
                        panel.conversation.push(ConversationMessage {
                            role: "assistant".to_string(),
                            content: format!("Erro: {}", e),
                        });
                        panel.is_loading = false;
                        cx.notify();
                    }).ok();
                }# ESPECIFICAÇÃO TÉCNICA PARA IMPLEMENTAÇÃO - MINI EDITOR

**Projeto:** mini (Minimalist, Intelligent, Nice Interface)  
**Versão:** 1.0  
**Data:** 06/12/2024  
**Base Tecnológica:** Zed Editor (Rust + GPUI)  
**Autor:** Eduardo Alcântara (PO) + Claude (Supervisor de Desenvolvimento)

---

## 📋 ÍNDICE

1. [Contexto e Base Tecnológica](#contexto-e-base-tecnológica)
2. [Princípios de Desenvolvimento](#princípios-de-desenvolvimento)
3. [Organização em Fases](#organização-em-fases)
4. [Especificações Detalhadas por Fase](#especificações-detalhadas-por-fase)
5. [Padrões de Código Rust](#padrões-de-código-rust)
6. [Testes Automatizados](#testes-automatizados)
7. [Notificação de Conclusão](#notificação-de-conclusão)
8. [Glossário e Convenções](#glossário-e-convenções)

---

## 🎯 CONTEXTO E BASE TECNOLÓGICA

### Base: Zed Editor

O **mini** é construído sobre o **Zed Editor**, um editor de código moderno escrito em **Rust** utilizando o framework **GPUI** para interface gráfica.

**Stack Tecnológica:**
- **Linguagem:** Rust (stable, latest)
- **UI Framework:** GPUI (framework próprio do Zed)
- **Build System:** Cargo (Rust package manager)
- **Platform:** Windows 11 (primário), com suporte futuro para macOS e Linux

**Estrutura de Crates do Zed:**
```
crates/
├── zed/                    # Aplicação principal
├── editor/                 # Core do editor de texto
├── workspace/              # Gerenciamento de workspace
├── gpui/                   # Framework de UI
├── theme/                  # Sistema de temas
├── settings/               # Configurações
├── fs/                     # File system
├── ui/                     # Componentes de UI
└── ...
```

### Diferenças Cruciais vs Electron/VSCode

| Aspecto | Electron/VSCode | Zed/Rust |
|---------|-----------------|----------|
| **Linguagem** | TypeScript/JavaScript | Rust |
| **UI Framework** | HTML/CSS/React | GPUI (nativo) |
| **Performance** | ~300-500MB RAM | ~100-200MB RAM |
| **Startup** | ~2-3s | ~500ms |
| **Threading** | Node.js (single-thread) | Tokio (async multi-thread) |
| **Build** | npm/webpack | Cargo |

### Implicações para o mini

1. **Não usar conceitos de Electron** (IPC, renderer/main process)
2. **Não usar HTML/CSS** - UI é código Rust + GPUI
3. **Não usar npm/Node.js** - tudo é Cargo + Rust
4. **Performance nativa** - binário compilado, não interpretado

---

## 🏗️ PRINCÍPIOS DE DESENVOLVIMENTO

### 1. Código Completo e Funcional

**NUNCA deixar TODOs no código, EXCETO:**
- ⚠️ FASE 7 (Sincronização) - dependências de OAuth Google/GitHub
- ⚠️ FASE 8 (Atualizações) - dependências de servidor de updates

**Para todo o resto:**
- Implementar 100% da funcionalidade
- Se algo é complexo, dividir em sub-tarefas menores
- Se falta informação, usar defaults sensatos e documentar

### 2. Padrões Nativos do Rust

**Usar idiomas e padrões Rust:**
- `Result<T, E>` para error handling
- `Option<T>` para valores opcionais
- Traits para abstração
- Pattern matching extensivo
- Ownership e borrowing adequados
- Async/await com Tokio

**NÃO forçar DDD ou padrões OOP:**
- Rust favorece composição sobre herança
- Usar structs + traits ao invés de classes
- Módulos e crates para organização

### 3. Separação de Responsabilidades

**Organização de crates sugerida para o mini:**

```
crates/
├── mini/                   # Aplicação principal (binary crate)
│   ├── src/
│   │   ├── main.rs        # Entry point
│   │   └── app.rs         # Inicialização do app
│
├── mini_core/              # Lógica de negócio (library crate)
│   ├── src/
│   │   ├── lib.rs
│   │   ├── file_manager.rs      # Gerenciamento de arquivos
│   │   ├── session.rs           # Gerenciamento de sessão
│   │   ├── task_manager.rs      # Gerenciador de tarefas
│   │   └── config.rs            # Configurações
│
├── mini_ui/                # Componentes de UI (library crate)
│   ├── src/
│   │   ├── lib.rs
│   │   ├── tray_icon.rs         # Tray icon
│   │   ├── window_manager.rs    # Gerenciamento de janela
│   │   ├── sidebar.rs           # Painel lateral
│   │   ├── statusbar.rs         # Barra de status
│   │   └── tabs.rs              # Sistema de abas
│
├── mini_sync/              # Sincronização (library crate)
│   ├── src/
│   │   ├── lib.rs
│   │   ├── github.rs            # Sync GitHub
│   │   └── gdrive.rs            # Sync Google Drive
│
└── mini_theme/             # Temas customizados (library crate)
    ├── src/
    │   ├── lib.rs
    │   └── moleskine.rs         # Tema Moleskine Light
```

### 4. Testes Obrigatórios

**Cada fase DEVE incluir:**
- Unit tests (`#[cfg(test)]` módulos)
- Integration tests (pasta `tests/`)
- Cobertura mínima: 70%
- CI/CD automático (GitHub Actions)

### 5. Documentação Inline

**Todo código público DEVE ter:**
```rust
/// Gerencia a janela principal do mini.
///
/// # Examples
///
/// ```
/// let manager = WindowManager::new();
/// manager.set_position(100, 100);
/// ```
pub struct WindowManager {
    // ...
}
```

---

## 📅 ORGANIZAÇÃO EM FASES

### FASE 0: Setup e Rebranding Zed → mini
**Duração Estimada:** 2-4 horas  
**Objetivo:** Preparar base do projeto com nome "mini"

### FASE 1: Trayicon e Gerenciamento de Janela ⭐ PRIORIDADE
**Duração Estimada:** 4-6 horas  
**Objetivo:** Implementar trayicon e controle de posicionamento/tamanho

### FASE 2: UI/UX Foundation
**Duração Estimada:** 6-8 horas  
**Objetivo:** Tema Moleskine, dimensionamento, movimento

### FASE 3: Sistema de Arquivos e Navegação
**Duração Estimada:** 8-10 horas  
**Objetivo:** Modos Pasta/Solto, painel lateral

### FASE 4: Editor e Funcionalidades de Texto
**Duração Estimada:** 6-8 horas  
**Objetivo:** Fontes customizadas, ajuda, pesquisa

### FASE 5: Gerenciador de Tarefas
**Duração Estimada:** 10-12 horas  
**Objetivo:** Sistema completo de tarefas

### FASE 6: Integração com IA
**Duração Estimada:** 4-6 horas  
**Objetivo:** Agente Claude via API

### FASE 7: Sincronização ⚠️ TODOs Permitidos
**Duração Estimada:** 12-16 horas  
**Objetivo:** GitHub e Google Drive sync

### FASE 8: Atualizações e Ambiente SO ⚠️ TODOs Permitidos
**Duração Estimada:** 6-8 horas  
**Objetivo:** Auto-update, menu de contexto

**TEMPO TOTAL ESTIMADO:** 58-78 horas (~7-10 dias úteis)

---

## 🔧 ESPECIFICAÇÕES DETALHADAS POR FASE

---

## FASE 0: SETUP E REBRANDING ZED → MINI

### Objetivos

1. Clonar repositório do Zed
2. Renomear todos os componentes para "mini"
3. Configurar ambiente de desenvolvimento
4. Compilar pela primeira vez

### Tarefas

#### 1. Clone e Configuração Inicial

```bash
# Clone do Zed
git clone https://github.com/zed-industries/zed.git mini-editor
cd mini-editor

# Configurar remote upstream para updates futuros
git remote rename origin upstream
git remote add origin https://github.com/eduardoalcantara/mini-editor.git

# Criar branch de desenvolvimento
git checkout -b feature/rebranding
```

#### 2. Renomeação de Crates

**Arquivos a modificar:**

**`Cargo.toml` (workspace root):**
```toml
[workspace]
members = [
    "crates/mini",           # era crates/zed
    "crates/mini_core",      # novo
    "crates/mini_ui",        # novo
    "crates/mini_theme",     # novo
    "crates/editor",         # manter do Zed
    "crates/gpui",           # manter do Zed
    "crates/workspace",      # manter do Zed
    # ... outros crates do Zed
]

[workspace.package]
version = "0.1.0"
edition = "2021"
authors = ["Eduardo Alcântara <email@exemplo.com>"]
license = "GPL-3.0"
```

**`crates/zed/` → `crates/mini/`:**
```bash
# Renomear diretório
mv crates/zed crates/mini

# Atualizar Cargo.toml
# crates/mini/Cargo.toml
```

```toml
[package]
name = "mini"
description = "Minimalist, Intelligent, Nice Interface - A clean text editor"
version = "0.1.0"
edition = "2021"
authors = ["Eduardo Alcântara <email@exemplo.com>"]
license = "GPL-3.0"

[[bin]]
name = "mini"
path = "src/main.rs"

[dependencies]
gpui = { path = "../gpui" }
editor = { path = "../editor" }
workspace = { path = "../workspace" }
mini_core = { path = "../mini_core" }
mini_ui = { path = "../mini_ui" }
# ... outras dependências
```

#### 3. Criar Novos Crates do mini

**Criar `crates/mini_core/`:**
```bash
cargo new --lib crates/mini_core
```

**`crates/mini_core/Cargo.toml`:**
```toml
[package]
name = "mini_core"
version = "0.1.0"
edition = "2021"

[dependencies]
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
tokio = { version = "1.0", features = ["full"] }
anyhow = "1.0"
```

**`crates/mini_core/src/lib.rs`:**
```rust
//! Lógica de negócio central do mini editor.

pub mod config;
pub mod file_manager;
pub mod session;

pub use config::Config;
pub use file_manager::FileManager;
pub use session::Session;
```

**Repetir para `mini_ui` e `mini_theme`.**

#### 4. Busca e Substituição Global

**Script de renomeação (bash/PowerShell):**
```bash
# Encontrar e substituir "zed" por "mini" em código Rust
find crates/ -name "*.rs" -type f -exec sed -i 's/use zed::/use mini::/g' {} +
find crates/ -name "*.rs" -type f -exec sed -i 's/\"Zed\"/\"mini\"/g' {} +

# Atualizar strings de UI
find crates/ -name "*.rs" -type f -exec sed -i 's/\"Zed Editor\"/\"mini Editor\"/g' {} +
```

**Verificar manualmente:**
- `crates/mini/src/main.rs` - Entry point
- `crates/workspace/` - Títulos de janelas
- `crates/editor/` - Nomes de comandos

#### 5. Configuração de Build

**`.cargo/config.toml`:**
```toml
[build]
target = "x86_64-pc-windows-msvc"

[target.x86_64-pc-windows-msvc]
rustflags = ["-C", "link-arg=/SUBSYSTEM:WINDOWS"]
```

#### 6. Primeira Compilação

```bash
# Build completo
cargo build --release

# Executar
./target/release/mini.exe

# Verificar que abre janela com título "mini"
```

### Testes

**Criar `crates/mini_core/tests/integration_test.rs`:**
```rust
#[test]
fn test_mini_builds() {
    // Verifica que o projeto compila
    assert!(true);
}

#[test]
fn test_config_loads() {
    use mini_core::Config;
    let config = Config::default();
    assert_eq!(config.app_name(), "mini");
}
```

**Executar:**
```bash
cargo test --all
```

### Critérios de Aceitação

- [ ] Compilação bem-sucedida sem erros
- [ ] Executável `mini.exe` gerado
- [ ] Janela abre com título "mini"
- [ ] Nenhuma referência a "Zed" na UI visível
- [ ] Configurações salvam em `%APPDATA%/mini/`
- [ ] Todos os testes passam

### Notificação

**Ao concluir, executar:**
```bash
cast.exe notify "FASE 0 CONCLUÍDA: Setup e Rebranding mini" "Compilação bem-sucedida. Executável mini.exe gerado. Próxima fase: Trayicon."
```

---

## FASE 1: TRAYICON E GERENCIAMENTO DE JANELA ⭐

### Objetivos

1. Implementar tray icon no Windows
2. Minimizar/restaurar para tray
3. Salvar/restaurar posição e tamanho da janela
4. Menu de contexto no tray icon

### Dependências

**Adicionar ao `crates/mini_ui/Cargo.toml`:**
```toml
[dependencies]
gpui = { path = "../gpui" }
windows = { version = "0.52", features = [
    "Win32_UI_Shell",
    "Win32_UI_WindowsAndMessaging",
    "Win32_Foundation",
    "Win32_System_LibraryLoader",
    "Win32_Graphics_Gdi",
]}
```

### Arquitetura

**Módulos:**
```
crates/mini_ui/src/
├── lib.rs
├── tray_icon.rs           # Implementação do tray icon
├── window_manager.rs      # Gerenciamento de janela
└── window_state.rs        # Persistência de estado
```

### Implementação

#### `crates/mini_ui/src/window_state.rs`

```rust
use serde::{Deserialize, Serialize};
use std::path::PathBuf;

/// Estado da janela (posição, tamanho, monitor).
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct WindowState {
    pub x: i32,
    pub y: i32,
    pub width: u32,
    pub height: u32,
    pub monitor_id: Option<String>,
    pub is_maximized: bool,
}

impl Default for WindowState {
    fn default() -> Self {
        Self {
            x: 100,
            y: 100,
            width: 1200,
            height: 800,
            monitor_id: None,
            is_maximized: false,
        }
    }
}

impl WindowState {
    /// Carrega estado salvo do disco.
    pub fn load() -> anyhow::Result<Self> {
        let path = Self::config_path()?;
        if !path.exists() {
            return Ok(Self::default());
        }
        
        let content = std::fs::read_to_string(&path)?;
        let state: WindowState = serde_json::from_str(&content)?;
        Ok(state)
    }

    /// Salva estado no disco.
    pub fn save(&self) -> anyhow::Result<()> {
        let path = Self::config_path()?;
        if let Some(parent) = path.parent() {
            std::fs::create_dir_all(parent)?;
        }
        
        let content = serde_json::to_string_pretty(self)?;
        std::fs::write(&path, content)?;
        Ok(())
    }

    fn config_path() -> anyhow::Result<PathBuf> {
        let mut path = dirs::config_dir()
            .ok_or_else(|| anyhow::anyhow!("Não foi possível encontrar diretório de config"))?;
        path.push("mini");
        path.push("window_state.json");
        Ok(path)
    }
}
```

#### `crates/mini_ui/src/window_manager.rs`

```rust
use crate::window_state::WindowState;
use anyhow::Result;
use gpui::{WindowBounds, WindowOptions, AppContext};

/// Gerencia posição, tamanho e estado da janela principal.
pub struct WindowManager {
    state: WindowState,
}

impl WindowManager {
    /// Cria novo gerenciador, carregando estado salvo.
    pub fn new() -> Result<Self> {
        let state = WindowState::load().unwrap_or_default();
        Ok(Self { state })
    }

    /// Retorna opções de janela baseadas no estado salvo.
    pub fn window_options(&self) -> WindowOptions {
        WindowOptions {
            bounds: if self.state.is_maximized {
                WindowBounds::Maximized
            } else {
                WindowBounds::Fixed(gpui::Bounds {
                    origin: gpui::Point {
                        x: self.state.x as f64,
                        y: self.state.y as f64,
                    },
                    size: gpui::Size {
                        width: self.state.width as f64,
                        height: self.state.height as f64,
                    },
                })
            },
            titlebar: None, // Customizar depois
            center: false,
            focus: true,
            show: true,
            kind: gpui::WindowKind::Normal,
            is_movable: true,
            display_id: None,
        }
    }

    /// Atualiza estado atual da janela.
    pub fn update_state(&mut self, x: i32, y: i32, width: u32, height: u32, is_maximized: bool) {
        // Só salvar posição se não estiver maximizado
        if !is_maximized {
            self.state.x = x;
            self.state.y = y;
            self.state.width = width;
            self.state.height = height;
        }
        self.state.is_maximized = is_maximized;
    }

    /// Salva estado atual no disco.
    pub fn save_state(&self) -> Result<()> {
        self.state.save()
    }

    /// Aplica margem de 10px das bordas do monitor.
    pub fn apply_screen_margins(&mut self, screen_width: u32, screen_height: u32) {
        const MARGIN: i32 = 10;
        
        // Ajustar X
        if self.state.x < MARGIN {
            self.state.x = MARGIN;
        }
        if self.state.x + self.state.width as i32 > screen_width as i32 - MARGIN {
            self.state.x = screen_width as i32 - self.state.width as i32 - MARGIN;
        }
        
        // Ajustar Y (considerar barra de tarefas)
        if self.state.y < MARGIN {
            self.state.y = MARGIN;
        }
        if self.state.y + self.state.height as i32 > screen_height as i32 - MARGIN {
            self.state.y = screen_height as i32 - self.state.height as i32 - MARGIN;
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_window_manager_creation() {
        let manager = WindowManager::new();
        assert!(manager.is_ok());
    }

    #[test]
    fn test_apply_margins() {
        let mut manager = WindowManager::new().unwrap();
        manager.update_state(0, 0, 800, 600, false);
        manager.apply_screen_margins(1920, 1080);
        
        assert_eq!(manager.state.x, 10);
        assert_eq!(manager.state.y, 10);
    }
}
```

#### `crates/mini_ui/src/tray_icon.rs`

```rust
use windows::Win32::UI::Shell::{
    Shell_NotifyIconW, NIF_ICON, NIF_MESSAGE, NIF_TIP, NIM_ADD, NIM_DELETE, 
    NIM_MODIFY, NOTIFYICONDATAW,
};
use windows::Win32::UI::WindowsAndMessaging::{
    LoadImageW, IMAGE_ICON, LR_DEFAULTSIZE, LR_LOADFROMFILE,
};
use windows::Win32::Foundation::{HWND, LPARAM, WPARAM};
use windows::core::PCWSTR;
use std::path::PathBuf;

const WM_TRAYICON: u32 = 0x8000; // Mensagem customizada

/// Gerencia o tray icon do Windows.
pub struct TrayIcon {
    hwnd: HWND,
    icon_path: PathBuf,
}

impl TrayIcon {
    /// Cria novo tray icon.
    pub fn new(hwnd: HWND) -> anyhow::Result<Self> {
        let icon_path = Self::get_icon_path()?;
        let mut tray = Self { hwnd, icon_path };
        tray.add()?;
        Ok(tray)
    }

    /// Adiciona ícone à bandeja.
    fn add(&self) -> anyhow::Result<()> {
        unsafe {
            let mut nid = self.create_notify_icon_data();
            nid.uFlags = NIF_ICON | NIF_MESSAGE | NIF_TIP;
            
            let success = Shell_NotifyIconW(NIM_ADD, &nid).as_bool();
            if !success {
                anyhow::bail!("Falha ao adicionar tray icon");
            }
        }
        Ok(())
    }

    /// Remove ícone da bandeja.
    pub fn remove(&self) -> anyhow::Result<()> {
        unsafe {
            let nid = self.create_notify_icon_data();
            Shell_NotifyIconW(NIM_DELETE, &nid);
        }
        Ok(())
    }

    /// Atualiza tooltip do ícone.
    pub fn set_tooltip(&self, text: &str) -> anyhow::Result<()> {
        unsafe {
            let mut nid = self.create_notify_icon_data();
            nid.uFlags = NIF_TIP;
            
            let wide: Vec<u16> = text.encode_utf16().chain(std::iter::once(0)).collect();
            nid.szTip[..wide.len().min(128)].copy_from_slice(&wide[..wide.len().min(128)]);
            
            Shell_NotifyIconW(NIM_MODIFY, &nid);
        }
        Ok(())
    }

    fn create_notify_icon_data(&self) -> NOTIFYICONDATAW {
        unsafe {
            let mut nid: NOTIFYICONDATAW = std::mem::zeroed();
            nid.cbSize = std::mem::size_of::<NOTIFYICONDATAW>() as u32;
            nid.hWnd = self.hwnd;
            nid.uID = 1;
            nid.uCallbackMessage = WM_TRAYICON;
            
            // Carregar ícone
            let icon_path_wide: Vec<u16> = self.icon_path
                .to_string_lossy()
                .encode_utf16()
                .chain(std::iter::once(0))
                .collect();
            
            nid.hIcon = LoadImageW(
                None,
                PCWSTR(icon_path_wide.as_ptr()),
                IMAGE_ICON,
                0,
                0,
                LR_LOADFROMFILE | LR_DEFAULTSIZE,
            ).unwrap_or_default().0 as *mut _;
            
            nid
        }
    }

    fn get_icon_path() -> anyhow::Result<PathBuf> {
        let mut path = std::env::current_exe()?;
        path.pop(); // Remove exe name
        path.push("assets");
        path.push("icon.ico");
        Ok(path)
    }
}

impl Drop for TrayIcon {
    fn drop(&mut self) {
        let _ = self.remove();
    }
}
```

#### `crates/mini/src/main.rs` (integração)

```rust
use mini_ui::{WindowManager, TrayIcon};
use gpui::*;

fn main() {
    env_logger::init();
    
    App::new().run(|cx: &mut AppContext| {
        // Carregar estado da janela
        let window_manager = WindowManager::new()
            .expect("Falha ao criar WindowManager");
        
        // Criar janela principal
        let window_options = window_manager.window_options();
        cx.open_window(window_options, |cx| {
            // Criar tray icon
            // Nota: hwnd precisa ser obtido do GPUI
            // let tray = TrayIcon::new(hwnd).expect("Falha ao criar tray icon");
            
            // Configurar workspace
            cx.new_view(|cx| {
                // Workspace view aqui
            })
        });
    });
}
```

### Menu de Contexto do Tray

**Adicionar ao `tray_icon.rs`:**

```rust
use windows::Win32::UI::WindowsAndMessaging::{
    CreatePopupMenu, AppendMenuW, TrackPopupMenu, TPM_BOTTOMALIGN, TPM_LEFTALIGN,
    MF_STRING, HMENU,
};

impl TrayIcon {
    /// Mostra menu de contexto.
    pub fn show_context_menu(&self, x: i32, y: i32) -> anyhow::Result<()> {
        unsafe {
            let menu = CreatePopupMenu()?;
            
            self.append_menu_item(menu, 1, "Abrir mini")?;
            self.append_menu_item(menu, 2, "Sincronizar")?;
            self.append_menu_separator(menu)?;
            self.append_menu_item(menu, 100, "Sair")?;
            
            TrackPopupMenu(
                menu,
                TPM_BOTTOMALIGN | TPM_LEFTALIGN,
                x,
                y,
                0,
                self.hwnd,
                None,
            );
        }
        Ok(())
    }

    unsafe fn append_menu_item(&self, menu: HMENU, id: u32, text: &str) -> anyhow::Result<()> {
        let wide: Vec<u16> = text.encode_utf16().chain(std::iter::once(0)).collect();
        AppendMenuW(menu, MF_STRING, id as usize, PCWSTR(wide.as_ptr()))?;
        Ok(())
    }

    unsafe fn append_menu_separator(&self, menu: HMENU) -> anyhow::Result<()> {
        AppendMenuW(menu, windows::Win32::UI::WindowsAndMessaging::MF_SEPARATOR, 0, None)?;
        Ok(())
    }
}
```

### Testes

**`crates/mini_ui/tests/window_state_test.rs`:**
```rust
use mini_ui::WindowState;

#[test]
fn test_window_state_default() {
    let state = WindowState::default();
    assert_eq!(state.width, 1200);
    assert_eq!(state.height, 800);
}

#[test]
fn test_window_state_save_load() {
    let mut state = WindowState::default();
    state.x = 200;
    state.y = 300;
    
    state.save().expect("Falha ao salvar");
    
    let loaded = WindowState::load().expect("Falha ao carregar");
    assert_eq!(loaded.x, 200);
    assert_eq!(loaded.y, 300);
}
```

### Critérios de Aceitação

- [ ] Tray icon aparece na bandeja do Windows
- [ ] Clicar no tray icon minimiza/restaura a janela
- [ ] Botão direito no tray icon mostra menu de contexto
- [ ] Posição e tamanho da janela são salvos ao fechar
- [ ] Janela reabre na mesma posição (modo normal)
- [ ] Janela reabre maximizada se foi fechada maximizada
- [ ] Margem de 10px das bordas é respeitada
- [ ] Todos os testes passam (`cargo test --all`)

### Notificação

```bash
cast.exe notify "FASE 1 CONCLUÍDA: Trayicon e Gerenciamento de Janela" "Tray icon funcional. Posicionamento persistente implementado. Próxima fase: UI/UX Foundation."
```

---

## FASE 2: UI/UX FOUNDATION

### Objetivos

1. Implementar Tema Moleskine Light (Vanilla Cream)
2. Configurar dimensionamento da janela
3. Implementar movimento da janela (livre/assistido/bloqueado)
4. Fade in/out ao minimizar/restaurar
5. Fontes customizadas por extensão de arquivo

### Tema Moleskine Light

**Criar `crates/mini_theme/src/moleskine.rs`:**

```rust
use gpui::{rgb, rgba, FontFamily, FontWeight, SharedString};
use theme::{Theme, ThemeColors, ThemeSettings};

/// Paleta de cores Moleskine Light (Vanilla Cream).
pub struct MoleskineColors {
    /// Fundo principal - Vanilla Cream
    pub background: gpui::Rgba,
    /// Texto principal - Dark Brown
    pub foreground: gpui::Rgba,
    /// Texto secundário - Medium Brown
    pub secondary: gpui::Rgba,
    /// Bordas e divisores - Light Beige
    pub border: gpui::Rgba,
    /// Acentos (links, highlights) - Soft Blue
    pub accent: gpui::Rgba,
    /// Hover states - Warm Hover
    pub hover: gpui::Rgba,
    /// Seleção de texto - Selection Beige
    pub selection: gpui::Rgba,
}

impl Default for MoleskineColors {
    fn default() -> Self {
        Self {
            background: rgba(0xFAF6EFff), // #FAF6EF
            foreground: rgba(0x2C2416ff), // #2C2416
            secondary: rgba(0x6B5E4Fff),  // #6B5E4F
            border: rgba(0xEFEAE1ff),     // #EFEAE1
            accent: rgba(0x3484F7ff),     // #3484F7
            hover: rgba(0xF5F0E7ff),      // #F5F0E7
            selection: rgba(0xE8DCC8B3),  // #E8DCC8 com 70% opacity
        }
    }
}

/// Cria tema Moleskine Light completo.
pub fn create_moleskine_theme() -> Theme {
    let colors = MoleskineColors::default();
    
    Theme {
        name: SharedString::from("Moleskine Light"),
        appearance: theme::Appearance::Light,
        colors: ThemeColors {
            editor_background: colors.background,
            editor_foreground: colors.foreground,
            editor_selection: colors.selection,
            editor_line_highlight: rgba(0xF5F0E710), // Muito sutil
            
            // UI Colors
            panel_background: colors.background,
            panel_border: colors.border,
            
            tab_bar_background: colors.hover,
            tab_inactive_background: colors.hover,
            tab_active_background: colors.background,
            
            status_bar_background: colors.background,
            status_bar_foreground: colors.secondary,
            
            // Syntax Highlighting
            syntax_comment: rgba(0x8B7355ff),    // Comments
            syntax_keyword: rgba(0x8B4513ff),    // Keywords
            syntax_string: rgba(0x2E7D32ff),     // Strings
            syntax_number: rgba(0x1565C0ff),     // Numbers
            syntax_function: rgba(0x00695Cff),   // Functions
            syntax_type: rgba(0x6A1B9Aff),       // Types
            syntax_variable: colors.foreground,  // Variables
            
            // ... (mais cores conforme necessário)
        },
        // ... (resto das configurações do tema)
    }
}
```

### Fontes Customizadas por Extensão

**Criar `crates/mini_core/src/font_config.rs`:**

```rust
use std::collections::HashMap;
use gpui::{FontFamily, FontWeight};

/// Configuração de fontes por extensão de arquivo.
pub struct FontConfig {
    mappings: HashMap<String, FontSettings>,
    default_text: FontSettings,
    default_code: FontSettings,
}

#[derive(Clone, Debug)]
pub struct FontSettings {
    pub family: FontFamily,
    pub size: f32,
    pub line_height: f32,
    pub weight: FontWeight,
}

impl Default for FontConfig {
    fn default() -> Self {
        let mut mappings = HashMap::new();
        
        // Arquivos de texto - Bookman Old Style
        let text_font = FontSettings {
            family: FontFamily::new("Bookman Old Style"),
            size: 16.0,
            line_height: 1.6,
            weight: FontWeight::NORMAL,
        };
        mappings.insert("txt".to_string(), text_font.clone());
        
        // Markdown - Charter
        let markdown_font = FontSettings {
            family: FontFamily::new("Charter"),
            size: 15.0,
            line_height: 1.65,
            weight: FontWeight::NORMAL,
        };
        mappings.insert("md".to_string(), markdown_font);
        
        // Código - Fira Code
        let code_font = FontSettings {
            family: FontFamily::new("Fira Code"),
            size: 14.0,
            line_height: 1.5,
            weight: FontWeight::NORMAL,
        };
        
        for ext in &["rs", "js", "ts", "py", "java", "json", "html", "css"] {
            mappings.insert(ext.to_string(), code_font.clone());
        }
        
        Self {
            mappings,
            default_text: text_font,
            default_code: code_font,
        }
    }
}

impl FontConfig {
    /// Retorna configuração de fonte para uma extensão.
    pub fn get_for_extension(&self, ext: &str) -> &FontSettings {
        self.mappings.get(ext).unwrap_or(&self.default_code)
    }
    
    /// Verifica se extensão é considerada "texto" (vs "código").
    pub fn is_text_file(&self, ext: &str) -> bool {
        matches!(ext, "txt" | "md")
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_font_for_txt() {
        let config = FontConfig::default();
        let font = config.get_for_extension("txt");
        assert_eq!(font.size, 16.0);
    }

    #[test]
    fn test_font_for_code() {
        let config = FontConfig::default();
        let font = config.get_for_extension("rs");
        assert_eq!(font.size, 14.0);
    }
}
```

### Dimensionamento e Movimento da Janela

**Adicionar ao `window_manager.rs`:**

```rust
/// Modo de dimensionamento da janela.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum WindowSizeMode {
    /// Bloqueado no último tamanho definido
    Locked,
    /// Redimensionamento livre
    Free,
    /// Tamanho fixo em pixels
    Fixed { width: u32, height: u32 },
    /// Tamanho em porcentagem da tela
    Percentage { width: f32, height: f32 },
    /// Tamanhos pré-definidos
    Preset(WindowPreset),
}

#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum WindowPreset {
    /// Centralizado, 50% largura e altura
    Centered50,
    /// Esquerda, modo retrato 50% largura
    LeftPortrait,
    /// Direita, modo retrato 50% largura
    RightPortrait,
    /// Canto inferior direito, 25% da tela
    BottomRight25,
}

impl WindowPreset {
    /// Calcula bounds para o preset dado o tamanho da tela.
    pub fn calculate_bounds(&self, screen_width: u32, screen_height: u32) -> (i32, i32, u32, u32) {
        match self {
            WindowPreset::Centered50 => {
                let w = screen_width / 2;
                let h = screen_height / 2;
                let x = (screen_width - w) as i32 / 2;
                let y = (screen_height - h) as i32 / 2;
                (x, y, w, h)
            }
            WindowPreset::LeftPortrait => {
                let w = screen_width / 2;
                (10, 10, w - 20, screen_height - 20)
            }
            WindowPreset::RightPortrait => {
                let w = screen_width / 2;
                let x = (screen_width / 2 + 10) as i32;
                (x, 10, w - 20, screen_height - 20)
            }
            WindowPreset::BottomRight25 => {
                let w = screen_width / 4;
                let h = screen_height / 4;
                let x = (screen_width - w - 10) as i32;
                let y = (screen_height - h - 10) as i32;
                (x, y, w, h)
            }
        }
    }
}

/// Modo de movimento da janela.
#[derive(Debug, Clone, Copy, Serialize, Deserialize)]
pub enum WindowMoveMode {
    /// Bloqueado (não move)
    Locked,
    /// Movimentação livre
    Free,
    /// Movimentação assistida (Ctrl = Y, Shift = X)
    Assisted,
}

impl WindowManager {
    /// Aplica preset de tamanho/posição.
    pub fn apply_preset(&mut self, preset: WindowPreset, screen_width: u32, screen_height: u32) {
        let (x, y, w, h) = preset.calculate_bounds(screen_width, screen_height);
        self.update_state(x, y, w, h, false);
    }
    
    /// Verifica se movimento é permitido baseado no modo.
    pub fn can_move(&self, mode: WindowMoveMode) -> bool {
        !matches!(mode, WindowMoveMode::Locked)
    }
    
    /// Aplica movimento assistido (restringe a um eixo).
    pub fn apply_assisted_move(&mut self, dx: i32, dy: i32, ctrl_pressed: bool, shift_pressed: bool) {
        if ctrl_pressed && !shift_pressed {
            // Apenas Y
            self.state.y += dy;
        } else if shift_pressed && !ctrl_pressed {
            // Apenas X
            self.state.x += dx;
        } else {
            // Livre
            self.state.x += dx;
            self.state.y += dy;
        }
    }
}
```

### Fade In/Out ao Minimizar/Restaurar

**Criar `crates/mini_ui/src/window_animations.rs`:**

```rust
use gpui::{AppContext, WindowHandle};
use std::time::Duration;

/// Duração padrão do fade.
const FADE_DURATION: Duration = Duration::from_millis(200);

/// Aplica fade-out antes de minimizar.
pub fn fade_out_and_minimize(window: WindowHandle<impl gpui::View>, cx: &mut AppContext) {
    cx.spawn(|mut cx| async move {
        // Fade out
        for i in (0..=10).rev() {
            let opacity = i as f32 / 10.0;
            cx.update_window(window, |cx| {
                cx.set_window_opacity(opacity);
            }).ok();
            tokio::time::sleep(Duration::from_millis(20)).await;
        }
        
        // Minimizar
        cx.update_window(window, |cx| {
            cx.minimize_window();
        }).ok();
    }).detach();
}

/// Aplica fade-in ao restaurar.
pub fn restore_and_fade_in(window: WindowHandle<impl gpui::View>, cx: &mut AppContext) {
    cx.spawn(|mut cx| async move {
        // Restaurar
        cx.update_window(window, |cx| {
            cx.restore_window();
            cx.set_window_opacity(0.0);
        }).ok();
        
        // Fade in
        for i in 0..=10 {
            let opacity = i as f32 / 10.0;
            cx.update_window(window, |cx| {
                cx.set_window_opacity(opacity);
            }).ok();
            tokio::time::sleep(Duration::from_millis(20)).await;
        }
    }).detach();
}
```

### Testes

**`crates/mini_theme/tests/moleskine_test.rs`:**
```rust
use mini_theme::moleskine::{MoleskineColors, create_moleskine_theme};

#[test]
fn test_moleskine_colors() {
    let colors = MoleskineColors::default();
    assert_eq!(colors.background.r, 250);
    assert_eq!(colors.background.g, 246);
    assert_eq!(colors.background.b, 239);
}

#[test]
fn test_create_theme() {
    let theme = create_moleskine_theme();
    assert_eq!(theme.name.as_ref(), "Moleskine Light");
}
```

**`crates/mini_ui/tests/window_presets_test.rs`:**
```rust
use mini_ui::{WindowPreset, WindowManager};

#[test]
fn test_preset_centered_50() {
    let (x, y, w, h) = WindowPreset::Centered50.calculate_bounds(1920, 1080);
    assert_eq!(w, 960);
    assert_eq!(h, 540);
    assert_eq!(x, 480);
    assert_eq!(y, 270);
}

#[test]
fn test_preset_bottom_right_25() {
    let (x, y, w, h) = WindowPreset::BottomRight25.calculate_bounds(1920, 1080);
    assert_eq!(w, 480);
    assert_eq!(h, 270);
    assert!(x > 1400); // Canto direito
    assert!(y > 800);  // Canto inferior
}
```

### Critérios de Aceitação

- [ ] Tema Moleskine Light aplicado com cores corretas
- [ ] Fontes mudam conforme extensão do arquivo
- [ ] Bookman Old Style para .txt (16px, line-height 1.6)
- [ ] Fira Code para código (14px, line-height 1.5)
- [ ] Presets de janela funcionam corretamente
- [ ] Movimento assistido (Ctrl/Shift) funciona
- [ ] Fade in/out ao minimizar/restaurar (200ms)
- [ ] Margem de 10px respeitada em todos os presets
- [ ] Todos os testes passam

### Notificação

```bash
cast.exe notify "FASE 2 CONCLUÍDA: UI/UX Foundation" "Tema Moleskine Light implementado. Fontes customizadas por extensão. Presets de janela funcionais. Próxima fase: Sistema de Arquivos."
```

---

## FASE 3: SISTEMA DE ARQUIVOS E NAVEGAÇÃO

### Objetivos

1. Modo Pasta/Projeto (árvore de arquivos)
2. Modo Solto (arquivos de vários locais)
3. Painel lateral com duas linhas por arquivo
4. Fixar/desafixar arquivos
5. Modos de exibição: Fixo, Oculto, Hover

### Arquitetura

```
crates/mini_core/src/
├── file_manager.rs      # Gerencia arquivos abertos
├── folder_mode.rs       # Modo pasta (projeto)
└── loose_mode.rs        # Modo solto (arquivos diversos)

crates/mini_ui/src/
├── sidebar.rs           # Painel lateral
├── file_item.rs         # Item de arquivo (duas linhas)
└── file_tree.rs         # Árvore de pastas
```

### Modelo de Dados

**`crates/mini_core/src/file_manager.rs`:**

```rust
use std::path::{Path, PathBuf};
use std::collections::HashMap;
use serde::{Deserialize, Serialize};

/// Modo de operação do gerenciador de arquivos.
#[derive(Debug, Clone, Copy, Serialize, Deserialize, PartialEq)]
pub enum FileManagerMode {
    /// Modo pasta: uma pasta aberta com árvore
    Folder,
    /// Modo solto: arquivos de vários locais
    Loose,
}

/// Representa um arquivo aberto no editor.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct OpenFile {
    pub path: PathBuf,
    pub is_pinned: bool,
    pub is_modified: bool,
    pub last_cursor_position: (usize, usize), // (linha, coluna)
}

impl OpenFile {
    pub fn new(path: PathBuf) -> Self {
        Self {
            path,
            is_pinned: false,
            is_modified: false,
            last_cursor_position: (1, 1),
        }
    }
    
    /// Nome do arquivo sem path.
    pub fn file_name(&self) -> String {
        self.path.file_name()
            .and_then(|n| n.to_str())
            .unwrap_or("Unknown")
            .to_string()
    }
    
    /// Path relativo à pasta raiz (se em modo pasta).
    pub fn relative_path(&self, root: Option<&Path>) -> String {
        if let Some(root) = root {
            self.path.strip_prefix(root)
                .map(|p| p.to_string_lossy().to_string())
                .unwrap_or_else(|_| self.path.to_string_lossy().to_string())
        } else {
            self.path.to_string_lossy().to_string()
        }
    }
}

/// Gerenciador central de arquivos.
pub struct FileManager {
    mode: FileManagerMode,
    open_files: Vec<OpenFile>,
    active_file_index: Option<usize>,
    folder_root: Option<PathBuf>,
}

impl FileManager {
    pub fn new() -> Self {
        Self {
            mode: FileManagerMode::Loose,
            open_files: Vec::new(),
            active_file_index: None,
            folder_root: None,
        }
    }
    
    /// Abre um arquivo.
    pub fn open_file(&mut self, path: PathBuf) -> anyhow::Result<usize> {
        // Verifica se já está aberto
        if let Some(index) = self.find_file_index(&path) {
            self.active_file_index = Some(index);
            return Ok(index);
        }
        
        // Adiciona novo arquivo
        let file = OpenFile::new(path);
        self.open_files.push(file);
        let index = self.open_files.len() - 1;
        self.active_file_index = Some(index);
        Ok(index)
    }
    
    /// Abre uma pasta (modo projeto).
    pub fn open_folder(&mut self, path: PathBuf) -> anyhow::Result<()> {
        if !path.is_dir() {
            anyhow::bail!("Path não é um diretório");
        }
        
        self.mode = FileManagerMode::Folder;
        self.folder_root = Some(path);
        Ok(())
    }
    
    /// Fecha uma pasta (volta ao modo solto).
    pub fn close_folder(&mut self) {
        self.mode = FileManagerMode::Loose;
        self.folder_root = None;
    }
    
    /// Fixa/desfixa um arquivo.
    pub fn toggle_pin(&mut self, index: usize) -> anyhow::Result<()> {
        if let Some(file) = self.open_files.get_mut(index) {
            file.is_pinned = !file.is_pinned;
            Ok(())
        } else {
            anyhow::bail!("Índice de arquivo inválido")
        }
    }
    
    /// Fecha um arquivo.
    pub fn close_file(&mut self, index: usize) -> anyhow::Result<()> {
        if index >= self.open_files.len() {
            anyhow::bail!("Índice inválido");
        }
        
        self.open_files.remove(index);
        
        // Ajustar índice ativo
        if let Some(active) = self.active_file_index {
            if active == index {
                self.active_file_index = if self.open_files.is_empty() {
                    None
                } else {
                    Some(active.min(self.open_files.len() - 1))
                };
            } else if active > index {
                self.active_file_index = Some(active - 1);
            }
        }
        
        Ok(())
    }
    
    /// Retorna lista de arquivos abertos.
    pub fn open_files(&self) -> &[OpenFile] {
        &self.open_files
    }
    
    /// Retorna arquivo ativo atual.
    pub fn active_file(&self) -> Option<&OpenFile> {
        self.active_file_index.and_then(|i| self.open_files.get(i))
    }
    
    fn find_file_index(&self, path: &Path) -> Option<usize> {
        self.open_files.iter().position(|f| f.path == path)
    }
    
    pub fn mode(&self) -> FileManagerMode {
        self.mode
    }
    
    pub fn folder_root(&self) -> Option<&Path> {
        self.folder_root.as_deref()
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_open_file() {
        let mut manager = FileManager::new();
        let path = PathBuf::from("test.txt");
        let index = manager.open_file(path.clone()).unwrap();
        
        assert_eq!(index, 0);
        assert_eq!(manager.open_files().len(), 1);
        assert_eq!(manager.active_file().unwrap().path, path);
    }

    #[test]
    fn test_toggle_pin() {
        let mut manager = FileManager::new();
        let path = PathBuf::from("test.txt");
        let index = manager.open_file(path).unwrap();
        
        assert!(!manager.open_files()[index].is_pinned);
        manager.toggle_pin(index).unwrap();
        assert!(manager.open_files()[index].is_pinned);
    }

    #[test]
    fn test_close_file() {
        let mut manager = FileManager::new();
        manager.open_file(PathBuf::from("test1.txt")).unwrap();
        manager.open_file(PathBuf::from("test2.txt")).unwrap();
        
        assert_eq!(manager.open_files().len(), 2);
        manager.close_file(0).unwrap();
        assert_eq!(manager.open_files().len(), 1);
    }
}
```

### UI do Painel Lateral

**`crates/mini_ui/src/sidebar.rs`:**

```rust
use gpui::*;
use mini_core::{FileManager, FileManagerMode};

/// Modo de exibição do painel lateral.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum SidebarMode {
    /// Sempre visível
    Fixed,
    /// Oculto
    Hidden,
    /// Aparece ao passar o mouse
    Hover,
}

/// Painel lateral do mini.
pub struct Sidebar {
    mode: SidebarMode,
    width: f32,
    is_hovered: bool,
}

impl Sidebar {
    pub fn new(cx: &mut ViewContext<Self>) -> Self {
        Self {
            mode: SidebarMode::Fixed,
            width: 280.0,
            is_hovered: false,
        }
    }
    
    pub fn set_mode(&mut self, mode: SidebarMode, cx: &mut ViewContext<Self>) {
        self.mode = mode;
        cx.notify();
    }
    
    fn should_be_visible(&self) -> bool {
        match self.mode {
            SidebarMode::Fixed => true,
            SidebarMode::Hidden => false,
            SidebarMode::Hover => self.is_hovered,
        }
    }
}

impl Render for Sidebar {
    fn render(&mut self, cx: &mut ViewContext<Self>) -> impl IntoElement {
        let visible = self.should_be_visible();
        
        div()
            .w(px(if visible { self.width } else { 0.0 }))
            .h_full()
            .bg(rgb(0xFAF6EF)) // Vanilla Cream
            .border_r_1()
            .border_color(rgb(0xEFEAE1)) // Light Beige
            .on_mouse_enter(cx.listener(|sidebar, _, cx| {
                sidebar.is_hovered = true;
                cx.notify();
            }))
            .on_mouse_leave(cx.listener(|sidebar, _, cx| {
                sidebar.is_hovered = false;
                cx.notify();
            }))
            .child(
                div()
                    .p_3()
                    .child("Arquivos Abertos") // Placeholder
            )
    }
}
```

### Item de Arquivo (Duas Linhas)

**`crates/mini_ui/src/file_item.rs`:**

```rust
use gpui::*;
use mini_core::OpenFile;

pub struct FileItem {
    file: OpenFile,
    is_active: bool,
}

impl FileItem {
    pub fn new(file: OpenFile, is_active: bool) -> Self {
        Self { file, is_active }
    }
}

impl RenderOnce for FileItem {
    fn render(self, cx: &mut WindowContext) -> impl IntoElement {
        let bg_color = if self.is_active {
            rgb(0xEBE3D6) // Selecionado
        } else {
            rgb(0xFAF6EF) // Normal
        };
        
        div()
            .w_full()
            .p_2()
            .bg(bg_color)
            .hover(|style| style.bg(rgb(0xF5F0E7))) // Warm Hover
            .cursor_pointer()
            .child(
                div()
                    .flex()
                    .flex_col()
                    .gap_0p5()
                    // Linha 1: Nome do arquivo
                    .child(
                        div()
                            .text_sm()
                            .font_weight(FontWeight::MEDIUM)
                            .text_color(rgb(0x2C2416)) // Dark Brown
                            .child(self.file.file_name())
                    )
                    // Linha 2: Path relativo
                    .child(
                        div()
                            .text_xs()
                            .text_color(rgb(0x6B5E4F)) // Medium Brown
                            .child(self.file.relative_path(None))
                    )
            )
    }
}
```

### Testes

**`crates/mini_core/tests/file_manager_integration.rs`:**
```rust
use mini_core::FileManager;
use std::path::PathBuf;

#[test]
fn test_full_workflow() {
    let mut manager = FileManager::new();
    
    // Abrir arquivos
    manager.open_file(PathBuf::from("file1.txt")).unwrap();
    manager.open_file(PathBuf::from("file2.txt")).unwrap();
    assert_eq!(manager.open_files().len(), 2);
    
    // Fixar arquivo
    manager.toggle_pin(0).unwrap();
    assert!(manager.open_files()[0].is_pinned);
    
    // Fechar arquivo
    manager.close_file(1).unwrap();
    assert_eq!(manager.open_files().len(), 1);
}
```

### Critérios de Aceitação

- [ ] Modo pasta mostra árvore de arquivos/subpastas
- [ ] Modo solto mostra arquivos de vários locais
- [ ] Cada item mostra duas linhas (nome + path)
- [ ] Arquivos podem ser fixados/desfixados
- [ ] Painel lateral tem modo Fixo/Oculto/Hover
- [ ] Hover funciona (aparece ao passar mouse)
- [ ] Largura do painel é redimensionável (240-400px)
- [ ] Fechar pasta volta ao modo solto
- [ ] Arquivos anteriores são restaurados ao fechar pasta
- [ ] Todos os testes passam

### Notificação

```bash
cast.exe notify "FASE 3 CONCLUÍDA: Sistema de Arquivos e Navegação" "Modos Pasta/Solto implementados. Painel lateral funcional com hover. Fixar/desafixar arquivos. Próxima fase: Editor e Funcionalidades."
```

---

## FASE 4: EDITOR E FUNCIONALIDADES DE TEXTO

### Objetivos

1. Integração com editor do Zed
2. Aplicar fontes customizadas por extensão
3. Ajuda inteligente (? icons + Saiba Mais)
4. Pesquisa de arquivos (Ctrl+Shift+F)
5. Autocompletar configurável (IA/palavras/dicionário)

### Integração de Fontes no Editor

**`crates/mini_core/src/editor_config.rs`:**

```rust
use crate::font_config::FontConfig;
use std::path::Path;

/// Configuração do editor baseada no tipo de arquivo.
pub struct EditorConfig {
    font_config: FontConfig,
}

impl EditorConfig {
    pub fn new() -> Self {
        Self {
            font_config: FontConfig::default(),
        }
    }
    
    /// Retorna configuração de fonte para um arquivo.
    pub fn font_for_file(&self, path: &Path) -> &crate::font_config::FontSettings {
        let ext = path.extension()
            .and_then(|e| e.to_str())
            .unwrap_or("");
        
        self.font_config.get_for_extension(ext)
    }
}
```

### Sistema de Ajuda

**`crates/mini_ui/src/help_system.rs`:**

```rust
use gpui::*;

/// Componente de ajuda (? icon + tooltip).
pub struct HelpIcon {
    topic: String,
    short_text: String,
    full_help_content: String,
}

impl HelpIcon {
    pub fn new(topic: impl Into<String>, short: impl Into<String>, full: impl Into<String>) -> Self {
        Self {
            topic: topic.into(),
            short_text: short.into(),
            full_help_content: full.into(),
        }
    }
}

impl RenderOnce for HelpIcon {
    fn render(self, cx: &mut WindowContext) -> impl IntoElement {
        div()
            .w_4()
            .h_4()
            .rounded_full()
            .border_1()
            .border_color(rgb(0x6B5E4F)) // Medium Brown
            .text_color(rgb(0x6B5E4F))
            .flex()
            .items_center()
            .justify_center()
            .cursor_pointer()
            .hover(|style| style.bg(rgb(0xF5F0E7)))
            .tooltip(move |cx| {
                Tooltip::new(self.short_text.clone())
                    .with_action("Saiba mais...", move |cx| {
                        // Abrir aba de ajuda completa
                        cx.emit(OpenHelpTab {
                            topic: self.topic.clone(),
                            content: self.full_help_content.clone(),
                        });
                    })
            })
            .child("?")
    }
}

#[derive(Clone)]
pub struct OpenHelpTab {
    pub topic: String,
    pub content: String,
}
```

### Pesquisa Global de Arquivos

**`crates/mini_ui/src/file_search.rs`:**

```rust
use gpui::*;
use std::path::{Path, PathBuf};

/// Barra de pesquisa de arquivos (Ctrl+Shift+F).
pub struct FileSearchBar {
    query: String,
    results: Vec<PathBuf>,
    selected_index: usize,
    is_visible: bool,
}

impl FileSearchBar {
    pub fn new() -> Self {
        Self {
            query: String::new(),
            results: Vec::new(),
            selected_index: 0,
            is_visible: false,
        }
    }
    
    pub fn show(&mut self, cx: &mut ViewContext<Self>) {
        self.is_visible = true;
        self.query.clear();
        self.results.clear();
        cx.notify();
    }
    
    pub fn hide(&mut self, cx: &mut ViewContext<Self>) {
        self.is_visible = false;
        cx.notify();
    }
    
    pub fn update_query(&mut self, query: String, cx: &mut ViewContext<Self>) {
        self.query = query;
        self.search(cx);
    }
    
    fn search(&mut self, cx: &mut ViewContext<Self>) {
        // Pesquisa assíncrona no sistema de arquivos
        let query = self.query.clone();
        
        cx.spawn(|search_bar, mut cx| async move {
            // Implementar pesquisa (usar walkdir crate)
            let results = perform_file_search(&query).await;
            
            search_bar.update(&mut cx, |bar, cx| {
                bar.results = results;
                bar.selected_index = 0;
                cx.notify();
            }).ok();
        }).detach();
    }
}

async fn perform_file_search(query: &str) -> Vec<PathBuf> {
    use walkdir::WalkDir;
    
    let mut results = Vec::new();
    
    // Pesquisar em locais comuns
    let search_paths = vec![
        dirs::home_dir(),
        dirs::document_dir(),
    ];
    
    for base_path in search_paths.into_iter().flatten() {
        for entry in WalkDir::new(base_path)
            .max_depth(5) // Limitar profundidade
            .follow_links(false)
            .into_iter()
            .filter_map(|e| e.ok())
        {
            if let Some(name) = entry.file_name().to_str() {
                if name.to_lowercase().contains(&query.to_lowercase()) {
                    results.push(entry.path().to_path_buf());
                    
                    // Limitar resultados
                    if results.len() >= 50 {
                        return results;
                    }
                }
            }
        }
    }
    
    results
}

impl Render for FileSearchBar {
    fn render(&mut self, cx: &mut ViewContext<Self>) -> impl IntoElement {
        if !self.is_visible {
            return div();
        }
        
        div()
            .absolute()
            .top_10()
            .left_1_2()
            .w_96()
            .bg(rgb(0xFAF6EF))
            .border_1()
            .border_color(rgb(0xEFEAE1))
            .rounded_md()
            .shadow_lg()
            .p_2()
            .child(
                // Input de pesquisa
                div()
                    .w_full()
                    .child("Pesquisar arquivos...")
            )
            .child(
                // Lista de resultados
                div()
                    .mt_2()
                    .max_h_96()
                    .overflow_y_auto()
                    .children(self.results.iter().enumerate().map(|(i, path)| {
                        let is_selected = i == self.selected_index;
                        div()
                            .p_1()
                            .bg(if is_selected { rgb(0xEBE3D6) } else { rgb(0xFAF6EF) })
                            .child(path.to_string_lossy().to_string())
                    }))
            )
    }
}
```

### Autocompletar

**`crates/mini_core/src/autocomplete.rs`:**

```rust
/// Modo de autocompletar.
#[derive(Debug, Clone, Copy, PartialEq)]
pub enum AutocompleteMode {
    /// Desabilitado
    Disabled,
    /// Usando agente de IA
    AI,
    /// Palavras do arquivo atual
    Words,
    /// Dicionário da língua
    Dictionary,
}

pub struct AutocompleteEngine {
    mode: AutocompleteMode,
    language: String,
}

impl AutocompleteEngine {
    pub fn new(mode: AutocompleteMode) -> Self {
        Self {
            mode,
            language: "pt-BR".to_string(),
        }
    }
    
    /// Retorna sugestões baseadas no contexto.
    pub async fn suggest(&self, text: &str, cursor_pos: usize) -> Vec<String> {
        match self.mode {
            AutocompleteMode::Disabled => Vec::new(),
            AutocompleteMode::AI => self.suggest_ai(text, cursor_pos).await,
            AutocompleteMode::Words => self.suggest_words(text),
            AutocompleteMode::Dictionary => self.suggest_dictionary(text),
        }
    }
    
    async fn suggest_ai(&self, text: &str, cursor_pos: usize) -> Vec<String> {
        // TODO FASE 6: Implementar com Claude API
        Vec::new()
    }
    
    fn suggest_words(&self, text: &str) -> Vec<String> {
        // Extrair palavras únicas do texto
        let words: std::collections::HashSet<String> = text
            .split_whitespace()
            .map(|w| w.to_lowercase())
            .collect();
        
        words.into_iter().collect()
    }
    
    fn suggest_dictionary(&self, text: &str) -> Vec<String> {
        // Carregar dicionário da líng