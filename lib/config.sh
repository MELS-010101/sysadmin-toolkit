# lib/config.sh - Р‘РµР·РѕРїР°СЃРЅС‹Р№ РїР°СЂСЃРµСЂ key=value РєРѕРЅС„РёРіРѕРІ Р±РµР· eval()
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
    # РџСЂРѕРїСѓСЃРє РєРѕРјРјРµРЅС‚Р°СЂРёРµРІ Рё РїСѓСЃС‚С‹С… СЃС‚СЂРѕРє
    [[ "$key" =~ ^[[:space:]]*# ]] && continue
    [[ -z "$key" ]] && continue

    # РћС‡РёСЃС‚РєР° РїСЂРѕР±РµР»РѕРІ Рё РєР°РІС‹С‡РµРє
    key=$(echo "$key" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
    value=$(echo "$value" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//;s/^["'\'']\(.*\)["'\'']$/\1/')

    # Р‘РµР·РѕРїР°СЃРЅР°СЏ РІР°Р»РёРґР°С†РёСЏ РёРјРµРЅРё РїРµСЂРµРјРµРЅРЅРѕР№
    if [[ "$key" =~ ^[a-zA-Z_][a-zA-Z0-9_]*$ ]]; then
      export "SAT_${key^^}"="$value"
    else
      log "WARN" "Invalid config key skipped: ${key}"
    fi
  done < "$config_file"
}
