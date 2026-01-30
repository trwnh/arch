#!/bin/sh

## variables

HOSTNAME="desktop"
TIMEZONE="America/Chicago"

## instructions

pacstrap /mnt base base-devel

# TODO: consider loading from repo instead of writing from scratch?
# TODO: extract variables for labels (fslabels? partlabels? which does LABEL= pull from?)
cat > /mnt/etc/fstab <<EOF 
LABEL=ESP /efi vfat rw,relatime,fmask=0077,dmask=0077,codepage=437,iocharset=ascii,shortname=mixed,utf8,errors=remount-ro 0 2
LABEL=SWAP none swap defaults 0 0
EOF

# TODO: is there a better way to set hostname now?
cat <<EOF > /mnt/etc/hostname
$HOSTNAME
EOF

cat <<EOF > /mnt/etc/hosts
127.0.0.1 localhost
::1 localhost
127.0.1.1 $HOSTNAME.local $HOSTNAME
EOF


# TODO: is there a better way to set timezone now?
arch-chroot /mnt ln -sf /usr/share/zoneinfo/$TIMEZONE /etc/localtime


# TODO: is there a better way to manage this locale patch? maybe a patch file? maybe in the repo?
cp /mnt/usr/share/i18n/locales/en_US /mnt/usr/share/i18n/locales/en_US@a
sed -i -e 's/"English locale for the USA"/"English locale for the USA \(24h ymd\)"/' /mnt/usr/share/i18n/locales/en_US@a
sed -i -e 's/"1.0"/"1.0a"/' /mnt/usr/share/i18n/locales/en_US@a
sed -i -e 's/"2000-06-24"/"2025-02-23"/' /mnt/usr/share/i18n/locales/en_US@a
sed -i -e 's/^d_t_fmt "%a %d %b %Y %r %Z"$/d_t_fmt "%a %Y %b %d %r %Z"/' /mnt/usr/share/i18n/locales/en_US@a
sed -i -e 's/^d_fmt   "%m\/\/%d\/\/%Y"$/d_fmt   "%Y\/\/%m\/\/%d"/' /mnt/usr/share/i18n/locales/en_US@a
sed -i -e 's/^t_fmt   "%r"$/t_fmt   "%R"/' /mnt/usr/share/i18n/locales/en_US@a
sed -i -e 's/^date_fmt "%a %b %e %r %Z %Y"$/date_fmt "%a %Y %b %e %r %Z"/' /mnt/usr/share/i18n/locales/en_US@a

cat <<EOF > /mnt/etc/locale.gen
en_US.UTF-8 UTF-8
ar_JO.UTF-8 UTF-8
en_US.UTF-8@a UTF-8
EOF

arch-chroot /mnt locale-gen

cat <<EOF > /mnt/etc/locale.conf
LANG=en_US.UTF-8
LC_COLLATE=C.UTF-8
LC_TIME=en_US.UTF-8@a
EOF
