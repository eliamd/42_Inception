# ───────── WordPress ─────────

# ───────── 0 : Base image ─────────
FROM debian:buster

# ───────── 1 : Install necessary packages ─────────
RUN apt update -y && \
	apt upgrade -y && \
	apt install -y php7.3 php-fpm php-mysqli mariadb-client && \
	apt install -y nano && \
	apt install -y curl && \
	apt install -y wget && \
	apt install -y procps && \
	apt install -y msmtp msmtp-mta

# ───────── 2 : Configure PHP-FPM ─────────
RUN mkdir -p /run/php
COPY conf/www.conf /etc/php/7.3/fpm/pool.d/

# ───────── 3 : Download and setup WordPress ─────────
RUN wget https://fr.wordpress.org/wordpress-6.0-fr_FR.tar.gz -P /var/www
RUN cd /var/www && tar -xzf wordpress-6.0-fr_FR.tar.gz && rm wordpress-6.0-fr_FR.tar.gz
RUN chown -R www-data:www-data /var/www/wordpress

# ───────── 4 : Install WP-CLI ─────────
RUN wget https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
RUN chmod +x wp-cli.phar
RUN mv wp-cli.phar /usr/local/bin/wp

# ───────── 5 : Copy the auto-configuration script ─────────
COPY conf/auto_config.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/auto_config.sh

# ───────── 6 : Expose port ─────────
EXPOSE 9000

# ───────── 7 : Launch PHP-FPM and auto-configuration ─────────
COPY conf/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]

