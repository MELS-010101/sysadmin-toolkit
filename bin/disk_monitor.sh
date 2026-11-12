#!/bin/bash
THRESHOLD=80
LOG_FILE="logs/disk_monitor.log"

# Создаём папку для логов, если её нет
mkdir -p logs

# Функция логирования (уже знакомая)
log() {
    local msg="$(date '+%Y-%m-%d %H:%M:%S') | $1"
    echo "$msg" | tee -a "$LOG_FILE"

}


usage=$(df -h / | awk 'NR==2 {print $5}' | tr -cd '0-9')


if [ "$usage" -ge "$THRESHOLD" ]; then
    log "WARNING: Disk usage is ${usage}% (threshold: ${THRESHOLD}%)"
else
    log "OK: Disk usage is ${usage}%"
fi
