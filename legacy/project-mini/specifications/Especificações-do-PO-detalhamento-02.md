<img src="https://r2cdn.perplexity.ai/pplx-full-logo-primary-dark%402x.png" style="height:64px;margin-right:32px"/>

# O Claude estava fazendo as especificações mas quebrou na metade. Dê uma olhada e veja se consegue aproveitar algo para um arquivo de especificações complementar.

O arquivo do Claude contém especificações muito detalhadas com código Rust implementado para as Fases 0-6, mas foi interrompido durante a Fase 6 (Integração com IA). Vou criar um documento complementar que completa as partes faltantes e adiciona as fases finais.[^1]

***

# Especificação Complementar para Implementação do MINI

## Projeto: MINI (Editor Minimalista baseado no Zed)

## Versão: 2.0 - Complemento

## Data: 2025-12-06

## Autor: Arquiteto/Supervisor IA (Perplexity)


***

## Resumo das Especificações Existentes

O documento "Especificacoes-Incompletas.md" contém implementações detalhadas em Rust para as seguintes fases:[^1]


| Fase | Status | Conteúdo |
| :-- | :-- | :-- |
| FASE 0 | ✅ Completa | Setup e Rebranding Zed → mini |
| FASE 1 | ✅ Completa | Trayicon e Gerenciamento de Janela |
| FASE 2 | ✅ Completa | UI/UX Foundation (Tema Moleskine, Fontes) |
| FASE 3 | ✅ Completa | Sistema de Arquivos e Navegação |
| FASE 4 | ✅ Completa | Editor e Funcionalidades de Texto |
| FASE 5 | ✅ Completa | Gerenciador de Tarefas |
| FASE 6 | ⚠️ Parcial | Integração com IA (cortado no meio) |
| FASE 7 | ❌ Ausente | Sincronização |
| FASE 8 | ❌ Ausente | Atualizações e Ambiente SO |


***

## FASE 6: INTEGRAÇÃO COM IA (Complemento)

### Código Faltante do Painel de IA

O documento original foi cortado durante a implementação do `AiPanel`. Segue a conclusão:

**`crates/mini_ui/src/ai_panel.rs` (continuação):**

```rust
impl Render for AiPanel {
    fn render(&mut self, cx: &mut ViewContext<Self>) -> impl IntoElement {
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
                    .flex()
                    .justify_between()
                    .items_center()
                    .child("Assistente IA")
                    .child(
                        div()
                            .text_xs()
                            .text_color(rgb(0x6B5E4F))
                            .child("Claude")
                    )
            )
            // Conversação
            .child(
                div()
                    .flex_1()
                    .overflow_y_auto()
                    .p_3()
                    .children(self.conversation.iter().map(|msg| {
                        self.render_message(msg, cx)
                    }))
                    .when(self.is_loading, |div| {
                        div.child(
                            div()
                                .p_2()
                                .text_sm()
                                .text_color(rgb(0x6B5E4F))
                                .child("Pensando...")
                        )
                    })
            )
            // Input
            .child(
                div()
                    .p_3()
                    .border_t_1()
                    .border_color(rgb(0xEFEAE1))
                    .child(
                        div()
                            .w_full()
                            .p_2()
                            .bg(rgb(0xF5F0E7))
                            .rounded_md()
                            .child(&self.input_text)
                    )
            )
    }
    
    fn render_message(&self, msg: &ConversationMessage, cx: &mut ViewContext<Self>) -> impl IntoElement {
        let is_user = msg.role == "user";
        
        div()
            .w_full()
            .mb_3()
            .child(
                div()
                    .max_w_4_5()
                    .when(is_user, |d| d.ml_auto())
                    .p_3()
                    .bg(if is_user { rgb(0x3484F7) } else { rgb(0xF5F0E7) })
                    .text_color(if is_user { rgb(0xFFFFFF) } else { rgb(0x2C2416) })
                    .rounded_lg()
                    .child(&msg.content)
            )
    }
}
```


### Modo Inline com `///`

**`crates/mini_core/src/inline_ai.rs`:**

```rust
use regex::Regex;

/// Detecta e processa prompts inline com ///.
pub struct InlineAiDetector {
    pattern: Regex,
}

impl InlineAiDetector {
    pub fn new() -> Self {
        Self {
            // Padrão: /// seguido de texto até o final da linha
            pattern: Regex::new(r"^///\s*(.+)$").unwrap(),
        }
    }
    
    /// Verifica se a linha contém um prompt inline.
    pub fn detect_prompt(&self, line: &str) -> Option<String> {
        self.pattern.captures(line.trim())
            .and_then(|caps| caps.get(1))
            .map(|m| m.as_str().to_string())
    }
    
    /// Processa linha quando usuário pressiona ENTER.
    pub async fn process_line(
        &self,
        line: &str,
        client: &super::ai_client::ClaudeClient,
    ) -> Option<String> {
        if let Some(prompt) = self.detect_prompt(line) {
            match client.send_prompt(prompt).await {
                Ok(response) => Some(response),
                Err(e) => Some(format!("// Erro: {}", e)),
            }
        } else {
            None
        }
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_detect_prompt() {
        let detector = InlineAiDetector::new();
        
        assert_eq!(
            detector.detect_prompt("/// Explique recursão"),
            Some("Explique recursão".to_string())
        );
        
        assert_eq!(detector.detect_prompt("// Comentário normal"), None);
        assert_eq!(detector.detect_prompt("let x = 10;"), None);
    }
}
```


