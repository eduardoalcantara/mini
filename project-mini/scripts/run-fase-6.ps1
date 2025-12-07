# ============================================================================
# Script de Execução de Comandos com Controle de Erros
# ============================================================================
# Este script executa uma série de comandos sequencialmente com:
# - Controle de erros em cascata (se um falha, os seguintes são cancelados)
# - Logging individual por comando
# - 3 tipos de verificação de erro
# - Normalização automática de caminhos relativos
# ============================================================================

Clear-Host
cd D:\proj\mini\

# ============================================================================
# INICIALIZAÇÃO DE VARIÁVEIS (evita problemas entre execuções)
# ============================================================================
$erroAnterior = $null
$descricaoErro = $null
$codigoSaida = $null
$tipoErroAnterior = $null
$tipoErro = $null

# ============================================================================
# CONFIGURAÇÃO: Preencha o array abaixo com seus comandos
# ============================================================================
$comandos = @(
    @{
        Descricao = "FASE 6: Verificação de Sintaxe (cargo check)"
        Comando = "D:\app\dev\rust\cargo\bin\cargo.exe check --workspace"
        LogFile = "D:\proj\mini\project-mini\logs\fase6-cargo-check.log"
    },
    @{
        Descricao = "FASE 6: Testes Unitários (cargo test)"
        Comando = "D:\app\dev\rust\cargo\bin\cargo.exe test --workspace"
        LogFile = "D:\proj\mini\project-mini\logs\fase6-cargo-test.log"
    }
)

# ============================================================================
# CONFIGURAÇÃO: Palavras-chave que indicam erro nos logs (case-insensitive)
# ============================================================================
$palavrasErro = @(
    "erro",
    "error",
    "exception",
    "fail",
    "fatal"
)

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

    # Se for relativo, concatena com o diretório do script
    return Join-Path $PSScriptRoot $Caminho
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
"@
    Set-Content -Path $LogFile -Value $mensagem -Encoding UTF8
}

# ============================================================================
# PRIMEIRA ETAPA: Limpeza dos arquivos de log
# ============================================================================

Write-Host "LIMPEZA DE LOGS.." -ForegroundColor Cyan

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

Write-Host "EXECUÇÃO DE COMANDOS..." -ForegroundColor Cyan

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

    $erroEncontrado = $false
    $tipoErro = ""

    try {
        # Normaliza o caminho do comando se necessário
        $comandoCompleto = Get-CaminhoCompleto $comando

        # Redireciona saída para o log (stdout + stderr)
        Invoke-Expression "$comandoCompleto > `"$logFile`" 2>&1"

        # ====================================================================
        # VERIFICAÇÃO TIPO 2: Código de saída
        # ====================================================================
        if ($LASTEXITCODE -ne $null -and $LASTEXITCODE -ne 0) {
            $erroEncontrado = $true
            $tipoErro = "exit-code"
            Write-Host "✗ O comando retornou um erro, verifique o log em: $logFile" -ForegroundColor Red
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

    # ========================================================================
    # VERIFICAÇÃO TIPO 3: Palavras-chave no log
    # ========================================================================
    if (-not $erroEncontrado -and (Test-Path $logFile) -and $palavrasErro.Count -gt 0) {
        # Constrói regex dinamicamente a partir do array de palavras
        $regexPalavras = ($palavrasErro | ForEach-Object { [regex]::Escape($_) }) -join '|'

        $conteudoLog = Get-Content $logFile -Encoding UTF8
        $linhasComErro = $conteudoLog | Select-String -Pattern $regexPalavras -AllMatches

        if ($linhasComErro) {
            $erroEncontrado = $true
            $tipoErro = "palavra-chave-log"
            Write-Host "✗ O comando retornou um erro, verifique o log em: $logFile" -ForegroundColor Red
            Write-Host ""
            Write-Host "Linhas com erro encontradas:" -ForegroundColor Yellow
            foreach ($linha in $linhasComErro) {
                Write-Host "  → $($linha.Line)" -ForegroundColor DarkYellow
            }
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
        Write-Host "[Tipo de erro: $tipoErro]" -ForegroundColor DarkGray
    } else {
        Write-Host "✓ Comando executado com sucesso!" -ForegroundColor Green
    }

}

# ============================================================================
# FINALIZAÇÃO
# ============================================================================

if ($codigoSaida -eq 0) {
    Write-Host "TODOS OS COMANDOS FORAM EXECUTADOS COM SUCESSO!" -ForegroundColor Green
} else {
    Write-Host "EXECUÇÃO FINALIZADA COM ERROS!" -ForegroundColor Red
}

exit $codigoSaida
