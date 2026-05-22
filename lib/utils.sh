#!/usr/bin/env bash
# Utility functions for SysAdmin-Toolkit

# Load configuration file
# Usage: load_config <path> [default_path]
load_config() {
    local config_file="$1"
    local default_file="${2:-}"
    
    if [ -f "$config_file" ]; then
        # Simple key=value loader
        set -a
        source "$config_file" 2>/dev/null || true
        set +a
        return 0
    elif [ -n "$default_file" ] && [ -f "$default_file" ]; then
        set -a
        source "$default_file" 2>/dev/null || true
        set +a
        return 0
    fi
    return 1
}

# Format output as JSON if SAT_FORMAT is set to 'json'
# Usage: output_json <key> <value> ...
output_json() {
    if [ "${SAT_FORMAT:-text}" = "json" ]; then
        echo "{"
        while [ $# -ge 2 ]; do
            echo "  \"$1\": \"$2\","
            shift 2
        done
        echo "}"
    else
        # Default text output - do nothing, let the script handle it
        return 1
    fi
}
