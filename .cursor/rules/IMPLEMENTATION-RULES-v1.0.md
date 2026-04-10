# Regras de Implementação — Editor Minimalista

### Documento de uso obrigatório em TODA implementação
**Documento:** IMPLEMENTATION-RULES-v1.0
**Data:** 2026-04-10
**Status:** VIGENTE — entregar ao Cursor junto com cada spec de implementação
**Atualização:** obrigatória após cada mudança estrutural no projeto

> **Histórico de versões:**
> - `v1.0` — 2026-04-10 — versão inicial (stack Go + Wails v2 + frontend web)

---

## Como usar este documento

Este documento deve ser entregue ao Cursor **sempre**, junto com qualquer spec de implementação.
Ele não substitui a spec — ele define as regras que a spec assume cumpridas.

> **Ordem de leitura obrigatória antes de implementar qualquer tarefa:**
> 1. Este documento (regras)
> 2. `STATUS.md` na raiz (o que já foi feito e o que está pendente)
> 3. A spec da tarefa em `project/specs/doing/`
> 4. Specs relacionadas em `project/specs/done/` se a tarefa tocar em área já implementada

---

## PRÉ-ANÁLISE OBRIGATÓRIA (antes de qualquer implementação)

### Passo 1 — Ler `STATUS.md`

Antes de qualquer implementação, o Cursor **deve**:
- Verificar o que já foi implementado para não duplicar
- Verificar o que está pendente para entender o contexto
- Verificar se a tarefa atual já tem parte implementada
- Se encontrar conflito entre a spec e o status atual: **PARAR e reportar ao supervisor**

### Passo 2 — Identificar áreas impactadas

Se a implementação **criar ou modificar** qualquer parte que faça parte de um fluxo documentado,
ler a spec correspondente em `project/specs/done/` antes de implementar:

| Área impactada | Spec de referência |
|---|---|
| Janela e posicionamento | `window-management.md` |
| Painel lateral (sidebar) | `sidebar.md` |
| Abas de arquivos | `tabs.md` |
| Editor de texto (CodeMirror) | `editor.md` |
| Temas e tipografia | `visual-ux.md` |
| Configurações e persistência local | `local-config.md` |
| Sincronização GitHub/GitLab | `sync-github.md` |
| Sincronização Google Drive | `sync-gdrive.md` |
| Agente de IA | `ai-agent.md` |
| Gerenciador de tarefas | `task-manager.md` |
| Tray icon e menu de contexto | `tray.md` |
| Comunicação Go ↔ Frontend (Wails bindings) | `wails-bindings.md` |

Se não houver spec para a área: implementar e criar a spec em `project/specs/done/` após a conclusão.

---

## STACK OBRIGATÓRIA

| Camada | Tecnologia | Versão mínima |
|---|---|---|
| Backend / lógica | Go | 1.22+ |
| Bridge desktop | Wails v2 | v2.9+ |
| Frontend | HTML + CSS + JavaScript (vanilla) ou Svelte | — |
| Editor de texto | CodeMirror 6 | 6.x |
| Empacotamento | Wails CLI (`wails build`) | — |

**NUNCA usar:**
- Electron, Tauri ou qualquer outra shell de desktop além do Wails
- React, Angular, Vue (overhead desnecessário — vanilla JS ou Svelte)
- Monaco Editor (substituído por CodeMirror 6 nesta stack)
- TypeScript no frontend sem aprovação explícita do PO
- Qualquer ORM — persistência local via arquivo JSON/TOML gerenciado pelo backend Go

---

## REGRAS DE ARQUITETURA — Backend (Go)

### Separação de responsabilidades obrigatória

```
Frontend (HTML/CSS/JS)
    ↓ Wails bindings (chamadas expostas via @wailsio/runtime)
Backend (Go — pacote app/)
    ↓ chamadas internas
Serviços Go (pacote services/)
    ↓
Sistema de arquivos / APIs externas
```

**NUNCA:**
- Lógica de negócio em handlers Wails diretos — handlers são DUMB, delegam para `services/`
- Acesso direto ao sistema de arquivos fora do pacote `services/`
- Estado global em variáveis de pacote — estado vive na struct `App` em `app/app.go`

### Estrutura obrigatória do pacote `app/`

```go
// app/app.go — único ponto de entrada do Wails
type App struct {
    ctx      context.Context
    config   *services.ConfigService
    editor   *services.EditorService
    sync     *services.SyncService
    // ... outros services
}

// Métodos expostos ao frontend via Wails binding:
// APENAS orquestração — zero lógica de negócio aqui
func (a *App) OpenFile(path string) (FileResult, error) {
    return a.editor.OpenFile(path)
}
```

