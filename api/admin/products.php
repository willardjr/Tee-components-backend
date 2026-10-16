<?php
require dirname(__DIR__) . '/bootstrap.php';
require_admin();
$pdo = db();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') respond($pdo->query('SELECT id, title, description, specifications, image_url, sort_order, is_published FROM products ORDER BY sort_order, id')->fetchAll());
require_csrf();

function product_input(): array {
    $input = request_json();
    $title = trim((string) ($input['title'] ?? ''));
    $description = trim((string) ($input['description'] ?? ''));
    $specifications = trim((string) ($input['specifications'] ?? ''));
    $imageUrl = trim((string) ($input['image_url'] ?? ''));
    $sortOrder = max(0, (int) ($input['sort_order'] ?? 0));
    $published = !empty($input['is_published']) ? 1 : 0;
    if ($title === '' || $description === '') respond(['message' => 'Product title and description are required.'], 422);
    return compact('title', 'description', 'specifications', 'imageUrl', 'sortOrder', 'published');
}
if ($method === 'POST') {
    $product = product_input();
    $statement = $pdo->prepare('INSERT INTO products (title, description, specifications, image_url, sort_order, is_published) VALUES (?, ?, ?, ?, ?, ?)');
    $statement->execute([$product['title'], $product['description'], $product['specifications'], $product['imageUrl'], $product['sortOrder'], $product['published']]);
    respond(['message' => 'Product added successfully.', 'id' => (int) $pdo->lastInsertId()], 201);
}
if ($method === 'PUT') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) respond(['message' => 'A product ID is required.'], 422);
    $product = product_input();
    $statement = $pdo->prepare('UPDATE products SET title = ?, description = ?, specifications = ?, image_url = ?, sort_order = ?, is_published = ? WHERE id = ?');
    $statement->execute([$product['title'], $product['description'], $product['specifications'], $product['imageUrl'], $product['sortOrder'], $product['published'], $id]);
    respond(['message' => 'Product updated successfully.']);
}
if ($method === 'DELETE') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) respond(['message' => 'A product ID is required.'], 422);
    $pdo->prepare('DELETE FROM products WHERE id = ?')->execute([$id]);
    respond(['message' => 'Product deleted.']);
}
respond(['message' => 'Method not allowed.'], 405);
