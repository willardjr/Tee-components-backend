<?php
require __DIR__ . '/bootstrap.php';
require_method('GET');

$products = db()->query('SELECT id, title, description, specifications, image_url, sort_order FROM products WHERE is_published = 1 ORDER BY sort_order, id')->fetchAll();
respond($products);
