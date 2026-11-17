<?php
// Merge these constants into the real wp-config.php above "That's all, stop editing!".
// This file is a safe reference only; never store credentials or salts in Git.
define('DISALLOW_FILE_EDIT', true);
define('WP_DEBUG', true);
define('WP_DEBUG_DISPLAY', false);
define('WP_DEBUG_LOG', true);
// Example for a NEW installation only. Existing sites require a database migration.
$table_prefix = 'sec_lab_';
