#!/bin/bash
if [ $# -ne 1 ]; then
    echo "Использование: ./backup.sh <папка>" >&2
    exit 1
fi
SOURCE_DIR="$1"
BACKUP_DIR="backup_$(date +%F)"
ARCHIVE_NAME="${SOURCE_DIR}_$(date +%H%M%S).tar.gz"
LOG_FILE="$BACKUP_DIR/backup.log"

log() {
    local msg="$(date '+%Y-%m-%d %H:%M:%S') | $1"
    echo "$msg" | tee -a "$LOG_FILE"
}

if [ ! -d "$SOURCE_DIR" ]; then
    log "ОШИБКА: Папка $SOURCE_DIR не существует!"
    exit 1
fi

if [ -d "$BACKUP_DIR" ]; then
    log "Папка $BACKUP_DIR уже есть"
else
    mkdir "$BACKUP_DIR" || { log "ОШИБКА: Не создал $BACKUP_DIR"; exit 1; }
    log "Создал папку $BACKUP_DIR"
fi

read -p "Архивировать $SOURCE_DIR в $BACKUP_DIR/$ARCHIVE_NAME? (y/n): " confirm
if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
    log "Отменено пользователем."
    exit 0
fi

count=$(find "$SOURCE_DIR" -type f | wc -l)
log "Начало архивации $count файлов из $SOURCE_DIR"

tar -czf "$BACKUP_DIR/$ARCHIVE_NAME" -C "$(dirname "$SOURCE_DIR")" "$(basename "$SOURCE_DIR")"
archive_status=$?

if [ $archive_status -eq 0 ]; then
    log "УСПЕХ: Архив $ARCHIVE_NAME создан"
else
    log "ОШИБКА: tar завершился кодом $archive_status"
    exit 1
fi

log "Готово. Лог: $LOG_FILE"
