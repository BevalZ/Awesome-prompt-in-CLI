@echo off
REM Windows Batch Wrapper for Awesome Academic Prompts
REM Automatically detects and launches Bash environment

REM Set UTF-8 encoding for proper path handling
chcp 65001 >nul 2>&1

echo.
echo ================================================================
echo  Awesome Academic Prompts - Windows Launcher
echo ================================================================
echo.

REM Check for WSL (preferred)
where wsl >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Detected WSL - launching...
    wsl bash "%~dp0main.sh" %*
    goto :end
)

REM Check for Git Bash / any bash in PATH
where bash >nul 2>&1
if %errorlevel% equ 0 (
    echo [*] Detected Bash - launching...
    bash "%~dp0main.sh" %*
    goto :end
)

REM No Bash found - show installation help
echo [!] ERROR: Bash not found on this system.
echo.
echo This toolkit requires a Bash environment. Please install one of:
echo.
echo   1. Git for Windows (recommended for most users)
echo      Download: https://git-scm.com/download/win
echo.
echo   2. Windows Subsystem for Linux (WSL)
echo      Run in PowerShell: wsl --install
echo.
echo   3. Cygwin
echo      Download: https://www.cygwin.com/
echo.
pause
exit /b 1

:end
if %errorlevel% neq 0 (
    echo.
    echo [!] Script exited with error code: %errorlevel%
    pause
)
