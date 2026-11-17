#!/usr/bin/env bash
# Run from repository root after Docker WordPress has completed installation.
set -euo pipefail
CONTAINER="${WP_CONTAINER:-$(docker compose -f lab/docker-compose.yml ps -q wordpress)}"
[ -n "$CONTAINER" ] || { echo "WordPress container not running"; exit 2; }
echo "Applying lab hardening directives and filesystem modes..."
docker exec -i "$CONTAINER" bash -s <<'IN'
set -e
ROOT=/var/www/html
# Add directives to the generated wp-config.php without exposing its contents.
grep -q "DISALLOW_FILE_EDIT" "$ROOT/wp-config.php" || sed -i "/That's all, stop editing/i define('DISALLOW_FILE_EDIT', true);\ndefine('WP_DEBUG', true);\ndefine('WP_DEBUG_DISPLAY', false);\ndefine('WP_DEBUG_LOG', true);\n" "$ROOT/wp-config.php"
# Remove public information files and obvious backup artifacts only in lab.
rm -f "$ROOT/readme.html" "$ROOT/license.txt"
find "$ROOT" -maxdepth 1 -type f \( -name '*.sql' -o -name '*.zip' -o -name '*.bak' \) -delete
find "$ROOT" -type d -exec chmod 755 {} +
find "$ROOT" -type f -exec chmod 644 {} +
chmod 440 "$ROOT/wp-config.php"
mkdir -p "$ROOT/wp-content/uploads"
cat > "$ROOT/wp-content/uploads/.htaccess" <<'HT'
<FilesMatch "\\.(?i:php[0-9]?|phtml|phar|phps)$">
    Require all denied
</FilesMatch>
Options -ExecCGI
HT
chmod 644 "$ROOT/.htaccess" "$ROOT/wp-content/uploads/.htaccess"
echo "Hardening applied. Config permissions: $(stat -c %a "$ROOT/wp-config.php")"
IN
echo "Audit:"
docker exec "$CONTAINER" bash -lc 'test ! -e /var/www/html/readme.html && test ! -e /var/www/html/license.txt && test "$(stat -c %a /var/www/html/wp-config.php)" = 440 && grep -q "DISALLOW_FILE_EDIT" /var/www/html/wp-config.php && echo PASS || echo WARN'
