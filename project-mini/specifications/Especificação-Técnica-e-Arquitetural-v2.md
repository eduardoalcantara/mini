# Especificação Técnica e Arquitetural do Projeto mini

**Documento:** Especificação-Técnica-e-Arquitetural.md
**Versão:** 2.0 (Atualizada para base VSCode)
**Data:** 04/12/2025
**Autor:** Eduardo Alcântara (PO) + Perplexity AI (Supervisor)
**Localização:** `D:\proj\mini\project-mini\specifications\`

---

## 📋 Índice

1. [Visão Geral](#visão-geral)
2. [Arquitetura de Alto Nível](#arquitetura-de-alto-nível)
3. [Stack Tecnológica](#stack-tecnológica)
4. [Estrutura de Código](#estrutura-de-código)
5. [Componentes Principais](#componentes-principais)
6. [Customizações do mini](#customizações-do-mini)
7. [Sistema de Temas](#sistema-de-temas)
8. [Extensões](#extensões)
9. [Build e Deploy](#build-e-deploy)
10. [Performance e Otimização](#performance-e-otimização)
11. [Segurança](#segurança)
12. [Manutenção e Atualização](#manutenção-e-atualização)

---

## 🎯 Visão Geral

### Base Tecnológica

O **mini** é baseado em um **fork direto do microsoft/vscode**, aproveitando 80% das funcionalidades já implementadas e testadas do editor mais popular do mundo. A estratégia é:

1. ✅ **Herdar** toda infraestrutura robusta do VSCode
2. ✅ **Remover** features de IDE (debugger, git avançado, etc)
3. ✅ **Customizar** interface para minimalismo e elegância
4. ✅ **Adicionar** features específicas do mini (tema Moleskine, fontes por extensão)

### Diferencial vs. Reescrever do Zero

| Aspecto | Electron do Zero | VSCode Fork |
|---------|------------------|-------------|
| **Tempo de Desenvolvimento** | 6-12 meses | 1-3 meses |
| **Complexidade** | Alta | Média |
| **Estabilidade** | Incerta | Comprovada |
| **Manutenção** | Toda nossa | Aproveitamos updates MS |
| **Funcionalidades** | Implementar tudo | 80% pronto |
| **Testes** | Criar do zero | Já testado |
| **Comunidade** | Nenhuma | VSCode (enorme) |

**Decisão:** Fork do VSCode é claramente superior para o mini.

---

## 🏗️ Arquitetura de Alto Nível

### Diagrama de Camadas

```
┌─────────────────────────────────────────────────────────────┐
│                     mini Application                         │
├─────────────────────────────────────────────────────────────┤
│  Customizações do mini                                       │
│  - Tema Moleskine (extensions/theme-moleskine/)             │
│  - Branding (product.json)                                   │
│  - UI Simplificada (remoção de features IDE)                │
│  - Fontes por Extensão (settings)                            │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              VSCode Workbench (Interface)                    │
│  - Editor Area (Monaco)                                      │
│  - Side Bar (File Explorer)                                  │
│  - Status Bar                                                │
│  - Title Bar / Menu Bar                                      │
│  - Tabs (Editor Groups)                                      │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│           VSCode Platform Services                           │
│  - File Service                                              │
│  - Configuration Service                                     │
│  - Keybinding Service                                        │
│  - Theme Service                                             │
│  - Extension Service                                         │
│  - Language Service                                          │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│              Monaco Editor (Core)                            │
│  - Text Model                                                │
│  - Syntax Highlighting                                       │
│  - IntelliSense (básico)                                     │
│  - Multi-cursor                                              │
│  - Find/Replace                                              │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Electron Framework                          │
│  - Main Process (Node.js backend)                           │
│  - Renderer Process (Chromium frontend)                     │
│  - IPC Communication                                         │
│  - Native APIs (filesystem, OS integration)                 │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│               Operating System                               │
│  Windows 10/11 | macOS 10.15+ | Linux (Ubuntu, etc)        │
└─────────────────────────────────────────────────────────────┘
```

### Fluxo de Dados

```
User Input → Electron (Main Process) → VSCode Workbench → Monaco Editor
                                              ↓
                                    VSCode Services
                                    (Theme, Config, File)
                                              ↓
                                    File System / Storage
