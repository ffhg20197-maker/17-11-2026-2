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

## Статус автоматической проверки
Полный CI smoke-test успешно пройден: [GitHub Actions run #21](https://github.com/ffhg20197-maker/17-11-2026-2/actions/runs/44023494150). Проверены права 755/644/440, очистка служебных/резервных файлов, константы WordPress, префикс `sec_lab_`, HTTP 403 для `wp-config.php` и PHP в uploads, а также HTTP 200 главной страницы и wp-login после переноса конфигурации за пределы DocumentRoot.

CI доказывает работу изолированной Docker-лаборатории. Он не означает, что изменения применены к отдельному production-сайту или хостингу. Для подтверждения именно личного сайта сделайте дополнительные снимки его панели/файлового менеджера; не выдавайте CI-иллюстрации за скриншоты личного хостинга.

## Безопасность
Настоящий `wp-config.php`, пароли, salts и дампы БД не коммитятся. Скрипты рассчитаны на отдельный учебный стенд, а не на production. После лабораторной диагностики выключите WP_DEBUG на публичном сайте. .htaccess действует на Apache/LiteSpeed; Nginx требует эквивалентных правил в server config.

Полная инструкция: [docs/implementation.md](docs/implementation.md)  
Критерии: [docs/score-matrix.md](docs/score-matrix.md)  
Отчёт: [17-11-2026/docs/ОТЧЕТ.md](17-11-2026/docs/ОТЧЕТ.md)
