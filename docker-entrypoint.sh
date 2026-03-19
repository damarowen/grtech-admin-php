#!/bin/bash
set -e

# 1. Pastikan folder storage ada
mkdir -p /var/www/html/storage/app/public/logos
mkdir -p /var/www/html/storage/framework/{sessions,views,cache}

# 2. Cek apakah ini instalasi pertama kali (database belum ada)
if [ ! -f /var/www/html/storage/app/database.sqlite ]; then
    echo "Peringatan: Database tidak ditemukan. Membuat database baru..."
    touch /var/www/html/storage/app/database.sqlite
    
    # Beri izin akses ke file database baru
    chown www-data:www-data /var/www/html/storage/app/database.sqlite
    chmod 664 /var/www/html/storage/app/database.sqlite

    # Jalankan migrasi DAN seeding pertama kali
    echo "Menjalankan migrasi dan seeding awal..."
    php artisan migrate --force --seed
else
    echo "Database ditemukan. Menjalankan migrasi tambahan jika ada..."
    # Jalankan migrasi biasa (tanpa seed agar tidak duplikat)
    php artisan migrate --force
fi

# 3. Atur permission folder storage & bootstrap cache agar tidak error 500
echo "Mengoptimalkan permission..."
chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache
chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache

# 4. Jalankan perintah utama
exec "$@"