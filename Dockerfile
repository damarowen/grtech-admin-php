# syntax=docker/dockerfile:1
FROM php:8.4-apache

# 1. Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    git curl zip unzip libpng-dev libonig-dev libxml2-dev libzip-dev libsqlite3-dev \
    && docker-php-ext-install pdo_mysql pdo_sqlite mbstring zip exif pcntl opcache \
    && apt-get clean && rm -rf /var/lib/apt/lists/*

# 2. Install Node.js 20
RUN curl -fsSL https://deb.nodesource.com/setup_20.x | bash - \
    && apt-get install -y nodejs && apt-get clean && rm -rf /var/lib/apt/lists/*

# 3. Install Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

WORKDIR /var/www/html

# 4. Copy Source Code
COPY . .

# 5. Install Dependencies (PHP & JS)
RUN composer install --no-dev --prefer-dist --no-interaction --optimize-autoloader
RUN npm install && npm run build && rm -rf node_modules

# 6. Configure Apache
ENV APACHE_DOCUMENT_ROOT=/var/www/html/public
RUN sed -ri -e 's!/var/www/html!/var/www/html/public!g' /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf \
    && a2enmod rewrite

# 7. SETUP DATABASE & PERMISSIONS (SOLUSI ERROR READONLY)
RUN cp .env.example .env \
    && php artisan key:generate \
    && touch database/database.sqlite \
    && php artisan storage:link \
    # Memberikan hak akses penuh ke user www-data untuk folder storage, cache, dan DATABASE
    && chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database \
    && chmod -R 775 /var/www/html/storage /var/www/html/bootstrap/cache /var/www/html/database

EXPOSE 80
CMD ["apache2-foreground"]