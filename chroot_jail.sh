#!/bin/bash

# How to make a chroot jail

sudo mkdir /mnt/chroot
sudo mount --bind /dev /mnt/chroot/dev
sudo mount --bind /proc /mnt/chroot/proc
sudo mount --bind /sys /mnt/chroot/sys
sudo mount --bind /etc/resolv.conf /mnt/chroot/etc/resolv.conf
