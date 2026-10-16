<?php
require __DIR__ . '/bootstrap.php';
require_method('GET');
$posts = db()->query('SELECT id, title, excerpt, content, image_url, published_at FROM news_posts WHERE is_published = 1 AND published_at <= NOW() ORDER BY published_at DESC, id DESC')->fetchAll();
respond($posts);
