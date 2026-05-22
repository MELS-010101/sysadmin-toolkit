# Module: SSL Checker

VERSION="1.0.0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

DOMAIN="$1"
PORT="${2:-443}"

if [ -z "$DOMAIN" ]; then
  echo -e "${RED}Usage: sat ssl <domain> [port]${RESET}"
  exit 1
fi

if ! command -v openssl &> /dev/null; then
  echo -e "${RED}openssl is required${RESET}"
  exit 1
fi

echo -e "${YELLOW}Checking SSL for $DOMAIN:$PORT...${RESET}"

# Get expiry date
EXPIRY=$(echo | openssl s_client -servername $DOMAIN -connect $DOMAIN:$PORT 2>/dev/null | openssl x509 -noout -enddate 2>/dev/null | cut -d= -f2)

if [ -z "$EXPIRY" ]; then
  echo -e "${RED}Could not retrieve certificate info${RESET}"
else
  echo -e "${GREEN}Certificate expires: $EXPIRY${RESET}"
  
  # Check days left
  EXP_DATE=$(date -d "$EXPIRY" +%s 2>/dev/null)
  NOW=$(date +%s)
  DIFF=$(( (EXP_DATE - NOW) / 86400 ))
  
  if [ "$DIFF" -lt 30 ]; then
    echo -e "${RED}Warning: Certificate expires in $DIFF days!${RESET}"
  else
    echo -e "${GREEN}Certificate valid for $DIFF days${RESET}"
  fi
fi
