FROM composer:1 AS build-env
COPY . /app
RUN apk add --no-cache libpng libpng-dev && docker-php-ext-install gd && apk del libpng-dev
RUN cd /app && COMPOSER_MEMORY_LIMIT=-1 composer install

# FROM wesleyelfring/laravel:latest as test-env
# WORKDIR /var/www/html/
# COPY --from=build-env /app/php.ini /usr/local/etc/php/
# COPY --from=build-env /app /var/www/html
# RUN make run-test

FROM wesleyelfring/laravel:latest

# Copy files
WORKDIR /var/www/html/
COPY --from=build-env /app/php.ini /usr/local/etc/php/
COPY --from=build-env /app /var/www/html

RUN php artisan storage:link

RUN chown -R www-data:www-data \
    /var/www/html/storage \
    /var/www/html/bootstrap/cache
RUN chmod 777 -R /var/www/html/storage

RUN apt-get update && apt-get install -y cron sqlite3 libsqlite3-dev
RUN rm -rf /var/lib/apt/lists



ENTRYPOINT ["/bin/bash", "-c","apachectl -D FOREGROUND"]