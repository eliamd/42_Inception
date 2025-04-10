# ───────── MariaDB ─────────

# ───────── 0 : Base image ─────────
FROM debian:buster

# ───────── 1 : Install MariaDB and other necessary packages ─────────
RUN apt update -y && \
    apt upgrade -y && \
    apt-get install -y mariadb-server mariadb-client && \
    apt install -y nano curl procps && \
    rm -rf /var/lib/apt/lists/*

# ───────── 2 : Copy configuration files ─────────
RUN mkdir -p /var/run/mysqld && \
    chown -R mysql:mysql /var/run/mysqld && \
    chmod 777 /var/run/mysqld

COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# ───────── 3 : Copy and setup initialization script ─────────
COPY tools/config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/config.sh

# ───────── 4 : Expose port ─────────
EXPOSE 3306

# ───────── 5 : Launch MariaDB with configuration script ─────────
CMD ["/usr/local/bin/config.sh"]