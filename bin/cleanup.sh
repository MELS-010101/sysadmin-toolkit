#!/bin/bash
LOG_DIR="logs" # Создадим тестовую папку logs для проверки
DAYS_OLD=7

# 1. ЗАДАНИЕ: Найти старые логи
# Нужно собрать команду find внутри $(...).
# Параметры: путь ($LOG_DIR), тип (-type f), имя (* .log), возраст (-mtime +$DAYS_OLD)
files_to_delete=$(find "$LOG_DIR" -type f -name "*.log" -mtime +$DAYS_OLD)

# 2. Проверка: если ничего не нашли — выходим
if [ -z "$files_to_delete" ]; then
    echo "Старых логов не найдено."
    exit 0
fi

# 3. Удаляем найденное
echo "Найдено файлов для удаления:"
for file in $files_to_delete; do
    rm "$file"
    echo "Удален: $file"
done

