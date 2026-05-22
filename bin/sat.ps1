# SysAdmin-Toolkit - Windows PowerShell Entry Point
$VERSION = "2.2.0"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SCRIPT_DIR
$LINUX_DIR = Join-Path $ROOT_DIR "src\linux"
$WINDOWS_DIR = Join-Path $ROOT_DIR "src\windows"

$SAT_FORMAT = "text"
$INTERACTIVE_MODE = $false

# Parse arguments
$command = $null
$cmdArgs = @()
foreach ($arg in $args) {
    if ($arg -eq "-i" -or $arg -eq "--interactive") {
        $INTERACTIVE_MODE = $true
    } elseif ($arg -eq "--format") {
        $SAT_FORMAT = $args[$args.IndexOf($arg) + 1]
    } elseif ($arg -notlike "-*" -and $command -eq $null) {
        $command = $arg
    } else {
        $cmdArgs += $arg
    }
}

$env:SAT_FORMAT = $SAT_FORMAT

# Interactive mode
if ($INTERACTIVE_MODE) {
    while ($true) {
        Clear-Host
        Write-Host "╔════════════════════════════════════════════════════════╗"
        Write-Host "║           SysAdmin-Toolkit | Interactive Mode          ║"
        Write-Host "╚════════════════════════════════════════════════════════╝"
        Write-Host ""
        Write-Host " 1) System Health"
        Write-Host " 2) Security Audit"
        Write-Host " 3) Network Check"
        Write-Host " 4) Log Cleanup"
        Write-Host " 5) Backup"
        Write-Host " 6) Docker Info"
        Write-Host " 7) SSL Check"
        Write-Host " 8) Update Toolkit"
        Write-Host " 9) Process Manager"
        Write-Host "10) File Finder"
        Write-Host "11) Quit"
        Write-Host ""
        
        $choice = Read-Host "Enter choice [1-11]"
        
        switch ($choice) {
            "1" { & bash "$LINUX_DIR\system_health.sh" }
            "2" { & bash "$LINUX_DIR\security_audit.sh" }
            "3" { & bash "$LINUX_DIR\net_audit.sh" }
            "4" { & bash "$LINUX_DIR\log_cleanup.sh" }
            "5" { & bash "$LINUX_DIR\backup.sh" }
            "6" { & bash "$LINUX_DIR\docker.sh" }
            "7" { & bash "$LINUX_DIR\ssl.sh" }
            "8" { & bash "$LINUX_DIR\update.sh" }
            "9" { & powershell -File "$WINDOWS_DIR\process_manager.ps1" }
            "10" { & powershell -File "$WINDOWS_DIR\file_finder.ps1" }
            "11" { Write-Host "Exiting..."; exit 0 }
            default { Write-Host "Invalid option." }
        }
        
        if ($choice -ne "11") {
            Write-Host ""
            Read-Host "Press Enter to return to menu"
        }
    }
}

# Command execution
switch ($command) {
    "health" { & bash "$LINUX_DIR\system_health.sh" $cmdArgs }
    "security" { & bash "$LINUX_DIR\security_audit.sh" $cmdArgs }
    "net-check" { & bash "$LINUX_DIR\net_audit.sh" $cmdArgs }
    "log-clean" { & bash "$LINUX_DIR\log_cleanup.sh" $cmdArgs }
    "backup" { & bash "$LINUX_DIR\backup.sh" $cmdArgs }
    "update" { & bash "$LINUX_DIR\update.sh" $cmdArgs }
    "docker" { & bash "$LINUX_DIR\docker.sh" $cmdArgs }
    "ssl" { & bash "$LINUX_DIR\ssl.sh" $cmdArgs }
    "procs" { & powershell -File "$WINDOWS_DIR\process_manager.ps1" $cmdArgs }
    "find" { & powershell -File "$WINDOWS_DIR\file_finder.ps1" $cmdArgs }
    "--help" { 
        Write-Host "SysAdmin-Toolkit v$VERSION"
        Write-Host "Usage: sat <command> [options]"
        Write-Host ""
        Write-Host "Commands: health, security, net-check, log-clean, backup, update, docker, ssl, procs, find"
        Write-Host "Options: -i (interactive), --format json"
    }
    $null { 
        Write-Host "SysAdmin-Toolkit v$VERSION"
        Write-Host "Usage: sat <command> [options]"
        Write-Host "Run 'sat --help' for usage."
    }
    default { 
        Write-Host "Error: Unknown command '$command'"
        Write-Host "Run 'sat --help' for usage."
    }
}
