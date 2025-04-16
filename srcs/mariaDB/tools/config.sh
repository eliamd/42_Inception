#!/bin/bash

log() {
    echo "[MariaDB-Init] $1"
}

log "Démarrage du script d'initialisation de MariaDB"
log "Paramètres: DATABASE=${SQL_DATABASE}, USER=${SQL_USER}"

if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ] || [ -z "$SQL_ROOT_PASSWORD" ]; then
    log "ERREUR: Variables d'environnement manquantes"
    exit 1
fi

mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

create_db_and_user() {
    log "Configuration de la base de données et des utilisateurs"

    mysql -u root -p"${SQL_ROOT_PASSWORD}" <<EOF
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    if mysql -u root -p"${SQL_ROOT_PASSWORD}" -e "SHOW DATABASES LIKE '${SQL_DATABASE}';" | grep -q "${SQL_DATABASE}"; then
        log "Base de données '${SQL_DATABASE}' configurée avec succès"
        return 0
    else
        log "ERREUR: Échec de configuration de la base de données"
        return 1
    fi
}

secure_mysql() {
    log "Sécurisation de l'installation MariaDB"

    # Script de sécurisation plus stricte
    mysql -u root <<EOF
-- Définir le mot de passe root
UPDATE mysql.user SET Password=PASSWORD('${SQL_ROOT_PASSWORD}') WHERE User='root';
-- S'assurer que le plugin d'authentification utilise le mot de passe
UPDATE mysql.user SET plugin='' WHERE User='root';
-- Supprimer les utilisateurs anonymes
DELETE FROM mysql.user WHERE User='';
-- Ne permettre la connexion de root que depuis localhost
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
-- Supprimer la base de test
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
-- Révoquer tous les privilèges globaux sur les utilisateurs non-root
UPDATE mysql.user SET Grant_priv='N' WHERE User<>'root';
-- Supprimer les utilisateurs avec un mot de passe vide
DELETE FROM mysql.user WHERE Password='';
-- Recharger les privilèges pour appliquer les changements
FLUSH PRIVILEGES;
EOF

    # Vérifier que la sécurisation a fonctionné
    if ! mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" status &>/dev/null; then
        log "ERREUR: La sécurisation de MariaDB a échoué"
        exit 1
    else
        log "MariaDB sécurisé avec succès"
    fi
}

# Initialisation du système de fichiers
if [ ! -d "/var/lib/mysql/mysql" ]; then
    log "Première initialisation de MariaDB"

    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    log "Démarrage temporaire de MariaDB"
    /usr/bin/mysqld_safe --skip-networking &

    log "Attente du démarrage de MariaDB..."
    for i in {1..30}; do
        if mysqladmin ping &>/dev/null; then
            break
        fi
        log "Attente... ($i/30)"
        sleep 1
    done

    if ! mysqladmin ping &>/dev/null; then
        log "ERREUR: MariaDB n'a pas démarré correctement"
        exit 1
    fi

    # Sécuriser l'installation
    secure_mysql

    # Créer la base de données et l'utilisateur
    create_db_and_user

    log "Arrêt du service temporaire MariaDB"
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown

    sleep 3

    log "Initialisation complète"
else
    log "Instance MariaDB existante détectée"

    log "Démarrage temporaire de MariaDB pour vérification"
    /usr/bin/mysqld_safe --skip-networking &

    log "Attente du démarrage de MariaDB..."
    for i in {1..30}; do
        if mysqladmin ping &>/dev/null; then
            break
        fi
        log "Attente... ($i/30)"
        sleep 1
    done

    # Sécuriser l'installation existante
    secure_mysql

    # Vérifier/créer la base et l'utilisateur
    create_db_and_user

    log "Arrêt du service temporaire MariaDB"
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown

    sleep 3
fi

log "Configuration des permissions"
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chmod 777 /var/run/mysqld

log "Démarrage de MariaDB..."
exec mysqld_safe --user=mysql