```

---

## 🔧 Stack Tecnológica

### Core

| Tecnologia | Versão | Uso no mini | Observações |
|------------|--------|-------------|-------------|
| **Node.js** | v25 | Runtime JavaScript/TypeScript | LTS, atualizado |
| **TypeScript** | 5.x | Linguagem principal | 100% do código VSCode |
| **Electron** | (integrado VSCode) | Framework desktop | Multiplataforma |
| **Monaco Editor** | (integrado VSCode) | Motor de edição | Core do VSCode |

### Build e Desenvolvimento

| Ferramenta | Versão | Uso no mini |
|------------|--------|-------------|
| **npm** | 11.6.2 | Package manager |
| **gulp** | (VSCode) | Task runner, builds |
| **webpack** | (VSCode) | Bundling |
| **eslint** | (VSCode) | Linting TypeScript |
| **mocha** | (VSCode) | Testes unitários |

### Dependências Principais (herdadas do VSCode)

```
{
  "@vscode/ripgrep": "^1.x",
  "vscode-languageclient": "^9.x",
  "vscode-languageserver": "^9.x",
  "iconv-lite-umd": "^0.x",
  "jschardet": "^3.x",
  "minimist": "^1.x",
  "native-keymap": "^3.x",
  "native-watchdog": "^1.x",
  "node-pty": "^1.x",
  "spdlog": "^0.x",
  "vscode-proxy-agent": "^0.x",
  "vscode-regexpp": "^3.x"
}
```

**Nota:** Não adicionamos dependências externas desnecessariamente. VSCode já tem tudo que precisamos.

---

## 📁 Estrutura de Código

### Estrutura de Pastas Principal

```
D:\proj\mini\
├── project-mini\                    # 📁 Documentação do mini
│   ├── prompts\                     # Prompts de desenvolvimento
│   ├── reports\                     # Relatórios de execução
│   ├── specifications\              # Especificações (este arquivo)
│   ├── tests\                       # Testes customizados do mini
│   ├── scripts\                     # Scripts utilitários do mini
│   └── PROJECT-CONTEXT.md           # Contexto completo do projeto
│
├── src\                             # 📁 Código-fonte do VSCode
│   ├── vs\                          # Namespace principal do VSCode
│   │   ├── base\                    # Utilitários fundamentais
│   │   │   ├── common\              # Code comum (platform-agnostic)
│   │   │   ├── browser\             # Code específico de browser
│   │   │   ├── node\                # Code específico de Node.js
│   │   │   └── test\                # Testes base
│   │   │
│   │   ├── platform\                # APIs de plataforma
│   │   │   ├── files\               # File system
│   │   │   ├── configuration\       # Settings
│   │   │   ├── keybinding\          # Keyboard shortcuts
│   │   │   ├── theme\               # Sistema de temas
│   │   │   └── ...
│   │   │
│   │   ├── editor\                  # Monaco Editor
│   │   │   ├── browser\             # Editor UI
│   │   │   ├── common\              # Editor core
│   │   │   ├── contrib\             # Contribuições (features)
│   │   │   └── standalone\          # Standalone Monaco
│   │   │
│   │   ├── workbench\               # Interface do Workbench
│   │   │   ├── browser\             # Workbench UI (onde customizamos)
│   │   │   ├── common\              # Workbench core
│   │   │   ├── contrib\             # Contribuições (features)
│   │   │   │   ├── files\           # File explorer
│   │   │   │   ├── preferences\     # Settings UI
│   │   │   │   ├── themes\          # Theme picker
│   │   │   │   ├── debug\           # Debugger (remover)
│   │   │   │   ├── scm\             # Git integration (simplificar)
│   │   │   │   └── terminal\        # Terminal (remover/simplificar)
│   │   │   └── services\            # Serviços do workbench
│   │   │
│   │   └── code\                    # Entry points da aplicação
│   │       ├── electron-main\       # Main process (Electron)
│   │       ├── electron-sandbox\    # Renderer process
│   │       └── node\                # Node.js APIs
│   │
│   └── typings\                     # Type definitions
│
├── extensions\                      # 📁 Extensões do VSCode
│   ├── theme-defaults\              # Temas padrão do VSCode
│   ├── theme-moleskine\             # 🎨 Tema Moleskine (a criar)
│   ├── markdown-basics\             # Suporte Markdown
│   ├── json-language-features\      # Suporte JSON
│   └── ...
│
├── build\                           # 📁 Scripts de build
│   ├── lib\                         # Bibliotecas de build
│   ├── gulpfile.js                  # Tarefas gulp
│   └── ...
│
├── scripts\                         # 📁 Scripts utilitários
│   ├── code.bat                     # Executar no Windows
│   ├── code.sh                      # Executar no Linux/Mac
│   ├── test.bat                     # Testes (Windows)
│   └── ...
│
├── product.json                     # ⚙️ Configuração do produto (CUSTOMIZADO)
├── package.json                     # Dependências npm
├── tsconfig.json                    # Configuração TypeScript
├── .cursorrules                     # Regras para Cursor IDE
├── .gitignore
├── .eslintrc.json
├── LICENSE
└── README.md
```

### Áreas de Customização do mini

**Onde NÃO mexer (código core do VSCode):**
- ❌ `src/vs/base/` - Utilitários fundamentais
- ❌ `src/vs/editor/` - Monaco Editor (apenas usar)
- ❌ `src/vs/platform/` - APIs de plataforma (apenas usar)

**Onde mexer (customizações do mini):**
- ✅ `product.json` - Branding, configurações
- ✅ `extensions/theme-moleskine/` - Tema customizado
- ✅ `src/vs/workbench/contrib/` - Remover features desnecessárias
- ✅ `src/vs/workbench/browser/` - Ajustes de UI
- ✅ CSS overrides quando necessário

---

## 🧩 Componentes Principais

### 1. Monaco Editor (Core)

**Localização:** `src/vs/editor/`

**Responsabilidade:** Motor de edição de texto

**Features Principais:**
- Syntax highlighting
- IntelliSense básico
- Multi-cursor
- Find/Replace
- Code folding
- Minimap
- Diff editor

**Customizações no mini:**
- ✅ Tema Moleskine aplicado via API
- ✅ Fontes customizadas por extensão
- ✅ Configurações minimalistas (sem features avançadas)

**API Exemplo:**
```
import * as monaco from 'monaco-editor';

