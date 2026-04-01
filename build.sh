#!/bin/bash
# build.sh — Build MorseRunner for Apple Silicon (aarch64-darwin)
#
# Prerequisites:
#   brew install lazarus   # provides lazbuild + LCL Cocoa units
#   xcode-select --install # provides clang
#
# Usage:
#   ./build.sh            # build only
#   ./build.sh run        # build and launch
#   ./build.sh clean      # remove compiled artefacts

set -e

PROJ_ROOT="$(cd "$(dirname "$0")" && pwd)"
SRC_VCL="$PROJ_ROOT/src/VCL"
BIN="$PROJ_ROOT/MorseRunner.app"

# ── FPC compiler — use Homebrew arm64 FPC 3.2.2 (universal binary) ──────────
# The Lazarus cask installed fpc-laz which puts the compiler at /usr/local/bin/fpc.
# It is a universal binary; on Apple Silicon it natively targets aarch64-darwin.
# (The /tmp/fpc331/bin/fpc wrapper calls the system ppca64, so it is not needed here.)
FPC_COMPILER="/usr/local/bin/fpc"
if [ ! -x "$FPC_COMPILER" ]; then
  echo "ERROR: FPC compiler not found at $FPC_COMPILER" >&2
  echo "  Run: brew install fpc-laz" >&2
  exit 1
fi

# ── Locate lazbuild ──────────────────────────────────────────────────────────
LAZBUILD="$(command -v lazbuild 2>/dev/null || true)"
if [ -z "$LAZBUILD" ]; then
  # Common Homebrew / manual install locations
  for candidate in \
      /opt/homebrew/bin/lazbuild \
      /usr/local/bin/lazbuild \
      "$HOME/Applications/Lazarus/lazbuild" \
      "/Applications/Lazarus/lazbuild"; do
    if [ -x "$candidate" ]; then
      LAZBUILD="$candidate"
      break
    fi
  done
fi

if [ -z "$LAZBUILD" ]; then
  echo "ERROR: lazbuild not found. Install Lazarus:" >&2
  echo "  brew install lazarus" >&2
  exit 1
fi
echo "Using lazbuild: $LAZBUILD"

# ── Clean ────────────────────────────────────────────────────────────────────
if [ "$1" = "clean" ]; then
  echo "Cleaning..."
  rm -rf "$PROJ_ROOT/lib" "$PROJ_ROOT/MorseRunner" "$PROJ_ROOT/MorseRunner.app"
  rm -f "$SRC_VCL/AudioBackend2.o"
  echo "Done."
  exit 0
fi

# ── Step 1: Compile Objective-C audio backend ────────────────────────────────
echo "[1/2] Compiling AudioBackend2.m (Clang → $SRC_VCL/AudioBackend2.o)..."
clang -c "$SRC_VCL/AudioBackend2.m" \
  -o "$SRC_VCL/AudioBackend2.o" \
  -arch arm64 \
  -fobjc-arc \
  -framework AudioToolbox \
  -framework CoreAudio \
  -framework Foundation \
  -O2

# ── Step 2: Build Pascal project with lazbuild ───────────────────────────────
echo "[2/2] Building MorseRunner.lpi (lazbuild + Cocoa widgetset)..."

# Write a project-local fpc.cfg so the unit paths reach FPC regardless of
# whether lazbuild expands $(ProjPath) or {$UNITPATH} directives.
# FPC searches for fpc.cfg in the current directory first.
# FPC reads the FIRST fpc.cfg it finds (current dir wins over /etc/fpc.cfg).
# So we merge the system config with our project paths into one local file.
{
  cat /etc/fpc.cfg
  printf '\n# --- project-specific unit search paths (added by build.sh) ---\n'
  printf -- '-Fu%s/src\n'            "$PROJ_ROOT"
  printf -- '-Fu%s/src/VCL\n'       "$PROJ_ROOT"
  printf -- '-Fu%s/src/Util\n'      "$PROJ_ROOT"
  printf -- '-Fu%s\n'               "$PROJ_ROOT"
  printf -- '-Fu%s/lib/aarch64-darwin\n' "$PROJ_ROOT"
  printf -- '-FU%s/lib/aarch64-darwin\n' "$PROJ_ROOT"
  printf -- '-Fu/usr/local/lib/fpc/3.2.2/units/aarch64-darwin/fcl-web\n'
} > "$PROJ_ROOT/fpc.cfg"

# --compiler  : use the Homebrew arm64 FPC (universal binary, targets aarch64 on M1)
# --cpu/--os  : tell lazbuild to build LCL units for aarch64-darwin (not x86_64)
# --build-all : recompile LCL if arch-specific .ppu files don't exist yet
mkdir -p "$PROJ_ROOT/lib/aarch64-darwin"
"$LAZBUILD" "$PROJ_ROOT/MorseRunner.lpi" \
  --ws=cocoa \
  --compiler="$FPC_COMPILER" \
  --cpu=aarch64 \
  --os=darwin \
  --build-all 2>&1

rm -f "$PROJ_ROOT/fpc.cfg"

# ── Ad-hoc code sign for local testing ──────────────────────────────────────
if [ -d "$BIN" ]; then
  echo "Signing MorseRunner.app..."
  codesign --force --deep -s - "$BIN"
  echo ""
  echo "Build succeeded: $BIN"
elif [ -f "$PROJ_ROOT/MorseRunner" ]; then
  codesign --force -s - "$PROJ_ROOT/MorseRunner" 2>/dev/null || true
  echo ""
  echo "Build succeeded: $PROJ_ROOT/MorseRunner"
fi

# ── Optionally launch ────────────────────────────────────────────────────────
if [ "$1" = "run" ]; then
  if [ -d "$BIN" ]; then
    open "$BIN"
  else
    "$PROJ_ROOT/MorseRunner"
  fi
fi
