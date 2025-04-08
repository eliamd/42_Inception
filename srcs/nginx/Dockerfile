# ───────── NGINX ─────────

# ───────── 0 : Base image ─────────
FROM debian:buster

# ───────── 1 : Install Nginx and other necessary packages ─────────
RUN apt update -y && \
	apt upgrade -y && \
	apt install -y nginx && \
	apt install -y nano && \
	apt install -y curl && \
	apt install neofetch -y

# ───────── 2 : Install TLS and create a cert  ─────────
RUN mkdir -p /etc/nginx/ssl
RUN apt install -y openssl

# Create a self-signed certificate
RUN openssl req -x509 -nodes -out /etc/nginx/ssl/inception.crt -keyout /etc/nginx/ssl/inception.key -subj "/C=FR/ST=IDF/L=Paris/O=42/OU=42/CN=edetoh.42.fr/UID=edetoh"

# ───────── 3 : Copy the Nginx configuration file ─────────
RUN mkdir -p /var/run/nginx
COPY conf/nginx.conf /etc/nginx/nginx.conf

# ───────── 4 : Set permissions ─────────

RUN chmod 755 /var/www/html
RUN chown -R www-data:www-data /var/www/html

# ───────── 5 : Launch NGINX ─────────

CMD ["nginx", "-g", "daemon off;"]