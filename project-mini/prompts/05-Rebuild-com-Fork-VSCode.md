# Tarefa: Build e Testes Iniciais do Editor mini

**Data:** 04/12/2025
**Prompt:** #005
**Dependências:** Prompt #004 (Migração para VSCode concluída)
**Plataforma:** Windows
**Contexto:** Primeira execução do mini baseado em VSCode fork

---

## 📋 Contexto

A migração para base VSCode foi **concluída com sucesso**. O ambiente está preparado:

- ✅ Fork do microsoft/vscode clonado em `D:\proj\mini\`
- ✅ Node.js v25 instalado
- ✅ `npm install` executado (dependências instaladas)
- ✅ `product.json` customizado (branding mini, telemetria removida)
- ✅ Marketplace Open VSX configurado
- ✅ Documentação atualizada (`.cursorrules`, `PROJECT-CONTEXT.md`, specs)

**Objetivo desta tarefa:** Compilar o código VSCode, executar o editor localmente, validar funcionalidades básicas e documentar o estado inicial antes de começar customizações.

---

## 🎯 Objetivos

1. ✅ Compilar código TypeScript (npm run watch)
2. ✅ Executar mini local (.\scripts\code.bat)
3. ✅ Validar funcionalidades core do VSCode
4. ✅ Capturar screenshots do estado inicial
5. ✅ Identificar áreas para customização
6. ✅ Documentar completamente no relatório

---

## 📝 PARTE 1: Compilação Inicial

### 1.1 Verificar Ambiente

**Antes de começar, verificar:**

```
# Navegar para pasta do projeto
cd D:\proj\mini

# Verificar versões
node --version    # Deve mostrar: v25.x.x
npm --version     # Deve mostrar: 11.x.x
git --version     # Deve mostrar: 2.51.0

# Verificar se node_modules existe
Test-Path node_modules
# Deve retornar: True

# Verificar se product.json está customizado
Get-Content product.json | Select-String "mini"
# Deve encontrar múltiplas ocorrências
```

**Documentar no relatório:**
- Versões exatas de Node.js, npm, Git
- Tamanho da pasta `node_modules` (em GB)
- Screenshot do `product.json` mostrando customizações

---

### 1.2 Compilar TypeScript (Watch Mode)

**Comando:**
```
npm run watch
```

**O que esperar:**
- Compilação pode demorar 5-10 minutos na primeira vez
- Muitos arquivos `.ts` sendo compilados
- Mensagem final: `Compilation complete. Watching for file changes.`
- Terminal deve ficar "travado" (rodando watch)

**Possíveis Avisos (Normal):**
- TypeScript warnings (algumas centenas) - IGNORAR se não forem erros
- Deprecated warnings - IGNORAR

**Erros Críticos (PARAR se ocorrer):**
- `TS` erros de sintaxe
- Module not found
- Out of memory

**Ações:**
1. Executar `npm run watch`
2. Aguardar conclusão
3. Capturar screenshot do terminal quando aparecer "Compilation complete"
4. **DEIXAR RODANDO** (não fechar terminal)
5. Anotar tempo total de compilação

**Documentar no relatório:**
- Tempo de compilação inicial
- Número de arquivos compilados (aproximado)
- Warnings/erros encontrados
- Screenshot do terminal

---

## 📝 PARTE 2: Execução do Editor

### 2.1 Executar mini Local (Primeiro Boot)

**Abrir NOVO terminal PowerShell** (manter watch rodando no primeiro)

```
# Navegar para projeto
cd D:\proj\mini

# Executar editor
.\scripts\code.bat
```

**O que esperar:**
- Janela do editor deve abrir em 5-15 segundos
- Título da janela: "mini" (se product.json estiver correto)
- Interface padrão do VSCode (ainda não customizada)

**Possíveis Problemas:**

**Problema 1:** Janela não abre
```
# Verificar se há processo travado
Get-Process | Where-Object {$_.ProcessName -like "*code*"}

