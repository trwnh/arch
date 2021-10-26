# arch
install/config commands for arch linux for self-reference

# assumptions
- UEFI/GPT/SSD on one drive only
- ext4 filesystem for / (or zfs rpool)
- systemd-boot (or refind if installing on zfs)
- only one system installed per drive (no dual boot from same drive by default)
- `yay` as AUR helper (since `packer` has stalled and been renamed `packer-aur`, after `packer-io` has been renamed to `packer`)
