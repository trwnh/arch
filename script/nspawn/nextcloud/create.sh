#!/bin/bash

DIR=/var/lib/machines/nextcloud

mkdir $DIR
pacstrap -c $DIR base sudo nano \
  nextcloud \
  php php-fpm \
  mariadb \
  redis php-redis \
  php-gd php-imagick ffmpeg libreoffice-fresh \
  smbclient php-intl php-imap curl python

cat "pts/0" >> $DIR/etc/securetty

curl https://github.com/trwnh/arch/raw/main/script/nspawn/nextcloud/nextcloud.nspawn > /etc/systemd/nspawn/nextcloud.nspawn
