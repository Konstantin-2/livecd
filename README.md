# Linux Live CD
Create custom small Linux live CD. Stripts are to run on Debian.

# Usage
1. Install deb packages: grub-efi-amd64-bin dosfstools mtools isolinux syslinux-common console-setup.
1. Install [copyso](https://github.com/Konstantin-2/copyso) and [copyko](https://github.com/Konstantin-2/copyko)
2. Download these files.
3. Run *1.mkinitramfs.sh*. *initramfs* directory will be created.
4. Edit *initramfs* directory as you wish.
5. Run *2.mkiso.sh*. *livecd.iso* file will be created.
6. Copy *livecd.iso* to your flash with *dd* command or burn to CD with *wodim* command.

## Install deb packages
apt install grub-efi-amd64-bin dosfstools mtools isolinux syslinux-common console-setup

## Copy iso file to flash drive
dd if=livecd.iso of=/dev/sdz

Here /dev/sdz is the flash drive, not a partition like /dev/sdz1.

## Restore flash drive
wipefs -a /dev/sdz
mkfs.exfat /dev/sdz
