#!/bin/bash
# Run this once to create the GitHub release and upload the compiled binaries.
# Usage: ./create_release.sh

set -e
cd "$(dirname "$0")"

gh release create v1.5_1.85.3_Linux_macOS \
  --title "MorseRunner v1.5_1.85.3 Linux & macOS" \
  --notes "Ready-to-run builds for macOS Apple Silicon, Linux x86_64, and Linux ARM64.

## What's New
- Linux binaries now distributed as self-contained AppImages (no installation or sudo needed)
- Linux x86_64 and ARM64 support (PulseAudio + LCL GTK2)
- macOS Apple Silicon (CoreAudio + LCL Cocoa)
- Unified codebase for all three platforms

## Installation, Option A — Pre-compiled Binary

| File | Platform |
|---|---|
| \`MorseRunner_macOS_arm64.zip\` | macOS Apple Silicon |
| \`MorseRunner-x86_64.AppImage\` | Linux x86_64 |
| \`MorseRunner-aarch64.AppImage\` | Linux ARM64 |

**macOS:** Unzip and double-click \`MorseRunner.app\`. If blocked, right-click → Open.

**Linux (AppImage — no install needed):**
\`\`\`
chmod +x MorseRunner-x86_64.AppImage   # or MorseRunner-aarch64.AppImage
./MorseRunner-x86_64.AppImage
\`\`\`
> If you see a FUSE error, run: \`sudo apt install libfuse2\`

## Installation, Option B — Build from Source
See the README for full build instructions.

## Credits
Original MorseRunner by Alex Shovkoplyas VE3NEA.
Windows version further developed by Mike W7SST (github.com/w7sst/MorseRunner).
Linux/macOS port by Nian WU6P.

73" \
  compiled/MorseRunner_macOS_arm64.zip \
  compiled/MorseRunner-x86_64.AppImage \
  compiled/MorseRunner-aarch64.AppImage
