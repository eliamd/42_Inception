# ───────── NGINX ─────────
FROM debian:bullseye

# Installation des paquets et configuration du certificat
RUN apt update -y && apt upgrade -y && \
    apt install -y nginx openssl nano curl neofetch && \
    rm -rf /var/lib/apt/lists/* && \
    mkdir -p /etc/nginx/ssl /var/run/nginx && \
    openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt \
    -keyout /etc/nginx/ssl/inception.key \
    -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=edetoh.42.fr/UID=edetoh" && \
    chmod 755 /var/www/html && \
    chown -R www-data:www-data /var/www/html

# Copie du fichier de configuration
COPY conf/nginx.conf /etc/nginx/nginx.conf

EXPOSE 443

CMD ["nginx", "-g", "daemon off;"]