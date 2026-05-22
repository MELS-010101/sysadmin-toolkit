# Module: File Finder (Windows PowerShell)
$search_dir = if ($args[0]) { $args[0] } else { "." }
$min_size = if ($args[1]) { [int]$args[1] } else { 100 }

Write-Host "--- Files larger than ${min_size}MB in ${search_dir} ---"
Get-ChildItem -Path $search_dir -Recurse -File -ErrorAction SilentlyContinue | 
    Where-Object { $_.Length -gt ($min_size * 1MB) } | 
    Sort-Object Length -Descending | 
    Select-Object -First 20 FullName, @{Name='Size(MB)';Expression={[math]::Round($_.Length/1MB,2)}} |
    Format-Table -AutoSize
