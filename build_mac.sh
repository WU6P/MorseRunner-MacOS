#!/bin/bash
# Build MorseRunner for macOS (Apple M1 / aarch64).
# lazbuild uses FPC 3.2.2 which generates ppaslink.sh with the new ld-prime
# linker that rejects FPC's ObjC metadata format. We intercept the link step
# and substitute ld-classic (which ships alongside ld on Xcode / CommandLineTools).
set -e
cd "$(dirname "$0")"

LD_NEW=/Library/Developer/CommandLineTools/usr/bin/ld
LD_OLD=/Library/Developer/CommandLineTools/usr/bin/ld-classic
PPASLINK=lib/aarch64-darwin/ppaslink.sh

if [ ! -x "$LD_OLD" ]; then
  echo "ERROR: $LD_OLD not found — cannot build without ld-classic"
  exit 1
fi

# Ensure AudioBackend2.o is present and up-to-date
if [ ! -f mac/VCL/AudioBackend2.o ] || [ mac/VCL/AudioBackend2.m -nt mac/VCL/AudioBackend2.o ]; then
  echo "=== Rebuilding AudioBackend2.o ==="
  /Library/Developer/CommandLineTools/usr/bin/clang -c \
    -fPIC \
    -arch arm64 \
    -mmacosx-version-min=11.0 \
    -fno-objc-arc \
    -isysroot /Library/Developer/CommandLineTools/SDKs/MacOSX.sdk \
    -o mac/VCL/AudioBackend2.o \
    mac/VCL/AudioBackend2.m
fi

# Run lazbuild. It will compile Pascal → assemble → then try to link with the
# new ld and fail. We catch that failure, patch ppaslink.sh, and re-run link.
echo "=== Compiling ==="
/Applications/Lazarus/lazbuild MorseRunner.lpi \
  --ws=cocoa \
  --compiler=/usr/local/bin/fpc \
  --cpu=aarch64 \
  --os=darwin \
  2>&1 || true   # ignore error; we'll check if ppaslink.sh needs patching

# If lazbuild succeeded (produced binary directly), great.
if [ -x lib/aarch64-darwin/MorseRunner ] && [ lib/aarch64-darwin/MorseRunner -nt "$PPASLINK" ]; then
  echo "=== Build successful (no ld patch needed) ==="
  exit 0
fi

# Patch ppaslink.sh to use ld-classic
# Note: Lazarus 3.7+ writes ppaslink.sh into the unit output dir, not project root
if [ ! -f "$PPASLINK" ]; then
  echo "ERROR: $PPASLINK not found — compile step failed completely"
  exit 1
fi

if grep -q "$LD_NEW " "$PPASLINK" && ! grep -q "ld-classic" "$PPASLINK"; then
  echo "=== Patching ppaslink.sh: ld → ld-classic ==="
  sed -i '' "s|${LD_NEW} |${LD_OLD} |g" "$PPASLINK"
fi

echo "=== Linking with ld-classic ==="
bash "$PPASLINK"

BINARY=lib/aarch64-darwin/MorseRunner
if [ -x "$BINARY" ]; then
  echo "=== Build successful: $BINARY ==="
  file "$BINARY"
  otool -l "$BINARY" | grep -A3 "minos\|platform" | head -12
else
  echo "ERROR: MorseRunner not produced"
  exit 1
fi

# Build .app bundle so macOS activates it properly (keyboard focus)
echo "=== Building MorseRunner.app bundle ==="
APP=MorseRunner.app
MACOS="$APP/Contents/MacOS"
RES="$APP/Contents/Resources"
mkdir -p "$MACOS" "$RES"

cp "$BINARY" "$MACOS/MorseRunner"
codesign --force --deep -s - "$MACOS/MorseRunner" 2>/dev/null || true

# Copy data files into Resources
for f in *.LIST *.DTA; do
  [ -f "$f" ] && cp "$f" "$RES/"
done
for f in *.txt; do
  [ -f "$f" ] && [ "$f" != "*.txt" ] && cp "$f" "$RES/"
done

cat > "$APP/Contents/Info.plist" << 'PLIST'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>CFBundleExecutable</key>
  <string>MorseRunner</string>
  <key>CFBundleIdentifier</key>
  <string>com.morserunner.MorseRunner</string>
  <key>CFBundleName</key>
  <string>Morse Runner</string>
  <key>CFBundleVersion</key>
  <string>1.85.3</string>
  <key>CFBundlePackageType</key>
  <string>APPL</string>
  <key>LSMinimumSystemVersion</key>
  <string>11.0</string>
  <key>NSHighResolutionCapable</key>
  <true/>
</dict>
</plist>
PLIST

codesign --force --deep -s - "$APP" 2>/dev/null || true
echo "=== MorseRunner.app bundle ready ==="
