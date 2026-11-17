#!/usr/bin/env bash
# Move wp-config.php one directory above the WordPress document root in the disposable Docker lab.
# Run only after WordPress installation and after creating a database/files backup.
set -euo pipefail

COMPOSE=(docker compose --env-file lab/.env -f lab/docker-compose.yml)
CONTAINER="${WP_CONTAINER:-$("${COMPOSE[@]}" ps -q wordpress)}"
BASE="${BASE_URL:-http://localhost:8080}"

if [[ -z "$CONTAINER" ]]; then
  echo "WordPress container is not running. Start the lab first." >&2
  exit 2
fi

docker exec "$CONTAINER" bash -lc '
set -euo pipefail
ROOT=/var/www/html
SOURCE="$ROOT/wp-config.php"
TARGET=/var/www/wp-config.php
ROLLBACK=/var/www/wp-config.php.rollback

[[ -f "$SOURCE" ]] || { echo "Expected config not found: $SOURCE" >&2; exit 3; }
[[ ! -e "$TARGET" && ! -e "$ROLLBACK" ]] || { echo "Parent config or rollback file already exists; refusing to overwrite." >&2; exit 4; }

cp -a "$SOURCE" "$TARGET"
chmod 440 "$TARGET"
mv "$SOURCE" "$ROLLBACK"
echo "Parent config staged; document-root config temporarily moved for verification."
'

home_code="$(curl -L -sS -o /dev/null -w '%{http_code}' "$BASE/")"
login_code="$(curl -L -sS -o /dev/null -w '%{http_code}' "$BASE/wp-login.php")"
if [[ "$home_code" =~ ^2[0-9][0-9]$ && "$login_code" =~ ^2[0-9][0-9]$ ]]; then
  docker exec "$CONTAINER" rm -f /var/www/wp-config.php.rollback
  echo "PASS: WordPress homepage ($home_code) and login ($login_code) work with parent config."
  echo "Parent config: /var/www/wp-config.php (mode 440)."
else
  echo "FAIL: homepage=$home_code, wp-login=$login_code. Rolling back."
  docker exec "$CONTAINER" bash -lc 'if [[ -f /var/www/wp-config.php.rollback ]]; then mv /var/www/wp-config.php.rollback /var/www/html/wp-config.php; fi; rm -f /var/www/wp-config.php'
  exit 1
fi

config_code="$(curl -L -sS -o /dev/null -w '%{http_code}' "$BASE/wp-config.php")"
echo "Direct /wp-config.php HTTP: $config_code (expected 404 after move; before move the .htaccess rule returns 403)."
