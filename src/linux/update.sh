#!/usr/bin/env bash
# Module: Auto Update

VERSION="1.0.0"
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

echo -e "${YELLOW}Checking for updates via npm...${RESET}"
npm update -g @mels-010101/sysadmin-toolkit
echo -e "${GREEN}Update check completed.${RESET}"
sat --version
