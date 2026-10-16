<?php
declare(strict_types=1);

ini_set('session.use_strict_mode', '1');
ini_set('session.use_only_cookies', '1');
session_name('tee_components_admin');
session_start([
    'cookie_httponly' => true,
    'cookie_samesite' => 'Lax',
    'cookie_secure' => !empty($_SERVER['HTTPS']) && $_SERVER['HTTPS'] !== 'off',
    'cookie_path' => '/',
]);

header('X-Content-Type-Options: nosniff');
header('X-Frame-Options: DENY');
header('Referrer-Policy: strict-origin-when-cross-origin');
header('Permissions-Policy: camera=(), microphone=(), geolocation=()');

function respond(array $data, int $status = 200): never
{
    http_response_code($status);
    header('Content-Type: application/json; charset=utf-8');
    header('Cache-Control: no-store');
    echo json_encode($data, JSON_UNESCAPED_SLASHES);
    exit;
}

function request_json(): array
{
    $data = json_decode(file_get_contents('php://input'), true);
    return is_array($data) ? $data : [];
}

function config(): array
{
    static $config = null;
    if ($config !== null) return $config;
    $file = dirname(__DIR__) . DIRECTORY_SEPARATOR . '.env';
    $config = is_file($file) ? parse_ini_file($file, false, INI_SCANNER_RAW) : [];
    if ($config === false) respond(['message' => 'Server configuration could not be read.'], 500);
    foreach (['DB_HOST', 'DB_PORT', 'DB_NAME', 'DB_USER', 'DB_PASSWORD', 'ADMIN_NAME', 'ADMIN_EMAIL', 'ADMIN_PASSWORD', 'RESEND_API_KEY', 'RESEND_FROM_EMAIL', 'RESEND_FROM_NAME', 'RESEND_TEST_RECIPIENT', 'SMTP_HOST', 'SMTP_PORT', 'SMTP_ENCRYPTION', 'SMTP_USERNAME', 'SMTP_PASSWORD', 'MAIL_FROM', 'MAIL_FROM_NAME', 'ENQUIRY_RECIPIENT', 'APP_URL', 'TURNSTILE_SECRET_KEY'] as $key) {
        $value = getenv($key);
        if ($value !== false) $config[$key] = $value;
    }
    return $config;
}

function smtp_response($socket): array
{
    $lines = [];
    do {
        $line = fgets($socket, 515);
        if ($line === false) throw new RuntimeException('SMTP server stopped responding.');
        $lines[] = rtrim($line, "\r\n");
    } while (isset($line[3]) && $line[3] === '-');

    $last = end($lines);
    return [(int) substr((string) $last, 0, 3), $lines];
}

function smtp_expect($socket, array $expected): void
{
    [$code] = smtp_response($socket);
    if (!in_array($code, $expected, true)) throw new RuntimeException('SMTP server rejected a request.');
}

function smtp_command($socket, string $command, array $expected): void
{
    if (fwrite($socket, $command . "\r\n") === false) throw new RuntimeException('SMTP server connection was lost.');
    smtp_expect($socket, $expected);
}

function resend_send_mail(string $to, string $subject, string $body, ?string $replyTo = null): bool
{
    $settings = config();
    $apiKey = trim((string) ($settings['RESEND_API_KEY'] ?? ''));
    $fromEmail = trim((string) ($settings['RESEND_FROM_EMAIL'] ?? ''));
    $fromName = trim((string) ($settings['RESEND_FROM_NAME'] ?? 'Tee Components'));
    $testRecipient = trim((string) ($settings['RESEND_TEST_RECIPIENT'] ?? ''));

    if ($apiKey === '' || !filter_var($to, FILTER_VALIDATE_EMAIL) || !filter_var($fromEmail, FILTER_VALIDATE_EMAIL)
        || ($replyTo !== null && !filter_var($replyTo, FILTER_VALIDATE_EMAIL))
        || ($testRecipient !== '' && !filter_var($testRecipient, FILTER_VALIDATE_EMAIL))) return false;

    $recipient = $testRecipient !== '' ? $testRecipient : $to;
    $safeName = str_replace(["\r", "\n"], '', $fromName);
    $safeSubject = str_replace(["\r", "\n"], '', $subject);
    $payload = [
        'from' => $safeName . ' <' . $fromEmail . '>',
        'to' => [$recipient],
        'subject' => $safeSubject,
        'text' => $body,
    ];
    if ($replyTo !== null) $payload['reply_to'] = $replyTo;

    try {
        $json = json_encode($payload, JSON_UNESCAPED_SLASHES | JSON_UNESCAPED_UNICODE | JSON_THROW_ON_ERROR);
        $context = stream_context_create([
            'http' => [
                'method' => 'POST',
                'header' => "Authorization: Bearer {$apiKey}\r\nContent-Type: application/json\r\nAccept: application/json\r\n",
                'content' => $json,
                'timeout' => 15,
                'ignore_errors' => true,
            ],
            'ssl' => ['verify_peer' => true, 'verify_peer_name' => true],
        ]);
        $response = @file_get_contents('https://api.resend.com/emails', false, $context);
        $statusLine = $http_response_header[0] ?? '';
        if (preg_match('/\s(\d{3})\s/', $statusLine, $matches) && (int) $matches[1] >= 200 && (int) $matches[1] < 300) {
            return true;
        }
        $detail = is_string($response) ? trim($response) : '';
        error_log('Resend delivery failed' . ($statusLine !== '' ? ': ' . $statusLine : '.') . ($detail !== '' ? ' ' . substr($detail, 0, 500) : ''));
        return false;
    } catch (Throwable $error) {
        error_log('Resend delivery failed: ' . $error->getMessage());
        return false;
    }
}

