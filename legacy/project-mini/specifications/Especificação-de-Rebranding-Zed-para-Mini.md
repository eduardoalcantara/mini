# Especificação de Rebranding: Zed → mini

**Versão:** 1.0
**Data:** 2024-12-06
**Status:** Em Análise

---

## 1. Objetivo

Transformar o **Zed Editor** em **mini** (Minimalist, Intelligent, Nice Interface), mantendo a base técnica do Zed mas criando uma identidade visual e funcional completamente nova, focada em minimalismo e edição de texto pura.

---

## 2. Escopo do Rebranding

### 2.1 Nome do Produto

| Antes (Zed) | Depois (mini) |
|-------------|---------------|
| Zed | mini |
| Zed Editor | mini Editor |
| zed.exe | mini.exe |
| Zed Industries | Eduardo Almeida (PO) |

### 2.2 Identidade Visual

#### Cores Principais
- **Antes:** Tema escuro com azul/roxo
- **Depois:** Tema Moleskine Light (bege/sépia com toques de preto)

#### Ícone/Logo
- **Antes:** Logo Zed (raio/lightning)
- **Depois:** Logo mini (a definir - sugestão: caderno minimalista ou letra "m" estilizada)

#### Tipografia
- **Antes:** Inter, JetBrains Mono
- **Depois:** Manter ou ajustar para fonte mais "caderno" (a definir)

---

## 3. Alterações Técnicas Necessárias

### 3.1 Sistema de Build (Cargo)

#### Arquivos a modificar:

**`Cargo.toml` (workspace root)**
```toml
[workspace]
members = [
    "crates/mini",           # era crates/zed
    "crates/mini_actions",   # era crates/zed_actions
    # ... outros
]

[workspace.package]
version = "0.1.0"
edition = "2021"
authors = ["Eduardo Almeida <eduardo@...>"]
homepage = "https://github.com/user/mini"
license = "GPL-3.0"
```

**`crates/zed/Cargo.toml` → `crates/mini/Cargo.toml`**
```toml
[package]
name = "mini"
description = "Minimalist, Intelligent, Nice Interface - A clean text editor"
repository = "https://github.com/user/mini"

[[bin]]
name = "mini"
path = "src/main.rs"
```

### 3.2 Estrutura de Diretórios

#### Renomeações obrigatórias:

```
crates/zed/                     → crates/mini/
crates/zed_actions/             → crates/mini_actions/
crates/collab/                  → [REMOVER - não usaremos colaboração]
crates/collab_ui/               → [REMOVER]
crates/assistant/               → [REMOVER - não usaremos AI]
crates/assistant_tooling/       → [REMOVER]

# Manter (mas revisar imports):
crates/editor/
crates/gpui/
crates/workspace/
crates/theme/
crates/settings/
crates/fs/
crates/git/
```

### 3.3 Código-Fonte

#### Busca e Substituição Global

Execute os seguintes comandos (após backup):

```bash
# Renomear referências no código
grep -r "zed::" crates/ | # Identificar imports
sed -i 's/use zed::/use mini::/g' crates/**/*.rs

# Atualizar strings de usuário
sed -i 's/"Zed"/"mini"/g' crates/**/*.rs
sed -i 's/"Zed Editor"/"mini Editor"/g' crates/**/*.rs

# Atualizar URLs
sed -i 's|zed-industries/zed|user/mini|g' crates/**/*.rs
sed -i 's|https://zed.dev|https://mini-editor.com|g' crates/**/*.rs
```

#### Arquivos críticos a revisar manualmente:

1. **`crates/mini/src/main.rs`**
   - Window title
   - Application name
   - Crash reporter (remover ou customizar)

2. **`crates/workspace/src/workspace.rs`**
   - Títulos de janelas
   - Mensagens de boas-vindas

3. **`crates/welcome/src/welcome.rs`**
   - Tela de boas-vindas completa
   - Links e textos

4. **`crates/theme/src/default_theme.rs`**
   - Tema padrão → Moleskine Light

### 3.4 Assets e Recursos

#### Diretório: `assets/`

**Ícones a substituir:**
```
assets/icons/app_icon.icns        # macOS
assets/icons/app_icon.ico         # Windows
assets/icons/app_icon.png         # Linux
assets/icons/tray_icon.png        # System tray
```

**Imagens a substituir:**
```
assets/images/logo.png
assets/images/splash.png
assets/images/welcome_screen.png
```

**Fontes (opcional):**
```
assets/fonts/                      # Adicionar fontes customizadas se necessário
```

### 3.5 Configurações e Paths

#### Diretórios de configuração do usuário:

**Windows:**
```
%APPDATA%/Zed/          → %APPDATA%/mini/
```

**macOS:**
```
~/Library/Application Support/Zed/   → ~/Library/Application Support/mini/
```

