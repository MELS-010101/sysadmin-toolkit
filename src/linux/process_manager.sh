# Module: Process Manager
VERSION="1.0.0"

OS_TYPE="$(uname)"
action="${1:-list}"
target="${2:-}"

if [ "$action" = "list" ]; then
    echo "--- Top Processes (CPU) ---"
    if [ "$OS_TYPE" = "Darwin" ] || command -v ps >/dev/null 2>&1; then
        # Try standard ps first
        ps -eo pid,pcpu,comm --sort=-pcpu 2>/dev/null | head -n 11 || \
        ps aux 2>/dev/null | head -n 11 || \
        echo "ps command not available"
    else
        # Windows fallback - use tasklist
        tasklist 2>/dev/null | head -n 20 || echo "tasklist not available"
    fi
    
    echo ""
    echo "--- Top Processes (RAM) ---"
    if [ "$OS_TYPE" = "Darwin" ]; then
        ps -eo pid,rss,comm --sort=-rss 2>/dev/null | head -n 11
    else
        ps aux --sort=-%mem 2>/dev/null | head -n 11 || \
        tasklist 2>/dev/null | head -n 20 || \
        echo "Memory info not available"
    fi
    
elif [ "$action" = "kill" ]; then
    if [ -z "$target" ]; then
        echo "Usage: sat procs kill <PID>"
        exit 1
    fi
    echo "Killing process $target..."
    kill -9 "$target" 2>/dev/null && echo "Success" || echo "Failed (check permissions)"
    
elif [ "$action" = "tree" ]; then
    echo "--- Process Tree ---"
    if command -v pstree >/dev/null 2>&1; then
        pstree
    elif [ "$OS_TYPE" = "Darwin" ]; then
        echo "pstree not available on macOS, use 'ps -ejH'"
        ps -ejH 2>/dev/null | head -n 30
    else
        # Windows - use wmic or tasklist
        wmic process get name,processid,parentprocessid 2>/dev/null | head -n 30 || \
        echo "Process tree not available"
    fi
else
    echo "Usage: sat procs [list|kill|tree] [PID]"
fi