/**
 * Sends a plain-text email through Resend when configured, otherwise authenticated SMTP.
 * Returns false for delivery/configuration failures without exposing SMTP credentials.
 */
function send_mail(string $to, string $subject, string $body, ?string $replyTo = null): bool
{
    $settings = config();
    if (trim((string) ($settings['RESEND_API_KEY'] ?? '')) !== '') {
        return resend_send_mail($to, $subject, $body, $replyTo);
    }
    $host = trim((string) ($settings['SMTP_HOST'] ?? ''));
    $port = (int) ($settings['SMTP_PORT'] ?? 587);
    $encryption = strtolower(trim((string) ($settings['SMTP_ENCRYPTION'] ?? 'tls')));
    $username = trim((string) ($settings['SMTP_USERNAME'] ?? ''));
    $password = (string) ($settings['SMTP_PASSWORD'] ?? '');
    $from = trim((string) ($settings['MAIL_FROM'] ?? ''));
    $fromName = trim((string) ($settings['MAIL_FROM_NAME'] ?? 'Tee Components'));

    if (!filter_var($to, FILTER_VALIDATE_EMAIL) || !filter_var($from, FILTER_VALIDATE_EMAIL)
        || $host === '' || $port < 1 || $port > 65535 || !in_array($encryption, ['tls', 'ssl'], true)
        || $username === '' || $password === '' || ($replyTo !== null && !filter_var($replyTo, FILTER_VALIDATE_EMAIL))) return false;

    $socket = null;
    try {
        $context = stream_context_create(['ssl' => [
            'verify_peer' => true,
            'verify_peer_name' => true,
            'allow_self_signed' => false,
            'peer_name' => $host,
        ]]);
        $target = ($encryption === 'ssl' ? 'ssl://' : 'tcp://') . $host . ':' . $port;
        $socket = @stream_socket_client($target, $errno, $errstr, 15, STREAM_CLIENT_CONNECT, $context);
        if ($socket === false) throw new RuntimeException('SMTP server could not be reached.');
        stream_set_timeout($socket, 15);

        smtp_expect($socket, [220]);
        smtp_command($socket, 'EHLO localhost', [250]);
        if ($encryption === 'tls') {
            smtp_command($socket, 'STARTTLS', [220]);
            if (!stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT)) {
                throw new RuntimeException('SMTP TLS negotiation failed.');
            }
            smtp_command($socket, 'EHLO localhost', [250]);
        }
        smtp_command($socket, 'AUTH LOGIN', [334]);
        smtp_command($socket, base64_encode($username), [334]);
        smtp_command($socket, base64_encode($password), [235]);
        smtp_command($socket, 'MAIL FROM:<' . $from . '>', [250]);
        smtp_command($socket, 'RCPT TO:<' . $to . '>', [250, 251]);
        smtp_command($socket, 'DATA', [354]);

        $safeName = str_replace(["\r", "\n"], '', $fromName);
        $safeSubject = str_replace(["\r", "\n"], '', $subject);
        $encodedSubject = function_exists('mb_encode_mimeheader')
            ? mb_encode_mimeheader($safeSubject, 'UTF-8', 'B', "\r\n")
            : $safeSubject;
        $headers = [
            'From: ' . $safeName . ' <' . $from . '>',
            'To: <' . $to . '>',
            'Subject: ' . $encodedSubject,
            'MIME-Version: 1.0',
            'Content-Type: text/plain; charset=UTF-8',
            'Content-Transfer-Encoding: 8bit',
        ];
        if ($replyTo !== null) $headers[] = 'Reply-To: <' . $replyTo . '>';
        $message = implode("\r\n", $headers) . "\r\n\r\n" . str_replace("\n.", "\n..", str_replace("\r\n", "\n", $body));
        if (fwrite($socket, $message . "\r\n.\r\n") === false) throw new RuntimeException('SMTP server connection was lost.');
        smtp_expect($socket, [250]);
        smtp_command($socket, 'QUIT', [221]);
        fclose($socket);
        return true;
    } catch (Throwable $error) {
        error_log('SMTP delivery failed: ' . $error->getMessage());
        if (is_resource($socket)) fclose($socket);
        return false;
    }
}