**Linux:**
```
~/.config/zed/          → ~/.config/mini/
```

#### Arquivos de configuração:

**`crates/settings/src/settings.rs`**
```rust
// Antes:
const APP_NAME: &str = "Zed";

// Depois:
const APP_NAME: &str = "mini";
```

**Arquivos de exemplo:**
```
assets/settings/default.json
assets/settings/vim.json
assets/keymap-default.json
```

### 3.6 Metadados do Sistema Operacional

#### Windows (`script/windows/build.ps1`):

```xml
<!-- Antes -->
<Product Name="Zed" Manufacturer="Zed Industries" Version="..." />

<!-- Depois -->
<Product Name="mini" Manufacturer="Eduardo Almeida" Version="0.1.0" />
```

#### macOS (`script/bundle-mac`):

```xml
<key>CFBundleName</key>
<string>mini</string>
<key>CFBundleDisplayName</key>
<string>mini Editor</string>
<key>CFBundleIdentifier</key>
<string>com.eduardoalmeida.mini</string>
```

#### Linux (`.desktop` file):

```ini
[Desktop Entry]
Name=mini
Comment=Minimalist text editor
Exec=/usr/bin/mini
Icon=mini
```

---

## 4. Strings de Interface do Usuário

### 4.1 Mensagens a alterar

| Contexto | Antes | Depois |
|----------|-------|--------|
| Window Title | "Zed" | "mini" |
| Welcome Screen | "Welcome to Zed" | "Bem-vindo ao mini" |
| About Dialog | "Zed Editor v..." | "mini Editor v..." |
| Update Check | "Zed is up to date" | "mini está atualizado" |
| Crash Reporter | "Zed has crashed" | "mini encontrou um erro" |
| Menu Items | "Zed > Preferences" | "mini > Preferências" |

### 4.2 Arquivos de localização

Se o Zed usar arquivos de tradução, criar/atualizar:

```
assets/locales/pt-BR.json
assets/locales/en.json
```

---

## 5. Documentação Interna

### 5.1 Arquivos a atualizar

- `README.md` → Reescrever para mini
- `LICENSE.txt` → Verificar compatibilidade GPL/MIT
- `CONTRIBUTING.md` → Adaptar ou remover
- `docs/` → Limpar documentação do Zed, criar documentação mini

### 5.2 Comentários no código

Não é necessário alterar comentários internos que mencionem "Zed" em contexto técnico, mas revisar:

- Headers de arquivos com copyright
- Comentários em funções públicas
- Documentação inline (`///`)

---

## 6. Features a Remover

Ao renomear, também **remover/desabilitar** features não desejadas:

### 6.1 Colaboração (Collab)

**Crates a remover:**
- `crates/collab/`
- `crates/collab_ui/`
- `crates/channel/`
- `crates/call/`
- `crates/live_kit_client/`

**Remover dependências em:**
- `Cargo.toml` (workspace)
- `crates/zed/Cargo.toml`

### 6.2 AI/Assistant

**Crates a remover:**
- `crates/assistant/`
- `crates/assistant_tooling/`
- `crates/prompt_library/`

### 6.3 Telemetry/Analytics

**Arquivos a modificar:**
- `crates/client/src/telemetry.rs` → Substituir por no-op
- Remover chaves de API/tracking

---

## 7. Testes Pós-Rebranding

### 7.1 Checklist de Verificação

- [ ] Binário gerado se chama `mini.exe` / `mini`
- [ ] Window title mostra "mini"
- [ ] Ícone da aplicação é o novo logo mini
- [ ] Tray icon é o novo ícone mini
- [ ] Configurações salvam em `%APPDATA%/mini/`
- [ ] About dialog mostra informações corretas
- [ ] Nenhuma referência a "Zed" na UI visível
- [ ] Links apontam para repositório/site corretos
- [ ] Tema padrão é Moleskine Light
- [ ] Features removidas não aparecem (collab, AI)

### 7.2 Testes de Build

```bash
# Clean build
cargo clean
cargo build --release

# Verificar binário
file target/release/mini.exe
target/release/mini.exe --version

# Buscar referências residuais
grep -r "Zed" target/release/ | grep -v ".pdb"
```

### 7.3 Testes de Integração

- Abrir arquivos
- Editar e salvar
- Testar syntax highlighting
- Verificar temas
- Testar atalhos de teclado
- Minimizar para tray (quando implementado)

---

## 8. Estratégia de Implementação

### Fase 1: Preparação (1h)
1. ✅ Criar esta especificação
2. Fazer backup completo do código
3. Criar branch `rebranding/zed-to-mini`
4. Documentar estrutura atual

