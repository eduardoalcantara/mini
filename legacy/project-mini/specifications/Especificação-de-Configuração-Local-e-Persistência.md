# Especificação-de-Configuração-Local-e-Persistência.md
## Projeto: mini (Minimalist, Intelligent, Nice Interface)
## Versão: 1.0 - 2025-11-13
## Autor: Equipe de IA (PO, Arquiteto/Supervisor, Dev Sênior)

---

## Objetivo

Garantir que todas as configurações do usuário, sessões abertas e preferências do editor **mini** sejam salvas e recuperáveis automaticamente no ambiente local, proporcionando continuidade e segurança no uso mesmo sem sincronização cloud.

---

## Local de Armazenamento

- **Windows:** Utilizar pasta padrão do usuário via Electron (`app.getPath('userData')`), ex:  
  `C:\Users\<user>\AppData\Roaming\mini`
- Arquivos de configuração separados por contexto:
  - `config.json` – preferências gerais, temas, fontes, UI, comportamento do painel lateral
  - `session.json` – arquivos abertos, abas, posição/tamanho da janela, estado dos painéis
  - `backup-yyyy-mm-dd-hh-mm.json` – histórico automático/salvo manualmente

---

## Estrutura e Formato dos Dados

- JSON para fácil leitura, validação e migração.
- Exemplo de `config.json`:
```
{
  "theme": "github-light",
  "fontTxt": "Bookman Old Style",
  "fontCode": "JetBrains Mono",
  "sidebarMode": "hover",
  "trayBehavior": true,
  "windowPosition": { "x": 1200, "y": 900 },
  "windowSize": { "width": 900, "height": 420 }
}
```
- Exemplo de `session.json`:
```
{
  "openFiles": [
    { "path": "D:/Projetos/file1.txt", "fixed": true },
    { "path": "D:/Projetos/file2.md", "fixed": false }
  ],
  "lastActiveFile": "D:/Projetos/file2.md"
}
```

---

## Persistência e Atualização

- Salvamento automático a cada modificação relevante (config, abas, arquivos).
- Backup manual disponível pelo usuário.
- Recuperação automática na inicialização do app.
- Esquema incremental por históricos (opcional): múltiplos backups antigos para revert/cancel.

---

## Versionamento e Migração

- Toda alteração de estrutura em arquivos de configuração será acompanhada de controle de versão (chave `configVersion` nos JSON).
- Caso a versão detectada seja antiga, app solicita migração automática.
- Ferramentas/utilitários para exportar/importar configurações e sessões.

---

## Segurança e Limitações

- Dados sensíveis (tokens, senhas) nunca salvos em texto plano.
- Permissão para reset total das configurações pela interface do mini.
- Limite de arquivos abertos/salvos configurável (evitar overload no recovery).
- Remoção segura dos backups antigos pelo usuário.

---

## Observações

- Configuração local é prioritária: todas funções do editor funcionam sem internet ou sincronização cloud.
- Documentação das opções de configuração será mantida nos arquivos README e help do app.

---

*Documento sujeito a revisões e incrementos conforme evolução do projeto.*
