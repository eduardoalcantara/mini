# 03 — Qualidade, Bloqueios e Honestidade
**Projeto:** Editor Minimalista | **Versão:** 1.0 | **Data:** 2026-04-10

---

## Checklist de Saída — Responder Antes de Gerar Qualquer Artefato

### Backend Go

- [ ] Toda lógica de negócio está em `services/`, não em `app/app.go`?
- [ ] Nenhuma variável global de estado foi criada?
- [ ] Todos os erros são retornados explicitamente — sem `panic`, sem `_ =`?
- [ ] Nenhum `os.*` fora de `services/`?
- [ ] Nenhum `fmt.Println` — usar `log/slog`?
- [ ] Goroutines usam `context.Context` com ciclo de vida controlado?

### Frontend

- [ ] Nenhum acesso direto a `window.go.[...]` — tudo via `bindings/index.js`?
- [ ] Nenhum valor de cor/espaçamento hardcoded — tudo via `var(--token)`?
- [ ] Nenhum uso de `localStorage` ou `sessionStorage`?
- [ ] Nenhuma lógica de negócio no componente JS?

### Geral

- [ ] As mudanças foram listadas e aprovadas antes de implementar?
- [ ] Nenhum arquivo em `project/specs/done/` ou `project/decisions/` foi modificado sem autorização?
- [ ] O `STATUS.md` foi atualizado?

**Se qualquer resposta for NÃO: não gerar o artefato. Corrigir o plano e reportar.**

---

## Bloqueios — Quando Parar e Consultar o Supervisor

**PARAR imediatamente e reportar antes de prosseguir quando:**

1. A spec conflita com código existente e a resolução não é óbvia
2. O `wails build` falha por motivo desconhecido
3. O `golangci-lint` falha por motivo desconhecido — **não modificar regras de lint, corrigir o código**
4. A correção de um erro de lint impacta mais de 3 arquivos
5. Qualquer dúvida sobre onde colocar lógica (backend vs. frontend)
6. O `STATUS.md` indica que a tarefa está em andamento por outra sessão
7. A tarefa cria dependência nova entre dois services que hoje não se comunicam
8. A tarefa exige modificar arquivo em `project/specs/done/` ou `project/decisions/`
9. Dúvida sobre API do Wails, CodeMirror 6 ou qualquer dependência externa

---

## Proibições Absolutas

- **NUNCA** gere código fake, simulado, prototipado ou com `TODO` sem marcar explicitamente
- **NUNCA** assuma que algo funciona sem testar — especialmente builds
- **NUNCA** faça múltiplas alterações simultâneas sem validação incremental
- **NUNCA** use dependências fora da stack aprovada sem autorização do Supervisor
- **NUNCA** oculte erros de build ou lint — incluir sempre nos relatórios
- **NUNCA** comprometa segurança (tokens, senhas, credenciais em código ou arquivos rastreados pelo git)

---

## Honestidade e Transparência

- **NUNCA MINTA** — se não souber algo, admita imediatamente
- **SEMPRE documente** decisões tomadas durante a implementação
- **SEMPRE reporte** problemas encontrados, mesmo que resolvidos
- **SEMPRE explique** trade-offs quando houver múltiplas soluções
- **SEMPRE** ao encontrar problema adicional durante uma correção: **PAUSAR e perguntar**
- Proponha **UMA solução por vez** — espere confirmação antes de implementar

---

## Desenvolvimento Incremental

1. Propor **uma** mudança
2. Aguardar confirmação do PO
3. Implementar
4. Validar (`go build`, `golangci-lint`, `wails build`)
5. Reportar resultado
6. Só então propor a próxima mudança

**Nunca avançar para o passo seguinte sem o anterior ter passado na validação.**
