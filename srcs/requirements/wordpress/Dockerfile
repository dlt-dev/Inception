FROM debian:bookworm

# PHP, the extensions WordPress needs .........
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-gd \
    php8.2-mbstring php8.2-xml php8.2-zip \
    curl ca-certificates mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# wp-cli = download and make it executable (wp command)
RUN curl -fsSL -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp


# Replace the default php-fpm pool config
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# php-fpm needs this folder for its pid file
RUN mkdir -p /run/php

EXPOSE 9000

# run php-fpm in the foreground as PID 1
ENTRYPOINT ["php-fpm8.2", "-F", "-O"]