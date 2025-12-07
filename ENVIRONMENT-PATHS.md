# Ambiente de Desenvolvimento - Caminhos Absolutos

**Data:** 04/12/2025
**Sistema:** Windows 11 (Build 26220)
**Projeto:** mini - Editor de Texto Minimalista

---

## 📁 Projeto

**Diretório Raiz:**
```
D:\proj\mini\
```

**Estrutura Principal:**
```
D:\proj\mini\src\              # Código-fonte TypeScript do VSCode
D:\proj\mini\build\            # Scripts de build
D:\proj\mini\extensions\       # Extensões do VSCode
D:\proj\mini\project-mini\     # Documentação e specs do mini
D:\proj\mini\node_modules\     # Dependências npm
```

---

## 🛠️ Ferramentas de Desenvolvimento

### Node.js
**Versão Requerida:** v22.20.0 (especificado em `.nvmrc`)
**Versão Instalada:** v22.20.0
**Executável:**
```
D:\app\dev\nodejs\node.exe
```

**npm:**
```
Versão: 10.9.3
D:\app\dev\nvm\v22.20.0\node_modules\npm\
```

**nvm (Node Version Manager):**
```
D:\app\dev\nvm\
```

---

### Python
**Versão:** 3.14.0
**Executável:**
```
C:\Users\Eduardo\AppData\Local\Python\pythoncore-3.14-64\python.exe
```

---

### Git
**Versão:** 2.51.0.windows.1
**Executável:**
```
C:\Program Files\Git\cmd\git.exe
```

---

## 🏗️ Visual Studio 2022 Build Tools

### Instalação Principal
**Path:**
```
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\
```

### MSVC (Microsoft Visual C++)
**Versões Instaladas:**
- v143 (14.44.35207) - Atual
- v143 (14.38.33130) - Legado

**MSVC v143 (14.44.35207) - Paths:**
```
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\bin\
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\x64\
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\x86\
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\spectre\x64\
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\spectre\x86\
```

**Bibliotecas Importantes:**
```
DelayImp.lib (x64): C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\x64\delayimp.lib
DelayImp.lib (x86): C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\x86\delayimp.lib
```

### MSBuild
**Path:**
```
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\Bin\MSBuild.exe
```

### Visual Studio Installer
**Path:**
```
C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe
C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe
```

---

## 📦 Windows SDK

**Versões Instaladas:**
- 10.0.19041.0 (Windows 10)
- 10.0.22621.0 (Windows 11)
- 10.0.26100.0 (Windows 11 - mais recente)

**Path Base:**
```
C:\Program Files (x86)\Windows Kits\10\
```

**Bibliotecas (x64):**
```
C:\Program Files (x86)\Windows Kits\10\Lib\10.0.22621.0\um\x64\
C:\Program Files (x86)\Windows Kits\10\Lib\10.0.26100.0\um\x64\
```

**Headers:**
```
C:\Program Files (x86)\Windows Kits\10\Include\10.0.22621.0\
C:\Program Files (x86)\Windows Kits\10\Include\10.0.26100.0\
```

---

## 🔧 Componentes Instalados (VS 2022 BuildTools)

### Ferramentas de Build
- ✅ MSVC v143 - Ferramentas de compilação VS 2022 C++ (v14.44)
- ✅ Bibliotecas com mitigação de Spectre (x64/x86)
- ✅ ATL do C++ para v143
- ✅ Windows 11 SDK (10.0.26100.6901)
- ✅ Windows 11 SDK (10.0.22621.0)
- ✅ Ferramentas do CMake
- ✅ AddressSanitizer do C++
- ✅ vcpkg package manager

### Cargas de Trabalho
- ✅ Desenvolvimento para desktop com C++ (parcial)

---

## 📝 Caches e Temporários

### node-gyp Cache
```
C:\Users\Eduardo\AppData\Local\node-gyp\Cache\
```

**Versões em Cache:**
- Electron v39.2.3
- Node.js v22.20.0
- Node.js v22.21.1

### npm Cache
```
C:\Users\Eduardo\AppData\Local\npm-cache\
```

**Logs:**
```
C:\Users\Eduardo\AppData\Local\npm-cache\_logs\
```

---

## 🚀 Scripts do Projeto

### Build Scripts (VSCode)
```
D:\proj\mini\scripts\code.bat           # Executar editor local (Windows)
D:\proj\mini\scripts\code.sh            # Executar editor local (Linux/Mac)
D:\proj\mini\scripts\test.bat           # Executar testes
```

### Custom Scripts (mini)
```
D:\proj\mini\project-mini\scripts\      # Scripts customizados do mini
```

---

## ⚙️ Configurações npm (projeto)

**Arquivo:**
```
D:\proj\mini\.npmrc
```

**Configurações:**
```
disturl="https://electronjs.org/headers"
target="39.2.3"
ms_build_id="12869810"
runtime="electron"
build_from_source="true"
legacy-peer-deps="true"
timeout=180000
```

---

## 📊 Versões de Dependências Principais

### Electron
**Versão:** 39.2.3
**Headers:** https://electronjs.org/headers/v39.2.3/

### TypeScript
**Versão:** (instalado via npm, verificar package.json)

### Monaco Editor
**Versão:** Integrado no VSCode

---

