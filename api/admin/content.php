<?php
require dirname(__DIR__) . '/bootstrap.php';
require_admin();

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET') {
    $rows = db()->query('SELECT content_key, content_value FROM site_content ORDER BY content_key')->fetchAll();
    $content = [];
    foreach ($rows as $row) $content[$row['content_key']] = $row['content_value'];
    respond($content);
}
require_method('PUT');
require_csrf();
$allowed = ['hero_eyebrow', 'hero_title_main', 'hero_title_accent', 'hero_description', 'primary_phone', 'secondary_phone', 'contact_email', 'address', 'business_hours', 'hero_image_id', 'logo_image_id', 'about_image_id', 'process_image_id', 'team_image_id'];
$input = request_json();
$updates = array_intersect_key($input, array_flip($allowed));
if (!$updates) respond(['message' => 'No valid content changes were provided.'], 422);

$pdo = db();
$statement = $pdo->prepare('INSERT INTO site_content (content_key, content_value) VALUES (?, ?) ON DUPLICATE KEY UPDATE content_value = VALUES(content_value)');
$pdo->beginTransaction();
try {
    foreach ($updates as $key => $value) {
        if (!is_string($value)) continue;
        $statement->execute([$key, trim($value)]);
    }
    $pdo->commit();
} catch (Throwable $error) {
    $pdo->rollBack();
    throw $error;
}
respond(['message' => 'Changes published successfully.']);
