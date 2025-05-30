#!/bin/sh

USERNAME="a"

pacman -S sudo

useradd \
	-G wheel \  # add to admins
	-c "a" \  # comment
	-d /home/a -M \  # set home directory but do not create it
	-s /bin/bash \  # set shell
	$USERNAME  # set username

mkdir /tmp/build
chmod -R 777 /tmp/build
cd /tmp/build
sudo -u nobody git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
sudo -u nobody makepkg
pacman -U --noconfirm *.pkg.tar.*

sed -e 's/#.*$//g' -e '/^$/d' -e 's/\s//g' packages.txt | sudo -u $USERNAME yay -S - --needed
rsync -avizP etc/ /etc