#!/bin/bash

$ROOT = /mnt
$POOL = rpool

zpool import \
	-R $ROOT \
	$POOL
