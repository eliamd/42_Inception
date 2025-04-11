#!/bin/bash

# Fonction pour les messages de log
log() {
    echo "[MariaDB-Init] $1"
}

log "Démarrage du script d'initialisation de MariaDB"
log "Paramètres: DATABASE=${SQL_DATABASE}, USER=${SQL_USER}"

# Vérification des variables d'environnement
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ] || [ -z "$SQL_ROOT_PASSWORD" ]; then
    log "ERREUR: Variables d'environnement manquantes"
    log "Veuillez définir SQL_DATABASE, SQL_USER, SQL_PASSWORD et SQL_ROOT_PASSWORD"
    exit 1
fi

# Création du répertoire pour les logs
mkdir -p /var/log/mysql
chown -R mysql:mysql /var/log/mysql

# Fonction pour vérifier et créer la base de données
create_db_and_user() {
    log "Création/vérification de la base de données et des utilisateurs"

    mysql -u root -p"${SQL_ROOT_PASSWORD}" <<EOF
-- Créer la base de données et l'utilisateur WordPress
CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;
CREATE USER IF NOT EXISTS '${SQL_USER}'@'%' IDENTIFIED BY '${SQL_PASSWORD}';
GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO '${SQL_USER}'@'%';
FLUSH PRIVILEGES;
EOF

    if [ $? -eq 0 ]; then
        log "Configuration de la base de données réussie"
        # Vérifier que la base de données a bien été créée
        if mysql -u root -p"${SQL_ROOT_PASSWORD}" -e "SHOW DATABASES LIKE '${SQL_DATABASE}';" | grep -q "${SQL_DATABASE}"; then
            log "Base de données '${SQL_DATABASE}' vérifiée et présente"
        else
            log "ERREUR: La base de données '${SQL_DATABASE}' n'a pas été créée correctement"
            return 1
        fi
    else
        log "ERREUR: Échec de la configuration de la base de données"
        return 1
    fi

    return 0
}

# Initialisation du système de fichiers
if [ ! -d "/var/lib/mysql/mysql" ]; then
    log "Première initialisation de MariaDB"

    # Initialiser la base de données
    log "Initialisation de la base de données MariaDB"
    mysql_install_db --user=mysql --datadir=/var/lib/mysql

    # Démarrer MariaDB temporairement
    log "Démarrage temporaire de MariaDB"
    /usr/bin/mysqld_safe --skip-networking &

    # Attendre que MariaDB démarre
    log "Attente du démarrage de MariaDB..."
    for i in {1..30}; do
        if mysqladmin ping &>/dev/null; then
            break
        fi
        log "Attente... ($i/30)"
        sleep 1
    done

    # Vérifier si MariaDB a démarré
    if ! mysqladmin ping &>/dev/null; then
        log "ERREUR: MariaDB n'a pas démarré correctement"
        exit 1
    fi

    # Configuration de MariaDB avec mysql_secure_installation
    mysql -u root <<EOF
-- Sécuriser MariaDB
ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';
DELETE FROM mysql.user WHERE User='';
DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');
DROP DATABASE IF EXISTS test;
DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
FLUSH PRIVILEGES;
EOF

    # Création de la base de données et des utilisateurs
    create_db_and_user

    # Arrêter MariaDB temporaire
    log "Arrêt du service temporaire MariaDB"
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown

    # Attendre l'arrêt complet
    sleep 3

    log "Initialisation complète"
else
    log "Instance MariaDB existante détectée"

    # Démarrer MariaDB temporairement pour vérifier/créer la base de données
    log "Démarrage temporaire de MariaDB pour vérification"
    /usr/bin/mysqld_safe --skip-networking &

    # Attendre que MariaDB démarre
    log "Attente du démarrage de MariaDB..."
    for i in {1..30}; do
        if mysqladmin ping &>/dev/null; then
            break
        fi
        log "Attente... ($i/30)"
        sleep 1
    done

    # Vérifier/créer la base de données
    create_db_and_user

    # Arrêter MariaDB temporaire
    log "Arrêt du service temporaire MariaDB"
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown

    # Attendre l'arrêt complet
    sleep 3
fi

# Configuration des permissions
log "Configuration des permissions"
chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
chmod 777 /var/run/mysqld

# Lancer MariaDB avec toutes les options
log "Démarrage de MariaDB..."
exec mysqld_safe --user=mysql
