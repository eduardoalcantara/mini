# Ambiente de Desenvolvimento Windows - Projeto mini (Zed Editor)

**Data de Verificação:** 05 de dezembro de 2025
**Sistema Operacional:** Windows 11 (Build 26220)
**Máquina:** SDC-85739
**Usuário:** Eduardo

---

## 📋 Índice

1. [Resumo Executivo](#resumo-executivo)
2. [Ferramentas Essenciais](#ferramentas-essenciais)
3. [Detalhamento de Instalações](#detalhamento-de-instalações)
4. [Estrutura de Diretórios](#estrutura-de-diretórios)
5. [Variáveis de Ambiente](#variáveis-de-ambiente)
6. [Verificação do Ambiente](#verificação-do-ambiente)
7. [Troubleshooting](#troubleshooting)

---

## 📊 Resumo Executivo

### Status Geral: ✅ **AMBIENTE COMPLETO E PRONTO**

Todas as ferramentas necessárias para compilar o Zed Editor estão instaladas e configuradas corretamente nesta máquina.

| Ferramenta | Status | Versão | Localização |
|------------|--------|--------|-------------|
| **Rust Toolchain** | ✅ | 1.90.0 | `C:\Users\Eduardo\.rustup` |
| **Cargo** | ✅ | 1.90.0 | `C:\Users\Eduardo\.cargo` |
| **Visual Studio Build Tools 2022** | ✅ | MSVC 14.44.35207 | `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools` |
| **Bibliotecas Spectre** | ✅ | 14.44-17.14 | `...\MSVC\14.44.35207\lib\spectre` |
| **Windows SDK** | ✅ | 10.0.26100.0 | `C:\Program Files (x86)\Windows Kits\10` |
| **CMake** | ✅ | 3.27.1 | Sistema (PATH) |
| **Git** | ✅ | 2.51.0 | Sistema (PATH) |
| **Node.js** | ✅ | 22.21.0 | `D:\app\dev\nodejs` |

---

## 🛠️ Ferramentas Essenciais

### 1. Rust Toolchain

**Objetivo:** Linguagem de programação principal do Zed Editor (100% do código)

#### Componentes Instalados:

- **rustc** (Compilador Rust)
  - Versão: `1.90.0 (1159e78c4 2025-09-14)`
  - Localização: `C:\Users\Eduardo\.rustup\toolchains\stable-x86_64-pc-windows-msvc\bin\rustc.exe`

- **cargo** (Gerenciador de Pacotes e Build Tool)
  - Versão: `1.90.0 (840b83a10 2025-07-30)`
  - Localização: `C:\Users\Eduardo\.cargo\bin\cargo.exe`

- **rustup** (Gerenciador de Versões Rust)
  - Versão: `1.28.2 (e4f3ad6f8 2025-04-28)`
  - Localização: `C:\Users\Eduardo\.cargo\bin\rustup.exe`

#### Diretórios Importantes:

```
C:\Users\Eduardo\.rustup\        # Toolchains e componentes
C:\Users\Eduardo\.cargo\         # Binários e cache de pacotes
├── bin\                         # Executáveis (cargo, rustc, etc)
├── registry\                    # Cache de crates do crates.io
└── git\                         # Repositórios de dependências
```

#### Verificação:

```cmd
rustc --version
cargo --version
rustup --version
```

---

### 2. Visual Studio Build Tools 2022

**Objetivo:** Compilador C++ (MSVC) e ferramentas de build nativas do Windows

#### Informações de Instalação:

- **Versão:** Visual Studio Build Tools 2022 (17.14)
- **MSVC Toolset:** v143 (14.44.35207)
- **Localização Base:** `C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools`

#### Componentes Instalados:

##### MSVC Compiler (C++)

```
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\
├── bin\                         # Compiladores (cl.exe, link.exe, etc)
│   ├── Hostx64\x64\            # Compilador 64-bit para 64-bit
│   ├── Hostx64\x86\            # Compilador 64-bit para 32-bit
│   ├── Hostx86\x64\            # Compilador 32-bit para 64-bit
│   └── Hostx86\x86\            # Compilador 32-bit para 32-bit
├── lib\                         # Bibliotecas de runtime
│   ├── x64\                    # Bibliotecas 64-bit
│   ├── x86\                    # Bibliotecas 32-bit
│   ├── onecore\                # Bibliotecas OneCore
│   └── spectre\                # ✅ Bibliotecas com mitigação Spectre
│       ├── x64\                #    44 arquivos .lib (incluindo delayimp.lib)
│       └── x86\                #    44 arquivos .lib
└── include\                     # Headers C/C++
```

##### Bibliotecas Spectre (Recém-instaladas)

**Versão:** MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs (14.44-17.14)

**Arquivos Críticos:**
```
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\spectre\x64\
├── delayimp.lib                # ✅ Biblioteca de delay-loading (essencial)
├── libcmt.lib                  # C Runtime Library (static)
├── msvcrt.lib                  # C Runtime Library (dynamic)
├── libvcruntime.lib            # VC Runtime Library
└── ... (40+ arquivos .lib)
```

##### MSBuild

```
C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\MSBuild\Current\
├── Bin\                         # msbuild.exe
└── ...
```

#### ID do Componente Spectre:

```
Microsoft.VisualStudio.Component.VC.14.44.17.14.x86.x64.Spectre
```

#### Verificação:

```cmd
"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
cl
link
```

---

### 3. Windows SDK

**Objetivo:** APIs e bibliotecas do Windows para desenvolvimento nativo

#### Versões Instaladas:

- **10.0.26100.0** (Windows 11 SDK - mais recente) ✅
- **10.0.22621.0** (Windows 11 SDK - compatível) ✅

**Versão Mínima Requerida:** 10.0.20348.0 ✅ Atendido

#### Localização:

```
C:\Program Files (x86)\Windows Kits\10\
├── Include\
│   ├── 10.0.26100.0\           # Headers
│   │   ├── um\                 # User Mode headers
│   │   ├── ucrt\               # Universal C Runtime
│   │   ├── shared\             # Shared headers
│   │   └── winrt\              # Windows Runtime
│   └── 10.0.22621.0\           # Headers (versão alternativa)
├── Lib\
│   ├── 10.0.26100.0\           # Bibliotecas
│   │   ├── um\x64\             # User Mode libs 64-bit
│   │   ├── um\x86\             # User Mode libs 32-bit
│   │   └── ucrt\x64\           # UCRT libs 64-bit
│   └── 10.0.22621.0\           # Bibliotecas (versão alternativa)
└── bin\
    ├── 10.0.26100.0\           # Ferramentas (rc.exe, midl.exe, etc)
    └── 10.0.22621.0\           # Ferramentas (versão alternativa)
```

#### Verificação:

```cmd
dir "C:\Program Files (x86)\Windows Kits\10\Lib" /b
```

---

### 4. CMake

**Objetivo:** Sistema de build cross-platform (requerido por dependências do Zed)

#### Informações:

- **Versão:** 3.27.1
- **Localização:** Sistema (adicionado ao PATH)
- **Instalador:** Kitware (cmake.org)

#### Verificação:

```cmd
cmake --version
```

---

### 5. Git

**Objetivo:** Controle de versão e clone do repositório Zed

#### Informações:

- **Versão:** 2.51.0.windows.1
- **Localização:** Sistema (adicionado ao PATH)

#### Configurações Importantes:

- **Longpaths:** ✅ Habilitado (`core.longpaths = true`)
  - Essencial para repositórios grandes como o Zed
  - Configurado em nível system

#### Verificação:

```cmd
git --version
git config --system core.longpaths
```

#### Habilitar Longpaths (se necessário):

```cmd
git config --system core.longpaths true
```

---

### 6. Node.js (Opcional)

**Objetivo:** Ferramentas de desenvolvimento JavaScript (não essencial para Zed core)

#### Informações:

- **Versão:** 22.21.0
- **Localização:** `D:\app\dev\nodejs\`
- **npm:** Incluído

**Nota:** Node.js **NÃO** é necessário para compilar o Zed Editor (100% Rust), mas pode ser útil para ferramentas auxiliares.

---

## 📂 Estrutura de Diretórios

### Diretórios do Projeto mini (Zed Fork)

```
D:\proj\mini\
├── project-mini\               # Documentação e scripts customizados
│   ├── documents\              # 📄 Esta documentação
│   ├── prompts\                # Tarefas e instruções do supervisor
│   ├── reports\                # Relatórios de execução
│   ├── scripts\                # Scripts de automação
│   │   ├── check-zed-requirements.bat
│   │   └── list-spectre-components.bat
│   ├── specifications\         # Especificações técnicas
│   └── tests\                  # Testes customizados
├── crates\                     # (A criar) Código-fonte do Zed
├── docs\                       # (A criar) Documentação do Zed
├── assets\                     # (A criar) Assets do Zed
├── target\                     # (A criar) Build output
├── Cargo.toml                  # (A criar) Workspace manifest
├── Cargo.lock                  # (A criar) Lockfile
└── .cursorrules                # Regras do projeto
```

---

## 🔧 Variáveis de Ambiente

### PATH (Sistema)

Caminhos relevantes que devem estar no PATH:

```
C:\Users\Eduardo\.cargo\bin                    # cargo, rustc, rustup
C:\Program Files\CMake\bin                     # cmake
C:\Program Files\Git\cmd                       # git
D:\app\dev\nodejs                              # node, npm (opcional)
```

### Variáveis MSVC (Temporárias)

Ao usar o MSVC, execute primeiro:

```cmd
"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
```

Isso configura automaticamente:
- `INCLUDE` - Diretórios de headers
- `LIB` - Diretórios de bibliotecas
- `PATH` - Ferramentas de compilação

### Variáveis Rust

```
CARGO_HOME=C:\Users\Eduardo\.cargo
RUSTUP_HOME=C:\Users\Eduardo\.rustup
```

---

## ✅ Verificação do Ambiente

### Script Automatizado

Execute o script de verificação completo:

```cmd
D:\proj\mini\project-mini\scripts\check-zed-requirements.bat
```

### Verificação Manual

#### 1. Rust Toolchain

```cmd
rustc --version
# Esperado: rustc 1.90.0 (1159e78c4 2025-09-14)

cargo --version
# Esperado: cargo 1.90.0 (840b83a10 2025-07-30)

rustup --version
# Esperado: rustup 1.28.2 (e4f3ad6f8 2025-04-28)
```

#### 2. Visual Studio Build Tools

```cmd
dir "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC" /b
# Esperado: 14.44.35207

dir "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\MSVC\14.44.35207\lib\spectre\x64\*.lib" /b | find /c ".lib"
# Esperado: 44
```

#### 3. Windows SDK

```cmd
dir "C:\Program Files (x86)\Windows Kits\10\Lib" /b
# Esperado: 10.0.22621.0 e 10.0.26100.0
```

#### 4. CMake

```cmd
cmake --version
# Esperado: cmake version 3.27.1
```

#### 5. Git

```cmd
git --version
# Esperado: git version 2.51.0.windows.1

git config --system core.longpaths
# Esperado: true
```

---

## 🚀 Próximos Passos

### 1. Clonar o Repositório Zed

```cmd
cd D:\proj\mini
git clone https://github.com/zed-industries/zed.git .
```

### 2. Compilar em Modo Debug

```cmd
cargo build
```

### 3. Executar o Editor

```cmd
cargo run
```

### 4. Compilar em Modo Release (Otimizado)

```cmd
cargo build --release
cargo run --release
```

### 5. Executar Testes

```cmd
cargo test --workspace
```

---

## 🐛 Troubleshooting

### Problema: `error: linker 'link.exe' not found`

**Solução:** Inicie o Developer Command Prompt ou execute:

```cmd
"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Auxiliary\Build\vcvarsall.bat" x64
```

### Problema: `LNK1181: cannot open input file 'DelayImp.lib'`

**Solução:** Instale as bibliotecas Spectre (já instalado nesta máquina ✅)

### Problema: `cargo build` falha com erros de Windows SDK

**Solução:** Verifique se a versão mínima do SDK está instalada:

```cmd
dir "C:\Program Files (x86)\Windows Kits\10\Lib\10.0.20348.0"
```

Se não existir, instale via:
- Visual Studio Installer → Componentes Individuais → Windows 10 SDK (10.0.20348.0)

### Problema: `error: failed to get 'pet' as a dependency` (path too long)

**Solução:** Habilite longpaths (já habilitado nesta máquina ✅)

```cmd
git config --system core.longpaths true
```

Ou via PowerShell (como Admin):

```powershell
New-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" -Name "LongPathsEnabled" -Value 1 -PropertyType DWORD -Force
```

**Reinicie o sistema após habilitar.**

### Problema: Build muito lento

**Solução:** Use build incremental e ajuste o número de threads:

```cmd
# Usar 75% dos cores da CPU
cargo build -j 6
```

### Problema: `STATUS_ACCESS_VIOLATION`

**Solução:** Tente usar um linker diferente. Edite `.cargo/config.toml`:

```toml
[target.x86_64-pc-windows-msvc]
linker = "lld-link.exe"
```

---

## 📚 Referências

### Documentação Oficial

- [Building Zed for Windows](https://github.com/zed-industries/zed/blob/main/docs/src/development/windows.md)
- [Rust Installation Guide](https://www.rust-lang.org/tools/install)
- [Visual Studio Build Tools](https://visualstudio.microsoft.com/visual-cpp-build-tools/)
- [Windows SDK Archive](https://developer.microsoft.com/windows/downloads/windows-sdk/)

### Componentes VS Installer

Para exportar sua configuração atual do VS Installer:

1. Abra o Visual Studio Installer
2. Clique em "More" → "Export configuration"
3. Salve o arquivo `.vsconfig`

### Scripts de Verificação

- `D:\proj\mini\project-mini\scripts\check-zed-requirements.bat` - Verificação completa
- `D:\proj\mini\project-mini\scripts\list-spectre-components.bat` - Lista componentes Spectre

---

## 📝 Histórico de Mudanças

| Data | Mudança | Detalhes |
|------|---------|----------|
| 2025-12-05 | ✅ Instalação Bibliotecas Spectre | MSVC v143 14.44-17.14 x64/x86 |
| 2025-12-05 | ✅ Habilitação Git Longpaths | `core.longpaths = true` |
| 2025-12-05 | ✅ Verificação Completa do Ambiente | Todos os requisitos atendidos |
| 2025-12-05 | 📄 Criação desta Documentação | Ambiente-de-Desenvolvimento-Windows.md |

---

## 📞 Contato e Suporte

**Projeto:** mini (Minimalist, Intelligent, Nice Interface)
**Base:** Fork do Zed Editor (https://github.com/zed-industries/zed)
**PO:** Eduardo
**Supervisor:** Perplexity AI
**Agente de Desenvolvimento:** Claude 3.5 Sonnet (Cursor IDE)

---

**Última Atualização:** 05 de dezembro de 2025, 20:45
**Status do Ambiente:** ✅ **COMPLETO E PRONTO PARA COMPILAÇÃO**