## 🔍 Comandos Úteis de Verificação

### Verificar Versões
```powershell
# Node.js
node --version

# npm
npm --version

# Python
python --version

# Git
git --version

# MSVC (Visual Studio)
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -version "[17.0,18.0)" -products * -property productDisplayVersion
```

### Verificar Componentes VS
```powershell
# Listar produtos VS instalados
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -products * -property displayName

# Verificar MSVC instalado
Get-ChildItem "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC" | Select-Object Name

# Verificar Windows SDK
Get-ChildItem "C:\Program Files (x86)\Windows Kits\10\Lib" | Select-Object Name
```

### Verificar Bibliotecas
```powershell
# Verificar DelayImp.lib
Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\x64\delayimp.lib"

# Verificar bibliotecas Spectre
Test-Path "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\spectre"
```

---

## 🐧 WSL (Windows Subsystem for Linux)

**Distribuição:** Ubuntu 22.04 LTS
**Acesso ao projeto:**
```bash
cd /mnt/d/proj/mini
```

**Node.js (via nvm):**
```bash
# nvm instalado em: ~/.nvm
# Node.js v22.20.0: ~/.nvm/versions/node/v22.20.0/bin/node
# npm: ~/.nvm/versions/node/v22.20.0/bin/npm
```

**Verificar versões:**
```bash
node --version  # v22.20.0
npm --version   # 10.9.0
```

**Comandos de Build no WSL:**
```bash
# Instalar dependências
npm install --legacy-peer-deps

# Instalar dependências de extensões
node build/npm/postinstall.ts

# Compilar projeto
npm run compile

# Compilar em modo watch
npm run watch
```

**Vantagens do WSL:**
- ✅ `node-gyp` funciona perfeitamente (detecta ferramentas automaticamente)
- ✅ Compilação mais rápida
- ✅ Não precisa configurar Visual Studio Build Tools manualmente
- ✅ Ambiente Linux nativo para builds
- ✅ Código compilado funciona no Windows (é JavaScript)

---

## 🐛 Problemas Conhecidos e Soluções

### Problema 1: Bibliotecas Spectre Ausentes
**Erro:** `MSB8040: as bibliotecas com Mitigações de Spectre são necessárias`
**Solução:** Instalar componente via VS Installer:
```
Microsoft.VisualStudio.Component.VC.14.44.17.12.x86.x64.Spectre
```
**Status:** ✅ Resolvido

### Problema 2: Node.js Incompatível
**Erro:** `C++20 or later required`
**Causa:** Node.js v25+ exige C++20
**Solução:** Usar Node.js v22.20.0 (LTS)
**Status:** ✅ Resolvido

### Problema 3: DelayImp.lib não encontrado (node-gyp no Windows)
**Erro:** `LNK1181: não foi possível abrir o arquivo de entrada 'DelayImp.lib'`
**Causa:** `node-gyp` no Windows não consegue detectar o Windows SDK corretamente, mesmo com todas as ferramentas instaladas

**Soluções TENTADAS (não funcionaram no Windows):**
- ❌ Instalar carga de trabalho "Desenvolvimento para desktop com C++" completa
- ❌ Configurar variáveis de ambiente LIB/INCLUDE manualmente
- ❌ Usar vcvarsall.bat / VsDevCmd.bat para inicializar ambiente
- ❌ Instalar componentes individuais (SDK, Spectre, ATL)
- ❌ Copiar delayimp.lib manualmente para pastas do Windows SDK
- ❌ Reiniciar o PC após instalação completa
- ❌ Limpar caches npm/node-gyp

**Solução DEFINITIVA:**
✅ **Usar WSL (Windows Subsystem for Linux) com Ubuntu**

**Ambiente WSL:**
```bash
# Instalar nvm
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.0/install.sh | bash

# Instalar Node.js v22.20.0
nvm install 22.20.0
nvm use 22.20.0

# Navegar para projeto (montado em /mnt/d/proj/mini)
cd /mnt/d/proj/mini

# Instalar dependências (sem problemas de node-gyp!)
npm install --legacy-peer-deps

# Instalar dependências de extensões
node build/npm/postinstall.ts

# Compilar projeto
npm run compile
```

**Status:** ✅ **RESOLVIDO COM WSL**

**Resultado:**
- Compilação TypeScript completa em 5.75 minutos
- 0 erros de compilação
- `out/main.js` gerado com sucesso (49KB)
- Todas as extensões compiladas sem erros

**Observação:** O editor compilado no WSL pode ser executado normalmente no Windows usando `.\project-mini\scripts\code.bat`, pois o código compilado (JavaScript) é multiplataforma

---

## 📚 Referências

**Documentação do Projeto:**
```
D:\proj\mini\.cursorrules
D:\proj\mini\PROJECT-CONTEXT.md
D:\proj\mini\project-mini\specifications\
D:\proj\mini\project-mini\prompts\
D:\proj\mini\project-mini\reports\
```

**Documentação Externa:**
- VSCode Build: https://github.com/microsoft/vscode/wiki/How-to-Contribute
- Node.js: https://nodejs.org/
- Visual Studio Build Tools: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022

---

**Última Atualização:** 04/12/2025
**Mantido por:** Equipe de Desenvolvimento mini (Eduardo + AI Agents)
