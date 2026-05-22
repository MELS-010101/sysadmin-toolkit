# ==============================================================================
# Module: System Health Monitor
# OS: Linux (Ubuntu/Debian/RHEL)
# ==============================================================================

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh" 2>/dev/null || true
source "${TOOLKIT_ROOT}/lib/config.sh" 2>/dev/null || true

set -euo pipefail

readonly VERSION="1.0.0"
readonly DISK_ALERT_THRESHOLD=85

readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

print_header() {
  echo ""
  echo "  ╔══════════════════════════════════════════════════════════╗"
  echo "  ║          SysAdmin-Toolkit | System Health Module         ║"
  echo "  ╚══════════════════════════════════════════════════════════╝"
  echo -e "${CYAN}  Version: ${VERSION} | Platform: Linux${RESET}"
  echo ""
}

show_help() {
  echo "USAGE: ./system_health.sh [OPTIONS]"
  echo ""
  echo "OPTIONS:"
  echo "  -h, --help      Show this help message"
  echo "  -v, --version   Show version"
  exit 0
}

check_disk() {
  echo -e "${CYAN}DISK USAGE${RESET}"
  
  if ! command -v df &>/dev/null; then
    echo "  df command not found"
    echo ""
    return
  fi
  
  df -h 2>/dev/null | grep -E '^/' | while read -r filesystem size used avail use_pct mount; do
    use_pct="${use_pct%\%}"
    
    if [[ "$use_pct" =~ ^[0-9]+$ ]]; then
      if [[ "$use_pct" -ge "$DISK_ALERT_THRESHOLD" ]]; then
        echo -e "  ${RED}[CRITICAL] ${mount}: ${use_pct}% used${RESET}"
      else
        echo -e "  ${GREEN}[OK] ${mount}: ${use_pct}% used${RESET}"
      fi
    fi
  done || true
  echo ""
}

check_cpu_ram() {
  echo -e "${CYAN}CPU & MEMORY${RESET}"
  
  if [[ -f /proc/loadavg ]]; then
    local load_avg
    load_avg=$(awk '{print $1, $2, $3}' /proc/loadavg)
    echo -e "  Load Average: ${YELLOW}${load_avg}${RESET}"
  fi
  
  if [[ -f /proc/meminfo ]]; then
    local mem_total mem_available mem_used_pct
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    
    if [[ -n "$mem_total" && -n "$mem_available" && "$mem_total" -gt 0 ]]; then
      mem_used_pct=$(( (mem_total - mem_available) * 100 / mem_total ))
      echo -e "  RAM Usage: ${YELLOW}${mem_used_pct}%${RESET}"
    fi
  fi
  echo ""
}

check_services() {
  echo -e "${CYAN}SERVICES${RESET}"
  
  if command -v systemctl &>/dev/null; then
    local failed
    failed=$(systemctl --failed --no-legend 2>/dev/null || true)
    
    if [[ -z "$failed" ]]; then
      echo -e "${GREEN}  All services running${RESET}"
    else
      echo -e "${RED}  Failed services detected${RESET}"
    fi
  else
    echo "  systemctl not available"
  fi
  echo ""
}

check_processes() {
  echo -e "${CYAN}TOP PROCESSES${RESET}"
  
  if command -v ps &>/dev/null; then
    ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "  %-8s %5s%%  %s\n", $2, $3, $11}' || true
  fi
  echo ""
}

main() {
  for arg in "$@"; do
    case "$arg" in
      -h|--help)  show_help ;;
      -v|--version) echo "v${VERSION}"; exit 0 ;;
    esac
  done

  print_header
  check_disk
  check_cpu_ram
  check_services
  check_processes
  
  echo -e "${CYAN}Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
}

main "$@"
