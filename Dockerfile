# syntax=docker/dockerfile:1

FROM php:8.1-apache-bookworm

# Configure PHP
RUN mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini"
RUN apt-get update && apt-get install -y cron zip libpng-dev libzip-dev libonig-dev libxml2-dev libgmp-dev libc-client-dev libkrb5-dev git wget

RUN docker-php-ext-install zip && \
    docker-php-ext-install mysqli && \
    docker-php-ext-install pdo && \
    docker-php-ext-install pdo_mysql && \
    docker-php-ext-install mbstring && \
    docker-php-ext-install gettext && \
    docker-php-ext-install soap && \
    docker-php-ext-install gmp && \
    docker-php-ext-install gd && \
    docker-php-ext-configure imap --with-kerberos --with-imap-ssl && \
    docker-php-ext-install imap && \
    docker-php-ext-enable mysqli

# Install ionCube loader
ARG TARGETPLATFORM
RUN if [ "$TARGETPLATFORM" = "linux/amd64" ]; then ARCHITECTURE="x86-64"; elif [ "$TARGETPLATFORM" = "linux/arm/v7" ]; then ARCHITECTURE="armv7l"; elif [ "$TARGETPLATFORM" = "linux/arm64" ]; then ARCHITECTURE="aarch64"; else ARCHITECTURE="x86-64"; fi && \
    curl -fSL "http://downloads3.ioncube.com/loader_downloads/ioncube_loaders_lin_${ARCHITECTURE}.tar.gz" -o ioncube.tar.gz && \
    mkdir -p ioncube && \
    tar -xf ioncube.tar.gz -C ioncube --strip-components=1 && \
    rm ioncube.tar.gz && \
    mv ioncube/ioncube_loader_lin_8.1.so /var/www/ioncube_loader_lin_8.1.so && \
    rm -r ioncube && \
    echo "\nzend_extension = /var/www/ioncube_loader_lin_8.1.so\n" >> "$PHP_INI_DIR/php.ini"

# Install Composer
RUN wget https://raw.githubusercontent.com/composer/getcomposer.org/76a7060ccb93902cd7576b67264ad91c8a2700e2/web/installer -O - -q | php -- --quiet && \
    chmod +x composer.phar && \
    mv ./composer.phar /usr/local/bin/composer

# Install Blesta
RUN wget https://account.blesta.com/client/plugin/download_manager/client_main/download/254/blesta-5.10.2.zip -O blesta.zip &&\
    mkdir ./blesta && \
    mkdir /var/www/uploads && \
    unzip blesta.zip -d ./blesta && \
    mv -f ./blesta/blesta/.htaccess /var/www/html && \
    mv -f ./blesta/blesta/* /var/www/html && \
    mv -f ./blesta/uploads/* /var/www/uploads && \
    rm -rf ./blesta.zip && \
    rm -rf ./blesta

# Configure Apache
RUN chown -R www-data:www-data /var/www/html/.htaccess && \
    chown -R www-data:www-data /var/www/html/* && \
    sed -i 's|<VirtualHost \*:80>|<VirtualHost *:8080>|g' /etc/apache2/sites-enabled/000-default.conf && \
    sed -i 's|Listen 80|Listen 8080|g' /etc/apache2/ports.conf && \
    a2enmod rewrite && \
    service apache2 restart

# Configure cron
RUN rm -rf /etc/cron.{hourly,daily,weekly,monthly} && \
    echo '*/5 * * * * www-data /usr/local/bin/php /var/www/html/index.php cron' > /etc/cron.d/blesta

# Set enviroment variables
ENV HOSTNAME="localhost"
ENV MYSQL_HOST="localhost"
ENV MYSQL_USER="blesta"
ENV MYSQL_PASSWORD="blesta"
ENV MYSQL_DATABASE="blesta"

# Start Apache
CMD (sleep 15 && /usr/local/bin/php /var/www/html/index.php install -dbhost ${MYSQL_HOST} -dbname ${MYSQL_DATABASE} -dbuser ${MYSQL_USER} -dbpass ${MYSQL_PASSWORD} -hostname ${HOSTNAME} -docroot /var/www/html/) && \
    (cron -f &) && \
    apache2-foreground

# Expose server port
EXPOSE 8080

# Set required volumes
VOLUME ["/var/www/html/cache", "/var/www/html/config", "/var/www/uploads"]