### Serviços (`services/`)

- Cada domínio tem seu próprio arquivo: `config_service.go`, `editor_service.go`, `sync_service.go`, etc.
- Toda lógica de negócio vive nos services — nunca nos handlers da `App`
- Serviços **não se chamam diretamente** — comunicação via `App` ou interfaces

### Erros

- **Nunca usar `panic()`** exceto em `init()` para falhas de configuração críticas
- Sempre retornar `error` como segundo valor — nunca ignorar erros silenciosamente
- Erros retornados ao frontend devem ser strings legíveis pelo usuário, não stack traces

### Configuração e persistência local

- Arquivo de configuração: `~/.config/[nome-do-app]/config.toml`
- Leitura e escrita exclusivamente via `services/config_service.go`
- **Nunca** escrever diretamente em `os.WriteFile` fora do `ConfigService`

---

## REGRAS DE CÓDIGO — Go

### Proibições absolutas

| Proibido | Motivo | Correto |
|---|---|---|
| `panic()` em serviços | Mata o processo sem recovery | Retornar `error` |
| Variáveis globais de estado | Concorrência insegura | Usar struct `App` |
| Acesso direto a `os.*` fora de `services/` | Viola separação de camadas | Usar service responsável |
| `fmt.Println` em produção | Poluição de log | Usar `log/slog` |
| Ignorar `error` retornado (`_ =`) | Falhas silenciosas | Tratar ou propagar |
| Goroutines sem controle de ciclo de vida | Leaks | Usar `context.Context` |

### Nomenclatura

- Pacotes: `lowercase` sem underscores (`services`, `editor`, `config`)
- Structs exportadas: `PascalCase` (`ConfigService`, `FileResult`)
- Funções e métodos: `PascalCase` se exportados, `camelCase` se internos
- Constantes: `PascalCase` se exportadas (`MaxTabCount`), `camelCase` se internas
- Arquivos: `snake_case.go` (`config_service.go`, `editor_service.go`)

### Wails Bindings — contrato obrigatório

Toda função exposta ao frontend via Wails **deve**:
1. Receber tipos primitivos ou structs serializáveis em JSON
2. Retornar `(TipoResultado, error)` — nunca só `void`
3. Estar declarada em `app/app.go` — nunca em outros pacotes
4. Ter documentação GoDoc mínima descrevendo o que faz e o que retorna

```go
// OpenFile abre um arquivo pelo caminho absoluto e retorna seu conteúdo e metadados.
// Retorna erro se o arquivo não existir ou não tiver permissão de leitura.
func (a *App) OpenFile(path string) (models.FileResult, error) {
    return a.editor.OpenFile(a.ctx, path)
}
```

---

## REGRAS DE FRONTEND

### Princípio geral — UI é DUMB

O frontend **não toma decisões de negócio**. Toda lógica (o que salvar, como sincronizar, qual tema aplicar) vive no backend Go. O frontend apenas:
- Renderiza o estado recebido do backend
- Captura eventos do usuário e chama os bindings Wails correspondentes
- Aplica CSS baseado em tokens de design (nunca hardcodes de cor ou tamanho)

### Design Tokens obrigatórios

Todo valor visual deve ser uma variável CSS. **Nunca hardcodar** cores, tamanhos ou espaçamentos:

```css
/* CORRETO */
.editor { background: var(--color-bg); font-size: var(--text-editor); }

/* ERRADO */
.editor { background: #1c1b19; font-size: 15px; }
```

Tokens mínimos obrigatórios que devem existir em `frontend/src/styles/tokens.css`:

```css
:root {
  /* Superfícies */
  --color-bg: ...;
  --color-surface: ...;
  --color-surface-2: ...;
  --color-border: ...;

  /* Texto */
  --color-text: ...;
  --color-text-muted: ...;
  --color-text-faint: ...;

  /* Acento */
  --color-accent: ...;

  /* Tipografia — editor */
  --font-editor-text: "Bookman Old Style", Literata, "EB Garamond", serif;
  --font-editor-code: "JetBrains Mono", "Fira Code", Consolas, monospace;
  --text-editor: 16px;
  --text-editor-code: 14px;
  --line-height-editor: 1.6;

  /* Tipografia — UI chrome */
  --font-ui: system-ui, sans-serif;
  --text-ui-sm: 13px;
  --text-ui-base: 14px;

  /* Espaçamentos */
  --space-1: 4px;
  --space-2: 8px;
  --space-3: 12px;
  --space-4: 16px;

  /* Animações */
  --transition-ui: 180ms ease;
  --transition-panel: 200ms ease;
}
```

