-- Run this once if the services table already exists from an earlier version.
ALTER TABLE services
  ADD COLUMN details TEXT NOT NULL AFTER summary,
  ADD COLUMN benefits TEXT NOT NULL AFTER details,
  ADD COLUMN service_includes TEXT NOT NULL AFTER benefits;

-- Then re-run database/schema.sql to populate the service detail content.