// Definir tema Moleskine
monaco.editor.defineTheme('moleskine-light', {
  base: 'vs',
  inherit: true,
  rules: [/* ... */],
  colors: {
    'editor.background': '#F6EEE3',
    'editor.foreground': '#2C2416',
    // ...
  }
});

// Aplicar tema
monaco.editor.setTheme('moleskine-light');
```

---

### 2. Workbench (Interface)

**Localização:** `src/vs/workbench/`

**Responsabilidade:** Interface principal do editor

**Áreas Principais:**

#### a) Editor Area
- Container do Monaco Editor
- Sistema de abas (Editor Groups)
- Split view (horizontal/vertical)

#### b) Side Bar (Painel Lateral)
- File Explorer (árvore de arquivos)
- Search
- Extensions (desabilitar no mini?)
- **Customização mini:** Simplificar, manter apenas File Explorer

#### c) Status Bar (Barra de Status)
- Informações do arquivo (encoding, linha/coluna)
- Status de sincronização (futuro)
- Toggle de textura de papel (mini feature)
- **Customização mini:** Simplificar, remover Git status

#### d) Menu Bar / Title Bar
- File, Edit, View, Window, Help
- **Customização mini:** Simplificar menus, remover opções de IDE

---

### 3. Platform Services

**Localização:** `src/vs/platform/`

**Serviços Principais Usados no mini:**

#### File Service
- Ler/escrever arquivos
- Watch de mudanças
- File system abstraction

#### Configuration Service
- Gerenciar settings do mini
- Persistir configurações do usuário
- Fontes por extensão, tema, etc

#### Keybinding Service
- Shortcuts de teclado
- Customizações de teclas

#### Theme Service
- Carregar/aplicar temas
- Tema Moleskine integrado aqui

#### Extension Service
- Carregar extensões
- Open VSX integration

---

### 4. Electron Integration

**Localização:** `src/vs/code/electron-main/` e `src/vs/code/electron-sandbox/`

**Responsabilidade:** Integração com Electron (desktop)

**Main Process (Node.js):**
- Gerenciar janelas
- File system nativo
- Menu nativo
- Notificações

**Renderer Process (Chromium):**
- UI (HTML/CSS/JS)
- Monaco Editor
- Workbench

**IPC (Inter-Process Communication):**
- Comunicação Main ↔ Renderer
- VSCode usa IPC para operações seguras

**Customizações mini:**
- ✅ Janela customizada (tamanho, ícone)
- ✅ Menu nativo simplificado
- ✅ Splash screen com logo mini (futuro)

---

## 🎨 Customizações do mini

### 1. Branding (`product.json`)

**Arquivo:** `D:\proj\mini\product.json`

**Customizações Aplicadas:**

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

  "licenseUrl": "https://github.com/eduardoalcantara/mini-editor/blob/main/LICENSE",
  "reportIssueUrl": "https://github.com/eduardoalcantara/mini-editor/issues/new",
  "urlProtocol": "mini",

  "extensionsGallery": {
    "serviceUrl": "https://open-vsx.org/vscode/gallery",
    "itemUrl": "https://open-vsx.org/vscode/item"
  },

  "enableTelemetry": false,
  "quality": "stable"
}
```