### Temas

- Temas são trocados adicionando `data-theme="[nome]"` no `<html>`
- Cada tema redefine os tokens em `frontend/src/styles/themes/[nome].css`
- **Nunca** aplicar estilos de tema inline ou via JavaScript direto

### Estrutura obrigatória de arquivos frontend

```
frontend/
├── src/
│   ├── styles/
│   │   ├── tokens.css          ← variáveis globais
│   │   ├── base.css            ← reset + base
│   │   └── themes/
│   │       ├── dark.css
│   │       ├── light.css
│   │       └── pastel.css
│   ├── components/
│   │   ├── editor/             ← CodeMirror + wrapper
│   │   ├── sidebar/            ← painel lateral
│   │   ├── tabs/               ← barra de abas
│   │   ├── statusbar/          ← rodapé
│   │   └── ui/                 ← botões, tooltips, menus
│   ├── bindings/               ← wrappers JS dos bindings Wails
│   │   └── index.js            ← re-exporta todos os bindings com tipagem JSDoc
│   └── main.js                 ← entrypoint
└── index.html
```

### Bindings Wails — uso obrigatório via wrapper

**Nunca** chamar `window.go.[...]` diretamente nos componentes. Usar sempre o wrapper:

```javascript
// frontend/src/bindings/index.js
import { OpenFile, SaveFile, GetConfig } from '../../wailsjs/go/app/App';

export const openFile = (path) => OpenFile(path);
export const saveFile = (path, content) => SaveFile(path, content);
export const getConfig = () => GetConfig();
```

### CodeMirror 6 — configuração mínima obrigatória

```javascript
import { EditorView, basicSetup } from 'codemirror';
import { EditorState } from '@codemirror/state';

// OBRIGATÓRIO: extensões mínimas em todo editor instanciado
const minimalExtensions = [
  basicSetup,
  EditorView.theme({ /* tokens CSS mapeados */ }),
  EditorView.lineWrapping,        // wrap configurável pelo usuário
];
```

- **Nunca** instanciar `EditorView` fora do componente `editor/`
- Configurações do editor (fonte, tamanho, wrap, números de linha) vêm sempre do `ConfigService` via binding, nunca hardcodadas

### Proibições absolutas no frontend

| Proibido | Motivo | Correto |
|---|---|---|
| `window.go.[...]` diretamente | Acoplamento direto ao Wails | Usar `bindings/index.js` |
| Hardcode de cor/tamanho | Impede theming | Usar tokens CSS |
| `localStorage` / `sessionStorage` | Não disponível no Wails WebView | Estado via backend Go |
| `alert()` / `confirm()` nativos | Fora do design system | Componente `ui/dialog` |
| Lógica de negócio em componente | Frontend é DUMB | Delegar ao backend via binding |
| Monaco Editor | Substituído por CodeMirror 6 | Usar CodeMirror 6 |

---

## REGRAS DE UI/UX (conformidade com as specs visuais)

Toda implementação de UI deve estar em conformidade com `project/specs/visual-ux.md`. Itens críticos:

- **UI padrão = somente editor**: ao inicializar, nenhum painel, barra de ferramentas ou menu deve estar visível além da área de texto e do botão discreto de expansão
- **Painel lateral**: transição fade-in/out em exatamente `200ms` — **nunca instantânea**
- **Todas as animações**: `< 300ms` e com `prefers-reduced-motion` respeitado
- **Abas**: sem close button visível por padrão — exibir apenas no hover
- **Rodapé**: altura máxima de 24px em repouso
- **Fonte por extensão**: `.txt` usa `--font-editor-text`, arquivos de código usam `--font-editor-code` — lógica de decisão **no backend**, não no frontend

---

## CHECKLIST DE SAÍDA (responder antes de gerar qualquer artefato)

### Para qualquer arquivo Go:
- [ ] Lógica de negócio está em `services/`, não em `app/app.go`?
- [ ] Nenhuma variável global de estado?
- [ ] Todos os erros tratados (nenhum `_ =` em erro relevante)?
- [ ] Nenhum `panic()` fora de `init()`?
- [ ] Logs usando `slog`, não `fmt.Println`?
- [ ] Funções expostas ao Wails declaradas apenas em `app/app.go`?

### Para qualquer arquivo de frontend:
- [ ] Nenhuma cor ou tamanho hardcodado (tudo via tokens CSS)?
- [ ] Bindings Wails chamados apenas via `bindings/index.js`?
- [ ] Nenhum uso de `localStorage` ou `sessionStorage`?
- [ ] Nenhuma lógica de negócio no componente?
- [ ] Animações dentro de 300ms e com `prefers-reduced-motion`?
- [ ] Tema aplicado via `data-theme` no `<html>`, não inline?

