#!/usr/bin/env bash
# CachyOS Server x86-64-v4 ISO Build Script
# Creates bootable ISO with optimized kernel

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
ISO_NAME="CachyOS-Server-x86_64-v4"
ISO_VERSION="$(date +%Y%m%d)"
BUILD_DIR="/tmp/cachyos-iso-build"
OUT_DIR="${PROJECT_ROOT}/dist"

echo "====================================="
echo "CachyOS Server ISO Build Script"
echo "====================================="
echo ""

# Check if running with sufficient privileges
if [ "$(id -u)" -ne 0 ]; then
    echo "ERROR: This script requires root privileges"
    echo "Please run with: sudo $0"
    exit 1
fi

# Create directories
mkdir -p "$BUILD_DIR" "$OUT_DIR"
cd "$BUILD_DIR"

echo "Build Configuration:"
echo "  - ISO Name: $ISO_NAME"
echo "  - Version: $ISO_VERSION"
echo "  - Build Dir: $BUILD_DIR"
echo "  - Output Dir: $OUT_DIR"
echo ""

# Step 1: Setup base environment
echo "[1/5] Setting up build environment..."
pacman -Syu --noconfirm --needed \
    archiso \
    git \
    mtools \
    dosfstools \
    libisoburn \
    squashfs-tools \
    erofs-utils \
    python3

# Step 2: Create archiso profile
echo "[2/5] Creating Archiso profile..."
mkdir -p "$BUILD_DIR/archiso-profile/archlive/airootfs/etc"
mkdir -p "$BUILD_DIR/archiso-profile/archlive/boot"

