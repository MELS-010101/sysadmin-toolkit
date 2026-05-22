# Module: Docker Manager

VERSION="1.0.0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

if ! command -v docker &> /dev/null; then
  echo -e "${RED}Docker is not installed or not in PATH${RESET}"
  exit 1
fi

echo ""
echo "  SysAdmin-Toolkit | Docker Manager"
echo ""

echo -e "${YELLOW}Running Containers:${RESET}"
docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}" 2>/dev/null || echo "  None"
echo ""

echo -e "${YELLOW}Docker Disk Usage:${RESET}"
docker system df 2>/dev/null | head -5
echo ""

echo -e "${GREEN}Docker check completed.${RESET}"
