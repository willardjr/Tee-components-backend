-- Run once for existing Tee Components databases. Back up the database first.
-- Requires MySQL 8.0.29+ for IF NOT EXISTS. On older MySQL, omit a line for a column that already exists.
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS role VARCHAR(20) NOT NULL DEFAULT 'admin' AFTER password_hash;
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS is_active TINYINT(1) NOT NULL DEFAULT 1 AFTER role;
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS suspended_until DATETIME NULL DEFAULT NULL AFTER is_active;
ALTER TABLE admin_users ADD COLUMN IF NOT EXISTS last_login_at DATETIME NULL DEFAULT NULL AFTER suspended_until;
UPDATE admin_users SET role = 'admin' WHERE role NOT IN ('super_admin', 'admin') OR role IS NULL;
ALTER TABLE admin_users MODIFY COLUMN role VARCHAR(20) NOT NULL DEFAULT 'admin';
UPDATE admin_users SET role = 'super_admin', is_active = 1 WHERE id = (SELECT id FROM (SELECT MIN(id) AS id FROM admin_users) AS first_user);

CREATE TABLE IF NOT EXISTS admin_invites (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_admin_invites_user FOREIGN KEY (user_id) REFERENCES admin_users(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS admin_password_resets (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  user_id INT UNSIGNED NOT NULL,
  token_hash CHAR(64) NOT NULL UNIQUE,
  expires_at DATETIME NOT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  CONSTRAINT fk_admin_password_resets_user FOREIGN KEY (user_id) REFERENCES admin_users(id) ON DELETE CASCADE
);
