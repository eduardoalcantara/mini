# ============================================================================
# Script de Execução de Comandos Cargo com Controle de Erros
# ============================================================================
# Este script executa comandos Cargo sequencialmente com:
# - Controle de erros em cascata (se um falha, os seguintes são cancelados)
# - Logging individual por comando em project-mini/logs/
# - 3 tipos de verificação de erro (comando não encontrado, exit code, palavras-chave)
# - Suporte a diferentes fases do projeto via parâmetro -Phase
# - Detecção específica de erros Rust/Cargo
# ============================================================================
# Uso:
#   .\run.ps1                    # Executa comandos padrão (FASE 0)
#   .\run.ps1 -Phase 0           # FASE 0: Setup e Rebranding
#   .\run.ps1 -Phase 1           # FASE 1: TrayIcon e Window Management
#   .\run.ps1 -Phase 2           # FASE 2: UI/UX Foundation
#   .\run.ps1 -Custom @(...)     # Comandos customizados
# ============================================================================

param(
    [int]$Phase = 0,
    [array]$Custom = $null
)

Clear-Host

# ============================================================================
# VERIFICAÇÃO DE LOCK: Evita execuções simultâneas
# ============================================================================
$LockFile = Join-Path $env:TEMP "mini-build-script.lock"
$LockTimeout = 300 # 5 minutos - se o lock existir há mais que isso, assume que processo anterior morreu

if (Test-Path $LockFile) {
    $lockTime = (Get-Item $LockFile).LastWriteTime
    $age = (Get-Date) - $lockTime

    if ($age.TotalSeconds -lt $LockTimeout) {
        $lockPid = Get-Content $LockFile -ErrorAction SilentlyContinue
        $lockProcess = Get-Process -Id $lockPid -ErrorAction SilentlyContinue

        if ($lockProcess) {
            Write-Host "⚠️  Script já está em execução (PID: $lockPid)" -ForegroundColor Yellow
            Write-Host "   Aguarde a conclusão ou cancele o processo anterior." -ForegroundColor Yellow
            Write-Host "   Para forçar execução, delete o arquivo: $LockFile" -ForegroundColor DarkGray
            exit 1
        } else {
            # Processo morreu, remove lock antigo
            Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
            Write-Host "⚠️  Removido lock de processo que não existe mais." -ForegroundColor Yellow
        }
    } else {
        # Lock muito antigo, assume que processo morreu
        Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
        Write-Host "⚠️  Removido lock antigo (>$LockTimeout segundos)." -ForegroundColor Yellow
    }
}

# Cria lock file com PID atual
$PID | Set-Content $LockFile -ErrorAction SilentlyContinue

# Remove lock ao sair (mesmo em caso de erro)
$script:CleanupLock = {
    if (Test-Path $LockFile) {
        Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
    }
}
Register-EngineEvent PowerShell.Exiting -Action $script:CleanupLock | Out-Null

# ============================================================================
# CONFIGURAÇÃO: Diretório base do projeto
# ============================================================================
$ProjectRoot = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$LogsDir = Join-Path (Split-Path -Parent $PSScriptRoot) "logs"

# Cria diretório de logs se não existir
if (-not (Test-Path $LogsDir)) {
    New-Item -ItemType Directory -Path $LogsDir -Force | Out-Null
}

# ============================================================================
# CONFIGURAÇÃO: Palavras-chave que indicam erro nos logs (case-insensitive)
# Específicas para Rust/Cargo
# ============================================================================
$palavrasErro = @(
    "error",
    "failed",
    "fatal",
    "panic",
    "abort",
    "out of memory",
    "cannot find",
    "expected",
    "found",
    "error:",
    "warning:",
    "failed to",
    "compilation failed",
    "linker.*not found",
    "no such file",
    "undefined reference",
    "undefined symbol"
)

# ============================================================================
# CONFIGURAÇÃO: Comandos por Fase
# ============================================================================

