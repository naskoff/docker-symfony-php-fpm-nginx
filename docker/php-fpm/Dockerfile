ARG USER=www-data
ARG NODE_VERSION=22.12.0
ARG PHP_VERSION=8.3.9-fpm
ARG COMPOSER_VERSION=2.2.24

FROM php:${PHP_VERSION}-alpine AS php

FROM node:${NODE_VERSION}-alpine AS node

FROM composer:${COMPOSER_VERSION} AS composer

FROM php AS base

WORKDIR /app

COPY --from=composer /usr/bin/composer /usr/bin/composer

COPY --from=node /usr/local/bin/node /usr/local/bin/node
COPY --from=node /usr/local/include/node /usr/local/include/node
COPY --from=node /usr/local/lib/node_modules /usr/local/lib/node_modules

RUN apk add --no-cache --update bash supervisor && \
    curl -sSLf -o /usr/local/bin/wait-for-it.sh \
      https://raw.githubusercontent.com/vishnubob/wait-for-it/refs/heads/master/wait-for-it.sh && \
    curl -sSLf -o /usr/local/bin/install-php-extensions \
        https://github.com/mlocati/docker-php-extension-installer/releases/latest/download/install-php-extensions && \
    chmod +x /usr/local/bin/install-php-extensions /usr/local/bin/wait-for-it.sh && \
    install-php-extensions apcu amqp pdo_mysql opcache

USER $USER

# Build Dev Image
FROM base AS dev

ARG USER

COPY --chown=$USER:$USER --chmod=755 docker-entrypoint-php.sh /entrypoint.sh

RUN mv $PHP_INI_DIR/php.ini-development $PHP_INI_DIR/php.ini

ENTRYPOINT ["/entrypoint.sh"]

# Build Prod Image
FROM base AS prod

WORKDIR /app

USER $USER

COPY --chown=$USER:$USER . .

RUN mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini

RUN composer install --no-dev --no-scripts