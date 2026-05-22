# Module: System Health Monitor

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/utils.sh" 2>/dev/null || true

VERSION="1.0.0"

# Main logic
main() {
    if [ "${SAT_FORMAT:-text}" = "json" ]; then
        # JSON Output Mode
        local load_avg disk_pct mem_pct
        load_avg=$(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo "N/A")
        disk_pct=$(df / 2>/dev/null | grep / | awk '{print $5}' | tr -d '%' || echo "N/A")
        mem_total=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "0")
        mem_avail=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}' || echo "0")
        
        if [ "$mem_total" -gt 0 ] 2>/dev/null; then
            mem_pct=$(( (mem_total - mem_avail) * 100 / mem_total ))
        else
            mem_pct="N/A"
        fi

        cat <<EOF
{
  "module": "system_health",
  "version": "${VERSION}",
  "load_avg": "${load_avg}",
  "disk_usage_pct": "${disk_pct}",
  "memory_usage_pct": "${mem_pct}"
}
EOF
    else
        # Text Output Mode
        echo ""
        echo "  SysAdmin-Toolkit | System Health Module"
        echo "  Version: ${VERSION}"
        echo ""
        
        echo "Load Average: $(cat /proc/loadavg 2>/dev/null | awk '{print $1}' || echo 'N/A')"
        echo "Disk Usage: $(df / 2>/dev/null | grep / | awk '{print $5}' || echo 'N/A')"
        
        local mem_total=$(grep MemTotal /proc/meminfo 2>/dev/null | awk '{print $2}')
        local mem_avail=$(grep MemAvailable /proc/meminfo 2>/dev/null | awk '{print $2}')
        if [ -n "$mem_total" ] && [ "$mem_total" -gt 0 ]; then
            local mem_pct=$(( (mem_total - mem_avail) * 100 / mem_total ))
            echo "Memory Usage: ${mem_pct}%"
        else
            echo "Memory Usage: N/A"
        fi
        echo ""
    fi
}

main "$@"
