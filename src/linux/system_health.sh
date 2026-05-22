# Module: System Health Monitor

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh" 2>/dev/null || true
source "${TOOLKIT_ROOT}/lib/config.sh" 2>/dev/null || true

set -euo pipefail

VERSION="1.0.0"
DISK_ALERT_THRESHOLD=85

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
CYAN='\033[0;36m'
RESET='\033[0m'

print_header() {
  echo ""
  echo "  SysAdmin-Toolkit | System Health Module"
  echo -e "  Version: ${VERSION} | Platform: Linux"
  echo ""
}

show_help() {
  echo "USAGE: ./system_health.sh [OPTIONS]"
  echo "OPTIONS: -h|--help  -v|--version"
  exit 0
}

check_disk() {
  echo -e "${CYAN}DISK USAGE${RESET}"
  df -h 2>/dev/null | grep "^/" | while read -r line; do
    pct=$(echo "$line" | awk '{print $5}' | tr -d '%')
    mount=$(echo "$line" | awk '{print $6}')
    if [ "$pct" -ge "$DISK_ALERT_THRESHOLD" ] 2>/dev/null; then
      echo -e "  ${RED}[CRITICAL] ${mount}: ${pct}%${RESET}"
    else
      echo -e "  ${GREEN}[OK] ${mount}: ${pct}%${RESET}"
    fi
  done || true
  echo ""
}

check_cpu_ram() {
  echo -e "${CYAN}CPU & MEMORY${RESET}"
  if [ -f /proc/loadavg ]; then
    load=$(awk '{print $1, $2, $3}' /proc/loadavg)
    echo -e "  Load Average: ${YELLOW}${load}${RESET}"
  fi
  if [ -f /proc/meminfo ]; then
    total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    avail=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    if [ -n "$total" ] && [ -n "$avail" ] && [ "$total" -gt 0 ]; then
      used=$(( (total - avail) * 100 / total ))
      echo -e "  RAM Usage: ${YELLOW}${used}%${RESET}"
    fi
  fi
  echo ""
}

check_services() {
  echo -e "${CYAN}SERVICES${RESET}"
  if command -v systemctl >/dev/null 2>&1; then
    if systemctl --failed --no-legend 2>/dev/null | grep -q .; then
      echo -e "  ${RED}Failed services detected${RESET}"
    else
      echo -e "  ${GREEN}All services OK${RESET}"
    fi
  else
    echo "  systemctl not available"
  fi
  echo ""
}

check_processes() {
  echo -e "${CYAN}TOP PROCESSES${RESET}"
  ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "  %-8s %5s%%  %s\n", $2, $3, $11}' || true
  echo ""
}

main() {
  case "${1:-}" in
    -h|--help)  show_help ;;
    -v|--version) echo "v${VERSION}"; exit 0 ;;
  esac

  print_header
  check_disk
  check_cpu_ram
  check_services
  check_processes
  echo -e "${CYAN}Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
}

main "$@"