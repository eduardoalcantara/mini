# SPEC: Reestruturação do Repositório mini

**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.1
**Projeto:** Ted — Editor Minimalista

---

## Objetivo

Reorganizar a estrutura de diretórios do repositório `eduardoalcantara/mini` para separar claramente:

- Arquivos de leitura imediata pela IA (raiz)
- Documentação humana (`docs/`)
- Especificações de arquitetura e implementação para IA (`project/specs/`)
- Decisões arquiteturais registradas (`project/decisions/`)
- Regras e contexto do Cursor IDE (`project/.cursor/rules/`)

---

## Estrutura Final Esperada

```
mini/
│
├── README.md                          ← Visível imediatamente pela IA e humanos
├── STATUS.md                          ← Estado atual do projeto (sprint, bloqueadores)
├── CHANGELOG.md                       ← Histórico de versões e mudanças relevantes
│
├── docs/                              ← Documentação para humanos
│   └── onboarding.md                  ← Guia de entrada para novos colaboradores
│
├── project/                           ← Contexto estruturado para IA e arquitetura
│   ├── specs/                         ← Especificações técnicas para o Cursor
│   │   ├── to-do/                     ← Specs aguardando implementação
│   │   ├── doing/                     ← Specs em implementação ativa
│   │   └── done/                      ← Specs já implementadas
│   │
│   └── decisions/                     ← ADRs (Architecture Decision Records)
│       └── ADR-001-wails-go-webview.md
│
├── .cursor/                           ← Regras de comportamento do Cursor IDE AI
│   └── rules/
│       ├── 00-project-overview.md
│       ├── 01-architecture.md
│       ├── 02-coding-standards.md
│       └── 03-pipeline-compliance.md
│
├── scripts/                           ← Scripts de build, lint e compliance
│   ├── build.sh
│   └── compliance-check.sh
│
├── logs/                              ← Logs de sessões de desenvolvimento
│   └── 2026-04-10-sessao.md
│
├── src/                               ← Código-fonte Go (backend)
└── frontend/                          ← UI web (HTML/CSS/JS ou Svelte)
```

---

## Regras de Uso por Tipo de Arquivo

### Raiz (`/`)

Apenas três arquivos fixos. Nenhum outro arquivo deve ser criado na raiz além destes:

| Arquivo | Propósito | Atualizado por |
|---|---|---|
| `README.md` | Apresentação do projeto, stack, como rodar localmente | Dev Sênior / PO |
| `STATUS.md` | Sprint atual, próximas tarefas, bloqueadores, última decisão | Arquiteto / PO |
| `CHANGELOG.md` | Histórico versionado de mudanças (semver) | Dev Sênior |

### `docs/`

Documentação narrativa para leitura humana. Não é consumida diretamente como contexto de implementação pelo Cursor. Conteúdo em prosa, focado em orientação e integração de pessoas.

- `onboarding.md` — guia para novos colaboradores, como configurar o ambiente, fluxo de trabalho da equipe

### `project/specs/`

Especificações técnicas e funcionais para consumo pelo Cursor IDE AI. Organizadas em três subpastas que refletem o estado de implementação de cada spec:

| Subpasta | Significado | Quando mover para cá |
|---|---|---|
| `to-do/` | Spec definida, aguardando implementação | Ao criar ou migrar uma spec ainda não iniciada |
| `doing/` | Spec em implementação ativa na sprint atual | Ao iniciar o desenvolvimento da feature |
| `done/` | Spec implementada e validada | Após aprovação do PO na entrega |

**Regras:**
- Cada spec vive em apenas uma subpasta por vez
- Mover o arquivo de pasta é o sinal oficial de mudança de estado — não usar campos de status dentro do arquivo
- O Cursor deve consultar `doing/` prioritariamente, depois `to-do/`; `done/` serve como referência histórica
- Todo arquivo deve ser objetivo, direto e sem narrativa excessiva, estruturado em seções com headers claros
- Atualizar o conteúdo da spec sempre que a implementação divergir do planejado

Migração dos arquivos existentes do Space do Perplexity (estado inicial: `to-do/`):

