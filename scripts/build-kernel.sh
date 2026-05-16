#!/usr/bin/env bash
# CachyOS Server x86-64-v4 Kernel Build Script
# Optimizes PKGBUILD for x86-64-v4 server workloads

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"

echo "====================================="
echo "CachyOS Server x86-64-v4 Build Script"
echo "====================================="
echo ""

# Configuration
BUILD_TYPE="${1:-gcc}"  # gcc or clang
PROCESSOR_OPT="GENERIC_V4"
LINUX_CACHYOS_REPO="https://github.com/CachyOS/linux-cachyos.git"
TEMP_BUILD_DIR="/tmp/cachyos-build-$$"

echo "Build Configuration:"
echo "  - Build Type: $BUILD_TYPE"
echo "  - Processor: $PROCESSOR_OPT"
echo "  - Temp Directory: $TEMP_BUILD_DIR"
echo ""

# Create temporary build directory
mkdir -p "$TEMP_BUILD_DIR"
cd "$TEMP_BUILD_DIR"

# Clone linux-cachyos repository
echo "[1/5] Cloning CachyOS linux-cachyos repository..."
git clone --depth 1 "$LINUX_CACHYOS_REPO" linux-cachyos
cd linux-cachyos/linux-cachyos-server

# Backup original PKGBUILD
cp PKGBUILD PKGBUILD.orig

# Apply optimizations for x86-64-v4 server workload
echo "[2/5] Applying x86-64-v4 server optimizations..."

echo "  - Setting processor optimization to x86-64-v4..."
sed -i "s/_processor_opt:=/_processor_opt:=$PROCESSOR_OPT/" PKGBUILD

echo "  - Optimizing for server workloads..."
sed -i "s/_HZ_ticks:=300/_HZ_ticks:=100/" PKGBUILD  # 100Hz for servers
sed -i "s/_tickrate:=full/_tickrate:=full/" PKGBUILD
sed -i "s/_preempt:=lazy/_preempt:=full/" PKGBUILD
sed -i "s/_cc_harder:=yes/_cc_harder:=yes/" PKGBUILD  # Enhanced GCC optimizations
sed -i "s/_per_gov:=no/_per_gov:=yes/" PKGBUILD  # Performance governor

echo "  - Enabling server-focused features..."
sed -i "s/_build_zfs:=no/_build_zfs:=yes/" PKGBUILD
sed -i "s/_build_nvidia_open:=no/_build_nvidia_open:=yes/" PKGBUILD
sed -i "s/_build_r8125:=no/_build_r8125:=yes/" PKGBUILD
sed -i "s/_tcp_bbr3:=no/_tcp_bbr3:=yes/" PKGBUILD  # Better congestion control
sed -i "s/_cachy_config:=no/_cachy_config:=yes/" PKGBUILD
sed -i "s/_cpusched:=eevdf/_cpusched:=eevdf/" PKGBUILD  # EEVDF good for servers

echo "  - Configuring compiler..."
if [ "$BUILD_TYPE" = "clang" ]; then
    echo "    Using LLVM/Clang with Thin LTO..."
    sed -i "s/_use_llvm_lto:=none/_use_llvm_lto:=thin/" PKGBUILD
    sed -i "s/_use_kcfi:=no/_use_kcfi:=yes/" PKGBUILD  # kCFI for Clang
else
    echo "    Using GCC without LTO..."
    sed -i "s/_use_llvm_lto:=thin/_use_llvm_lto:=none/" PKGBUILD
fi

# Display configuration
echo ""
echo "[3/5] Build configuration summary:"
echo "---------------------------------------"
grep -E "^: \"\$\{_(processor_opt|HZ_ticks|tickrate|preempt|cc_harder|per_gov|build_zfs|build_nvidia|tcp_bbr3|cachy_config|cpusched|use_llvm_lto)" PKGBUILD | head -12
echo "---------------------------------------"
echo ""

# Show differences
echo "[4/5] Configuration changes applied:"
echo "  Differences from original:"
diff -u PKGBUILD.orig PKGBUILD | grep "^[+-]" | grep "^+" | head -15 || true
echo ""

echo "[5/5] Ready for build"
echo ""
echo "Next steps:"
echo "  1. Review the configuration above"
echo "  2. Run: cd '$TEMP_BUILD_DIR/linux-cachyos/linux-cachyos-server'"
echo "  3. Execute: makepkg --skipchecksums --syncdeps --noconfirm"
echo ""
echo "Build directory preserved at: $TEMP_BUILD_DIR"
echo ""
