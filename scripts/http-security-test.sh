#!/usr/bin/env bash
# Smoke tests for local Docker lab. Run after WP install and hardening.
set -euo pipefail
BASE="${BASE_URL:-http://localhost:8080}"
tmp="$(mktemp)"
trap 'rm -f "$tmp"; docker compose -f lab/docker-compose.yml exec -T wordpress rm -f /var/www/html/wp-content/uploads/security-test.php >/dev/null 2>&1 || true' EXIT
echo '<?php echo "THIS SHOULD NEVER EXECUTE";' > "$tmp"
docker compose -f lab/docker-compose.yml cp "$tmp" wordpress:/var/www/html/wp-content/uploads/security-test.php
code_config="$(curl -s -o /dev/null -w '%{http_code}' "$BASE/wp-config.php")"
code_upload="$(curl -s -o /dev/null -w '%{http_code}' "$BASE/wp-content/uploads/security-test.php")"
printf 'wp-config.php HTTP: %s (expected 403)\n' "$code_config"
printf 'uploads PHP HTTP: %s (expected 403)\n' "$code_upload"
[ "$code_config" = 403 ] && [ "$code_upload" = 403 ]
echo "PASS: both direct requests are denied."
