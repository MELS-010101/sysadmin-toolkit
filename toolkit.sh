#!/bin/bash

while true; do

echo "=== SysAdmin Toolkit ==="
echo "1) Инвентаризация файлов"
echo "2) Поиск дубликатов"
echo "3) Проверка диска"
echo "0) Выход"

read -p "Что делаем? " choice

case "$choice" in
    1) read -p "Какая папка? " dir 
     ./bin/inventory.sh "$dir" ;;
    2) read -p "Какая папка? " dir
      ./bin/dupfinder.sh "$dir" ;;
    3) ./bin/disk_monitor.sh ;;
    0) echo "Пока!"; exit 0 ;;
    *) echo "Неизвестная команда: $choice" ;;
esac

done
