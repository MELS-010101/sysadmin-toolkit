#!/usr/bin/env bash
# bin/sat - Cross-platform entry point
set -euo pipefail

readonly TOOLKIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
readonly VERSION="1.0.0"

detect_os() {
  case "$(uname -s)" in
    Linux*)   echo "linux" ;;
    Darwin*)  echo "macos" ;;
    CYGWIN*|MINGW*|MSYS*) echo "windows" ;;
    *)        echo "unknown" ;;
  esac
}

main() {
  local os
  os="$(detect_os)"
  
  if [[ "$os" == "windows" ]]; then
    # PowerShell entry
    exec pwsh -NoProfile -ExecutionPolicy Bypass -File "${TOOLKIT_DIR}/src/windows/System-Health.ps1" "$@"
  else
    # Unix entry
    exec bash "${TOOLKIT_DIR}/src/${os}/system_health.sh" "$@"
  fi
}

main "$@"