### Barra de Pesquisa IA

**`crates/mini_ui/src/ai_search_bar.rs`:**

```rust
use gpui::*;
use mini_core::{ClaudeClient, ClaudeConfig};

/// Barra de pesquisa para interação rápida com IA.
/// Resposta é inserida no arquivo em foreground na posição do cursor.
pub struct AiSearchBar {
    client: ClaudeClient,
    query: String,
    is_visible: bool,
    is_loading: bool,
}

impl AiSearchBar {
    pub fn new(config: ClaudeConfig) -> Self {
        Self {
            client: ClaudeClient::new(config),
            query: String::new(),
            is_visible: false,
            is_loading: false,
        }
    }
    
    pub fn toggle(&mut self, cx: &mut ViewContext<Self>) {
        self.is_visible = !self.is_visible;
        if self.is_visible {
            self.query.clear();
        }
        cx.notify();
    }
    
    pub fn submit(&mut self, cx: &mut ViewContext<Self>) {
        if self.query.is_empty() || self.is_loading {
            return;
        }
        
        self.is_loading = true;
        cx.notify();
        
        let query = self.query.clone();
        let client = self.client.clone();
        
        cx.spawn(|bar, mut cx| async move {
            let result = client.send_prompt(query).await;
            
            bar.update(&mut cx, |bar, cx| {
                bar.is_loading = false;
                bar.is_visible = false;
                
                match result {
                    Ok(response) => {
                        // Emitir evento para inserir no editor
                        cx.emit(InsertAiResponse { text: response });
                    }
                    Err(e) => {
                        // Mostrar erro
                        cx.emit(InsertAiResponse { 
                            text: format!("// Erro IA: {}", e) 
                        });
                    }
                }
                
                cx.notify();
            }).ok();
        }).detach();
    }
}

#[derive(Clone)]
pub struct InsertAiResponse {
    pub text: String,
}

impl Render for AiSearchBar {
    fn render(&mut self, cx: &mut ViewContext<Self>) -> impl IntoElement {
        if !self.is_visible {
            return div();
        }
        
        div()
            .absolute()
            .top_20()
            .left_1_2()
            .w_128()
            .bg(rgb(0xFAF6EF))
            .border_1()
            .border_color(rgb(0xEFEAE1))
            .rounded_lg()
            .shadow_xl()
            .p_4()
            .child(
                div()
                    .flex()
                    .items_center()
                    .gap_2()
                    .child(
                        div()
                            .text_sm()
                            .text_color(rgb(0x3484F7))
                            .child("🤖")
                    )
                    .child(
                        div()
                            .flex_1()
                            .p_2()
                            .bg(rgb(0xF5F0E7))
                            .rounded_md()
                            .child(if self.is_loading {
                                "Processando...".to_string()
                            } else {
                                self.query.clone()
                            })
                    )
            )
            .child(
                div()
                    .mt_2()
                    .text_xs()
                    .text_color(rgb(0x6B5E4F))
                    .child("Enter para enviar • Esc para cancelar • Resposta será inserida no cursor")
            )
    }
}
```


### Testes da Fase 6

```rust
#[cfg(test)]
mod ai_tests {
    use super::*;

    #[test]
    fn test_inline_detector() {
        let detector = InlineAiDetector::new();
        
        // Deve detectar prompt válido
        assert!(detector.detect_prompt("/// teste").is_some());
        
        // Não deve detectar comentário normal
        assert!(detector.detect_prompt("// teste").is_none());
        
        // Não deve detectar código
        assert!(detector.detect_prompt("let x = 3;").is_none());
    }
    
    #[tokio::test]
    async fn test_claude_client_requires_key() {
        let client = ClaudeClient::new(ClaudeConfig::default());
        let result = client.send_prompt("test".to_string()).await;
        assert!(result.is_err());
    }
}
```


### Critérios de Aceitação - Fase 6

- [ ] Painel lateral de IA funcional
- [ ] Barra de pesquisa IA (atalho configurável)
- [ ] Modo inline `///` detecta e processa prompts
- [ ] Resposta inserida na posição do cursor
- [ ] Autocompletar com 3 modos (IA, palavras, dicionário)
- [ ] `Ctrl+Espaço` ativa autocompletar
- [ ] Tratamento de erros de API
- [ ] Todos os testes passam


### Notificação

```bash
cast.exe send tg me "FASE 6 CONCLUÍDA: Integração com IA - Painel, barra de pesquisa e modo inline /// implementados"
```


***

## FASE 7: SINCRONIZAÇÃO

**⚠️ TODOs PERMITIDOS — Requer configurações externas**

### Objetivos

1. Sincronização via Git (GitHub/GitLab)
2. Sincronização via Google Drive
3. Arquivo `.mini` para configuração por pasta
4. Git embutido (caso não detectado no SO)

