<?php
require dirname(__DIR__) . '/bootstrap.php';
require_admin();

if (($_SERVER['REQUEST_METHOD'] ?? 'GET') === 'GET') {
    $rows = db()->query('SELECT id, original_name, stored_name, mime_type, alt_text, uploaded_at FROM media_items ORDER BY uploaded_at DESC')->fetchAll();
    foreach ($rows as &$row) $row['url'] = '/uploads/' . rawurlencode($row['stored_name']);
    respond($rows);
}
require_method('POST');
require_csrf();
if (empty($_FILES['image']) || $_FILES['image']['error'] !== UPLOAD_ERR_OK) respond(['message' => 'Choose a JPG, PNG, or WebP image up to 5 MB.'], 422);
$file = $_FILES['image'];
if ($file['size'] > 5 * 1024 * 1024) respond(['message' => 'Images must be 5 MB or smaller.'], 422);
$mime = (new finfo(FILEINFO_MIME_TYPE))->file($file['tmp_name']);
$extensions = ['image/jpeg' => 'jpg', 'image/png' => 'png', 'image/webp' => 'webp'];
if (!isset($extensions[$mime])) respond(['message' => 'Only JPG, PNG, and WebP images are allowed.'], 422);

$storedName = bin2hex(random_bytes(20)) . '.' . $extensions[$mime];
if (!move_uploaded_file($file['tmp_name'], uploads_path() . DIRECTORY_SEPARATOR . $storedName)) respond(['message' => 'Image upload failed. Please try again.'], 500);
$altText = substr(trim((string) ($_POST['alt_text'] ?? '')), 0, 255);
$statement = db()->prepare('INSERT INTO media_items (original_name, stored_name, mime_type, alt_text) VALUES (?, ?, ?, ?)');
$statement->execute([basename($file['name']), $storedName, $mime, $altText]);
respond(['id' => (int) db()->lastInsertId(), 'url' => '/uploads/' . rawurlencode($storedName), 'alt_text' => $altText], 201);
