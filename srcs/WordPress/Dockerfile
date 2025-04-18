# ───────── WordPress ─────────
FROM debian:bullseye

# Installation des paquets nécessaires
RUN apt update -y && apt upgrade -y && \
    apt install -y \
    php php-fpm php-mysqli mariadb-client \
    wget curl nano procps msmtp msmtp-mta && \
    rm -rf /var/lib/apt/lists/*

# Configuration de PHP-FPM
RUN mkdir -p /run/php
COPY conf/www.conf /etc/php/7.4/fpm/pool.d/

# Installation de WordPress
RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www && \
    cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz && \
    chown -R www-data:www-data /var/www/wordpress

# Installation de WP-CLI
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && mv wp-cli.phar /usr/local/bin/wp

# Configuration et point d'entrée
COPY conf/auto_config.sh /usr/local/bin/
COPY conf/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/auto_config.sh /usr/local/bin/entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

