@'
# Get script directory
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptDir

# Check for WSL
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl bash "$RootDir/bin/sat" @args
    exit $LASTEXITCODE
}

# Check for Git Bash
$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBash) {
    & $gitBash "$RootDir/bin/sat" @args
    exit $LASTEXITCODE
}

Write-Error "Neither WSL nor Git Bash found. Please install one."
Write-Host "Install WSL: https://aka.ms/wsl"
Write-Host "Or Git for Windows: https://git-scm.com/download/win"
exit 1
'@ | Set-Content "bin\sat.ps1" -Encoding UTF8