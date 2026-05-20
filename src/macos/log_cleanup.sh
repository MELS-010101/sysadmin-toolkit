#!/usr/bin/env bash
set -euo pipefail

readonly VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TOOLKIT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${TOOLKIT_ROOT}/lib/logging.sh"
source "${TOOLKIT_ROOT}/lib/config.sh"
load_config "${HOME}/.config/sat/config.conf" 2>/dev/null || true

readonly DEFAULT_DAYS="${SAT_LOG_DAYS:-30}"
readonly DEFAULT_PATTERN="${SAT_LOG_PATTERN:-*.log}"
readonly DEFAULT_ARCHIVE_DIR="${SAT_ARCHIVE_DIR:-/var/log/sat-archive}"
readonly DEFAULT_MAX_SIZE_MB="${SAT_LOG_MAX_SIZE_MB:-100}"

DRY_RUN=false
FORCE=false
UPLOAD_S3=""
TARGET_DIR="/var/log"

print_header() {
  cat << 'EOF'
  ╔══════════════════════════════════════════════════════════╗
  ║          ____  _      _   ____  ___  ___                 ║
  ║         / ___|| |__  | | / ___|/ _ \/  _ \               ║
  ║         \___ \| '_ \ | || |   | | | | | | |              ║
  ║          ___) | | | || || |___| |_| | |_| |              ║
  ║         |____/|_| |_||_| \____|\___/ \___/               ║
  ║                                                          ║
  ║           SysAdmin-Toolkit | Log Cleanup Module          ║
  ╚══════════════════════════════════════════════════════════╝
EOF
  echo -e "${CYAN}🛠️  Version: ${VERSION} | Platform: macOS${RESET}\n"
}

show_help() {
  cat << EOF
${CYAN}USAGE${RESET}
  ./log_cleanup.sh [OPTIONS] --dir <path>

${CYAN}OPTIONS${RESET}
  -d, --days <int>        Archive logs older than N days (default: ${DEFAULT_DAYS})
  -p, --pattern <glob>    File pattern to match (default: ${DEFAULT_PATTERN})
  -s, --max-size <MB>     Rotate files larger than N MB (default: ${DEFAULT_MAX_SIZE_MB})
  -a, --archive <path>    Directory for archived logs (default: ${DEFAULT_ARCHIVE_DIR})
  --upload-s3 <bucket>    Sync archive to S3/MinIO (requires 'aws' CLI)
  --dry-run               Simulate actions without modifying files
  -f, --force             Skip interactive confirmation
  --dir <path>            Target directory to scan (default: ${TARGET_DIR})
  -h, --help              Show this help

${YELLOW}💡 PRODUCTION TIPS${RESET}
  • macOS Unified Logging is separate. This module targets file-based logs (/var/log, /Library/Logs).
  • Use 'sudo' for system logs: sudo ./log_cleanup.sh --dir /var/log
  • Archive retention: combine with 'tmutil' or Time Machine for long-term compliance.
EOF
  exit 0
}

parse_args() {
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -d|--days)        DEFAULT_DAYS="$2"; shift 2 ;;
      -p|--pattern)     DEFAULT_PATTERN="$2"; shift 2 ;;
      -s|--max-size)    DEFAULT_MAX_SIZE_MB="$2"; shift 2 ;;
      -a|--archive)     DEFAULT_ARCHIVE_DIR="$2"; shift 2 ;;
      --upload-s3)      UPLOAD_S3="$2"; shift 2 ;;
      --dry-run)        DRY_RUN=true; shift ;;
      -f|--force)       FORCE=true; shift ;;
      --dir)            TARGET_DIR="$2"; shift 2 ;;
      -h|--help)        show_help ;;
      *)                log "ERROR" "Unknown argument: $1"; exit 1 ;;
    esac
  done
}

validate() {
  [[ ! -d "$TARGET_DIR" ]] && { log "FATAL" "Target directory missing: ${TARGET_DIR}"; exit 1; }
  mkdir -p "${DEFAULT_ARCHIVE_DIR}"
  [[ -n "$UPLOAD_S3" ]] && ! command -v aws &>/dev/null && { log "ERROR" "AWS CLI required"; exit 1; }
}

process_logs() {
  log "INFO" "Scanning: ${TARGET_DIR} | Pattern: ${DEFAULT_PATTERN} | Age > ${DEFAULT_DAYS}d"
  local count=0
  
  # BSD find совместимость: -mtime +N работает идентично GNU
  while IFS= read -r -d '' file; do
    count=$((count + 1))
    local basename_file
    basename_file="$(basename "$file")"
    # macOS date: -u для UTC, %Y%m%d стандартно
    local archive_name="${DEFAULT_ARCHIVE_DIR}/${basename_file}.$(date -u +%Y%m%d).gz"
    
    log "INFO" "Processing: ${file}"
    if [[ "$DRY_RUN" == false ]]; then
      gzip -c "$file" > "${archive_name}" && rm -f "$file"
      log "INFO" "✅ Archived & cleaned: ${basename_file}"
    else
      log "WARN" "[DRY-RUN] Would archive: ${file}"
    fi
  done < <(find "${TARGET_DIR}" -type f -name "${DEFAULT_PATTERN}" -mtime +"${DEFAULT_DAYS}" -print0 2>/dev/null)
  
  log "INFO" "Processed ${count} files."
}

sync_to_s3() {
  [[ -z "$UPLOAD_S3" || "$DRY_RUN" == true ]] && { log "INFO" "Skipping S3 sync."; return 0; }
  log "INFO" "Syncing to s3://${UPLOAD_S3}/sat-logs/"
  aws s3 sync "${DEFAULT_ARCHIVE_DIR}" "s3://${UPLOAD_S3}/sat-logs/" --storage-class STANDARD_IA --only-show-errors 2>/dev/null && log "INFO" "✅ S3 sync completed." || log "ERROR" "❌ S3 sync failed."
}

main() {
  parse_args "$@"
  print_header
  validate
  
  if [[ "$DRY_RUN" == false && "$FORCE" == false ]]; then
    echo -e "${YELLOW}⚠️  Proceed with log cleanup? [y/N]${RESET}"
    read -r -n 1 -s reply
    [[ "$reply" != [yY] ]] && { echo -e "\n${RED}Aborted.${RESET}"; exit 0; }
    echo
  fi

  log "INFO" "Starting log cleanup..."
  process_logs
  sync_to_s3
  log "INFO" "🎉 Cleanup completed at $(date '+%Y-%m-%d %H:%M:%S')"
}

main "$@"