require('dotenv').config();
const mysql = require('mysql2/promise');
const bcrypt = require('bcryptjs');

async function createAdmin() {
  const required = ['ADMIN_NAME', 'ADMIN_EMAIL', 'ADMIN_PASSWORD'];
  const missing = required.filter((key) => !process.env[key] || process.env[key].includes('change-this'));
  if (missing.length) throw new Error(`Set ${missing.join(', ')} in .env before creating an admin.`);
  const connection = await mysql.createConnection({ host: process.env.DB_HOST, port: Number(process.env.DB_PORT || 3306), database: process.env.DB_NAME, user: process.env.DB_USER, password: process.env.DB_PASSWORD });
  const passwordHash = await bcrypt.hash(process.env.ADMIN_PASSWORD, 12);
  await connection.query('INSERT INTO admin_users (name, email, password_hash) VALUES (?, ?, ?) ON DUPLICATE KEY UPDATE name = VALUES(name), password_hash = VALUES(password_hash)', [process.env.ADMIN_NAME, process.env.ADMIN_EMAIL.toLowerCase(), passwordHash]);
  await connection.end();
  console.log(`Admin account is ready for ${process.env.ADMIN_EMAIL}.`);
}

createAdmin().catch((error) => { console.error(error.message); process.exitCode = 1; });
