gh release create v1.1_v1.85.3-macOS \
  --title "MorseRunner v1.1_1.85.3 macOS" \
  --notes "Ready-to-use macOS app bundle for Apple Silicon (M1, M2, M3, M4, M5) Macs.

## What's New
- Fixed keyboard focus handling on macOS when launched from terminal (use Open MorseRunner.app)
- Improved field input handling (semicolon as trigger, space trimming)
- Fixed Cocoa integration issues with modern Xcode

## Installation
1. Download MorseRunner.app.zip
2. Unzip the file
3. Move MorseRunner.app to Applications folder
4. Launch from Finder or Dock
(or you can build from source file, using build_mac.sh)

Requires macOS 11.0 or later.

Enjoy

73
Nian WU6P " \
  MorseRunner.app.zip \
  MorseRunner-source.zip
