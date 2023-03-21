#!/bin/bash

ARCH=amd64
RELEASE=2210
DESKTOP=Gnome
ISO_IMAGE=PikaOS-$DESKTOP-$RELEASE-$ARCH_$(date '+%y.%m.%d')

gpg --keyserver keyserver.ubuntu.com --recv-keys 204DD8AEC33A7AFF

apt install --yes --option Acquire::Retries=5 --option Acquire::http::Timeout=100 \
    sudo \
    debootstrap \
    germinate \
    grub-efi-amd64-bin \
    grub-pc-bin \
    isolinux \
    mtools \
    ovmf \
    qemu-efi \
    qemu-kvm \
    squashfs-tools \
    erofs-utils \
    xorriso \
    zsync \
    build-essential \
    apt-utils \
    dosfstools \
    git \
    coreutils
    

echo "Building: $ISO_IMAGE".iso
make

mkdir -p builds/
mv build/pikaos/22.10/PikaOS_22*.iso builds/"$ISO_IMAGE".iso
cd builds
touch "$ISO_IMAGE".md5
md5sum "$ISO_IMAGE".iso > "$ISO_IMAGE".md5
