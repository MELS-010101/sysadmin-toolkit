#!/bin/bash
# logrotate.sh - ротация: упаковал -> проверил -> удалил -> подчистил
if [ $# -ne 2 ]; then
    echo "Использование: ./logrotate.sh <папка_логов> <папка_архивов>"
    exit 1
fi
LOG_DIR="$1"
ARCHIVE_DIR="$2"
DAYS_OLD=7
KEEP_DAYS=30

if [ ! -d "$LOG_DIR" ]; then
    echo "Такой папки логов нет!"
    exit 1
fi
mkdir -p "$ARCHIVE_DIR"

find "$LOG_DIR" -maxdepth 1 -type f -name "*.log" -mtime +$DAYS_OLD > /tmp/rotate_list.txt

if [ ! -s /tmp/rotate_list.txt ]; then
    echo "Старых логов нет, ротация не нужна."
    exit 0
fi

stamp=$(date '+%Y%m%d_%H%M%S')
archive="$ARCHIVE_DIR/logs_$stamp.tar.gz"

tar -czf "$archive" -T /tmp/rotate_list.txt   # пропуск 1: упаковать по списку (tar -czf ... -T ...)

if tar -tzf "$archive" > /dev/null 2>&1; then

    while read -r f; do rm "$f"; done < /tmp/rotate_list.txt   # пропуск 2: удалить оригиналы по списку (цикл while read)

    echo "Упаковано и удалено: $(wc -l < /tmp/rotate_list.txt) файлов. Архив: $archive"
else
    echo "Архив битый! Оригиналы НЕ удалены."
    exit 1
fi

find "$ARCHIVE_DIR" -type f -name "*.tar.gz" -mtime +$KEEP_DAYS -delete