function Get-ComandosFase0 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --package mini"
            LogFile = "logs/fase0-cargo-check.log"
        },
        @{
            Descricao = "Compilação Release (cargo build --release)"
            Comando = "cargo build --release --package mini"
            LogFile = "logs/fase0-cargo-build-release.log"
        }
    )
}

function Get-ComandosFase1 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --package mini --package mini_ui"
            LogFile = "logs/fase1-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --package mini_ui"
            LogFile = "logs/fase1-cargo-test.log"
        },
        @{
            Descricao = "Compilação Release (cargo build --release)"
            Comando = "cargo build --release --package mini --package mini_ui"
            LogFile = "logs/fase1-cargo-build-release.log"
        }
    )
}

function Get-ComandosFase2 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --package mini --package mini_ui --package mini_theme"
            LogFile = "logs/fase2-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --package mini_theme"
            LogFile = "logs/fase2-cargo-test.log"
        },
        @{
            Descricao = "Compilação Release (cargo build --release)"
            Comando = "cargo build --release --package mini --package mini_ui --package mini_theme"
            LogFile = "logs/fase2-cargo-build-release.log"
        }
    )
}

function Get-ComandosFase3 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --package mini --package mini_core"
            LogFile = "logs/fase3-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --package mini_core"
            LogFile = "logs/fase3-cargo-test.log"
        },
        @{
            Descricao = "Compilação Release (cargo build --release)"
            Comando = "cargo build --release --package mini --package mini_core"
            LogFile = "logs/fase3-cargo-build-release.log"
        }
    )
}

function Get-ComandosFase4 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --workspace"
            LogFile = "logs/fase4-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --workspace"
            LogFile = "logs/fase4-cargo-test.log"
        },
        @{
            Descricao = "Lint (cargo clippy)"
            Comando = "cargo clippy --workspace -- -D warnings"
            LogFile = "logs/fase4-cargo-clippy.log"
        }
    )
}

function Get-ComandosFase5 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --workspace"
            LogFile = "logs/fase5-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --workspace"
            LogFile = "logs/fase5-cargo-test.log"
        }
    )
}

function Get-ComandosFase6 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --workspace"
            LogFile = "logs/fase6-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --workspace"
            LogFile = "logs/fase6-cargo-test.log"
        }
    )
}

function Get-ComandosFase7 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --workspace"
            LogFile = "logs/fase7-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --workspace"
            LogFile = "logs/fase7-cargo-test.log"
        }
    )
}

function Get-ComandosFase8 {
    return @(
        @{
            Descricao = "Verificação de Sintaxe (cargo check)"
            Comando = "cargo check --workspace"
            LogFile = "logs/fase8-cargo-check.log"
        },
        @{
            Descricao = "Testes Unitários (cargo test)"
            Comando = "cargo test --workspace"
            LogFile = "logs/fase8-cargo-test.log"
        },
        @{
            Descricao = "Compilação Release Final (cargo build --release)"
            Comando = "cargo build --release"
            LogFile = "logs/fase8-cargo-build-release.log"
        }
    )
}

# ============================================================================
# Seleção de comandos baseado na fase ou custom
# ============================================================================
if ($null -ne $Custom) {
    $comandos = $Custom
} else {
    switch ($Phase) {
        0 { $comandos = Get-ComandosFase0 }
        1 { $comandos = Get-ComandosFase1 }
        2 { $comandos = Get-ComandosFase2 }
        3 { $comandos = Get-ComandosFase3 }
        4 { $comandos = Get-ComandosFase4 }
        5 { $comandos = Get-ComandosFase5 }
        6 { $comandos = Get-ComandosFase6 }
        7 { $comandos = Get-ComandosFase7 }
        8 { $comandos = Get-ComandosFase8 }
        default {
            Write-Host "Fase $Phase não configurada. Usando FASE 0." -ForegroundColor Yellow
            $comandos = Get-ComandosFase0
        }
    }
}

# Normaliza caminhos dos logs para serem relativos ao diretório do script
foreach ($cmd in $comandos) {
    if ($cmd.LogFile -notmatch '^[a-zA-Z]:\\' -and $cmd.LogFile -notmatch '^\\\\') {
        $cmd.LogFile = Join-Path $LogsDir (Split-Path -Leaf $cmd.LogFile)
    }
}

