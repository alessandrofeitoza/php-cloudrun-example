FROM php:8.5-fpm

WORKDIR /app

RUN apt-get update && apt-get install -y unzip git

COPY composer.json composer.lock ./
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin --filename=composer
RUN composer install --no-dev --optimize-autoloader

COPY . .

CMD ["php-fpm"]