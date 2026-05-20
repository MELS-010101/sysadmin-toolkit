## 🚀 Installation

### From Source

```bash
# 1. Clone repository
git clone https://github.com/MELS-010101//sysadmin-toolkit.git
cd sysadmin-toolkit

# 2. Set executable permissions
chmod +x src/linux/*.sh src/macos/*.sh lib/*.sh

# 3. Add to PATH (optional)
echo 'export PATH="$PATH:$(pwd)/bin"' >> ~/.bashrc
source ~/.bashrc

# 4. Run
./bin/sat --help
# or
./src/linux/system_health.sh --help


[![CI/CD](https://github.com/your-org/sysadmin-toolkit/actions/workflows/publish.yml/badge.svg)](https://github.com/your-org/sysadmin-toolkit/actions/workflows/publish.yml)
[![Version](https://img.shields.io/github/v/release/your-org/sysadmin-toolkit?color=blue&logo=github)](https://github.com/your-org/sysadmin-toolkit/releases)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Linux%20%7C%20macOS%20%7C%20Windows-orange)](#installation)
[![ShellCheck](https://github.com/your-org/sysadmin-toolkit/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/your-org/sysadmin-toolkit/actions)

> **Production-ready CLI toolkit** для автоматизации рутинных задач системного администратора. Мониторинг, очистка логов, аудит безопасности и многое другое — всё в одном инструменте.

---

## ✨ Features

- 🐧 **Linux** (Ubuntu/Debian/RHEL/CentOS)
- 🍎 **macOS** (Catalina и новее)
- 🪟 **Windows Server** (2016+ / PowerShell 5.1+)
- 🔒 **Безопасность**: dry-run режим, подтверждение деструктивных операций
- 📦 **Пакетные менеджеры**: npm, NuGet, Homebrew (скоро)
- 🐳 **Docker**: готовый стек мониторинга (Prometheus + Grafana)
- ☁️ **Cloud**: интеграция с S3/MinIO для архивации
- 🧪 **Тесты**: покрытие Bats (Bash) + Pester (PowerShell)

---

## 📦 Установка

### 🔥 Быстрый старт (Recommended)

```bash
# Clone repository
git clone https://github.com/MELS-010101//sysadmin-toolkit.git
cd sysadmin-toolkit

# Install & setup
make install

# Verify installation
sat --help

📥 Через пакетные менеджеры
Linux/macOS (npm)
npm install -g @your-org/sysadmin-toolkit

Windows (NuGet)
Install-Package SysAdmin-Toolkit

Docker
docker run --rm -it ghcr.io/your-org/sysadmin-toolkit:latest --help

🚀 Использование
Основные команды

# System Health Check
sat health

# Log Cleanup (dry-run first!)
sat log-clean --dir /var/log --days 30 --dry-run
sat log-clean --dir /var/log --days 30 --upload-s3 my-logs-bucket

Примеры
Мониторинг системы

./src/linux/system_health.sh
./src/linux/system_health.sh >> /var/log/sat-health.log 2>&1

# Dry-run
./src/linux/log_cleanup.sh --dir /var/log --days 30 --dry-run

Очистка логов
# Реальная очистка с архивацией
./src/linux/log_cleanup.sh \
  --dir /var/log \
  --days 30 \
  --archive /backup/logs \
  --upload-s3 company-logs

  