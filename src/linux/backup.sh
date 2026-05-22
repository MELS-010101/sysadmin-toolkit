#!/usr/bin/env bash
# Module: Backup Configs

VERSION="1.0.0"
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
RESET='\033[0m'

SOURCE_DIR="$1"
BACKUP_NAME="${2:-backup_$(date +%Y-%m-%d_%H-%M-%S)}"

if [ -z "$SOURCE_DIR" ]; then
  echo -e "${RED}Usage: sat backup <source_dir> [backup_name]${RESET}"
  exit 1
fi

if [ ! -d "$SOURCE_DIR" ]; then
  echo -e "${RED}Error: Directory $SOURCE_DIR not found${RESET}"
  exit 1
fi

echo -e "${YELLOW}Starting backup of $SOURCE_DIR...${RESET}"
mkdir -p "$BACKUP_NAME"
cp -r "$SOURCE_DIR"/* "$BACKUP_NAME/" 2>/dev/null

# Create tarball
tar -czf "${BACKUP_NAME}.tar.gz" "$BACKUP_NAME" 2>/dev/null
rm -rf "$BACKUP_NAME"

if [ -f "${BACKUP_NAME}.tar.gz" ]; then
  SIZE=$(du -h "${BACKUP_NAME}.tar.gz" | cut -f1)
  echo -e "${GREEN}Backup created: ${BACKUP_NAME}.tar.gz ($SIZE)${RESET}"
else
  echo -e "${RED}Backup failed${RESET}"
fi
