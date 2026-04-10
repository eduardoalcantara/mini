# STATUS

## Situação atual

- Fase: scaffold técnico da stack Go + Wails concluído
- Estado: base executável inicial validada (build, lint e dev)
- Escopo atual: preparar próxima spec funcional (editor e fluxos de UI)

## Decisão vigente

- Stack oficial: Go + WebView (Wails v2)
- Decisão estratégica: descontinuar a base ativa em Rust/Zed para este novo ciclo
- Arquivos legados: preservados em `legacy/` para consulta histórica

## Pendências imediatas

- Criar ADR-001 com a decisão arquitetural formal
- Definir próxima spec em `project/specs/doing/` para iniciar features de produto
- Evoluir frontend de scaffold mínimo para estrutura funcional de editor
