#!/usr/bin/env bash

set -e -x

export DEBIAN_FRONTEND=noninteractive
export HOME=/root
export LC_ALL=C

# Generate a machine ID
if [ -n "$(which dbus-uuidgen)" ]
then
    dbus-uuidgen > /etc/machine-id
    ln -sf /etc/machine-id /var/lib/dbus/machine-id
fi

if [ ! -f /run/systemd/resolve/stub-resolv.conf ]
then
    mkdir -p /run/systemd/resolve
    echo "nameserver 1.1.1.1" > /run/systemd/resolve/stub-resolv.conf
fi

# Correctly specify resolv.conf
ln -sf ../run/systemd/resolve/stub-resolv.conf /etc/resolv.conf

# Enable i386 so that steam is installable out of the box
dpkg --add-architecture i386

# Add APT key
if [ -n "${KEY}" ]
then
    echo "Adding APT key: ${KEY}"
    apt-key add "${KEY}"
fi

# Install PikaOS sources
apt install wget -y
wget https://ppa.pika-os.com/dists/lunar/pika-sources.deb
sudo apt install ./pika-sources.deb --yes --option Acquire::Retries=5 --option Acquire::http::Timeout=100 --option Dpkg::Options::="--force-confnew"
rm -rf ./pika-sources.deb
apt-get update -y

# Actions to do before DISTRO_PKGS
sudo apt install initramfs-tools adwaita-icon-theme humanity-icon-theme amdgpu-drm --yes --option Acquire::Retries=5
sudo apt install update-notifier --yes --option Acquire::Retries=5
sudo apt install update-manager --yes --option Acquire::Retries=5
sudo apt install ubuntu-release-upgrader-gtk --yes --option Acquire::Retries=5
sudo mkdir -p /usr/lib/firmware/
if echo "${INSTALL}" | grep nvidia-driver
then
    sudo apt install  nvidia-kernel-common-535  --yes --option Acquire::Retries=5
    sudo apt install  kernel-pika  --yes --option Acquire::Retries=5
    ls /usr/src
    ls /boot
    sudo apt install  nvidia-dkms-535  --yes --option Acquire::Retries=5 || echo "Workaround: Link chroot kernel to host kernel..."
    ln -sfv /boot/config-6.5.0-pikaos /boot/config-$(uname -r)
    ln -sfv /boot/initrd.img-6.5.0-pikaos /boot/initrd.img-$(uname -r)
    ln -sfv /usr/src/linux-headers-6.5.0-pikaos /usr/src/linux-headers-$(uname -r)
    ln -sfv /boot/System.map-6.5.0-pikaos /boot/System.map-$(uname -r)
    ln -sfv /boot/vmlinuz-6.5.0-pikaos /boot/vmlinuz-$(uname -r)
    sudo dpkg --configure nvidia-dkms-535 && sudo apt-get install -yf
fi

# Update package definitions
if [ -n "${UPDATE}" ]
then
    apt-get update -y
fi

# Upgrade installed packages
if [ -n "${UPGRADE}" ]
then
    apt-get upgrade -y --allow-downgrades
fi

# Install packages
if [ -n "${INSTALL}" ]
then
    echo "Installing packages: ${INSTALL}"
    apt-get install -y ${INSTALL}
fi

if [ -n "${LANGUAGES}" ]
then
    pkgs=""
    for language in ${LANGUAGES}
    do
        echo "Adding language '$language'"
        pkgs+=" $(XDG_CURRENT_DESKTOP=GNOME check-language-support --show-installed --language="$language")"
    done
    if [ -n "$pkgs" ]
    then
        apt-get install -y $pkgs
    fi
fi

# Remove packages
if [ -n "${PURGE}" ]
then
    echo "Removing packages: ${PURGE}"
    apt-get purge -y ${PURGE}
fi

# Remove unnecessary packages
if [ -n "${AUTOREMOVE}" ]
then
    apt-get autoremove --purge -y
fi

# Download main pool packages
if [ -n "${MAIN_POOL}" ]
then
    mkdir -p "/iso/pool/main"
    chown -R _apt "/iso/pool/main"
    pushd "/iso/pool/main"
        apt-get download ${MAIN_POOL}
    popd
fi

# Download restricted pool packages
if [ -n "${RESTRICTED_POOL}" ]
then
    mkdir -p "/iso/pool/restricted"
    chown -R _apt "/iso/pool/restricted"
    pushd "/iso/pool/restricted"
        apt-get download ${RESTRICTED_POOL}
    popd
fi

# Remove apt files
if [ -n "${CLEAN}" ]
then
    apt-get clean -y
fi

# Remove temporary files
rm -rf /tmp/*

# Remove machine ID
rm -f /var/lib/dbus/machine-id
