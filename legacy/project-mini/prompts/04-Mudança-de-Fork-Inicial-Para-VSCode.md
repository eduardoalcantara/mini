# Tarefa: Migração para Base VSCode e Preparação do Ambiente

**Data:** 04/12/2025
**Prompt:** #004
**Dependências:** Relatórios anteriores (Prompts #000 e #002)
**Plataforma:** Windows

---

## Contexto

Após análise técnica detalhada, identificamos que o fork atual do Electron (electron-monaco-editor) não possui as funcionalidades necessárias para o projeto **mini**. A decisão do PO foi migrar para uma base mais robusta: **VSCode/VSCodium**.

**Motivos da mudança:**
- ❌ Fork Electron atual: Sem sistema de abas, sem gerenciamento de múltiplos arquivos, sem sistema de temas
- ✅ VSCode base: 80% das funcionalidades já implementadas, sistema de temas robusto, UI moderna
- ✅ VSCodium: Scripts para remover telemetria, open source, legal para uso

**Objetivo:** Preparar ambiente com VSCode como base, remover telemetria, e preparar para customizações do mini.

---

## Estratégia de Implementação

Vamos usar **microsoft/vscode** (código-fonte) + **scripts do VSCodium** (para limpar telemetria):

1. Fork do código-fonte do VSCode
2. Aplicar scripts de limpeza do VSCodium
3. Preparar estrutura para customizações
4. Build inicial e testes no Windows

---

## Pré-Requisitos (Windows)

### Ferramentas Necessárias

Antes de começar, instale/verifique:

**1. Node.js (já instalado - v22.18.0)**
- ✅ Verificado no Prompt #000

**2. Python 3.11+**
```
# Verificar se está instalado
python --version

# Se não estiver, instalar via Microsoft Store ou:
winget install Python.Python.3.11
```

**3. Visual Studio Build Tools**
```
# Necessário para compilar módulos nativos do VSCode
# Opção 1: Instalar Visual Studio 2022 Community (recomendado)
# https://visualstudio.microsoft.com/downloads/

# Opção 2: Build Tools standalone
# https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

# Durante instalação, selecionar:
# - Desktop development with C++
# - Windows 10/11 SDK
```

**4. Git (já instalado - v2.51.0)**
- ✅ Verificado no Prompt #000

**5. Yarn (gerenciador de pacotes do VSCode)**
```
npm install -g yarn
yarn --version
```

---

## PARTE 1: Preparação do Repositório

### 1.1 Backup do Trabalho Atual

```
# Navegar para pasta do projeto atual
cd D:\proj\mini  # (ajustar para seu caminho)

# Criar backup do trabalho feito até agora
git checkout -b backup-electron-fork
git add .
git commit -m "Backup: Fork Electron antes da migração para VSCode"
git push origin backup-electron-fork

# Documentar arquivos/configurações importantes para preservar
# Criar arquivo de referência
echo "# Arquivos Preservados do Fork Anterior" > MIGRATION-NOTES.md
echo "" >> MIGRATION-NOTES.md
echo "## Configurações a Migrar:" >> MIGRATION-NOTES.md
echo "- package.json (dependências específicas)" >> MIGRATION-NOTES.md
echo "- .cursorrules" >> MIGRATION-NOTES.md
echo "- /specifications/ (todos arquivos)" >> MIGRATION-NOTES.md
echo "- /prompts/" >> MIGRATION-NOTES.md
echo "- /reports/" >> MIGRATION-NOTES.md
```

### 1.2 Criar Nova Branch para VSCode

```
# Criar branch para novo código
git checkout -b vscode-base
```

---

## PARTE 2: Clone do VSCode

### 2.1 Fork e Clone do microsoft/vscode

**Ação Manual (GitHub):**
1. Acessar: https://github.com/microsoft/vscode
2. Clicar em "Fork" (canto superior direito)
3. Nome do fork: `mini` ou `mini-editor`
4. Criar fork no seu usuário: `eduardoalcantara/mini`

**Clone Local:**
```
# Navegar para pasta de projetos
cd D:\proj  # (ajustar para seu caminho)

# Clonar seu fork
git clone https://github.com/eduardoalcantara/mini.git mini-vscode
cd mini-vscode

# Adicionar remote do original (para updates futuros)
git remote add upstream https://github.com/microsoft/vscode.git

# Verificar remotes
git remote -v
# Deve mostrar:
# origin    https://github.com/eduardoalcantara/mini.git
# upstream  https://github.com/microsoft/vscode.git
```

### 2.2 Download dos Scripts do VSCodium

```
# Criar pasta para scripts de build
mkdir build
cd build

# Baixar scripts principais do VSCodium
# Usar Invoke-WebRequest do PowerShell

# Script de remoção de telemetria
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/VSCodium/vscodium/master/prepare_vscode.sh" -OutFile "prepare_vscode.sh"

# Script de aplicação de patches
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/VSCodium/vscodium/master/patches/patch.sh" -OutFile "patch.sh"

# Product.json customizado (sem telemetria)
Invoke-WebRequest -Uri "https://raw.githubusercontent.com/VSCodium/vscodium/master/product.json" -OutFile "product.json.vscodium"

# Voltar para raiz
cd ..
```

---

## PARTE 3: Instalação de Dependências

### 3.1 Instalar Dependências do VSCode

```
# Instalar dependências (pode demorar 10-20 minutos)
yarn install

# Aguardar conclusão
# Observar se há erros de compilação
```

**Erros Comuns e Soluções:**

**Erro:** `gyp ERR! find VS`
```
# Solução: Instalar Visual Studio Build Tools (passo 3 dos pré-requisitos)
# Após instalar, executar:
npm config set msvs_version 2022
yarn install
```

**Erro:** `Python not found`
```
# Solução: Configurar caminho do Python
npm config set python "C:\Users\<SEU_USER>\AppData\Local\Programs\Python\Python311\python.exe"
# Ajustar caminho conforme sua instalação
yarn install
```

### 3.2 Verificar Instalação

```
# Listar scripts disponíveis
yarn run

# Deve mostrar scripts como:
# - watch
# - compile
# - electron
# - etc
```

---

## PARTE 4: Build e Teste Inicial

### 4.1 Compilar VSCode (Desenvolvimento)

```
# Compilar código (primeira vez demora ~10-15 min)
yarn watch

# Aguardar mensagem: "Compilation complete"
# Deixar rodando (não fechar terminal)
```

### 4.2 Executar VSCode Local (Novo Terminal)

```
# Abrir NOVO terminal PowerShell
cd D:\proj\mini-vscode  # (seu caminho)

# Executar VSCode em modo desenvolvimento
.\scripts\code.bat

# Deve abrir janela do VSCode (ainda sem customizações)
```

### 4.3 Testes Básicos

**Verificar se funciona:**
- [ ] Janela abre corretamente
- [ ] Pode abrir arquivos
- [ ] Sistema de abas funciona
- [ ] Painel lateral (Explorer) funciona
- [ ] Monaco Editor funciona
- [ ] Syntax highlighting funciona
- [ ] Temas podem ser trocados (Ctrl+K Ctrl+T)
- [ ] Barra de status aparece
- [ ] Configurações acessíveis (Ctrl+,)

**Capturar screenshots:**
- Interface completa
- Painel de temas
- Barra de status
- Múltiplos arquivos abertos

---

## PARTE 5: Aplicar Limpeza de Telemetria

### 5.1 Modificar product.json

```
# Backup do product.json original
Copy-Item product.json product.json.original

# Editar product.json
# Remover/modificar linhas relacionadas a telemetria:

# Procurar e alterar:
# - "enableTelemetry": true  →  "enableTelemetry": false
# - "aiConfig": {...}  →  remover seção completa
# - URLs da Microsoft  →  substituir ou remover
```

**Referência do product.json do VSCodium:**
```
{
  "nameShort": "mini",
  "nameLong": "mini - Minimalist, Intelligent, Nice Interface",
  "applicationName": "mini",
  "dataFolderName": ".mini",
  "win32MutexName": "minimutex",
  "win32DirName": "mini",
  "win32NameVersion": "mini",
  "win32AppUserModelId": "mini.mini",
  "win32ShellNameShort": "mini",
  "darwinBundleIdentifier": "com.mini.editor",
  "linuxIconName": "mini",
  "licenseUrl": "https://github.com/eduardoalcantara/mini/blob/main/LICENSE",
  "reportIssueUrl": "https://github.com/eduardoalcantara/mini/issues/new",
  "urlProtocol": "mini",
  "extensionsGallery": {
    "serviceUrl": "https://open-vsx.org/vscode/gallery",
    "itemUrl": "https://open-vsx.org/vscode/item"
  },
  "enableTelemetry": false,
  "quality": "stable"
}
```

### 5.2 Rebuild Após Mudanças

```
# Parar watch anterior (Ctrl+C)

# Limpar build anterior
yarn gulp clean

# Recompilar com novas configurações
yarn watch

# Testar novamente
.\scripts\code.bat
```

---

## PARTE 6: Estrutura de Pastas Customizadas

### 6.1 Criar Pastas do Projeto mini

```
# Na raiz do repositório, criar estrutura do mini
mkdir custom
mkdir custom\themes
mkdir custom\icons
mkdir custom\branding

# Copiar especificações do projeto antigo
# (ajustar caminho conforme necessário)
xcopy /E /I D:\proj\mini\specifications .\specifications
xcopy /E /I D:\proj\mini\prompts .\prompts
xcopy /E /I D:\proj\mini\reports .\reports
xcopy /E /I D:\proj\mini\tests .\tests
xcopy /E /I D:\proj\mini\scripts .\scripts

# Copiar .cursorrules
copy D:\proj\mini\.cursorrules .\.cursorrules
```

### 6.2 Documentar Estrutura

```
# Criar README específico da estrutura
echo "# Estrutura do Projeto mini" > STRUCTURE.md
echo "" >> STRUCTURE.md
echo "## Pastas:" >> STRUCTURE.md
echo "- /custom/ - Customizações específicas do mini" >> STRUCTURE.md
echo "- /custom/themes/ - Tema Moleskine e outros" >> STRUCTURE.md
echo "- /custom/icons/ - Ícones do mini" >> STRUCTURE.md
echo "- /custom/branding/ - Logo, nome, identidade visual" >> STRUCTURE.md
echo "- /specifications/ - Documentação técnica e requisitos" >> STRUCTURE.md
echo "- /prompts/ - Prompts para desenvolvimento" >> STRUCTURE.md
echo "- /reports/ - Relatórios de execução de tarefas" >> STRUCTURE.md
echo "- /tests/ - Testes automatizados" >> STRUCTURE.md
echo "- /scripts/ - Scripts utilitários" >> STRUCTURE.md
```

---

## PARTE 7: Commit e Documentação

### 7.1 Commit Inicial

```
# Adicionar arquivos
git add .
git commit -m "feat: Migração para base VSCode/VSCodium

- Fork do microsoft/vscode
- Scripts de limpeza do VSCodium integrados
- Telemetria removida do product.json
- Estrutura de pastas do mini criada
- Build inicial testado e funcional

Ref: Prompt #004"

# Push para repositório
git push origin vscode-base
```

### 7.2 Atualizar README

```
# Criar README.md principal do projeto
echo "# mini - Minimalist, Intelligent, Nice Interface" > README.md
echo "" >> README.md
echo "Editor de texto minimalista e elegante, baseado no VSCode." >> README.md
echo "" >> README.md
echo "## Base" >> README.md
echo "- Código: microsoft/vscode" >> README.md
echo "- Build Scripts: VSCodium/vscodium" >> README.md
echo "- Telemetria: Removida" >> README.md
echo "- Marketplace: Open VSX" >> README.md
echo "" >> README.md
echo "## Desenvolvimento" >> README.md
echo "" >> README.md
echo "### Pré-requisitos Windows" >> README.md
echo "- Node.js 18+" >> README.md
echo "- Python 3.11+" >> README.md
echo "- Visual Studio Build Tools 2022" >> README.md
echo "- Yarn" >> README.md
echo "" >> README.md
echo "### Build" >> README.md
echo '```powershell' >> README.md
echo "yarn install" >> README.md
echo "yarn watch" >> README.md
echo '```
echo "" >> README.md
echo "### Executar" >> README.md
echo '```powershell' >> README.md
echo ".\scripts\code.bat" >> README.md
echo '```
```

---

## Checklist de Execução

Marque cada item após completar:

### Pré-requisitos
- [ ] Node.js verificado (v22.18.0)
- [ ] Python 3.11+ instalado
- [ ] Visual Studio Build Tools instalado
- [ ] Yarn instalado globalmente

### Backup e Preparação
- [ ] Branch backup criada (backup-electron-fork)
- [ ] Arquivos importantes documentados
- [ ] Branch vscode-base criada

### Clone e Setup
- [ ] Fork criado no GitHub (eduardoalcantara/mini)
- [ ] Repositório clonado localmente
- [ ] Remote upstream configurado
- [ ] Scripts VSCodium baixados

### Build e Teste
- [ ] yarn install executado com sucesso
- [ ] yarn watch compilado sem erros
- [ ] VSCode local executado (.\scripts\code.bat)
- [ ] Testes básicos realizados
- [ ] Screenshots capturados

### Limpeza de Telemetria
- [ ] product.json modificado
- [ ] Telemetria desabilitada
- [ ] Rebuild realizado
- [ ] Testes pós-limpeza OK

### Estrutura e Documentação
- [ ] Pastas custom/ criadas
- [ ] Especificações migradas
- [ ] .cursorrules copiado
- [ ] STRUCTURE.md criado
- [ ] README.md atualizado
- [ ] Commit inicial feito
- [ ] Push para GitHub realizado

---

## Estrutura do Relatório

Crie o arquivo `/reports/report-prompt-004-YYYYMMDD.md` com:

1. **Resumo Executivo**
2. **Pré-requisitos Instalados** (versões, screenshots)
3. **Processo de Clone e Setup** (comandos executados, outputs)
4. **Build Inicial** (tempo, warnings/erros, soluções aplicadas)
5. **Testes Realizados** (checklist de funcionalidades)
6. **Limpeza de Telemetria** (mudanças no product.json)
7. **Estrutura de Pastas Criada** (tree view)
8. **Screenshots** (OBRIGATÓRIO):
   - VSCode local rodando (interface completa)
   - Painel de temas
   - Múltiplos arquivos abertos
   - Barra de status
   - Terminal do build (yarn watch)
   - Product.json modificado (antes/depois)
9. **Problemas Encontrados e Soluções**
10. **Comparação com Fork Anterior** (funcionalidades disponíveis)
11. **Comandos Executados** (histórico completo PowerShell)
12. **Tempo Total de Execução**
13. **Próximos Passos Sugeridos**

---

## Observações Importantes - Windows

- **PowerShell:** Use PowerShell (não CMD) para todos os comandos
- **Caminhos:** Use `\` ao invés de `/` em caminhos Windows
- **Permissões:** Execute PowerShell como Administrador se necessário
- **Antivírus:** Pode ser necessário adicionar exceção na pasta do projeto (builds são lentos com scan ativo)
- **Espaço em Disco:** Certifique-se de ter ~10GB livres (node_modules + build são grandes)
- **RAM:** Build consome bastante memória, feche aplicações desnecessárias

---

## Critérios de Aceitação

✅ VSCode compilado e executando localmente
✅ Todas funcionalidades básicas funcionando
✅ Telemetria removida
✅ Product.json customizado para mini
✅ Estrutura de pastas do projeto criada
✅ Especificações e documentos migrados
✅ Screenshots completos documentados
✅ Commit inicial feito e pushed
✅ README atualizado com instruções Windows
✅ Ambiente pronto para próxima fase (customizações UI)

---

## Tempo Estimado

- **Pré-requisitos:** 30-60 min (se precisar instalar ferramentas)
- **Clone e Setup:** 10 min
- **yarn install:** 15-20 min
- **Build inicial:** 10-15 min
- **Testes e configuração:** 20-30 min
- **Documentação:** 15-20 min

**Total:** 2-3 horas

---

## Próximos Passos (Prompt #005)

Após concluir esta tarefa, próximo prompt focará em:
- Customização do branding (nome, logo, ícone)
- Implementação do tema Moleskine
- Remoção de features de IDE (debugger, git avançado, etc)
- Simplificação da UI para editor minimalista

---

**Boa sorte! Aguardo relatório completo com screenshots e documentação detalhada.**
