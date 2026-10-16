CREATE DATABASE IF NOT EXISTS tee_components
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE tee_components;

CREATE TABLE IF NOT EXISTS admin_users (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  name VARCHAR(100) NOT NULL,
  email VARCHAR(190) NOT NULL UNIQUE,
  password_hash VARCHAR(255) NOT NULL,
  role VARCHAR(20) NOT NULL DEFAULT 'admin',
  is_active TINYINT(1) NOT NULL DEFAULT 1,
  suspended_until DATETIME NULL DEFAULT NULL,
  last_login_at DATETIME NULL DEFAULT NULL,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

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

CREATE TABLE IF NOT EXISTS site_content (
  content_key VARCHAR(100) PRIMARY KEY,
  content_value TEXT NOT NULL,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS media_items (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  original_name VARCHAR(255) NOT NULL,
  stored_name VARCHAR(255) NOT NULL UNIQUE,
  mime_type VARCHAR(100) NOT NULL,
  alt_text VARCHAR(255) NOT NULL DEFAULT '',
  uploaded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS services (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(150) NOT NULL,
  summary TEXT NOT NULL,
  details TEXT NOT NULL,
  benefits TEXT NOT NULL,
  service_includes TEXT NOT NULL,
  image_url VARCHAR(500) NOT NULL DEFAULT '',
  slug VARCHAR(170) NOT NULL UNIQUE,
  icon VARCHAR(50) NOT NULL DEFAULT 'Settings',
  sort_order INT UNSIGNED NOT NULL DEFAULT 0,
  is_published TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS news_posts (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(220) NOT NULL,
  excerpt TEXT NOT NULL,
  content TEXT NOT NULL,
  image_url VARCHAR(500) NOT NULL DEFAULT '',
  published_at DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP,
  is_published TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

CREATE TABLE IF NOT EXISTS products (
  id INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
  title VARCHAR(180) NOT NULL,
  description TEXT NOT NULL,
  specifications TEXT NOT NULL,
  image_url VARCHAR(500) NOT NULL DEFAULT '',
  sort_order INT UNSIGNED NOT NULL DEFAULT 0,
  is_published TINYINT(1) NOT NULL DEFAULT 1,
  created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
  updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP
);

INSERT INTO site_content (content_key, content_value) VALUES
  ('hero_eyebrow', 'ICT solutions · Malawi'),
  ('hero_title_main', 'Technology that keeps'),
  ('hero_title_accent', 'your business moving.'),
  ('hero_description', 'From the right equipment to reliable infrastructure and ongoing support, we help organisations work securely, efficiently and without interruption.'),
  ('primary_phone', '+265 884 534 425'),
  ('secondary_phone', '+265 999 933 197'),
  ('contact_email', 'teecomp@globemw.net'),
  ('address', 'Kidney Crescent Road, Blantyre, Malawi'),
  ('business_hours', 'Monday – Friday | 8:00 AM – 5:00 PM'),
  ('logo_image_id', ''),
  ('about_image_id', ''),
  ('process_image_id', ''),
  ('team_image_id', ''),
  ('hero_image_id', '')
ON DUPLICATE KEY UPDATE content_value = VALUES(content_value);

INSERT INTO services (title, summary, details, benefits, service_includes, slug, icon, sort_order) VALUES
  ('Preventive Maintenance', 'Proactively inspecting and servicing ICT equipment to optimise performance and reduce downtime.', 'Tee Components provides professional maintenance for ICT equipment, from routine inspections and diagnostics to repairs and replacement of faulty components. Our service helps businesses minimise downtime, improve productivity and extend the life of their technology investments.', 'Proactive maintenance plans|On-site and remote support|Genuine replacement parts|Fast response times', 'Hardware diagnostics and repairs|Printer maintenance and troubleshooting|Network equipment upkeep|Laptop and desktop repairs|Preventive maintenance schedules', 'preventive-maintenance', 'Wrench', 1),
  ('Networking Solutions', 'Designing, installing and maintaining LAN and WAN systems for seamless connectivity.', 'We design, install and maintain dependable network infrastructure that keeps people, systems and locations connected. Our networking solutions are planned around your organisation’s performance, coverage, security and future growth requirements.', 'Reliable LAN and WAN connectivity|Scalable network design|Professional installation|Ongoing support and optimisation', 'Network assessment and design|LAN and WAN installation|Wi-Fi deployment|Routers, switches and access points|Network maintenance and troubleshooting', 'networking-solutions', 'Network', 2),
  ('IT Equipment Supply', 'Providing high-quality ICT equipment including printers, servers, POS machines and spare parts.', 'We supply high-quality ICT equipment tailored to your organisation’s needs. From printers and laptops to POS machines, servers and spare parts, our team helps you choose dependable technology that supports daily operations and future growth.', 'Wide range of ICT equipment|Trusted global brands|Competitive pricing|After-sales support and warranties', 'Printers and printer parts|Laptops and accessories|POS machines|Servers and networking equipment|Surveillance systems', 'it-equipment-supply', 'MonitorCog', 3),
  ('Video Surveillance Systems', 'Enhancing security with IP and analog camera installations for businesses and homes.', 'Protect your premises with video surveillance designed around your environment. We install practical IP and analog camera solutions that improve visibility, deterrence and incident response for businesses and homes.', 'Improved site visibility|Solutions for businesses and homes|Professional installation|Ongoing technical support', 'Site assessment|IP and analog camera installation|Recording and monitoring configuration|Remote viewing setup|Maintenance and support', 'video-surveillance-systems', 'Cctv', 4),
  ('Access Control Systems', 'Secure and manage facility access with advanced authentication systems.', 'Tee Components provides reliable and customisable access control systems that help safeguard your premises and ensure only authorised people can enter. We tailor solutions for organisations of all sizes.', 'Biometric, RFID and keypad options|Customisable configurations|Integration with existing systems|Enhanced monitoring and control', 'Biometric access systems|Card-based RFID solutions|Keypad and PIN access|Video surveillance integration|Maintenance and technical support', 'access-control-systems', 'ScanFace', 5),
  ('Time & Attendance Systems', 'Streamlining payroll processes with integrated employee attendance tracking solutions.', 'Our time and attendance systems simplify employee tracking and payroll processes. From biometric devices to cloud-based tracking, we help organisations improve accuracy, reduce errors and gain useful workforce insights.', 'Biometric and card-based systems|Cloud access for remote visibility|Payroll integration|Real-time tracking and reporting', 'Biometric attendance systems|Cloud-based attendance solutions|HR and payroll integration|Custom reporting and analytics|On-site setup and support', 'time-attendance-systems', 'Clock3', 6),
  ('Database Design & Management', 'Providing robust database solutions to streamline operations and improve data accessibility.', 'We create reliable database solutions that organise critical information, improve access to data and support smoother day-to-day operations. Each solution is designed around your organisation’s workflows and reporting needs.', 'Better data accessibility|Structured business information|Tailored to operations|Support for reporting and growth', 'Database requirements assessment|Database design and implementation|Data organisation|Reporting support|Maintenance and optimisation', 'database-design-management', 'Database', 7),
  ('Video Conferencing Systems', 'Setting up advanced video conferencing solutions for seamless remote communication.', 'Enable clear, dependable remote communication with video conferencing systems designed for meeting rooms, teams and organisations. We help select, install and configure the right solution for your environment.', 'Clearer remote collaboration|Solutions for meeting spaces|Professional setup|Ongoing technical support', 'Solution assessment|Equipment supply|Meeting room installation|Configuration and user setup|Technical support', 'video-conferencing-systems', 'Video', 8)
ON DUPLICATE KEY UPDATE title = VALUES(title), summary = VALUES(summary), details = VALUES(details), benefits = VALUES(benefits), service_includes = VALUES(service_includes), icon = VALUES(icon), sort_order = VALUES(sort_order);

INSERT INTO products (title, description, specifications, sort_order) VALUES
  ('Laptops', 'High-performance laptops from trusted brands for personal, professional and educational use.', 'Brands: Dell, HP, Lenovo|Features: Intel/AMD processors, SSD storage, long battery life', 1),
  ('Printers', 'Efficient office and home printers, including inkjet, laser and multifunctional models.', 'Brands: Canon, Epson, HP|Features: Print, scan, copy, wireless connectivity', 2),
  ('POS Machines', 'Modern point-of-sale machines designed to streamline transactions in retail and hospitality.', 'Brands: Clover, Square, Verifone|Features: Touchscreen, receipt printing, barcode scanning', 3),
  ('Networking Devices', 'Reliable routers, switches and access points that improve connectivity across your organisation.', 'Brands: TP-Link, Cisco, Netgear|Features: High-speed connectivity, dual-band support', 4),
  ('Laptop Accessories', 'Batteries, keyboards, chargers, bags, docking stations and other accessories.', 'Items: Batteries, bags, docking stations, motherboards', 5),
  ('Projectors', 'High-resolution projectors for presentations, training and events.', 'Brands: Epson, BenQ, Sony', 6),
  ('Money Counting Machines', 'Accurate and efficient money counting machines for organisations handling large cash volumes.', 'Features: UV/MG detection, high speed, portable models|Applications: Retail, banking, hospitality', 7),
  ('Solid State Hard Drives', 'High-performance SSDs for fast data access and dependable storage.', 'Brands: Samsung, Kingston, Crucial|Capacities: 256GB, 512GB, 1TB, 2TB', 8),
  ('Olivetti Printers', 'Efficient printing solutions designed for office and business environments.', 'Features: High-speed printing, duplex, wireless', 9),
  ('Epson Printers', 'Professional printers that deliver vivid colour and sharp text.', 'Features: EcoTank, multifunction printing', 10),
  ('HP Printers', 'Reliable printing solutions for home and enterprise use.', 'Models: DeskJet, LaserJet, OfficeJet', 11),
  ('Mouse', 'Ergonomic and responsive mice for daily productivity and specialist work.', 'Brands: Logitech, HP, Microsoft', 12),
  ('Fuser Units', 'Durable replacement fuser units for printer maintenance.', 'Brands: Canon, HP, Ricoh', 13),
  ('Network Switches', 'High-speed switches for seamless organisational connectivity.', 'Brands: Cisco, TP-Link, D-Link', 14),
  ('iPads', 'Versatile Apple iPads for work, learning and entertainment.', 'Models: iPad Air, iPad Pro, iPad Mini', 15),
  ('All-in-One ThinkPad Computers & Laptops', 'Integrated, space-saving systems for professional workspaces.', 'Features: Touchscreen, powerful performance', 16),
  ('Microsoft/Beats Headphones', 'Premium headphones for clear, immersive audio.', 'Features: Noise cancellation, Bluetooth', 17),
  ('BlackArmor NAS 400 Series', 'Network-attached storage for secure data management.', 'Capacity: 4TB, 8TB, 12TB|Features: RAID, remote access', 18),
  ('Cheque Scanners', 'High-accuracy cheque scanners for financial institutions and businesses.', 'Brands: Canon, Epson, Panini|Features: High-speed scanning, MICR reading, compact design', 19),
  ('TPG Receipt Printing Printers', 'Compact and reliable receipt printers for retail and hospitality.', 'Brands: TPG|Features: High-speed thermal printing, easy paper loading', 20);
