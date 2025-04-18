#!/bin/bash

# Configuration puis lancement de PHP-FPM
/usr/local/bin/auto_config.sh
exec /usr/sbin/php-fpm7.4 --nodaemonize
