# 🛠️ SysAdmin-Toolkit

[![CI/CD](https://github.com/your-org/sysadmin-toolkit/actions/workflows/publish.yml/badge.svg)](https://github.com/your-org/sysadmin-toolkit/actions/workflows/publish.yml)
[![Version](https://img.shields.io/github/v/release/your-org/sysadmin-toolkit?color=blue&logo=github)](https://github.com/your-org/sysadmin-toolkit/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-orange)](#installation)

Production-ready CLI toolkit для автоматизации рутинных задач системного администратора.

## ✨ Features

- Linux (Ubuntu/Debian/RHEL/CentOS)
- macOS (Catalina и новее)
- Windows Server (2016+ / PowerShell 5.1+)
- Dry-run режим и подтверждение операций
- Docker стек (Prometheus + Grafana)
- Интеграция с S3/MinIO
- Тесты: Bats + Pester

## 📦 Установка

### Быстрый старт

git clone https://github.com/MELS-010101/sysadmin-toolkit.git
cd sysadmin-toolkit
chmod +x src/linux/*.sh src/macos/*.sh lib/*.sh
make install
sat --help

### Через npm (Linux/macOS)

npm install -g @your-org/sysadmin-toolkit

### Через NuGet (Windows)

Install-Package SysAdmin-Toolkit

## 🚀 Использование

sat health
sat log-clean --dir /var/log --days 30 --dry-run
./src/linux/system_health.sh
./src/linux/log_cleanup.sh --dir /var/log --days 30 --archive /backup/logs

## 📚 Модули

| Модуль | Команда | Статус |
|--------|---------|--------|
| System Health | sat health | ✅ Stable |
| Log Cleanup | sat log-clean | ✅ Stable |
| Network Audit | sat net-check | 🚧 WIP |

## ⚙️ Конфигурация

~/.config/sat/config.conf:

LOG_LEVEL=info
LOG_DAYS=30
ARCHIVE_DIR=/backup/logs

## 🐳 Docker

cd integrations/docker
docker-compose up -d

Grafana: http://localhost:3000 (admin/admin)
Prometheus: http://localhost:9090

## 🛠️ Разработка

make permissions
make lint
make test
make install

## 📖 Документация

- docs/ARCHITECTURE.md
- CONTRIBUTING.md
- SECURITY.md
- CHANGELOG.md

## 🔐 Безопасность

- Dry-run режим по умолчанию
- Подтверждение деструктивных операций
- Локальное выполнение

## 📄 License

MIT License

## 👥 Авторы

Lead DevOps: @your-username

Made with ❤️ by SysAdmins for SysAdmins
  