$ProgressPreference = 'SilentlyContinue'

# ============================================================================
# FUNÇÕES AUXILIARES
# ============================================================================

function Get-CaminhoCompleto {
    param([string]$Caminho)

    # Verifica se é caminho absoluto (tem letra de unidade ou UNC)
    if ($Caminho -match '^[a-zA-Z]:\\' -or $Caminho -match '^\\\\') {
        return $Caminho
    }

    # Se for relativo, concatena com o diretório do projeto
    return Join-Path $ProjectRoot $Caminho
}

function New-LogCancelamento {
    param(
        [string]$LogFile,
        [string]$DescricaoAtual,
        [string]$DescricaoErro,
        [string]$TipoErro = "desconhecido"
    )

    $mensagem = @"
Comando '$DescricaoAtual' não executado por causa de erros na execução do comando '$DescricaoErro'
Tipo de erro: $TipoErro
Data/Hora: $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")
"@
    Set-Content -Path $LogFile -Value $mensagem -Encoding UTF8
}

# ============================================================================
# PRIMEIRA ETAPA: Limpeza dos arquivos de log
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host "MINI EDITOR - Script de Execução de Comandos Cargo" -ForegroundColor Cyan
Write-Host "Fase: $Phase | Comandos: $($comandos.Count)" -ForegroundColor Cyan
Write-Host "============================================================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "LIMPEZA DE LOGS..." -ForegroundColor Cyan

foreach ($cmd in $comandos) {
    # Normaliza o caminho do log
    $logCompleto = Get-CaminhoCompleto $cmd.LogFile
    $cmd.LogFile = $logCompleto

    if (Test-Path $logCompleto) {
        Remove-Item $logCompleto -Force
        # Write-Host "✓ Log removido: $logCompleto" -ForegroundColor Gray
    }
}

# ============================================================================
# SEGUNDA ETAPA: Execução dos comandos
# ============================================================================

Write-Host ""
Write-Host "EXECUÇÃO DE COMANDOS..." -ForegroundColor Cyan
Write-Host ""

# Muda para o diretório do projeto antes de executar
Push-Location $ProjectRoot

$erroAnterior = $false
$descricaoErro = ""
$tipoErroAnterior = ""
$codigoSaida = 0

