#!/bin/bash
set -e

# 1. Pastikan folder storage/app benar-benar ada (antisipasi volume kosong)
mkdir -p /var/www/html/storage/app

# 2. PERMANEN CHOWN: Jalankan setiap kali container start
# Ini akan memastikan user www-data punya hak akses penuh
echo "Mengatur hak akses folder storage secara permanen..."
chown -R www-data:www-data /var/www/html/storage
chmod -R 775 /var/www/html/storage

# 3. Pastikan file database ada
if [ ! -f /var/www/html/storage/app/database.sqlite ]; then
    touch /var/www/html/storage/app/database.sqlite
    chown www-data:www-data /var/www/html/storage/app/database.sqlite
fi

# 4. Jalankan migrasi
php artisan migrate --force

# 5. Jalankan perintah utama (Apache)
exec "$@"