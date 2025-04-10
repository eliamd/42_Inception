#!/bin/bash

# Attente que MariaDB soit prêt avec un maximum de 60 tentatives
echo "Waiting for MariaDB..."
MAX_TRIES=60
count=0

# Vérification des variables d'environnement
if [ -z "$SQL_USER" ] && [ ! -z "$WORDPRESS_DB_USER" ]; then
    echo "Utilisation de WORDPRESS_DB_USER à la place de SQL_USER"
    SQL_USER=$WORDPRESS_DB_USER
    SQL_PASSWORD=$WORDPRESS_DB_PASSWORD
fi

while [ $count -lt $MAX_TRIES ]; do
    if mariadb -h mariadb -u "${SQL_USER}" -p"${SQL_PASSWORD}" -e "SELECT 1;" &>/dev/null; then
        echo "MariaDB est prêt!"
        break
    fi
    echo "Tentative $((count+1))/$MAX_TRIES - MariaDB n'est pas encore prêt..."
    sleep 2
    count=$((count+1))
done

if [ $count -eq $MAX_TRIES ]; then
    echo "Erreur: Impossible de se connecter à MariaDB après $MAX_TRIES tentatives."
    exit 1
fi

# Vérifier le répertoire d'installation de WordPress
WP_DIR="/var/www/wordpress"
if [ ! -d "$WP_DIR" ]; then
    echo "Erreur: Le répertoire WordPress n'existe pas: $WP_DIR"
    exit 1
fi

cd $WP_DIR

# Création du fichier de configuration WordPress
if [ ! -f wp-config.php ]; then
    echo "Configuring WordPress..."
    if ! wp config create \
        --dbname="${SQL_DATABASE:-$WORDPRESS_DB_NAME}" \
        --dbuser="${SQL_USER:-$WORDPRESS_DB_USER}" \
        --dbpass="${SQL_PASSWORD:-$WORDPRESS_DB_PASSWORD}" \
        --dbhost=mariadb:3306 \
        --path=$WP_DIR \
        --allow-root; then
        echo "Erreur: Impossible de créer wp-config.php"
        exit 1
    fi

    # Installation de WordPress
    echo "Installing WordPress..."
    if ! wp core install \
        --url=edetoh.42.fr \
        --title="Inception" \
        --admin_user=eliamadmin \
        --admin_password="${WORDPRESS_ADMIN_PASSWORD}" \
        --admin_email=admin@example.com \
        --allow-root; then
        echo "Erreur: Impossible d'installer WordPress"
        exit 1
    fi

    # Création d'un utilisateur supplémentaire
    echo "Creating additional user..."
    if ! wp user create "${WORDPRESS_USER}" user@example.com \
        --role=editor \
        --user_pass="${WORDPRESS_PASSWORD}" \
        --allow-root; then
        echo "Warning: Impossible de créer l'utilisateur supplémentaire"
    fi
fi

echo "WordPress setup completed!"