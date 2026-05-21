#!/usr/bin/env bash
set -euo pipefail
readonly VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TOOLKIT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh"
source "${TOOLKIT_ROOT}/lib/config.sh"
load_config "${HOME}/.config/sat/config.conf" 2>/dev/null || true

readonly DEFAULT_DNS="${SAT_DNS_TEST:-8.8.8.8}"
readonly DEFAULT_PORT="${SAT_PORT_TEST:-443}"
FORMAT="text"
CHECK_FIREWALL=false
TARGET_DNS=""
TARGET_PORT=""

print_header() {
  cat << 'EOF'
  ╔══════════════════════════════════════════════════════════╗
  ║          ____  _      _   ____  ___  ___                 
  ║         / ___|| |__  | | / ___|/ _ \/ _ \                ║
  ║         \___ \| '_ \ | || |   | | | | | |               ║
  ║          ___) | | | || || |___| |_| | |_| |              
  ║         |____/|_| |_||_| \____|\___/ \___/               
  ║                                                          ║
  ║           SysAdmin-Toolkit | Network Audit Module         ║
  ╚══════════════════════════════════════════════════════════╝
EOF
  echo -e "${CYAN}🛠️  Version: ${VERSION} | Platform: macOS${RESET}\n"
}

show_help() {
  cat << EOF
${CYAN}USAGE${RESET}
  ./net_audit.sh [OPTIONS]

${CYAN}OPTIONS${RESET}
  -a, --all             Full network audit
  -f, --firewall        Check PF firewall state
  --dns <host>          Test DNS (default: ${DEFAULT_DNS})
  --port <host:port>    Test TCP (default: ${DEFAULT_PORT})
  --format json         JSON output
  -h, --help            Show guide

${YELLOW}💡 PRODUCTION TIPS${RESET}
  • macOS uses PF. Check state: sudo pfctl -s info
  • Network interfaces managed by networksetup. List: networksetup -listallhardwareports
  • Use 'sudo' for accurate routing & PF dumps.
EOF
  exit 0
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -a|--all)     SHOW_ALL=true; shift ;;
      -f|--firewall) CHECK_FIREWALL=true; shift ;;
      --dns)        TARGET_DNS="$2"; shift 2 ;;
      --port)       TARGET_PORT="$2"; shift 2 ;;
      --format)     FORMAT="$2"; shift 2 ;;
      -h|--help)    show_help ;;
      *)            log "ERROR" "Unknown arg: $1"; exit 1 ;;
    esac
  done
}

check_interfaces() {
  log "INFO" "Scanning interfaces..."
  echo -e "${CYAN} INTERFACES${RESET}"
  ifconfig -l | tr ' ' '\n' | grep -v '^$' | while read -r iface; do
    local status
    status=$(ifconfig "$iface" | grep -m1 "status:" | awk '{print $2}')
    local ip
    ip=$(ifconfig "$iface" | awk '/inet / {print $2}' | head -1)
    local color="$GREEN"
    [[ "$status" == "inactive" ]] && color="$RED"
    echo -e "${color}• ${iface} [${status:-up}] ${ip:-no ip}${RESET}"
  done
}

check_dns() {
  local host="${TARGET_DNS:-$DEFAULT_DNS}"
  log "INFO" "Testing DNS: ${host}"
  local result
  result=$(dig +short "$host" 2>/dev/null | head -1)
  echo -e "${CYAN}🔍 DNS CHECK${RESET}\n${EMOJI_OK} ${GREEN}${host} → ${result:-FAILED}${RESET}"
}

check_ports() {
  local target="${TARGET_PORT:-localhost:${DEFAULT_PORT}}"
  local host="${target%%:*}"
  local port="${target##*:}"
  log "INFO" "Testing TCP: ${host}:${port}"
  if nc -z -w3 "$host" "$port" 2>/dev/null; then
    echo -e "${CYAN}🔌 PORT CHECK${RESET}\n${EMOJI_OK} ${GREEN}${host}:${port} is reachable${RESET}"
  else
    echo -e "${CYAN}🔌 PORT CHECK${RESET}\n${EMOJI_WARN} ${RED}${host}:${port} unreachable${RESET}"
  fi
}

check_firewall() {
  log "INFO" "Checking PF firewall..."
  echo -e "${CYAN}🛡️  PF STATE${RESET}"
  sudo pfctl -s info 2>/dev/null | grep -E "Status|Enabled|Debug" || echo -e "${RED}Requires sudo${RESET}"
}

check_latency() {
  log "INFO" "Ping latency to ${DEFAULT_DNS}..."
  local avg
  avg=$(ping -c 3 -t 2 "$DEFAULT_DNS" 2>/dev/null | tail -1 | awk -F/ '{print $5}')
  echo -e "${CYAN}📡 LATENCY${RESET}\n${EMOJI_OK} ${GREEN}Avg: ${avg:-N/A} ms${RESET}"
}

main() {
  parse_args "$@"
  print_header
  check_interfaces
  check_dns
  check_ports
  check_latency
  [[ "$CHECK_FIREWALL" == true ]] && check_firewall
  echo -e "\n${CYAN}✨ Network audit completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
}

main "$@"