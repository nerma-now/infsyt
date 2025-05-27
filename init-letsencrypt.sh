#!/bin/bash

# Параметры из .env файла (или укажите явно)
DOMAIN_EMAIL=${DOMAIN_EMAIL:-"your@email.com"}  # Если нет в .env
DOMAIN_URL=${DOMAIN_URL:-"tsiul.ru"}           # Если нет в .env

# Создаем временную конфигурацию Nginx для ACME-проверки
mkdir -p ./nginx
cat > ./nginx/nginx.conf <<EOF
events {}
http {
    server {
        listen 80;
        server_name $DOMAIN_URL www.$DOMAIN_URL;
        location /.well-known/acme-challenge/ {
            root /var/www/certbot;
        }
        location / {
            return 301 https://\$host\$request_uri;
        }
    }
}
EOF

# Запускаем временный Nginx и Certbot
docker compose up -d nginx  # Запускаем только Nginx
sleep 5  # Ждем инициализации

# Получаем сертификат (webroot-метод)
docker compose run --rm certbot certonly \
  --webroot \
  --webroot-path /var/www/certbot \
  --email $DOMAIN_EMAIL \
  --agree-tos \
  --no-eff-email \
  -d $DOMAIN_URL \
  -d www.$DOMAIN_URL \
  --force-renewal

# Останавливаем временный Nginx
docker compose down

# Запускаем полноценный сервис с SSL
docker compose up -d