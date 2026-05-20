#!/usr/bin/env bats
# tests/bash/test_log_cleanup.bats

setup() {
  MOCK_DIR="$(mktemp -d)"
  export PATH="${MOCK_DIR}:${PATH}"
  mkdir -p "${MOCK_DIR}/logs" "${MOCK_DIR}/archive"
  # Создаем фейковые логи старше 30 дней
  touch -t 202301010000 "${MOCK_DIR}/logs/app.log"
  dd if=/dev/zero of="${MOCK_DIR}/logs/big.log" bs=1M count=101 2>/dev/null
}

teardown() { rm -rf "$MOCK_DIR"; }

@test "--dry-run не должен удалять файлы" {
  run ./src/linux/log_cleanup.sh --dir "${MOCK_DIR}/logs" --archive "${MOCK_DIR}/archive" --dry-run -f
  [ "$status" -eq 0 ]
  [[ "$output" == *"[DRY-RUN]"* ]]
  [ -f "${MOCK_DIR}/logs/app.log" ] # Файл должен остаться
}

@test "Архивация должна создавать .gz и удалять оригинал" {
  run ./src/linux/log_cleanup.sh --dir "${MOCK_DIR}/logs" --archive "${MOCK_DIR}/archive" -f
  [ "$status" -eq 0 ]
  [[ "$output" == *"Archived & cleaned"* ]]
  [ ! -f "${MOCK_DIR}/logs/app.log" ] # Удален
  [ -f "${MOCK_DIR}/archive/app.log."*".gz" ] # Архив создан
}