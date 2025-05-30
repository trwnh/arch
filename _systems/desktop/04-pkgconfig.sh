efibootmgr \
	--create \
	--disk /dev/nvme0n1 \
	--part 1 \
	--loader '\EFI\systemd\systemd-bootx64.efi' \
	--label 'systemd-boot' \
	--unicode

# copy/sync etc folder?