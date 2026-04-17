#!/bin/bash
# dist.sh — Package a compiled MorseRunner binary for distribution.
#
# Run AFTER a successful build (build_mac.sh or build_linux.sh).
# Auto-detects the current platform and produces the appropriate zip.
#
# macOS output : MorseRunner_macOS_arm64.zip       — contains MorseRunner.app
#                (drag-to-Applications, no deps needed)
#
# Linux output : MorseRunner_linux_x86_64.zip      — contains binary + data files
#              : MorseRunner_linux_aarch64.zip      — same, ARM64 build
#                (run ./install_runtime.sh once for libpulse0 + GTK2, then ./MorseRunner)
#
# Usage:
#   ./dist.sh

set -e

PROJ_ROOT="$(cd "$(dirname "$0")" && pwd)"

# ── Shared data files (travel with the binary on all platforms) ───────────────
DATA_FILES=(
  MASTER.DTA
  DXCC.LIST
  CWOPS.LIST
  NAQPCW.txt
  CQWWCW.txt
  ARRLDXCW_USDX.txt
  FDGOTA.txt
  K1USNSST.txt
  IARU_HF.txt
  SSCW.txt
  JARL_ACAG.TXT
  JARL_ALLJA.TXT
  HstResults.txt
  Readme.txt
)

# ─────────────────────────────────────────────────────────────────────────────
# Helper: verify all data files exist in PROJ_ROOT
# ─────────────────────────────────────────────────────────────────────────────
check_data_files() {
  local missing=0
  for f in "${DATA_FILES[@]}"; do
    if [ ! -f "$PROJ_ROOT/$f" ]; then
      echo "  MISSING: $f" >&2
      missing=1
    fi
  done
  if [ "$missing" = "1" ]; then
    echo "ERROR: One or more data files are missing from $PROJ_ROOT" >&2
    exit 1
  fi
  echo "    All data files present."
}

# ═════════════════════════════════════════════════════════════════════════════
# macOS packaging
# ═════════════════════════════════════════════════════════════════════════════
package_macos() {
  local APP="$PROJ_ROOT/MorseRunner.app"
  local ARCH
  ARCH="$(uname -m)"   # arm64 on Apple Silicon, x86_64 on Intel
  local ZIP_NAME="MorseRunner_macOS_${ARCH}.zip"
  local ZIP_PATH="$PROJ_ROOT/$ZIP_NAME"

  echo "==> Platform: macOS ($ARCH)"

  # ── Verify the app bundle was built ────────────────────────────────────────
  if [ ! -d "$APP" ]; then
    echo "ERROR: MorseRunner.app not found in $PROJ_ROOT" >&2
    echo "  Run ./build_mac.sh first." >&2
    exit 1
  fi
  if [ ! -x "$APP/Contents/MacOS/MorseRunner" ]; then
    echo "ERROR: MorseRunner binary not found inside MorseRunner.app" >&2
    echo "  Run ./build_mac.sh first." >&2
    exit 1
  fi

  # ── Ensure all data files are present inside the bundle ────────────────────
  local RES="$APP/Contents/Resources"
  echo "==> Checking / refreshing data files in app bundle..."
  local refreshed=0
  for f in "${DATA_FILES[@]}"; do
    # Source: project root; destination: Resources/
    if [ -f "$PROJ_ROOT/$f" ] && [ ! -f "$RES/$f" ]; then
      cp "$PROJ_ROOT/$f" "$RES/$f"
      echo "    Added: $f"
      refreshed=1
    fi
  done
  [ "$refreshed" = "0" ] && echo "    Bundle resources already complete."

  # ── Ad-hoc codesign (allows running without notarization) ──────────────────
  echo "==> Ad-hoc signing MorseRunner.app..."
  codesign --force --deep -s - "$APP" 2>/dev/null || true

  # ── Create zip ─────────────────────────────────────────────────────────────
  echo "==> Creating $ZIP_NAME ..."
  rm -f "$ZIP_PATH"
  cd "$PROJ_ROOT"
  zip -r "$ZIP_NAME" "MorseRunner.app/"

  local SIZE
  SIZE="$(du -sh "$ZIP_PATH" | cut -f1)"
  echo ""
  echo "Done: $ZIP_PATH  ($SIZE)"
  echo ""
  echo "Recipients:"
  echo "  1. Download and unzip $ZIP_NAME"
  echo "  2. Move MorseRunner.app to /Applications  (or run from anywhere)"
  echo "  3. Double-click MorseRunner.app"
  echo "  Requires macOS 11.0+ (Apple Silicon or Intel matching this build)."
}