for ($i = 0; $i -lt $comandos.Count; $i++) {
    $cmd = $comandos[$i]
    $descricao = $cmd.Descricao
    $comando = $cmd.Comando
    $logFile = $cmd.LogFile

    Write-Host "[$($i+1)/$($comandos.Count)] " -NoNewline -ForegroundColor Yellow

    # ========================================================================
    # Verifica se deve cancelar por erro anterior
    # ========================================================================
    if ($erroAnterior) {
        Write-Host "Execução do comando '$descricao' cancelada." -ForegroundColor Red
        New-LogCancelamento -LogFile $logFile -DescricaoAtual $descricao -DescricaoErro $descricaoErro -TipoErro $tipoErroAnterior
        continue
    }

    # ========================================================================
    # Executa o comando
    # ========================================================================
    Write-Host "Executando '$descricao'..." -ForegroundColor White
    Write-Host "  Comando: $comando" -ForegroundColor DarkGray
    Write-Host "  Log: $logFile" -ForegroundColor DarkGray

    $erroEncontrado = $false
    $tipoErro = ""
    $startTime = Get-Date

    try {
        # Define caminhos absolutos do Rust (prioridade: variáveis de ambiente > padrão)
        $cargoHome = if ($env:CARGO_HOME) { $env:CARGO_HOME } else { "D:\app\dev\rust\cargo" }
        $rustupHome = if ($env:RUSTUP_HOME) { $env:RUSTUP_HOME } else { "D:\app\dev\rust\rustup" }

        # Caminho absoluto do cargo.exe
        $cargoPath = Join-Path $cargoHome "bin"
        $cargoExe = Join-Path $cargoPath "cargo.exe"

        # Verifica se cargo existe no caminho absoluto
        if (-not (Test-Path $cargoExe)) {
            # Fallback para local padrão se não encontrar
            $fallbackCargoPath = Join-Path $env:USERPROFILE ".cargo\bin"
            $fallbackCargoExe = Join-Path $fallbackCargoPath "cargo.exe"
            if (Test-Path $fallbackCargoExe) {
                $cargoPath = $fallbackCargoPath
                $cargoExe = $fallbackCargoExe
                $cargoHome = Join-Path $env:USERPROFILE ".cargo"
            } else {
                throw "Cargo não encontrado em $cargoExe nem em $fallbackCargoExe. Verifique se Rust está instalado."
            }
        }

        # Executa o comando usando PowerShell Core 7
        # Carrega o PATH do Rust antes de executar o comando
        $pwshPath = "C:\Program Files\PowerShell\7\pwsh.exe"
        if (-not (Test-Path $pwshPath)) {
            throw "PowerShell Core 7 não encontrado em $pwshPath"
        }

        # Cria script temporário para executar o comando com caminhos absolutos
        $tempScript = Join-Path $env:TEMP "mini-build-$(Get-Random).ps1"

        # Usa caminhos absolutos diretamente no script
        $scriptContent = @"
# Configura variáveis de ambiente do Rust com caminhos absolutos
`$env:CARGO_HOME = "$cargoHome"
`$env:RUSTUP_HOME = "$rustupHome"

# Adiciona cargo ao PATH usando caminho absoluto
`$env:Path = "$cargoPath;$env:Path"

# Muda para o diretório do projeto
Set-Location "$ProjectRoot"

# Executa o comando usando caminho absoluto do cargo se necessário
$comando
"@
        Set-Content -Path $tempScript -Value $scriptContent -Encoding UTF8

        try {
            $processInfo = New-Object System.Diagnostics.ProcessStartInfo
            $processInfo.FileName = $pwshPath
            $processInfo.Arguments = "-NoProfile -File `"$tempScript`""
            $processInfo.WorkingDirectory = $ProjectRoot
            $processInfo.UseShellExecute = $false
            $processInfo.RedirectStandardOutput = $true
            $processInfo.RedirectStandardError = $true
            $processInfo.CreateNoWindow = $true

            # Passa variáveis de ambiente com caminhos absolutos para o processo filho
            $processInfo.EnvironmentVariables["CARGO_HOME"] = $cargoHome
            $processInfo.EnvironmentVariables["RUSTUP_HOME"] = $rustupHome
            $processInfo.EnvironmentVariables["Path"] = "$cargoPath;$env:Path"

            $process = New-Object System.Diagnostics.Process
            $process.StartInfo = $processInfo

            $process.Start() | Out-Null
            $stdout = $process.StandardOutput.ReadToEnd()
            $stderr = $process.StandardError.ReadToEnd()
            $process.WaitForExit()

            $exitCode = $process.ExitCode

            # Combina stdout e stderr e escreve no log
            $output = $stdout + $stderr
            Set-Content -Path $logFile -Value $output -Encoding UTF8
        } finally {
            # Remove script temporário
            if (Test-Path $tempScript) {
                Remove-Item $tempScript -Force -ErrorAction SilentlyContinue
            }
        }

        # ====================================================================
        # VERIFICAÇÃO TIPO 2: Código de saída
        # ====================================================================
        if ($exitCode -ne 0) {
            $erroEncontrado = $true
            $tipoErro = "exit-code"
            Write-Host "✗ O comando retornou código de saída $exitCode" -ForegroundColor Red
            Write-Host "  Verifique o log em: $logFile" -ForegroundColor Red
        }

    } catch [System.Management.Automation.CommandNotFoundException] {
        # ====================================================================
        # VERIFICAÇÃO TIPO 1: Comando não encontrado
        # ====================================================================
        $erroEncontrado = $true
        $tipoErro = "comando-nao-encontrado"
        Write-Host "✗ Não foi possível executar o comando porque ele não foi encontrado." -ForegroundColor Red

        # Cria log com a mensagem de erro
        $mensagemErro = "ERRO: Comando não encontrado`n`n$($_.Exception.Message)"
        Set-Content -Path $logFile -Value $mensagemErro -Encoding UTF8

    } catch {
        # Outros erros de execução
        $erroEncontrado = $true
        $tipoErro = "erro-execucao"
        Write-Host "✗ Erro ao executar o comando: $($_.Exception.Message)" -ForegroundColor Red

        # Cria log com a mensagem de erro
        $mensagemErro = "ERRO: $($_.Exception.Message)"
        Set-Content -Path $logFile -Value $mensagemErro -Encoding UTF8
    }

    $endTime = Get-Date
    $duration = $endTime - $startTime

    # ========================================================================
    # VERIFICAÇÃO TIPO 3: Palavras-chave no log
    # ========================================================================
    if (-not $erroEncontrado -and (Test-Path $logFile) -and $palavrasErro.Count -gt 0) {
        # Aguarda um pouco para garantir que o arquivo foi escrito completamente
        Start-Sleep -Milliseconds 500

        # Constrói regex dinamicamente a partir do array de palavras
        $regexPalavras = ($palavrasErro | ForEach-Object { [regex]::Escape($_) }) -join '|'

        try {
            $conteudoLog = Get-Content $logFile -Encoding UTF8 -ErrorAction SilentlyContinue
            if ($null -ne $conteudoLog) {
                $linhasComErro = $conteudoLog | Select-String -Pattern $regexPalavras -AllMatches -CaseSensitive:$false

                if ($linhasComErro) {
                    $erroEncontrado = $true
                    $tipoErro = "palavra-chave-log"
                    Write-Host "✗ O comando retornou um erro detectado no log" -ForegroundColor Red
                    Write-Host "  Verifique o log em: $logFile" -ForegroundColor Red
                    Write-Host ""
                    Write-Host "  Linhas com erro encontradas:" -ForegroundColor Yellow
                    foreach ($linha in $linhasComErro | Select-Object -First 5) {
                        Write-Host "    → $($linha.Line.Trim())" -ForegroundColor DarkYellow
                    }
                    if ($linhasComErro.Count -gt 5) {
                        Write-Host "    ... e mais $($linhasComErro.Count - 5) linha(s)" -ForegroundColor DarkGray
                    }
                }
            }
        } catch {
            # Ignora erros de leitura do log (arquivo pode estar sendo escrito)
        }
    }

    # ========================================================================
    # Atualiza estado para próxima iteração
    # ========================================================================
    if ($erroEncontrado) {
        $erroAnterior = $true
        $descricaoErro = $descricao
        $tipoErroAnterior = $tipoErro
        $codigoSaida = 1
        Write-Host ""
        Write-Host "  [Tipo de erro: $tipoErro] [Duração: $($duration.ToString('mm\:ss'))]" -ForegroundColor DarkGray
    } else {
        Write-Host "✓ Comando executado com sucesso! [Duração: $($duration.ToString('mm\:ss'))]" -ForegroundColor Green
    }
    Write-Host ""

}

# Restaura o diretório original
Pop-Location

# ============================================================================
# FINALIZAÇÃO
# ============================================================================

Write-Host "============================================================================" -ForegroundColor Cyan
if ($codigoSaida -eq 0) {
    Write-Host "TODOS OS COMANDOS FORAM EXECUTADOS COM SUCESSO!" -ForegroundColor Green
} else {
    Write-Host "EXECUÇÃO FINALIZADA COM ERROS!" -ForegroundColor Red
    Write-Host ""
    Write-Host "Verifique os logs em: $LogsDir" -ForegroundColor Yellow
}
Write-Host "============================================================================" -ForegroundColor Cyan

# Remove lock antes de sair
if (Test-Path $LockFile) {
    Remove-Item $LockFile -Force -ErrorAction SilentlyContinue
}

exit $codigoSaida
