<?php
require dirname(__DIR__) . '/bootstrap.php';
$admin = require_admin();
require_method('POST');
require_csrf();
$input = request_json();
$current = (string) ($input['current_password'] ?? '');
$new = (string) ($input['new_password'] ?? '');
if (strlen($new) < 12) respond(['message' => 'Your new password must have at least 12 characters.'], 422);
$statement = db()->prepare('SELECT password_hash FROM admin_users WHERE id = ? LIMIT 1');
$statement->execute([$admin['id']]);
$hash = (string) $statement->fetchColumn();
if (!$hash || !password_verify($current, $hash)) respond(['message' => 'Your current password is incorrect.'], 422);
db()->prepare('UPDATE admin_users SET password_hash = ? WHERE id = ?')->execute([password_hash($new, PASSWORD_DEFAULT), $admin['id']]);
respond(['message' => 'Password updated successfully.']);
