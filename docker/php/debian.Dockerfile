FROM php:8.2-fpm

# Arguments defined in docker-compose.yml
ARG user
ARG uid

# Install main dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    ffmpeg libsm6 libxext6 \
    libicu-dev \
    libmcrypt-dev \
    zlib1g-dev \
    libxml2-dev \
    libonig-dev \
    libpq-dev \
    libcurl4-openssl-dev \
    libpng-dev \
    libjpeg62-turbo-dev \
    libwebp-dev libjpeg62-turbo-dev libpng-dev libxpm-dev \
    libfreetype6 libfreetype6-dev \
    locales \
    pkg-config \
    sqlite3 libsqlite3-dev \
    libzip-dev zip unzip\
    jpegoptim optipng pngquant gifsicle \
    git \
    curl

# Install frontend dependencies
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash - \
    && apt-get install -y nodejs \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - \
    && echo "deb https://dl.yarnpkg.com/debian/ stable main" > /etc/apt/sources.list.d/yarn.list \
    && apt-get update \
    && apt-get install -y yarn

# Install PECL and PEAR extensions
RUN pecl install \
    redis

# Enable PECL and PEAR extensions
RUN docker-php-ext-enable \
    redis

# Configure php extensions
RUN docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp

# Install php extensions
RUN docker-php-ext-install \
    gd \
    bcmath \
    calendar \
    curl \
    exif \
    iconv \
    intl \
    mbstring \
    opcache \
    pdo \
    pdo_pgsql \
    pdo_sqlite \
    pcntl \
    tokenizer \
    xml \
    zip

###########################################################################
# xDebug:
###########################################################################

ARG ENABLE_XDEBUG=false

RUN if [ ${ENABLE_XDEBUG} = true ]; then \
  # Install the xdebug extension
    pecl install xdebug; \
    docker-php-ext-enable xdebug; \
    echo "xdebug.mode=debug" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini; \
    echo "xdebug.client_host = host.docker.internal" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
;fi

# Copy php.ini configuration
COPY php.ini /usr/local/etc/php/conf.d/40-custom.ini
# Copy opcache.ini configuration
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

# Cleanup dev dependencies
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && docker-php-source delete

# Create system user to run Composer and Artisan Commands
RUN useradd -G www-data,root -u $uid -d /home/$user $user
RUN mkdir -p /home/$user/.composer && \
    chown -R $user:$user /home/$user

# Set working directory
WORKDIR /var/www

USER $user

EXPOSE 9000

# The main purpose of a CMD is to provide defaults for an executing container. These defaults can include an executable,
# or they can omit the executable, in which case you must specify an ENTRYPOINT instruction as well.
CMD php-fpm
