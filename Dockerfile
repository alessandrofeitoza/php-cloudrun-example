# =============================
# STAGE 1 — Build (Composer)
# =============================
FROM php:8.5-fpm AS build

WORKDIR /var/www

# Instalar dependências do sistema
RUN apt-get update && apt-get install -y \
    git \
    unzip \
    zip \
    && rm -rf /var/lib/apt/lists/*

# Instalar Composer
COPY --from=composer:2 /usr/bin/composer /usr/bin/composer

# Copiar dependências PHP
COPY composer.json composer.lock ./
RUN composer install --no-dev --optimize-autoloader

# Copiar código depois do install (boa prática)
COPY . .


# =============================
# STAGE 2 — Runtime (Nginx + PHP-FPM)
# =============================
FROM php:8.5-fpm

# Instalar Nginx
RUN apt-get update && apt-get install -y nginx \
    && rm -rf /var/lib/apt/lists/*

# Copiar configuração do Nginx
COPY nginx.conf /etc/nginx/nginx.conf

# Copiar código já instalado
COPY --from=build /var/www /var/www

# Ajustar permissões
RUN chown -R www-data:www-data /var/www

WORKDIR /var/www

# Cloud Run usa a porta 8080
ENV PORT=8080
EXPOSE 8080

# Comando final: subir Nginx + PHP-FPM
CMD service nginx start && php-fpm