# Matar processos se necessário
Stop-Process -Name "code" -Force
```

**Problema 2:** Erro "Cannot find module"
```
# Recompilar
npm run compile
.\scripts\code.bat
```

**Problema 3:** Janela abre mas fica em branco
- Verificar console de desenvolvedor: Ctrl+Shift+I
- Capturar erros no console
- Incluir no relatório

**Ações:**
1. Executar `.\scripts\code.bat`
2. Aguardar abertura da janela
3. Capturar screenshot da interface completa
4. Verificar título da janela (deve ser "mini")
5. **NÃO FECHAR** ainda - vamos testar funcionalidades

**Documentar no relatório:**
- Tempo até janela abrir
- Título correto ("mini" ou ainda "Code - OSS")
- Screenshot da interface inicial
- Erros encontrados (se houver)

---

### 2.2 Exploração Inicial da Interface

**Com o editor aberto, explorar:**

#### a) Menu Bar
- Verificar menus: File, Edit, Selection, View, Go, Run, Terminal, Window, Help
- **Observar:** Menus de IDE ainda estão presentes (Run, Terminal) - serão removidos depois

#### b) Barra de Status (Rodapé)
- Verificar se aparece informações
- **Observar:** Pode ter Git status, problemas, etc - simplificar depois

#### c) Side Bar (Painel Lateral Esquerdo)
- Ícones: Explorer, Search, Source Control, Run and Debug, Extensions
- **Observar:** Ícones de IDE (Debug, SCM) - remover depois

#### d) Editor Area (Centro)
- Deve aparecer Welcome page ou área vazia
- **Observar:** Aparência padrão VSCode (ainda não Moleskine)

**Ações:**
1. Explorar cada área
2. Capturar screenshot de cada menu aberto
3. Anotar features de IDE que precisam ser removidas
4. Listar no relatório

**Documentar no relatório:**
- Screenshot de cada área principal
- Lista de features de IDE identificadas (para remoção futura)
- Observações sobre UI padrão

---

## 📝 PARTE 3: Testes de Funcionalidades Básicas

### 3.1 Teste: Abrir Arquivo

**Passos:**
1. File → Open File (Ctrl+O)
2. Navegar até `D:\proj\mini\README.md`
3. Abrir arquivo

**Validar:**
- [ ] Arquivo abre corretamente
- [ ] Syntax highlighting funciona (Markdown)
- [ ] Barra de status mostra: linha/coluna, encoding
- [ ] Título da aba mostra "README.md"

**Capturar:**
- Screenshot do arquivo aberto
- Screenshot da barra de status

---

### 3.2 Teste: Sistema de Abas (Múltiplos Arquivos)

**Passos:**
1. Arquivo já aberto: `README.md`
2. Abrir segundo arquivo: `package.json` (Ctrl+O)
3. Abrir terceiro arquivo: `product.json`

**Validar:**
- [ ] Três abas aparecem no topo
- [ ] Pode alternar entre abas (clique ou Ctrl+Tab)
- [ ] Aba ativa tem destaque visual
- [ ] Pode fechar abas (botão X ou Ctrl+W)

**Capturar:**
- Screenshot com 3 arquivos abertos (abas visíveis)
- Screenshot ao alternar entre abas

---

### 3.3 Teste: File Explorer (Painel Lateral)

**Passos:**
1. View → Explorer (ou Ctrl+Shift+E)
2. File → Open Folder
3. Selecionar `D:\proj\mini\project-mini\specifications\`

**Validar:**
- [ ] Árvore de arquivos aparece no Explorer
- [ ] Pode expandir/colapsar pastas
- [ ] Clicar em arquivo abre no editor
- [ ] Arquivos .md mostram ícone correto

**Capturar:**
- Screenshot do Explorer com pasta aberta
- Screenshot da árvore de arquivos expandida

---

### 3.4 Teste: Editor Monaco (Features Básicas)

**Abrir arquivo:** `D:\proj\mini\project-mini\PROJECT-CONTEXT.md`

**Validar:**

#### Multi-cursor
- [ ] Ctrl+D seleciona próxima ocorrência
- [ ] Alt+Click adiciona cursor
- [ ] Ctrl+Shift+L seleciona todas ocorrências

#### Find/Replace
- [ ] Ctrl+F abre Find
- [ ] Busca funciona
- [ ] Ctrl+H abre Replace
- [ ] Replace funciona

#### Code Folding
- [ ] Pode colapsar seções (markdown headers)
- [ ] Pode expandir seções

#### Syntax Highlighting
- [ ] Markdown com cores corretas
- [ ] Títulos (#, ##) destacados
- [ ] Code blocks (```

**Capturar:**
- Screenshot de multi-cursor em ação
- Screenshot de Find/Replace aberto
- Screenshot de code folding

***

