@'
#!/usr/bin/env bash
# ==============================================================================
# Module: System Health Monitor
# OS: Linux (Ubuntu/Debian/RHEL)
# Style: Google Bash Style Guide + ShellDoc
# ==============================================================================
# Подключение библиотек
readonly TOOLKIT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)"
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

# ANSI Colors & Emojis
readonly RED='\033[0;31m'
readonly GREEN='\033[0;32m'
readonly YELLOW='\033[0;33m'
readonly CYAN='\033[0;36m'
readonly RESET='\033[0m'
readonly EMOJI_START=""
readonly EMOJI_OK="✅"
readonly EMOJI_WARN="⚠️"
readonly EMOJI_ERR="🚨"

# @description Prints ASCII logo, version and stylized header
print_header() {
  cat << 'EOF'
  ╔════════════════════════════════════════════════════════════╗
  ║          ____  _      _   ____  ___   ___                  ║
  ║         / ___|| |__  | | / ___|/ _ \/  _ \                 ║
  ║         \___ \| '_ \ | || |   | | | | | | |                ║
  ║          ___) | | | || || |___| |_| | |_| |                ║
  ║         |____/|_| |_||_| \____|\___/ \___/                 ║
  ║                                                            ║
  ║           SysAdmin-Toolkit | System Health Module          ║
  ╚════════════════════════════════════════════════════════════╝
EOF
  echo -e "${CYAN}🛠️  Version: ${VERSION} | Platform: Linux${RESET}\n"
}

# @description Displays structured man-like help with production tips
show_help() {
  cat << EOF
${CYAN}USAGE${RESET}
  ./system_health.sh [OPTIONS]

${CYAN}OPTIONS${RESET}
  -h, --help      Show this help message and exit
  -v, --version   Show version and exit

${CYAN}EXAMPLES${RESET}
  # Run full health check
  ./system_health.sh

  # Check version
  ./system_health.sh --version

${YELLOW}💡 PRODUCTION TIPS${RESET}
  • Run via cron for automated daily reports: 0 2 * * * /opt/toolkit/linux/system_health.sh >> /var/log/sa_health.log
  • Combine with 'watch' for live monitoring: watch -n 5 ./system_health.sh
  • Ensure sudo access for accurate service & process metrics.
EOF
  exit 0
}

# @description Checks disk usage and triggers alert if > threshold
check_disk() {
  echo -e "${CYAN}📦 DISK USAGE${RESET}"
  local disk_usage
  # FIX: Moved || true outside to avoid syntax error in subshell
  disk_usage=$(df -h --output=pcent,source,target 2>/dev/null | grep -vE '^(Filesystem|tmpfs|cdrom|devfs|overlay)' | sort -t ' ' -k1 -rn) || disk_usage=""
  
  if [[ -z "$disk_usage" ]]; then
    echo -e "${EMOJI_WARN} ${YELLOW}Could not retrieve disk usage information${RESET}"
    echo
    return
  fi
  
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    local usage_pct target
    usage_pct=$(echo "$line" | awk '{print $1}' | tr -d '%')
    target=$(echo "$line" | awk '{print $3}')
    
    # Skip if usage_pct is not a number
    if ! [[ "$usage_pct" =~ ^[0-9]+$ ]]; then
      continue
    fi
    
    if [[ "$usage_pct" -ge "$DISK_ALERT_THRESHOLD" ]]; then
      echo -e "${EMOJI_ERR} ${RED}[CRITICAL] ${target}: ${usage_pct}% used (Threshold: ${DISK_ALERT_THRESHOLD}%)${RESET}"
    else
      echo -e "${EMOJI_OK} ${GREEN}${target}: ${usage_pct}% used${RESET}"
    fi
  done <<< "$disk_usage"
  echo
}

# @description Checks CPU load average and RAM usage
check_cpu_ram() {
  echo -e "${CYAN}⚡ CPU & MEMORY${RESET}"
  
  # Check CPU load
  if [[ -f /proc/loadavg ]]; then
    local load_avg
    load_avg=$(awk '{print $1, $2, $3}' /proc/loadavg)
    echo -e "${EMOJI_OK} Load Average (1/5/15m): ${YELLOW}${load_avg}${RESET}"
  else
    echo -e "${EMOJI_WARN} ${YELLOW}Could not read CPU load information${RESET}"
  fi
  
  # Check RAM usage
  if [[ -f /proc/meminfo ]]; then
    local mem_total mem_available mem_used_pct
    mem_total=$(grep MemTotal /proc/meminfo | awk '{print $2}')
    mem_available=$(grep MemAvailable /proc/meminfo | awk '{print $2}')
    
    if [[ -n "$mem_total" && -n "$mem_available" && "$mem_total" -gt 0 ]]; then
      mem_used_pct=$(( (mem_total - mem_available) * 100 / mem_total ))
      echo -e "${EMOJI_OK} RAM Usage: ${YELLOW}${mem_used_pct}%${RESET} (${mem_available}KB available)"
    else
      echo -e "${EMOJI_WARN} ${YELLOW}Could not calculate RAM usage${RESET}"
    fi
  else
    echo -e "${EMOJI_WARN} ${YELLOW}Could not read memory information${RESET}"
  fi
  echo
}

# @description Checks for failed systemctl services
check_services() {
  echo -e "${CYAN}⚙️  SYSTEM SERVICES${RESET}"
  
  if ! command -v systemctl &>/dev/null; then
    echo -e "${EMOJI_WARN} ${YELLOW}systemctl not found, skipping service check${RESET}"
    echo
    return
  fi
  
  local failed_services
  failed_services=$(systemctl --failed --no-legend --no-pager 2>/dev/null || true)
  
  if [[ -z "$failed_services" ]]; then
    echo -e "${EMOJI_OK} ${GREEN}All critical services are running.${RESET}"
  else
    echo -e "${EMOJI_ERR} ${RED}Failed Services Detected:${RESET}"
    echo "$failed_services" | awk '{printf "  %s (%s)\n", $1, $3}'
  fi
  echo
}

# @description Displays top 5 CPU-consuming processes
check_top_processes() {
  echo -e "${CYAN}📊 TOP 5 CPU PROCESSES${RESET}"
  
  if command -v ps &>/dev/null; then
    ps aux --sort=-%cpu 2>/dev/null | head -6 | tail -5 | awk '{printf "%-8s %-10s %5s%%  %s\n", $1, $2, $3, $11}' || true
  else
    echo -e "${EMOJI_WARN} ${YELLOW}ps command not found${RESET}"
  fi
  echo
}

# @description Main execution flow
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
'@ | Set-Content "src/linux/system_health.sh" -Encoding UTF8

# Обновляем версию до 1.4.2
$json = Get-Content "package.json" | ConvertFrom-Json
$json.version = "1.4.2"
$json | ConvertTo-Json -Depth 10 | Set-Content "package.json"

$xml = [xml](Get-Content "packaging\nuget\sysadmin-toolkit.nuspec")
$xml.package.metadata.version = "1.4.2"
$xml.Save("packaging\nuget\sysadmin-toolkit.nuspec")

git add -A
git commit -m "fix: move || true outside subshell to fix syntax error (v1.4.2)"
git tag v1.4.2
git push origin main
git push origin v1.4.2