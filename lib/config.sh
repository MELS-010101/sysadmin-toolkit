#!/usr/bin/env bash
# lib/config.sh - Безопасный парсер key=value конфигов без eval()
set -euo pipefail

# @description Loads .conf/.env files safely. Exports as SAT_KEY=value
# @example load_config "~/.config/sat/config.conf"
load_config() {
  local config_file="${1:?Config file path required}"
  
  if [[ ! -f "$config_file" ]]; then
    log "WARN" "Config not found: ${config_file}. Using defaults."
    return 0
  fi

  log "DEBUG" "Loading config: ${config_file}"
  while IFS='=' read -r key value || [[ -n "$key" ]]; do
    # Пропуск комментариев и пустых строк
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue

    # Очистка пробелов и кавычек
    key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^["'\'']\(.*\)["'\'']$/\1/')

    # Безопасная валидация имени переменной
    if [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
      export "SAT_${key^^}"="$value"
    else
      log "WARN" "Invalid config key skipped: ${key}"
    fi
  done < "$config_file"
}