### Arquitetura

```
crates/mini_sync/
├── src/
│   ├── lib.rs
│   ├── git/
│   │   ├── mod.rs
│   │   ├── embedded.rs      # Git embutido (libgit2)
│   │   ├── github.rs        # GitHub API
│   │   └── gitlab.rs        # GitLab API
│   ├── gdrive/
│   │   ├── mod.rs
│   │   ├── oauth.rs         # OAuth2 Google
│   │   └── api.rs           # Drive API
│   ├── sync_manager.rs      # Orquestrador de sync
│   └── conflict.rs          # Resolução de conflitos
└── Cargo.toml
```


### Dependências

**`crates/mini_sync/Cargo.toml`:**

```toml
[package]
name = "mini_sync"
version = "0.1.0"
edition = "2021"

[dependencies]
git2 = "0.18"                    # libgit2 bindings (Git embutido)
reqwest = { version = "0.11", features = ["json"] }
oauth2 = "4.4"
tokio = { version = "1.0", features = ["full"] }
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
dirs = "5.0"
```


### Modelo de Dados

**`crates/mini_sync/src/lib.rs`:**

```rust
pub mod git;
pub mod gdrive;
pub mod sync_manager;
pub mod conflict;

use serde::{Deserialize, Serialize};
use std::path::PathBuf;

/// Configuração de sincronização.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncConfig {
    pub enabled: bool,
    pub provider: SyncProvider,
    pub auto_sync: bool,
    pub sync_interval_minutes: u32,
}

#[derive(Debug, Clone, Serialize, Deserialize)]
pub enum SyncProvider {
    None,
    GitHub { repo_url: String, token: String },
    GitLab { repo_url: String, token: String },
    GoogleDrive { folder_name: String },
}

impl Default for SyncConfig {
    fn default() -> Self {
        Self {
            enabled: false,
            provider: SyncProvider::None,
            auto_sync: false,
            sync_interval_minutes: 15,
        }
    }
}

/// Informação de arquivo para sincronização.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct SyncFileInfo {
    pub local_path: PathBuf,
    pub remote_path: String,
    pub device_id: String,
    pub last_modified: chrono::DateTime<chrono::Utc>,
    pub checksum: String,
}
```


### Git Embutido

**`crates/mini_sync/src/git/embedded.rs`:**

```rust
use git2::{Repository, Signature, Cred, RemoteCallbacks};
use std::path::Path;
use anyhow::Result;

/// Git embutido usando libgit2.
pub struct EmbeddedGit {
    repo: Option<Repository>,
}

impl EmbeddedGit {
    pub fn new() -> Self {
        Self { repo: None }
    }
    
    /// Inicializa ou abre repositório.
    pub fn init_or_open(&mut self, path: &Path) -> Result<()> {
        self.repo = Some(if path.join(".git").exists() {
            Repository::open(path)?
        } else {
            Repository::init(path)?
        });
        Ok(())
    }
    
    /// Adiciona arquivos ao staging.
    pub fn add_all(&self) -> Result<()> {
        let repo = self.repo.as_ref()
            .ok_or_else(|| anyhow::anyhow!("Repositório não inicializado"))?;
        
        let mut index = repo.index()?;
        index.add_all(["*"].iter(), git2::IndexAddOption::DEFAULT, None)?;
        index.write()?;
        Ok(())
    }
    
    /// Cria commit.
    pub fn commit(&self, message: &str) -> Result<()> {
        let repo = self.repo.as_ref()
            .ok_or_else(|| anyhow::anyhow!("Repositório não inicializado"))?;
        
        let sig = Signature::now("mini", "mini@local")?;
        let mut index = repo.index()?;
        let tree_id = index.write_tree()?;
        let tree = repo.find_tree(tree_id)?;
        
        let parent = repo.head()
            .ok()
            .and_then(|h| h.peel_to_commit().ok());
        
        let parents: Vec<&git2::Commit> = parent.iter().collect();
        
        repo.commit(Some("HEAD"), &sig, &sig, message, &tree, &parents)?;
        Ok(())
    }
    
    /// Push para remote.
    pub fn push(&self, remote_name: &str, token: &str) -> Result<()> {
        let repo = self.repo.as_ref()
            .ok_or_else(|| anyhow::anyhow!("Repositório não inicializado"))?;
        
        let mut remote = repo.find_remote(remote_name)?;
        
        let mut callbacks = RemoteCallbacks::new();
        callbacks.credentials(|_url, username, _allowed| {
            Cred::userpass_plaintext(
                username.unwrap_or("git"),
                token,
            )
        });
        
        let mut push_options = git2::PushOptions::new();
        push_options.remote_callbacks(callbacks);
        
        remote.push(&["refs/heads/main:refs/heads/main"], Some(&mut push_options))?;
        Ok(())
    }
    
    /// Pull do remote.
    pub fn pull(&self, remote_name: &str, token: &str) -> Result<()> {
        let repo = self.repo.as_ref()
            .ok_or_else(|| anyhow::anyhow!("Repositório não inicializado"))?;
        
        // TODO: Implementar fetch + merge
        // Esta é uma operação complexa que requer:
        // 1. Fetch do remote
        // 2. Merge ou rebase
        // 3. Resolução de conflitos
        
        anyhow::bail!("TODO: Implementar pull completo")
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_init_repo() {
        let dir = tempdir().unwrap();
        let mut git = EmbeddedGit::new();
        
        git.init_or_open(dir.path()).unwrap();
        assert!(dir.path().join(".git").exists());
    }
}
```


