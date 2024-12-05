#!/usr/bin/env sh
set -eux pipefail

composer install --optimize-autoloader

wait-for-it.sh --strict --timeout=10 mysql:3306 -- echo "MySQL started and loaded successfully"
php bin/console doctrine:migrations:migrate --no-interaction --allow-no-migration

wait-for-it.sh --strict --timeout=10 rabbitmq:5672 -- echo "Rabbitmq started and loaded successfully"
php bin/console messenger:setup-transports --no-interaction

exec php-fpm -R