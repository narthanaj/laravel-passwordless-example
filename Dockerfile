# Use the official PHP image as the base image
FROM php:8.0-apache

# Set the working directory in the container
WORKDIR /var/www/html

# Copy the source code into the container
COPY . .

# Install dependencies
RUN apt-get update && apt-get install -y \
    git \
    zip \
    unzip \
    libzip-dev \
    && docker-php-ext-install pdo_mysql zip

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Set up Composer environment variables
ENV COMPOSER_MEMORY_LIMIT=-1 \
    COMPOSER_ALLOW_SUPERUSER=1

# Update PHP version requirement in composer.json
RUN sed -i 's/"php": "^7.2.5"/"php": "^8.0"/' composer.json

# Install project dependencies
RUN composer install --no-interaction --no-plugins --no-scripts

# Set the correct permissions for Laravel
RUN chown -R www-data:www-data storage bootstrap/cache

# Generate application key
RUN php artisan key:generate

# Run database migrations
RUN php artisan migrate --force

# Expose port 80 for web server
EXPOSE 80

# Start Apache web server
CMD ["apache2-foreground"]
