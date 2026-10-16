<?php
require dirname(__DIR__) . '/bootstrap.php';
require_admin();
$pdo = db();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';
if ($method === 'GET') respond($pdo->query('SELECT id, title, excerpt, content, image_url, published_at, is_published FROM news_posts ORDER BY published_at DESC, id DESC')->fetchAll());
require_csrf();

function news_input(): array {
    $input = request_json();
    $title = trim((string) ($input['title'] ?? ''));
    $excerpt = trim((string) ($input['excerpt'] ?? ''));
    $content = trim((string) ($input['content'] ?? ''));
    $imageUrl = trim((string) ($input['image_url'] ?? ''));
    $publishedAt = trim((string) ($input['published_at'] ?? ''));
    $published = !empty($input['is_published']) ? 1 : 0;
    if (!$title || !$excerpt || !$content) respond(['message' => 'Title, summary and full news content are required.'], 422);
    $date = $publishedAt ? date('Y-m-d H:i:s', strtotime($publishedAt)) : date('Y-m-d H:i:s');
    return compact('title', 'excerpt', 'content', 'imageUrl', 'publishedAt', 'published', 'date');
}
if ($method === 'POST') {
    $post = news_input();
    $statement = $pdo->prepare('INSERT INTO news_posts (title, excerpt, content, image_url, published_at, is_published) VALUES (?, ?, ?, ?, ?, ?)');
    $statement->execute([$post['title'], $post['excerpt'], $post['content'], $post['imageUrl'], $post['date'], $post['published']]);
    respond(['message' => 'News post added successfully.', 'id' => (int) $pdo->lastInsertId()], 201);
}
if ($method === 'PUT') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) respond(['message' => 'A news post ID is required.'], 422);
    $post = news_input();
    $statement = $pdo->prepare('UPDATE news_posts SET title = ?, excerpt = ?, content = ?, image_url = ?, published_at = ?, is_published = ? WHERE id = ?');
    $statement->execute([$post['title'], $post['excerpt'], $post['content'], $post['imageUrl'], $post['date'], $post['published'], $id]);
    respond(['message' => 'News post updated successfully.']);
}
if ($method === 'DELETE') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) respond(['message' => 'A news post ID is required.'], 422);
    $statement = $pdo->prepare('DELETE FROM news_posts WHERE id = ?');
    $statement->execute([$id]);
    respond(['message' => 'News post deleted.']);
}
respond(['message' => 'Method not allowed.'], 405);