### Google Drive OAuth

**`crates/mini_sync/src/gdrive/oauth.rs`:**

```rust
use oauth2::{
    AuthorizationCode, AuthUrl, ClientId, ClientSecret, CsrfToken,
    PkceCodeChallenge, RedirectUrl, Scope, TokenResponse, TokenUrl,
    basic::BasicClient,
};
use anyhow::Result;

/// Configuração OAuth para Google Drive.
pub struct GoogleOAuthConfig {
    pub client_id: String,
    pub client_secret: String,
    pub redirect_uri: String,
}

impl Default for GoogleOAuthConfig {
    fn default() -> Self {
        Self {
            // TODO: Preencher com credenciais do GCP Console
            client_id: String::new(),
            client_secret: String::new(),
            redirect_uri: "http://localhost:8080/callback".to_string(),
        }
    }
}

pub struct GoogleOAuth {
    client: BasicClient,
    pkce_verifier: Option<oauth2::PkceCodeVerifier>,
}

impl GoogleOAuth {
    pub fn new(config: GoogleOAuthConfig) -> Result<Self> {
        let client = BasicClient::new(
            ClientId::new(config.client_id),
            Some(ClientSecret::new(config.client_secret)),
            AuthUrl::new("https://accounts.google.com/o/oauth2/v2/auth".to_string())?,
            Some(TokenUrl::new("https://oauth2.googleapis.com/token".to_string())?),
        )
        .set_redirect_uri(RedirectUrl::new(config.redirect_uri)?);
        
        Ok(Self {
            client,
            pkce_verifier: None,
        })
    }
    
    /// Gera URL de autorização.
    pub fn get_auth_url(&mut self) -> (String, CsrfToken) {
        let (pkce_challenge, pkce_verifier) = PkceCodeChallenge::new_random_sha256();
        self.pkce_verifier = Some(pkce_verifier);
        
        let (auth_url, csrf_token) = self.client
            .authorize_url(CsrfToken::new_random)
            .add_scope(Scope::new("https://www.googleapis.com/auth/drive.file".to_string()))
            .set_pkce_challenge(pkce_challenge)
            .url();
        
        (auth_url.to_string(), csrf_token)
    }
    
    /// Troca código de autorização por token.
    pub async fn exchange_code(&self, code: String) -> Result<String> {
        let verifier = self.pkce_verifier.clone()
            .ok_or_else(|| anyhow::anyhow!("PKCE verifier não inicializado"))?;
        
        let token_result = self.client
            .exchange_code(AuthorizationCode::new(code))
            .set_pkce_verifier(verifier)
            .request_async(oauth2::reqwest::async_http_client)
            .await?;
        
        Ok(token_result.access_token().secret().clone())
    }
}
```


### Gerenciador de Sincronização

**`crates/mini_sync/src/sync_manager.rs`:**

```rust
use crate::{SyncConfig, SyncProvider, SyncFileInfo};
use crate::git::EmbeddedGit;
use std::path::PathBuf;
use anyhow::Result;
use tokio::time::{interval, Duration};

/// Gerenciador central de sincronização.
pub struct SyncManager {
    config: SyncConfig,
    git: EmbeddedGit,
    sync_folder: PathBuf,
}

impl SyncManager {
    pub fn new(config: SyncConfig) -> Result<Self> {
        let sync_folder = dirs::config_dir()
            .ok_or_else(|| anyhow::anyhow!("Config dir não encontrado"))?
            .join("mini")
            .join("sync");
        
        std::fs::create_dir_all(&sync_folder)?;
        
        Ok(Self {
            config,
            git: EmbeddedGit::new(),
            sync_folder,
        })
    }
    
    /// Inicia sincronização automática.
    pub async fn start_auto_sync(&self) {
        if !self.config.auto_sync {
            return;
        }
        
        let mut interval = interval(Duration::from_secs(
            self.config.sync_interval_minutes as u64 * 60
        ));
        
        loop {
            interval.tick().await;
            if let Err(e) = self.sync().await {
                log::error!("Erro na sincronização automática: {}", e);
            }
        }
    }
    
    /// Executa sincronização manual.
    pub async fn sync(&self) -> Result<()> {
        match &self.config.provider {
            SyncProvider::None => Ok(()),
            SyncProvider::GitHub { repo_url, token } => {
                self.sync_git(repo_url, token).await
            }
            SyncProvider::GitLab { repo_url, token } => {
                self.sync_git(repo_url, token).await
            }
            SyncProvider::GoogleDrive { folder_name } => {
                self.sync_gdrive(folder_name).await
            }
        }
    }
    
    async fn sync_git(&self, _repo_url: &str, _token: &str) -> Result<()> {
        // TODO: Implementar sync completo
        // 1. Pull changes
        // 2. Resolver conflitos
        // 3. Add + Commit local changes
        // 4. Push
        
        anyhow::bail!("TODO: Implementar sync Git completo - requer configuração de repositório")
    }
    
    async fn sync_gdrive(&self, _folder_name: &str) -> Result<()> {
        // TODO: Implementar sync com Google Drive
        // 1. Autenticar (ou usar token salvo)
        // 2. Listar arquivos remotos
        // 3. Comparar com locais
        // 4. Upload/Download conforme necessário
        
        anyhow::bail!("TODO: Implementar sync GDrive - requer configuração OAuth no GCP")
    }
}
```


