FROM docker.io/moodlehq/moodle-php-apache:8.4

ARG MOODLE_BRANCH=main

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Clone Moodle 5.3+ and install Composer dependencies
WORKDIR /var/www/html
RUN rm -rf /var/www/html/* \
    && git clone --depth 1 --branch "${MOODLE_BRANCH}" https://github.com/moodle/moodle.git /var/www/html \
    && composer install --no-dev --classmap-authoritative --no-interaction \
    && mkdir -p /var/www/moodledata \
    && chown -R www-data:www-data /var/www/moodledata

# Copy default configuration and entrypoint
COPY .docker/config.php /var/www/html/config.php
COPY .docker/entrypoint.sh /usr/local/bin/iassign-entrypoint.sh
RUN chmod +x /usr/local/bin/iassign-entrypoint.sh

# Copy mod_iassign plugin into Moodle (can be overridden via bind mount in development)
COPY . /var/www/html/public/mod/iassign
RUN mkdir -p /var/www/html/public/mod/iassign/ilm \
    && chown -R www-data:www-data /var/www/html/public/mod/iassign/ilm

EXPOSE 80
ENTRYPOINT ["iassign-entrypoint.sh"]