function db(): PDO
{
    static $pdo = null;
    if ($pdo instanceof PDO) return $pdo;
    $config = config();
    try {
        $pdo = new PDO(
            sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', $config['DB_HOST'] ?? '127.0.0.1', $config['DB_PORT'] ?? '3306', $config['DB_NAME'] ?? 'tee_components'),
            $config['DB_USER'] ?? 'root',
            $config['DB_PASSWORD'] ?? '',
            [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION, PDO::ATTR_DEFAULT_FETCH_MODE => PDO::FETCH_ASSOC]
        );
        return $pdo;
    } catch (PDOException) {
        respond(['message' => 'The website database is unavailable. Check the MySQL service and .env credentials.'], 503);
    }
}

function require_method(string ...$methods): void
{
    if (!in_array($_SERVER['REQUEST_METHOD'] ?? 'GET', $methods, true)) respond(['message' => 'Method not allowed.'], 405);
}

function require_admin(): array
{
    if (empty($_SESSION['admin']) || !is_array($_SESSION['admin'])) respond(['message' => 'Please sign in to continue.'], 401);
    $now = time();
    if (($now - (int) ($_SESSION['last_activity'] ?? $now)) > 28800) {
        session_unset();
        session_destroy();
        respond(['message' => 'Your session has expired. Please sign in again.'], 401);
    }
    $statement = db()->prepare('SELECT id, name, email, role, is_active, suspended_until FROM admin_users WHERE id = ? LIMIT 1');
    $statement->execute([(int) ($_SESSION['admin']['id'] ?? 0)]);
    $admin = $statement->fetch();
    $isSuspended = $admin && $admin['suspended_until'] && strtotime($admin['suspended_until']) > $now;
    if (!$admin || !(int) $admin['is_active'] || $isSuspended || !in_array($admin['role'], ['super_admin', 'admin'], true)) {
        $_SESSION = [];
        session_destroy();
        respond(['message' => 'Your account is no longer active. Please contact a super admin.'], 401);
    }
    $_SESSION['admin'] = [
        'id' => (int) $admin['id'],
        'name' => $admin['name'],
        'email' => $admin['email'],
        'role' => $admin['role'],
    ];
    $_SESSION['last_activity'] = $now;
    return $_SESSION['admin'];
}

function require_super_admin(): array
{
    $admin = require_admin();
    if (($admin['role'] ?? '') !== 'super_admin') respond(['message' => 'Only a super admin can manage user accounts.'], 403);
    return $admin;
}

function csrf_token(): string
{
    if (empty($_SESSION['csrf_token'])) $_SESSION['csrf_token'] = bin2hex(random_bytes(32));
    return $_SESSION['csrf_token'];
}

function require_csrf(): void
{
    $token = $_SERVER['HTTP_X_CSRF_TOKEN'] ?? '';
    if (!is_string($token) || !hash_equals((string) ($_SESSION['csrf_token'] ?? ''), $token)) {
        respond(['message' => 'Security check failed. Refresh the page and try again.'], 419);
    }
}

function rate_limit(string $bucket, int $maximum, int $windowSeconds): void
{
    $address = $_SERVER['REMOTE_ADDR'] ?? 'unknown';
    $file = sys_get_temp_dir() . DIRECTORY_SEPARATOR . 'tee-components-' . hash('sha256', $bucket . '|' . $address) . '.json';
    $now = time();
    $entries = is_file($file) ? json_decode((string) file_get_contents($file), true) : [];
    $entries = is_array($entries) ? array_values(array_filter($entries, static fn ($time) => (int) $time > $now - $windowSeconds)) : [];
    if (count($entries) >= $maximum) respond(['message' => 'Too many requests. Please wait and try again.'], 429);
    $entries[] = $now;
    file_put_contents($file, json_encode($entries), LOCK_EX);
}

function uploads_path(): string
{
    $path = dirname(__DIR__) . DIRECTORY_SEPARATOR . 'uploads';
    if (!is_dir($path)) mkdir($path, 0755, true);
    return $path;
}
