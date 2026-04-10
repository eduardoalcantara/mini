# SPEC — Config Service
**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Status:** TO-DO
**Arquivo:** `project/specs/to-do/2026-04-10-SPEC-config-service.md`

**Pipeline:** executar **primeiro** neste lote. Pode correr em paralelo com `SPEC-fontes-embed`. Ver [`2026-04-10-README-batch-specs.md`](./2026-04-10-README-batch-specs.md).

---

## Objetivo

Implementar o `ConfigService` em Go — responsável por ler, persistir e expor as
configurações do usuário em `config.json`, na mesma pasta do executável.
Expor bindings Wails para o frontend consultar e alterar configurações.

---

## Schema do `config.json`

```json
{
  "theme": "perplexity-dark",
  "font": "auto",
  "font_size": 16,
  "line_wrap": true,
  "line_numbers": true
}
```

### Valores válidos por campo

| Campo | Tipo | Valores aceitos | Padrão |
|---|---|---|---|
| `theme` | string | `"perplexity-dark"`, `"github-light-default"`, `"claude-code-light"`, `"moleskine-light"`, ou slug de tema customizado | `"perplexity-dark"` |
| `font` | string | `"auto"`, `"eb-garamond"`, `"jetbrains-mono"`, `"other"` | `"auto"` |
| `font_size` | int | 10–18 | 16 |
| `line_wrap` | bool | true, false | true |
| `line_numbers` | bool | true, false | true |

### Lógica do `font: "auto"`

Quando `font` é `"auto"`, o backend resolve a fonte com base na extensão do arquivo aberto:

- **JetBrains Mono:** `.md`, `.js`, `.ts`, `.go`, `.json`, `.yaml`, `.yml`, `.toml`, `.html`, `.css`, `.scss`, `.py`, `.sh`, `.bash`, `.zsh`, `.rs`, `.c`, `.cpp`, `.h`, `.java`, `.kt`, `.rb`, `.php`, `.sql`
- **EB Garamond:** `.txt` e qualquer extensão não listada acima (incluindo sem extensão)

---

## Localização do `config.json`

```go
// Caminho resolvido em runtime — mesma pasta do executável
exe, err := os.Executable()
if err != nil { /* tratar */ }
configPath := filepath.Join(filepath.Dir(exe), "config.json")
```

> ⚠️ Durante `wails dev`, `os.Executable()` aponta para um binário temporário em cache.
> O Cursor deve testar o caminho real e documentar no relatório onde o `config.json`
> é criado em modo dev vs. modo build.

---

## Tarefas

### 1. Criar `src/models/config.go`

```go
// src/models/config.go
package models

// Config representa as preferências persistidas do usuário.
type Config struct {
    Theme       string `json:"theme"`
    Font        string `json:"font"`
    FontSize    int    `json:"font_size"`
    LineWrap    bool   `json:"line_wrap"`
    LineNumbers bool   `json:"line_numbers"`
}

// DefaultConfig retorna a configuração padrão do app.
func DefaultConfig() Config {
    return Config{
        Theme:       "perplexity-dark",
        Font:        "auto",
        FontSize:    16,
        LineWrap:    true,
        LineNumbers: true,
    }
}
```

---

### 2. Criar `src/services/config_service.go`

Responsabilidades:
- Resolver o caminho do `config.json` via `os.Executable()`
- Ler e desserializar o JSON na inicialização
- Criar o arquivo com valores padrão se não existir
- Serializar e escrever no disco a cada alteração
- Resolver a fonte correta quando `font == "auto"` dado uma extensão de arquivo

```go
// src/services/config_service.go
package services

import (
    "encoding/json"
    "os"
    "path/filepath"
    "strings"

    "mini/src/models"
)

// ConfigService gerencia leitura e persistência das configurações do usuário.
type ConfigService struct {
    path   string
    config models.Config
}

// NewConfigService inicializa o serviço, lendo ou criando o config.json.
func NewConfigService() (*ConfigService, error) {
    exe, err := os.Executable()
    if err != nil {
        return nil, err
    }
    path := filepath.Join(filepath.Dir(exe), "config.json")

    svc := &ConfigService{path: path}
    if err := svc.load(); err != nil {
        return nil, err
    }
    return svc, nil
}

func (s *ConfigService) load() error {
    data, err := os.ReadFile(s.path)
    if os.IsNotExist(err) {
        s.config = models.DefaultConfig()
        return s.save()
    }
    if err != nil {
        return err
    }
    return json.Unmarshal(data, &s.config)
}

func (s *ConfigService) save() error {
    data, err := json.MarshalIndent(s.config, "", "  ")
    if err != nil {
        return err
    }
    return os.WriteFile(s.path, data, 0644)
}

// Get retorna uma cópia da configuração atual.
func (s *ConfigService) Get() models.Config {
    return s.config
}

// Set atualiza a configuração e persiste imediatamente no disco.
func (s *ConfigService) Set(cfg models.Config) error {
    s.config = cfg
    return s.save()
}

// ResolveFont retorna o nome da fonte a usar para uma dada extensão de arquivo.
// Se font == "auto", resolve pela extensão. Caso contrário, retorna o valor direto.
func (s *ConfigService) ResolveFont(fileExt string) string {
    if s.config.Font != "auto" {
        return s.config.Font
    }
    codeExts := map[string]bool{
        ".md": true, ".js": true, ".ts": true, ".go": true,
        ".json": true, ".yaml": true, ".yml": true, ".toml": true,
        ".html": true, ".css": true, ".scss": true, ".py": true,
        ".sh": true, ".bash": true, ".zsh": true, ".rs": true,
        ".c": true, ".cpp": true, ".h": true, ".java": true,
        ".kt": true, ".rb": true, ".php": true, ".sql": true,
    }
    ext := strings.ToLower(fileExt)
    if codeExts[ext] {
        return "jetbrains-mono"
    }
    return "eb-garamond"
}
```

