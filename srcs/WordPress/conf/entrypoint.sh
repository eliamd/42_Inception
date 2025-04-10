#!/bin/bash

# Lancement de PHP-FPM en arrière-plan
/usr/sbin/php-fpm7.3 --nodaemonize &

# Exécution du script de configuration WordPress
/usr/local/bin/auto_config.sh

# Maintenir le container actif
wait
