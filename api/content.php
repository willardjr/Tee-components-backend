<?php
require __DIR__ . '/bootstrap.php';
require_method('GET');

$rows = db()->query('SELECT content_key, content_value FROM site_content')->fetchAll();
$content = [];
foreach ($rows as $row) $content[$row['content_key']] = $row['content_value'];
foreach ($content as $key => $value) {
    if (!str_ends_with($key, '_image_id') || empty($value)) continue;
    $statement = db()->prepare('SELECT id, stored_name, alt_text FROM media_items WHERE id = ?');
    $statement->execute([(int) $value]);
    $image = $statement->fetch();
    $content[substr($key, 0, -3)] = $image ? ['id' => (int) $image['id'], 'url' => '/uploads/' . rawurlencode($image['stored_name']), 'alt' => $image['alt_text']] : null;
}
respond($content);
