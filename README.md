# WordPress Security Lab — тема 3.2.49

**Дата:** 17.11.2026  
**Задание:** «Структура файлов WordPress, требующих защиты».

## Быстрый старт (Docker Compose)
Требуются Docker и Docker Compose. В каталоге `lab/`:
```bash
cp .env.example .env
docker compose up -d
```
Откройте http://localhost:8080 и завершите установку WordPress. После установки:
```bash
bash scripts/harden-and-audit.sh
bash scripts/http-security-test.sh
```
Скрипты рассчитаны на локальный учебный стенд. Не запускайте их на production без резервной копии и понимания последствий.

## Состав
- `lab/docker-compose.yml`, `lab/.env.example` — локальная среда WordPress + MariaDB.
- `lab/apache/root-hardening.htaccess` и `lab/apache/uploads.htaccess` — правила Apache.
- `lab/config/wp-config-extra.php` — директивы безопасности без секретов.
- `scripts/` — применение безопасных режимов на лабораторном томе и HTTP smoke tests.
- `docs/` — пошаговая методика, карта 100 баллов и отчётные доказательства.
- `site/index.html` — визуальная страница проекта.

## Безопасность
Настоящий `wp-config.php`, пароли, salts и дампы БД не коммитятся. Для реального сайта настройка должна быть адаптирована под хостинг. .htaccess действует на Apache/LiteSpeed; Nginx требует эквивалентных правил в server config.
