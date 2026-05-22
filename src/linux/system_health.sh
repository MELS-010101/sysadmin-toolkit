@'
#!/usr/bin/env bash
# ==============================================================================
# Module: System Health Monitor
# OS: Linux (Ubuntu/Debian/RHEL)
# Style: Google Bash Style Guide + ShellDoc
# ==============================================================================

# Подключение библиотек
TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh" 2>/dev/null || true
source "${TOOLKIT_ROOT}/lib/config.sh" 2>/dev/null || true

set -euo pipefail

readonly VERSION="1.0.0"
readonly DISK_ALERT_THRESHOLD=85

# ANSI Colors & Emojis
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'

# @description Prints header
print_header() {
  echo ""
  echo "  ╔══════════════════════════════════════════════════════════╗"
  echo "  ║          SysAdmin-Toolkit | System Health Module         ║"
  echo "  ╚══════════════════════════════════════════════════════════╝"
  echo -e "${CYAN}  Version: ${VERSION} | Platform: Linux${RESET}"
  echo ""
}

# @description Displays help
show_help() {
  cat << EOF
${CYAN}USAGE${RESET}
  ./system_health.sh [OPTIONS]

${CYAN}OPTIONS${RESET}
  -h, --help      Show this help message and exit
  -v, --version   Show version and exit

${CYAN}EXAMPLES${RESET}
  ./system_health.sh
  ./system_health.sh --version
EOF
  exit 0
}

# @description Checks disk usage
check_disk() {
  echo -e "${CYAN}📦 DISK USAGE${RESET}"
  
  if ! command -v df &>/dev/null; then
    echo -e "${YELLOW}  df command not found${RESET}"
    echo ""
    return
  fi
  
  local disk_info
  disk_info=$(df -h 2>/dev/null | grep -E '^/' || true)
  
  if [[ -z "$disk_info" ]]; then
    echo -e "${YELLOW}  Could not retrieve disk information${RESET}"
    echo ""
    return
  fi
  
  echo "$disk_info" | while read -r line; do
    local filesystem size used avail use_pct mount
    read -r filesystem size used avail use_pct mount <<< "$line"
    
    # Remove % sign
    use_pct="${use_pct%\%}"
    
    if [[ "$use_pct" =~ ^[0-9]+$ ]]; then
      if [[ "$use_pct" -ge "$DISK_ALERT_THRESHOLD" ]]; then
        echo -e "${RED}  [CRITICAL] ${mount}: ${use_pct}% used${RESET}"
      else
        echo -e "${GREEN}  [OK] ${mount}: ${use_pct}% used${RESET}"
      fi
    fi
  done
  echo ""
}

# @description Checks CPU and RAM
check_cpu_ram() {
  echo -e "${CYAN}⚡ CPU & MEMORY${RESET}"
  
  # CPU Load
  if [[ -f /proc/loadavg ]]; then
    local load_avg
    load_avg=$(cat /proc/loadavg | awk '{print $1, $2, $3}')
    echo -e "  Load Average: ${YELLOW}${load_avg}${RESET}"
  fi
  
  # RAM Usage
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

# @description Checks services
check_services() {
  echo -e "${CYAN}⚙️  SERVICES${RESET}"
  
  if ! command -v systemctl &>/dev/null; then
    echo -e "${YELLOW}  systemctl not available${RESET}"
    echo ""
    return
  fi
  
  local failed
  failed=$(systemctl --failed --no-legend 2>/dev/null || true)
  
  if [[ -z "$failed" ]]; then
    echo -e "${GREEN}  All services running${RESET}"
  else
    echo -e "${RED}  Failed services detected${RESET}"
    echo "$failed" | head -5
  fi
  echo ""
}

# @description Top processes
check_processes() {
  echo -e "${CYAN}📊 TOP PROCESSES${RESET}"
  
  if command -v ps &>/dev/null; then
    ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "  %-8s %5s%%  %s\n", $2, $3, $11}' || true
  fi
  echo ""
}

# @description Main
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
  
  echo -e "${CYAN}✨ Completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
}