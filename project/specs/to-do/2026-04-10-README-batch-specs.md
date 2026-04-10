# Lote de specs — 2026-04-10

Resumo executivo e ordem de trabalho para as três specs abaixo (ficheiros irmãos nesta pasta).

---

## Ordem de execução recomendada

```
SPEC-config-service  ←── primeiro (backend + bindings)
SPEC-fontes-embed    ←── pode rodar em paralelo com config-service
SPEC-context-menu    ←── só após as duas anteriores concluídas
```

| # | Ficheiro | Foco |
|---|----------|------|
| 1 | [`2026-04-10-SPEC-config-service.md`](./2026-04-10-SPEC-config-service.md) | Go: `config.json` ao lado do exe, `GetConfig` / `SetConfig` / `ResolveFont`, `font: "auto"` por extensão |
| 2 | [`2026-04-10-SPEC-fontes-embed.md`](./2026-04-10-SPEC-fontes-embed.md) | 7× `.woff2`, `fonts.css`, tokens; Material Symbols ~3MB — documentar no relatório |
| 3 | [`2026-04-10-SPEC-context-menu.md`](./2026-04-10-SPEC-context-menu.md) | Menu contextual vanilla, submenus 150ms, `config-changed`, `execCommand` (parar se falhar no WebView2) |

---

## Destaques por spec

### Config Service
- `src/models/config.go` + `src/services/config_service.go` + bindings `GetConfig`, `SetConfig`, `ResolveFont`
- `font: "auto"` resolvido no backend pela extensão do ficheiro
- `config.json` criado na primeira execução junto ao `mini.exe`

### Fontes embed
- EB Garamond (3) + JetBrains Mono (3) + Material Symbols Rounded (variable)
- `fonts.css` com `@font-face` + classe `.icon`
- Aviso: Material Symbols ~3MB — registar tamanho no relatório de conclusão

### Context menu
- Deteção automática zona editor vs. resto da janela
- Submenus com atraso 150ms no hover
- Integração via evento `config-changed` (desacoplado do editor)
- `document.execCommand` para cut/copy/paste — se não funcionar no WebView2, parar e consultar o Supervisor

---

## Estado

As três specs estão em **`project/specs/to-do/`** com status **TO-DO** até o PO mover a ativa para `doing/` e o dev fechar com relatório em `done/`.
