#!/bin/bash

# stop the container if any command fails
set -e   

# read password from /secret into variables
SQL_PASSWORD=$(cat /run/secrets/db_password)
WP_ADMIN_PASSWORD=$(cat /run/secrets/wp_admin_password)
WP_USER_PASSWORD=$(cat /run/secrets/wp_user_password)

# wait until MariaDB accepts a REAL login
# loop every 2 seconds until a real login to mariadb work 
# wp cant  install itself before database is ready
until mariadb -h mariadb -u"${SQL_USER}" -p"${SQL_PASSWORD}" "${SQL_DATABASE}" -e "SELECT 1;" >/dev/null 2>&1; do
    echo "waiting for mariadb..."
    sleep 2
done

cd /var/www/html

# first run, stup WordPress structure, url, title ...., if wp-config.php doesnt exist

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

# www-data is a compromised PHP worker, only gets limited rights
# php-fpm runs as www-data, that user must own the files
# www-data must own them to write uploads
chown -R www-data:www-data /var/www/html

# replace the script by php-fpm
# exec replaces the shell,  php-fpm is PID 1
exec php-fpm8.2 -F -O