### Arquivo `.mini` para Configuração por Pasta

**`crates/mini_core/src/mini_config_file.rs`:**

```rust
use serde::{Deserialize, Serialize};
use std::path::Path;
use anyhow::Result;

/// Configuração específica de pasta (arquivo .mini).
#[derive(Debug, Clone, Serialize, Deserialize, Default)]
pub struct MiniConfigFile {
    /// URL do repositório de sincronização
    pub sync_repo: Option<String>,
    
    /// Nome da pasta no Google Drive
    pub gdrive_folder: Option<String>,
    
    /// Tema específico para esta pasta
    pub theme: Option<String>,
    
    /// Fonte específica para arquivos desta pasta
    pub font_override: Option<String>,
    
    /// Arquivos a ignorar
    pub ignore_patterns: Vec<String>,
}

impl MiniConfigFile {
    /// Carrega configuração do arquivo .mini.
    pub fn load(folder_path: &Path) -> Result<Option<Self>> {
        let config_path = folder_path.join(".mini");
        
        if !config_path.exists() {
            return Ok(None);
        }
        
        let content = std::fs::read_to_string(&config_path)?;
        let config: MiniConfigFile = serde_json::from_str(&content)?;
        Ok(Some(config))
    }
    
    /// Salva configuração no arquivo .mini.
    pub fn save(&self, folder_path: &Path) -> Result<()> {
        let config_path = folder_path.join(".mini");
        let content = serde_json::to_string_pretty(self)?;
        std::fs::write(config_path, content)?;
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_mini_config_save_load() {
        let dir = tempdir().unwrap();
        
        let config = MiniConfigFile {
            sync_repo: Some("https://github.com/user/repo".to_string()),
            gdrive_folder: Some("mini-backup".to_string()),
            ..Default::default()
        };
        
        config.save(dir.path()).unwrap();
        
        let loaded = MiniConfigFile::load(dir.path()).unwrap().unwrap();
        assert_eq!(loaded.sync_repo, config.sync_repo);
    }
}
```


### Testes da Fase 7

```rust
#[cfg(test)]
mod sync_tests {
    use super::*;
    use tempfile::tempdir;

    #[test]
    fn test_embedded_git_init() {
        let dir = tempdir().unwrap();
        let mut git = EmbeddedGit::new();
        
        assert!(git.init_or_open(dir.path()).is_ok());
        assert!(dir.path().join(".git").exists());
    }
    
    #[test]
    fn test_sync_config_default() {
        let config = SyncConfig::default();
        assert!(!config.enabled);
        assert!(matches!(config.provider, SyncProvider::None));
    }
    
    #[test]
    fn test_mini_config_file() {
        let dir = tempdir().unwrap();
        
        let config = MiniConfigFile {
            sync_repo: Some("test".to_string()),
            ..Default::default()
        };
        
        config.save(dir.path()).unwrap();
        let loaded = MiniConfigFile::load(dir.path()).unwrap();
        
        assert!(loaded.is_some());
    }
}
```


### Critérios de Aceitação - Fase 7

- [ ] Git embutido funciona (init, add, commit)
- [ ] Arquivo `.mini` é lido e respeitado
- [ ] OAuth Google configurável (mesmo com TODOs)
- [ ] Estrutura de sync manager criada
- [ ] Detecção de Git no SO funciona
- [ ] Testes básicos passam
- [ ] TODOs documentados para configuração externa


### Notificação

```bash
cast.exe send tg me "FASE 7 CONCLUÍDA: Sincronização (com TODOs) - Git embutido, OAuth estruturado, arquivo .mini implementado"
```


***

## FASE 8: ATUALIZAÇÕES E AMBIENTE SO

**⚠️ TODOs PERMITIDOS — Requer servidor de atualização**

### Objetivos

1. Sistema de atualização transparente
2. Menu de contexto do Windows Explorer
3. Inicialização com o SO
4. Internacionalização (pt-BR, en, zh)

### Arquitetura

```
crates/mini_updater/
├── src/
│   ├── lib.rs
│   ├── checker.rs           # Verificação de atualizações
│   ├── downloader.rs        # Download em background
│   └── installer.rs         # Aplicação da atualização
└── Cargo.toml

crates/mini_os/
├── src/
│   ├── lib.rs
│   ├── windows/
│   │   ├── mod.rs
│   │   ├── context_menu.rs  # Menu de contexto
│   │   ├── startup.rs       # Inicialização com SO
│   │   └── registry.rs      # Manipulação do registro
│   └── i18n.rs              # Internacionalização
└── Cargo.toml
```


