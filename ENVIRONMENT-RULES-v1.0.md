# SPEC: Ambiente de Desenvolvimento

**Autor:** Perplexity (Arquiteto/Supervisor IA)
**Data:** 2026-04-10
**Versão:** 1.0
**Projeto:** Editor Minimalista

---

## Visão Geral

Este documento especifica todas as ferramentas, runtimes, compiladores e dependências necessárias para desenvolver, compilar e distribuir o aplicativo em todas as plataformas suportadas. Toda a equipe e o Cursor IDE devem ter o ambiente configurado conforme esta spec antes de iniciar qualquer implementação.

---

## Plataformas Suportadas

| Plataforma | Versão mínima | Arquitetura |
|---|---|---|
| **Windows** | 10 / 11 | AMD64, ARM64 |
| **macOS** | 10.15 (Catalina) para dev; 10.13 para release | AMD64 |
| **macOS** | 11.0 (Big Sur) | ARM64 (Apple Silicon) |
| **Linux** | Qualquer distro moderna com WebKitGTK | AMD64, ARM64 |

---

## Ferramentas Obrigatórias

### 1. Go

| Item | Valor |
|---|---|
| **Versão mínima** | 1.21 |
| **Versão recomendada** | 1.22+ (estável atual) |
| **Download** | https://go.dev/dl/ |
| **Verificação** | `go version` |

O Wails v2 exige Go 1.21+ como mínimo absoluto. Em macOS 15+, o mínimo sobe para Go 1.23.3+. Usar sempre a versão estável mais recente do canal `stable`.

Configuração obrigatória pós-instalação:
```bash
# Verificar que GOPATH e GOBIN estão no PATH
go env GOPATH
go env GOBIN

# Adicionar ao PATH (Linux/macOS — ~/.bashrc ou ~/.zshrc)
export PATH=$PATH:$(go env GOPATH)/bin
```

---

### 2. Wails CLI v2

| Item | Valor |
|---|---|
| **Versão** | v2 (latest) |
| **Instalação** | `go install github.com/wailsapp/wails/v2/cmd/wails@latest` |
| **Verificação** | `wails version` |
| **Diagnóstico** | `wails doctor` |

O comando `wails doctor` verifica automaticamente se todas as dependências de plataforma estão instaladas corretamente. **Executar obrigatoriamente após instalar o Wails** e antes de iniciar qualquer trabalho no projeto.

---

### 3. Node.js + pnpm

| Item | Valor |
|---|---|
| **Node.js — versão mínima** | 18 (requisito do pnpm 10) |
| **Node.js — versão recomendada** | 22.x LTS ("Jod") |
| **Node.js — download** | https://nodejs.org/en/download |
| **Node.js — verificação** | `node --version` |
| **pnpm — versão recomendada** | 10.x (latest — 10.33.0 em março 2026) |
| **pnpm — instalação** | `npm install -g pnpm` ou `corepack enable pnpm` |
| **pnpm — verificação** | `pnpm --version` |
| **pnpm — atualização** | `pnpm self-update` |

Node.js é necessário exclusivamente para o pipeline de build do frontend (Wails usa internamente para empacotar os assets). Não é um runtime do produto final.

**Por que pnpm em vez de npm:**
- Armazenamento content-addressable: pacotes compartilhados entre projetos via hard links — economia significativa de disco
- Instalação mais rápida que npm e yarn
- Lockfile (`pnpm-lock.yaml`) mais determinístico
- Compatibilidade total com o ecossistema npm

Configuração obrigatória na raiz do projeto (`package.json`):
```json
{
  "packageManager": "pnpm@10.33.0"
}
```

> ⚠️ Node.js 20.x entra em fim de vida em **30 de abril de 2026**. Não usar Node 20 em ambientes novos.
> ⚠️ pnpm 9.x entra em fim de vida em **30 de abril de 2026**. Usar somente pnpm 10.x.

---

### 4. Git

| Item | Valor |
|---|---|
| **Versão mínima** | 2.25 |
| **Versão recomendada** | 2.40+ |
| **Download** | https://git-scm.com/downloads |
| **Verificação** | `git --version` |

Configuração obrigatória:
```bash
git config --global user.name "Seu Nome"
git config --global user.email "seu@email.com"
git config --global core.autocrlf false   # Importante no Windows
```

---

### 5. golangci-lint

| Item | Valor |
|---|---|
| **Versão** | v2.x (latest — v2.11.4 em março 2026) |
| **Instalação** | `go install github.com/golangci/golangci-lint/v2/cmd/golangci-lint@latest` |
| **Verificação** | `golangci-lint --version` |
| **Documentação** | https://golangci-lint.run |

> ⚠️ A versão v2.x tem breaking changes em relação à v1.x (configuração `.golangci.yml` mudou). Não misturar versões entre ambientes.

Arquivo `.golangci.yml` mínimo na raiz do projeto:
```yaml
run:
  timeout: 5m
  go: "1.22"

linters:
  enable:
    - errcheck
    - gosimple
    - govet
    - ineffassign
    - staticcheck
    - unused
    - gofmt
    - goimports

linters-settings:
  gofmt:
    simplify: true
```

