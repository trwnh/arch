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
nano /etc/my.cnf.d/server.cnf
#### [mysqld]
#### skip-networking
systemctl restart mariadb

## Redis
nano /etc/redis/redis.conf
#### port 0
#### unixsocket /run/redis/redis.sock
#### unixsocketperm 770
usermod -aG redis http
usermod -aG redis nextcloud
systemctl enable --now redis

## PHP
nano /etc/php/php.ini
#### date.timezone = America/Chicago
#### extension={bcmath,bz2,exif,gd,iconv,imap,intl,imagick,pdo_mysql}
#### memory_limit = 512M or higher
#### zend_extension=opcache
####
#### [opcache]
#### opcache.enable = 1
#### opcache.interned_strings_buffer = 8
#### opcache.max_accelerated_files = 10000
#### opcache.memory_consumption = 128
#### opcache.save_comments = 1
#### opcache.revalidate_freq = 1

## Nextcloud
nano /etc/webapps/nextcloud/config/config.php
# 'trusted_domains' =>
#   array (
#     0 => 'localhost',
#     1 => 'cloud.trwnh.com',
#   ),    
# 'overwrite.cli.url' => 'https://cloud.trwnh.com/',
# 'htaccess.RewriteBase' => '/',

install --owner=nextcloud --group=nextcloud --mode=700 -d /var/lib/nextcloud/sessions
localectl set-locale en_US.UTF-8
occ maintenance:install \
    --database=mysql \
    --database-name=nextcloud \
    --database-host=localhost:/run/mysqld/mysqld.sock \
    --database-user=nextcloud \
    --database-pass= \
    --admin-pass= \
    --admin-email= \
    --data-dir=/var/lib/nextcloud/data

## NGINX

# CTRL + ]]]
