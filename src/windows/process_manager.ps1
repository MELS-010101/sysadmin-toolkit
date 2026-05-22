# Module: Process Manager (Windows PowerShell)
$action = $args[0]
$target = $args[1]

if ($action -eq "list" -or [string]::IsNullOrEmpty($action)) {
    Write-Host "--- Top Processes (CPU) ---"
    Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Id, @{Name='Mem(MB)';Expression={[int]($_.WS/1MB)}}, @{Name='CPU(%)';Expression={[int]$_.CPU}}, Name | Format-Table -AutoSize
    
    Write-Host ""
    Write-Host "--- Top Processes (RAM) ---"
    Get-Process | Sort-Object WS -Descending | Select-Object -First 10 Id, @{Name='Mem(MB)';Expression={[int]($_.WS/1MB)}}, Name | Format-Table -AutoSize
    
} elseif ($action -eq "kill") {
    if ([string]::IsNullOrEmpty($target)) {
        Write-Host "Usage: sat procs kill <PID>"
        exit 1
    }
    Write-Host "Killing process $target..."
    Stop-Process -Id $target -Force -ErrorAction SilentlyContinue
    if ($?) { Write-Host "Success" } else { Write-Host "Failed" }
    
} elseif ($action -eq "tree") {
    Write-Host "--- Process Tree ---"
    Get-CimInstance Win32_Process | Select-Object -First 20 Name, ProcessId, ParentProcessId | Format-Table -AutoSize
} else {
    Write-Host "Usage: sat procs [list|kill|tree] [PID]"
}
