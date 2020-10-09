FROM phusion/baseimage:0.11

ENV DEBIAN_FRONTEND noninteractive

RUN DEBIAN_FRONTEND=noninteractive
RUN locale-gen en_US.UTF-8

ENV LANGUAGE=en_US.UTF-8
ENV LC_ALL=en_US.UTF-8
ENV LC_CTYPE=en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV TERM xterm

# add users
ARG UID=1000
ARG GID=1000
ARG WORKSPACE_USER=dockstead

RUN groupadd -g $GID $WORKSPACE_USER && \
    useradd -u $UID -g $WORKSPACE_USER -m $WORKSPACE_USER && \
    usermod -p "*" $WORKSPACE_USER -s /bin/bash

USER root

ARG PHP_VERSION=${PHP_VERSION}
RUN echo 'DPkg::options { "--force-confdef"; };' >> /etc/apt/apt.conf

RUN apt-add-repository -y ppa:ondrej/php

# Install "PHP Extentions", "libraries", "Software's"
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y --allow-downgrades --allow-remove-essential \
        --allow-change-held-packages \
        php-imagick \
        pkg-config \
        libcurl4-openssl-dev \
        libedit-dev \
        libssl-dev \
        libxml2-dev \
        xz-utils \
        libsqlite3-dev \
        libreadline-dev \
        libyaml-dev \
        libxslt1-dev \
        libffi-dev \
        rsync \
        sqlite3 \
        git \
        curl \
        vim \
        nano \
        postgresql-client \
        unzip \
        wget \
        git-core \
        zlib1g-dev \
        build-essential \
        autoconf \
        bison \
    && apt-get clean

ARG PHP_VERSION=7.4
ENV PHP_VERSION ${PHP_VERSION}

# install PHP ${PHP_VERSION}
COPY install_php${PHP_VERSION}.sh ./install/install_php${PHP_VERSION}.sh
RUN chmod 775 ./install/install_php${PHP_VERSION}.sh
RUN ./install/install_php${PHP_VERSION}.sh
RUN rm ./install/install_php${PHP_VERSION}.sh

# # install PHP 7.2
# COPY install_php7.2.sh ./install/install_php7.2.sh
# RUN chmod 775 ./install/install_php7.2.sh
# RUN ./install/install_php7.2.sh
# RUN rm ./install/install_php7.2.sh

# # install PHP 7.3
# COPY install_php7.3.sh ./install/install_php7.3.sh
# RUN chmod 775 ./install/install_php7.3.sh
# RUN ./install/install_php7.3.sh
# RUN rm ./install/install_php7.3.sh

# # install PHP 7.4
# COPY install_php7.4.sh ./install/install_php7.4.sh
# RUN chmod 775 ./install/install_php7.4.sh
# RUN ./install/install_php7.4.sh
# RUN rm ./install/install_php7.4.sh

# set PHP ${PHP_VERSION} as default
RUN update-alternatives --set php /usr/bin/php${PHP_VERSION}

# install sudo
RUN apt-get install -y sudo && \
    echo "$WORKSPACE_USER ALL=(root) NOPASSWD:ALL" > /etc/sudoers.d/user && \
    chmod 0440 /etc/sudoers.d/user

USER ${WORKSPACE_USER}
RUN touch /home/${WORKSPACE_USER}/.bashrc

# install composer
USER root
RUN curl -sS https://getcomposer.org/installer | php
RUN mv composer.phar /usr/local/bin/composer

USER ${WORKSPACE_USER}
#install laravel installer
RUN composer global require laravel/installer
# install symfony
RUN wget https://get.symfony.com/cli/installer -O - | bash
RUN sudo mv /home/dockstead/.symfony/bin/symfony /usr/local/bin/symfony
#install phpunit
RUN composer global require phpunit/phpunit

RUN echo 'PATH="$HOME/.composer/vendor/bin:$PATH"' >> /home/${WORKSPACE_USER}/.bashrc

# install nodejs
ARG INSTALL_NODE=true
ARG NODE_VERSION=node
ENV NODE_VERSION ${NODE_VERSION}
ARG NPM_REGISTRY
ENV NPM_REGISTRY ${NPM_REGISTRY}
ENV NVM_DIR /home/${WORKSPACE_USER}/.nvm

RUN if [ ${INSTALL_NODE} = true ]; then \
    # Install nvm (A Node Version Manager)
    mkdir -p $NVM_DIR && \
    curl -o- https://raw.githubusercontent.com/creationix/nvm/v0.33.11/install.sh | bash \
        && . $NVM_DIR/nvm.sh \
        && nvm install ${NODE_VERSION} \
        && nvm use ${NODE_VERSION} \
        && nvm alias ${NODE_VERSION} \
        && if [ ${NPM_REGISTRY} ]; then \
        npm config set registry ${NPM_REGISTRY} \
        ;fi \
        && if [ ${INSTALL_NPM_GULP} = true ]; then \
        npm install -g gulp \
        ;fi \
        && if [ ${INSTALL_NPM_BOWER} = true ]; then \
        npm install -g bower \
        ;fi \
        && if [ ${INSTALL_NPM_VUE_CLI} = true ]; then \
        npm install -g @vue/cli \
        ;fi \
        && if [ ${INSTALL_NPM_ANGULAR_CLI} = true ]; then \
        npm install -g @angular/cli \
        ;fi \
        && ln -s `npm bin --global` /home/${WORKSPACE_USER}/.node-bin \
;fi

# Wouldn't execute when added to the RUN statement in the above block
# Source NVM when loading bash since ~/.profile isn't loaded on non-login shell
RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="$HOME/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
;fi

# Add NVM binaries to root's .bashrc
USER root

RUN if [ ${INSTALL_NODE} = true ]; then \
    echo "" >> ~/.bashrc && \
    echo 'export NVM_DIR="/home/\$WORKSPACE_USER/.nvm"' >> ~/.bashrc && \
    echo '[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm' >> ~/.bashrc \
;fi

# Add PATH for node
ENV PATH $PATH:/home/${WORKSPACE_USER}/.node-bin

# install yarn
RUN apt-get install -y yarn && \
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && \
    apt-get install -y --no-install-recommends yarn

RUN mkdir /home/${WORKSPACE_USER}/code && \
    chown -R ${WORKSPACE_USER}:${WORKSPACE_USER} /home/${WORKSPACE_USER}/code

USER ${WORKSPACE_USER}

RUN echo "" >> /home/${WORKSPACE_USER}/.bashrc \
    && echo "PS1='${debian_chroot:+($debian_chroot)}\[\033[01;32m\]\u@workspace\[\033[00m\]:\[\033[01;34m\]\w\[\033[00m\]\$ '\n" >> /home/${WORKSPACE_USER}/.bashrc && \
    echo "\nswitchphp () {" >> ~/.bashrc && \
    echo "    sudo update-alternatives --set php /usr/bin/php\$1" >> ~/.bashrc && \
    echo "}\n" >> ~/.bashrc && \
    /bin/bash -c ". /home/$WORKSPACE_USER/.bashrc"

# aliases
RUN echo "" >> /home/${WORKSPACE_USER}/.bashrc \
    && echo "alias artisan='php artisan'" >> /home/${WORKSPACE_USER}/.bashrc

USER root

# Clean up
RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* && \
    rm /var/log/lastlog /var/log/faillog

WORKDIR /home/${WORKSPACE_USER}/code
