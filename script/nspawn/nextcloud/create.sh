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

iptables -A FORWARD -i ve-+ -o internet0 -j ACCEPT
iptables -A INPUT -i ve-+ -p udp -m udp --dport 67 -j ACCEPT

mkdir /etc/systemd/nspawn
curl https://github.com/trwnh/arch/raw/main/script/nspawn/nextcloud/nextcloud.nspawn > /etc/systemd/nspawn/nextcloud.nspawn
