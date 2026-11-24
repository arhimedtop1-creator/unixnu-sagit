#!/usr/bin/env bash
# One-time Fedora host setup for the UniXNU sagit self-hosted runner.
# Run as the normal desktop user; sudo is used only for dnf and toolchain shims.
set -euo pipefail

if ! command -v dnf >/dev/null 2>&1; then
  echo "This setup script targets Fedora (dnf)." >&2
  exit 1
fi

sudo dnf install -y \
  git curl patch xz make gcc gcc-c++ nasm acpica-tools flex bison cmake ninja-build \
  llvm-devel clang-devel tcsh unifdef mtools dosfstools dtc python3 python3-pip \
  python3-pillow python3-GitPython python3-setuptools gettext uuid-devel iasl \
  openssl-devel zlib-devel libbsd-devel libuuid-devel pkgconf-pkg-config \
  bzip2 cpio rsync wget

mkdir -p "$HOME/.cache"
SETUP_SRC="$HOME/.cache/unixnu-setup-src"
if [[ ! -f "$SETUP_SRC/scripts/linux/setup-toolchain.py" ]]; then
  rm -rf "$SETUP_SRC"
  git clone --depth 1 https://github.com/UniXNU/UniXNU.git "$SETUP_SRC"
fi

# This is the expensive one-time build. The result is reused by every workflow run.
sudo env UNIXNU_TOOLCHAIN="$HOME/.cache/unixnu-toolchain" \
  python3 "$SETUP_SRC/scripts/linux/setup-toolchain.py" \
  "$HOME/.cache/unixnu-toolchain" --jobs 4
sudo chown -R "$(id -u):$(id -g)" "$HOME/.cache/unixnu-toolchain"

echo
echo "Fedora dependencies and UniXNU toolchain are installed."
echo "Next: register a repository self-hosted runner with the labels: self-hosted, linux, x64, sagit."
echo "Keep the runner service running; workflow builds will execute on this computer."
