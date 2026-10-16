<?php
require dirname(__DIR__) . '/bootstrap.php';
require_method('POST');
rate_limit('admin-password-reset', 5, 900);

$email = strtolower(trim((string) (request_json()['email'] ?? '')));
$message = ['message' => 'If that email belongs to an administrator, a password-reset link has been sent.'];
if (!filter_var($email, FILTER_VALIDATE_EMAIL)) respond($message);

$statement = db()->prepare('SELECT id, name FROM admin_users WHERE email = ? AND is_active = 1 AND (suspended_until IS NULL OR suspended_until <= NOW()) LIMIT 1');
$statement->execute([$email]);
$user = $statement->fetch();
if (!$user) respond($message);

$config = config();
$from = trim((string) ($config['MAIL_FROM'] ?? ''));
if (!filter_var($from, FILTER_VALIDATE_EMAIL)) respond($message);
$token = bin2hex(random_bytes(32));
$pdo = db();
$pdo->prepare('DELETE FROM admin_password_resets WHERE user_id = ?')->execute([$user['id']]);
$pdo->prepare('INSERT INTO admin_password_resets (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 1 HOUR))')->execute([$user['id'], hash('sha256', $token)]);
$url = rtrim((string) ($config['APP_URL'] ?? 'http://localhost:8000'), '/') . '/admin/reset-password.php?token=' . $token;
$subject = 'Reset your Tee Components admin password';
$body = "Hello {$user['name']},\n\nUse this one-time link to reset your password within one hour:\n{$url}\n\nIf you did not request this, you can ignore this email.";
send_mail($email, $subject, $body);
respond($message);
