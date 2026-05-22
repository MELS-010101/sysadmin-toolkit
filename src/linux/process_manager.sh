# Module: Process Manager
VERSION="1.0.0"
action="${1:-list}"
target="${2:-}"

if [ "$action" = "list" ]; then
    echo "--- Top Processes (CPU) ---"
    ps aux --sort=-%cpu | head -n 11
    echo ""
    echo "--- Top Processes (RAM) ---"
    ps aux --sort=-%mem | head -n 11
elif [ "$action" = "kill" ]; then
    if [ -z "$target" ]; then
        echo "Usage: sat procs kill <PID>"
        exit 1
    fi
    echo "Killing process $target..."
    kill -9 "$target" 2>/dev/null && echo "Success" || echo "Failed (check permissions)"
elif [ "$action" = "tree" ]; then
    echo "--- Process Tree ---"
    pstree 2>/dev/null || echo "pstree command not found"
else
    echo "Usage: sat procs [list|kill|tree] [PID]"
fi