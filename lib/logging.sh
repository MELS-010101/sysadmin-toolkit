# lib/logging.sh - РљСЂРѕСЃСЃРїР»Р°С‚С„РѕСЂРјРµРЅРЅС‹Р№ Р»РѕРіРіРµСЂ СЃ СѓСЂРѕРІРЅСЏРјРё Рё ANSI-С†РІРµС‚Р°РјРё
set -euo pipefail

readonly LOG_LEVEL_DEBUG=0
readonly LOG_LEVEL_INFO=1
readonly LOG_LEVEL_WARN=2
readonly LOG_LEVEL_ERROR=3
readonly LOG_LEVEL_FATAL=4

# РџРµСЂРµРѕРїСЂРµРґРµР»СЏРµС‚СЃСЏ С‡РµСЂРµР· ENV: export SAT_LOG_LEVEL=0 (DEBUG)
readonly SAT_LOG_LEVEL="${SAT_LOG_LEVEL:-1}"

readonly COLOR_RESET="\033[0m"
readonly COLOR_DEBUG="\033[38;5;244m"
readonly COLOR_INFO="\033[0;32m"
readonly COLOR_WARN="\033[0;33m"
readonly COLOR_ERROR="\033[0;31m"
readonly COLOR_FATAL="\033[0;91m\033[1m"

# @description Logs message with timestamp, level, emoji and color to stderr
log() {
  local level="$1" message="$2" level_code color emoji
  case "$level" in
    DEBUG)  level_code=$LOG_LEVEL_DEBUG; color="$COLOR_DEBUG"; emoji="рџ”Ќ" ;;
    INFO)   level_code=$LOG_LEVEL_INFO;  color="$COLOR_INFO";  emoji="в„№пёЏ" ;;
    WARN)   level_code=$LOG_LEVEL_WARN;  color="$COLOR_WARN";  emoji="вљ пёЏ" ;;
    ERROR)  level_code=$LOG_LEVEL_ERROR; color="$COLOR_ERROR"; emoji="рџљЁ" ;;
    FATAL)  level_code=$LOG_LEVEL_FATAL; color="$COLOR_FATAL"; emoji="рџ’Ђ" ;;
    *)      echo -e "${COLOR_ERROR}[UNKNOWN] Invalid log level: ${level}${COLOR_RESET}" >&2; return 1 ;;
  esac

  if (( level_code >= SAT_LOG_LEVEL )); then
    local ts
    ts="$(date '+%Y-%m-%d %H:%M:%S')"
    echo -e "${color}[${ts}] ${emoji} ${level^^} ${COLOR_RESET}${message}" >&2
  fi
}
