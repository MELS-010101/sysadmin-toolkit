$ScriptDir = $PSScriptRoot
$BashScript = Join-Path $ScriptDir "sat"

# Try Git Bash first
$gitBash = "C:\Program Files\Git\bin\bash.exe"
if (Test-Path $gitBash) {
    & $gitBash -c "& '$BashScript' `"$args`""
    exit $LASTEXITCODE
}

# Try WSL
if (Get-Command wsl -ErrorAction SilentlyContinue) {
    wsl bash "$BashScript" @args
    exit $LASTEXITCODE
}

# Try bash from PATH
if (Get-Command bash -ErrorAction SilentlyContinue) {
    bash "$BashScript" @args
    exit $LASTEXITCODE
}

Write-Error "No bash found. Install Git for Windows or WSL."
exit 1
