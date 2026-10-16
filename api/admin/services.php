<?php
require dirname(__DIR__) . '/bootstrap.php';
require_admin();
$pdo = db();
$method = $_SERVER['REQUEST_METHOD'] ?? 'GET';

if ($method === 'GET') {
    respond($pdo->query('SELECT id, title, summary, details, benefits, service_includes, image_url, slug, icon, sort_order, is_published FROM services ORDER BY sort_order, id')->fetchAll());
}
require_csrf();

function service_input(): array {
    $input = request_json();
    $title = trim((string) ($input['title'] ?? ''));
    $summary = trim((string) ($input['summary'] ?? ''));
    $details = trim((string) ($input['details'] ?? ''));
    $benefits = trim((string) ($input['benefits'] ?? ''));
    $serviceIncludes = trim((string) ($input['service_includes'] ?? ''));
    $imageUrl = trim((string) ($input['image_url'] ?? ''));
    $icon = trim((string) ($input['icon'] ?? 'Settings'));
    $sortOrder = max(0, (int) ($input['sort_order'] ?? 0));
    $published = !empty($input['is_published']) ? 1 : 0;
    if ($title === '' || $summary === '' || $details === '') respond(['message' => 'Service title, summary and detail content are required.'], 422);
    $slug = strtolower(trim(preg_replace('/[^a-z0-9]+/i', '-', $title), '-'));
    if ($slug === '') respond(['message' => 'Please use a valid service title.'], 422);
    return compact('title', 'summary', 'details', 'benefits', 'serviceIncludes', 'imageUrl', 'icon', 'sortOrder', 'published', 'slug');
}

if ($method === 'POST') {
    $service = service_input();
    $existing = $pdo->prepare('SELECT COUNT(*) FROM services WHERE slug = ?');
    $existing->execute([$service['slug']]);
    if ((int) $existing->fetchColumn()) $service['slug'] .= '-' . time();
    $statement = $pdo->prepare('INSERT INTO services (title, summary, details, benefits, service_includes, image_url, slug, icon, sort_order, is_published) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)');
    $statement->execute([$service['title'], $service['summary'], $service['details'], $service['benefits'], $service['serviceIncludes'], $service['imageUrl'], $service['slug'], $service['icon'], $service['sortOrder'], $service['published']]);
    respond(['message' => 'Service added successfully.', 'id' => (int) $pdo->lastInsertId()], 201);
}

if ($method === 'PUT') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) respond(['message' => 'A service ID is required.'], 422);
    $service = service_input();
    $statement = $pdo->prepare('UPDATE services SET title = ?, summary = ?, details = ?, benefits = ?, service_includes = ?, image_url = ?, icon = ?, sort_order = ?, is_published = ? WHERE id = ?');
    $statement->execute([$service['title'], $service['summary'], $service['details'], $service['benefits'], $service['serviceIncludes'], $service['imageUrl'], $service['icon'], $service['sortOrder'], $service['published'], $id]);
    respond(['message' => 'Service updated successfully.']);
}

if ($method === 'DELETE') {
    $id = (int) ($_GET['id'] ?? 0);
    if (!$id) respond(['message' => 'A service ID is required.'], 422);
    $statement = $pdo->prepare('DELETE FROM services WHERE id = ?');
    $statement->execute([$id]);
    respond(['message' => 'Service deleted.']);
}
respond(['message' => 'Method not allowed.'], 405);
