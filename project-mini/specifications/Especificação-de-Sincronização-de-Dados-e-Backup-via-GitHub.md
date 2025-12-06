# Especificação-de-Sincronização-de-Dados-e-Backup-via-GitHub.md
## Projeto: mini (Minimalist, Intelligent, Nice Interface)
## Versão: 1.0 - 2025-11-13
## Autor: Equipe de IA (PO, Arquiteto/Supervisor, Dev Sênior)

---

## Objetivo

Permitir ao usuário do editor **mini** sincronizar, fazer backup e restaurar tanto suas configurações como os arquivos abertos de forma segura e prática utilizando repositório privado no GitHub. Esse recurso garante continuidade no uso em diferentes PCs e mantém segurança e privacidade dos dados.

---

## Fluxo de Sincronização

1. **Autenticação**
   - Usuário informa login/senha (preferencialmente GitHub Token Pessoal).
   - URL do repositório privado onde serão salvos os dados.
   - App mini usa OAuth ou API GitHub.

2. **Sincronização Inicial**
   - Arquivos abertos e configurações são enviados para uma pasta específica no repositório (ex: `/mini-backup`).
   - Cada sessão pode ser versionada por data/hora ou identificador de máquina.

3. **Backup Recorrente**
   - A cada alteração relevante (abrir, salvar, configurar), mini faz push incremental dos dados.
   - Preferências do usuário determinam frequência (manual, automático, ao fechar/minimizar, agendamento configurável).

4. **Restore/Continuidade Multi-PC**
   - Ao abrir o mini em outro ambiente, usuário informa token/repo.
   - O editor baixa as últimas configurações e arquivos abertos, restaurando a sessão.

5. **Gerenciamento**
   - Usuário pode visualizar sessões salvas no repositório, fazer restore, excluir backups antigos.
   - Logs de sincronização acessíveis na interface.

---

## Estrutura de Dados no GitHub

```
/mini-backup
    |--config.json      # Configurações do editor, temas, fontes, UI
    |--session-YYYYMMDD-HHMM.json  # Estado dos arquivos/abas/sessão
    |--open-files/
        |--file1.txt
        |--file2.md
        ...
```

- Todas informações salvas em JSON ou TXT simples (criptografado se desejado).
- Dados sensíveis (tokens) nunca salvos no repositório.

---

## Regras de Segurança e Privacidade

- Apenas repositórios privados permitidos para sincronização.
- Autenticação sempre via token/oauth, nunca senha direta.
- Dados trafegados via HTTPS.
- Usuário pode revogar token ou desabilitar a sincronização a qualquer momento.

---

## Limitações e Considerações

- Limite de tamanho por arquivo e número de arquivos salvos pode ser configurável.
- Sincronização não substitui backup tradicional – é recurso para continuidade, não para auditoria de longo prazo.
- Caso de conflito (mesmo arquivo aberto/modificado em dois PCs): prioridade do último push, com versionamento opcional.
- Mensagens de erro claras caso falhe a autenticação ou sincronização.

---

## Requisitos Técnicos

- Integração com API REST do GitHub.
- Gerenciamento de arquivos locais e remotos.
- Painel na interface mini para configuração e status da sincronização.
- Logs locais para depuração e auditoria de sincronização.

---

## Observações

- Função opcional, ativa/desativa via configurações no mini.
- Roadmap prevê integração com outros serviços cloud (Dropbox, Google Drive) em versões futuras.

---

*Documento sujeito a revisões e incrementos conforme evolução do projeto.*
