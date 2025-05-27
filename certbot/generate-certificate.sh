#!/bin/bash

if [ ! -f "/etc/letsencrypt/live/${DOMAIN_URL}/fullchain.pem" ]; then
  certbot certonly --standalone --email $DOMAIN_EMAIL -d $DOMAIN_URL \
    --cert-name $DOMAIN_URL --key-type rsa --agree-tos --non-interactive
fi

while true; do
  certbot renew --quiet
  sleep 12h
done