**Impacto:**
- ✅ Nome "mini" em toda aplicação
- ✅ Pasta de configurações: `~/.mini/` (não `~/.vscode/`)
- ✅ Telemetria desabilitada
- ✅ Marketplace Open VSX (legal e open source)
- ✅ URLs apontam para repo do mini

---

### 2. Remoção de Features de IDE

**Features a Remover:**

| Feature | Localização | Estratégia de Remoção |
|---------|-------------|----------------------|
| **Debugger** | `src/vs/workbench/contrib/debug/` | Remover contribuição do workbench |
| **Terminal Integrado** | `src/vs/workbench/contrib/terminal/` | Remover ou simplificar muito |
| **Git Avançado** | `src/vs/workbench/contrib/scm/` | Manter básico (status, diff visual) |
| **Extensions View** | `src/vs/workbench/contrib/extensions/` | Remover UI (instalar via Open VSX manual) |
| **Remote Development** | `src/vs/workbench/contrib/remote/` | Remover completamente |
| **Live Share** | Extensão | Não instalar |
| **Copilot** | Extensão | Não instalar |

**Estratégia:**
1. Comentar registros de contribuições em `workbench.contributions.ts`
2. Remover entradas de menu relacionadas
3. Remover comandos não usados
4. Testes de regressão

**Exemplo de Remoção:**
```
// src/vs/workbench/workbench.contributions.ts

// ANTES (VSCode)
import 'vs/workbench/contrib/debug/browser/debug.contribution';
import 'vs/workbench/contrib/terminal/browser/terminal.contribution';

// DEPOIS (mini)
// import 'vs/workbench/contrib/debug/browser/debug.contribution'; // REMOVIDO - IDE feature
// import 'vs/workbench/contrib/terminal/browser/terminal.contribution'; // REMOVIDO - IDE feature
```