---

### 3. Criar `src/models/font_result.go`

```go
// src/models/font_result.go
package models

// FontResult é retornado ao frontend com a fonte e tamanho resolvidos.
type FontResult struct {
    Font     string `json:"font"`
    FontSize int    `json:"font_size"`
}
```

---

### 4. Atualizar `src/app/app.go`

Injetar o `ConfigService` na struct `App` e expor os bindings:

```go
type App struct {
    ctx    context.Context
    config *services.ConfigService
}

func NewApp() *App {
    return &App{}
}

func (a *App) Startup(ctx context.Context) {
    a.ctx = ctx
    cfg, err := services.NewConfigService()
    if err != nil {
        slog.Error("falha ao inicializar ConfigService", "err", err)
        // continuar com padrões em memória
        return
    }
    a.config = cfg
}

// GetConfig retorna a configuração atual do usuário.
func (a *App) GetConfig() (models.Config, error) {
    if a.config == nil {
        return models.DefaultConfig(), nil
    }
    return a.config.Get(), nil
}

// SetConfig persiste a configuração atualizada.
func (a *App) SetConfig(cfg models.Config) error {
    if a.config == nil {
        return nil
    }
    return a.config.Set(cfg)
}

// ResolveFont retorna a fonte correta para uma dada extensão de arquivo.
// Extensão deve incluir o ponto: ".txt", ".go", ".md"
func (a *App) ResolveFont(fileExt string) (models.FontResult, error) {
    font := "eb-garamond"
    fontSize := 16
    if a.config != nil {
        font = a.config.ResolveFont(fileExt)
        fontSize = a.config.Get().FontSize
    }
    return models.FontResult{Font: font, FontSize: fontSize}, nil
}
```

---

### 5. Atualizar `main.go`

Garantir que `NewApp()` é chamado e passado corretamente ao Wails
(provavelmente já está — verificar e ajustar apenas se necessário).

---

### 6. Atualizar `frontend/src/bindings/index.js`

Após o `wails dev` gerar os bindings em `frontend/src/bindings/wailsjs/go/app/App.js`:

```javascript
// frontend/src/bindings/index.js
import { GetConfig, SetConfig, ResolveFont } from './wailsjs/go/app/App.js';

export const getConfig   = ()        => GetConfig();
export const setConfig   = (cfg)     => SetConfig(cfg);
export const resolveFont = (fileExt) => ResolveFont(fileExt);
```

> ⚠️ Os bindings só são gerados pelo Wails após `wails dev` ou `wails build`.
> Verificar o caminho real gerado e ajustar o import se necessário.

---

## Validações obrigatórias

```powershell
$RepoRoot = Split-Path -Parent $PSScriptRoot
$Wails    = Join-Path $RepoRoot "tools\wails.exe"
$Lint     = Join-Path $RepoRoot "tools\golangci-lint.exe"

go build ./...
& $Lint run
& $Wails build
& $Wails dev
```

---

## Critérios de aceitação

- [ ] `go build ./...` — sem erros
- [ ] `golangci-lint run` — 0 issues
- [ ] `wails build` — `build/bin/mini.exe` gerado sem erros
- [ ] Na primeira execução do `mini.exe`, `config.json` é criado na mesma pasta com os valores padrão
- [ ] Ao chamar `GetConfig()` no console do WebView2 durante `wails dev`, retorna o objeto de configuração
- [ ] Ao chamar `SetConfig({...})` com valores alterados, o `config.json` é atualizado no disco imediatamente
- [ ] `ResolveFont(".go")` retorna `"jetbrains-mono"`
- [ ] `ResolveFont(".txt")` retorna `"eb-garamond"`
- [ ] `ResolveFont(".xyz")` retorna `"eb-garamond"` (extensão desconhecida)
- [ ] Com `font: "jetbrains-mono"` no config, `ResolveFont(".txt")` retorna `"jetbrains-mono"` (override manual)
- [ ] Documentar no relatório o caminho real do `config.json` em modo dev

---

## Bloqueios — parar e consultar o Supervisor se:

1. `os.Executable()` em modo dev apontar para path inesperado que cause erro de permissão
2. O Wails não gerar os bindings automaticamente após `wails dev` — verificar `wailsjsdir` no `wails.json`
3. Qualquer erro de lint que impacte mais de 3 arquivos

---

## Arquivos a criar/modificar

| Ação | Arquivo |
|---|---|
| CRIAR | `src/models/config.go` |
| CRIAR | `src/models/font_result.go` |
| CRIAR | `src/services/config_service.go` |
| MODIFICAR | `src/app/app.go` — injetar ConfigService + bindings |
| MODIFICAR | `main.go` — verificar inicialização |
| MODIFICAR | `frontend/src/bindings/index.js` — expor getConfig, setConfig, resolveFont |
| MODIFICAR | `STATUS.md` |
