#!/bin/bash

ARCH=amd64
RELEASE=3
DESKTOP=Gnome
ISO_IMAGE=PikaOS-nvidia-$DESKTOP-$RELEASE-$ARCH-$(date '+%y.%m.%d')

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
cp ./Makefiles/nvidia ./Makefile
make

mkdir -p builds/
mv build/pikaos/3/pikaos_3*.iso builds/"$ISO_IMAGE".iso  || exit 7
cd builds
touch "$ISO_IMAGE".md5
md5sum "$ISO_IMAGE".iso > "$ISO_IMAGE".md5

rsync -azP ./ ferreo@direct.pika-os.com:/srv/www/pikaiso/
