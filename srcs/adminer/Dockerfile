# ───────── Adminer ─────────
FROM debian:bullseye

RUN apt update -y && apt upgrade -y && \
    apt install -y php php-fpm php-mysqli wget && \
    rm -rf /var/lib/apt/lists/*

RUN mkdir -p /run/php

RUN mkdir -p /var/www/adminer && \
    wget https://github.com/vrana/adminer/releases/download/v5.2.1/adminer-5.2.1.php -O /var/www/adminer/index.php && \
    chown -R www-data:www-data /var/www/adminer && \
    chmod 755 /var/www/adminer && \
    chmod 644 /var/www/adminer/index.php

COPY conf/www.conf /etc/php/7.4/fpm/pool.d/
COPY conf/entrypoint.sh /usr/local/bin/
RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 9000
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
