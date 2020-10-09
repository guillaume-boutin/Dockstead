ARG PHP_VERSION=7.4

FROM php:${PHP_VERSION}-fpm

RUN apt-get update && apt-get install $PHPIZE_DEPS

RUN docker-php-ext-install pdo
RUN docker-php-ext-install pdo_mysql
RUN docker-php-ext-install exif
RUN docker-php-ext-install pcntl
RUN docker-php-ext-install bcmath
RUN docker-php-ext-install mysqli

# xdebug
RUN if [ $(php -r "echo PHP_MAJOR_VERSION;") = "5" ]; then \
    pecl install xdebug-2.5.5; \
else \
    if [ $(php -r "echo PHP_MINOR_VERSION;") = "0" ]; then \
        pecl install xdebug-2.9.0; \
    else \
        pecl install xdebug; \
    fi \
fi && \
docker-php-ext-enable xdebug

# # python3
# RUN apt-get update && apt-get -y upgrade && \
#     apt-get install -y build-essential libssl-dev libffi-dev python3-dev \
#     python3-pip
# RUN apt install -y python3-opencv && pip3 install imutils scipy

#upload
RUN echo "file_uploads = On" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "memory_limit = 100M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "upload_max_filesize = 100M" >> /usr/local/etc/php/conf.d/uploads.ini \
    && echo "post_max_size = 100M" >> /usr/local/etc/php/conf.d/uploads.ini

# # swoole
# RUN { \
#     echo "\n"; \
#     echo "\n"; \
#     echo "\n"; \
#     echo "\n"; \
# } | pecl install swoole
# RUN docker-php-ext-enable swoole

ARG UID=1000
ARG GID=1000
RUN usermod -u ${UID} www-data && groupmod -g ${GID} www-data

RUN chown -R www-data:www-data /var/www

USER www-data

WORKDIR /var/www
