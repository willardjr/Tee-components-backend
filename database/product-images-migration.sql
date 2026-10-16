-- Product photography supplied for the Tee Components catalogue.
-- Safe to run more than once: it only updates the listed product titles.
UPDATE products
SET image_url = CASE title
  WHEN 'Laptops' THEN '/uploads/laptop.jpg'
  WHEN 'Printers' THEN '/uploads/hpprinter2.jpg'
  WHEN 'POS Machines' THEN '/uploads/pos-machine.jpg'
  WHEN 'Money Counting Machines' THEN '/uploads/countingmachine1.jpg'
  WHEN 'Networking Devices' THEN '/uploads/switches.jpg'
  WHEN 'Solid State Hard Drives' THEN '/uploads/ssd.jpg'
  WHEN 'Olivetti Printers' THEN '/uploads/olivetic.jpg'
  WHEN 'Epson Printers' THEN '/uploads/epison2.jpg'
  WHEN 'HP Printers' THEN '/uploads/hpprinter2.jpg'
  WHEN 'Laptop Accessories' THEN '/uploads/laptopaccessories.jpg'
  WHEN 'Mouse' THEN '/uploads/mouse.jpg'
  WHEN 'Projectors' THEN '/uploads/projector.jpg'
  WHEN 'Fuser Units' THEN '/uploads/fuserunits.jpg'
  WHEN 'Network Switches' THEN '/uploads/switches.jpg'
  WHEN 'iPads' THEN '/uploads/ipad.jpg'
  WHEN 'All-in-One ThinkPad Computers & Laptops' THEN '/uploads/all-in-ones.jpg'
  WHEN 'Microsoft/Beats Headphones' THEN '/uploads/earphones.jpg'
  WHEN 'BlackArmor NAS 400 Series' THEN '/uploads/seagatenetworkdevice.jpg'
  WHEN 'Cheque Scanners' THEN '/uploads/cheque-scanners.jpg'
  WHEN 'TPG Receipt Printing Printers' THEN '/uploads/tpg-printers.jpg'
  ELSE image_url
END
WHERE title IN (
  'Laptops', 'Printers', 'POS Machines', 'Money Counting Machines',
  'Networking Devices', 'Solid State Hard Drives', 'Olivetti Printers',
  'Epson Printers', 'HP Printers', 'Laptop Accessories', 'Mouse',
  'Projectors', 'Fuser Units', 'Network Switches', 'iPads',
  'All-in-One ThinkPad Computers & Laptops', 'Microsoft/Beats Headphones',
  'BlackArmor NAS 400 Series', 'Cheque Scanners', 'TPG Receipt Printing Printers'
);
