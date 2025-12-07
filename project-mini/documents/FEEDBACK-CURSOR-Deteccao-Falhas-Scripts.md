# Feedback para Equipe de Desenvolvimento do Cursor

## Título do Problema
**Falha na Detecção de Erros e Interrupções em Scripts PowerShell e Processos de Build**

## Data
2025-01-XX

## Contexto
Durante o desenvolvimento de um projeto Rust (fork do Zed Editor), estamos usando scripts PowerShell para executar comandos `cargo build` e `cargo check` de forma automatizada. O agente de IA (Claude Sonnet) está tendo dificuldades em detectar quando:

1. Scripts PowerShell falham silenciosamente
2. Processos de build são interrompidos pelo usuário
3. Comandos retornam códigos de saída de erro
4. Scripts executam mas não produzem saída visível no terminal

## Problemas Específicos Encontrados

### 1. Scripts PowerShell Executam Mas Não Mostram Saída
**Cenário:**
- Script PowerShell (`run.ps1`) é executado via `run_terminal_cmd`
- O script executa comandos `cargo build` que podem levar 10-20 minutos
- O agente não recebe feedback visual do progresso
- Se o script falhar, o agente não detecta imediatamente

**Exemplo:**
```powershell
# Comando executado
"C:\Program Files\PowerShell\7\pwsh.exe" -File "project-mini\scripts\run.ps1" -Phase 0

# Resultado: Exit code 0, mas sem saída visível
# O agente assume sucesso, mas na verdade o script pode ter falhado
```

### 2. Processos de Build Interrompidos Não São Detectados
**Cenário:**
- `cargo build --release` é iniciado (pode levar 20+ minutos)
- Usuário interrompe o processo (Ctrl+C)
- O agente continua esperando indefinidamente
- Não há mecanismo de timeout ou detecção de interrupção

**Impacto:**
- Perda de tempo significativa
- Agente fica "preso" aguardando um processo que já terminou
- Usuário precisa cancelar manualmente a operação do agente

### 3. Códigos de Saída Não São Verificados Adequadamente
**Cenário:**
- Script PowerShell executa comando que falha
- Script retorna exit code 1
- `run_terminal_cmd` retorna exit code, mas o agente não verifica consistentemente
- Agente assume sucesso baseado em ausência de exceção

### 4. Saída de Scripts com `Clear-Host` Não É Capturada
**Cenário:**
- Scripts PowerShell usam `Clear-Host` no início
- Saída subsequente não é capturada pelo `run_terminal_cmd`
- Agente não vê mensagens de progresso ou erro

## Soluções Propostas

### 1. Streaming de Saída em Tempo Real
**Recomendação:**
- Adicionar suporte para streaming de saída de processos longos
- Permitir que o agente veja saída incremental (ex: "Compiling crate X...")
- Implementar callback ou evento para notificar progresso

**Exemplo de API desejada:**
```typescript
run_terminal_cmd({
  command: "cargo build --release",
  streamOutput: true,
  onOutput: (chunk: string) => {
    // Agente recebe chunks de saída em tempo real
  },
  timeout: 3600000 // 1 hora
})
```

### 2. Detecção de Interrupção de Processos
**Recomendação:**
- Verificar periodicamente se o processo ainda está rodando
- Detectar sinais de interrupção (SIGINT, SIGTERM)
- Retornar status específico quando processo é interrompido

**Exemplo:**
```typescript
{
  exitCode: null,
  interrupted: true,
  duration: 120000, // 2 minutos antes de ser interrompido
  output: "Compiling... [interrupted]"
}
```

### 3. Timeout Configurável
**Recomendação:**
- Permitir timeout configurável por comando
- Retornar erro específico quando timeout é atingido
- Permitir que agente cancele operações longas

**Exemplo:**
```typescript
run_terminal_cmd({
  command: "cargo build --release",
  timeout: 1800000, // 30 minutos
  onTimeout: () => {
    // Callback quando timeout é atingido
  }
})
```

