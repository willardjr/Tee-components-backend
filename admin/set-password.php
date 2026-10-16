<?php
declare(strict_types=1);
require dirname(__DIR__) . '/api/bootstrap.php';

$token = (string) ($_GET['token'] ?? $_POST['token'] ?? '');
$message = '';
$success = false;
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    rate_limit('admin-invite-password', 6, 900);
    $password = (string) ($_POST['password'] ?? '');
    if (!preg_match('/^[a-f0-9]{64}$/', $token) || strlen($password) < 12) {
        $message = 'Use the valid invitation link and a password of at least 12 characters.';
    } else {
        $pdo = db();
        try {
            $pdo->beginTransaction();
            $statement = $pdo->prepare('SELECT i.id, i.user_id FROM admin_invites i INNER JOIN admin_users u ON u.id = i.user_id WHERE i.token_hash = ? AND i.expires_at > NOW() AND u.is_active = 1 LIMIT 1 FOR UPDATE');
            $statement->execute([hash('sha256', $token)]);
            $invite = $statement->fetch();
            if (!$invite) {
                $pdo->rollBack();
                $message = 'This invitation is invalid or has expired.';
            } else {
            $pdo->prepare('UPDATE admin_users SET password_hash = ? WHERE id = ?')->execute([password_hash($password, PASSWORD_DEFAULT), $invite['user_id']]);
            $pdo->prepare('DELETE FROM admin_invites WHERE id = ?')->execute([$invite['id']]);
            $pdo->commit();
            $success = true;
            }
        } catch (PDOException) {
            if ($pdo->inTransaction()) $pdo->rollBack();
            $message = 'Unable to set your password. Please try again.';
        }
    }
}
?><!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><link rel="icon" type="image/png" href="/uploads/tee-components-icon.png"><title>Set password | Tee Components</title><style>body{margin:0;font-family:Arial,sans-serif;background:#f4f6fa;color:#101d32}.page{min-height:100vh;display:grid;place-items:center;padding:24px}.card{width:min(100%,440px);background:#fff;border-radius:18px;padding:32px;box-shadow:0 18px 50px #101d3215}.logo{width:62px;height:62px;object-fit:contain}label{display:grid;gap:8px;margin-top:20px;font-weight:700;font-size:14px}input{padding:13px;border:1px solid #dce3ed;border-radius:8px;font:inherit}.password-wrap{position:relative}.password-wrap input{box-sizing:border-box;width:100%;padding-right:48px}.password-toggle{position:absolute;right:8px;top:50%;transform:translateY(-50%);border:0;background:transparent;color:#52647d;cursor:pointer;padding:6px}.password-toggle:hover{color:#176dcc}button{margin-top:24px;width:100%;border:0;border-radius:8px;background:#101d32;color:#fff;padding:14px;font-weight:700}.message{padding:12px;border-radius:8px;background:#eef6ff;color:#176dcc}</style></head><body><main class="page"><section class="card"><img class="logo" src="/uploads/tee-components-icon.png" alt="Tee Components"><h1>Set your password</h1><?php if ($success): ?><p class="message">Password set successfully. You can now <a href="/admin/">sign in</a>.</p><?php else: ?><p>Create a strong password with at least 12 characters. This invitation expires after 24 hours.</p><?php if ($message): ?><p class="message"><?= htmlspecialchars($message, ENT_QUOTES, 'UTF-8') ?></p><?php endif; ?><form method="post"><input type="hidden" name="token" value="<?= htmlspecialchars($token, ENT_QUOTES, 'UTF-8') ?>"><label>New password<span class="password-wrap"><input type="password" name="password" minlength="12" required autocomplete="new-password"><button type="button" class="password-toggle" aria-label="Show password" onclick="var i=this.previousElementSibling;i.type=i.type==='password'?'text':'password';this.setAttribute('aria-label',i.type==='password'?'Show password':'Hide password')">&#128065;</button></span></label><button>Set password</button></form><?php endif; ?></section></main></body></html>
