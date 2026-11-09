#!/bin/bash

# loking for password dans /secret
SQL_PASSWORD=$(cat /run/secrets/db_password)
SQL_ROOT_PASSWORD=$(cat /run/secrets/db_root_password)

# a bind-mounted folder arrives empty and owned by the host user
# start to configure
mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql /run/mysqld


# empty data folder: create MariaDB's internal system tables first
if [ ! -d /var/lib/mysql/mysql ]; then
    mariadb-install-db --user=mysql --datadir=/var/lib/mysql > /dev/null
fi

if [ ! -d "/var/lib/mysql/${SQL_DATABASE}" ]; then
    # start a temporary server to configure it
    service mariadb start

    # wait until le server answers
    until mysqladmin ping --silent 2>/dev/null; do
        sleep 1
    done


    # create database (SQL_DATABASE)
    mysql -e "CREATE DATABASE IF NOT EXISTS \`${SQL_DATABASE}\`;"

    # create an user who can touch it (SQL_USER) + password (for local connections and for network connections)
    mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'localhost' IDENTIFIED BY '${SQL_PASSWORD}';"
    mysql -e "CREATE USER IF NOT EXISTS \`${SQL_USER}\`@'%' IDENTIFIED BY '${SQL_PASSWORD}';"

    # I give access SQL_USER with SQL_PASSWORD to SQL_DATABASE
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'localhost';"
    mysql -e "GRANT ALL PRIVILEGES ON \`${SQL_DATABASE}\`.* TO \`${SQL_USER}\`@'%';"

    # flush for mysql to update
    mysql -e "FLUSH PRIVILEGES;"

    # change les droits root with  SQL_ROOT_PASSWORD
    # set the root password
    mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED BY '${SQL_ROOT_PASSWORD}';"

    # restart with new config, first shutdown
    mysqladmin -u root -p"${SQL_ROOT_PASSWORD}" shutdown

fi

exec mariadbd --user=mysql

EOF
