-- Run this once on an existing Tee Components database before using image uploads
-- for services or news posts. New installations already receive these columns
-- from schema.sql.
ALTER TABLE services ADD COLUMN image_url VARCHAR(500) NOT NULL DEFAULT '' AFTER service_includes;
ALTER TABLE news_posts ADD COLUMN image_url VARCHAR(500) NOT NULL DEFAULT '' AFTER content;
