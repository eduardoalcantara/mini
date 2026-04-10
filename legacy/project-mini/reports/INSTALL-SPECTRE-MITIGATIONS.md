# Instruções: Instalar Mitigações de Spectre no Visual Studio Build Tools

**Erro Encontrado:**
```
error MSB8040: as bibliotecas com Mitigações de Spectre são necessárias para este projeto.
```

## Solução

### Opção 1: Via Visual Studio Installer (Recomendado)

1. **Abrir Visual Studio Installer**
   - Buscar "Visual Studio Installer" no menu Iniciar
   - Ou executar: `C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe`

2. **Modificar Instalação**
   - Clicar em "Modificar" na instalação do Visual Studio 2022 Build Tools

3. **Adicionar Componente**
   - Ir para a aba "Componentes individuais"
   - Buscar por: **"Spectre"** ou **"Mitigações de Spectre"**
   - Marcar: **"MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs"**
   - Ou: **"C++ Spectre-mitigated libraries (x86 and x64)"**

4. **Aplicar Mudanças**
   - Clicar em "Modificar"
   - Aguardar instalação (pode levar alguns minutos)

### Opção 2: Via Linha de Comando (PowerShell como Admin)

```powershell
# Localizar o instalador
$installerPath = "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"

# Adicionar componente Spectre (ajustar productId conforme necessário)
& $installerPath modify --installPath "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools" --add Microsoft.VisualStudio.Component.VC.Libraries.x86.x64.Spectre --quiet --norestart
```

### Opção 3: Verificar Instalação Atual

```powershell
# Listar componentes instalados
& "C:\Program Files (x86)\Microsoft Visual Studio\Installer\vswhere.exe" -products * -requires Microsoft.VisualStudio.Component.VC.Libraries.x86.x64.Spectre -property installationPath
```

## Após Instalação

1. **Fechar todos os terminais PowerShell**
2. **Abrir novo terminal**
3. **Tentar npm install novamente:**

```powershell
cd D:\proj\mini-vscode
npm install
```

## Referências

- Erro MSB8040: https://aka.ms/Ofhn4c
- Visual Studio Build Tools: https://visualstudio.microsoft.com/downloads/#build-tools-for-visual-studio-2022
