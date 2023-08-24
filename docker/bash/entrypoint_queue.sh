#!/usr/bin/env bash

trap "echo 'Shutting down'; kill \$!; exit" SIGINT SIGTERM

echo "Start the queue..."
php /var/www/artisan queue:work
