#!/bin/bash
rm -r iso
mkdir iso

# Загрузчик UEFI
cp grub.cfg iso/grub.cfg
mkdir -p EFI/BOOT
grub-mkimage --prefix '' --config "grub-inst.cfg" -O x86_64-efi -o 'EFI/BOOT/bootx64.efi' acpi appleldr boot configfile efi_gop efi_uga elf fat fixvideo font gettext gfxmenu gfxterm gfxterm_background gfxterm_menu iso9660 linux memdisk minicmd normal part_gpt part_msdos search sleep usb video video_bochs video_cirrus video_fb videotest
mkdosfs -F12 -n "EFI" -C iso/efiboot.img 2048
mcopy -s -i iso/efiboot.img EFI ::
rm -r EFI

# Загрузчик BIOS
cp syslinux.cfg iso
cp /usr/lib/ISOLINUX/isolinux.bin iso
cp /usr/lib/syslinux/modules/bios/{ldlinux.c32,menu.c32,libutil.c32,libcom32.c32} iso

# Ядро
cp $(ls -t /boot/vmlinuz-$(uname -r) | head -n 1) iso/linux

# Фалы
cd initramfs
find . | cpio -o -H newc --owner=root.root | gzip -9 > ../iso/init.ram
cd ..

# Обзаз
xorriso -as mkisofs -r -o livecd.iso -isohybrid-mbr /usr/lib/ISOLINUX/isohdpfx.bin -partition_offset 16 -J -l -joliet-long -c boot.cat -b isolinux.bin -no-emul-boot -boot-load-size 4 -boot-info-table -eltorito-alt-boot -e efiboot.img -no-emul-boot -isohybrid-gpt-basdat iso