### Fase 2: Renomeações Estruturais (2-3h)
1. Renomear diretórios principais (`crates/zed` → `crates/mini`)
2. Atualizar todos os `Cargo.toml`
3. Atualizar imports e módulos Rust
4. Testar compilação incremental

### Fase 3: Assets e Visual (1-2h)
1. Criar/substituir ícones
2. Atualizar imagens
3. Configurar tema Moleskine Light como padrão
4. Atualizar cores de UI

### Fase 4: Strings e Mensagens (1h)
1. Busca e substituição de strings
2. Traduzir para português onde apropriado
3. Atualizar arquivos de configuração de exemplo

### Fase 5: Remoção de Features (2h)
1. Remover crates de colaboração
2. Remover crates de AI
3. Desabilitar telemetry
4. Limpar dependências não usadas

### Fase 6: Testes e Validação (2h)
1. Build completo em release
2. Executar todos os testes
3. Testes manuais de UI
4. Verificar instalação/empacotamento

### Fase 7: Documentação (1h)
1. Atualizar README.md
2. Criar documentação de usuário
3. Documentar mudanças para desenvolvedores

**Tempo estimado total: 10-12 horas**

---

## 9. Riscos e Mitigações

### 9.1 Riscos Técnicos

| Risco | Impacto | Probabilidade | Mitigação |
|-------|---------|---------------|-----------|
| Quebra de compilação | Alto | Média | Testes incrementais, backup |
| Referências hardcoded | Médio | Alta | Grep recursivo, revisão manual |
| Paths de config | Alto | Baixa | Testar migração de configs antigas |
| Assets faltando | Baixo | Média | Usar placeholders temporários |

### 9.2 Riscos de Negócio

| Risco | Impacto | Probabilidade | Mitigação |
|-------|---------|---------------|-----------|
| Licenciamento | Alto | Baixa | Verificar GPL/MIT compatibility |
| Marca registrada | Médio | Baixa | "mini" é genérico, baixo risco |
| Updates do Zed upstream | Médio | Alta | Fork definitivo, não merge |

---

## 10. Ferramentas Úteis

### 10.1 Scripts de Automação

Criar scripts auxiliares em `project-mini/scripts/`:

- `rename-crates.sh` - Renomeia todos os crates
- `update-strings.sh` - Substitui strings no código
- `verify-branding.sh` - Verifica referências residuais
- `build-mini.sh` - Build customizado

### 10.2 Comandos Úteis

```bash
# Encontrar todas as referências a "Zed"
rg -i "zed" crates/ --type rust

# Encontrar imports problemáticos
rg "use zed::" crates/ -l

# Verificar Cargo.toml files
fd Cargo.toml -x cat {}

# Buscar hardcoded paths
rg '\.config/zed|AppData.*Zed' crates/
```

---

## 11. Critérios de Aceitação

### 11.1 Obrigatórios (MVP)

- [x] Compilação bem-sucedida com nome "mini"
- [ ] Executável `mini.exe` gerado
- [ ] Window title mostra "mini"
- [ ] Configurações em path correto (`%APPDATA%/mini/`)
- [ ] Nenhuma feature de collab/AI presente
- [ ] Tema padrão é Moleskine Light

### 11.2 Desejáveis

- [ ] Ícone customizado do mini
- [ ] Tela de boas-vindas customizada
- [ ] Documentação completa
- [ ] Instalador Windows com branding mini
- [ ] Site/landing page (se aplicável)

### 11.3 Futuro

- [ ] Logo profissional
- [ ] Animações de splash screen
- [ ] Branding completo (fontes, cores, temas)
- [ ] Empacotamento para distribuição

---

## 12. Referências

- [Zed Repository](https://github.com/zed-industries/zed)
- [Cargo Documentation](https://doc.rust-lang.org/cargo/)
- [GPUI Framework Docs](https://github.com/zed-industries/zed/tree/main/crates/gpui)
- Especificações do projeto mini em `project-mini/specifications/`

---

## 13. Notas Adicionais

### 13.1 Compatibilidade com Zed Upstream

Como estamos fazendo um **fork definitivo**, não é necessário manter compatibilidade com updates do Zed. Podemos fazer mudanças estruturais profundas sem preocupação com merge conflicts futuros.

### 13.2 Licenciamento

- **Zed:** GPL-3.0 + Apache-2.0 (dual license)
- **mini:** GPL-3.0 (compatível, permitido)
- Manter atribuição ao Zed nos créditos
- Adicionar copyright do mini

### 13.3 Trademark

"Zed" é marca registrada da Zed Industries. "mini" é um nome genérico, baixo risco de conflito. Evitar usar "fork of Zed" em marketing, mas pode mencionar em documentação técnica.

---

**Documento criado por:** IA Assistant (Claude)
**Revisado por:** Eduardo Almeida (PO)
**Próxima revisão:** Após primeira implementação
