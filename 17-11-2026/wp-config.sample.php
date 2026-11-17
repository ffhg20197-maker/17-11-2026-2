<?php
/**
 * Merge these lines into the existing wp-config.php.
 * Do NOT replace DB credentials, salts, table prefix, or other site settings.
 * Keep this file outside the public repository/web root.
 */

// Disable the built-in theme/plugin code editor in wp-admin.
define('DISALLOW_FILE_EDIT', true);

// Required by the assignment for a controlled lab environment.
// On production, normally turn WP_DEBUG off after diagnostics.
define('WP_DEBUG', true);
define('WP_DEBUG_DISPLAY', false);
define('WP_DEBUG_LOG', true);
@ini_set('display_errors', '0');

// Example only: use a unique prefix for a NEW installation.
// Changing an existing site's prefix requires a database migration.
$table_prefix = 'site_sec7_';
