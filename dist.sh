#!/bin/bash
# dist.sh — Package a compiled MorseRunner binary for distribution.
#
# Run AFTER a successful build (build_mac.sh or build_linux.sh).
# Auto-detects the current platform and produces the appropriate zip.
#
# macOS output : MorseRunner_macOS_arm64.zip       — contains MorseRunner.app
#                (drag-to-Applications, no deps needed)
#
# Linux output : MorseRunner-x86_64.AppImage        — self-contained, no install needed
#              : MorseRunner-aarch64.AppImage        — same, ARM64 build
#                (chmod +x, then ./MorseRunner-*.AppImage — no apt/install step)
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
# Linux packaging — produces a self-contained AppImage
# ═════════════════════════════════════════════════════════════════════════════
package_linux() {
  local ARCH
  ARCH="$(uname -m)"   # x86_64 or aarch64
  local APPIMAGE_NAME="MorseRunner-${ARCH}.AppImage"
  local APPIMAGE_PATH="$PROJ_ROOT/$APPIMAGE_NAME"
  local APPDIR="/tmp/MorseRunner_AppDir_${ARCH}"
  local TOOLS_DIR="$PROJ_ROOT/tools"

  echo "==> Platform: Linux ($ARCH) — building AppImage"

  # ── Verify build output ────────────────────────────────────────────────────
  if [ ! -f "$PROJ_ROOT/MorseRunner" ] || [ ! -x "$PROJ_ROOT/MorseRunner" ]; then
    echo "ERROR: MorseRunner binary not found in $PROJ_ROOT" >&2
    echo "  Run ./build_linux.sh first." >&2
    exit 1
  fi
  if file "$PROJ_ROOT/MorseRunner" | grep -q "shell script"; then
    echo "ERROR: $PROJ_ROOT/MorseRunner is a shell script, not a compiled binary." >&2
    echo "  Re-run ./build_linux.sh to produce a fresh build." >&2
    exit 1
  fi

  # ── Verify data files ──────────────────────────────────────────────────────
  echo "==> Checking required data files..."
  check_data_files

  # ── Download appimagetool (no linuxdeploy needed) ──────────────────────────
  echo "==> Checking packaging tools in $TOOLS_DIR ..."
  mkdir -p "$TOOLS_DIR"

  local APPIMAGETOOL="$TOOLS_DIR/appimagetool-${ARCH}.AppImage"
  if [ ! -f "$APPIMAGETOOL" ]; then
    echo "    Downloading appimagetool-${ARCH}..."
    curl -fsSL -o "$APPIMAGETOOL" \
      "https://github.com/AppImage/appimagetool/releases/download/continuous/appimagetool-${ARCH}.AppImage"
    chmod +x "$APPIMAGETOOL"
  else
    echo "    appimagetool: cached"
  fi

  # ── Build AppDir skeleton ──────────────────────────────────────────────────
  echo "==> Building AppDir at $APPDIR ..."
  rm -rf "$APPDIR"
  mkdir -p "$APPDIR/usr/bin"
  mkdir -p "$APPDIR/usr/lib"
  mkdir -p "$APPDIR/usr/share/MorseRunner"
  mkdir -p "$APPDIR/usr/share/applications"
  mkdir -p "$APPDIR/usr/share/icons/hicolor/256x256/apps"

  # Binary (unmodified — no RPATH patching)
  cp "$PROJ_ROOT/MorseRunner" "$APPDIR/usr/bin/MorseRunner"
  chmod +x "$APPDIR/usr/bin/MorseRunner"

  # ── Bundle libpulse only ───────────────────────────────────────────────────
  # GTK2 is left to the system — bundling it causes GType double-registration
  # crashes because GTK2's theme/IM plugins always load the system libgdk.
  # libpulse is the only non-universal dep: we copy just those two .so files.
  # LD_LIBRARY_PATH in AppRun makes the binary find them; no RPATH patching.
  echo "==> Bundling libpulse libraries..."
  local pulse_found=0
  while IFS= read -r line; do
    # ldd output:  "libpulse.so.0 => /usr/lib/.../libpulse.so.0 (0x...)"
    local libpath
    libpath="$(echo "$line" | awk '{print $3}')"
    if [ -f "$libpath" ]; then
      cp "$libpath" "$APPDIR/usr/lib/"
      echo "    Bundled: $(basename "$libpath")"
      pulse_found=1
    fi
  done < <(ldd "$PROJ_ROOT/MorseRunner" 2>/dev/null | grep -E 'libpulse')

  if [ "$pulse_found" = "0" ]; then
    echo "    WARNING: libpulse not found in binary's ldd output — audio may not work."
    echo "    Is libpulse0 installed on this build machine? (apt install libpulse0)"
  fi

  # Data files
  for f in "${DATA_FILES[@]}"; do
    cp "$PROJ_ROOT/$f" "$APPDIR/usr/share/MorseRunner/$f"
  done

  # Icon
  if [ -f "$PROJ_ROOT/MorseRunner.png" ]; then
    cp "$PROJ_ROOT/MorseRunner.png" \
       "$APPDIR/usr/share/icons/hicolor/256x256/apps/MorseRunner.png"
    cp "$PROJ_ROOT/MorseRunner.png" "$APPDIR/MorseRunner.png"
  fi

  # .desktop file (required at AppDir root AND in usr/share/applications/)
  cat > "$APPDIR/MorseRunner.desktop" << 'DESKTOP'
[Desktop Entry]
Version=1.0
Type=Application
Name=Morse Runner
Comment=CW contesting simulator
Exec=MorseRunner
Icon=MorseRunner
Terminal=false
Categories=HamRadio;Education;
Keywords=morse;cw;ham radio;amateur radio;contest;
DESKTOP
  cp "$APPDIR/MorseRunner.desktop" "$APPDIR/usr/share/applications/MorseRunner.desktop"

  # ── Write AppRun ───────────────────────────────────────────────────────────
  cat > "$APPDIR/AppRun" << 'APPRUN'
#!/bin/bash
# AppRun — MorseRunner AppImage entry point.
# $APPDIR is set by the AppImage runtime; derive defensively for extract-and-run.
APPDIR_SELF="$(dirname "$(readlink -f "$0")")"
export APPDIR="${APPDIR:-$APPDIR_SELF}"

# GTK2 rendering fixes
export GDK_NATIVE_WINDOWS=1   # prevents depth-mismatch glitches with compositors
export GDK_SCALE=1            # disable GTK2 fractional-DPI scaling
export GDK_DPI_SCALE=1        # keep widgets at intended pixel sizes
export GTK_MODULES=""         # suppress canberra-gtk-module warning

# libpulse is bundled in usr/lib/. LD_LIBRARY_PATH lets the binary find it.
# ONLY libpulse* is present there — GTK2/GLib/X11 remain system-provided,
# so there are no GType double-registration conflicts.
export LD_LIBRARY_PATH="$APPDIR/usr/lib${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"

# Verify GTK2 is available on this system (nearly universal on any Linux desktop)
if ! ldconfig -p 2>/dev/null | grep -q 'libgtk-x11-2.0.so\|libgtk-x11-2\.0\.so\.0'; then
  echo "ERROR: libgtk2.0-0 not found on this system." >&2
  echo "  Install with: sudo apt install libgtk2.0-0" >&2
  exit 1
fi

exec "$APPDIR/usr/bin/MorseRunner" "$@" 2>/dev/null
APPRUN
  chmod +x "$APPDIR/AppRun"

  # ── Package into final AppImage ────────────────────────────────────────────
  echo "==> Creating $APPIMAGE_NAME ..."
  rm -f "$APPIMAGE_PATH"
  APPIMAGE_EXTRACT_AND_RUN=1 "$APPIMAGETOOL" \
      "$APPDIR" \
      "$APPIMAGE_PATH"
  chmod +x "$APPIMAGE_PATH"

  # ── Cleanup temp AppDir ────────────────────────────────────────────────────
  rm -rf "$APPDIR"

  local SIZE
  SIZE="$(du -sh "$APPIMAGE_PATH" | cut -f1)"
  echo ""
  echo "Done: $APPIMAGE_PATH  ($SIZE)"
  echo ""
  echo "Recipients — no apt/install step needed on standard Ubuntu 22.04+ desktops:"
  echo "  chmod +x $APPIMAGE_NAME"
  echo "  ./$APPIMAGE_NAME"
  echo ""
  echo "  If FUSE is unavailable (Ubuntu 24.04+):"
  echo "  APPIMAGE_EXTRACT_AND_RUN=1 ./$APPIMAGE_NAME"
  echo ""
  echo "  Requires: libgtk2.0-0 (standard desktop dep) + PulseAudio or PipeWire-pulse"
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
