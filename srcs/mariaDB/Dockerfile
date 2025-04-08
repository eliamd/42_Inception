# ───────── MariaDB ─────────

# ───────── 0 : Base image ─────────
FROM debian:buster

# ───────── 1 : Install MariaDB and other necessary packages ─────────
RUN apt update -y && \
	apt upgrade -y && \
	apt-get install -y mariadb-server && \
	apt install -y nano && \
	apt install -y curl && \
	apt install neofetch -y

# ───────── 2 : Copy configuration files ─────────
RUN mkdir -p /var/run/mariadb
COPY conf/50-server.cnf /etc/mysql/mariadb.conf.d/50-server.cnf

# ───────── 3 : Copy and setup initialization script ─────────
COPY tools/config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/config.sh

# ───────── 4 : Launch MariaDB with configuration script ─────────
CMD ["/usr/local/bin/config.sh"]