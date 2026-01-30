#!/bin/bash

# Given:
# - the goal state is to pacstrap to some $ROOT
# - $POOL exists already
# - efi system partition already exists with partlabel $ESP_label
# When:
# - we create a new $DATASET like rpool/OS/arch-20260130 or whatever
# - we mark that $DATASET as the bootfs of the zpool (TODO: is this the right time to do this?)
# Then:
# - $ROOT contains a system ready for pacstrap

## extracted variables

$POOL = rpool
$OS = arch-$(date +%Y%m%d)
$DATASET = $POOL/OS/$OS

$ROOT = /mnt
$ESP_label = ESP

## instructions

zpool import \
	-R $ROOT \
	$POOL

zfs create \
	-o canmount=noauto
	-o mountpoint=/ \
	$DATASET

zpool set \
	bootfs=$DATASET \
	$POOL

zfs mount $DATASET
mkdir -p $ROOT/efi
mount -L $ESP_label $ROOT/efi
