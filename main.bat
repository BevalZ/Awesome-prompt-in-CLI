@echo off
REM ================================================================
REM  Awesome Academic Prompts - Windows CMD Launcher
REM  IMPORTANT: Run this file from Windows CMD or File Explorer ONLY
REM  Do NOT run from Git Bash / WSL / PowerShell
REM  For PowerShell: use .\main.ps1 instead
REM ================================================================

REM Set UTF-8 encoding for proper path handling
chcp 65001 >nul 2>&1

echo.
echo ================================================================
echo  Awesome Academic Prompts - Windows Launcher
echo ================================================================
echo.

REM Check for Git Bash first (most common)
if exist "C:\Program Files\Git\bin\bash.exe" (
    echo [*] Detected Git Bash - launching...
    "C:\Program Files\Git\bin\bash.exe" "%~dp0main.sh" %*
    goto :end
)

REM Check for any bash in PATH
where bash >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Detected Bash - launching...
    bash "%~dp0main.sh" %*
    goto :end
)

REM Check for WSL as last resort
where wsl >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Detected WSL - launching...
    wsl bash "%~dp0main.sh" %*
    goto :end
)

REM No Bash found - show installation help
echo [!] ERROR: No Bash environment found.
echo.
echo Please install one of the following:
echo.
echo   1. Git for Windows ^(RECOMMENDED^)
echo      Download: https://git-scm.com/download/win
echo.
echo   2. Windows Subsystem for Linux ^(WSL^)
echo      Run in PowerShell ^(Admin^): wsl --install
echo.
echo   3. MSYS2
echo      Download: https://www.msys2.org/
echo.
pause
exit /b 1

:end
if %errorlevel% neq 0 (
    echo.
    echo [!] Script exited with error code: %errorlevel%
    pause
)
