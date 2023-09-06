DISTRO_NAME=PikaOS

DISTRO_VOLUME_LABEL=$(DISTRO_NAME) $(DISTRO_VERSION) amd64 Nvidia

# Packages to install
DISTRO_PKGS=\
	ubuntu-minimal \
	ubuntu-standard \
	ubuntu-keyring \
	pika-sources \
	systemd \
	zram-config \
	fonts-ubuntu \
	plymouth-theme-spinner \
	plymouth-theme-pika-text \
	pika-baseos \
	pika-amdgpu-core \
	pika-amdgpu-switcher \
	pika-gnome-desktop-minimal \
	pika-gnome-first-setup \
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
	open-vm-tools \
	open-vm-tools-desktop \
	f2fs-tools \
	xfsprogs \
	refind \
	nvidia-driver-535
	
# Packages to install after (to avoid dependency issues)
POST_DISTRO_PKGS=rsync

DISTRO_PARAMS+=modules_load=nvidia
DISTRO_PARAMS+=nvidia-drm.modeset=0
DISTRO_PARAMS+=amd_pstate=active

# Packages to have in live instance
LIVE_PKGS=\
	casper \
	expect \
	gparted \
	calamares-settings-pika-gnome

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
	yaru-theme-gnome-shell \
	tilix \
	apport

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
	plymouth-theme-spinner \
	plymouth \
	plymouth-label \
	pm-utils \
	postfix \
	powermgmt-base \
	python3-debian \
	python3-distro \
	python3-evdev \
	python3-systemd \
	vbetool \
	xbacklight \
	refind \
	mokutil \
	pika-refind-theme \
	booster
