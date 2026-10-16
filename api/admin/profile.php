<?php
require dirname(__DIR__) . '/bootstrap.php';

$admin = require_admin();
$pdo = db();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    $statement = $pdo->prepare('SELECT id, name, email, role, created_at, last_login_at FROM admin_users WHERE id = ? LIMIT 1');
    $statement->execute([$admin['id']]);
    $profile = $statement->fetch();
    if (!$profile) respond(['message' => 'Profile not found.'], 404);
    respond(['profile' => $profile]);
}

require_method('PATCH');
require_csrf();
$input = request_json();
$name = trim((string) ($input['name'] ?? ''));
$email = strtolower(trim((string) ($input['email'] ?? '')));
$currentPassword = (string) ($input['current_password'] ?? '');
if (mb_strlen($name) < 2 || mb_strlen($name) > 100 || !filter_var($email, FILTER_VALIDATE_EMAIL)) respond(['message' => 'Enter a valid name and email address.'], 422);
if ($currentPassword === '') respond(['message' => 'Enter your current password to save profile changes.'], 422);

$statement = $pdo->prepare('SELECT password_hash FROM admin_users WHERE id = ? LIMIT 1');
$statement->execute([$admin['id']]);
$hash = (string) ($statement->fetchColumn() ?: '');
if (!$hash || !password_verify($currentPassword, $hash)) respond(['message' => 'Your current password is incorrect.'], 422);

try {
    $statement = $pdo->prepare('UPDATE admin_users SET name = ?, email = ? WHERE id = ?');
    $statement->execute([$name, $email, $admin['id']]);
} catch (PDOException) {
    respond(['message' => 'That email address is already in use.'], 422);
}

$_SESSION['admin']['name'] = $name;
$_SESSION['admin']['email'] = $email;
respond(['message' => 'Your profile has been updated.', 'admin' => $_SESSION['admin']]);