---

### 3. Simplificação da UI

**Ajustes Planejados:**

#### Barra de Status
- ❌ Remover: Git status, branch info
- ❌ Remover: Problemas/warnings (IDE feature)
- ❌ Remover: Seleção de linguagem (simplificar)
- ✅ Manter: Encoding, linha/coluna, caminho do arquivo
- ✅ Adicionar: Toggle de textura de papel (mini feature)

#### Split Bar (Divisor de Painéis)
- Reduzir largura: 1-2px (minimalista)
- Hover: 3-4px com cor azul (`#3484F7`)
- Transição suave: 150ms

#### Barra de Abas
- Altura: ~36px
- Close button: Visível apenas ao hover
- Aba ativa: Highlight suave

#### Painel Lateral
- Largura: 240-320px
- Modo: Fixo (no futuro: hover/oculto)
- Duas linhas por item: Nome + caminho

---

## 🎨 Sistema de Temas

### Arquitetura de Temas no VSCode

VSCode usa arquivos JSON para definir temas:

```
{
  "name": "Moleskine Light",
  "type": "light",
  "colors": {
    "editor.background": "#F6EEE3",
    "editor.foreground": "#2C2416",
    "statusBar.background": "#F6EEE3",
    "titleBar.activeBackground": "#F6EEE3",
    // ... 300+ tokens
  },
  "tokenColors": [
    {
      "scope": "comment",
      "settings": {
        "foreground": "#6B5E4F",
        "fontStyle": "italic"
      }
    },
    // ...
  ]
}
```

### Tema Moleskine Light (mini)

**Localização:** `extensions/theme-moleskine/themes/moleskine-light.json`

**Estrutura:**
```
extensions/
└── theme-moleskine/
    ├── package.json              # Manifest da extensão
    ├── themes/
    │   ├── moleskine-light.json  # Tema claro
    │   └── moleskine-dark.json   # (futuro) Tema escuro
    ├── icons/
    │   └── icon.png
    └── README.md
```

**package.json:**
```
{
  "name": "theme-moleskine",
  "displayName": "Moleskine Theme",
  "description": "Minimalist theme inspired by Moleskine notebooks",
  "version": "1.0.0",
  "publisher": "mini",
  "engines": {
    "vscode": "^1.80.0"
  },
  "categories": ["Themes"],
  "contributes": {
    "themes": [
      {
        "label": "Moleskine Light",
        "uiTheme": "vs",
        "path": "./themes/moleskine-light.json"
      }
    ]
  }
}
```

**Paleta de Cores:**
- **Fundo:** `#F6EEE3` (Moleskine Ivory)
- **Texto:** `#2C2416` (marrom escuro)
- **Secundário:** `#6B5E4F` (marrom médio)
- **Bordas:** `#E5DDD0` (bege suave)
- **Acentos:** `#3484F7` (azul suave)

**Feature Especial: Textura de Papel**

CSS overlay aplicado via configuração:
```
.monaco-editor .overflow-guard::before {
  content: "";
  position: absolute;
  top: 0; left: 0; right: 0; bottom: 0;
  pointer-events: none;
  opacity: 0;
  background-image:
    repeating-linear-gradient(
      0deg,
      transparent,
      transparent 2px,
      rgba(44, 36, 22, 0.02) 2px,
      rgba(44, 36, 22, 0.02) 4px
    );
  transition: opacity 200ms ease;
}

.monaco-editor.paper-texture .overflow-guard::before {
  opacity: 1;
}
```

---

## 🔌 Extensões

### Open VSX Registry

**URL:** https://open-vsx.org/

**Configuração:** Já aplicada em `product.json`

**Temas Disponíveis (~70% dos populares):**
- GitHub themes ✅
- Dracula ✅
- One Dark Pro ✅
- Material Theme ✅
- Nord ✅
- Monokai ✅

**Instalação Manual (.vsix):**

