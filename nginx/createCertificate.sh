#!/bin/sh

DOMAIN=$1
{\
    echo "CA"; \
    echo "Quebec"; \
    echo "Montreal"; \
    echo "Receiptient"; \
    echo "Development"; \
    echo $DOMAIN; \
    echo "support@$DOMAIN"; \
} | openssl req -newkey rsa:2048 -nodes -keyout /etc/nginx/ssl/$DOMAIN.pem -x509 -days 5000 -out /etc/nginx/ssl/$DOMAIN.crt

openssl pkcs12 -inkey /etc/nginx/ssl/$DOMAIN.pem -in /etc/nginx/ssl/$DOMAIN.crt -export -out /etc/nginx/ssl/$DOMAIN.p12 -password pass:secret

echo ""