### 3.5 Teste: Temas (Color Themes)

**Passos:**
1. Ctrl+K Ctrl+T (ou File → Preferences → Color Theme)
2. Visualizar lista de temas disponíveis

**Validar:**
- [ ] Painel de temas abre
- [ ] Lista de temas aparece
- [ ] Pode alternar entre temas (preview ao navegar)
- [ ] Tema aplica corretamente

**Testar temas:**
- Dark+ (default dark)
- Light+ (default light)
- Dark High Contrast
- Light High Contrast

**Capturar:**
- Screenshot do seletor de temas
- Screenshot com tema Dark+
- Screenshot com tema Light+
- **Observação:** Tema Moleskine ainda não existe (será criado no Prompt #006)

**Retornar ao tema:** Light+ (ou Dark+ se preferir)

***

### 3.6 Teste: Configurações (Settings)

**Passos:**
1. File → Preferences → Settings (ou Ctrl+,)
2. Explorar categorias

**Validar:**
- [ ] Settings UI abre
- [ ] Pode buscar configurações
- [ ] Pode modificar valores
- [ ] Alterações são persistidas

**Testar modificações:**
- Mudar `editor.fontSize` para 16
- Mudar `editor.fontFamily` para "Consolas"
- Verificar se mudanças aplicam no editor

**Capturar:**
- Screenshot da Settings UI
- Screenshot de configurações modificadas

**Reverter mudanças** após teste

***

### 3.7 Teste: Split View (Divisão de Painéis)

**Passos:**
1. Abrir arquivo `README.md`
2. View → Editor Layout → Split Right (ou Ctrl+\)
3. Abrir `package.json` no segundo painel

**Validar:**
- [ ] Editor divide em dois painéis
- [ ] Pode ter arquivos diferentes em cada painel
- [ ] Pode redimensionar painéis (arrastar divisor)
- [ ] Divisor (split bar) é visível

**Observar:**
- Largura do divisor (split bar)
- Cor do divisor
- Comportamento ao hover
- **Nota:** Será refinado no Prompt #007 (UI minimalista)

**Capturar:**
- Screenshot de split view com 2 arquivos
- Screenshot do divisor (zoom se necessário)

***

### 3.8 Teste: Barra de Status (Status Bar)

**Validar informações exibidas:**
- [ ] Encoding do arquivo (UTF-8, etc)
- [ ] Tipo de arquivo / Linguagem
- [ ] Linha e coluna atual (Ln X, Col Y)
- [ ] Espaços/Tabs (Spaces: 4, etc)
- [ ] End of Line (CRLF, LF)

**Observar features de IDE:**
- Git branch (se houver)
- Problemas/Warnings
- Outros indicadores

**Capturar:**
- Screenshot da barra de status (zoom)
- Anotar todas informações exibidas

***

### 3.9 Teste: Shortcuts de Teclado

**Validar shortcuts principais:**

| Ação | Shortcut | Funciona? |
|------|----------|-----------|
| Open File | Ctrl+O | [ ] |
| Save | Ctrl+S | [ ] |
| Save As | Ctrl+Shift+S | [ ] |
| Close Tab | Ctrl+W | [ ] |
| New File | Ctrl+N | [ ] |
| Find | Ctrl+F | [ ] |
| Replace | Ctrl+H | [ ] |
| Command Palette | Ctrl+Shift+P | [ ] |
| Quick Open | Ctrl+P | [ ] |
| Toggle Sidebar | Ctrl+B | [ ] |
| Toggle Terminal | Ctrl+` | [ ] |
| Split Editor | Ctrl+\ | [ ] |
| Zoom In | Ctrl++ | [ ] |
| Zoom Out | Ctrl+- | [ ] |

**Capturar:**
- Screenshot do Command Palette aberto (Ctrl+Shift+P)
- Screenshot do Quick Open (Ctrl+P)

***

## 📝 PARTE 4: Identificação de Áreas para Customização

### 4.1 Features de IDE a Remover

**Listar tudo que precisa ser removido:**

#### Menus
- [ ] Run menu (completo)
- [ ] Terminal menu (simplificar ou remover)
- [ ] Debug options (remover)

#### Side Bar
- [ ] Run and Debug ícone (remover)
- [ ] Source Control ícone (simplificar - manter básico)
- [ ] Extensions ícone (remover UI, manter instalação manual)

#### Barra de Status
- [ ] Git branch info (remover)
- [ ] Problemas/Warnings count (remover)
- [ ] Language selection (simplificar)

#### Command Palette
- [ ] Comandos de debug (remover)
- [ ] Comandos de terminal (simplificar)
- [ ] Comandos de git avançado (remover)

**Documentar no relatório:**
- Lista completa de features a remover
- Screenshots marcando cada elemento
- Priorização (crítico, importante, nice-to-have)

***

### 4.2 UI a Simplificar

**Elementos que precisam de refinamento:**

#### Split Bar (Divisor)
- Largura atual: ~5px (estimado)
- **Objetivo:** 1-2px, hover com transição suave

#### Barra de Abas
- Altura atual: ~35px
- Close button: Sempre visível
- **Objetivo:** ~36px, close apenas ao hover

#### Barra de Status
- Informações: Muitas (git, problemas, etc)
- **Objetivo:** Apenas essenciais (encoding, linha/coluna, caminho)

#### Painel Lateral
- Largura: ~200px (estimado)
- **Objetivo:** 240-320px, mais espaçoso

**Documentar no relatório:**
- Medidas atuais (pixels - usar DevTools se necessário)
- Objetivos de refinamento
- Screenshots anotadas

***

### 4.3 Tema Atual vs. Tema Moleskine

**Tema Atual (Light+):**
- Fundo: Branco (`#FFFFFF`)
- Texto: Preto
- Bordas: Cinza claro

**Tema Moleskine (Objetivo):**
- Fundo: `#FAF6EF` (Vanilla Cream)
- Texto: `#2C2416` (marrom escuro)
- Bordas: `#E5DDD0` (bege suave)
- Acentos: `#3484F7` (azul suave)

**Capturar:**
- Screenshot do tema atual (Light+)
- Anotar diferenças visuais vs. objetivo

***

## 📝 PARTE 5: Testes de Performance

### 5.1 Tempo de Startup

**Teste:**
1. Fechar mini completamente
2. Cronometrar tempo até janela abrir
3. Repetir 3 vezes e calcular média

**Comandos:**
```powershell
# Fechar mini
Stop-Process -Name "code" -Force -ErrorAction SilentlyContinue

# Executar e cronometrar
Measure-Command { .\scripts\code.bat }
```

**Documentar:**
- Tempo 1: X.XX segundos
- Tempo 2: X.XX segundos
- Tempo 3: X.XX segundos
- **Média:** X.XX segundos

**Objetivo:** <3s em SSD

***

### 5.2 Uso de Memória

**Com mini aberto:**

```powershell
# Verificar uso de memória
Get-Process | Where-Object {$_.ProcessName -like "*code*"} | Select-Object ProcessName, @{Name="Memory (MB)";Expression={[math]::Round($_.WorkingSet64/1MB,2)}}
```

**Documentar:**
- Processo principal: XXX MB
- Processos auxiliares: XXX MB
- **Total:** XXX MB

**Objetivo:** <300 MB (mini sem extensões)

***

### 5.3 Tempo de Abertura de Arquivo

**Teste:**
1. Abrir arquivo grande: `D:\proj\mini\out\vs\code\electron-main\main.js` (~1MB)
2. Cronometrar tempo até exibição completa

**Documentar:**
- Tamanho do arquivo: X.XX MB
- Tempo de abertura: X.XX segundos

**Objetivo:** <500ms para arquivos <5MB

***

## 📝 PARTE 6: Testes de Integração (Open VSX)

### 6.1 Verificar Marketplace Configurado

**Passos:**
1. View → Extensions (Ctrl+Shift+X)
2. Buscar extensão: "GitHub Theme"

**Validar:**
- [ ] Painel de extensões abre
- [ ] Busca funciona
- [ ] Extensões do Open VSX aparecem
- [ ] **NÃO** aparece mensagem de erro de marketplace

**Se aparecer erro:**
- Verificar `product.json`:
  ```json
  "extensionsGallery": {
    "serviceUrl": "https://open-vsx.org/vscode/gallery",
    "itemUrl": "https://open-vsx.org/vscode/item"
  }
  ```
- Recompilar e testar novamente

**Capturar:**
- Screenshot do painel de extensões
- Screenshot de busca por "GitHub Theme"

***

### 6.2 Testar Instalação de Tema (Open VSX)

**Passos:**
1. No painel Extensions, buscar: "GitHub Theme"
2. Clicar em "Install"
3. Aguardar instalação
4. Aplicar tema: Ctrl+K Ctrl+T → "GitHub Light"

**Validar:**
- [ ] Tema instala corretamente
- [ ] Tema aparece na lista (Ctrl+K Ctrl+T)
- [ ] Tema aplica visualmente

**Capturar:**
- Screenshot da instalação
- Screenshot com tema GitHub Light aplicado

**Remover tema após teste** (para manter clean)

***

## 📝 PARTE 7: Console de Desenvolvedor

### 7.1 Verificar Erros no Console

**Abrir DevTools:**
- Help → Toggle Developer Tools (ou Ctrl+Shift+I)

**Verificar:**
- [ ] Aba Console: Erros vermelhos?
- [ ] Aba Network: Requests falhando?
- [ ] Aba Performance: Gargalos?

**Se houver erros:**
- Capturar screenshot
- Copiar mensagens de erro completas
- Incluir no relatório

**Capturar:**
- Screenshot do Console (se sem erros, mostrar "clean")
- Screenshot de erros (se houver)

***

## 📝 PARTE 8: Documentação Final

### 8.1 Checklist de Validação

**Marcar tudo que funciona:**

#### Core
- [ ] Editor compila sem erros
- [ ] Janela abre corretamente
- [ ] Título mostra "mini"
- [ ] Interface responsiva (não trava)

#### Editor
- [ ] Abrir arquivos funciona
- [ ] Salvar arquivos funciona
- [ ] Syntax highlighting funciona
- [ ] Multi-cursor funciona
- [ ] Find/Replace funciona
- [ ] Code folding funciona

#### UI
- [ ] Sistema de abas funciona
- [ ] Split view funciona
- [ ] File Explorer funciona
- [ ] Barra de status exibe informações
- [ ] Temas podem ser trocados

#### Configurações
- [ ] Settings UI funciona
- [ ] Configurações são persistidas
- [ ] Shortcuts funcionam

#### Performance
- [ ] Startup <5s
- [ ] Uso de memória <400 MB
- [ ] Abertura de arquivos rápida

#### Integração
- [ ] Open VSX marketplace funciona
- [ ] Extensões podem ser instaladas
- [ ] Temas podem ser instalados

***

### 8.2 Problemas Encontrados

**Listar TODOS os problemas, mesmo pequenos:**

| Problema | Severidade | Status | Observações |
|----------|-----------|--------|-------------|
| Exemplo: Título ainda mostra "Code" | Baixa | ⚠️ Pendente | Verificar product.json |
| | | | |

**Severidades:**
- 🔴 Crítica: Impede uso
- 🟡 Alta: Impacta experiência
- 🟢 Baixa: Cosmético

***

### 8.3 Screenshots Obrigatórios

**Lista de screenshots que DEVEM estar no relatório:**

1. ✅ Terminal mostrando "Compilation complete"
2. ✅ Interface completa do mini (primeiro boot)
3. ✅ Menu File aberto
4. ✅ README.md aberto (syntax highlighting)
5. ✅ Três arquivos abertos (sistema de abas)
6. ✅ File Explorer com pasta aberta
7. ✅ Multi-cursor em ação
8. ✅ Find/Replace aberto
9. ✅ Seletor de temas (Ctrl+K Ctrl+T)
10. ✅ Tema Dark+ aplicado
11. ✅ Tema Light+ aplicado
12. ✅ Settings UI aberta
13. ✅ Split view (2 arquivos)
14. ✅ Barra de status (zoom)
15. ✅ Command Palette aberto
16. ✅ Painel de extensões (Open VSX)
17. ✅ Console de desenvolvedor (DevTools)
18. ✅ Identificação de features a remover (anotado)

**Total:** Mínimo 18 screenshots

***

## 📊 Estrutura do Relatório

**Criar:** `D:\proj\mini\project-mini\reports\report-prompt-005-YYYYMMDD.md`

### Seções Obrigatórias:

```markdown
# Relatório: Build e Testes Iniciais do mini

## 1. Resumo Executivo
- Status geral (sucesso/problemas)
- Principais conclusões
- Próximos passos

## 2. Ambiente
- Node.js: vX.X.X
- npm: X.X.X
- Git: X.X.X
- Tamanho node_modules: X GB

## 3. Compilação
- Tempo total: XX minutos
- Warnings: XX (listar se relevantes)
- Erros: Nenhum / Listar
- Screenshot do terminal

## 4. Primeira Execução
- Tempo de startup: X.Xs
- Título da janela: "mini" ou "Code"
- Screenshot da interface

## 5. Testes de Funcionalidades
### 5.1 Abrir Arquivo
- [ ] Passou / ❌ Falhou
- Screenshot

### 5.2 Sistema de Abas
- [ ] Passou / ❌ Falhou
- Screenshot

### 5.3 File Explorer
- [ ] Passou / ❌ Falhou
- Screenshot

### 5.4 Editor Monaco
- [ ] Multi-cursor: Passou
- [ ] Find/Replace: Passou
- [ ] Code folding: Passou
- [ ] Syntax highlighting: Passou
- Screenshots

### 5.5 Temas
- [ ] Passou / ❌ Falhou
- Screenshots (Dark+, Light+)

### 5.6 Configurações
- [ ] Passou / ❌ Falhou
- Screenshot

### 5.7 Split View
- [ ] Passou / ❌ Falhou
- Screenshot

### 5.8 Barra de Status
- Informações exibidas: [lista]
- Screenshot

### 5.9 Shortcuts
- [Tabela de resultados]

## 6. Identificação de Customizações
### 6.1 Features de IDE a Remover
- [Lista completa com screenshots]

### 6.2 UI a Simplificar
- [Lista com medidas atuais vs. objetivos]

### 6.3 Tema Atual vs. Moleskine
- [Comparação visual]

## 7. Performance
- Startup: X.Xs (média de 3 testes)
- Memória: XXX MB
- Abertura de arquivo: X.XXs

## 8. Open VSX Integration
- [ ] Marketplace funciona
- [ ] Instalação de extensões funciona
- Screenshots

## 9. Console de Desenvolvedor
- Erros: Nenhum / [Lista]
- Screenshot

## 10. Checklist de Validação
- [Checklist completa marcada]

## 11. Problemas Encontrados
- [Tabela de problemas]

## 12. Comandos Executados
```
[Histórico completo de comandos]
```

## 13. Screenshots
- [Todos os 18 screenshots obrigatórios]

## 14. Conclusões
- Estado atual: Funcional / Com problemas
- Pronto para customizações: Sim / Não
- Bloqueadores: Nenhum / [Lista]

## 15. Próximos Passos
- Prompt #006: Implementação do Tema Moleskine
- Prompt #007: Simplificação da UI
- Etc.

## 16. Tempo Total
- Execução desta tarefa: XX horas

## 17. Observações Adicionais
- [Notas relevantes]

***

## ⏱️ Tempo Estimado

- **Compilação:** 10-15 min
- **Primeira execução e exploração:** 15-20 min
- **Testes de funcionalidades:** 30-40 min
- **Identificação de customizações:** 20-30 min
- **Testes de performance:** 10-15 min
- **Open VSX integration:** 10-15 min
- **Documentação:** 30-40 min

**Total:** 2-3 horas

***

## 🎯 Critérios de Aceitação

✅ Compilação concluída sem erros críticos
✅ Editor abre e funciona corretamente
✅ Todas funcionalidades básicas validadas
✅ Performance dentro dos objetivos
✅ Open VSX marketplace funciona
✅ Console sem erros críticos
✅ Checklist 100% preenchido
✅ Mínimo 18 screenshots capturados
✅ Relatório completo e detalhado
✅ Problemas documentados (se houver)
✅ Pronto para Prompt #006 (Tema Moleskine)

***

## 📚 Referências

- `.cursorrules` (D:\proj\mini\.cursorrules)
- `PROJECT-CONTEXT.md` (D:\proj\mini\project-mini\PROJECT-CONTEXT.md)
- `Especificação-Técnica-e-Arquitetural-v2.md`
- `Especificação-Visual-e-Diretrizes-de-UX-UI.md`

***

## ⚠️ Observações Importantes

- **NUNCA force compilation** se houver erros críticos (reportar ao PO)
- **SEMPRE capture screenshots** antes de fechar o editor
- **NÃO faça customizações** nesta tarefa (apenas documentar o que precisa ser feito)
- **NÃO instale extensões** além do teste do Open VSX (remover depois)
- **PAUSE** se encontrar comportamentos inesperados e reporte

***

**Boa sorte! Aguardo relatório completo com todos os screenshots e validações.**
