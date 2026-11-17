# Практическая работа 3.2.49 — защита файлов WordPress

Дата комплекта: 17.11.2026. Полный проект, лабораторная среда, инструкции и инструменты находятся в корне репозитория и в этой папке.

## Быстрые ссылки
- [Полная инструкция по развёртыванию и проверкам](../docs/implementation.md)
- [Матрица критериев на 100 баллов](../docs/score-matrix.md)
- [Отчёт с листингами и местами для фактических скриншотов](docs/ОТЧЕТ.md)
- [Пошаговый порядок выполнения](docs/ПОРЯДОК_ВЫПОЛНЕНИЯ.md)
- [Контрольный лист сдачи](docs/КОНТРОЛЬНЫЙ_ЛИСТ.md)
- [Docker Compose стенд](../lab/docker-compose.yml)
- [Скрипт укрепления и аудита](../scripts/harden-and-audit.sh)
- [HTTP smoke tests](../scripts/http-security-test.sh)
- [Безопасный перенос wp-config.php](../scripts/move-config-outside-webroot.sh)

## Запуск
Из корня репозитория:
```bash
cp lab/.env.example lab/.env
# Отредактируйте .env: задайте собственные уникальные пароли.
docker compose --env-file lab/.env -f lab/docker-compose.yml up -d
```
Завершите установку на http://localhost:8080, затем выполните:
```bash
bash scripts/harden-and-audit.sh
bash scripts/http-security-test.sh
bash scripts/move-config-outside-webroot.sh
```

## Честный статус
Код и лабораторная среда подготовлены в репозитории, но Docker-контейнеры не запускались из GitHub и не подключены к вашему компьютеру/хостингу. Поэтому HTTP-коды, CHMOD, реальная админ-панель и перенос должны быть подтверждены запуском команд в вашей лаборатории. Скриншоты в отчёт вставляются только после фактического выполнения.
