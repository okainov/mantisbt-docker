FROM php:7.4-apache

RUN a2enmod rewrite

RUN set -xe \
    && apt-get update \
    && apt-get install -y \
        # PHP dependencies
        libfreetype6-dev libpng-dev libjpeg-dev libpq-dev libxml2-dev \
        # New in PHP 7.4, required for mbstring, see https://github.com/docker-library/php/issues/880
        libonig-dev \
        # To clone plugins
        git \
    && docker-php-ext-configure gd --with-jpeg --with-freetype \
    && docker-php-ext-install gd mbstring mysqli soap \
    && rm -rf /var/lib/apt/lists/*

ENV MANTIS_VER 2.24.1
ENV MANTIS_MD5 a5a001ffa5a9c9a55848de1fbf7fae95
ENV MANTIS_URL https://sourceforge.net/projects/mantisbt/files/mantis-stable/${MANTIS_VER}/mantisbt-${MANTIS_VER}.tar.gz
ENV MANTIS_FILE mantisbt.tar.gz

# Install MantisBT itself
RUN set -xe \
    && curl -fSL ${MANTIS_URL} -o ${MANTIS_FILE} \
    && md5sum ${MANTIS_FILE} \
    && echo "${MANTIS_MD5}  ${MANTIS_FILE}" | md5sum -c \
    && tar -xz --strip-components=1 -f ${MANTIS_FILE} \
    && rm ${MANTIS_FILE} \
    && rm -r doc \
    && chown -R www-data:www-data . \
    # Apply PHP and config fixes
    # Use the default production configuration
    && mv "$PHP_INI_DIR/php.ini-production" "$PHP_INI_DIR/php.ini" \
    && echo 'mysqli.allow_local_infile = Off' >> $PHP_INI_DIR/conf.d/mantis.php.ini \
    && echo 'display_errors = Off ' >> $PHP_INI_DIR/conf.d/mantis.php.ini \
    && echo 'log_errors = On ' >> $PHP_INI_DIR/conf.d/mantis.php.ini \
    && echo 'error_log = /dev/stderr' >> $PHP_INI_DIR/conf.d/mantis.php.ini \
    && echo 'register_argc_argv = Off' >> $PHP_INI_DIR/conf.d/mantis.php.ini

COPY config_inc.php /var/www/html/config/config_inc.php

# Install additional plugins
# TODO: copy from multi-stage to remove git dependency
ENV SOURCE_TAG v2.3.1
RUN set -xe && \
        git clone --branch $SOURCE_TAG --depth 1 https://github.com/mantisbt-plugins/source-integration.git /tmp/source && \
        cp -r /tmp/source/Source /tmp/source/SourceGitlab /tmp/source/SourceGithub /var/www/html/plugins/ && \
        rm -r /tmp/source

ADD ./mantis-entrypoint /usr/local/bin/mantis-entrypoint

CMD ["mantis-entrypoint"]