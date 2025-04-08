#!/bin/bash

# Vérification des variables d'environnement
if [ -z "$SQL_DATABASE" ] || [ -z "$SQL_USER" ] || [ -z "$SQL_PASSWORD" ] || [ -z "$SQL_ROOT_PASSWORD" ]; then
    echo "Erreur: Variables d'environnement manquantes."
    echo "Assurez-vous que SQL_DATABASE, SQL_USER, SQL_PASSWORD et SQL_ROOT_PASSWORD sont définies."
    exit 1
fi

# Démarrage du service MySQL
service mysql start

# Attente que le service soit complètement démarré
sleep 5

# Création de la base de données
mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

# Création de l'utilisateur
mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';"

# Attribution des privilèges
mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

# Modification du mot de passe root
mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

# Rafraîchissement des privilèges
mysql -e "FLUSH PRIVILEGES;"

# Arrêt de MySQL
mysqladmin -u root -p$SQL_ROOT_PASSWORD shutdown

# Redémarrage en mode sécurisé
exec mysqld_safe
