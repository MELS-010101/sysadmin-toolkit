# Get the directory where this script is located
$ScriptDir = $PSScriptRoot
$RootDir = Split-Path -Parent $ScriptDir

# Path to the bash script
$BashScript = Join-Path $ScriptDir "sat"

# Check for WSL
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl bash "$BashScript" @args
    exit $LASTEXITCODE
}

# Check for Git Bash
$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBash) {
    & $gitBash "$BashScript" @args
    exit $LASTEXITCODE
}

Write-Error "Neither WSL nor Git Bash found. Please install one."
Write-Host "Install WSL: https://aka.ms/wsl"
Write-Host "Or Git for Windows: https://git-scm.com/download/win"
exit 1