# ═════════════════════════════════════════════════════════════════════════════
# Linux packaging
# ═════════════════════════════════════════════════════════════════════════════
package_linux() {
  local ARCH
  ARCH="$(uname -m)"   # x86_64 or aarch64
  local ZIP_NAME="MorseRunner_linux_${ARCH}.zip"
  local ZIP_PATH="$PROJ_ROOT/$ZIP_NAME"
  local STAGE_DIR="/tmp/MorseRunner_linux_${ARCH}"
  local STAGE_APP="$STAGE_DIR/MorseRunner_linux_${ARCH}"

  echo "==> Platform: Linux ($ARCH)"

  # ── Verify build output exists ─────────────────────────────────────────────
  # build_linux.sh in MR_merge copies the binary directly to ./MorseRunner
  # (no .bin split — GDK env vars live in the .desktop file, not a wrapper).
  if [ ! -f "$PROJ_ROOT/MorseRunner" ] || [ ! -x "$PROJ_ROOT/MorseRunner" ]; then
    echo "ERROR: MorseRunner binary not found in $PROJ_ROOT" >&2
    echo "  Run ./build_linux.sh first." >&2
    exit 1
  fi
  # Quick sanity check: must be an ELF binary, not a shell script
  if file "$PROJ_ROOT/MorseRunner" | grep -q "shell script"; then
    echo "ERROR: $PROJ_ROOT/MorseRunner is a shell script, not a compiled binary." >&2
    echo "  Re-run ./build_linux.sh to produce a fresh build." >&2
    exit 1
  fi

  # ── Verify data files ──────────────────────────────────────────────────────
  echo "==> Checking required data files..."
  check_data_files

  # ── Stage files ────────────────────────────────────────────────────────────
  echo "==> Staging files in $STAGE_APP ..."
  rm -rf "$STAGE_DIR"
  mkdir -p "$STAGE_APP"

  # The binary goes in as MorseRunner.bin; we create a wrapper MorseRunner
  # that sets the required GTK2 env vars (GDK_NATIVE_WINDOWS, GDK_SCALE).
  # This matches what the .desktop Exec= line does, so the app behaves
  # the same whether launched from a terminal or a file manager.
  cp "$PROJ_ROOT/MorseRunner" "$STAGE_APP/MorseRunner.bin"
  chmod +x "$STAGE_APP/MorseRunner.bin"

  cat > "$STAGE_APP/MorseRunner" << 'WRAPPER'
#!/bin/bash
# Launcher: sets GTK2 env vars needed for correct rendering on modern desktops.
# GDK_NATIVE_WINDOWS=1  — prevents depth-mismatch glitches with compositors
# GDK_SCALE=1           — disable GTK2's broken fractional-DPI scaling
# GDK_DPI_SCALE=1       — keep widgets at intended pixel sizes
DIR="$(cd "$(dirname "$0")" && pwd)"
exec env GDK_NATIVE_WINDOWS=1 GDK_SCALE=1 GDK_DPI_SCALE=1 \
  "$DIR/MorseRunner.bin" "$@" 2>/dev/null
WRAPPER
  chmod +x "$STAGE_APP/MorseRunner"

  for f in "${DATA_FILES[@]}"; do
    cp "$PROJ_ROOT/$f" "$STAGE_APP/"
  done

  [ -f "$PROJ_ROOT/MorseRunner.png" ] && cp "$PROJ_ROOT/MorseRunner.png" "$STAGE_APP/"

  # ── Write .desktop file ────────────────────────────────────────────────────
  cat > "$STAGE_APP/MorseRunner.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=MorseRunner
Comment=Morse code CW contest practice simulator
Exec=bash -c 'cd "$(dirname "%k")" && ./MorseRunner'
Icon=MorseRunner
Terminal=false
Categories=HamRadio;Education;
Keywords=morse;cw;ham radio;amateur radio;contest;
DESKTOP

  # ── Write install_runtime.sh for recipients ───────────────────────────────
  cat > "$STAGE_APP/install_runtime.sh" << 'INSTALL'
#!/bin/bash
# install_runtime.sh — Install runtime libraries for MorseRunner (Linux)
#
# Run once on a new machine. Does NOT need a compiler or Lazarus.

set -e
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

echo "==> Installing MorseRunner runtime dependencies..."
if ! command -v apt-get &>/dev/null; then
  echo "ERROR: This script requires apt (Debian/Ubuntu)." >&2
  echo "  On other distros, install: libpulse0, libgtk2.0-0, libcanberra-gtk0" >&2
  exit 1
fi

sudo apt-get install -y \
  libpulse0 \
  libgtk2.0-0 \
  libcanberra-gtk0 \
  libcanberra-gtk-module

echo ""
echo "==> Runtime libraries installed."

# ── Optional: register in application menu ────────────────────────────────
DESKTOP_SRC="$SCRIPT_DIR/MorseRunner.desktop"
ICON_SRC="$SCRIPT_DIR/MorseRunner.png"
DESKTOP_DIR="$HOME/.local/share/applications"
ICON_DIR="$HOME/.local/share/icons"

echo ""
read -r -p "Register MorseRunner in your application menu? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  mkdir -p "$DESKTOP_DIR" "$ICON_DIR"

  sed "s|Exec=.*|Exec=bash -c 'cd \"$SCRIPT_DIR\" \&\& ./MorseRunner'|" \
    "$DESKTOP_SRC" > "$DESKTOP_DIR/MorseRunner.desktop"

  if [ -f "$ICON_SRC" ]; then
    cp "$ICON_SRC" "$ICON_DIR/MorseRunner.png"
    sed -i "s|^Icon=.*|Icon=$ICON_DIR/MorseRunner.png|" \
      "$DESKTOP_DIR/MorseRunner.desktop"
  fi

  chmod +x "$DESKTOP_DIR/MorseRunner.desktop"
  echo "  Registered: $DESKTOP_DIR/MorseRunner.desktop"
  echo "  You may need to log out/in for it to appear in the menu."
fi

echo ""
echo "Done. Run the app with:"
echo "  cd \"$SCRIPT_DIR\""
echo "  ./MorseRunner"
INSTALL
  chmod +x "$STAGE_APP/install_runtime.sh"

  # ── Create zip ─────────────────────────────────────────────────────────────
  echo "==> Creating $ZIP_NAME ..."
  rm -f "$ZIP_PATH"
  cd "$STAGE_DIR"
  zip -r "$ZIP_PATH" "MorseRunner_linux_${ARCH}/"

  local SIZE
  SIZE="$(du -sh "$ZIP_PATH" | cut -f1)"
  echo ""
  echo "Done: $ZIP_PATH  ($SIZE)"
  echo ""
  echo "Recipients:"
  echo "  unzip $ZIP_NAME"
  echo "  cd MorseRunner_linux_${ARCH}"
  echo "  ./install_runtime.sh    # once — installs libpulse0 + GTK2"
  echo "  ./MorseRunner           # run"
}

# ═════════════════════════════════════════════════════════════════════════════
# Dispatch by platform
# ═════════════════════════════════════════════════════════════════════════════
OS="$(uname -s)"
case "$OS" in
  Darwin)
    package_macos
    ;;
  Linux)
    package_linux
    ;;
  *)
    echo "ERROR: Unsupported OS: $OS" >&2
    echo "  Supported: Darwin (macOS), Linux" >&2
    exit 1
    ;;
esac
