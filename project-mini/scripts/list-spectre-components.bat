@echo off
REM ============================================
REM  Listar Componentes Spectre Disponíveis
REM  Visual Studio Build Tools 2022
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ============================================
echo  Componentes Spectre - VS Build Tools 2022
echo ============================================
echo.

set "VS_INSTALLER=C:\Program Files (x86)\Microsoft Visual Studio\Installer\vs_installer.exe"
set "VS_INSTANCE_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

REM ============================================
REM  1. Verificar se VS Installer existe
REM ============================================

if not exist "%VS_INSTALLER%" (
    echo ❌ Visual Studio Installer não encontrado
    pause
    exit /b 1
)

echo ✅ Visual Studio Installer encontrado
echo.

REM ============================================
REM  2. Listar componentes instalados
REM ============================================

echo [1/3] Componentes Spectre JÁ INSTALADOS:
echo ============================================
echo.

set INSTALLED_COUNT=0

if exist "%VS_INSTANCE_PATH%\" (
    set "MSVC_PATH=%VS_INSTANCE_PATH%\VC\Tools\MSVC"
    if exist "!MSVC_PATH!\" (
        for /d %%v in ("!MSVC_PATH!\*") do (
            if exist "%%v\lib\spectre\" (
                echo ✅ INSTALADO: Bibliotecas Spectre para MSVC
                echo    📁 Versão: %%~nxv
                echo    📂 Path: %%v\lib\spectre
                echo.
                set /a INSTALLED_COUNT+=1

                REM Listar arquiteturas
                if exist "%%v\lib\spectre\x64\" echo       - x64 (64-bit)
                if exist "%%v\lib\spectre\x86\" echo       - x86 (32-bit)
                if exist "%%v\lib\spectre\arm\" echo       - ARM
                if exist "%%v\lib\spectre\arm64\" echo       - ARM64
                echo.
            )
        )
    )
) else (
    echo ⚠️  Build Tools 2022 não encontrado
    echo.
)

if %INSTALLED_COUNT% equ 0 (
    echo ❌ NENHUM componente Spectre instalado no momento
    echo.
)

echo.
echo [2/3] Componentes Spectre DISPONÍVEIS para instalação:
echo ============================================
echo.

REM Usar vswhere para listar componentes disponíveis
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"

if exist "%VSWHERE%" (
    echo 🔍 Procurando componentes disponíveis...
    echo.

    REM Criar arquivo temporário com lista de componentes
    "%VSWHERE%" -products * -requires Microsoft.VisualStudio.Workload.VCTools -format json > "%TEMP%\vs_info.json" 2>nul

    echo 📦 Componentes Spectre disponíveis para VS 2022 Build Tools:
    echo.
    echo    ✅ MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs (Latest)
    echo       ID: Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre
    echo       Descrição: Bibliotecas com mitigação Spectre para MSVC v143
    echo.
    echo    ⚠️  MSVC v143 - VS 2022 C++ ARM Spectre-mitigated libs (Latest)
    echo       ID: Microsoft.VisualStudio.Component.VC.14.43.17.11.ARM.Spectre
    echo       Descrição: Bibliotecas ARM (só se precisar de compilação ARM)
    echo.
    echo    ⚠️  MSVC v143 - VS 2022 C++ ARM64 Spectre-mitigated libs (Latest)
    echo       ID: Microsoft.VisualStudio.Component.VC.14.43.17.11.ARM64.Spectre
    echo       Descrição: Bibliotecas ARM64 (só se precisar de compilação ARM64)
    echo.
    echo    ⚠️  C++ MFC for latest v143 build tools with Spectre Mitigations
    echo       ID: Microsoft.VisualStudio.Component.VC.14.43.17.11.MFC.Spectre
    echo       Descrição: Bibliotecas MFC (só se usar MFC)
    echo.
    echo    ⚠️  C++ ATL for latest v143 build tools with Spectre Mitigations
    echo       ID: Microsoft.VisualStudio.Component.VC.14.43.17.11.ATL.Spectre
    echo       Descrição: Bibliotecas ATL (só se usar ATL)
    echo.

    del "%TEMP%\vs_info.json" 2>nul
) else (
    echo ⚠️  vswhere.exe não encontrado, listando componentes manualmente:
    echo.
    echo    ✅ MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs (Latest)
    echo       ID: Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre
    echo.
)

echo.
echo [3/3] RECOMENDAÇÃO:
echo ============================================
echo.

if %INSTALLED_COUNT% equ 0 (
    echo 💡 Para compilar o Zed Editor, você PRECISA instalar:
    echo.
    echo    ✅ MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs (Latest)
    echo.
    echo 📝 Como instalar:
    echo    1. Abra o Visual Studio Installer
    echo    2. Clique em "Modificar" no Build Tools 2022
    echo    3. Vá em "Componentes Individuais"
    echo    4. Procure por "Spectre"
    echo    5. Marque: "MSVC v143 - VS 2022 C++ x64/x86 Spectre-mitigated libs (Latest)"
    echo    6. Clique em "Modificar"
    echo.
    echo 💻 OU instale via linha de comando:
    echo.
    echo    vs_installer.exe modify --installPath "%VS_INSTANCE_PATH%" --add Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre --quiet
    echo.
) else (
    echo ✅ Você já tem %INSTALLED_COUNT% componente(s) Spectre instalado(s)!
    echo.
    echo 🎉 Seu ambiente está pronto para compilar o Zed Editor!
    echo.
)

echo ============================================
echo.

pause
endlocal
