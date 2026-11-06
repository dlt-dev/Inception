#!/bin/bash

# stop the container if any command fails
set -e   

# attendre until MariaDB accepts a REAL login
until mariadb -h mariadb -u"${SQL_USER}" -p"${SQL_PASSWORD}" "${SQL_DATABASE}" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "waiting for mariadb..."
    sleep 2
done

cd /var/www/html

# lors du premier run, installe WordPress

if [ ! -f wp-config.php ]; then
    wp core download --allow-root

    wp config create --allow-root \
        --dbname="${SQL_DATABASE}" \
        --dbuser="${SQL_USER}" \
        --dbpass="${SQL_PASSWORD}" \
        --dbhost="mariadb:3306"

    wp core install --allow-root \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_ADMIN_USER}" \
        --admin_password="${WP_ADMIN_PASSWORD}" \
        --admin_email="${WP_ADMIN_EMAIL}" \
        --skip-email

    wp user create --allow-root "${WP_USER}" "${WP_USER_EMAIL}" \
        --user_pass="${WP_USER_PASSWORD}" \
        --role=author
fi

# php-fpm runs as www-data, that user must own the files
chown -R www-data:www-data /var/www/html

# exec replaces the shell,  php-fpm is PID 1
exec php-fpm8.2 -F -O