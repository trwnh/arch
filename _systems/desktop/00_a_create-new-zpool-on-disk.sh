#!/bin/bash

# Scenario: Use entire disk
# Given:
# - goal state is to have a $DISK layout ready for mounting a new $ROOT
# When:
# - we zap the gpt structure
# - we create partition layout on $DISK
# Then:
# - 

## extracted variables

$DISK = /dev/nvme0n1
$ESP_name = ESP
$POOL = rpool
$OS = arch-$(date +%Y%m%d)
$DATASET = $POOL/OS/$OS

## instructions

sgdisk -Z $DISK
parted -s $DISK mklabel gpt
sgdisk \
	-n 1:0:+2G -t 1:ef00 -c 1:"EFI" $DISK \
	-n 2:0:+2G -t 2:0082 -c 2:"SWAP" $DISK \
	-n 3:0:0 -t 3:bf00 -c 3:"ROOT" $DISK \
	sleep 3
partprobe $DISK
sleep 3

mkfs.fat -F32 -n $ESP_name /dev/disk/by-partlabel/EFI

zpool create -f \
	-o ashift=12              \
	-o autotrim=on            \
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
$POOL /dev/disk/by-partlabel/ROOT
