# src/windows/security_audit.ps1
# sysadmin-toolkit Module 4: Security Audit (Windows)
# Usage: .\security_audit.ps1

param(
    [switch]$Verbose
)

$ErrorActionPreference = "SilentlyContinue"

Write-Host "🛡️ Starting Security Audit (Windows)..." -ForegroundColor Cyan
Write-Host "====================================="

Write-Host "[CHECK] Checking Local Administrators group..." -ForegroundColor Yellow
try {
    $admins = Get-LocalGroupMember -Group "Administrators" -ErrorAction Stop
    foreach ($admin in $admins) {
        if ($admin.Name -notlike "*Administrator") {
            Write-Host "🔴 WARNING: Non-standard admin found: $($admin.Name)" -ForegroundColor Red
        } else {
            Write-Host "🟢 OK: Standard Admin: $($admin.Name)" -ForegroundColor Green
        }
    }
} catch {
    Write-Host "⚠️ Could not retrieve Admin group members (Run as Administrator?)." -ForegroundColor Yellow
}

Write-Host "[CHECK] Checking Windows Defender..." -ForegroundColor Yellow
try {
    $defender = Get-MpComputerStatus -ErrorAction Stop
    if ($defender.AntivirusEnabled -and $defender.RealTimeProtectionEnabled) {
        Write-Host "🟢 OK: Windows Defender is Active and Real-time Protection is ON." -ForegroundColor Green
    } else {
        Write-Host "🔴 CRITICAL: Windows Defender is disabled or incomplete!" -ForegroundColor Red
    }
} catch {
    Write-Host "⚠️ Could not check Defender status." -ForegroundColor Yellow
}

Write-Host "[CHECK] Checking Firewall Profiles..." -ForegroundColor Yellow
try {
    $profiles = Get-NetFirewallProfile
    foreach ($prof in $profiles) {
        if ($prof.Enabled -eq $true) {
            Write-Host "🟢 OK: Firewall Profile '$($prof.Name)' is Enabled." -ForegroundColor Green
        } else {
            Write-Host " WARNING: Firewall Profile '$($prof.Name)' is Disabled!" -ForegroundColor Red
        }
    }
} catch {
    Write-Host "⚠️ Could not check Firewall profiles." -ForegroundColor Yellow
}

Write-Host "[CHECK] Checking Auto-start Services (Top 5)..." -ForegroundColor Yellow
Get-Service | Where-Object { $_.StartType -eq 'Automatic' } | Select-Object -First 5 -Property Name, Status | Format-Table

Write-Host "====================================="
Write-Host "✅ Security Audit Complete." -ForegroundColor Green
