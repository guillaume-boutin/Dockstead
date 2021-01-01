#!/bin/bash

apt-get install -y --allow-downgrades --allow-remove-essential \
    --allow-change-held-packages \
    php8.0-cli \
    php8.0-common \
    php8.0-curl \
    php8.0-intl \
    php8.0-xml \
    php8.0-mbstring \
    php8.0-mysql \
    php8.0-pgsql \
    php8.0-sqlite \
    php8.0-sqlite3 \
    php8.0-zip \
    php8.0-bcmath \
    php8.0-memcached \
    php8.0-gd \
    php8.0-dev
