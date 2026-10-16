<?php
require dirname(__DIR__) . '/bootstrap.php';
$current = require_super_admin();
$pdo = db();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    // Super-admin accounts are never exposed through the ordinary admin directory.
    respond($pdo->query("SELECT id, name, email, is_active, suspended_until, created_at, last_login_at FROM admin_users WHERE role = 'admin' ORDER BY created_at, id")->fetchAll());
}

require_csrf();
$input = request_json();

if ($method === 'POST') {
    $name = trim((string) ($input['name'] ?? ''));
    $email = strtolower(trim((string) ($input['email'] ?? '')));
    if (mb_strlen($name) < 2 || !filter_var($email, FILTER_VALIDATE_EMAIL)) respond(['message' => 'Enter a valid name and email address.'], 422);
    $config = config();
    $from = trim((string) ($config['MAIL_FROM'] ?? ''));
    $appUrl = rtrim((string) ($config['APP_URL'] ?? 'http://localhost:8000'), '/');
    if (!filter_var($from, FILTER_VALIDATE_EMAIL)) respond(['message' => 'Set MAIL_FROM in .env before sending administrator invitations.'], 503);
    $token = bin2hex(random_bytes(32));
    $inviteUrl = $appUrl . '/admin/set-password.php?token=' . $token;
    try {
        $pdo->beginTransaction();
        $statement = $pdo->prepare("INSERT INTO admin_users (name, email, password_hash, role, is_active) VALUES (?, ?, ?, 'admin', 1)");
        $statement->execute([$name, $email, password_hash(bin2hex(random_bytes(32)), PASSWORD_DEFAULT)]);
        $userId = (int) $pdo->lastInsertId();
        $invite = $pdo->prepare('INSERT INTO admin_invites (user_id, token_hash, expires_at) VALUES (?, ?, DATE_ADD(NOW(), INTERVAL 24 HOUR))');
        $invite->execute([$userId, hash('sha256', $token)]);
        $pdo->commit();
    } catch (PDOException $exception) {
        if ($pdo->inTransaction()) $pdo->rollBack();
        respond(['message' => 'That email address is already in use.'], 422);
    }
    $subject = 'Set up your Tee Components admin account';
    $body = "Hello {$name},\n\nYou have been invited to manage the Tee Components website as an administrator.\n\nSet your password using this one-time link within 24 hours:\n{$inviteUrl}\n\nIf you were not expecting this invitation, you can ignore this email.\n";
    if (!send_mail($email, $subject, $body)) {
        $pdo->prepare('DELETE FROM admin_users WHERE id = ?')->execute([$userId]);
        respond(['message' => 'The invitation email could not be sent, so the account was not created.'], 503);
    }
    respond(['message' => 'Invitation sent. The user will set their own password securely.', 'id' => $userId], 201);
}

if ($method === 'PATCH') {
    $id = (int) ($input['id'] ?? 0);
    if (!$id) respond(['message' => 'Choose an administrator.'], 422);
    $statement = $pdo->prepare("SELECT id FROM admin_users WHERE id = ? AND role = 'admin' LIMIT 1");
    $statement->execute([$id]);
    if (!$statement->fetch()) respond(['message' => 'Administrator not found.'], 404);

    // Permanent deactivation retains the account for history while revoking access and outstanding tokens.
    if (isset($input['action']) && in_array($input['action'], ['deactivate', 'reactivate'], true)) {
        if ($input['action'] === 'deactivate') {
            $pdo->beginTransaction();
            try {
                $pdo->prepare('UPDATE admin_users SET is_active = 0, suspended_until = NULL WHERE id = ?')->execute([$id]);
                $pdo->prepare('DELETE FROM admin_invites WHERE user_id = ?')->execute([$id]);
                $pdo->prepare('DELETE FROM admin_password_resets WHERE user_id = ?')->execute([$id]);
                $pdo->commit();
            } catch (Throwable $exception) {
                if ($pdo->inTransaction()) $pdo->rollBack();
                throw $exception;
            }
            respond(['message' => 'Administrator permanently deactivated. The account record was retained.']);
        }
        $pdo->prepare('UPDATE admin_users SET is_active = 1, suspended_until = NULL WHERE id = ?')->execute([$id]);
        respond(['message' => 'Administrator access restored.']);
    }

    if (!array_key_exists('suspended_until', $input)) respond(['message' => 'Choose a suspension end date.'], 422);
    $value = trim((string) ($input['suspended_until'] ?? ''));
    $until = null;
    if ($value !== '') {
        $until = DateTimeImmutable::createFromFormat('Y-m-d\\TH:i', $value);
        $errors = DateTimeImmutable::getLastErrors();
        if (!$until || ($errors !== false && ($errors['warning_count'] || $errors['error_count'])) || $until <= new DateTimeImmutable()) respond(['message' => 'Choose a future date and time for the suspension.'], 422);
    }
    // Suspension replaces the former deactivate/delete workflow while keeping the account record.
    $pdo->prepare('UPDATE admin_users SET is_active = 1, suspended_until = ? WHERE id = ?')->execute([$until ? $until->format('Y-m-d H:i:s') : null, $id]);
    respond(['message' => $until ? 'Administrator deactivated until ' . $until->format('j M Y, H:i') . '.' : 'Administrator access restored.']);
}

respond(['message' => 'Method not allowed.'], 405);
