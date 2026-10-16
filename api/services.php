<?php
require __DIR__ . '/bootstrap.php';
require_method('GET');

$services = db()->query('SELECT id, title, summary, details, benefits, service_includes, image_url, slug, icon FROM services WHERE is_published = 1 ORDER BY sort_order, id')->fetchAll();
respond($services);
