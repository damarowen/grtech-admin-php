# GRTech Admin

Admin app built with Laravel 13, Inertia.js (Vue 3), Tailwind CSS, Ant Design Vue, and Vite.

## Stack
- PHP 8.3, Laravel 13 (Sanctum)
- Inertia.js + Vue 3, Vite, Tailwind CSS
- Breeze (Vue) auth scaffolding
- Ziggy (named routes in JS)

## Prerequisites
- PHP 8.3+, Composer
- Node.js 18+, npm
- Database (MySQL/PostgreSQL/SQLite)

## Quick Start
```bash
# PHP deps
composer install

# Env & key
cp .env.example .env
php artisan key:generate

# DB migrate (seed optional)
php artisan migrate
# or
php artisan migrate:fresh --seed

# Public storage symlink for logos
php artisan storage:link

# JS deps & dev
npm install
npm run dev      # dev server
# or
npm run build    # production build
```

Tip: You can also run everything with the provided scripts:
```bash
composer run dev     # server + queue + logs (Pail) + Vite
composer run test    # run tests
```

## Features
- Companies CRUD with logo upload
	- Logos stored in `storage/app/public/logos` and served via `storage:link`
	- On update without a new logo, the existing logo is preserved
- Employees CRUD with company relation
- Email notification on new employee: `App\Notifications\NewEmployeeNotification`
- Auth & Roles
	- `users.role` column (default `user`)
	- `IsAdmin` middleware registered as alias `admin` in `bootstrap/app.php`

Configure mail in `.env` (use `MAIL_MAILER=log` for local).

## Frontend Notes
- Inertia forms handle file uploads.
- Company logo input is reset between modal opens to avoid stale files.

## Testing
```bash
composer test
# or
php artisan test
```

## License
MIT
