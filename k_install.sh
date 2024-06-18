#!/bin/bash
VER=6.6.0-rc4+
rm -rf out
tar -xvf out.tar.gz
rm -rf /usr/lib/modules/$VER
cp -rf out/boot/* /boot
cp -rf out/modules/lib/modules/* /lib/modules
dracut -f /boot/initramfs-$VER.img $VER
grub2-mkconfig -o /boot/efi/EFI/openEuler/grub.cfg