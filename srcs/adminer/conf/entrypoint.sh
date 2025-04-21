#!/bin/bash

# Vérification du chemin de PHP-FPM
if [ -f /usr/sbin/php-fpm7.4 ]; then
    PHP_FPM="/usr/sbin/php-fpm7.4"
elif [ -f /usr/sbin/php-fpm ]; then
    PHP_FPM="/usr/sbin/php-fpm"
else
    echo "Erreur: impossible de trouver l'exécutable PHP-FPM"
    exit 1
fi

echo "Démarrage de PHP-FPM..."
exec $PHP_FPM --nodaemonize