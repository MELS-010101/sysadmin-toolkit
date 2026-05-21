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
SHOW_ALL=false
CHECK_FIREWALL=false
TARGET_DNS=""
TARGET_PORT=""

print_header() {
  cat << 'EOF'
  ╔══════════════════════════════════════════════════════════╗
  ║          ____  _      _   ____  ___  ___                 
  ║         / ___|| |__  | | / ___|/ _ \/ _ \                ║
  ║         \___ \| '_ \ | || |   | | | | | |               ║
  ║          ___) | | | || || |___| |_| | |_| |              ║
  ║         |____/|_| |_||_| \____|\___/ \___/               ║
  ║                                                          ║
  ║           SysAdmin-Toolkit | Network Audit Module         ║
  ╚══════════════════════════════════════════════════════════╝
EOF
  echo -e "${CYAN}️  Version: ${VERSION} | Platform: Linux${RESET}\n"
}

show_help() {
  cat << EOF
${CYAN}USAGE${RESET}
  ./net_audit.sh [OPTIONS]

${CYAN}OPTIONS${RESET}
  -a, --all             Run full network audit
  -f, --firewall        Dump & validate firewall rules (iptables/nft)
  --dns <host|ip>       Test DNS resolution (default: ${DEFAULT_DNS})
  --port <host:port>    Test TCP port connectivity (default: ${DEFAULT_PORT})
  --format json         Output in JSON format
  -h, --help            Show this guide

${YELLOW}💡 PRODUCTION TIPS${RESET}
  • Combine with cron for daily network baseline: 0 4 * * * /opt/sat/bin/sat net-audit --all --format json >> /var/log/sat-net.json
  • Use 'ip -j' for machine-readable output in automation pipelines.
  • Firewall dump requires root: sudo ./net_audit.sh --firewall
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
  log "INFO" "Scanning network interfaces..."
  if [[ "$FORMAT" == "json" ]]; then
    ip -j addr show 2>/dev/null | jq -c '.[] | {name: .ifname, state: .operstate, ipv4: [.addr_info[] | select(.family=="inet") | .local]}'
  else
    echo -e "${CYAN}🌐 INTERFACES${RESET}"
    ip -brief addr show | while read -r iface status addrs; do
      local color="$GREEN"
      [[ "$status" == "DOWN" ]] && color="$RED"
      echo -e "${color}• ${iface} [${status}] ${addrs}${RESET}"
    done
  fi
}

check_dns() {
  local host="${TARGET_DNS:-$DEFAULT_DNS}"
  log "INFO" "Testing DNS resolution for: ${host}"
  local result
  result=$(dig +short "$host" 2>/dev/null || nslookup "$host" 2>/dev/null | grep -A1 "Name:" | tail -1 | awk '{print $2}')
  if [[ -n "$result" ]]; then
    if [[ "$FORMAT" == "json" ]]; then
      echo -n "\"dns_${host}\": \"${result}\","
    else
      echo -e "${CYAN} DNS CHECK${RESET}\n${EMOJI_OK} ${GREEN}${host} → ${result}${RESET}"
    fi
  else
    log "WARN" "DNS resolution failed for ${host}"
    [[ "$FORMAT" == "json" ]] && echo -n "\"dns_${host}\": \"FAILED\","
  fi
}

check_ports() {
  local target="${TARGET_PORT:-localhost:${DEFAULT_PORT}}"
  local host="${target%%:*}"
  local port="${target##*:}"
  log "INFO" "Testing TCP connectivity: ${host}:${port}"
  if timeout 3 bash -c "echo >/dev/tcp/${host}/${port}" 2>/dev/null; then
    if [[ "$FORMAT" == "json" ]]; then
      echo -n "\"port_${host}_${port}\": \"OPEN\","
    else
      echo -e "${CYAN}🔌 PORT CHECK${RESET}\n${EMOJI_OK} ${GREEN}${host}:${port} is reachable${RESET}"
    fi
  else
    log "WARN" "Port ${host}:${port} unreachable or filtered"
    [[ "$FORMAT" == "json" ]] && echo -n "\"port_${host}_${port}\": \"CLOSED/FILTERED\","
  fi
}

check_firewall() {
  if ! command -v sudo &>/dev/null || ! sudo -n true 2>/dev/null; then
    log "WARN" "Root required for firewall dump. Skipping or run with sudo."
    return 0
  fi
  log "INFO" "Dumping firewall rules..."
  if command -v nft &>/dev/null; then
    echo -e "${CYAN}🛡️  NFTABLES RULES${RESET}"
    sudo nft list ruleset 2>/dev/null | head -20
    echo -e "${YELLOW}... (truncated, use --firewall --format json for full dump)${RESET}"
  elif command -v iptables &>/dev/null; then
    echo -e "${CYAN}🛡️  IPTABLES RULES${RESET}"
    sudo iptables -L -n -v --line-numbers | head -30
  fi
}

check_latency() {
  log "INFO" "Measuring latency to ${DEFAULT_DNS}..."
  local ping_out
  ping_out=$(ping -c 3 -W 2 "$DEFAULT_DNS" 2>/dev/null | tail -1 | awk -F/ '{print $5}')
  if [[ -n "$ping_out" ]]; then
    if [[ "$FORMAT" == "json" ]]; then
      echo -n "\"avg_latency_ms\": \"${ping_out}\","
    else
      echo -e "${CYAN}📡 LATENCY${RESET}\n${EMOJI_OK} ${GREEN}Avg: ${ping_out} ms${RESET}"
    fi
  else
    log "WARN" "Ping failed"
    [[ "$FORMAT" == "json" ]] && echo -n "\"avg_latency_ms\": \"N/A\","
  fi
}

main() {
  parse_args "$@"
  [[ "$FORMAT" == "json" ]] && echo "{"
  print_header
  check_interfaces
  check_dns
  check_ports
  check_latency
  [[ "$CHECK_FIREWALL" == true ]] && check_firewall
  if [[ "$FORMAT" == "json" ]]; then
    echo "\"timestamp\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\""
    echo "}"
  else
    echo -e "\n${CYAN}✨ Network audit completed at $(date '+%Y-%m-%d %H:%M:%S')${RESET}"
  fi
}

main "$@"