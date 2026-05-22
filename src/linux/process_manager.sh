# Module: Process Manager
VERSION="1.0.0"

OS_TYPE="$(uname)"
action="${1:-list}"
target="${2:-}"

show_processes() {
    # Detect OS and use appropriate command
    if [[ "$OS_TYPE" == MINGW* ]] || [[ "$OS_TYPE" == MSYS* ]]; then
        # Windows - use PowerShell
        echo "PID        CPU%    MEM%    Name"
        echo "----------------------------------------"
        powershell -Command "Get-Process | Sort-Object CPU -Descending | Select-Object -First 10 Id, @{Name='CPU';Expression={[math]::Round(`$_.CPU,2)}}, @{Name='Mem%';Expression={[math]::Round((`$_.WorkingSet/1MB)*100/(Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize*100,2)}}, Name | Format-Table -HideTableHeaders"
    else
        # Linux/macOS
        ps aux --sort=-%cpu 2>/dev/null | head -n 11 || \
        ps -eo pid,pcpu,pmem,comm --sort=-pcpu 2>/dev/null | head -n 11
    fi
}

show_memory() {
    if [[ "$OS_TYPE" == MINGW* ]] || [[ "$OS_TYPE" == MSYS* ]]; then
        # Windows - use PowerShell
        echo "PID        MEM(MB)    MEM%    Name"
        echo "----------------------------------------"
        powershell -Command "Get-Process | Sort-Object WorkingSet64 -Descending | Select-Object -First 10 Id, @{Name='Mem(MB)';Expression={[math]::Round(`$_.WorkingSet64/1MB,2)}}, @{Name='Mem%';Expression={[math]::Round((`$_.WorkingSet64/1MB)*100/((Get-CimInstance Win32_OperatingSystem).TotalVisibleMemorySize/1KB),2)}}, Name | Format-Table -HideTableHeaders"
    else
        # Linux/macOS
        ps aux --sort=-%mem 2>/dev/null | head -n 11 || \
        ps -eo pid,rss,pmem,comm --sort=-rss 2>/dev/null | head -n 11
    fi
}

show_tree() {
    if [[ "$OS_TYPE" == MINGW* ]] || [[ "$OS_TYPE" == MSYS* ]]; then
        # Windows - use PowerShell
        echo "Process Tree (Name, PID, Parent PID)"
        echo "----------------------------------------"
        powershell -Command "Get-CimInstance Win32_Process | Select-Object -First 20 Name, ProcessId, ParentProcessId | Format-Table -HideTableHeaders"
    else
        # Linux/macOS
        pstree 2>/dev/null || ps -ejH 2>/dev/null | head -n 30 || echo "Process tree not available"
    fi
}

if [ "$action" = "list" ]; then
    echo "--- Top Processes (CPU) ---"
    show_processes
    
    echo ""
    echo "--- Top Processes (RAM) ---"
    show_memory
    
elif [ "$action" = "kill" ]; then
    if [ -z "$target" ]; then
        echo "Usage: sat procs kill <PID>"
        exit 1
    fi
    echo "Killing process $target..."
    if [[ "$OS_TYPE" == MINGW* ]] || [[ "$OS_TYPE" == MSYS* ]]; then
        # Windows - use taskkill
        taskkill /PID "$target" /F 2>/dev/null && echo "Success" || echo "Failed (check permissions)"
    else
        # Linux/macOS
        kill -9 "$target" 2>/dev/null && echo "Success" || echo "Failed (check permissions)"
    fi
    
elif [ "$action" = "tree" ]; then
    echo "--- Process Tree ---"
    show_tree
else
    echo "Usage: sat procs [list|kill|tree] [PID]"
fi