# mini

Editor de texto minimalista com stack Go + WebView (Wails v2).

## Estado do projeto

Este repositório foi reiniciado para um novo ciclo de desenvolvimento.
A base anterior (Rust/Zed) foi arquivada em `legacy/` e permanece intacta.

## Stack atual

- Backend: Go
- UI Desktop: WebView via Wails v2
- Frontend: HTML/CSS/JavaScript (framework opcional)

## Estrutura inicial

- `docs/`: documentação para pessoas
- `project/specs/`: especificações técnicas por estado (`to-do`, `doing`, `done`)
- `project/decisions/`: ADRs de arquitetura
- `.cursor/rules/`: regras do Cursor para o projeto
- `scripts/`: automações de build/compliance
- `logs/`: registros de sessão e execução
- `src/`: código Go (backend)
- `frontend/`: código da interface web
- `legacy/`: projeto anterior arquivado (sem alterações nesta fase)

## Próximos passos

1. Definir as novas especificações em `project/specs/to-do/`.
2. Registrar ADR-001 para formalizar Go + WebView.
3. Iniciar o bootstrap do app Wails com editor web minimalista.
