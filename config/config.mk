DISTRO_NAME=PikaOS

DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64 Intel

# Packages to install
DISTRO_PKGS=\
	ubuntu-minimal \
	ubuntu-standard \
	ubuntu-keyring \
	pika-sources \
	update-systemd-boot \
	systemd-boot \
	systemd \
	zram-config \
	plymouth-theme-spinner \
	plymouth-theme-pika-text \
	pika-baseos \
	pika-amdgpu-core \
	pika-amdgpu-switcher \
	pika-gnome-desktop-minimal \
	dbus-x11 \
	rsync \
	apt-utils \
	dosfstools \
	intel-microcode \
	amd64-microcode \
	linux-firmware \
	firmware-sof-signed \
	iucode-tool \
	setserial \
	git \
	wireguard-modules \
	kernel-pika \
	open-vm-tools
	
# Packages to install after (to avoid dependency issues)
POST_DISTRO_PKGS=rsync

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	expect \
	gparted \
	calamares-settings-pika

# Packages to remove from installed system (usually installed as Recommends)
RM_PKGS=\
	ibus-mozc \
	imagemagick-6.q16 \
	irqbalance \
	mozc-utils-gui \
	snapd \
	ubuntu-session \
	ubuntu-wallpapers \
	unattended-upgrades \
	xul-ext-ubufox \
	yaru-theme-gnome-shell

# Packages not installed, but that may need to be discovered by the installer
MAIN_POOL=\
	at \
	dfu-programmer \
	efibootmgr \
	ethtool \
	grub-efi-amd64 \
	grub-efi-amd64-bin \
	grub-efi-amd64-signed \
	grub2-common \
	grub-pc \
	grub-pc-bin \
	grub-gfxpayload-lists \
	libfl2 \
	libx86-1 \
	lm-sensors \
	pm-utils \
	postfix \
	powermgmt-base \
	python3-debian \
	python3-distro \
	python3-evdev \
	python3-systemd \
	vbetool \
	xbacklight \
	update-systemd-boot \
	systemd-boot \
	systemd
