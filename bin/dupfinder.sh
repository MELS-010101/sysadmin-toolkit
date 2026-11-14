#!/bin/bash
# dupfinder.sh - поиск файлов с одинаковыми именами
if [ $# -ne 1 ]; then
    echo "Использование: ./dupfinder.sh <папка>"
    exit 1
fi

TARGET_DIR="$1"

if [ ! -d "$TARGET_DIR" ]; then
    echo "Такой папки нет!"
    exit 1
fi

echo "Ищу дубликаты имён в $TARGET_DIR..."
duplicates=$(find "$TARGET_DIR" -type f -not -path "*/.git/*" -printf "%f\n" | sort | uniq -c | awk '$1 > 1 {print $1, $2}')

if [ -z "$duplicates" ]; then
    echo "Дубликатов не найдено."
else
    echo "Найдены дубликаты (сколько раз | имя):"
    echo "$duplicates"
fi
