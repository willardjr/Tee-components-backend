<?php
declare(strict_types=1);

require __DIR__ . '/bootstrap.php';
require_method('POST');
rate_limit('website-enquiry', 4, 3600);

$input = request_json();
$name = trim((string) ($input['name'] ?? ''));
$email = strtolower(trim((string) ($input['email'] ?? '')));
$phone = trim((string) ($input['phone'] ?? ''));
$service = trim((string) ($input['service'] ?? 'General enquiry'));
$message = trim((string) ($input['message'] ?? ''));
$startedAt = (int) ($input['started_at'] ?? 0);
$honeypot = trim((string) ($input['company_website'] ?? ''));
$turnstileToken = trim((string) ($input['turnstile_token'] ?? ''));

if ($honeypot !== '' || !$startedAt || time() - $startedAt < 3) respond(['message' => 'We could not verify this submission. Please try again.'], 422);
$turnstileSecret = trim((string) (config()['TURNSTILE_SECRET_KEY'] ?? ''));
if ($turnstileSecret === '') respond(['message' => 'Human verification is not configured yet. Please call us instead.'], 503);
if ($turnstileToken === '' || strlen($turnstileToken) > 2048) respond(['message' => 'Please complete the human verification and try again.'], 422);
$verifyContext = stream_context_create([
    'http' => [
        'method' => 'POST',
        'header' => "Content-Type: application/x-www-form-urlencoded\r\n",
        'content' => http_build_query(['secret' => $turnstileSecret, 'response' => $turnstileToken]),
        'timeout' => 10,
        'ignore_errors' => true,
    ],
    'ssl' => ['verify_peer' => true, 'verify_peer_name' => true],
]);
$verificationResponse = @file_get_contents('https://challenges.cloudflare.com/turnstile/v0/siteverify', false, $verifyContext);
$verification = is_string($verificationResponse) ? json_decode($verificationResponse, true) : null;
if (!is_array($verification) || empty($verification['success'])) {
    error_log('Turnstile verification failed' . (is_array($verification) ? ': ' . implode(',', $verification['error-codes'] ?? []) : '.'));
    respond(['message' => 'Human verification could not be confirmed. Please try again.'], 422);
}
if (mb_strlen($name) < 2 || mb_strlen($name) > 100 || !filter_var($email, FILTER_VALIDATE_EMAIL)) respond(['message' => 'Enter your name and a valid email address.'], 422);
if (mb_strlen($phone) > 40 || mb_strlen($service) > 120 || mb_strlen($message) < 10 || mb_strlen($message) > 4000) respond(['message' => 'Please provide a short project description (10–4,000 characters).'], 422);
foreach ([$name, $email, $phone, $service, $message] as $value) {
    if (preg_match('/[\r\n]/', $value) && $value !== $message) respond(['message' => 'Invalid form content.'], 422);
}

$config = config();
$recipient = trim((string) ($config['ENQUIRY_RECIPIENT'] ?? $config['CONTACT_EMAIL'] ?? ''));
$from = trim((string) ($config['MAIL_FROM'] ?? ''));
if (!filter_var($recipient, FILTER_VALIDATE_EMAIL) || !filter_var($from, FILTER_VALIDATE_EMAIL)) {
    respond(['message' => 'Email delivery has not been configured yet. Please call us instead.'], 503);
}

$safe = static fn (string $value): string => trim(strip_tags($value));
$body = "New website enquiry\n\n"
    . 'Name: ' . $safe($name) . "\n"
    . 'Email: ' . $safe($email) . "\n"
    . 'Phone: ' . $safe($phone) . "\n"
    . 'Service: ' . $safe($service) . "\n\n"
    . "Project details:\n" . $safe($message) . "\n";
if (!send_mail($recipient, 'Website enquiry: ' . $safe($service), $body, $email)) {
    respond(['message' => 'Your enquiry could not be sent right now. Please call us instead.'], 503);
}
respond(['message' => 'Thank you. Your enquiry has been sent.']);
