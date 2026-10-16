# Tee Components API and admin

This repository is the PHP backend for the Tee Components website. It contains the API, admin dashboard, database schema and migrations, and the initial website media.

## Deploy to Render

Create a Render Web Service from this repository. Render will use the included Dockerfile. Create a MySQL database with a provider reachable from Render, then set the connection details in the service environment: `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, and `DB_PASSWORD`. Create the database (named `tee_components` unless you set a different `DB_NAME`) and import `database/tee_components.sql` into it. This is the content and schema snapshot from the local database. For safety, the dump omits administrator accounts and password reset records. Set `ADMIN_NAME`, `ADMIN_EMAIL`, and a strong `ADMIN_PASSWORD` before creating the first administrator with `php scripts/create-admin.php` from the Render shell.

Set `APP_URL` to the public Render service URL. Configure `TURNSTILE_SECRET_KEY`, `RESEND_API_KEY`, `RESEND_FROM_EMAIL`, `ENQUIRY_RECIPIENT`, and `MAIL_FROM` as needed. Keep credentials in Render's environment settings; never commit `.env`.

The Render container filesystem is temporary. Admin uploaded media will not persist across deploys unless you add persistent storage or switch uploads to object storage. The initial media in `uploads/` is versioned in this repository.

## Local setup

Copy `.env.example` to `.env`, configure MySQL and mail settings, import `database/schema.sql`, then run the app with PHP's local server:

```sh
php -S localhost:8000 router.php
```

The React frontend lives in its own repository. Configure its `vercel.json` rewrite target to this Render service URL.
