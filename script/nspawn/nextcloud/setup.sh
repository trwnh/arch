#!/bin/bash

# systemd-nspawn -D /var/lib/machines/nextcloud
# passwd
# logout

# systemd-nspawn -b -D /var/lib/machines/nextcloud

## MariaDB
mariadb-install-db --user=mysql --basedir=/usr --datadir=/var/lib/mysql
systemctl enable --now mariadb
mysql_secure_installation
mysql -u root -p
#### create database nextcloud;
#### create user 'nextcloud'@'localhost' identified by 'password';
#### grant all privileges on nextcloud.* to 'nextcloud'@'localhost';
#### flush privileges;

## Redis
systemctl enable --now redis

systemctl enable {nginxredis}

# CTRL + ]]]
