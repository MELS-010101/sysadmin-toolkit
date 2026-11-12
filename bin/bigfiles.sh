#!/bin/bash
SEARCH_DIR="." # Искать в текущей папке (точка = здесь)
SIZE_LIMIT="+10M" # Больше 10 мегабайт

# 1. ЗАДАНИЕ: Найти большие файлы
# Синтаксис тот же, что и в cleanp.sh, только вместо -mtime используем -size
found_files=$(find "$SEARCH_DIR" -type f -size +10M)

# 2. Проверка результата
if [ -z "$found_files" ]; then
    echo "Больших файлов не найдено."
    exit 0
fi

# 3. Вывод списка
echo "Найдены файлы тяжелее ${SIZE_LIMIT}:"
for f in $found_files; do
    ls -lh "$f" # Показать файл с размером в человекочитаемом виде
done