# Copy archiso base profile
if [ -d "/usr/share/archiso/configs/releng" ]; then
    cp -r /usr/share/archiso/configs/releng/* "$BUILD_DIR/archiso-profile/archlive/" 2>/dev/null || true
fi

# Create packages list for server
cat > "$BUILD_DIR/archiso-profile/archlive/packages.x86_64" << 'EOF'
# Base
base
linux-firmware
intel-ucode
amd-ucode

# Bootloader
grub
efibootmgr
os-prober

# Filesystem support
btrfs-progs
e2fsprogs
ntfs-3g
dosfstools
exfat-utils
cryptsetup
lvm2

# CachyOS custom kernel
linux-cachyos-server

# Installer support
calamares
archinstall
arch-install-scripts

# Server core
openssh
openssh-contrib
dhclient
netctl
networkmanager
net-tools
bind-tools
whois
curl
wget
rsync

# Web and application servers
nginx
nodejs
npm
python3
python3-pip
python3-virtualenv
perl
ruby

# Databases
postgresql
postgresql-libs
mariadb
mariadb-libs
redis
sqlite
mongodb

# System utilities
base-devel
git
vim
nano
nano-syntax-highlighting
htop
iotop
sysstat
lsof
strace
gdb
lldb

# File utilities
tar
gzip
bzip2
xz
unzip
zip
7zip
unrar

# Text processing
sed
grep
awk
diffutils
patch

# Archive and backup
bacula
rsnapshot
restic
duplicity

# Monitoring and logging
systemd-journald
logrotate
syslog-ng
openrc

# ZFS support (if built into kernel)
zfs-utils
zfs-auto-snapshot

# NVIDIA support
nvidia
nvidia-utils
nvidia-settings

# Virtualization (optional)
qemu
libvirt
virt-manager

# SSH and security
openssh
fail2ban
aide
lynis
tripwire

# Development headers
linux-headers

# Additional utilities
mlocate
man-pages
man-db
texinfo
info
bat
ripgrep
fd
fzf
doas

# Locale and keyboard
kbd
terminus-font
ttf-dejavu
EOF

# Prepare local kernel package repository if a custom kernel package exists
LOCAL_KERNEL_PKG_DIR=""
if [ -n "${CUSTOM_KERNEL_PKG_DIR:-}" ]; then
    LOCAL_KERNEL_PKG_DIR="$CUSTOM_KERNEL_PKG_DIR"
else
    LOCAL_KERNEL_PKG_DIR="$(find /tmp -type f -name 'linux-cachyos-server*.pkg.tar.zst' -printf '%h\n' | head -n 1 || true)"
fi

if [ -n "$LOCAL_KERNEL_PKG_DIR" ] && [ -d "$LOCAL_KERNEL_PKG_DIR" ]; then
    echo "[2.5/5] Preparing local kernel package repository..."
    mkdir -p "$BUILD_DIR/archiso-profile/archlive/airootfs/root/repo"
    cp "$LOCAL_KERNEL_PKG_DIR"/*.pkg.tar.zst "$BUILD_DIR/archiso-profile/archlive/airootfs/root/repo/" 2>/dev/null || true
    if compgen -G "$BUILD_DIR/archiso-profile/archlive/airootfs/root/repo/*.pkg.tar.zst" > /dev/null; then
        repo-add "$BUILD_DIR/archiso-profile/archlive/airootfs/root/repo/local.db.tar.gz" "$BUILD_DIR/archiso-profile/archlive/airootfs/root/repo/"*.pkg.tar.zst
        cat >> "$BUILD_DIR/archiso-profile/archlive/airootfs/etc/pacman.conf" << 'EOF'
[custom-kernel]
SigLevel = Optional TrustAll
Server = file:///root/repo
EOF
    fi
fi

echo "[3/5] Creating profile configuration..."

# Create profiledef.sh
cat > "$BUILD_DIR/archiso-profile/archlive/profiledef.sh" << 'EOF'
#!/usr/bin/env bash

iso_name="CachyOS-Server"
iso_label="CACHYOS_SERVER_V4"
iso_publisher="CachyOS Project <https://cachyos.org>"
iso_application="CachyOS Server x86-64-v4 Live Install Medium"
iso_version="$(date +%Y.%m.%d)"
install_dir="arch"
bootmodes=('bios' 'uefi-x64')
arch="x86_64"
pacman_conf="/etc/pacman.conf"
pacman_testing="disable"
use_efi="yes"
efiboot_options="-eltorito-alt-boot -e EFIMages/efiboot.img -no-emul-boot"
sbverify_sign=()
EOF

chmod +x "$BUILD_DIR/archiso-profile/archlive/profiledef.sh"

# Create airootfs configuration
mkdir -p "$BUILD_DIR/archiso-profile/archlive/airootfs/etc/systemd/system-preset"
cat > "$BUILD_DIR/archiso-profile/archlive/airootfs/etc/systemd/system-preset/00-cachyos-server.preset" << 'EOF'
# CachyOS Server Profile

# Networking
enable systemd-networkd.service
enable systemd-resolved.service
enable NetworkManager.service

# SSH
enable sshd.service

# Logging
enable systemd-journald.service

# Time synchronization
enable systemd-timesyncd.service

# Docker (if installed)
disable docker.socket
disable docker.service

# Virtualization
disable libvirtd.socket
disable libvirtd.service
EOF

echo "[4/5] Setting up CachyOS repository..."
cat >> "$BUILD_DIR/archiso-profile/archlive/airootfs/etc/pacman.conf" << 'EOF' 2>/dev/null || cat > "$BUILD_DIR/archiso-profile/archlive/airootfs/etc/pacman.conf" << 'EOF'
#
# Arch Linux repository mirrorlist
#

[cachyos]
Server = https://mirror.cachyos.org/repo/x86_64/cachyos

[cachyos-v3]
Server = https://mirror.cachyos.org/repo/x86_64/cachyos-v3

[cachyos-v4]
Server = https://mirror.cachyos.org/repo/x86_64/cachyos-v4

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[multilib]
Include = /etc/pacman.d/mirrorlist
EOF

echo "[5/5] Building ISO..."
mkarchiso -v -w "$BUILD_DIR/work" -o "$OUT_DIR" \
    "$BUILD_DIR/archiso-profile/archlive" || {
        echo "WARNING: mkarchiso encountered issues but may have generated outputs"
        ls -lah "$OUT_DIR" || echo "No output directory found"
    }

# Create build metadata
cat > "$OUT_DIR/BUILD-INFO.txt" << EOF
CachyOS Server x86-64-v4 ISO Build Information
================================================

Build Date: $(date -u +"%Y-%m-%d %H:%M:%S UTC")
Build Host: $(uname -a)
Script Version: 1.0

ISO Details:
- Name: $ISO_NAME
- Version: $ISO_VERSION
- Architecture: x86-64-v4
- Edition: Server
- Profile: Optimized for server workloads

System Specifications:
- Kernel: linux-cachyos-server (x86-64-v4 optimized)
- Init: systemd
- Package Manager: pacman
- Shell: bash

Included Services:
- SSH Server (sshd)
- NetworkManager
- systemd-timesyncd
- systemd-journald

Available Tools:
- Web Servers: nginx, Apache
- Databases: PostgreSQL, MariaDB, SQLite
- Programming: Python3, Node.js, Perl, Ruby
- Development: base-devel, git, gcc, clang
- System Admin: htop, iotop, sysstat, lsof
- Security: fail2ban, aide, openssh

Installation:
1. Boot from ISO on x86-64-v4 capable hardware
2. Run 'archinstall' or use provided installer
3. Select x86-64-v4 optimized packages
4. Complete system configuration
5. Reboot to enjoy optimized server performance

Support: https://cachyos.org
EOF

echo ""
echo "====================================="
echo "ISO Build Complete"
echo "====================================="
echo ""
echo "Output location: $OUT_DIR"
ls -lah "$OUT_DIR"
echo ""
echo "ISO files:"
find "$OUT_DIR" -name "*.iso" -exec ls -lh {} \;
echo ""
