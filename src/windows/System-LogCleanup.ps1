<#
.SYNOPSIS
  SysAdmin-Toolkit Log Rotation & Cleanup (Windows)
.DESCRIPTION
  Finds, compresses, archives and optionally uploads logs to S3.
  Supports dry-run, size/age thresholds, and safe deletion.
.PARAMETER Days
  Rotate logs older than N days. Default: 30
.PARAMETER Pattern
  File extension filter. Default: *.log
.PARAMETER ArchivePath
  Destination for compressed logs. Default: C:\ProgramData\SAT\Archive
.PARAMETER UploadS3
  S3/MinIO bucket name. Requires 'aws' CLI in PATH.
.PARAMETER DryRun
  Simulate actions without modifying files.
.PARAMETER Force
  Skip confirmation prompts.
.PARAMETER TargetDir
  Root directory to scan. Default: C:\Windows\System32\LogFiles
.PARAMETER Help
  Show detailed usage guide.
.EXAMPLE
  .\System-LogCleanup.ps1 -TargetDir "C:\Logs\App" -Days 14 -DryRun
  .\System-LogCleanup.ps1 -UploadS3 "logs-bucket" -Force
.NOTES
  License: MIT
#>
[CmdletBinding()]
param(
    [int]$Days = 30,
    [string]$Pattern = "*.log",
    [string]$ArchivePath = "C:\ProgramData\SAT\Archive",
    [string]$UploadS3 = "",
    [switch]$DryRun,
    [switch]$Force,
    [string]$TargetDir = "C:\Windows\System32\LogFiles",
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
  ║           SysAdmin-Toolkit | Log Cleanup Module          ║
  ╚══════════════════════════════════════════════════════════╝
"@
    Write-Host "`n$logo`n" -ForegroundColor Cyan
    Write-Host "🛠️  Version: $Script:Version | Platform: Windows Server" -ForegroundColor Cyan
    Write-Host ""
}

function Write-STHelp {
    $helpText = @"
USAGE
  .\System-LogCleanup.ps1 [OPTIONS]

OPTIONS
  -Days <int>         Rotate logs older than N days (Default: 30)
  -Pattern <glob>     File filter (Default: *.log)
  -ArchivePath <path> Destination for .zip archives
  -UploadS3 <bucket>  Sync to S3/MinIO (requires 'aws' CLI)
  -DryRun             Simulate actions
  -Force              Skip confirmation
  -TargetDir <path>   Directory to scan
  -Help               Show this guide

💡 PRODUCTION TIPS
  • Run as SYSTEM or Administrator for EventLog/IIS paths.
  • Use Windows Task Scheduler with "Run whether user is logged on or not".
  • For IIS logs: -TargetDir "C:\inetpub\logs\LogFiles" -Pattern "*.log"
  • Enable Windows Defender Exclusion for archive path to avoid scanning overhead.
"@
    Write-Host $helpText -ForegroundColor Yellow
    exit 0
}

function Invoke-LogCleanup {
    Write-Host "🔍 Scanning: $TargetDir | Pattern: $Pattern | Age > $Days days" -ForegroundColor Cyan
    
    $cutoffDate = (Get-Date).AddDays(-$Days)
    $files = Get-ChildItem -Path $TargetDir -Filter $Pattern -Recurse -File -ErrorAction SilentlyContinue | 
             Where-Object { $_.LastWriteTime -lt $cutoffDate }
    
    if ($files.Count -eq 0) {
        Write-Host "✅ No logs match criteria." -ForegroundColor Green
        return
    }

    if (-not (Test-Path $ArchivePath)) { New-Item -ItemType Directory -Path $ArchivePath -Force | Out-Null }

    $count = 0
    foreach ($f in $files) {
        $count++
        $zipName = Join-Path $ArchivePath "$($f.BaseName)_$(Get-Date -Format 'yyyyMMdd').zip"
        
        Write-Host "📦 Processing: $($f.FullName)"
        if (-not $DryRun) {
            try {
                Compress-Archive -Path $f.FullName -DestinationPath $zipName -Force -ErrorAction Stop
                Remove-Item $f.FullName -Force
                Write-Host "  ✅ Archived & cleaned" -ForegroundColor Green
            } catch {
                Write-Host "  ❌ Failed: $_" -ForegroundColor Red
            }
        } else {
            Write-Host "  ⚠️ [DRY-RUN] Would compress to: $zipName" -ForegroundColor Yellow
        }
    }
    Write-Host "📊 Processed $count files." -ForegroundColor Cyan
}

function Invoke-S3Sync {
    if ([string]::IsNullOrWhiteSpace($UploadS3) -or $DryRun) {
        Write-Host "⏭️  Skipping S3 sync (dry-run or no bucket)." -ForegroundColor Yellow
        return
    }
    if (-not (Get-Command aws -ErrorAction SilentlyContinue)) {
        Write-Host "🚨 AWS CLI not found in PATH. Install from https://aws.amazon.com/cli/" -ForegroundColor Red
        return
    }

    Write-Host "🌐 Syncing to s3://$UploadS3/sat-logs/" -ForegroundColor Cyan
    try {
        & aws s3 sync $ArchivePath "s3://$UploadS3/sat-logs/" --storage-class STANDARD_IA --only-show-errors 2>&1 | Out-Null
        if ($LASTEXITCODE -eq 0) { Write-Host "✅ S3 sync completed." -ForegroundColor Green }
        else { Write-Host "❌ S3 sync failed with exit code $LASTEXITCODE" -ForegroundColor Red }
    } catch {
        Write-Host "❌ S3 sync error: $_" -ForegroundColor Red
    }
}

# --- Execution ---
if ($Help) { Write-STHelp }
if ($DryRun) { Write-Host "⚠️  DRY-RUN MODE ENABLED" -ForegroundColor Yellow }

Write-STLogo
if (-not $Force -and -not $DryRun) {
    $confirm = Read-Host "🗑️  This will permanently delete old logs. Continue? (y/N)"
    if ($confirm -notmatch '^[yY]$') { Write-Host "Aborted."; exit 0 }
}

Invoke-LogCleanup
Invoke-S3Sync
Write-Host "✨ Cleanup completed at $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')" -ForegroundColor Cyan