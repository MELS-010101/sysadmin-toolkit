# SysAdmin-Toolkit - Windows PowerShell Entry Point
$VERSION = "2.2.5"
$SCRIPT_DIR = Split-Path -Parent $MyInvocation.MyCommand.Path
$ROOT_DIR = Split-Path -Parent $SCRIPT_DIR
$LINUX_DIR = Join-Path $ROOT_DIR "src\linux"
$WINDOWS_DIR = Join-Path $ROOT_DIR "src\windows"

$command = $args[0]
$cmdArgs = $args[1..($args.Length-1)]

switch ($command) {
    "health" { & bash "$LINUX_DIR\system_health.sh" $cmdArgs }
    "security" { & bash "$LINUX_DIR\security_audit.sh" $cmdArgs }
    "net-check" { & bash "$LINUX_DIR\net_audit.sh" $cmdArgs }
    "log-clean" { & bash "$LINUX_DIR\log_cleanup.sh" $cmdArgs }
    "backup" { & bash "$LINUX_DIR\backup.sh" $cmdArgs }
    "update" { & bash "$LINUX_DIR\update.sh" $cmdArgs }
    "docker" { & bash "$LINUX_DIR\docker.sh" $cmdArgs }
    "ssl" { & bash "$LINUX_DIR\ssl.sh" $cmdArgs }
    "procs" { & "$WINDOWS_DIR\process_manager.ps1" $cmdArgs }
    "find" { & "$WINDOWS_DIR\file_finder.ps1" $cmdArgs }
    "--help" { 
        Write-Host "SysAdmin-Toolkit v$VERSION"
        Write-Host "Usage: sat <command>"
        Write-Host "Commands: health, security, net-check, log-clean, backup, update, docker, ssl, procs, find"
    }
    default { 
        if ($command) {
            Write-Host "Error: Unknown command '$command'"
        }
        Write-Host "SysAdmin-Toolkit v$VERSION"
        Write-Host "Usage: sat <command>"
        Write-Host "Run 'sat --help' for usage."
    }
}
