# GRTech Admin

Admin app for managing Companies and Employees with role-based access control. Built with Laravel 13, Inertia.js (Vue 3), Tailwind CSS, Ant Design Vue, and Vite. Includes Breeze authentication (register disabled), server-side pagination, file uploads for company logos, and admin-only management.

## Project Structure
```
├─ app/
│  ├─ Http/
│  │  ├─ Controllers/
│  │  │  ├─ CompanyController.php
│  │  │  └─ EmployeeController.php
│  │  ├─ Middleware/
│  │  │  └─ IsAdmin.php
│  │  ├─ Requests/
│  │  │  ├─ StoreCompanyRequest.php
│  │  │  ├─ UpdateCompanyRequest.php
│  │  │  └─ EmployeeRequest.php
│  │  └─ Resources/
│  │     ├─ CompanyResource.php
│  │     └─ EmployeeResource.php
│  ├─ Models/
│  │  ├─ Company.php
│  │  ├─ Employee.php
│  │  └─ User.php
│  └─ Notifications/
│     └─ NewEmployeeNotification.php
├─ bootstrap/
│  └─ app.php (middleware alias 'admin')
├─ database/
│  ├─ migrations/ (companies, employees, users, jobs, etc.)
│  └─ seeders/
│     └─ DatabaseSeeder.php (admin & user accounts)
├─ resources/
│  ├─ js/
│  │  ├─ Pages/
│  │  │  ├─ Companies/Index.vue
│  │  │  └─ Employees/Index.vue
│  │  ├─ Layouts/AuthenticatedLayout.vue
│  │  └─ app.js
│  └─ css/app.css
├─ routes/
│  ├─ web.php (companies & employees protected by auth+admin)
│  └─ auth.php (register disabled)
├─ public/ (index.php, build assets, storage symlink)
├─ tests/
├─ composer.json
├─ package.json
├─ vite.config.js
└─ Dockerfile, .dockerignore
```

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
