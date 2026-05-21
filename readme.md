# ️ SysAdmin-Toolkit

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

###  Основные функции
- ✅ **System Health Monitor** - мониторинг состояния системы
- ✅ **Log Cleanup** - автоматическая ротация и очистка логов
- ✅ **Network Audit** - аудит сети и безопасности
- ✅ **Dry-run режим** - безопасное тестирование команд
- ✅ **Docker стек** - Prometheus + Grafana из коробки
- ✅ **S3/MinIO интеграция** - работа с object storage

---

## 📦 Установка

### 🚀 Быстрый старт
git clone https://github.com/MELS-010101/sysadmin-toolkit.git
cd sysadmin-toolkit
chmod +x src/linux/*.sh src/macos/*.sh lib/*.sh
make install
sat --help

### 📦 Через пакетные менеджеры
npm (Linux/macOS):
npm install -g sysadmin-toolkit-mels

NuGet (Windows):
Install-Package SysAdmin-Toolkit

---

## 🚀 Быстрое использование
# Проверка здоровья системы
sat health

# Очистка логов старше 30 дней (dry-run)
sat log-clean --dir /var/log --days 30 --dry-run

# Аудит сети
sat net-check --full

# Запуск отдельных скриптов
./src/linux/system_health.sh
./src/linux/log_cleanup.sh --dir /var/log --days 30 --archive /backup/logs

---

##  Доступные модули

| Модуль | Команда | Описание | Статус |
|--------|---------|----------|--------|
| **System Health** | sat health | Проверка CPU, RAM, диска, сервисов | ✅ Stable |
| **Log Cleanup** | sat log-clean | Ротация и архивация логов | ✅ Stable |
| **Network Audit** | sat net-check | Сканирование портов, firewall | 🚧 WIP |
| **Security Audit** | sec-audit | Проверка безопасности | ⏳ Planned |

---

## ⚙️ Конфигурация

Файл конфигурации: ~/.config/sat/config.conf

# Уровень логирования: debug, info, warn, error
LOG_LEVEL=info

# Хранить логи старше N дней
LOG_DAYS=30

# Директория для архивов
ARCHIVE_DIR=/backup/logs

# S3 настройки
S3_ENDPOINT=minio.example.com:9000
S3_BUCKET=sysadmin-logs

---

## 🐳 Docker развёртывание

cd integrations/docker
docker-compose up -d

Сервисы:
- 📊 Grafana: http://localhost:3000 (admin/admin)
- 📈 Prometheus: http://localhost:9090
- 💾 MinIO: http://localhost:9001

---

## 🛠️ Разработка

# Установка зависимостей
make install-deps

# Проверка прав
make permissions

# Линтинг кода
make lint

# Запуск тестов
make test

# Локальная установка
make install

### Структура проекта
sysadmin-toolkit/
├── bin/                    # Исполняемые файлы
├── src/
│   ├── linux/             # Linux скрипты
│   ├── macos/             # macOS скрипты
│   └── windows/           # PowerShell скрипты
├── lib/                   # Общие библиотеки
├── tests/
│   ├── bash/              # Bats тесты
│   └── pester/            # Pester тесты
├── integrations/
│   └── docker/            # Docker конфигурации
└── packaging/             # Пакеты (npm, NuGet)

---

## 📖 Документация

- [ Architecture](docs/ARCHITECTURE.md) - Архитектура проекта
- [🤝 Contributing](CONTRIBUTING.md) - Как внести вклад
- [🔒 Security](SECURITY.md) - Политика безопасности
- [📝 Changelog](CHANGELOG.md) - История изменений

---

## 🔐 Безопасность

- 🔒 Dry-run по умолчанию - все деструктивные операции требуют подтверждения
-  Локальное выполнение - никаких внешних вызовов
- ✅ Проверка прав - явные проверки sudo/root
- 📝 Полное логирование - все действия записываются

---

## 🤝 Вклад в проект

1. Fork репозиторий
2. Создайте feature branch (git checkout -b feature/AmazingFeature)
3. Commit changes (git commit -m 'Add some AmazingFeature')
4. Push to branch (git push origin feature/AmazingFeature)
5. Open Pull Request

---

##  Лицензия

MIT License - см. файл LICENSE для деталей.

---

## 👥 Авторы

- **Lead DevOps**: [@MELS-010101](https://github.com/MELS-010101)

---

<div align="center">

**Made with ❤️ by SysAdmins for SysAdmins**

[⬆ Back to top](#-sysadmin-toolkit)

</div>
