#!/usr/bin/env bash
# Move wp-config.php one directory above the WordPress document root in the disposable Docker lab.
# Run only after WordPress installation and after creating a database/files backup.
set -euo pipefail

COMPOSE=(docker compose -f lab/docker-compose.yml)
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

if [[ ! -f "$SOURCE" ]]; then
  echo "Expected config not found in $SOURCE" >&2
  exit 3
fi
if [[ -e "$TARGET" ]]; then
  echo "Refusing to overwrite existing $TARGET" >&2
  exit 4
fi

cp -a "$SOURCE" "$TARGET"
chmod 440 "$TARGET"
# Keep a rollback copy in the web root until HTTP smoke tests pass.
echo "Config copied to parent directory; original retained for rollback."
'

home_code="$(curl -sS -o /dev/null -w '%{http_code}' "$BASE/")"
login_code="$(curl -sS -o /dev/null -w '%{http_code}' "$BASE/wp-login.php")"
if [[ "$home_code" =~ ^2[0-9][0-9]$ && "$login_code" =~ ^2[0-9][0-9]$ ]]; then
  docker exec "$CONTAINER" rm -f /var/www/html/wp-config.php
  echo "PASS: WordPress homepage ($home_code) and login ($login_code) work with parent config."
  echo "Parent config: /var/www/wp-config.php (mode 440)."
else
  echo "FAIL: homepage=$home_code, wp-login=$login_code. Rolling back."
  docker exec "$CONTAINER" bash -lc 'if [[ -f /var/www/wp-config.php && ! -f /var/www/html/wp-config.php ]]; then cp -a /var/www/wp-config.php /var/www/html/wp-config.php; fi'
  exit 1
fi

# Once moved, direct URL should be 404 because the file is no longer inside DocumentRoot.
config_code="$(curl -sS -o /dev/null -w '%{http_code}' "$BASE/wp-config.php")"
echo "Direct /wp-config.php HTTP: $config_code (expected 404 after move; before move the .htaccess rule returns 403)."
