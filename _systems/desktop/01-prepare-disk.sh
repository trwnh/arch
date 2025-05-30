#!/bin/sh

# === Run this in a live ISO environment

# sgdisk -Z $DEV
# parted -s $DEV mklabel gpt
# sgdisk -n 1:0:+2G -t 1:ef00 -c 1:"EFI" $DEV \
#        -n 2:0:+2G -t 2:0082 -c 2:"SWAP" $DEV \
#        -n 3:0:0 -t 3:bf00 -c 3:"ROOT" $DEV \
# sleep 3
# partprobe $DEV
# sleep 3
# mkfs.fat -F32 -n "ESP" /dev/disk/by-partlabel/EFI

zpool create -f \
	-o ashift=12              \
	-O acltype=posixacl       \
	-O relatime=on            \
	-O xattr=sa               \
	-O dnodesize=legacy       \
	-O normalization=formD    \
	-O mountpoint=none        \
	-O canmount=off           \
	-O devices=off            \
	-O compression=lz4        \
	# -O encryption=aes-256-gcm \
	# -O keyformat=passphrase   \
	# -O keylocation=prompt     \
	-R /mnt                   \
rpool /dev/disk/by-partlabel/ROOT

zfs create -o canmount=off -o mountpoint=none rpool/OS
zfs create -o canmount=noauto -o mountpoint=/ rpool/OS/arch
zpool set bootfs=rpool/OS/arch rpool

zfs mount rpool/OS/arch
mkdir -p /mnt/efi
mount -L ESP /mnt/efi

pacstrap /mnt base base-devel