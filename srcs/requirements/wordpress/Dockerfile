FROM debian:bookworm

# PHP, the extensions WordPress needs .........
# download images, terxt, encoding ..
RUN apt-get update && apt-get install -y --no-install-recommends \
    php8.2-fpm php8.2-cli php8.2-mysql php8.2-curl php8.2-gd \
    php8.2-mbstring php8.2-xml php8.2-zip \
    curl ca-certificates mariadb-client \
    && rm -rf /var/lib/apt/lists/*

# wp-cli = download and make it executable (wp command)
RUN curl -fsSL -o /usr/local/bin/wp \
    https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x /usr/local/bin/wp


# Replace the default settings php-fpm pool config by the one we have
COPY conf/www.conf /etc/php/8.2/fpm/pool.d/www.conf

# create the folder php-fpm needs for its pid file
RUN mkdir -p /run/php

# the port
EXPOSE 9000

# copy the script
COPY tools/setup.sh /usr/local/bin/setup.sh

# start the script, make it executable
RUN chmod +x /usr/local/bin/setup.sh && mkdir -p /var/www/html

# the folder where wp will live
WORKDIR /var/www/html

# the programthe container is buit to run 
ENTRYPOINT ["/usr/local/bin/setup.sh"]

