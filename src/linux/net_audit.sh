#!/usr/bin/env bash
# Module: Network Audit

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh" 2>/dev/null || true
source "${TOOLKIT_ROOT}/lib/config.sh" 2>/dev/null || true

VERSION="1.0.0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

check_dns() {
  echo -e "${YELLOW}Checking DNS resolution...${RESET}"
  if nslookup google.com >/dev/null 2>&1; then
    echo -e "  ${GREEN}DNS resolution: OK${RESET}"
  else
    echo -e "  ${RED}DNS resolution: FAILED${RESET}"
  fi
  echo ""
}

check_connectivity() {
  echo -e "${YELLOW}Checking connectivity (ping 8.8.8.8)...${RESET}"
  if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
    echo -e "  ${GREEN}Connectivity: OK${RESET}"
  else
    echo -e "  ${RED}Connectivity: FAILED${RESET}"
  fi
  echo ""
}

check_interfaces() {
  echo -e "${YELLOW}Network Interfaces:${RESET}"
  if command -v ip >/dev/null 2>&1; then
    ip addr show 2>/dev/null | grep -E "inet |state " || true
  elif command -v ifconfig >/dev/null 2>&1; then
    ifconfig 2>/dev/null | grep -E "inet |UP " || true
  fi
  echo ""
}

main() {
  echo ""
  echo "  SysAdmin-Toolkit | Network Audit Module"
  echo "  Version: ${VERSION}"
  echo ""
  
  check_dns
  check_connectivity
  check_interfaces
  
  echo -e "${GREEN}Audit completed.${RESET}"
}

main "$@"