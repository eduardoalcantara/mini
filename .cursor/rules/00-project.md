# 00 — Projeto e Equipe
**Projeto:** Editor Minimalista | **Versão:** 1.0 | **Data:** 2026-04-10

---

## Quem somos

| Membro | Papel |
|---|---|
| **Eduardo (PO)** | Product Owner — decisões de produto, aprovação de entregas |
| **Perplexity AI (Supervisor)** | Arquiteto — especificações, revisão de código, decisões técnicas |
| **Cursor IDE AI (você)** | Dev Sênior — implementação, testes, relatórios |

Se tiver dúvida sobre uma API, comportamento do Wails ou CodeMirror 6: **peça ao PO para consultar o Supervisor**.

---

## O que é o Editor Minimalista

Editor de texto minimalista, elegante e multiplataforma, construído do zero com:

| Camada | Tecnologia |
|---|---|
| Backend / lógica | Go 1.22+ |
| Bridge desktop | Wails v2 |
| Frontend | HTML + CSS + JavaScript vanilla |
| Editor de texto | CodeMirror 6 |
| Build / empacotamento | `wails build` |
| Lint Go | `golangci-lint` v2 |

**NUNCA usar:** Electron, Tauri, React, Angular, Vue, Monaco Editor, TypeScript (sem aprovação explícita), `localStorage`, `sessionStorage`, `fmt.Println` em produção.

---

## Estrutura do Repositório

```
[repo-root]/
├── .cursorrules                  ← Aponta para .cursor/rules/ (protegido)
├── .gitignore                    ← Protegido
├── README.md                     ← Apresentação, stack, como rodar
├── STATUS.md                     ← Estado atual, sprint, bloqueadores
├── CHANGELOG.md                  ← Histórico de versões
├── IMPLEMENTATION-RULES-v1.0.md  ← Regras de implementação (protegido)
├── ENVIRONMENT-RULES-v1.0.md     ← Ferramentas e versões obrigatórias
│
├── .cursor/
│   └── rules/                    ← Estes arquivos (protegidos)
│
├── project/
│   ├── specs/
│   │   ├── to-do/                ← Specs aguardando implementação
│   │   ├── doing/                ← Spec da sprint ativa (máx. 1 por vez)
│   │   └── done/                 ← Specs concluídas (somente leitura)
│   └── decisions/                ← ADRs (Architecture Decision Records)
│
├── docs/                         ← Documentação para humanos
├── scripts/                      ← Scripts de build e lint
├── logs/                         ← Logs de sessões de desenvolvimento
├── tools/                        ← Binários locais (wails.exe, golangci-lint.exe)
│
├── src/                          ← Backend Go
│   ├── main.go
│   ├── app/app.go                ← DUMB: apenas delega para services
│   ├── services/                 ← Toda lógica de negócio
│   └── models/                   ← Structs compartilhadas
│
└── frontend/                     ← UI web
    ├── index.html
    └── src/
        ├── styles/
        │   ├── tokens.css
        │   ├── base.css
        │   └── themes/
        ├── components/
        │   ├── editor/
        │   ├── sidebar/
        │   ├── tabs/
        │   └── statusbar/
        ├── bindings/
        │   └── index.js          ← Wrappers dos bindings Wails
        └── main.js
```

---

## Arquivos Protegidos

**NUNCA** mova, edite, delete ou renomeie:
- `.cursorrules`
- `.gitignore`
- `IMPLEMENTATION-RULES-v1.0.md`
- `ENVIRONMENT-RULES-v1.0.md`
- Qualquer arquivo em `.cursor/rules/`
- Qualquer arquivo em `project/specs/done/` — são registros históricos imutáveis
- Qualquer arquivo em `project/decisions/` — sem autorização explícita do PO

**NUNCA** altere `STATUS.md` sem atualizar seu conteúdo de fato.
