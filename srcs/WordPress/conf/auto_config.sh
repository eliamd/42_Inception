#!/bin/bash

echo "Attente de MariaDB..."
MAX_TRIES=30
count=0

# Normalisation des variables d'environnement
[ -z "$SQL_USER" ] && [ ! -z "$WORDPRESS_DB_USER" ] && SQL_USER=$WORDPRESS_DB_USER && SQL_PASSWORD=$WORDPRESS_DB_PASSWORD

# Attente de disponibilité de MariaDB
while [ $count -lt $MAX_TRIES ] && ! mariadb -h mariadb -u "${SQL_USER}" -p"${SQL_PASSWORD}" -e "SELECT 1;" &>/dev/null; do
    echo "Tentative $((count+1))/$MAX_TRIES - Attente de MariaDB..."
    sleep 2
    count=$((count+1))
done

[ $count -eq $MAX_TRIES ] && echo "Erreur: Impossible de se connecter à MariaDB après $MAX_TRIES tentatives." && exit 1
echo "MariaDB est prêt!"

# Vérification et configuration de WordPress
WP_DIR="/var/www/wordpress"
[ ! -d "$WP_DIR" ] && echo "Erreur: Répertoire WordPress manquant: $WP_DIR" && exit 1
cd $WP_DIR

# Configuration de WordPress si nécessaire
if [ ! -f wp-config.php ]; then
    echo "Configuration de WordPress..."
    wp config create \
        --dbname="${SQL_DATABASE:-$WORDPRESS_DB_NAME}" \
        --dbuser="${SQL_USER:-$WORDPRESS_DB_USER}" \
        --dbpass="${SQL_PASSWORD:-$WORDPRESS_DB_PASSWORD}" \
        --dbhost=mariadb:3306 \
        --path=$WP_DIR \
        --allow-root || { echo "Erreur: Échec de création wp-config.php"; exit 1; }

    echo "Installation de WordPress..."
    wp core install \
        --url=edetoh.42.fr \
        --title="Inception" \
        --admin_user="${WORDPRESS_ADMIN_USER}" \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email=admin@example.com \
        --allow-root || { echo "Erreur: Échec d'installation WordPress"; exit 1; }

    echo "Création d'un utilisateur supplémentaire..."
    wp user create "${WORDPRESS_USER}" user@example.com \
        --role=editor \
        --user_pass="${WORDPRESS_PASSWORD}" \
        --allow-root || echo "Avertissement: Échec de création de l'utilisateur"
fi

echo "Configuration WordPress terminée!"