#!/bin/bash

DOMAIN_EMAIL=${DOMAIN_EMAIL:-"your@email.com"}
DOMAIN_URL=${DOMAIN_URL:-"tsiul.ru"}

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

docker-compose up -d nginx
sleep 5

docker-compose run --rm certbot certonly \
  --webroot \
  --webroot-path /var/www/certbot \
  --email $DOMAIN_EMAIL \
  --agree-tos \
  --no-eff-email \
  -d $DOMAIN_URL \
  -d www.$DOMAIN_URL \
  --force-renewal

docker-compose down

docker-compose up -d