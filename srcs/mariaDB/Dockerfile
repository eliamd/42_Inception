# ───────── MariaDB ─────────
FROM debian:buster

# Installation des paquets et configuration initiale
RUN apt update -y && apt upgrade -y && \
    apt-get install -y mariadb-server mariadb-client nano curl procps && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

# Copie des fichiers de configuration
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf
COPY tools/config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/config.sh

EXPOSE 3306

CMD ["/usr/local/bin/config.sh"]