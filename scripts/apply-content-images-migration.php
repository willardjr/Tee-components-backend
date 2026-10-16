<?php
declare(strict_types=1);

$config = parse_ini_file(dirname(__DIR__) . DIRECTORY_SEPARATOR . '.env', false, INI_SCANNER_RAW);
if ($config === false) {
    fwrite(STDERR, "Unable to read .env.\n");
    exit(1);
}

$pdo = new PDO(
    sprintf('mysql:host=%s;port=%s;dbname=%s;charset=utf8mb4', $config['DB_HOST'] ?? '127.0.0.1', $config['DB_PORT'] ?? '3306', $config['DB_NAME'] ?? 'tee_components'),
    $config['DB_USER'] ?? 'root',
    $config['DB_PASSWORD'] ?? '',
    [PDO::ATTR_ERRMODE => PDO::ERRMODE_EXCEPTION]
);

foreach (['services' => 'service_includes', 'news_posts' => 'content'] as $table => $afterColumn) {
    $column = $pdo->prepare("SHOW COLUMNS FROM `{$table}` LIKE 'image_url'");
    $column->execute();
    if ($column->fetch()) {
        echo "image_url already exists on {$table}.\n";
        continue;
    }
    $pdo->exec("ALTER TABLE `{$table}` ADD COLUMN image_url VARCHAR(500) NOT NULL DEFAULT '' AFTER `{$afterColumn}`");
    echo "Added image_url to {$table}.\n";
}

$pdo->exec('CREATE TABLE IF NOT EXISTS admin_password_resets (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_admin_password_resets_user FOREIGN KEY (user_id) REFERENCES admin_users(id) ON DELETE CASCADE
)');
echo "Password-reset table is ready.\n";
