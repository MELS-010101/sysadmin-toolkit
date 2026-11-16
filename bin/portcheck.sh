#!/bin/bash
# portcheck.sh - стук в порт: открыт или закрыт
if [ $# -ne 2 ]; then
    echo "Использование: ./portcheck.sh <хост> <порт>"
    exit 1
fi

HOST="$1"
PORT="$2"

if timeout 2 bash -c "echo > /dev/tcp/$HOST/$PORT" 2>/dev/null; then
    echo "Порт $PORT на $HOST ОТКРЫТ"
else
    echo "Порт $PORT на $HOST ЗАКРЫТ (или молчит)"
fi
