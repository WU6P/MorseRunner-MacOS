#!/bin/bash
# build_linux.sh — Build MorseRunner for Linux (x86_64 or ARM64)
#
# Prerequisites:
#   sudo apt install lazarus fpc libpulse-dev pkg-config
#
# Usage:
#   ./build_linux.sh            # build only
#   ./build_linux.sh run        # build and launch
#   ./build_linux.sh clean      # remove compiled artefacts

set -e

PROJ_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_VCL="$PROJ_ROOT/linux/VCL"

# ── Detect architecture ─────────────────────────────────────────────────────
ARCH="$(uname -m)"
case "$ARCH" in
  x86_64)  FPC_CPU="x86_64"  ;;
  aarch64) FPC_CPU="aarch64" ;;
  *)
    echo "ERROR: Unsupported architecture: $ARCH" >&2
    echo "  Supported: x86_64, aarch64" >&2
    exit 1
    ;;
esac
echo "Building for: $ARCH (FPC target: $FPC_CPU)"

# ── Locate FPC compiler ─────────────────────────────────────────────────────
FPC_COMPILER="$(command -v fpc 2>/dev/null || true)"
if [ -z "$FPC_COMPILER" ]; then
  echo "ERROR: FPC compiler not found" >&2
  echo "  Run: sudo apt install fpc" >&2
  exit 1
fi
echo "Using FPC: $FPC_COMPILER"

# ── Locate lazbuild ─────────────────────────────────────────────────────────
LAZBUILD="$(command -v lazbuild 2>/dev/null || true)"
if [ -z "$LAZBUILD" ]; then
  echo "ERROR: lazbuild not found. Install Lazarus:" >&2
  echo "  sudo apt install lazarus" >&2
  exit 1
fi
echo "Using lazbuild: $LAZBUILD"

# ── Check PulseAudio dev headers ────────────────────────────────────────────
if ! pkg-config --exists libpulse-simple 2>/dev/null; then
  echo "ERROR: libpulse-dev not found" >&2
  echo "  Run: sudo apt install libpulse-dev" >&2
  exit 1
fi

# ── Clean ────────────────────────────────────────────────────────────────────
if [ "$1" = "clean" ]; then
  echo "Cleaning..."
  rm -rf "$PROJ_ROOT/lib"
  rm -f "$SRC_VCL/AudioBackendPulse.o"
  rm -f "$PROJ_ROOT/MorseRunner.bin"
  rm -f "$PROJ_ROOT/MorseRunner"
  echo "Done."
  exit 0
fi

# ── Step 1: Compile PulseAudio C backend ─────────────────────────────────────
echo "[1/2] Compiling AudioBackendPulse.c (gcc → $SRC_VCL/AudioBackendPulse.o)..."
gcc -c "$SRC_VCL/AudioBackendPulse.c" \
  -o "$SRC_VCL/AudioBackendPulse.o" \
  -fPIC \
  $(pkg-config --cflags libpulse-simple) \
  -O2

# ── Step 2: Build Pascal project with lazbuild ──────────────────────────────
echo "[2/2] Building MorseRunner_linux.lpi (lazbuild + GTK2 widgetset)..."

OUT_DIR="$PROJ_ROOT/lib/${FPC_CPU}-linux"
mkdir -p "$OUT_DIR"

# Write a project-local fpc.cfg so unit paths reach FPC.
# FPC reads fpc.cfg from the current directory first.
SYSTEM_CFG="/etc/fpc.cfg"
{
  if [ -f "$SYSTEM_CFG" ]; then
    cat "$SYSTEM_CFG"
  fi
  printf '\n# --- project-specific unit search paths (added by build_linux.sh) ---\n'
  printf -- '-Fu%s/linux\n'         "$PROJ_ROOT"
  printf -- '-Fu%s/linux/VCL\n'     "$PROJ_ROOT"
  printf -- '-Fu%s/mac\n'           "$PROJ_ROOT"
  printf -- '-Fu%s/mac/VCL\n'       "$PROJ_ROOT"
  printf -- '-Fu%s\n'               "$PROJ_ROOT"
  printf -- '-Fu%s/VCL\n'           "$PROJ_ROOT"
  printf -- '-Fu%s/Util\n'          "$PROJ_ROOT"
  printf -- '-FU%s\n'               "$OUT_DIR"
} > "$PROJ_ROOT/fpc.cfg"

cd "$PROJ_ROOT"
"$LAZBUILD" "MorseRunner_linux.lpi" \
  --ws=gtk2 \
  --compiler="$FPC_COMPILER" \
  --cpu="$FPC_CPU" \
  --os=linux \
  --build-all 2>&1
LAZBUILD_EXIT=$?

rm -f "$PROJ_ROOT/fpc.cfg"

if [ $LAZBUILD_EXIT -ne 0 ]; then
  echo "ERROR: lazbuild failed (exit $LAZBUILD_EXIT)" >&2
  exit $LAZBUILD_EXIT
fi

# ── Copy binary to project root as MorseRunner.bin ──────────────────────────
BINARY="$OUT_DIR/MorseRunner"
if [ -f "$BINARY" ]; then
  cp "$BINARY" "$PROJ_ROOT/MorseRunner.bin"
  chmod +x "$PROJ_ROOT/MorseRunner.bin"
  echo ""
  echo "Build succeeded: $PROJ_ROOT/MorseRunner.bin"
else
  echo ""
  echo "Build succeeded (binary location: check lib/ directory)"
fi

# ── Write launcher as ./MorseRunner ──────────────────────────────────────────
# GTK2 on modern Ubuntu with a compositor gives harmless depth-mismatch
# warnings on stderr. GDK_NATIVE_WINDOWS=1 forces GTK2 to use plain X11
# windows for all widgets, avoiding the mismatch. Stderr is also redirected
# to /dev/null so the terminal stays clean.
cat > "$PROJ_ROOT/MorseRunner" << 'EOF'
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
GDK_NATIVE_WINDOWS=1 "$DIR/MorseRunner.bin" "$@" 2>/dev/null
EOF
chmod +x "$PROJ_ROOT/MorseRunner"
echo "Launcher written: $PROJ_ROOT/MorseRunner"

# ── Write .desktop file so the file manager shows the correct icon ───────────
cat > "$PROJ_ROOT/MorseRunner.desktop" << EOF
[Desktop Entry]
Type=Application
Name=Morse Runner
Comment=CW contesting simulator
Exec=$PROJ_ROOT/MorseRunner
Icon=$PROJ_ROOT/MorseRunner.png
Terminal=false
Categories=HamRadio;Education;
EOF
chmod +x "$PROJ_ROOT/MorseRunner.desktop"
echo "Desktop file written: $PROJ_ROOT/MorseRunner.desktop"

# ── Copy data files next to binary (if not already there) ───────────────────
for f in MASTER.DTA DXCC.LIST CWOPS.LIST NAQPCW.txt CQWWCW.txt \
         ARRLDXCW_USDX.txt FDGOTA.txt K1USNSST.txt IARU_HF.txt \
         HstResults.txt SSCW.txt Readme.txt \
         JARL_ACAG.TXT JARL_ALLJA.TXT; do
  if [ -f "$PROJ_ROOT/$f" ]; then
    # Data files are already in project root — no copy needed
    :
  fi
done

# ── Optionally launch ───────────────────────────────────────────────────────
if [ "$1" = "run" ]; then
  echo "Launching MorseRunner..."
  "$PROJ_ROOT/MorseRunner"   # runs the launcher (which calls MorseRunner.bin)
fi
