#!/bin/bash
while true; do
    echo "=== SysAdmin Toolkit ==="
    echo "1) Инвентаризация файлов"
    echo "2) Поиск дубликатов"
    echo "3) Проверка диска"
    echo "4) Проверка порта"
    echo "5) Ротация логов"
    echo "0) Выход"
    read -p "Что делаем? " choice
    case "$choice" in
        1) read -p "Какая папка? " dir
           ./bin/inventory.sh "$dir" ;;
        2) read -p "Какая папка? " dir
           ./bin/dupfinder.sh "$dir" ;;
        3) ./bin/disk_monitor.sh ;;
        4) read -p "Хост? " host
           read -p "Порт? " port
           ./bin/portcheck.sh "$host" "$port" ;;
        5) read -p "Папка логов? " logdir
           read -p "Папка архивов? " archdir
           ./bin/logrotate.sh "$logdir" "$archdir" ;;
        0) echo "Пока!"; exit 0 ;;
        *) echo "Неизвестная команда: $choice" ;;
    esac
done
