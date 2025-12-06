
- Verificar se há outras dependências deprecated no projeto
- Atualizar scripts em package.json se necessário

**Resultado Esperado:**
- Sem warnings de dependências deprecated
- Scripts funcionando corretamente

---

### 3. Corrigir Vulnerabilidades de Segurança

**Ações:**

- Executar `npm audit fix` para correções automáticas
- Verificar se há breaking changes nas atualizações
- Para vulnerabilidades que não podem ser corrigidas automaticamente:
- Documentar no relatório
- Propor soluções alternativas ou aceitar risco temporariamente

**Resultado Esperado:**
- Reduzir vulnerabilidades para 0 (ideal) ou mínimo possível
- Documentar vulnerabilidades remanescentes com justificativa

---

### 4. Limpar e Reorganizar Código

**Ações:**

- Executar `npm clean-install` (CI mode) para instalação limpa
- Remover pasta `node_modules` antes da reinstalação
- Verificar se há arquivos temporários ou logs antigos para limpar
- Garantir que `.gitignore` está configurado corretamente

**Resultado Esperado:**
- Instalação limpa e completa
- Sem erros de compilação
- Ambiente pronto para desenvolvimento

---

### 5. Testar Aplicação Básica

**Ações:**

Após limpeza e correções:

1. Executar `npm install` e verificar se não há erros
2. Executar `npm start` e verificar se aplicação inicia
3. Testar funcionalidades básicas ainda presentes:
 - Abertura da janela Electron
 - Interface React carrega
 - Monaco Editor funciona
 - Painel lateral (se houver)
4. Documentar quaisquer erros ou warnings no console

**Resultado Esperado:**
- Aplicação inicia sem erros
- Interface básica funcional
- Console limpo (sem erros críticos)

---

## Checklist de Execução

Marque cada item após completar:

- [ ] `node-pty` removido do package.json
- [ ] `xterm` e addons removidos do package.json
- [ ] Arquivos/pastas de terminal deletados
- [ ] Imports de terminal removidos do código
- [ ] `electron-rebuild` substituído por `@electron/rebuild`
- [ ] Outras dependências deprecated atualizadas
- [ ] `npm audit fix` executado
- [ ] Vulnerabilidades documentadas
- [ ] `node_modules` removido
- [ ] `npm clean-install` executado com sucesso
- [ ] `.gitignore` verificado
- [ ] `npm start` funciona sem erros
- [ ] Interface básica testada e funcional

---

## Estrutura do Relatório

Crie o arquivo `/reports/report-prompt-002-YYYYMMDD.md` com:

1. **Resumo Executivo** (status geral da tarefa)
2. **Dependências Removidas** (lista completa)
3. **Arquivos Deletados** (lista completa com caminhos)
4. **Vulnerabilidades Corrigidas** (antes/depois)
5. **Vulnerabilidades Remanescentes** (se houver, com justificativa)
6. **Comandos Executados** (histórico completo)
7. **Testes Realizados** (resultados de cada teste)
8. **Problemas Encontrados** (se houver)
9. **Screenshots** (opcional, da aplicação rodando)
10. **Próximos Passos Sugeridos**

---

## Observações Importantes

- **NÃO** modifique funcionalidades existentes além da remoção do terminal
- **NÃO** adicione novas features nesta tarefa (apenas limpeza)
- **DOCUMENTE** todas as mudanças no relatório
- **PAUSE** e reporte se encontrar problemas inesperados
- **TESTE** após cada etapa crítica

---

## Critérios de Aceitação

Esta tarefa será considerada completa quando:

✅ Aplicação inicia sem erros
✅ Sem dependências de terminal no código
✅ Vulnerabilidades reduzidas ao mínimo
✅ Relatório completo entregue
✅ Ambiente limpo e pronto para desenvolvimento

---

**Boa sorte! Aguardo o relatório completo.**