| Arquivo original (Space) | Destino em `project/specs/to-do/` |
|---|---|
| `Especificação-Visual-e-Diretrizes-de-UX-UI.md` | `visual-ux.md` |
| `Especificação-Técnica-e-Arquitetural.md` | `technical-architecture.md` |
| `Especificação-de-Fluxos-de-Usuário-e-Funcionalidades-Chave.md` | `user-flows.md` |
| `Especificação-de-Sincronização-de-Dados-e-Backup-via-GDrive.md` | `sync-gdrive.md` |
| `Especificação-de-Sincronização-de-Dados-e-Backup-via-GitHub.md` | `sync-github.md` |
| `Especificação-de-Configuração-Local-e-Persistência.md` | `local-config.md` |
| `Especificação-de-Testes-e-Garantia-de-Qualidade.md` | `testing-qa.md` |

> ⚠️ Atenção: os arquivos de specs devem ser revisados antes da migração — alguns ainda referenciam a stack antiga (Electron + React + TypeScript). Atualizar para a stack atual (Go + Wails + frontend web) antes de commitar.

### `project/decisions/`

Architecture Decision Records (ADRs). Cada decisão arquitetural relevante ganha um arquivo próprio com o template abaixo.

**Template ADR:**

```markdown
# ADR-NNN: [Título da Decisão]

**Data:** AAAA-MM-DD
**Status:** Proposta | Aceita | Substituída por ADR-NNN
**Autor:** [membro da equipe]

## Contexto
[O que levou a essa decisão? Qual problema estava sendo resolvido?]

## Decisão
[O que foi decidido?]

## Alternativas consideradas
[Quais outras opções foram avaliadas e por quê foram descartadas?]

## Consequências
[O que muda com essa decisão? Quais trade-offs foram aceitos?]
```

ADR pendente de criação:
- `ADR-001-wails-go-webview.md` — decisão de usar Go + Wails v2 + frontend web em vez de Electron ou Tauri

### `.cursor/rules/`

Arquivos de instrução para o Cursor IDE AI. São lidos automaticamente pelo Cursor antes de qualquer sessão de codificação. Devem ser mantidos curtos, diretos e sempre sincronizados com as specs em `project/specs/`.

| Arquivo | Conteúdo |
|---|---|
| `00-project-overview.md` | Nome do projeto, objetivo, stack atual, links para specs principais |
| `01-architecture.md` | Estrutura de pastas do código (`src/`, `frontend/`), separação de responsabilidades, padrões de módulos Go |
| `02-coding-standards.md` | Convenções de nomenclatura, formatação, comentários, proibições explícitas |
| `03-pipeline-compliance.md` | Checklist pré-commit: documentação atualizada? spec referenciada? ADR necessário? |

---

## Passos de Execução para o Cursor

Execute as seguintes ações no repositório, nesta ordem:

1. **Criar diretórios** que ainda não existem:
   ```
   mkdir -p docs
   mkdir -p project/specs/to-do
   mkdir -p project/specs/doing
   mkdir -p project/specs/done
   mkdir -p project/decisions
   mkdir -p .cursor/rules
   mkdir -p scripts
   mkdir -p logs
   ```

2. **Mover ou criar** `STATUS.md` e `CHANGELOG.md` na raiz (se já existirem em subpastas, mover para `/`)

3. **Migrar arquivos de specs** conforme a tabela de mapeamento acima — renomear para kebab-case sem acentos, depositar em `project/specs/to-do/`

4. **Criar o ADR-001** usando o template fornecido, documentando a decisão Go + Wails

5. **Criar os 4 arquivos** em `.cursor/rules/` com conteúdo inicial baseado nas specs migradas

6. **Atualizar o `README.md`** para refletir a nova estrutura e a stack atual

7. **Não remover** nenhum arquivo de código-fonte (`src/`, `frontend/`) durante a reorganização

---

## Critérios de Aceitação

- [ ] `README.md`, `STATUS.md` e `CHANGELOG.md` estão na raiz
- [ ] Nenhum outro arquivo `.md` solto na raiz além desses três
- [ ] `project/specs/to-do/` contém todos os 7 arquivos de especificação migrados e renomeados
- [ ] `project/specs/doing/` e `project/specs/done/` existem (podem estar vazias inicialmente)
- [ ] `project/decisions/ADR-001-wails-go-webview.md` existe e está preenchido
- [ ] `.cursor/rules/` contém os 4 arquivos de regras
- [ ] `docs/onboarding.md` existe com conteúdo mínimo
- [ ] Nenhum arquivo de specs ainda referencia Electron, React ou TypeScript como stack ativa

---

*Documento gerado pelo Arquiteto/Supervisor IA. Requer aprovação do PO antes da execução pelo Dev Sênior (Cursor IDE AI).*
