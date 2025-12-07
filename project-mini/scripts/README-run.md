# Script de Execução de Comandos Cargo

## Descrição

Script PowerShell para execução sequencial de comandos Cargo com detecção robusta de erros e logging individual.

## Características

- ✅ **Detecção de erros em 3 níveis:**
  1. Comando não encontrado
  2. Código de saída (exit code)
  3. Palavras-chave no log (error, failed, panic, etc.)

- ✅ **Cancelamento em cascata:** Se um comando falha, os seguintes são cancelados automaticamente

- ✅ **Logs individuais:** Cada comando gera seu próprio log em `project-mini/logs/`

- ✅ **Suporte a fases:** Comandos pré-configurados para cada fase do projeto

## Uso

### Executar Fase Específica

```powershell
# FASE 0: Setup e Rebranding
.\project-mini\scripts\run.ps1 -Phase 0

# FASE 1: TrayIcon e Window Management
.\project-mini\scripts\run.ps1 -Phase 1

# FASE 2: UI/UX Foundation
.\project-mini\scripts\run.ps1 -Phase 2

# ... e assim por diante até FASE 8
```

### Executar Comandos Customizados

```powershell
$comandos = @(
    @{
        Descricao = "Meu Comando"
        Comando = "cargo check --package mini"
        LogFile = "logs/custom-check.log"
    }
)
.\project-mini\scripts\run.ps1 -Custom $comandos
```

### Executar Fase Padrão (FASE 0)

```powershell
.\project-mini\scripts\run.ps1
```

## Estrutura de Logs

Todos os logs são salvos em `project-mini/logs/` com o seguinte padrão:

- `fase0-cargo-check.log`
- `fase0-cargo-build-release.log`
- `fase1-cargo-check.log`
- etc.

## Palavras-chave de Erro Detectadas

O script detecta automaticamente as seguintes palavras-chave nos logs (case-insensitive):

- `error`
- `failed`
- `fatal`
- `panic`
- `abort`
- `out of memory`
- `cannot find`
- `expected`
- `found`
- `error:`
- `warning:`
- `failed to`
- `compilation failed`
- `linker.*not found`
- `no such file`
- `undefined reference`
- `undefined symbol`

## Comandos por Fase

### FASE 0: Setup e Rebranding
- `cargo check --package mini`
- `cargo build --release --package mini`

### FASE 1: TrayIcon e Window Management
- `cargo check --package mini --package mini_ui`
- `cargo test --package mini_ui`
- `cargo build --release --package mini --package mini_ui`

### FASE 2: UI/UX Foundation
- `cargo check --package mini --package mini_ui --package mini_theme`
- `cargo test --package mini_theme`
- `cargo build --release --package mini --package mini_ui --package mini_theme`

### FASE 3: Sistema de Arquivos
- `cargo check --package mini --package mini_core`
- `cargo test --package mini_core`
- `cargo build --release --package mini --package mini_core`

### FASE 4-7: Fases Intermediárias
- `cargo check --workspace`
- `cargo test --workspace`
- `cargo clippy --workspace -- -D warnings` (FASE 4)

### FASE 8: Finalização
- `cargo check --workspace`
- `cargo test --workspace`
- `cargo build --release`

## Exemplos de Saída

### Sucesso
```
[1/2] Executando 'Verificação de Sintaxe (cargo check)'...
✓ Comando executado com sucesso! [Duração: 01:23]
```

### Erro Detectado
```
[1/2] Executando 'Compilação Release (cargo build --release)'...
✗ O comando retornou código de saída 101
  Verifique o log em: D:\proj\mini\project-mini\logs\fase0-cargo-build-release.log

  [Tipo de erro: exit-code] [Duração: 02:15]

[2/2] Execução do comando 'Testes Unitários (cargo test)' cancelada.
```

## Troubleshooting

### Problema: Script não executa comandos

**Solução:** Certifique-se de estar no diretório raiz do projeto (`D:\proj\mini`) ou ajuste o `$ProjectRoot` no script.

### Problema: Logs não são gerados

**Solução:** Verifique se o diretório `project-mini/logs/` existe e tem permissões de escrita.

### Problema: Comandos são cancelados incorretamente

**Solução:** Verifique o log do comando anterior. Pode haver uma palavra-chave de erro sendo detectada incorretamente. Ajuste o array `$palavrasErro` no script se necessário.

## Requisitos

- PowerShell 5.1 ou superior (recomendado: PowerShell 7+)
- Rust e Cargo instalados e no PATH
- Permissões de escrita no diretório do projeto
