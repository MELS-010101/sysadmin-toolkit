# Module: Log Cleanup

TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh" 2>/dev/null || true
source "${TOOLKIT_ROOT}/lib/config.sh" 2>/dev/null || true

VERSION="1.0.0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

# Defaults
TARGET_DIR="/var/log"
DAYS=30

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --dir)
      TARGET_DIR="$2"
      shift 2
      ;;
    --days)
      DAYS="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

cleanup() {
  echo -e "${YELLOW}Starting cleanup for: ${TARGET_DIR} (older than ${DAYS} days)...${RESET}"
  
  if [ ! -d "$TARGET_DIR" ]; then
    echo -e "${RED}Error: Directory ${TARGET_DIR} not found.${RESET}"
    return 1
  fi

  # Attempt to find and delete
  # 2>/dev/null suppresses permission errors which are common on Linux
  count=$(find "$TARGET_DIR" -name "*.log" -mtime +${DAYS} -type f 2>/dev/null | wc -l)
  
  if [ "$count" -gt 0 ]; then
    echo -e "${GREEN}Found ${count} log files to delete.${RESET}"
    find "$TARGET_DIR" -name "*.log" -mtime +${DAYS} -type f -delete 2>/dev/null
    echo -e "${GREEN}Cleanup completed.${RESET}"
  else
    echo -e "${GREEN}No old log files found.${RESET}"
  fi
}

main() {
  echo ""
  echo "  SysAdmin-Toolkit | Log Cleanup Module"
  echo "  Version: ${VERSION}"
  echo ""
  
  cleanup
  
  echo ""
}

main "$@"