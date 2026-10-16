<?php
require dirname(__DIR__) . '/bootstrap.php';
require_method('POST');
rate_limit('admin-login', 8, 900);

$input = request_json();
$email = strtolower(trim((string) ($input['email'] ?? '')));
$password = (string) ($input['password'] ?? '');
if (!$email || !$password) respond(['message' => 'Email and password are required.'], 422);

$statement = db()->prepare('SELECT id, name, email, password_hash, role, is_active, suspended_until FROM admin_users WHERE email = ? LIMIT 1');
$statement->execute([$email]);
$user = $statement->fetch();
if (!$user || !(int) $user['is_active'] || ($user['suspended_until'] && strtotime($user['suspended_until']) > time()) || !in_array($user['role'], ['super_admin', 'admin'], true) || !password_verify($password, $user['password_hash'])) respond(['message' => 'Incorrect email or password.'], 401);

session_regenerate_id(true);
// Do not carry any role or account data forward when a different user signs in.
$_SESSION = [];
$_SESSION['csrf_token'] = bin2hex(random_bytes(32));
$_SESSION['admin'] = ['id' => (int) $user['id'], 'name' => $user['name'], 'email' => $user['email'], 'role' => $user['role']];
$_SESSION['last_activity'] = time();
db()->prepare('UPDATE admin_users SET last_login_at = NOW() WHERE id = ?')->execute([(int) $user['id']]);
respond(['admin' => $_SESSION['admin'], 'csrf' => csrf_token()]);
