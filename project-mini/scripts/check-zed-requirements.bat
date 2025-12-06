@echo off
REM ============================================
REM  Verificar Requisitos para Build do Zed
REM ============================================
REM
REM Baseado em: docs/src/development/windows.md
REM ============================================

setlocal enabledelayedexpansion

echo.
echo ============================================
echo  Verificação de Requisitos - Zed Editor
echo ============================================
echo.

set MISSING=0
set INSTALLED=0

REM ============================================
REM  1. Rustup / Rust
REM ============================================

echo [1/5] Verificando Rust...
where rustup >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('rustup --version 2^>nul') do set RUSTUP_VER=%%i
    for /f "tokens=*" %%i in ('rustc --version 2^>nul') do set RUSTC_VER=%%i
    for /f "tokens=*" %%i in ('cargo --version 2^>nul') do set CARGO_VER=%%i
    echo   ✅ Rustup: !RUSTUP_VER!
    echo   ✅ Rust: !RUSTC_VER!
    echo   ✅ Cargo: !CARGO_VER!
    set /a INSTALLED+=1
) else (
    echo   ❌ Rustup NÃO instalado
    echo   📥 Instalar: https://rustup.rs/
    set /a MISSING+=1
)

echo.

REM ============================================
REM  2. Visual Studio Build Tools 2022
REM ============================================

echo [2/5] Verificando Visual Studio Build Tools 2022...
set "VS_PATH=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"

if exist "%VS_PATH%\" (
    echo   ✅ VS Build Tools 2022 instalado

    REM Verificar componentes críticos
    set "MSVC_PATH=%VS_PATH%\VC\Tools\MSVC"
    if exist "!MSVC_PATH!\" (
        dir /b "!MSVC_PATH!" 2>nul | findstr /r "^14\." >nul 2>&1
        if not errorlevel 1 (
            dir /b "!MSVC_PATH!" 2>nul | findstr /r "^14\." > "%TEMP%\msvc_versions.txt"
            for /f "delims=" %%i in (%TEMP%\msvc_versions.txt) do (
                echo   ✅ MSVC: %%i
                set "LAST_MSVC=%%i"
            )
            del "%TEMP%\msvc_versions.txt" 2>nul

            REM Verificar Spectre na última versão encontrada
            if defined LAST_MSVC (
                if exist "!MSVC_PATH!\!LAST_MSVC!\lib\spectre\" (
                    echo   ✅ Bibliotecas Spectre instaladas
                ) else (
                    echo   ⚠️  Bibliotecas Spectre não encontradas
                    echo   📥 Instalar via VS Installer: Component.VC.Runtimes.x86.x64.Spectre
                )
            )
        ) else (
            echo   ⚠️  MSVC não encontrado
        )
        set /a INSTALLED+=1
    ) else (
        echo   ⚠️  MSVC não encontrado
        set /a MISSING+=1
    )
) else (
    echo   ❌ VS Build Tools 2022 NÃO instalado
    echo   📥 Instalar: https://visualstudio.microsoft.com/visual-cpp-build-tools/
    set /a MISSING+=1
)

echo.

REM ============================================
REM  3. Windows SDK
REM ============================================

echo [3/5] Verificando Windows SDK...
set "SDK_PATH=C:\Program Files (x86)\Windows Kits\10\Lib"

if exist "%SDK_PATH%\" (
    REM Verificar versões instaladas
    dir /b "%SDK_PATH%" 2>nul | findstr /r "^10\.0\." > "%TEMP%\sdk_versions.txt" 2>nul

    set SDK_COUNT=0
    for /f %%i in ('type "%TEMP%\sdk_versions.txt" 2^>nul ^| find /c /v ""') do set SDK_COUNT=%%i

    if !SDK_COUNT! gtr 0 (
        echo   ✅ Windows SDK instalado
        type "%TEMP%\sdk_versions.txt" | findstr "." > nul
        for /f "delims=" %%i in (%TEMP%\sdk_versions.txt) do (
            echo   ✅ SDK: %%i
        )
        echo   ✅ Versões compatíveis com Zed
        set /a INSTALLED+=1
    ) else (
        echo   ⚠️  Windows SDK instalado mas sem versões detectadas
        set /a MISSING+=1
    )
    del "%TEMP%\sdk_versions.txt" 2>nul
) else (
    echo   ❌ Windows SDK NÃO instalado
    echo   📥 Download: https://developer.microsoft.com/windows/downloads/windows-sdk/
    set /a MISSING+=1
)

