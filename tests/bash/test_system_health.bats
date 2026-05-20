#!/usr/bin/env bats
# tests/bash/test_system_health.bats

setup() {
  # Создаем временную директорию для моков
  MOCK_DIR="$(mktemp -d)"
  export PATH="${MOCK_DIR}:${PATH}"
}

teardown() {
  rm -rf "$MOCK_DIR"
}

@test "--help должен выводить руководство и Production Tips" {
  run ./src/linux/system_health.sh --help
  [ "$status" -eq 0 ]
  [[ "$output" == *"PRODUCTION TIPS"* ]]
  [[ "$output" == *"watch -n 5"* ]]
}

@test "--version должен возвращать корректный формат" {
  run ./src/linux/system_health.sh --version
  [ "$status" -eq 0 ]
  [[ "$output" =~ ^v[0-9]+\.[0-9]+\.[0-9]+$ ]]
}

@test "Дисковый алерт должен срабатывать при >85%" {
  # Мокаем df
  cat > "${MOCK_DIR}/df" << 'MOCK'
#!/usr/bin/env bash
echo "Filesystem      Size  Used Avail Use% Mounted on"
echo "/dev/sda1        50G   46G   4G  92% /"
echo "/dev/sdb1       100G   30G  70G  30% /data"
MOCK
  chmod +x "${MOCK_DIR}/df"

  run ./src/linux/system_health.sh
  [ "$status" -eq 0 ]
  [[ "$output" == *"🚨"* && "$output" == *"92%"* ]]
  [[ "$output" == *"✅"* && "$output" == *"30%"* ]]
}