### 4. Verificação Obrigatória de Exit Code
**Recomendação:**
- Sempre verificar exit code após execução
- Lançar exceção ou retornar erro quando exit code != 0
- Documentar claramente que exit code 0 não garante sucesso

### 5. Captura de Saída Mesmo com Clear-Host
**Recomendação:**
- Capturar toda saída do processo, incluindo antes de Clear-Host
- Ou desabilitar Clear-Host quando executado via run_terminal_cmd
- Fornecer flag para controlar comportamento de limpeza de tela

## Impacto no Desenvolvimento

### Problemas Atuais
1. **Perda de Produtividade:**
   - Agente fica "preso" aguardando processos que já falharam
   - Usuário precisa intervir manualmente constantemente
   - Retrabalho necessário quando agente não detecta falhas

2. **Falta de Confiança:**
   - Não podemos confiar que o agente detectará erros
   - Precisamos verificar manualmente todos os resultados
   - Scripts de verificação adicionais são necessários

3. **Experiência do Usuário:**
   - Frustração ao ver agente "travado"
   - Necessidade de cancelar e reiniciar operações
   - Perda de contexto quando operações são interrompidas

## Exemplo de Caso Real

**Situação:**
Executando script PowerShell que roda `cargo build --release`:

```powershell
# Script: project-mini/scripts/run.ps1
# Executa: cargo build --release --package mini
# Tempo esperado: 15-20 minutos
```

**O que acontece:**
1. Agente executa script via `run_terminal_cmd`
2. Script inicia `cargo build`
3. Usuário vê que há erro (via monitoramento manual)
4. Usuário interrompe processo (Ctrl+C)
5. Agente continua aguardando resposta do `run_terminal_cmd`
6. Após 8 horas, usuário percebe que agente está "preso"
7. Usuário precisa cancelar operação do agente manualmente

**O que deveria acontecer:**
1. Agente executa script
2. Agente recebe saída em tempo real
3. Agente detecta erro ou interrupção imediatamente
4. Agente reporta problema e para execução
5. Agente sugere próxima ação

## Prioridade
**ALTA** - Este problema impacta significativamente a produtividade e confiabilidade do agente em projetos que envolvem builds longos.

## Informações Técnicas

### Ambiente
- **Sistema Operacional:** Windows 10/11
- **Shell:** PowerShell Core 7 (`C:\Program Files\PowerShell\7\pwsh.exe`)
- **Ferramenta de Build:** Cargo (Rust)
- **Tempo típico de build:** 15-30 minutos para projetos grandes

### Comandos Afetados
- `cargo build --release`
- `cargo check --workspace`
- Scripts PowerShell que executam processos longos
- Qualquer comando que pode levar mais de 5 minutos

## Sugestões de Implementação

### Opção 1: Polling de Status
```typescript
// Verificar status do processo a cada X segundos
setInterval(() => {
  if (processHasTerminated(pid)) {
    handleTermination();
  }
}, 5000);
```

### Opção 2: Eventos de Processo
```typescript
// Usar eventos nativos do sistema operacional
process.on('exit', (code) => {
  handleExit(code);
});

process.on('SIGINT', () => {
  handleInterruption();
});
```

### Opção 3: Wrapper com Timeout
```typescript
// Wrapper que adiciona timeout automático
function runWithTimeout(cmd, timeout) {
  return Promise.race([
    run_terminal_cmd(cmd),
    new Promise((_, reject) =>
      setTimeout(() => reject(new Error('Timeout')), timeout)
    )
  ]);
}
```

## Conclusão

A capacidade de detectar falhas e interrupções em processos longos é crítica para a eficácia do agente de IA em projetos de desenvolvimento real. A implementação das melhorias sugeridas aumentaria significativamente a confiabilidade e produtividade do agente.

## Contato
Se precisarem de mais informações ou exemplos adicionais, estou disponível para fornecer.

---

**Nota:** Este feedback foi gerado durante o desenvolvimento do projeto "mini editor" (fork do Zed Editor) usando Cursor IDE com agente Claude Sonnet 4.5.