echo.

REM ============================================
REM  4. CMake
REM ============================================

echo [4/5] Verificando CMake...
where cmake >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('cmake --version 2^>nul ^| findstr "cmake version"') do (
        echo   ✅ %%i
    )
    set /a INSTALLED+=1
) else (
    echo   ❌ CMake NÃO instalado
    echo   📥 Instalar: https://cmake.org/download/
    echo   📥 Ou via VS Installer: Component.VC.CMake.Project
    set /a MISSING+=1
)

echo.

REM ============================================
REM  5. Git (opcional mas recomendado)
REM ============================================

echo [5/5] Verificando Git...
where git >nul 2>&1
if %errorlevel% equ 0 (
    for /f "tokens=*" %%i in ('git --version 2^>nul') do (
        echo   ✅ %%i
    )

    REM Verificar longpaths
    for /f "tokens=*" %%i in ('git config --system core.longpaths 2^>nul') do set LONGPATHS=%%i
    if "!LONGPATHS!"=="true" (
        echo   ✅ Git longpaths: habilitado
    ) else (
        echo   ⚠️  Git longpaths: desabilitado
        echo   💡 Recomendado: git config --system core.longpaths true
    )
    set /a INSTALLED+=1
) else (
    echo   ❌ Git NÃO instalado
    echo   📥 Instalar: https://git-scm.com/downloads
    set /a MISSING+=1
)

echo.

REM ============================================
REM  Resumo
REM ============================================

echo ============================================
echo  RESUMO
echo ============================================
echo.
echo ✅ Instalados: %INSTALLED%/5
echo ❌ Faltando: %MISSING%/5
echo.

if %MISSING% equ 0 (
    echo 🎉 Ambiente COMPLETO para compilar o Zed!
    echo.
    echo 🚀 Próximos passos:
    echo    1. git clone https://github.com/zed-industries/zed.git
    echo    2. cd zed
    echo    3. cargo run
    echo.
) else (
    echo ⚠️  Faltam componentes! Instale os itens marcados com ❌
    echo.
    echo 📋 Checklist de instalação:
    if %MISSING% gtr 0 (
        where rustup >nul 2>&1
        if !errorlevel! neq 0 echo    [ ] Rustup - https://rustup.rs/

        where cmake >nul 2>&1
        if !errorlevel! neq 0 echo    [ ] CMake - https://cmake.org/download/

        where git >nul 2>&1
        if !errorlevel! neq 0 echo    [ ] Git - https://git-scm.com/downloads

        set "VS_CHECK=C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools"
        if not exist "!VS_CHECK!" echo    [ ] VS Build Tools 2022 - https://visualstudio.microsoft.com/visual-cpp-build-tools/

        set "SDK_CHECK=C:\Program Files (x86)\Windows Kits\10\Lib"
        if not exist "!SDK_CHECK!" echo    [ ] Windows SDK - https://developer.microsoft.com/windows/downloads/windows-sdk/
    )
    echo.
)

echo ============================================

REM ============================================
REM  Componentes VS Build Tools Requeridos
REM ============================================

echo.
echo 📋 Componentes VS Build Tools 2022 requeridos:
echo.
echo    - Microsoft.VisualStudio.Component.Roslyn.Compiler
echo    - Microsoft.Component.MSBuild
echo    - Microsoft.VisualStudio.Component.CoreBuildTools
echo    - Microsoft.VisualStudio.Workload.MSBuildTools
echo    - Microsoft.VisualStudio.Component.Windows10SDK
echo    - Microsoft.VisualStudio.Component.VC.CoreBuildTools
echo    - Microsoft.VisualStudio.Component.VC.Tools.x86.x64
echo    - Microsoft.VisualStudio.Component.VC.Redist.14.Latest
echo    - Microsoft.VisualStudio.Component.Windows11SDK.26100
echo    - Microsoft.VisualStudio.Component.VC.CMake.Project
echo    - Microsoft.VisualStudio.Component.TextTemplating
echo    - Microsoft.VisualStudio.Component.VC.CoreIde
echo    - Microsoft.VisualStudio.ComponentGroup.NativeDesktop.Core
echo    - Microsoft.VisualStudio.Workload.VCTools
echo    - Microsoft.VisualStudio.Component.VC.Runtimes.x86.x64.Spectre
echo.
echo 💡 Exporte sua configuração atual: VS Installer ^> More ^> Export configuration
echo.

endlocal
pause
