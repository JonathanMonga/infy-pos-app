
FROM php:8.2-apache

# Install necessary libraries
RUN apt-get update --fix-missing && apt-get install -y \
    libonig-dev \
    libzip-dev \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libpng-dev

# Configure PHP extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg

# Install PHP extensions
RUN docker-php-ext-install gd \
        mbstring \
        zip \
        mysqli \
        pdo \
        pdo_mysql

# Copy Laravel application
COPY . /var/www/html

# Set working directory
WORKDIR /var/www/html

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Update dependencies
RUN composer update --ignore-platform-reqs

# Change ownership of our applications
RUN chown -R www-data:www-data /var/www/html

# Copy .env.example to .env
COPY .env.example .env

# Run Laravel commands
RUN php artisan key:generate --ansi  \
    && php artisan optimize:clear \
    && php artisan storage:link

# Expose port 80
EXPOSE 80

# Adjusting Apache configurations
RUN a2enmod rewrite
COPY apache-config.conf /etc/apache2/sites-available/000-default.conf