Usuário pode baixar `.vsix` do Microsoft Marketplace e instalar manualmente:
```
mini --install-extension theme.vsix
```

### Extensões Incluídas no mini

**Built-in (vêm com VSCode):**
- `markdown-basics` - Syntax highlighting Markdown
- `json-language-features` - JSON IntelliSense
- `html-language-features` - HTML básico
- `css-language-features` - CSS básico

**Customizadas (mini):**
- `theme-moleskine` - Tema Moleskine Light

**Não Incluir:**
- ❌ Debuggers (C#, Python, Java, etc)
- ❌ Live Share
- ❌ Remote Development Pack
- ❌ GitHub Copilot

---

## 🔨 Build e Deploy

### Comandos de Build

#### Desenvolvimento
```
# Instalar dependências
npm install

# Compilar TypeScript em modo watch
npm run watch
# ou
npm run watch-client  # Apenas renderer
npm run watch-extensions  # Apenas extensões

# Executar mini local
.\scripts\code.bat

# Executar com extensões de desenvolvimento
.\scripts\code.bat --extensionDevelopmentPath=D:\proj\mini\extensions\theme-moleskine
```

#### Produção (Windows)
```
# Build completo (x64)
npm run gulp vscode-win32-x64

# Resultado em: ..\VSCode-win32-x64\
# Arquivo executável: Code.exe (renomear para mini.exe)

# Criar instalador (.exe)
npm run gulp vscode-win32-x64-inno-updater
# Requer Inno Setup instalado
```

#### Produção (macOS)
```
npm run gulp vscode-darwin-x64

# Resultado: .app bundle
```

#### Produção (Linux)
```
npm run gulp vscode-linux-x64

# Gerar .deb
npm run gulp vscode-linux-x64-build-deb

# Gerar .rpm
npm run gulp vscode-linux-x64-build-rpm

# Gerar AppImage
npm run gulp vscode-linux-x64-build-appimage
```

### Pipeline de CI/CD (Futuro)

**GitHub Actions:**
```
name: Build mini
on:
  push:
    tags:
      - 'v*'

jobs:
  build:
    strategy:
      matrix:
        os: [windows-latest, macos-latest, ubuntu-latest]
    runs-on: ${{ matrix.os }}
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-node@v3
        with:
          node-version: '25'
      - run: npm install
      - run: npm run compile
      - run: npm run gulp vscode-${{ matrix.os }}-x64
      # Upload artifacts...
```

---

## ⚡ Performance e Otimização

### Estratégias Herdadas do VSCode

1. **Lazy Loading:** Módulos carregados sob demanda
2. **Web Workers:** Processamento pesado em threads separadas
3. **Virtual Scrolling:** Renderização eficiente de listas grandes
4. **Caching:** Cache agressivo de operações de I/O
5. **Debouncing/Throttling:** Eventos otimizados

### Otimizações Específicas do mini

1. **Remover features não usadas:**
   - Menos código = menos memória
   - Startup mais rápido

2. **Tema simples:**
   - Moleskine Light é mais leve que temas complexos

3. **Extensões mínimas:**
   - Apenas essenciais instaladas

**Métricas Esperadas:**
- Startup: <2s (em SSD)
- Memória: 150-250 MB (vs 300-500 MB VSCode com extensões)
- Abertura de arquivo: <100ms

---

## 🔒 Segurança

### Telemetria Desabilitada

**Configuração:** `product.json`
```
{
  "enableTelemetry": false
}
```

**Impacto:**
- ✅ Nenhum dado enviado para Microsoft
- ✅ Privacy do usuário respeitada
- ✅ Compliance com GDPR/LGPD

### Atualizações Seguras

**Estratégia:**
1. Monitorar releases do VSCode
2. Merge de updates de segurança (`git merge upstream/main`)
3. Testar extensivamente
4. Release do mini com patches aplicados

### Extensões Verificadas

- Open VSX Registry verifica extensões
- Instalação manual de .vsix requer validação do usuário

---

## 🔄 Manutenção e Atualização

### Sincronização com VSCode Upstream

**Frequência:** Mensal (seguir releases do VSCode)

**Processo:**
```
# 1. Fetch do upstream
git fetch upstream

# 2. Merge (pode ter conflitos)
git merge upstream/main

# 3. Resolver conflitos (manter customizações do mini)
# - product.json: Manter mini
# - Extensões removidas: Manter removidas
# - UI simplificada: Manter simplificada

# 4. Testar build
npm run watch
.\scripts\code.bat

# 5. Commit e push
git commit -m "chore: Sync with VSCode vX.XX.X"
git push origin main
```

### Versionamento

**Esquema:** Semantic Versioning (SemVer)

- **MAJOR.MINOR.PATCH** (ex: 1.2.3)
- **MAJOR:** Mudanças incompatíveis
- **MINOR:** Novas features (compatível)
- **PATCH:** Bug fixes

**Releases:**
- v1.0.0 - Release inicial (MVP)
- v1.1.0 - Tema Moleskine + Textura
- v1.2.0 - Fontes por extensão
- v2.0.0 - Sincronização GDrive/GitHub

---

## 📊 Métricas e Monitoramento

### Métricas de Desenvolvimento

- **Build Time:** <5 min
- **Test Coverage:** >70%
- **Startup Time:** <2s
- **Memory Usage:** <250 MB

### Ferramentas

- **Testes:** Mocha (do VSCode)
- **Coverage:** Istanbul
- **Performance:** Chrome DevTools (Electron)
- **Memory Profiling:** Node.js --inspect

---

## 🗺️ Roadmap Técnico

### v1.0 (MVP) - Dezembro 2024
- ✅ Fork VSCode configurado
- ✅ Branding mini aplicado
- ✅ Telemetria removida
- ⏳ Tema Moleskine Light
- ⏳ UI simplificada
- ⏳ Build de produção

### v1.1 - Janeiro 2025
- Fontes customizadas por extensão
- Toggle de textura de papel
- Ícones SVG modernos
- Instaladores (Windows, macOS, Linux)

### v1.2 - Fevereiro 2025
- Sincronização Google Drive
- Sincronização GitHub
- Backup automático

### v2.0 - Março 2025
- Versão Web (Browser)
- Colaboração em tempo real (opcional)
- Plugins customizados do mini

---

## 📚 Referências Técnicas

### Documentação do VSCode

- **Contributing Guide:** https://github.com/microsoft/vscode/wiki/How-to-Contribute
- **Architecture:** https://github.com/microsoft/vscode/wiki/Code-Organization
- **Extension API:** https://code.visualstudio.com/api
- **Theme Guide:** https://code.visualstudio.com/api/extension-guides/color-theme

### Monaco Editor

- **API Reference:** https://microsoft.github.io/monaco-editor/api/index.html
- **Playground:** https://microsoft.github.io/monaco-editor/playground.html

### Electron

- **Docs:** https://www.electronjs.org/docs/latest/
- **IPC:** https://www.electronjs.org/docs/latest/tutorial/ipc

### TypeScript

- **Handbook:** https://www.typescriptlang.org/docs/handbook/intro.html

---

## 📝 Notas Finais

### Princípios de Desenvolvimento

1. **Não Reinventar a Roda:** Usar o máximo possível do VSCode
2. **Simplicidade:** Remover, não adicionar complexidade
3. **Qualidade:** Testes e code review antes de merge
4. **Documentação:** Código auto-explicativo + comentários quando necessário
5. **Performance:** Medir e otimizar sempre

### Contato Técnico

**Supervisor:** Perplexity AI
**PO:** Eduardo Alcântara

---

**Última Atualização:** 04/12/2025 14:45 -03
**Versão:** 2.0
**Próxima Revisão:** Após Prompt #006 (Tema Moleskine)
