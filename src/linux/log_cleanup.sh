#!/usr/bin/env bash
# ==============================================================================
# Module: Log Rotation & Cleanup
# OS: Linux (Ubuntu/Debian/RHEL)
# Style: Google Bash Style Guide + ShellDoc
# ==============================================================================
set -euo pipefail

readonly VERSION="1.0.0"
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly TOOLKIT_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

# Подключение библиотек
source "${TOOLKIT_ROOT}/lib/logging.sh"
source "${TOOLKIT_ROOT}/lib/config.sh"

load_config "${HOME}/.config/sat/config.conf" 2>/dev/null || true

# @description Default configuration
readonly DEFAULT_DAYS="${SAT_LOG_DAYS:-30}"
readonly DEFAULT_PATTERN="${SAT_LOG_PATTERN:-*.log}"
readonly DEFAULT_ARCHIVE_DIR="${SAT_ARCHIVE_DIR:-/var/log/sat-archive}"
readonly DEFAULT_MAX_SIZE_MB="${SAT_LOG_MAX_SIZE_MB:-100}"

# Flags
DRY_RUN=false
FORCE=false
UPLOAD_S3=""
TARGET_DIR="/var/log"

# @description Prints ASCII header
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
  echo -e "${CYAN}🛠️  Version: ${VERSION} | Platform: Linux${RESET}\n"
}

# @description Man-like help with production tips
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
  -f, --force             Skip interactive confirmation for deletion
  --dir <path>            Target directory to scan (default: ${TARGET_DIR})
  -h, --help              Show this help

${YELLOW}💡 PRODUCTION TIPS${RESET}
  • Always run with --dry-run first: ./log_cleanup.sh --dir /var/log/app --dry-run
  • Combine with cron: 0 3 * * 0 /opt/sat/bin/sat log-clean --dir /var/log/app --upload-s3 logs-bucket
  • Ensure archive directory has same ownership/permissions as source: chown syslog:adm ${DEFAULT_ARCHIVE_DIR}
EOF
  exit 0
}

# @description Parses CLI arguments
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

# @description Validates environment and dependencies
validate() {
  if [[ ! -d "$TARGET_DIR" ]]; then
    log "FATAL" "Target directory does not exist: ${TARGET_DIR}"; exit 1
  fi
  mkdir -p "${DEFAULT_ARCHIVE_DIR}" 2>/dev/null || { log "ERROR" "Cannot create archive dir"; exit 1; }
  
  if [[ -n "$UPLOAD_S3" ]] && ! command -v aws &>/dev/null; then
    log "ERROR" "AWS CLI required for S3 sync. Install via: apt install awscli"; exit 1
  fi
}

# @description Finds, compresses and archives logs
process_logs() {
  log "INFO" "Scanning: ${TARGET_DIR} | Pattern: ${DEFAULT_PATTERN} | Age > ${DEFAULT_DAYS}d | Size > ${DEFAULT_MAX_SIZE_MB}MB"
  
  local count=0
  local find_args=("${TARGET_DIR}" -type f -name "${DEFAULT_PATTERN}" \( -mtime +"${DEFAULT_DAYS}" -o -size +"${DEFAULT_MAX_SIZE_MB}M" \))
  
  while IFS= read -r -d '' file; do
    count=$((count + 1))
    local basename_file
    basename_file="$(basename "$file")"
    local archive_name="${DEFAULT_ARCHIVE_DIR}/${basename_file}.$(date -u +%Y%m%d).gz"
    
    log "INFO" "Processing: ${file} -> ${archive_name}"
    
    if [[ "$DRY_RUN" == false ]]; then
      gzip -c "$file" > "${archive_name}" || { log "WARN" "Compression failed for: ${file}"; continue; }
      # Безопасное удаление только после успешной архивации
      rm -f "$file"
      log "INFO" "✅ Archived & cleaned: ${basename_file}"
    else
      log "WARN" "[DRY-RUN] Would compress & delete: ${file}"
    fi
  done < <(find "${find_args[@]}" -print0 2>/dev/null)
  
  log "INFO" "Processed ${count} files."
}

# @description Syncs archive to S3/MinIO
sync_to_s3() {
  if [[ -z "$UPLOAD_S3" || "$DRY_RUN" == true ]]; then
    log "INFO" "Skipping S3 sync (dry-run or no bucket specified)."
    return 0
  fi
  
  log "INFO" "Syncing archive to s3://${UPLOAD_S3}/sat-logs/"
  if [[ -n "${AWS_ENDPOINT_URL:-}" ]]; then
    log "INFO" "Using MinIO/Custom endpoint: ${AWS_ENDPOINT_URL}"
  fi
  
  aws s3 sync "${DEFAULT_ARCHIVE_DIR}" "s3://${UPLOAD_S3}/sat-logs/" \
    --storage-class STANDARD_IA \
    --delete \
    --only-show-errors 2>/dev/null && log "INFO" "✅ S3 sync completed." || log "ERROR" "❌ S3 sync failed."
}

# @description Main execution flow
main() {
  parse_args "$@"
  print_header
  validate
  
  if [[ "$DRY_RUN" == false && "$FORCE" == false ]]; then
    echo -e "${YELLOW}⚠️  This action will permanently delete logs. Press ENTER to continue or Ctrl+C to abort.${RESET}"
    read -r
  fi

  log "INFO" "Starting log cleanup..."
  process_logs
  sync_to_s3
  log "INFO" "🎉 Cleanup completed at $(date '+%Y-%m-%d %H:%M:%S')"
}

main "$@"