---

### 6. CodeMirror 6 (dependência de frontend)

| Item | Valor |
|---|---|
| **Versão** | 6.x (latest — view 6.36.8 em maio 2025) |
| **Pacote principal** | `codemirror` (meta-pacote) |
| **Instalação** | `npm install codemirror @codemirror/state @codemirror/view` |
| **Documentação** | https://codemirror.net |

Pacotes adicionais por funcionalidade (instalar conforme necessidade):
```bash
npm install @codemirror/lang-markdown    # Markdown highlight
npm install @codemirror/lang-javascript  # JS/TS highlight
npm install @codemirror/theme-one-dark   # Tema escuro base
npm install @codemirror/search           # Busca no editor
npm install @codemirror/commands         # Atalhos de teclado padrão
```

---

## Dependências de Plataforma

### Windows

| Dependência | Descrição | Como instalar |
|---|---|---|
| **WebView2 Runtime** | Engine de renderização do frontend no Windows | Incluso no Windows 11. Windows 10: baixar em https://developer.microsoft.com/en-us/microsoft-edge/webview2/ |
| **MSVC Build Tools** | Compilador C necessário para algumas dependências Go | Visual Studio Build Tools 2022 (componente "Desenvolvimento para Desktop com C++") |
| **GCC (opcional)** | Alternativa ao MSVC via MinGW-w64 | https://www.mingw-w64.org/ |

> O Wails no Windows usa o WebView2 nativamente (sem DLL extra). Em máquinas sem WebView2 instalado, o app pode ser configurado para baixar ou embutir o runtime via flag `-webview2 embed` no `wails build`.

---

### macOS

| Dependência | Descrição | Como instalar |
|---|---|---|
| **Xcode Command Line Tools** | Compilador Clang + ferramentas de build | `xcode-select --install` |
| **WKWebView** | Engine de renderização (nativo do macOS) | Incluído no sistema — nenhuma instalação necessária |

---

### Linux

| Dependência | Descrição | Como instalar |
|---|---|---|
| **GCC** | Compilador C | `apt install gcc` / `dnf install gcc` |
| **libgtk-3-dev** | Widgets GTK3 | `apt install libgtk-3-dev` |
| **libwebkit2gtk-4.0-dev** | Engine WebKitGTK | `apt install libwebkit2gtk-4.0-dev` |

> Executar `wails doctor` para obter o comando exato de instalação para a sua distro.

---

## IDEs e Ferramentas Recomendadas

| Ferramenta | Papel | Observação |
|---|---|---|
| **Cursor IDE** | Dev Sênior IA — implementação | Ferramenta oficial do projeto |
| **VS Code** | Alternativa para o PO/humanos | Com extensões Go e ESLint |
| **Extensão Go (vscode-go)** | Suporte Go no editor | `golang.Go` no marketplace |
| **GoDoc** | Documentação inline de APIs Go | `go doc [pacote]` |

---

## Verificação do Ambiente — Checklist

Antes de iniciar qualquer sessão de desenvolvimento, verificar:

```bash
# 1. Go
go version
# Esperado: go version go1.22.x (ou superior)

# 2. Wails
wails version
# Esperado: Wails CLI v2.x.x

# 3. Wails doctor (verifica TODAS as dependências de plataforma)
wails doctor
# Esperado: todos os itens com ✓

# 4. Node.js
node --version
# Esperado: v22.x.x (LTS)

# 5. pnpm
pnpm --version
# Esperado: 10.x.x

# 6. Git
git --version
# Esperado: git version 2.40.x ou superior

# 7. golangci-lint
golangci-lint --version
# Esperado: golangci-lint has version v2.x.x

# 8. Build do projeto (validação final)
wails build
# Esperado: build sem erros
```

---

## Versões em Resumo

| Ferramenta | Mínimo | Recomendado | EOL / Observação |
|---|---|---|---|
| Go | 1.21 | 1.22+ | Usar sempre canal `stable` |
| Wails CLI | v2.x | v2 latest | Não usar v3 alpha ainda |
| Node.js | 15 | 22.x LTS | Não usar 20.x (EOL abr/2026) |
| npm | 7 | 10.x | Incluído com Node.js 22 |
| Git | 2.25 | 2.40+ | — |
| golangci-lint | v2.0 | v2.11+ | Não misturar com v1.x |
| CodeMirror | 6.0 | 6.36+ | Usar pacotes `@codemirror/*` |
| WebView2 (Windows) | Qualquer | Runtime atual | Embutir no build para distribuição |

---

## Notas de Atualização

- Este documento deve ser revisado sempre que uma dependência principal mudar de versão major.
- O responsável pela atualização é o **Arquiteto/Supervisor (Perplexity)**, com aprovação do **PO**.
- Mudanças de versão mínima exigem testes em todas as plataformas antes de atualizar este documento.

---

*Documento gerado pelo Arquiteto/Supervisor IA. Aprovação do PO necessária antes de ser usado como referência obrigatória.*
