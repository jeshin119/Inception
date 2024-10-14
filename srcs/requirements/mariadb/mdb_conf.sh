#!/bin/bash

# mariadb start
service mariadb start
sleep 5

# mariadb config
# create database if not exists
mariadb -e "CREATE DATABASE IF NOT EXISTS \`${MYSQL_DB}\`;"

# create user if not exists
mariadb -e "CREATE USER IF NOT EXISTS \`${MYSQL_USER}\`@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';"

#grant privilegs to user
mariadb -e "GRANT ALL PRIVILEGES ON ${MYSQL_DB}.* TO \`${MYSQL_USER}\`@'%';"

# flush privileges to apply changes
mariadb -e "FLUSH PRIVILEGES;"

# mariadb restart
# shutdown mariadb to restart with new config
mysqladmin -u root -p$MYSQL_ROOT_PASSWORD shutdown

# restart mariadb with new config in the background to keep the container running
mysqld_safe --port=3306 --bind-address=0.0.0.0 --datadir='/var/lib/mysql'