<?php
require dirname(__DIR__) . '/bootstrap.php';
$admin = !empty($_SESSION['admin']) ? require_admin() : null;
respond(['admin' => $admin, 'csrf' => $admin ? csrf_token() : null]);
