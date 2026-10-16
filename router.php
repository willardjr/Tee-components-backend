<?php
declare(strict_types=1);

$path = parse_url($_SERVER['REQUEST_URI'] ?? '/', PHP_URL_PATH) ?: '/';
if ($path === '/') {
    header('Location: /admin/', true, 302);
    exit;
}

return false;
