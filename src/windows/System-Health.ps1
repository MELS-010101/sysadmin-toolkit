<#
.SYNOPSIS
  SysAdmin-Toolkit System Health Module (Windows)
.DESCRIPTION
  Monitors Disk (>85%), CPU/RAM, stopped services, and top 5 processes.
  Follows Verb-Noun cmdlet standard and modern PowerShell best practices.
.PARAMETER Help
  Shows detailed usage guide and production tips.
.EXAMPLE
  .\System-Health.ps1
  .\System-Health.ps1 -Help
.NOTES
  Author: SysAdmin-Toolkit Contributors
  License: MIT
#>
[CmdletBinding()]
param(
    [Parameter(Mandatory=$false)][switch]$Help,
    [Parameter(Mandatory=$false)][switch]$Version
)

$Script:Version = "1.0.0"
$Script:DiskAlertThreshold = 85

function Write-STLogo {
    $logo = @"
  ╔══════════════════════════════════════════════════════════╗
  ║          ____  _      _   ____  ___  ___                 ║
  ║         / ___|| |__  | | / ___|/ _ \/ _ \                ║
  ║         \___ \| '_ \ | || |   | | | | | |               ║
  ║          ___) | | | || || |___| |_| | |_| |              ║
  ║         |____/|_| |_||_| \____|\___/ \___/               ║
  ║                                                          ║
  ║           SysAdmin-Toolkit | System Health Module         ║
  ╚══════════════════════════════════════════════════════════╝
"@
    Write-Host "`n$logo`n" -ForegroundColor Cyan
    Write-Host "🛠️  Version: $Script:Version | Platform: Windows Server" -ForegroundColor Cyan
    Write-Host ""
}

function Write-STHelp {
    $helpText = @"
USAGE
  .\System-Health.ps1 [OPTIONS]

OPTIONS
  -Help           Show this help message and exit
  -Version        Show version and exit

EXAMPLES
  .\System-Health.ps1
  .\System-Health.ps1 -Version

💡 PRODUCTION TIPS
  • Run from Task Scheduler: Use 'Run whether user is logged on or not' + Highest Privileges
  • Enable Transcript Logging: Start-Transcript -Path "C:\Logs\SAT_Health.log"
  • Combine with Windows Event Forwarding for centralized alerting.
"@
    Write-Host $helpText -ForegroundColor Yellow
    exit 0
}

function Check-DiskHealth {
    Write-Host "📦 DISK USAGE" -ForegroundColor Cyan
    $drives = Get-CimInstance Win32_LogicalDisk -Filter "DriveType=3"
    foreach ($d in $drives) {
        $pctUsed = [math]::Round((($d.Size - $d.FreeSpace) / $d.Size) * 100, 1)
        $status = if ($pctUsed -ge $Script:DiskAlertThreshold) { "CRITICAL" } else { "OK" }
        $color  = if ($pctUsed -ge $Script:DiskAlertThreshold) { "Red" } else { "Green" }
        $emoji  = if ($pctUsed -ge $Script:DiskAlertThreshold) { "🚨" } else { "✅" }
        Write-Host "$emoji $status $($d.DeviceID): $($pctUsed)% used ($([math]::Round($d.FreeSpace/1GB,2))GB free)" -ForegroundColor $color
    }
    Write-Host ""
}

function Check-CpuRam {
    Write-Host "⚡ CPU & MEMORY" -ForegroundColor Cyan
    $cpu = Get-CimInstance Win32_Processor | Measure-Object -Property LoadPercentage -Average
    $os  = Get-CimInstance Win32_OperatingSystem
    $memUsed = [math]::Round((($os.TotalVisibleMemorySize - $os.FreePhysicalMemory) / $os.TotalVisibleMemorySize) * 100, 1)
    
    Write-Host "✅ CPU Load: $($cpu.Average)%" -ForegroundColor Green
    Write-Host "✅ RAM Usage: $($memUsed)% ($([math]::Round($os.FreePhysicalMemory/1MB,2))MB free)" -ForegroundColor Green
    Write-Host ""
}

function Check-Services {
    Write-Host "⚙️  CRITICAL SERVICES" -ForegroundColor Cyan
    $stopped = Get-Service | Where-Object { $_.Status -eq 'Stopped' -and $_.StartType -ne 'Disabled' }
    if (-not $stopped) {
        Write-Host "✅ All critical/startable services are running." -ForegroundColor Green
    } else {
        Write-Host "🚨 Stopped Services (StartType != Disabled):" -ForegroundColor Red
        $stopped | ForEach-Object { Write-Host "  • $($_.DisplayName) ($($_.Name))" -ForegroundColor Yellow }
    }
    Write-Host ""
}

function Check-TopProcesses {
    Write-Host "📊 TOP 5 CPU PROCESSES" -ForegroundColor Cyan
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 5 | Format-Table Id, ProcessName, CPU, WorkingSet64 -AutoSize
    Write-Host ""
}

# --- Execution Flow ---
if ($Help) { Write-STHelp }
if ($Version) { Write-Host "v$Script:Version"; exit 0 }

Write-STLogo
Check-DiskHealth
Check-CpuRam
Check-Services
Check-TopProcesses
Write-Host "✨ Health check completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan