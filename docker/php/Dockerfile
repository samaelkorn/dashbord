FROM php:8.2-fpm-alpine3.16

# Install dev dependencies
RUN apk add --no-cache --virtual .build-deps \
    $PHPIZE_DEPS \
    curl-dev \
    libtool \
    libxml2-dev \
    postgresql-dev \
    sqlite-dev \

# Install production dependencies
&& apk add --no-cache \
    bash \
    shadow \
    nano \
    curl \
    gnu-libiconv \
    wget \
    freetype-dev \
    icu-dev \
    icu-libs \
    libc-dev \
    libjpeg-turbo-dev \
    libwebp-dev \
    libpng-dev \
    libzip-dev \
    make \
    oniguruma-dev \
    openssh-client \
    postgresql-libs \
    rsync \
    jpegoptim optipng pngquant gifsicle \
    zlib-dev \

# Install PECL and PEAR extensions
&& pecl install \
    redis \

# Enable PECL and PEAR extensions
&& docker-php-ext-enable \
    redis \

# Configure php extensions
&& docker-php-ext-configure gd --enable-gd --with-freetype --with-jpeg --with-webp \

# Install php extensions
&& docker-php-ext-install \
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

# Copy php.ini configuration
COPY php.ini /usr/local/etc/php/conf.d/40-custom.ini
# Copy opcache.ini configuration
COPY opcache.ini /usr/local/etc/php/conf.d/opcache.ini

# install gnu-libiconv and set LD_PRELOAD env to make iconv work fully on Alpine image.
# see https://github.com/docker-library/php/issues/240#issuecomment-763112749
ENV LD_PRELOAD /usr/lib/preloadable_libiconv.so

# Install composer
ENV COMPOSER_ALLOW_SUPERUSER="1" \
    COMPOSER_HOME="/tmp/composer"
COPY --from=composer /usr/bin/composer /usr/bin/composer

# Cleanup dev dependencies
RUN apk del -f .build-deps && rm -rf /var/cache/apk/* && docker-php-source delete && rm -rf /tmp/pear

RUN usermod -u 1000 www-data && groupmod -g 1000 www-data

WORKDIR /var/www

USER 1000:1000

EXPOSE 9000

# The main purpose of a CMD is to provide defaults for an executing container. These defaults can include an executable,
# or they can omit the executable, in which case you must specify an ENTRYPOINT instruction as well.
CMD php-fpm
