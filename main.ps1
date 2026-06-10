# PowerShell Wrapper for Awesome Academic Prompts
# Automatically detects and launches Bash environment

Write-Host ""
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host " Awesome Academic Prompts - PowerShell Launcher" -ForegroundColor Cyan
Write-Host "================================================================" -ForegroundColor Cyan
Write-Host ""

# Check for WSL (preferred)
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    Write-Host "[*] Detected WSL - launching..." -ForegroundColor Green
    wsl bash "$PSScriptRoot/main.sh" @args
    exit $LASTEXITCODE
}

# Check for Git Bash / any bash in PATH
if (Get-Command bash -ErrorAction SilentlyContinue) {
    Write-Host "[*] Detected Bash - launching..." -ForegroundColor Green
    bash "$PSScriptRoot/main.sh" @args
    exit $LASTEXITCODE
}

# No Bash found - show installation help
Write-Host "[!] ERROR: Bash not found on this system." -ForegroundColor Red
Write-Host ""
Write-Host "This toolkit requires a Bash environment. Please install one of:" -ForegroundColor Yellow
Write-Host ""
Write-Host "  1. Git for Windows (recommended for most users)" -ForegroundColor White
Write-Host "     Download: https://git-scm.com/download/win" -ForegroundColor Gray
Write-Host ""
Write-Host "  2. Windows Subsystem for Linux (WSL)" -ForegroundColor White
Write-Host "     Run in PowerShell: wsl --install" -ForegroundColor Gray
Write-Host ""
Write-Host "  3. Cygwin" -ForegroundColor White
Write-Host "     Download: https://www.cygwin.com/" -ForegroundColor Gray
Write-Host ""
Read-Host "Press Enter to exit"
exit 1
