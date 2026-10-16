<?php
require dirname(__DIR__) . '/api/bootstrap.php';

$config = config();
$required = ['ADMIN_NAME', 'ADMIN_EMAIL', 'ADMIN_PASSWORD'];
foreach ($required as $key) {
    if (empty($config[$key]) || str_contains($config[$key], 'change-this')) {
        fwrite(STDERR, "Set {$key} in .env before creating an administrator.\n");
        exit(1);
    }
}
$statement = db()->prepare("INSERT INTO admin_users (name, email, password_hash, role, is_active) VALUES (?, ?, ?, 'super_admin', 1) ON DUPLICATE KEY UPDATE name = VALUES(name), password_hash = VALUES(password_hash), role = 'super_admin', is_active = 1");
$statement->execute([$config['ADMIN_NAME'], strtolower($config['ADMIN_EMAIL']), password_hash($config['ADMIN_PASSWORD'], PASSWORD_DEFAULT)]);
fwrite(STDOUT, "Administrator account is ready for {$config['ADMIN_EMAIL']}.\n");
