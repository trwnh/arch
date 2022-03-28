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

cat <<EOF >> /etc/webapps/nextcloud/php.ini
date.timezone = America/Chicago
extension=bcmath
extension=bz2
extension=exif
extension=gd
extension=iconv
extension=imagick
extension=intl
EOF

echo "NEXTCLOUD_PHP_CONFIG=/etc/webapps/nextcloud/php.ini" >> /etc/environment

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

mkdir -p /var/log/php-fpm/access
curl https://raw.githubusercontent.com/trwnh/arch/main/script/nspawn/nextcloud/php-fpm.pool > /etc/php/php-fpm.d/nextcloud.conf


systemctl edit php-fpm
# [Service]
# ExecStart=
# ExecStart=/usr/bin/php-fpm --nodaemonize --fpm-config /etc/php/php-fpm.conf --php-ini /etc/php/php-fpm.ini
# ReadWritePaths=/var/lib/nextcloud
# ReadWritePaths=/etc/webapps/nextcloud/config

systemctl enable --now php-fpm

# Nextcloud ================================================
nano /etc/webapps/nextcloud/config/config.php
# 'trusted_domains' =>
#   array (
#     0 => 'localhost',
#     1 => 'cloud.trwnh.com',
#   ),    
# 'overwrite.cli.url' => 'https://cloud.trwnh.com/',
# 'htaccess.RewriteBase' => '/',

# 'filelocking.enabled' => true,
# 'memcache.locking' => '\OC\Memcache\Redis',
# 'redis' => array(
#      'host' => '/run/redis/redis.sock',
#      'port' => 0,
#      'timeout' => 0.0,
#       ),

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
    
systemctl edit nextcloud-cron
# [Service]
# ExecStart=
# ExecStart=/usr/bin/php -c /etc/webapps/nextcloud/php.ini -f /usr/share/webapps/nextcloud/cron.php
systemctl enable nextcloud-cron.timer

# NGINX ================================================

nano /etc/nginx/nginx.conf
# include

mkdir /etc/nginx/ssl
openssl req  -nodes -new -x509 -keyout /etc/nginx/ssl/nextcloud.key -out /etc/nginx/ssl/nextcloud.cert -sha256 -days 365

mkdir /etc/nginx/sites
curl https://github.com/trwnh/arch/raw/main/script/nspawn/nextcloud/nginx.conf > /etc/nginx/sites/nextcloud.conf

# CTRL + ]]]
