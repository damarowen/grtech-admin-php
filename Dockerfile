# syntax=docker/dockerfile:1

# 1) Install PHP dependencies with Composer (no-dev)
FROM composer:2 AS vendor
WORKDIR /app
COPY composer.json composer.lock ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-progress --optimize-autoloader

# 2) Build frontend assets with Node/Vite
FROM node:20-alpine AS assets
WORKDIR /app
COPY package.json package-lock.json* ./
RUN npm install
COPY resources ./resources
COPY vite.config.js tailwind.config.js postcss.config.js ./
RUN npm run build

# 3) Runtime: PHP-FPM 8.3 (to be paired with Nginx)
FROM php:8.3-fpm-alpine AS runtime
WORKDIR /var/www/html

# Install PHP extensions required by Laravel
RUN docker-php-ext-install pdo_mysql opcache

# Copy application source
COPY . .
# Bring in vendor and built assets
COPY --from=vendor /app/vendor ./vendor
COPY --from=assets /app/public/build ./public/build

# Permissions for storage & cache
RUN chown -R www-data:www-data storage bootstrap/cache \
    && chmod -R 775 storage bootstrap/cache

# Expose PHP-FPM port
EXPOSE 9000
CMD ["php-fpm"]
