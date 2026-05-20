<#
.SYNOPSIS
  SysAdmin-Toolkit Network Diagnostics & Firewall Audit (Windows)
.DESCRIPTION
  Checks interfaces, DNS, TCP ports, routing, and Windows Firewall rules.
  Follows Verb-Noun standard and modern PS best practices.
.PARAMETER DnsHost
  Target for DNS resolution test. Default: 8.8.8.8
.PARAMETER PortTest
  Target for TCP connectivity test (host:port). Default: localhost:443
.PARAMETER Firewall
  Switch to dump & validate Windows Firewall rules.
.PARAMETER Format
  Output format: text or json. Default: text
.PARAMETER Help
  Show usage guide.
.EXAMPLE
  .\Net-Audit.ps1 -All
  .\Net-Audit.ps1 -DnsHost "internal.corp" -PortTest "db-srv:1433" -Firewall
.NOTES
  License: MIT
#>
[CmdletBinding()]
param(
    [switch]$All,
    [string]$DnsHost = "8.8.8.8",
    [string]$PortTest = "localhost:443",
    [switch]$Firewall,
    [ValidateSet("text","json")][string]$Format = "text",
    [switch]$Help
)

$Script:Version = "1.0.0"

function Write-STLogo {
    $logo = @"
  ╔══════════════════════════════════════════════════════════╗
  ║          ____  _      _   ____  ___  ___                 ║
  ║         / ___|| |__  | | / ___|/ _ \/  _ \               ║
  ║         \___ \| '_ \ | || |   | | | | | | |              ║
  ║          ___) | | | || || |___| |_| | |_| |              ║
  ║         |____/|_| |_||_| \____|\___/ \___/               ║
  ║                                                          ║
  ║           SysAdmin-Toolkit | Network Audit Module        ║
  ╚══════════════════════════════════════════════════════════╝
"@
    Write-Host "`n$logo`n" -ForegroundColor Cyan
    Write-Host "🛠️  Version: $Script:Version | Platform: Windows Server" -ForegroundColor Cyan
    Write-Host ""
}

function Show-STHelp {
    $help = @"
USAGE
  .\Net-Audit.ps1 [OPTIONS]

OPTIONS
  -All              Full network audit
  -DnsHost <str>    DNS target (default: 8.8.8.8)
  -PortTest <str>   TCP target host:port (default: localhost:443)
  -Firewall         Dump Windows Firewall rules
  -Format json      Output as JSON
  -Help             Show guide

💡 PRODUCTION TIPS
  • Run as Administrator for accurate firewall & routing data.
  • Use Test-NetConnection for detailed TCP/DNS diagnostics.
  • Schedule via Task Scheduler with "Run with highest privileges".
"@
    Write-Host $help -ForegroundColor Yellow
    exit 0
}

function Get-NetInterfaces {
    Write-Host "🌐 INTERFACES" -ForegroundColor Cyan
    Get-NetAdapter -Physical | ForEach-Object {
        $status = if ($_.Status -eq 'Up') { "UP" } else { "DOWN" }
        $color = if ($status -eq 'UP') { "Green" } else { "Red" }
        $ip = (Get-NetIPAddress -InterfaceAlias $_.Name -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress
        Write-Host "  • $($_.Name) [$status] $($ip -join ', ')" -ForegroundColor $color
    }
    Write-Host ""
}

function Test-DnsResolution {
    param([string]$Host)
    Write-Host "🔍 DNS CHECK" -ForegroundColor Cyan
    try {
        $res = Resolve-DnsName -Name $Host -Type A -ErrorAction Stop | Select-Object -First 1 -ExpandProperty IPAddress
        Write-Host "  ✅ $Host → $res" -ForegroundColor Green
    } catch {
        Write-Host "  ❌ $Host → FAILED" -ForegroundColor Red
    }
    Write-Host ""
}

function Test-TcpPort {
    param([string]$Target)
    $h, $p = $Target -split ':'
    Write-Host " PORT CHECK" -ForegroundColor Cyan
    $test = Test-NetConnection -ComputerName $h -Port $p -WarningAction SilentlyContinue
    if ($test.TcpTestSucceeded) {
        Write-Host "  ✅ $h`:$p is reachable" -ForegroundColor Green
    } else {
        Write-Host "  ❌ $h`:$p unreachable" -ForegroundColor Red
    }
    Write-Host ""
}

function Get-FirewallRules {
    Write-Host "🛡️  WINDOWS FIREWALL" -ForegroundColor Cyan
    if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
        Write-Host "  ⚠️ Requires Administrator for full dump" -ForegroundColor Yellow
    }
    $rules = Get-NetFirewallRule -Enabled True | Select-Object -First 10 Name, DisplayName, Direction, Action
    $rules | Format-Table -AutoSize
    Write-Host "  ... (showing first 10 active rules)" -ForegroundColor Yellow
    Write-Host ""
}

function Get-Latency {
    Write-Host "📡 LATENCY" -ForegroundColor Cyan
    $ping = Test-Connection -ComputerName "8.8.8.8" -Count 3 -ErrorAction SilentlyContinue
    if ($ping) {
        $avg = [math]::Round(($ping | Measure-Object -Property ResponseTime -Average).Average, 2)
        Write-Host "  ✅ Avg: ${avg} ms" -ForegroundColor Green
    } else {
        Write-Host "  ❌ Ping failed" -ForegroundColor Red
    }
    Write-Host ""
}

if ($Help) { Show-STHelp }
Write-STLogo
Get-NetInterfaces
Test-DnsResolution -Host $DnsHost
Test-TcpPort -Target $PortTest
Get-Latency
if ($Firewall -or $All) { Get-FirewallRules }
Write-Host "✨ Network audit completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan