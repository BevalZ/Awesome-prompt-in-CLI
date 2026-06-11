# PowerShell Wrapper for Awesome Academic Prompts
# Runs main.sh using available Bash on Windows
# NOTE: This script requires Bash (Git Bash, WSL, or Cygwin) to be installed

param([Parameter(ValueFromRemainingArguments=$true)][string[]]$PassArgs)

$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Awesome Academic Prompts - PowerShell Launcher" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Helper: try to launch bash with main.sh
function Invoke-Bash {
    param([string]$BashCmd)
    Write-Host "[*] Using $BashCmd to launch..." -ForegroundColor Green
    & $BashCmd "$ScriptDir/main.sh" @PassArgs
    exit $LASTEXITCODE
}

# Check for Git Bash (most common on Windows dev machines)
$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBash) {
    Invoke-Bash $gitBash
}

# Check for bash in PATH (covers Git Bash, Cygwin, MSYS2)
if (Get-Command bash -ErrorAction SilentlyContinue) {
    Invoke-Bash "bash"
}

# Check for WSL as last resort
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    Write-Host "[*] Using WSL to launch..." -ForegroundColor Green
    # Convert Windows path to WSL path
    $WslPath = $ScriptDir -replace '\\', '/' -replace '^([A-Za-z]):', '/mnt/$1'.ToLower()
    $WslPath = $WslPath -replace '^/mnt/([A-Z])', { '/mnt/' + $_.Groups[1].Value.ToLower() }
    wsl bash "$WslPath/main.sh" @PassArgs
    exit $LASTEXITCODE
}

# No Bash found - show installation help
Write-Host "[!] ERROR: No Bash environment found on this system." -ForegroundColor Red
Write-Host ""
Write-Host "Please install one of the following:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Git for Windows (RECOMMENDED - includes Git Bash)" -ForegroundColor White
Write-Host "     Download: https://git-scm.com/download/win" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Windows Subsystem for Linux (WSL)" -ForegroundColor White
Write-Host "     Run in PowerShell (Admin): wsl --install" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. MSYS2" -ForegroundColor White
Write-Host "     Download: https://www.msys2.org/" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to exit"
exit 1
