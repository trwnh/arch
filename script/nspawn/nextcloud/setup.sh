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

mkdir -p /var/log/php-fpm/access
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
nano /etc/nginx/sites/nextcloud.conf
# upstream php-handler {
#     server unix:/run/php-fpm/nextcloud.sock;
# }
# map $arg_v $asset_immutable {
#     "" "";
#     default "immutable";
# }
# server {
#     listen 80;
#     listen [::]:80;
#     server_name _;
#     return 301 https://$host$request_uri;
# }
# server {
#     listen 443      ssl http2;
#     listen [::]:443 ssl http2;
#     server_name _;
#     root /usr/share/webapps/nextcloud;
#     ssl_certificate     /etc/ssl/nginx/nextcloud.crt;
#     ssl_certificate_key /etc/ssl/nginx/nextcloud.key;
#     client_max_body_size 2048M;
#     client_body_timeout 1200s;
#     fastcgi_buffers 64 4K;
#     gzip on;
#     gzip_vary on;
#     gzip_comp_level 4;
#     gzip_min_length 256;
#     gzip_proxied expired no-cache no-store private no_last_modified no_etag auth;
#     gzip_types application/atom+xml application/javascript application/json application/ld+json application/manifest+json application/rss+xml application/vnd.geo+json application/vnd.ms-fontobject application/wasm application/x-font-ttf application/x-web-app-manifest+json application/xhtml+xml application/xml font/opentype image/bmp image/svg+xml image/x-icon text/cache-manifest text/css text/plain text/vcard text/vnd.rim.location.xloc text/vtt text/x-component text/x-cross-domain-policy;
#     add_header Referrer-Policy                      "no-referrer"   always;
#     add_header X-Content-Type-Options               "nosniff"       always;
#     add_header X-Download-Options                   "noopen"        always;
#     add_header X-Frame-Options                      "SAMEORIGIN"    always;
#     add_header X-Permitted-Cross-Domain-Policies    "none"          always;
#     add_header X-Robots-Tag                         "none"          always;
#     add_header X-XSS-Protection                     "1; mode=block" always;
#     fastcgi_hide_header X-Powered-By;
#     index index.php index.html /index.php$request_uri;
#     location = / {
#         if ( $http_user_agent ~ ^DavClnt ) {
#             return 302 /remote.php/webdav/$is_args$args;
#         }
#     }
#     location = /robots.txt {
#         allow all;
#         log_not_found off;
#         access_log off;
#     }
#     location ^~ /.well-known {
#         location = /.well-known/carddav { return 301 /remote.php/dav/; }
#         location = /.well-known/caldav  { return 301 /remote.php/dav/; }
#         location /.well-known/acme-challenge    { try_files $uri $uri/ =404; }
#         location /.well-known/pki-validation    { try_files $uri $uri/ =404; }
#         return 301 /index.php$request_uri;
#     }
#     location ~ ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)  { return 404; }
#     location ~ ^/(?:\.|autotest|occ|issue|indie|db_|console)                { return 404; }
#     location ~ \.php(?:$|/) {
#         rewrite ^/(?!index|remote|public|cron|core\/ajax\/update|status|ocs\/v[12]|updater\/.+|oc[ms]-provider\/.+|.+\/richdocumentscode\/proxy) /index.php$request_uri;
#         fastcgi_split_path_info ^(.+?\.php)(/.*)$;
#         set $path_info $fastcgi_path_info;
#         try_files $fastcgi_script_name =404;
#         include fastcgi_params;
#         fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
#         fastcgi_param PATH_INFO $path_info;
#         fastcgi_param HTTPS on;
#         fastcgi_param modHeadersAvailable true;         # Avoid sending the security headers twice
#         fastcgi_param front_controller_active true;     # Enable pretty urls
#         fastcgi_pass php-handler;
#         fastcgi_intercept_errors on;
#         fastcgi_request_buffering off;
#         fastcgi_max_temp_file_size 0;
#     }
#     location ~ \.(?:css|js|svg|gif|png|jpg|ico|wasm|tflite|map)$ {
#         try_files $uri /index.php$request_uri;
#         add_header Cache-Control "public, max-age=15778463, $asset_immutable";
#         access_log off;
#         location ~ \.wasm$ {
#             default_type application/wasm;
#         }
#     }
#     location ~ \.woff2?$ {
#         try_files $uri /index.php$request_uri;
#         expires 7d;
#         access_log off;
#     }
#     location /remote {
#         return 301 /remote.php$request_uri;
#     }
#     location / {
#         try_files $uri $uri/ /index.php$request_uri;
#     }
# }

# CTRL + ]]]
