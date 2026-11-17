# WordPress Security Lab — тема 3.2.49

**Дата:** 17.11.2026  
**Задание:** «Структура файлов WordPress, требующих защиты».

## Быстрый старт (Docker Compose)
Требуются Docker Desktop/Engine и Docker Compose v2. Выполнять команды из корня репозитория:
```bash
cp lab/.env.example lab/.env
# Обязательно замените локальные пароли в .env
docker compose --env-file lab/.env -f lab/docker-compose.yml up -d
```
Откройте http://localhost:8080 и завершите установку WordPress. После установки:
```bash
bash scripts/harden-and-audit.sh
bash scripts/http-security-test.sh
bash scripts/move-config-outside-webroot.sh
```
Последняя команда проверяет работу главной страницы и wp-login после переноса wp-config.php на уровень выше web-root, с автоматическим откатом при ошибке.

## Состав
- `lab/docker-compose.yml`, `lab/.env.example` — локальная среда WordPress + MariaDB.
- `lab/apache/` — защита корня сайта и запрет PHP в uploads.
- `lab/config/wp-config-extra.php` — директивы безопасности без секретов.
- `scripts/` — применение прав, read-only аудит, HTTP smoke tests и безопасный перенос wp-config.php.
- `docs/` — пошаговая методика, матрица 100 баллов и отчёт.
- `17-11-2026/` — материалы задания, отчёт и демонстрационная HTML-страница.
- `.github/workflows/wordpress-security-lab.yml` — CI-проверка на GitHub Actions: поднимает изолированный WordPress и проверяет hardening.

## Важно о статусе
Репозиторий содержит воспроизводимую лабораторную среду. Скриншоты для учебного отчёта должны быть сделаны в реальной панели WordPress/браузере после запуска стенда; статическая демонстрационная страница не является скриншотом WordPress. Не выдавайте подготовленные шаблоны за результаты выполнения на вашем личном хостинге.

## Безопасность
Настоящий `wp-config.php`, пароли, salts и дампы БД не коммитятся. Скрипты рассчитаны на отдельный учебный стенд, а не на production. После лабораторной диагностики выключите WP_DEBUG на публичном сайте. .htaccess действует на Apache/LiteSpeed; Nginx требует эквивалентных правил в server config.

Полная инструкция: [docs/implementation.md](docs/implementation.md)  
Критерии: [docs/score-matrix.md](docs/score-matrix.md)  
Отчёт: [17-11-2026/docs/ОТЧЕТ.md](17-11-2026/docs/ОТЧЕТ.md)
