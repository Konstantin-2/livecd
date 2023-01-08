#!/bin/bash

# Uncomment this if you want create hardlinks instead of copying. It will be faster.
#if [ $(whoami) == 'root' ]; then
#    copy_param="-l";
#fi


rm -r initramfs
mkdir initramfs

mkdir initramfs/{dev,lib,usr,proc,sys,tmp,run}
mkdir initramfs/usr/bin
ln -s usr/bin initramfs/bin

# ПРОГРАММЫ

BINS="dash mount umount mkdir find basename modprobe setfont loadkeys"
BINS="$BINS ls ln rm cat openvt env bash mount.ntfs mount.ntfs-3g mkfs.ntfs"
copyso $copy_param --x64 -p $BINS initramfs
ln -s lib initramfs/lib64
ln -s x86_64-linux-gnu/ld-linux-x86-64.so.2 initramfs/lib/ld-linux-x86-64.so.2
cp $copy_param init initramfs/init
chmod +x initramfs/init
ln -s /usr/bin/dash initramfs/bin/sh

# DEB-ПАКЕТЫ

copy_deb()
{
	for F in $(cat /var/lib/dpkg/info/$1.list); do
		if [ -d $F ]; then
			mkdir -p initramfs$F
		elif [ -f $F ]; then
			copyso $copy_param --x64 /$F initramfs
		fi
	done
}
DEBS="mc"
for DEB in $DEBS; do
	copy_deb $DEB
done
rm -rf initramfs/usr/share/{applications,doc,doc-base,info,man,lintian,libc-bin,locale,menu,pixmaps}

# МОДУЛИ ЯДРА

KERVER=$(uname -r)
MODS="sr_mod sd_mod ahci mptspi"

# Для оптических и жестких дисков:
MODS="$MODS sg evdev ata_generic ata_piix libsas uas mptsas"
for m in $(find /lib/modules/$KERVER/kernel/drivers/ata/ -name 'sata*.ko'); do MODS="$MODS $(basename -s .ko $m)"; done

# Для SSD дисков:
for m in $(find /lib/modules/$KERVER/kernel/drivers/nvme/ -name '*.ko'); do MODS="$MODS $(basename -s .ko $m)"; done

# Файловые системы:
MODS="$MODS squashfs overlay ext4 vfat exfat fuse udf isofs loop hfsplus libcrc32c crc32c-intel crc32c_generic"

# Языковые кодировки файловых систем:
for m in $(find /lib/modules/$KERVER/kernel/fs/nls/ -name '*.ko'); do MODS="$MODS $(basename -s .ko $m)"; done

# USB:
MODS="$MODS ehci-pci ohci-pci uhci-hcd xhci-pci usbhid i2c-hid psmouse hid-generic"

# EFI:
MODS="$MODS efivarfs"

copyko $MODS initramfs/lib/modules/$KERVER
cp $copy_param /lib/modules/$KERVER/modules.builtin* initramfs/lib/modules/$KERVER
depmod -b initramfs

# НАСТРОЙКА КОНСОЛИ

mkdir -p initramfs/lib/{terminfo,locale}
cp -r $copy_param /lib/terminfo/l initramfs/lib/terminfo
cp -r $copy_param /usr/share/mc/{skins,syntax,mc.charsets,mc.lib} initramfs/usr/share/mc
mkdir -p initramfs/usr/lib/locale
cp  $copy_param/usr/lib/locale/locale-archive initramfs/usr/lib/locale
cp -r $copy_param /usr/share/tabset initramfs/usr/share
cp $(find /etc/console-setup -name '*.psf.gz' | head -n 1) initramfs/etc/font.psf.gz
cp $(find /etc/console-setup -name '*.kmap.gz' | head -n 1) initramfs/etc/keys.kmap.gz
gunzip initramfs/etc/font.psf.gz
gunzip initramfs/etc/keys.kmap.gz
mkdir -p initramfs/.config/mc
echo '[Midnight-Commander]' > initramfs/.config/mc/ini
echo 'use_internal_edit=true' >> initramfs/.config/mc/ini
