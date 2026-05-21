# SysAdmin-Toolkit Main Entrypoint (Windows)
# Usage: sat <command> [options]

param(
    [Parameter(Position=0)][string]$Command,
    [Parameter(ValueFromRemainingArguments=$true)][string[]]$Args
)

$ScriptPath = Split-Path -Parent $MyInvocation.MyCommand.Path
$RootDir = Split-Path -Parent $ScriptPath
$WinModules = Join-Path $RootDir "src\windows"

function Show-Help {
    Write-Host "SysAdmin-Toolkit v1.0.0"
    Write-Host "Usage: sat <command> [options]"
    Write-Host ""
    Write-Host "Available commands:"
    Write-Host "  health      Check system health (CPU, RAM, Disk, Services)"
    Write-Host "  log-clean   Rotate & archive old logs [-Dir PATH] [-Days N]"
    Write-Host "  security    Run security audit (admins, defender, firewall)"
    Write-Host "  net-check   Network audit & listening ports"
    Write-Host "  --help      Show this help message"
}

switch -Regex ($Command) {
    '^health$' {
        if (Test-Path "$WinModules\system_health.ps1") {
            & "$WinModules\system_health.ps1" @Args
        } else {
            Write-Warning "Module not found: system_health.ps1"
        }
        break
    }
    '^log-clean$' {
        if (Test-Path "$WinModules\log_cleanup.ps1") {
            & "$WinModules\log_cleanup.ps1" @Args
        } else {
            Write-Warning "Module not found: log_cleanup.ps1"
        }
        break
    }
    '^security$' {
        if (Test-Path "$WinModules\security_audit.ps1") {
            & "$WinModules\security_audit.ps1" @Args
        } else {
            Write-Warning "Module not found: security_audit.ps1"
        }
        break
    }
    '^net-check$' {
        Write-Warning "Network audit module for Windows is under development."
        break
    }
    '^(--help|-h|help|)$' {
        Show-Help
        break
    }
    default {
        Write-Error "Unknown command: $Command"
        Write-Host "Run 'sat --help' for usage."
        exit 1
    }
}