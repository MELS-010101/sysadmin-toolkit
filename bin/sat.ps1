# SysAdmin-Toolkit - Simple Windows Version
Write-Host "DEBUG: sat.ps1 запущен"
Write-Host "DEBUG: Args: $args"

$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
Write-Host "DEBUG: SCRIPT_DIR: $SCRIPT_DIR"

$ROOT_DIR = Split-Path -Parent $SCRIPT_DIR
$WINDOWS_DIR = Join-Path $ROOT_DIR "src\windows"
Write-Host "DEBUG: WINDOWS_DIR: $WINDOWS_DIR"

$command = $args[0]
Write-Host "DEBUG: command: $command"

if ($command -eq "procs") {
    Write-Host "DEBUG: Запускаю process_manager.ps1"
    $procScript = Join-Path $WINDOWS_DIR "process_manager.ps1"
    Write-Host "DEBUG: Путь: $procScript"
    
    if (Test-Path $procScript) {
        Write-Host "DEBUG: Файл существует"
        & $procScript
    } else {
        Write-Host "ERROR: Файл не найден: $procScript"
    }
} else {
    Write-Host "Usage: sat <command>"
    Write-Host "Commands: procs, find, health, etc."
}
