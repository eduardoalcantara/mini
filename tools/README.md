# Ferramentas locais (binários)

Os executáveis **`wails.exe`** e **`golangci-lint.exe`** ficam nesta pasta para os scripts em `scripts/` não dependerem do `PATH` global.

Por política do repositório, `*.exe` em `tools/` está no **`.gitignore`** — cada máquina (ou CI) precisa gerar os binários uma vez.

## Instalação

Na raiz do repositório (PowerShell):

```powershell
.\scripts\install-tools.ps1
```

Requisitos: **Go** instalado (`go version`), com rede para baixar módulos.

Versões alinhadas ao projeto: Wails **v2.12.0** (mesmo `go.mod`); **golangci-lint v2.x** (`v2.11.4`, mesmo módulo que em `ENVIRONMENT-RULES-v1.0.md`).
