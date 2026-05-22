# Module: Process Manager
VERSION="1.0.0"

action="${1:-list}"
target="${2:-}"

# Simple cross-platform process viewer
list_processes() {
    echo "PID      MEM(MB)  CPU%     Name"
    echo "----------------------------------------"
    
    # Try different commands based on what's available
    if command -v ps >/dev/null 2>&1; then
        # Linux/macOS/Git Bash
        ps -eo pid,rss,pcpu,comm 2>/dev/null | tail -n +2 | sort -k3 -rn | head -n 10 | \
        while read pid rss cpu name; do
            mem_mb=$((rss / 1024))
            printf "%-8s %-8s %-8s %s\n" "$pid" "$mem_mb" "$cpu" "$name"
        done
    else
        # Fallback - use PowerShell on Windows
        pwsh -Command "Get-Process | Select-Object -First 10 Id, @{Name='Mem(MB)';Expression={[int](`$_.WS/1MB)}}, @{Name='CPU';Expression={[int]`$_.CPU}}, Name | Format-Table -HideTableHeaders" 2>/dev/null
    fi
}

list_memory() {
    echo "PID      MEM(MB)  MEM%     Name"
    echo "----------------------------------------"
    
    if command -v ps >/dev/null 2>&1; then
        ps -eo pid,rss,pcpu,comm 2>/dev/null | tail -n +2 | sort -k2 -rn | head -n 10 | \
        while read pid rss cpu name; do
            mem_mb=$((rss / 1024))
            printf "%-8s %-8s %-8s %s\n" "$pid" "$mem_mb" "$cpu" "$name"
        done
    else
        pwsh -Command "Get-Process | Select-Object -First 10 Id, @{Name='Mem(MB)';Expression={[int](`$_.WS/1MB)}}, Name | Format-Table -HideTableHeaders" 2>/dev/null
    fi
}

kill_process() {
    if [ -z "$target" ]; then
        echo "Usage: sat procs kill <PID>"
        exit 1
    fi
    echo "Killing process $target..."
    if command -v kill >/dev/null 2>&1; then
        kill -9 "$target" 2>/dev/null && echo "Success" || echo "Failed"
    else
        taskkill /PID "$target" /F 2>/dev/null && echo "Success" || echo "Failed"
    fi
}

show_tree() {
    if command -v pstree >/dev/null 2>&1; then
        pstree | head -n 30
    elif command -v ps >/dev/null 2>&1; then
        ps -ejH 2>/dev/null | head -n 30
    else
        echo "Process tree not available"
    fi
}

case "$action" in
    list)
        echo "--- Top Processes (CPU) ---"
        list_processes
        echo ""
        echo "--- Top Processes (RAM) ---"
        list_memory
        ;;
    kill)
        kill_process
        ;;
    tree)
        echo "--- Process Tree ---"
        show_tree
        ;;
    *)
        echo "Usage: sat procs [list|kill|tree] [PID]"
        ;;
esac