#!/bin/bash

# systemd-nspawn -D /var/lib/machines/nextcloud
# passwd
# logout

# systemd-nspawn -b -D /var/lib/machines/nextcloud

# MariaDB ================================================
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

## Redis ================================================
nano /etc/redis/redis.conf
# port 0
# unixsocket /run/redis/redis.sock
# unixsocketperm 770

usermod -aG redis http
usermod -aG redis nextcloud
systemctl enable --now redis

# PHP ================================================
cp /etc/php/php.ini /etc/webapps/nextcloud/php.ini
chown nextcloud:nextcloud /etc/webapps/nextcloud/php.ini
echo "NEXTCLOUD_PHP_CONFIG=/etc/webapps/nextcloud/php.ini" >> /etc/environment
nano /etc/webapps/nextcloud/php.ini
# date.timezone = America/Chicago
# extension=bcmath
# extension=bz2
# extension=exif
# extension=gd
# extension=iconv
# extension=imagick
# extension=intl

cp /etc/php/php.ini /etc/php/php-fpm.ini
nano /etc/php/php-fpm.ini
# zend_extension=opcache
#
# [opcache]
# opcache.enable = 1
# opcache.interned_strings_buffer = 8
# opcache.max_accelerated_files = 10000
# opcache.memory_consumption = 128
# opcache.save_comments = 1
# opcache.revalidate_freq = 1

nano /etc/php/php-fpm.d/nextcloud.conf
# [nextcloud]
# user = nextcloud
# group = nextcloud
# listen = /run/php-fpm/nextcloud.sock
# listen.owner = nextcloud
# listen.group = http
# listen.mode = 0660
# pm = dynamic
# pm.max_children = 5
# pm.start_servers = 2
# pm.min_spare_servers = 1
# pm.max_spare_servers = 3
# access.log = /var/log/php-fpm/access/$pool.log
# access.format = "%{%Y-%m-%dT%H:%M:%S%z}t %R: \"%m %r%Q%q\" %s %f %{milli}d %{kilo}M %C%%"
# chdir = /usr/share/webapps/$pool
# env[HOSTNAME] = $HOSTNAME
# env[PATH] = /usr/local/bin:/usr/bin
# env[TMP] = /tmp
# env[TMPDIR] = /tmp
# env[TEMP] = /tmp
# php_value[session.save_path] = /var/lib/$pool/sessions
# php_value[session.gc_maxlifetime] = 21600
# php_value[session.gc_divisor] = 500
# php_value[session.gc_probability] = 1
# php_flag[expose_php] = false
# php_value[post_max_size] = 2048M
# php_value[upload_max_filesize] = 2048M
# php_flag[output_buffering] = off
# php_value[max_input_time] = 120
# php_value[max_execution_time] = 60
# php_value[memory_limit] = 1024M
# php_value[extension] = bcmath
# php_value[extension] = bz2
# php_value[extension] = exif
# php_value[extension] = gd
# php_value[extension] = gmp
# php_value[extension] = imagick
# php_value[extension] = imap
# php_value[extension] = intl
# php_value[extension] = iconv
# php_value[extension] = pdo_mysql
# php_value[extension] = redis

systemctl edit php-fpm
# [Service]
# ExecStart=
# ExecStart=/usr/bin/php-fpm --nodaemonize --fpm-config /etc/php/php-fpm.conf --php-ini /etc/php/php-fpm.ini
# ReadWritePaths=/var/lib/nextcloud
# ReadWritePaths=/etc/webapps/nextcloud/config

# Nextcloud ================================================
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

# NGINX ================================================

# CTRL + ]]]
