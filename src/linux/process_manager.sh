# Module: Process Manager
VERSION="1.0.0"
action="${1:-list}"
target="${2:-}"

if [ "$action" = "list" ]; then
    echo "--- Top Processes (CPU) ---"
    ps -eo pid,rss,pcpu,comm 2>/dev/null | tail -n +2 | sort -k3 -rn | head -n 10 | while read pid rss cpu name; do
        mem_mb=$((rss / 1024))
        printf "%-8s %-8s %-8s %s\n" "$pid" "$mem_mb" "$cpu" "$name"
    done
    
    echo ""
    echo "--- Top Processes (RAM) ---"
    ps -eo pid,rss,pcpu,comm 2>/dev/null | tail -n +2 | sort -k2 -rn | head -n 10 | while read pid rss cpu name; do
        mem_mb=$((rss / 1024))
        printf "%-8s %-8s %-8s %s\n" "$pid" "$mem_mb" "$cpu" "$name"
    done
    
elif [ "$action" = "kill" ]; then
    if [ -z "$target" ]; then
        echo "Usage: sat procs kill <PID>"
        exit 1
    fi
    echo "Killing process $target..."
    kill -9 "$target" 2>/dev/null && echo "Success" || echo "Failed"
    
elif [ "$action" = "tree" ]; then
    echo "--- Process Tree ---"
    pstree 2>/dev/null || ps -ejH 2>/dev/null | head -n 30 || echo "Not available"
else
    echo "Usage: sat procs [list|kill|tree] [PID]"
fi