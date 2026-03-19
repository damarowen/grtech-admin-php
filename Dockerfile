# # syntax=docker/dockerfile:1
# FROM php:8.4-apache

# # 1. Install system dependencies & PHP extensions
# RUN apt-get update && apt-get install -y \
#     git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libsqlite3-dev \
#     && docker-php-ext-install pdo_mysql pdo_sqlite mbstring zip exif pcntl opcache \
#     && apt-get clean && rm -rf /var/lib/apt/lists/*

# # 2. Install Node.js 20
# RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
#     && apt-get install -y nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*

# # 3. Install Composer
# COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# WORKDIR /var/www/html

# # 4. Copy Source Code
# COPY . .

# # 5. Install Dependencies (PHP & JS)
# RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
# RUN npm install && npm run build && rm -rf node_modules

# # 6. Configure Apache
# ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
# RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf \
#     && a2enmod rewrite

# # 7. SETUP DATABASE & PERMISSIONS (SOLUSI ERROR READONLY)
# RUN cp .env.example .env \
#     && php artisan key:generate \
#     && touch database/database.sqlite \
#     && php artisan storage:link \
#     # Memberikan hak akses penuh ke user www-data untuk folder storage, cache, dan DATABASE
#     && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database \
#     && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

# EXPOSE 80
# CMD ["apache2-foreground"]

# syntax=docker/dockerfile:1

# --- STAGE 1: Install PHP Dependencies ---
FROM composer:2 AS vendor_builder
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --no-interaction --prefer-dist --optimize-autoloader --no-scripts

# --- STAGE 2: Build Frontend Assets ---
FROM node:20-slim AS frontend_builder
WORKDIR /app
COPY package*.json ./
RUN npm install
COPY . .

COPY --from=vendor_builder /app/vendor ./vendor
# Compile Vue/Inertia assets (Vite)
RUN npm run build

# --- STAGE 3: Production Runtime ---
FROM php:8.4-apache

# 1. Install runtime dependencies
RUN apt-get update && apt-get install -y \
    libpng-dev libzip-dev libsqlite3-dev \
    && docker-php-ext-install pdo_mysql pdo_sqlite zip opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Aktifkan OpCache untuk performa PHP yang lebih kencang
RUN { \
    echo 'opcache.memory_consumption=128'; \
    echo 'opcache.interned_strings_buffer=8'; \
    echo 'opcache.max_accelerated_files=4000'; \
    echo 'opcache.revalidate_freq=2'; \
    echo 'opcache.fast_shutdown=1'; \
    echo 'opcache.enable_cli=1'; \
    } > /usr/local/etc/php/conf.d/opcache-recommended.ini

WORKDIR /var/www/html

# 3. Copy source
COPY . .

# 4. Copy hasil build dari stage sebelumnya (Hanya vendor & public/build)
COPY --from=vendor_builder /app/vendor ./vendor
COPY --from=frontend_builder /app/public/build ./public/build

# 5. Hapus folder yang tidak berguna di production
RUN rm -rf node_modules tests

# 6. Configure Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf \
    && a2enmod rewrite

# 7. Setup Laravel & Permissions
RUN cp .env.example .env \
    && rm -f bootstrap/cache/packages.php bootstrap/cache/services.php \
    && php artisan key:generate \
    && touch database/database.sqlite \
    && php artisan storage:link \
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

# Copy entrypoint script dan berikan izin eksekusi
COPY docker-entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/docker-entrypoint.sh

# Set Entrypoint
ENTRYPOINT ["docker-entrypoint.sh"]

EXPOSE 80
CMD ["apache2-foreground"]