### Para qualquer alteração de UI:
- [ ] Conforma com `project/specs/doing/visual-ux.md`?
- [ ] Tokens CSS usados para todos os valores visuais?
- [ ] Estado padrão da UI = somente editor (sem painéis abertos)?

> **Se qualquer resposta for NÃO: NÃO GERAR o artefato. Corrigir o plano e reportar ao supervisor.**

---

## CHECKLIST DE FINALIZAÇÃO (após implementar)

### Validações obrigatórias — Backend Go
```bash
# 1. Build sem erros
cd [raiz-do-projeto] && go build ./...

# 2. Lint
cd [raiz-do-projeto] && golangci-lint run

# 3. Testes (quando existirem)
cd [raiz-do-projeto] && go test ./...

# Todos devem passar antes de considerar a tarefa concluída.
```

### Validações obrigatórias — Frontend
```bash
# Build Wails completo (valida frontend + backend integrados)
wails build

# Deve compilar sem erros.
# Warnings de bibliotecas de terceiros podem ser ignorados.
# Qualquer erro introduzido nesta tarefa deve ser corrigido antes de reportar.
```

---

## RELATÓRIO DE IMPLEMENTAÇÃO PARA O SUPERVISOR

Ao finalizar qualquer tarefa, criar o arquivo:

```
project/specs/done/RELATORIO-[NOME-DA-TAREFA]-[YYYY-MM-DD].md
```

**Template obrigatório:**

```markdown
# Relatório de Implementação — [Nome da Tarefa]
**Data:** [YYYY-MM-DD]
**Spec de origem:** [nome do arquivo de spec]
**Status:** [CONCLUÍDO / CONCLUÍDO COM RESSALVAS / PARCIALMENTE CONCLUÍDO]

## Checklist de implementação
- [x] Item 1 da spec
- [x] Item 2 da spec
- [ ] Item 3 — não implementado, motivo: [descrever]

## Arquivos criados
- `caminho/do/arquivo` — [descrição]

## Arquivos modificados
- `caminho/do/arquivo` — [o que mudou e por quê]

## Validações executadas
- [ ] go build ./... → [PASSOU / FALHOU]
- [ ] golangci-lint run → [PASSOU / FALHOU / N/A]
- [ ] go test ./... → [PASSOU / FALHOU / N/A]
- [ ] wails build → [PASSOU / FALHOU]

## Observações para o supervisor
[Qualquer desvio da spec, decisão técnica tomada, dúvida ou risco identificado]
```

---

## ATUALIZAÇÃO DO `STATUS.md`

Após **cada tarefa concluída**, atualizar o `STATUS.md` na raiz do projeto:

1. Mover o item de `⏳ Pendente` para `✅ Concluído`
2. Adicionar data de conclusão
3. Se a tarefa gerou novas pendências: adicioná-las em `⏳ Pendente`
4. Mover o arquivo de spec de `project/specs/doing/` para `project/specs/done/`
5. Commit junto com os arquivos da tarefa

---

## BLOQUEIOS — quando parar e consultar o supervisor

**PARAR e reportar antes de implementar quando:**

1. A spec conflita com código existente e a resolução não é óbvia
2. A tarefa exige modificar uma spec em `project/specs/done/`
3. A tarefa cria dependência nova entre dois serviços Go que hoje não se comunicam
4. A validação `wails build` falha por motivo desconhecido
5. A correção de um erro de lint pode impactar mais de 3 arquivos
6. Qualquer decisão sobre onde colocar lógica que pode ser backend **ou** frontend
7. O `STATUS.md` indica que a tarefa está "em andamento" por outra sessão

---

## Referências rápidas

| O que preciso | Onde ler |
|---|---|
| Stack e arquitetura geral | `project/specs/doing/technical-architecture.md` |
| Diretrizes visuais e UX | `project/specs/doing/visual-ux.md` ou `done/` |
| Fluxos de usuário | `project/specs/doing/user-flows.md` |
| Sincronização GitHub | `project/specs/doing/sync-github.md` |
| Sincronização Google Drive | `project/specs/doing/sync-gdrive.md` |
| Configuração e persistência | `project/specs/doing/local-config.md` |
| Testes e QA | `project/specs/doing/testing-qa.md` |
| Estado atual do projeto | `STATUS.md` (raiz) |
| Decisões arquiteturais | `project/decisions/` |

---

*Documento gerado pelo Arquiteto/Supervisor IA. Requer aprovação do PO antes de entrar em vigor.*
