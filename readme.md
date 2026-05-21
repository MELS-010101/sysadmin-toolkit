# 🛠️ SysAdmin-Toolkit

[![CI/CD](https://github.com/MELS-010101/sysadmin-toolkit/actions/workflows/ci.yml/badge.svg)](https://github.com/MELS-010101/sysadmin-toolkit/actions)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![GitHub release](https://img.shields.io/github/v/release/MELS-010101/sysadmin-toolkit)](https://github.com/MELS-010101/sysadmin-toolkit/releases)

**Production-ready CLI toolkit для автоматизации рутинных задач системного администратора**

---

## ✨ Возможности

### 🔹 Кроссплатформенность
- **Linux**: Ubuntu/Debian/RHEL/CentOS
- **macOS**: Catalina и новее
- **Windows**: Server 2016+ / PowerShell 5.1+

### 🔹 Основные функции
- ✅ **System Health Monitor** - мониторинг состояния системы
- ✅ **Log Cleanup** - автоматическая ротация и очистка логов
- ✅ **Network Audit** - аудит сети и безопасности
- ✅ **Dry-run режим** - безопасное тестирование команд
- ✅ **Docker стек** - Prometheus + Grafana из коробки
- ✅ **S3/MinIO интеграция** - работа с object storage

---

## 📦 Установка

### 🚀 Быстрый старт

```bash
git clone https://github.com/MELS-010101/sysadmin-toolkit.git
cd sysadmin-toolkit
chmod +x src/linux/*.sh src/macos/*.sh lib/*.sh
make install
sat --help

📦 Через пакетные менеджеры
npm (Linux/macOS):npm install -g sysadmin-toolkit-mels

NuGet (Windows):Install-Package SysAdmin-Toolkit