### Sistema de Atualização

**`crates/mini_updater/src/checker.rs`:**

```rust
use serde::{Deserialize, Serialize};
use anyhow::Result;

/// Informação de versão disponível.
#[derive(Debug, Clone, Serialize, Deserialize)]
pub struct VersionInfo {
    pub version: String,
    pub release_notes: String,
    pub download_url: String,
    pub checksum: String,
    pub release_date: String,
}

pub struct UpdateChecker {
    // TODO: Definir URL do servidor de atualizações
    update_url: String,
    current_version: String,
}

impl UpdateChecker {
    pub fn new(current_version: String) -> Self {
        Self {
            // TODO: Configurar servidor de atualizações
            update_url: "https://api.mini-editor.com/updates/latest".to_string(),
            current_version,
        }
    }
    
    /// Verifica se há atualização disponível.
    pub async fn check(&self) -> Result<Option<VersionInfo>> {
        // TODO: Implementar quando servidor estiver disponível
        // let response = reqwest::get(&self.update_url).await?;
        // let info: VersionInfo = response.json().await?;
        // 
        // if info.version > self.current_version {
        //     Ok(Some(info))
        // } else {
        //     Ok(None)
        // }
        
        Ok(None) // Placeholder
    }
}
```

**`crates/mini_updater/src/downloader.rs`:**

```rust
use std::path::PathBuf;
use anyhow::Result;
use tokio::io::AsyncWriteExt;

pub struct UpdateDownloader {
    download_dir: PathBuf,
}

impl UpdateDownloader {
    pub fn new() -> Result<Self> {
        let download_dir = dirs::cache_dir()
            .ok_or_else(|| anyhow::anyhow!("Cache dir não encontrado"))?
            .join("mini")
            .join("updates");
        
        std::fs::create_dir_all(&download_dir)?;
        
        Ok(Self { download_dir })
    }
    
    /// Baixa atualização em background.
    pub async fn download(&self, url: &str, expected_checksum: &str) -> Result<PathBuf> {
        // TODO: Implementar download real
        // let response = reqwest::get(url).await?;
        // let bytes = response.bytes().await?;
        // 
        // // Verificar checksum
        // let actual_checksum = sha256::digest(&bytes);
        // if actual_checksum != expected_checksum {
        //     anyhow::bail!("Checksum inválido");
        // }
        // 
        // let file_path = self.download_dir.join("mini_update.exe");
        // let mut file = tokio::fs::File::create(&file_path).await?;
        // file.write_all(&bytes).await?;
        // 
        // Ok(file_path)
        
        anyhow::bail!("TODO: Implementar download - requer servidor de atualizações")
    }
}
```


### Menu de Contexto do Windows

**`crates/mini_os/src/windows/context_menu.rs`:**

```rust
use winreg::enums::*;
use winreg::RegKey;
use anyhow::Result;
use std::path::Path;

/// Registra mini no menu de contexto do Windows Explorer.
pub struct ContextMenuRegistrar {
    exe_path: String,
}

impl ContextMenuRegistrar {
    pub fn new() -> Result<Self> {
        let exe_path = std::env::current_exe()?
            .to_string_lossy()
            .to_string();
        
        Ok(Self { exe_path })
    }
    
    /// Registra "Abrir com mini" para arquivos.
    pub fn register_file_handler(&self) -> Result<()> {
        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        
        // Criar chave para arquivos
        let (key, _) = hkcu.create_subkey(
            r"Software\Classes\*\shell\mini"
        )?;
        key.set_value("", &"Abrir com mini")?;
        key.set_value("Icon", &self.exe_path)?;
        
        // Comando
        let (cmd_key, _) = hkcu.create_subkey(
            r"Software\Classes\*\shell\mini\command"
        )?;
        cmd_key.set_value("", &format!("\"{}\" \"%1\"", self.exe_path))?;
        
        Ok(())
    }
    
    /// Registra "Abrir pasta com mini" para diretórios.
    pub fn register_folder_handler(&self) -> Result<()> {
        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        
        // Para diretórios
        let (key, _) = hkcu.create_subkey(
            r"Software\Classes\Directory\shell\mini"
        )?;
        key.set_value("", &"Abrir pasta com mini")?;
        key.set_value("Icon", &self.exe_path)?;
        
        let (cmd_key, _) = hkcu.create_subkey(
            r"Software\Classes\Directory\shell\mini\command"
        )?;
        cmd_key.set_value("", &format!("\"{}\" \"%1\"", self.exe_path))?;
        
        // Para background de diretório
        let (bg_key, _) = hkcu.create_subkey(
            r"Software\Classes\Directory\Background\shell\mini"
        )?;
        bg_key.set_value("", &"Abrir com mini")?;
        bg_key.set_value("Icon", &self.exe_path)?;
        
        let (bg_cmd_key, _) = hkcu.create_subkey(
            r"Software\Classes\Directory\Background\shell\mini\command"
        )?;
        bg_cmd_key.set_value("", &format!("\"{}\" \"%V\"", self.exe_path))?;
        
        Ok(())
    }
    
    /// Remove todas as entradas do registro.
    pub fn unregister_all(&self) -> Result<()> {
        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        
        let _ = hkcu.delete_subkey_all(r"Software\Classes\*\shell\mini");
        let _ = hkcu.delete_subkey_all(r"Software\Classes\Directory\shell\mini");
        let _ = hkcu.delete_subkey_all(r"Software\Classes\Directory\Background\shell\mini");
        
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_registrar_creation() {
        let registrar = ContextMenuRegistrar::new();
        assert!(registrar.is_ok());
    }
}
```


