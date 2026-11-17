<?php
// Reference fragment for the official WordPress Docker image.
// The Compose stack sets WP_DEBUG=1 via WORDPRESS_DEBUG and the prefix via
// WORDPRESS_TABLE_PREFIX=sec_lab_. Do not redefine WP_DEBUG or $table_prefix here.
define('DISALLOW_FILE_EDIT', true);
define('WP_DEBUG_DISPLAY', false);
define('WP_DEBUG_LOG', true);

// For a non-Docker installation, configure these in the real wp-config.php:
// define('WP_DEBUG', true);
// $table_prefix = 'sec_lab_';
// Changing an existing site's table prefix requires a database migration.
