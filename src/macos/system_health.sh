#!/usr/bin/env bash
# Подключение библиотек
readonly TOOLKIT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh"
source "${TOOLKIT_ROOT}/lib/config.sh"

# Загрузка конфига (если есть)
load_config "~/.config/sat/config.conf" 2>/dev/null || true

# Использование в коде:
# log "INFO" "Starting system health check..."
# log "WARN" "High CPU load detected: ${load_avg}"
set -euo pipefail


readonly VERSION="1.0.0"
readonly DISK_ALERT_THRESHOLD=85

readonly RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[0;33m' CYAN='\033[0;36m' RESET='\033[0m'
readonly EMOJI_START="🚀" EMOJI_OK="✅" EMOJI_WARN="⚠️" EMOJI_ERR="🚨"

print_header() {
  cat << 'EOF'
  ╔══════════════════════════════════════════════════════════╗
  ║          ____  _      _   ____  ___   ___                ║
  ║         / ___|| |__  | | / ___|/ _ \/  _ \               ║
  ║         \___ \| '_ \ | || |   | | | | | | |              ║
  ║          ___) | | | || || |___| |_| | |_| |              ║
  ║         |____/|_| |_||_| \____|\___/ \___/               ║
  ║                                                          ║
  ║           SysAdmin-Toolkit | System Health Module        ║
  ╚══════════════════════════════════════════════════════════╝
EOF
  echo -e "${CYAN}🛠️  Version: ${VERSION} | Platform: macOS${RESET}\n"
}

show_help() {
  cat << EOF
${CYAN}USAGE${RESET}
  ./system_health.sh [OPTIONS]

${CYAN}OPTIONS${RESET}
  -h, --help      Show this help message and exit
  -v, --version   Show version and exit

${YELLOW}💡 PRODUCTION TIPS${RESET}
  • macOS uses launchd. Check logs: log show --predicate 'process == "launchd"' --last 1h
  • Use 'sudo' for full process visibility and service status.
EOF
  exit 0
}

check_disk() {
  echo -e "${CYAN}📦 DISK USAGE${RESET}"
  df -hl | grep '^/dev/' | while read -r _ _ _ _ usage target; do
    local usage_pct="${usage//%/}"
    if [[ "$usage_pct" -ge "$DISK_ALERT_THRESHOLD" ]]; then
      echo -e "${EMOJI_ERR} ${RED}[CRITICAL] ${target}: ${usage} used${RESET}"
    else
      echo -e "${EMOJI_OK} ${GREEN}${target}: ${usage} used${RESET}"
    fi
  done
  echo
}

check_cpu_ram() {
  echo -e "${CYAN}⚡ CPU & MEMORY${RESET}"
  local load_avg
  load_avg=$(sysctl -n vm.loadavg | tr -d '{}' | awk '{print $1, $2, $3}')
  echo -e "${EMOJI_OK} Load Average (1/5/15m): ${YELLOW}${load_avg}${RESET}"
  
  local page_size free_pages spec_pages wired_pages
  page_size=$(vm_stat | head -1 | awk -F. '{print $NF}' | tr -d ' ')
  free_pages=$(vm_stat | awk '/Pages free/ {print $3}' | tr -d '.')
  wired_pages=$(vm_stat | awk '/Pages wired down/ {print $NF}' | tr -d '.')
  spec_pages=$(vm_stat | awk '/Pages speculative/ {print $3}' | tr -d '.')
  
  local total_mem_mb=$(( $(sysctl -n hw.memsize) / 1024 / 1024 ))
  local used_mb=$(( (wired_pages * page_size) / 1024 / 1024 ))
  echo -e "${EMOJI_OK} RAM Usage: ~${YELLOW}${used_mb}MB${RESET} / ${total_mem_mb}MB"
  echo
}

check_services() {
  echo -e "${CYAN}⚙️  LAUNCHDAEMONS (macOS)${RESET}"
  local failed
  failed=$(sudo launchctl list 2>/dev/null | awk 'NR>1 && $1 > 0 {print $3, "Exit:", $1}' || true)
  if [[ -z "$failed" ]]; then
    echo -e "${EMOJI_OK} ${GREEN}No known crashed daemons detected.${RESET}"
  else
    echo -e "${EMOJI_ERR} ${RED}Daemons with non-zero exit codes:${RESET}"
    echo "$failed" | sed 's/^/  /'
  fi
  echo
}

check_top_processes() {
  echo -e "${CYAN}📊 TOP 5 CPU PROCESSES${RESET}"
  ps aux -r | head -6 | tail -5 | awk '{printf "%-8s %-10s %5s%%  %s\n", $1, $2, $3, $11}'
  echo
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
  check_top_processes
  echo -e "${CYAN}✨ Health check completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
}

main "$@"