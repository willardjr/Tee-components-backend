<?php
require dirname(__DIR__) . '/bootstrap.php';
require_method('POST');
require_admin();
require_csrf();
$_SESSION = [];
session_destroy();
http_response_code(204);
exit;
