#!/bin/bash
# install_deps.sh — Install build dependencies for MorseRunner Linux
#
# Run this once on a fresh Ubuntu machine before building.
# Usage: sudo ./install_deps.sh   (or just ./install_deps.sh, will prompt for sudo)

set -e

echo "==> Updating package lists..."
sudo apt update

echo ""
echo "==> Installing MorseRunner build dependencies..."
sudo apt install -y \
  lazarus \
  fpc \
  libpulse-dev \
  pkg-config \
  gcc \
  libcanberra-gtk-module \
  libcanberra-gtk0 \
  libgtk-3-dev

echo ""
echo "==> Installed versions:"
fpc -iV
lazbuild --version
gcc --version | head -1
pkg-config --modversion libpulse-simple 2>/dev/null && echo "libpulse-simple: OK" || echo "WARNING: libpulse-simple not found"

echo ""
echo "==> All dependencies installed."
echo "    Now build with: ./build_linux.sh"
