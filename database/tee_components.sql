-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Oct 16, 2026 at 07:41 AM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.0.30

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `tee_components`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_invites`
--

CREATE TABLE `admin_invites` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Table structure for table `admin_password_resets`
--

CREATE TABLE `admin_password_resets` (
  `id` int(10) UNSIGNED NOT NULL,
  `user_id` int(10) UNSIGNED NOT NULL,
  `token_hash` char(64) NOT NULL,
  `expires_at` datetime NOT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_password_resets`
--

-- --------------------------------------------------------

--
-- Table structure for table `admin_users`
--

CREATE TABLE `admin_users` (
  `id` int(10) UNSIGNED NOT NULL,
  `name` varchar(100) NOT NULL,
  `email` varchar(190) NOT NULL,
  `password_hash` varchar(255) NOT NULL,
  `role` varchar(20) NOT NULL DEFAULT 'admin',
  `is_active` tinyint(1) NOT NULL DEFAULT 1,
  `suspended_until` datetime DEFAULT NULL,
  `last_login_at` datetime DEFAULT NULL,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `admin_users`
--

-- --------------------------------------------------------

--
-- Table structure for table `media_items`
--

CREATE TABLE `media_items` (
  `id` int(10) UNSIGNED NOT NULL,
  `original_name` varchar(255) NOT NULL,
  `stored_name` varchar(255) NOT NULL,
  `mime_type` varchar(100) NOT NULL,
  `alt_text` varchar(255) NOT NULL DEFAULT '',
  `uploaded_at` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `media_items`
--

INSERT INTO `media_items` (`id`, `original_name`, `stored_name`, `mime_type`, `alt_text`, `uploaded_at`) VALUES
(1, 'tee components.png', 'tee components.png', 'image/png', 'Tee Components logo', '2026-09-08 07:54:38'),
(2, 'about-1.jpg', 'about-1.jpg', 'image/jpeg', 'Tee Components technician maintaining equipment', '2026-09-08 07:54:39'),
(3, 'work-process-1.jpg', 'work-process-1.jpg', 'image/jpeg', 'Tee Components team member at work', '2026-09-08 07:54:39'),
(4, 'about.jpg', 'about.jpg', 'image/jpeg', 'Tee Components specialist at work', '2026-09-08 07:54:39'),
(5, 'work-process-2.jpg', 'work-process-2.jpg', 'image/jpeg', 'Tee Components technicians working together', '2026-09-08 07:54:39'),
(6, 'teeabout2.jpg', 'teeabout2.jpg', 'image/jpeg', 'Tee Components technical team', '2026-09-08 07:54:39'),
(7, 'teeabout2.jpg', 'cbc711dd9fe6321e804dd522bae748577daf00f5.jpg', 'image/jpeg', 'Induction of new Interns', '2026-09-23 14:22:32'),
(8, 'Conception de modÃ¨le de page de connexion utilisateur de site Web _ Vecteur Gratuite.jpg', '056de9d239c09d52a833266be64db7a5848843ef.jpg', 'image/jpeg', '', '2026-09-25 07:38:58'),
(9, 'Conception de modÃ¨le de page de connexion utilisateur de site Web _ Vecteur Gratuite.jpg', '3af130c59668e0f817af27e8e064decfde789120.jpg', 'image/jpeg', '', '2026-09-25 07:39:11'),
(10, 'Conception de modÃ¨le de page de connexion utilisateur de site Web _ Vecteur Gratuite.jpg', '27a6edf74e3ad96f5fef6d41854fc3c3fe8dcd71.jpg', 'image/jpeg', 'Web development', '2026-09-25 07:44:18'),
(11, 'IMG-20210830-WA0035.jpg', '5f7c9ace519554c1c92a032e31a58b2206645139.jpg', 'image/jpeg', 'Mobile phones', '2026-09-25 07:52:21');

-- --------------------------------------------------------

--
-- Table structure for table `news_posts`
--

CREATE TABLE `news_posts` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(220) NOT NULL,
  `excerpt` text NOT NULL,
  `content` text NOT NULL,
  `image_url` varchar(500) NOT NULL DEFAULT '',
  `published_at` datetime NOT NULL DEFAULT current_timestamp(),
  `is_published` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `news_posts`
--

INSERT INTO `news_posts` (`id`, `title`, `excerpt`, `content`, `image_url`, `published_at`, `is_published`, `created_at`, `updated_at`) VALUES
(1, 'Induction of new Interns', 'Tee Components has officially launched the induction process for our latest cohort of interns, welcoming new talent to the team and introducing them to our company culture, operations, and key department leads.', 'We are excited to welcome our new cohort of interns as they officially begin their journey with Tee Components Today marked the start of our comprehensive induction process, designed to help our new team members seamlessly transition into their roles. Throughout the session, the interns were introduced to our company values, core operational workflows, safety standards, and team structures. They also had the opportunity to meet department leaders and mentors who will guide them during their internship. At Tee Components, we are committed to fostering fresh talent and providing meaningful hands-on experience. We look forward to seeing the innovation, energy, and value our new interns will bring to our ongoing projects. Please join us in giving them a warm welcome!', '/uploads/cbc711dd9fe6321e804dd522bae748577daf00f5.jpg', '2026-09-23 16:22:00', 1, '2026-09-23 14:22:32', '2026-09-23 14:22:32');

-- --------------------------------------------------------

--
-- Table structure for table `products`
--

CREATE TABLE `products` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(180) NOT NULL,
  `description` text NOT NULL,
  `specifications` text NOT NULL,
  `image_url` varchar(500) NOT NULL DEFAULT '',
  `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `is_published` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `products`
--

INSERT INTO `products` (`id`, `title`, `description`, `specifications`, `image_url`, `sort_order`, `is_published`, `created_at`, `updated_at`) VALUES
(1, 'Laptops', 'High-performance laptops from trusted brands for personal, professional and educational use.', 'Brands: Dell, HP, Lenovo|Features: Intel/AMD processors, SSD storage, long battery life', '/uploads/laptop.jpg', 1, 1, '2026-09-04 10:57:08', '2026-09-08 09:26:51'),
(2, 'Printers', 'Efficient office and home printers, including inkjet, laser and multifunctional models.', 'Brands: Canon, Epson, HP|Features: Print, scan, copy, wireless connectivity', '/uploads/hpprinter2.jpg', 2, 1, '2026-09-04 10:57:08', '2026-09-08 09:26:51'),
(3, 'POS Machines', 'Modern point-of-sale machines designed to streamline transactions in retail and hospitality.', 'Brands: Clover, Square, Verifone|Features: Touchscreen, receipt printing, barcode scanning', '/uploads/pos-machine.jpg', 3, 1, '2026-09-04 10:57:08', '2026-09-08 09:26:51'),
(4, 'Networking Devices', 'Reliable routers, switches and access points that improve connectivity across your organisation.', 'Brands: TP-Link, Cisco, Netgear|Features: High-speed connectivity, dual-band support', '/uploads/switches.jpg', 4, 1, '2026-09-04 10:57:08', '2026-09-08 09:26:51'),
(5, 'Laptop Accessories', 'Batteries, keyboards, chargers, bags, docking stations and other accessories.', 'Items: Batteries, bags, docking stations, motherboards', '/uploads/laptopaccessories.jpg', 5, 1, '2026-09-04 10:57:08', '2026-09-08 09:26:51'),
(6, 'Projectors', 'High-resolution projectors for presentations, training and events.', 'Brands: Epson, BenQ, Sony', '/uploads/projector.jpg', 6, 1, '2026-09-04 10:57:08', '2026-09-08 09:26:51'),
(7, 'Money Counting Machines', 'Accurate and efficient money counting machines for organisations handling large cash volumes.', 'Features: UV/MG detection, high speed, portable models|Applications: Retail, banking, hospitality', '/uploads/countingmachine1.jpg', 7, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(8, 'Solid State Hard Drives', 'High-performance SSDs for fast data access and dependable storage.', 'Brands: Samsung, Kingston, Crucial|Capacities: 256GB, 512GB, 1TB, 2TB', '/uploads/ssd.jpg', 8, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(9, 'Olivetti Printers', 'Efficient printing solutions designed for office and business environments.', 'Features: High-speed printing, duplex, wireless', '/uploads/olivetic.jpg', 9, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(10, 'Epson Printers', 'Professional printers that deliver vivid colour and sharp text.', 'Features: EcoTank, multifunction printing', '/uploads/epison2.jpg', 10, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(11, 'HP Printers', 'Reliable printing solutions for home and enterprise use.', 'Models: DeskJet, LaserJet, OfficeJet', '/uploads/hpprinter2.jpg', 11, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(12, 'Mouse', 'Ergonomic and responsive mice for daily productivity and specialist work.', 'Brands: Logitech, HP, Microsoft', '/uploads/mouse.jpg', 12, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(13, 'Fuser Units', 'Durable replacement fuser units for printer maintenance.', 'Brands: Canon, HP, Ricoh', '/uploads/fuserunits.jpg', 13, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(14, 'Network Switches', 'High-speed switches for seamless organisational connectivity.', 'Brands: Cisco, TP-Link, D-Link', '/uploads/switches.jpg', 14, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(15, 'iPads', 'Versatile Apple iPads for work, learning and entertainment.', 'Models: iPad Air, iPad Pro, iPad Mini', '/uploads/ipad.jpg', 15, 1, '2026-09-08 09:00:44', '2026-09-08 09:26:51'),
(16, 'All-in-One ThinkPad Computers & Laptops', 'Integrated, space-saving systems for professional workspaces.', 'Features: Touchscreen, powerful performance', '/uploads/all-in-ones.jpg', 16, 1, '2026-09-08 09:00:44', '2026-09-08 09:40:56'),
(17, 'Microsoft/Beats Headphones', 'Premium headphones for clear, immersive audio.', 'Features: Noise cancellation, Bluetooth', '/uploads/earphones.jpg', 17, 1, '2026-09-08 09:00:44', '2026-09-08 09:40:56'),
(18, 'BlackArmor NAS 400 Series', 'Network-attached storage for secure data management.', 'Capacity: 4TB, 8TB, 12TB|Features: RAID, remote access', '/uploads/seagatenetworkdevice.jpg', 18, 1, '2026-09-08 09:00:44', '2026-09-08 09:40:56'),
(19, 'Cheque Scanners', 'High-accuracy cheque scanners for financial institutions and businesses.', 'Brands: Canon, Epson, Panini|Features: High-speed scanning, MICR reading, compact design', '/uploads/cheque-scanners.jpg', 19, 1, '2026-09-08 09:00:44', '2026-09-08 09:40:56'),
(20, 'TPG Receipt Printing Printers', 'Compact and reliable receipt printers for retail and hospitality.', 'Brands: TPG|Features: High-speed thermal printing, easy paper loading', '/uploads/tpg-printers.jpg', 20, 1, '2026-09-08 09:00:44', '2026-09-08 09:40:56'),
(21, 'Mobile phones', 'High-performance smartphones offering crisp displays, fast processors, and reliable battery life for daily communication, business productivity, and mobile entertainment.', 'High-Resolution Display | Fast Octa-Core Processor | High-Capacity Battery | Multi-Lens Camera System | Dual SIM & 4G/5G Connectivity', '/uploads/5f7c9ace519554c1c92a032e31a58b2206645139.jpg', 21, 1, '2026-09-25 07:52:21', '2026-09-25 07:52:21');

-- --------------------------------------------------------

--
-- Table structure for table `services`
--

CREATE TABLE `services` (
  `id` int(10) UNSIGNED NOT NULL,
  `title` varchar(150) NOT NULL,
  `summary` text NOT NULL,
  `details` text NOT NULL,
  `benefits` text NOT NULL,
  `service_includes` text NOT NULL,
  `image_url` varchar(500) NOT NULL DEFAULT '',
  `slug` varchar(170) NOT NULL,
  `icon` varchar(50) NOT NULL DEFAULT 'Settings',
  `sort_order` int(10) UNSIGNED NOT NULL DEFAULT 0,
  `is_published` tinyint(1) NOT NULL DEFAULT 1,
  `created_at` timestamp NOT NULL DEFAULT current_timestamp(),
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `services`
--

INSERT INTO `services` (`id`, `title`, `summary`, `details`, `benefits`, `service_includes`, `image_url`, `slug`, `icon`, `sort_order`, `is_published`, `created_at`, `updated_at`) VALUES
(1, 'Preventive Maintenance', 'Proactively inspecting and servicing ICT equipment to optimise performance and reduce downtime.', 'Tee Components provides professional maintenance for ICT equipment, from routine inspections and diagnostics to repairs and replacement of faulty components. Our service helps businesses minimise downtime, improve productivity and extend the life of their technology investments.', 'Proactive maintenance plans|On-site and remote support|Genuine replacement parts|Fast response times', 'Hardware diagnostics and repairs|Printer maintenance and troubleshooting|Network equipment upkeep|Laptop and desktop repairs|Preventive maintenance schedules', '', 'preventive-maintenance', 'Wrench', 1, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(2, 'Networking Solutions', 'Designing, installing and maintaining LAN and WAN systems for seamless connectivity.', 'We design, install and maintain dependable network infrastructure that keeps people, systems and locations connected. Our networking solutions are planned around your organisationâ€™s performance, coverage, security and future growth requirements.', 'Reliable LAN and WAN connectivity|Scalable network design|Professional installation|Ongoing support and optimisation', 'Network assessment and design|LAN and WAN installation|Wi-Fi deployment|Routers, switches and access points|Network maintenance and troubleshooting', '', 'networking-solutions', 'Network', 2, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(3, 'IT Equipment Supply', 'Providing high-quality ICT equipment including printers, servers, POS machines and spare parts.', 'We supply high-quality ICT equipment tailored to your organisationâ€™s needs. From printers and laptops to POS machines, servers and spare parts, our team helps you choose dependable technology that supports daily operations and future growth.', 'Wide range of ICT equipment|Trusted global brands|Competitive pricing|After-sales support and warranties', 'Printers and printer parts|Laptops and accessories|POS machines|Servers and networking equipment|Surveillance systems', '', 'it-equipment-supply', 'MonitorCog', 3, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(4, 'Video Surveillance Systems', 'Enhancing security with IP and analog camera installations for businesses and homes.', 'Protect your premises with video surveillance designed around your environment. We install practical IP and analog camera solutions that improve visibility, deterrence and incident response for businesses and homes.', 'Improved site visibility|Solutions for businesses and homes|Professional installation|Ongoing technical support', 'Site assessment|IP and analog camera installation|Recording and monitoring configuration|Remote viewing setup|Maintenance and support', '', 'video-surveillance-systems', 'Cctv', 4, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(5, 'Access Control Systems', 'Secure and manage facility access with advanced authentication systems.', 'Tee Components provides reliable and customisable access control systems that help safeguard your premises and ensure only authorised people can enter. We tailor solutions for organisations of all sizes.', 'Biometric, RFID and keypad options|Customisable configurations|Integration with existing systems|Enhanced monitoring and control', 'Biometric access systems|Card-based RFID solutions|Keypad and PIN access|Video surveillance integration|Maintenance and technical support', '', 'access-control-systems', 'ScanFace', 5, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(6, 'Time & Attendance Systems', 'Streamlining payroll processes with integrated employee attendance tracking solutions.', 'Our time and attendance systems simplify employee tracking and payroll processes. From biometric devices to cloud-based tracking, we help organisations improve accuracy, reduce errors and gain useful workforce insights.', 'Biometric and card-based systems|Cloud access for remote visibility|Payroll integration|Real-time tracking and reporting', 'Biometric attendance systems|Cloud-based attendance solutions|HR and payroll integration|Custom reporting and analytics|On-site setup and support', '', 'time-attendance-systems', 'Clock3', 6, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(7, 'Database Design & Management', 'Providing robust database solutions to streamline operations and improve data accessibility.', 'We create reliable database solutions that organise critical information, improve access to data and support smoother day-to-day operations. Each solution is designed around your organisationâ€™s workflows and reporting needs.', 'Better data accessibility|Structured business information|Tailored to operations|Support for reporting and growth', 'Database requirements assessment|Database design and implementation|Data organisation|Reporting support|Maintenance and optimisation', '', 'database-design-management', 'Database', 7, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(8, 'Video Conferencing Systems', 'Setting up advanced video conferencing solutions for seamless remote communication.', 'Enable clear, dependable remote communication with video conferencing systems designed for meeting rooms, teams and organisations. We help select, install and configure the right solution for your environment.', 'Clearer remote collaboration|Solutions for meeting spaces|Professional setup|Ongoing technical support', 'Solution assessment|Equipment supply|Meeting room installation|Configuration and user setup|Technical support', '', 'video-conferencing-systems', 'Video', 8, 1, '2026-09-04 10:57:08', '2026-09-04 10:57:08'),
(9, 'Web development', 'Custom web design and development solutions tailored to create responsive, fast, and secure websites for your business.', 'We design, build, and maintain modern, high-performing websites and web applications tailored to your business goals. From engaging corporate websites to scalable web platforms, our solutions ensure optimal performance, seamless user experience, and strong search engine visibility across all desktop and mobile devices.', 'Enhanced online visibility and brand credibility | Mobile-first and fully responsive design across all devices | Fast loading speeds optimized for performance and SEO | Scalable architecture to support business growth | Robust web security and data protection', 'Custom UI/UX web design | Front-end and back-end development | Content Management System (CMS) integration | SEO optimization & basic web analytics setup | Cross-browser compatibility testing | Post-launch support and maintenance', '/uploads/27a6edf74e3ad96f5fef6d41854fc3c3fe8dcd71.jpg', 'web-development', 'website', 9, 1, '2026-09-25 07:44:18', '2026-09-25 07:44:18');

-- --------------------------------------------------------

--
-- Table structure for table `site_content`
--

CREATE TABLE `site_content` (
  `content_key` varchar(100) NOT NULL,
  `content_value` text NOT NULL,
  `updated_at` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Dumping data for table `site_content`
--

INSERT INTO `site_content` (`content_key`, `content_value`, `updated_at`) VALUES
('about_image_id', '3', '2026-09-23 12:23:01'),
('address', 'Kidney Crescent Road, Blantyre & Lilongwe, Behind Game complex', '2026-09-25 08:25:41'),
('business_hours', 'Monday â€“ Friday | 8:00 AM â€“ 5:00 PM', '2026-09-01 09:10:31'),
('contact_email', 'teecomp@globemw.net', '2026-09-01 09:10:31'),
('hero_description', 'From the right equipment to reliable infrastructure and ongoing support, we help organisations work securely, efficiently and without interruption.', '2026-09-01 09:10:31'),
('hero_eyebrow', 'ICT solutions Â· Malawi', '2026-09-01 09:10:31'),
('hero_image_id', '5', '2026-09-08 07:54:39'),
('hero_title_accent', 'your business moving.', '2026-09-01 09:10:31'),
('hero_title_main', 'Technology that keeps', '2026-09-01 09:10:31'),
('logo_image_id', '1', '2026-09-23 08:36:46'),
('primary_phone', '+265 884 534 425', '2026-09-01 09:10:31'),
('process_image_id', '2', '2026-09-23 12:23:54'),
('secondary_phone', '+265 999 933 197', '2026-09-01 09:10:31'),
('team_image_id', '6', '2026-09-08 07:54:39');

--
-- Indexes for dumped tables
--

--
-- Indexes for table `admin_invites`
--
ALTER TABLE `admin_invites`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `fk_admin_invites_user` (`user_id`);

--
-- Indexes for table `admin_password_resets`
--
ALTER TABLE `admin_password_resets`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `token_hash` (`token_hash`),
  ADD KEY `fk_admin_password_resets_user` (`user_id`);

--
-- Indexes for table `admin_users`
--
ALTER TABLE `admin_users`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `email` (`email`);

--
-- Indexes for table `media_items`
--
ALTER TABLE `media_items`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `stored_name` (`stored_name`);

--
-- Indexes for table `news_posts`
--
ALTER TABLE `news_posts`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `products`
--
ALTER TABLE `products`
  ADD PRIMARY KEY (`id`);

--
-- Indexes for table `services`
--
ALTER TABLE `services`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `slug` (`slug`);

--
-- Indexes for table `site_content`
--
ALTER TABLE `site_content`
  ADD PRIMARY KEY (`content_key`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `admin_invites`
--
ALTER TABLE `admin_invites`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=16;

--
-- AUTO_INCREMENT for table `admin_password_resets`
--
ALTER TABLE `admin_password_resets`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT for table `admin_users`
--
ALTER TABLE `admin_users`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=17;

--
-- AUTO_INCREMENT for table `media_items`
--
ALTER TABLE `media_items`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=12;

--
-- AUTO_INCREMENT for table `news_posts`
--
ALTER TABLE `news_posts`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT for table `products`
--
ALTER TABLE `products`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=22;

--
-- AUTO_INCREMENT for table `services`
--
ALTER TABLE `services`
  MODIFY `id` int(10) UNSIGNED NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `admin_invites`
--
ALTER TABLE `admin_invites`
  ADD CONSTRAINT `fk_admin_invites_user` FOREIGN KEY (`user_id`) REFERENCES `admin_users` (`id`) ON DELETE CASCADE;

--
-- Constraints for table `admin_password_resets`
--
ALTER TABLE `admin_password_resets`
  ADD CONSTRAINT `fk_admin_password_resets_user` FOREIGN KEY (`user_id`) REFERENCES `admin_users` (`id`) ON DELETE CASCADE;
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;

