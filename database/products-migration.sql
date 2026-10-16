-- Run this once if you already imported schema.sql before products were added.
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

-- Adds the remaining categories from the Tee Components product catalogue without duplicating existing entries.
INSERT INTO products (title, description, specifications, sort_order)
SELECT seed.title, seed.description, seed.specifications, seed.sort_order
FROM (
  SELECT 'Money Counting Machines' title, 'Accurate and efficient money counting machines for organisations handling large cash volumes.' description, 'Features: UV/MG detection, high speed, portable models|Applications: Retail, banking, hospitality' specifications, 7 sort_order UNION ALL
  SELECT 'Solid State Hard Drives', 'High-performance SSDs for fast data access and dependable storage.', 'Brands: Samsung, Kingston, Crucial|Capacities: 256GB, 512GB, 1TB, 2TB', 8 UNION ALL
  SELECT 'Olivetti Printers', 'Efficient printing solutions designed for office and business environments.', 'Features: High-speed printing, duplex, wireless', 9 UNION ALL
  SELECT 'Epson Printers', 'Professional printers that deliver vivid colour and sharp text.', 'Features: EcoTank, multifunction printing', 10 UNION ALL
  SELECT 'HP Printers', 'Reliable printing solutions for home and enterprise use.', 'Models: DeskJet, LaserJet, OfficeJet', 11 UNION ALL
  SELECT 'Mouse', 'Ergonomic and responsive mice for daily productivity and specialist work.', 'Brands: Logitech, HP, Microsoft', 12 UNION ALL
  SELECT 'Fuser Units', 'Durable replacement fuser units for printer maintenance.', 'Brands: Canon, HP, Ricoh', 13 UNION ALL
  SELECT 'Network Switches', 'High-speed switches for seamless organisational connectivity.', 'Brands: Cisco, TP-Link, D-Link', 14 UNION ALL
  SELECT 'iPads', 'Versatile Apple iPads for work, learning and entertainment.', 'Models: iPad Air, iPad Pro, iPad Mini', 15 UNION ALL
  SELECT 'All-in-One ThinkPad Computers & Laptops', 'Integrated, space-saving systems for professional workspaces.', 'Features: Touchscreen, powerful performance', 16 UNION ALL
  SELECT 'Microsoft/Beats Headphones', 'Premium headphones for clear, immersive audio.', 'Features: Noise cancellation, Bluetooth', 17 UNION ALL
  SELECT 'BlackArmor NAS 400 Series', 'Network-attached storage for secure data management.', 'Capacity: 4TB, 8TB, 12TB|Features: RAID, remote access', 18 UNION ALL
  SELECT 'Cheque Scanners', 'High-accuracy cheque scanners for financial institutions and businesses.', 'Brands: Canon, Epson, Panini|Features: High-speed scanning, MICR reading, compact design', 19 UNION ALL
  SELECT 'TPG Receipt Printing Printers', 'Compact and reliable receipt printers for retail and hospitality.', 'Brands: TPG|Features: High-speed thermal printing, easy paper loading', 20
) AS seed
WHERE NOT EXISTS (SELECT 1 FROM products WHERE products.title = seed.title);
