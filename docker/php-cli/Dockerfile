ARG USER=www-data
ARG NODE_VERSION=22.12.0
ARG PHP_VERSION=8.3.9-cli
ARG COMPOSER_VERSION=2.2.24

FROM php:${PHP_VERSION}-alpine AS php

FROM composer:${COMPOSER_VERSION} AS composer

FROM php AS base

WORKDIR /app

COPY --from=composer /usr/bin/composer /usr/bin/composer

RUN apk add --no-cache --update bash supervisor && \
    curl -sSLf -o /usr/local/bin/wait-for-it.sh \
      https://raw.githubusercontent.com/vishnubob/wait-for-it/refs/heads/master/wait-for-it.sh && \
    curl -sSLf -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions /usr/local/bin/wait-for-it.sh && \
    install-php-extensions apcu amqp pdo_mysql opcache

COPY supervisord.conf /etc/supervisor/supervisord.conf

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisor/supervisord.conf"]

# Build Dev Image
FROM base AS dev

RUN install-php-extensions pcov xdebug

# Build Prod Image
FROM base AS prod

WORKDIR /app

USER $USER

COPY --chown=$USER:$USER . .

RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

RUN composer install --no-dev --no-scripts