FROM php:7.3-fpm

MAINTAINER Daniel Crump <d.crump@taenzer.me>

RUN php -r "copy('https://getcomposer.org/installer', '/tmp/composer-setup.php');"
RUN php /tmp/composer-setup.php --no-ansi --install-dir=/usr/local/bin --filename=composer && \
    rm -rf /tmp/composer-setup.php

RUN apt-get update && apt-get install -y \
        libfreetype6-dev \
        libjpeg62-turbo-dev \
        libmcrypt-dev \
        libpng-dev \
        libxml2-dev \
        git \
        unzip \
        libzip-dev \
        libc-client-dev \
        libkrb5-dev \
        wget

RUN rm -r /var/lib/apt/lists/*

# Install php modules
RUN docker-php-ext-configure imap --with-kerberos --with-imap-ssl
RUN docker-php-ext-install gd pdo pdo_mysql zip iconv soap mysqli intl imap xmlrpc

# Enable php modules
RUN docker-php-ext-enable mysqli intl imap

# Configure php modules
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/

RUN cd /tmp \
	&& curl -o ioncube.tar.gz http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_x86-64.tar.gz \
    && tar -xvvzf ioncube.tar.gz \
    && mv ioncube/ioncube_loader_lin_7.3.so /usr/local/lib/php/extensions/* \
    && rm -Rf ioncube.tar.gz ioncube \
    && echo "zend_extension=/usr/local/lib/php/extensions/no-debug-non-zts-20180731/ioncube_loader_lin_7.3.so" > /usr/local/etc/php/conf.d/00_docker-php-ext-ioncube_loader_lin_7.3.ini

WORKDIR /var/www

EXPOSE 9000

CMD ["php-fpm"]
