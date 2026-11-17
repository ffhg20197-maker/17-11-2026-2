<?php
/**
 * Read-only WordPress filesystem security audit.
 * Usage: php tools/audit.php /absolute/path/to/wordpress
 */
declare(strict_types=1);

$root = $argv[1] ?? '';
if ($root === '' || !is_dir($root)) {
    fwrite(STDERR, "Usage: php tools/audit.php /path/to/wordpress\n");
    exit(2);
}
$root = rtrim((string)realpath($root), DIRECTORY_SEPARATOR);
$checks = [];
$add = static function(string $name, string $status, string $detail) use (&$checks): void {
    $checks[] = [$name, $status, $detail];
};

foreach (['wp-admin', 'wp-includes', 'wp-content'] as $dir) {
    $add("Directory {$dir}", is_dir("$root/$dir") ? 'OK' : 'WARN',
        is_dir("$root/$dir") ? 'Directory exists' : 'Directory not found');
}

foreach (['readme.html', 'license.txt'] as $file) {
    $add("Informational file {$file}", file_exists("$root/$file") ? 'WARN' : 'OK',
        file_exists("$root/$file") ? 'Present; review and remove if not required' : 'Not present');
}

foreach (['wp-config.php', '.htaccess'] as $file) {
    $path = "$root/$file";
    if (is_file($path)) {
        $perms = substr(sprintf('%o', fileperms($path)), -3);
        $add("Permissions {$file}", 'INFO', "Current mode: {$perms}");
    } else {
        $add("File {$file}", 'INFO', 'Not found in web root (wp-config may be in parent directory)');
    }
}

$configCandidates = ["$root/wp-config.php", dirname($root) . '/wp-config.php'];
$config = null;
foreach ($configCandidates as $candidate) {
    if (is_file($candidate)) { $config = $candidate; break; }
}
if ($config !== null) {
    $content = (string)file_get_contents($config);
    if (preg_match('/\$table_prefix\s*=\s*[\'"]([^\'"]+)[\'"]\s*;/', $content, $m)) {
        $prefix = $m[1];
        $add('Database table prefix', str_starts_with($prefix, 'wp_') ? 'WARN' : 'INFO',
            str_starts_with($prefix, 'wp_') ? 'Default wp_ prefix detected' : 'Non-default prefix detected: ' . $prefix);
    } else {
        $add('Database table prefix', 'WARN', 'Could not parse $table_prefix');
    }
    foreach ([
        'DISALLOW_FILE_EDIT' => '/define\s*\(\s*[\'"]DISALLOW_FILE_EDIT[\'"]\s*,\s*true\s*\)/i',
        'WP_DEBUG_DISPLAY=false' => '/define\s*\(\s*[\'"]WP_DEBUG_DISPLAY[\'"]\s*,\s*false\s*\)/i',
        'WP_DEBUG_LOG=true' => '/define\s*\(\s*[\'"]WP_DEBUG_LOG[\'"]\s*,\s*true\s*\)/i',
    ] as $name => $pattern) {
        $add($name, preg_match($pattern, $content) ? 'OK' : 'WARN',
            preg_match($pattern, $content) ? 'Directive found' : 'Directive not detected');
    }
} else {
    $add('wp-config.php location', 'WARN', 'Not found in web root or one directory above');
}

$uploadsHtaccess = "$root/wp-content/uploads/.htaccess";
$uploadsRule = is_file($uploadsHtaccess) ? (string)file_get_contents($uploadsHtaccess) : '';
$blocked = $uploadsRule !== '' && stripos($uploadsRule, 'FilesMatch') !== false
    && stripos($uploadsRule, 'Require all denied') !== false;
$add('PHP blocked in uploads', $blocked ? 'OK' : 'WARN',
    $blocked ? 'A FilesMatch deny rule was detected; verify with HTTP request' : 'Rule not detected');

echo "WordPress security audit (read-only)\nRoot: {$root}\n";
foreach ($checks as [$name, $status, $detail]) {
    printf("[%s] %-32s %s\n", $status, $name, $detail);
}
echo "\nNote: static checks do not prove effective server behavior. Verify HTTP status codes and admin UI manually.\n";
