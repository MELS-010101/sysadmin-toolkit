# Module: Security Audit

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh" 2>/dev/null || true
source "${TOOLKIT_ROOT}/lib/config.sh" 2>/dev/null || true

VERSION="1.0.0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

check_users() {
  echo -e "${YELLOW}Checking users with UID 0 (root privileges)...${RESET}"
  awk -F: '($3 == 0) {print "  User: " $1 " is root"}' /etc/passwd
  echo ""
}

check_ports() {
  echo -e "${YELLOW}Checking listening ports...${RESET}"
  if command -v ss >/dev/null 2>&1; then
    ss -tulpn 2>/dev/null | head -20
  elif command -v netstat >/dev/null 2>&1; then
    netstat -tulpn 2>/dev/null | head -20
  else
    echo "  ss or netstat command not found"
  fi
  echo ""
}

check_permissions() {
  echo -e "${YELLOW}Checking world-writable files in /etc (example)...${RESET}"
  find /etc -perm -o+w -type f 2>/dev/null | head -10 || true
  echo ""
}

main() {
  echo ""
  echo "  SysAdmin-Toolkit | Security Audit Module"
  echo "  Version: ${VERSION}"
  echo ""
  
  check_users
  check_ports
  check_permissions
  
  echo -e "${GREEN}Audit completed.${RESET}"
}

main "$@"