### Inicialização com o SO

**`crates/mini_os/src/windows/startup.rs`:**

```rust
use winreg::enums::*;
use winreg::RegKey;
use anyhow::Result;

/// Gerencia inicialização automática do mini com o Windows.
pub struct StartupManager {
    exe_path: String,
}

impl StartupManager {
    pub fn new() -> Result<Self> {
        let exe_path = std::env::current_exe()?
            .to_string_lossy()
            .to_string();
        
        Ok(Self { exe_path })
    }
    
    /// Habilita inicialização automática.
    pub fn enable(&self) -> Result<()> {
        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        let (key, _) = hkcu.create_subkey(
            r"Software\Microsoft\Windows\CurrentVersion\Run"
        )?;
        
        key.set_value("mini", &format!("\"{}\" --minimized", self.exe_path))?;
        Ok(())
    }
    
    /// Desabilita inicialização automática.
    pub fn disable(&self) -> Result<()> {
        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        let key = hkcu.open_subkey_with_flags(
            r"Software\Microsoft\Windows\CurrentVersion\Run",
            KEY_WRITE,
        )?;
        
        let _ = key.delete_value("mini");
        Ok(())
    }
    
    /// Verifica se inicialização automática está habilitada.
    pub fn is_enabled(&self) -> bool {
        let hkcu = RegKey::predef(HKEY_CURRENT_USER);
        if let Ok(key) = hkcu.open_subkey(r"Software\Microsoft\Windows\CurrentVersion\Run") {
            key.get_value::<String, _>("mini").is_ok()
        } else {
            false
        }
    }
}
```


### Internacionalização

**`crates/mini_os/src/i18n.rs`:**

```rust
use serde::{Deserialize, Serialize};
use std::collections::HashMap;
use anyhow::Result;

/// Idiomas suportados.
#[derive(Debug, Clone, Copy, PartialEq, Serialize, Deserialize)]
pub enum Language {
    #[serde(rename = "pt-BR")]
    PortugueseBrazil,
    #[serde(rename = "en")]
    English,
    #[serde(rename = "zh")]
    Chinese,
}

impl Default for Language {
    fn default() -> Self {
        Self::PortugueseBrazil
    }
}

/// Sistema de tradução.
pub struct I18n {
    current_language: Language,
    translations: HashMap<String, HashMap<String, String>>,
}

impl I18n {
    pub fn new(language: Language) -> Result<Self> {
        let mut i18n = Self {
            current_language: language,
            translations: HashMap::new(),
        };
        
        i18n.load_translations()?;
        Ok(i18n)
    }
    
    fn load_translations(&mut self) -> Result<()> {
        // Português do Brasil
        let mut pt_br = HashMap::new();
        pt_br.insert("file".to_string(), "Arquivo".to_string());
        pt_br.insert("edit".to_string(), "Editar".to_string());
        pt_br.insert("view".to_string(), "Visual".to_string());
        pt_br.insert("tools".to_string(), "Ferramentas".to_string());
        pt_br.insert("help".to_string(), "Ajuda".to_string());
        pt_br.insert("tasks".to_string(), "Tarefas".to_string());
        pt_br.insert("sync".to_string(), "Sincronização".to_string());
        pt_br.insert("settings".to_string(), "Configurações".to_string());
        pt_br.insert("open_file".to_string(), "Abrir Arquivo".to_string());
        pt_br.insert("open_folder".to_string(), "Abrir Pasta".to_string());
        pt_br.insert("save".to_string(), "Salvar".to_string());
        pt_br.insert("close".to_string(), "Fechar".to_string());
        self.translations.insert("pt-BR".to_string(), pt_br);
        
        // English
        let mut en = HashMap::new();
        en.insert("file".to_string(), "File".to_string());
        en.insert("edit".to_string(), "Edit".to_string());
        en.insert("view".to_string(), "View".to_string());
        en.insert("tools".to_string(), "Tools".to_string());
        en.insert("help".to_string(), "Help".to_string());
        en.insert("tasks".to_string(), "Tasks".to_string());
        en.insert("sync".to_string(), "Sync".to_string());
        en.insert("settings".to_string(), "Settings".to_string());
        en.insert("open_file".to_string(), "Open File".to_string());
        en.insert("open_folder".to_string(), "Open Folder".to_string());
        en.insert("save".to_string(), "Save".to_string());
        en.insert("close".to_string(), "Close".to_string());
        self.translations.insert("en".to_string(), en);
        
        // 中文 (Chinese)
        let mut zh = HashMap::new();
        zh.insert("file".to_string(), "文件".to_string());
        zh.insert("edit".to_string(), "编辑".to_string());
        zh.insert("view".to_string(), "视图".to_string());
        zh.insert("tools".to_string(), "工具".to_string());
        zh.insert("help".to_string(), "帮助".to_string());
        zh.insert("tasks".to_string(), "任务".to_string());
        zh.insert("sync".to_string(), "同步".to_string());
        zh.insert("settings".to_string(), "设置".to_string());
        zh.insert("open_file".to_string(), "打开文件".to_string());
        zh.insert("open_folder".to_string(), "打开文件夹".to_string());
        zh.insert("save".to_string(), "保存".to_string());
        zh.insert("close".to_string(), "关闭".to_string());
        self.translations.insert("zh".to_string(), zh);
        
        Ok(())
    }
    
    /// Obtém tradução para uma chave.
    pub fn t(&self, key: &str) -> String {
        let lang_key = match self.current_language {
            Language::PortugueseBrazil => "pt-BR",
            Language::English => "en",
            Language::Chinese => "zh",
        };
        
        self.translations
            .get(lang_key)
            .and_then(|t| t.get(key))
            .cloned()
            .unwrap_or_else(|| key.to_string())
    }
    
    /// Muda o idioma atual.
    pub fn set_language(&mut self, language: Language) {
        self.current_language = language;
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_translations() {
        let i18n = I18n::new(Language::PortugueseBrazil).unwrap();
        assert_eq!(i18n.t("file"), "Arquivo");
        
        let i18n_en = I18n::new(Language::English).unwrap();
        assert_eq!(i18n_en.t("file"), "File");
        
        let i18n_zh = I18n::new(Language::Chinese).unwrap();
        assert_eq!(i18n_zh.t("file"), "文件");
    }
}
```


