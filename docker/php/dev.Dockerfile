FROM php:8.2-fpm

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git \
    curl \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    libpq-dev \
    zip \
    unzip

# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_mysql pgsql pdo_pgsql mbstring exif pcntl bcmath gd intl \
    && pecl install apcu xdebug \
    && docker-php-ext-enable apcu opcache xdebug

# Get latest Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Disable short_open_tag
COPY ./short_open_tag.ini $PHP_INI_DIR/conf.d/

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root dev
RUN mkdir -p /home/dev/.composer && \
    chown -R dev:dev /home/dev

# Set working directory
WORKDIR /var/www

USER dev