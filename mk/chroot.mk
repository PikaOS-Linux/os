$(BUILD)/debootstrap:
	mkdir -p $(BUILD)

	# Remove old debootstrap
	sudo rm -rf "$@" "$@.partial"

	# Install using debootstrap
	if ! sudo debootstrap \
		--arch=amd64 \
		"$(UBUNTU_CODE)" \
		"$@.partial" \
		"$(UBUNTU_MIRROR)"; \
	then \
		cat "$@.partial/debootstrap/debootstrap.log"; \
		false; \
	fi

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/chroot: $(BUILD)/debootstrap
	# Unmount chroot if mounted
	scripts/unmount.sh "$@.partial"

	# Remove old chroot
	sudo rm -rf "$@" "$@.partial"

	# Copy chroot
	sudo cp -a "$<" "$@.partial"

	# Make temp directory for modifications
	sudo rm -rf "$@.partial/iso"
	sudo mkdir -p "$@.partial/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$@.partial/iso/chroot.sh"
	sudo cp "scripts/repos.sh" "$@.partial/iso/repos.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Install dependencies of chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"UPDATE=1 \
		UPGRADE=1 \
		INSTALL=\"--no-install-recommends gnupg software-properties-common adwaita-icon-theme humanity-icon-theme amdgpu-drm \" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Clean APT sources
	sudo truncate --size=0 "$@.partial/etc/apt/sources.list"

	# Run chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"UPDATE=1 \
		UPGRADE=1 \
		INSTALL=\"$(DISTRO_PKGS)\" \
		LANGUAGES=\"$(LANGUAGES)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"
 
	# Rerun chroot script to install POST_DISTRO_PKGS
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"INSTALL=\"$(POST_DISTRO_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/chroot.tag: $(BUILD)/chroot
	sudo $(CHROOT) "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"

$(BUILD)/live: $(BUILD)/chroot
	# Unmount chroot if mounted
	scripts/unmount.sh "$@.partial"

	# Remove old chroot
	sudo rm -rf "$@" "$@.partial"

	# Copy chroot
	sudo cp -a "$<" "$@.partial"

	# Make temp directory for modifications
	sudo rm -rf "$@.partial/iso"
	sudo mkdir -p "$@.partial/iso"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$@.partial/iso/chroot.sh"

	# Copy console-setup script
	sudo cp "scripts/console-setup.sh" "$@.partial/iso/console-setup.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Copy GPG public key for APT CDROM
	mkdir -p "$@.partial/iso"
	touch "$@.partial/iso/apt-cdrom.key"
	apt-key exportall > "$@.partial/iso/apt-cdrom.key"

	# Copy ubuntu-drivers-common default prime-discrete configuration
	sudo cp "data/prime-discrete" "$@.partial/etc/prime-discrete"

	# Run chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"KEY=\"/iso/apt-cdrom.key\" \
		INSTALL=\"$(LIVE_PKGS)\" \
		PURGE=\"$(RM_PKGS)\" \
		AUTOREMOVE=1 \
		CLEAN=1 \
		/iso/chroot.sh"

	# Remove undesired casper script
	if [ -e "$@.partial/usr/share/initramfs-tools/scripts/casper-bottom/01integrity_check" ]; then \
		sudo rm -f "$@.partial/usr/share/initramfs-tools/scripts/casper-bottom/01integrity_check"; \
	fi

	# Update apt cache
	sudo $(CHROOT) "$@.partial" /usr/bin/apt-get update

	# Update appstream cache
	if [ -e "$@.partial/usr/bin/appstreamcli" ]; then \
		sudo $(CHROOT) "$@.partial" /usr/bin/appstreamcli refresh-cache --force; \
	fi

	# Update fwupd cache
	if [ -e "$@.partial/usr/bin/fwupdtool" ]; then \
		sudo $(CHROOT) "$@.partial" /usr/bin/fwupdtool refresh --force; \
	fi

	# Run console-setup script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"/iso/console-setup.sh"

	# Create missing network-manager file
	if [ -e "$@.partial/etc/NetworkManager/conf.d" ]; then \
		sudo touch "$@.partial/etc/NetworkManager/conf.d/10-globally-managed-devices.conf"; \
	fi

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	sudo rm -rf "$@.partial"/root/.launchpadlib

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"

$(BUILD)/live.tag: $(BUILD)/live
	sudo $(CHROOT) "$<" /bin/bash -e -c "dpkg-query -W --showformat='\$${Package}\t\$${Version}\n'" > "$@"

$(BUILD)/pool: $(BUILD)/chroot
	# Unmount chroot if mounted
	scripts/unmount.sh "$@.partial"

	# Remove old chroot
	sudo rm -rf "$@" "$@.partial"

	# Copy chroot
	sudo cp -a "$<" "$@.partial"

	# Make temp directory for modifications
	sudo rm -rf "$@.partial/iso"
	sudo mkdir -p "$@.partial/iso"

	# Create pool directory
	sudo mkdir -p "$@.partial/iso/pool"

	# Copy chroot script
	sudo cp "scripts/chroot.sh" "$@.partial/iso/chroot.sh"

	# Mount chroot
	"scripts/mount.sh" "$@.partial"

	# Run chroot script
	sudo $(CHROOT) "$@.partial" /bin/bash -e -c \
		"MAIN_POOL=\"$(MAIN_POOL)\" \
		RESTRICTED_POOL=\"$(RESTRICTED_POOL)\" \
		CLEAN=1 \
		/iso/chroot.sh"

	# Unmount chroot
	"scripts/unmount.sh" "$@.partial"

	sudo rm -rf "$@.partial"/root/.launchpadlib

	# Save package pool
	sudo mv "$@.partial/iso/pool" "$@.partial/pool"

	# Remove temp directory for modifications
	sudo rm -rf "$@.partial/iso"

	sudo touch "$@.partial"
	sudo mv "$@.partial" "$@"