### Testes da Fase 8

```rust
#[cfg(test)]
mod os_tests {
    use super::*;

    #[test]
    fn test_i18n_all_languages() {
        for lang in [Language::PortugueseBrazil, Language::English, Language::Chinese] {
            let i18n = I18n::new(lang).unwrap();
            assert!(!i18n.t("file").is_empty());
            assert!(!i18n.t("save").is_empty());
        }
    }
    
    #[test]
    fn test_context_menu_registrar() {
        let registrar = ContextMenuRegistrar::new();
        assert!(registrar.is_ok());
    }
    
    #[test]
    fn test_startup_manager() {
        let manager = StartupManager::new();
        assert!(manager.is_ok());
    }
}
```


### Critérios de Aceitação - Fase 8

- [ ] Menu de contexto "Abrir com mini" registrado
- [ ] Menu de contexto "Abrir pasta com mini" registrado
- [ ] Inicialização com SO configurável
- [ ] i18n funciona para pt-BR, en, zh
- [ ] Estrutura de auto-update criada (com TODOs)
- [ ] Todos os testes passam


### Notificação

```bash
cast.exe send tg me "FASE 8 CONCLUÍDA: Atualizações e Ambiente SO (com TODOs) - Menu de contexto, startup, i18n implementados"
```


***

## Checklist Final de Implementação

### Dependências Consolidadas (Cargo.toml workspace)

```toml
[workspace.dependencies]
# Core
serde = { version = "1.0", features = ["derive"] }
serde_json = "1.0"
anyhow = "1.0"
tokio = { version = "1.0", features = ["full"] }
chrono = { version = "0.4", features = ["serde"] }

# Windows
windows = { version = "0.52", features = [
    "Win32_UI_Shell",
    "Win32_UI_WindowsAndMessaging",
    "Win32_Foundation",
]}
winreg = "0.52"

# Sync
git2 = "0.18"
oauth2 = "4.4"
reqwest = { version = "0.11", features = ["json"] }

# Utilities
uuid = { version = "1.6", features = ["v4", "serde"] }
walkdir = "2.4"
dirs = "5.0"
regex = "1.10"
log = "0.4"
env_logger = "0.10"
```


### Comandos de Verificação por Fase

```bash
# Após cada fase:
cargo clippy --all -- -D warnings
cargo test --all
cargo fmt --all -- --check

# Gerar relatório:
echo "# Relatório Fase X - $(date)" > D:\proj\mini\project-mini\reports\FASE-X.md

# Notificar:
cast.exe send tg me "FASE X CONCLUÍDA: [descrição]"
```


### Sequência de Execução

1. **FASE 0** → Setup básico e compilação
2. **FASE 1** → TrayIcon (base para outras funcionalidades)
3. **FASE 2** → UI/UX (tema, fontes, janela)
4. **FASE 3** → Arquivos e navegação
5. **FASE 4** → Editor e funcionalidades de texto
6. **FASE 5** → Gerenciador de tarefas
7. **FASE 6** → Integração com IA
8. **FASE 7** → Sincronização (com TODOs)
9. **FASE 8** → Atualizações e SO (com TODOs)

***

*Documento elaborado pelo Arquiteto/Supervisor IA (Perplexity) como complemento às especificações do Claude, respeitando os requisitos do PO.*

<div align="center">⁂</div>

[^1]: Especificacoes-Incompletas.md

