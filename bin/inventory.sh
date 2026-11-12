#!/bin/bash
# 1. Проверяем, передали ли аргумент
if [ $# -ne 1 ]; then
    echo "Использование: ./inventory.sh <папка>"
    exit 1
fi

TARGET_DIR="$1"

# 2. Проверяем, существует ли такая папка
if [ ! -d "$TARGET_DIR" ]; then
    echo "Такой папки нет!"
    exit 1
fi

# 3. ЗАДАНИЕ: Посчитать файлы
# Вставь сюда команду find + wc -l, чтобы получить число в переменную total_files
total_files=$(find "$TARGET_DIR" -type f | wc -l )

echo "В папке $TARGET_DIR найдено файлов: $total_files"
