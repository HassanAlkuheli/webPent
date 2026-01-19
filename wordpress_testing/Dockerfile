FROM wordpress:6.4.3-php7.4-apache

# Install dependencies and extensions
RUN apt-get update && apt-get install -y \
    libzip-dev \
    libxml2-dev \
    libonig-dev \
    libpng-dev \
    ssl-cert \
    && docker-php-ext-install \
    mysqli \
    curl \
    gd \
    mbstring \
    xml \
    zip \
    && a2enmod ssl \
    && a2enmod headers \
    && a2enmod deflate \
    && a2enmod filter \
    && a2ensite default-ssl

# Configure Apache to listen on 8443 and use self-signed cert
RUN openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /etc/ssl/private/apache-selfsigned.key \
    -out /etc/ssl/certs/apache-selfsigned.crt \
    -subj "/C=US/ST=State/L=City/O=Organization/CN=local-test-site.dev"

# Update Apache ports configuration
RUN sed -i 's/80/8080/g' /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf
RUN sed -i 's/443/8443/g' /etc/apache2/ports.conf /etc/apache2/sites-available/*.conf

# Configure custom apache settings
COPY config/custom-apache.conf /etc/apache2/conf-available/custom-security.conf
RUN a2enconf custom-security

# Create custom php.ini
COPY config/php.ini /usr/local/etc/php/conf.d/custom-php.ini

# Ensure log directories exist and are writable
RUN mkdir -p /var/www/logs && chown -R www-data:www-data /var/www/logs

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar && \
    chmod +x wp-cli.phar && \
    mv wp-cli.phar /usr/local/bin/wp
