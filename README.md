# MorseRunner — Linux & macOS Port

This is a port of [MorseRunner](https://www.dxatlas.com/MorseRunner/), a CW (Morse code) contest
simulator originally written for Windows by Alex Shovkoplyas VE3NEA, and further developed by
Mike W7SST ([github.com/w7sst/MorseRunner](https://github.com/w7sst/MorseRunner)),
to **macOS (Apple Silicon)**, **Linux x86_64**, and **Linux ARM64**.

The port uses [Lazarus/FPC](https://www.lazarus-ide.org/) with the LCL widget toolkit.
Audio uses CoreAudio on macOS and PulseAudio on Linux.

---

## Platforms

| Platform | Architecture | Audio | GUI |
|---|---|---|---|
| macOS 11.0+ | Apple Silicon (ARM64) | CoreAudio | LCL Cocoa |
| Linux (Ubuntu 22.04+) | x86_64 | PulseAudio | LCL GTK2 |
| Linux (Ubuntu 22.04+) | ARM64 (aarch64) | PulseAudio | LCL GTK2 |

---

## Installation, Option A — Use the Pre-compiled Binary (no build tools needed)

Download the file for your platform from the
[Releases](https://github.com/WU6P/MorseRunner-Linux-MacOS/releases) page:

| File | Platform |
|---|---|
| `MorseRunner_macOS_arm64.zip` | macOS Apple Silicon |
| `MorseRunner-x86_64.AppImage` | Linux x86_64 |
| `MorseRunner-aarch64.AppImage` | Linux ARM64 |

### macOS ARM64

```bash
# Unzip, then double-click MorseRunner.app — or drag it to /Applications first
unzip MorseRunner_macOS_arm64.zip
open MorseRunner.app
```

> If macOS blocks the app ("unidentified developer"), right-click the app → **Open**.

### Linux x86_64 / ARM64

AppImages are self-contained — no installation or `sudo` required.

```bash
# x86_64:
chmod +x MorseRunner-x86_64.AppImage
./MorseRunner-x86_64.AppImage

# ARM64:
chmod +x MorseRunner-aarch64.AppImage
./MorseRunner-aarch64.AppImage
```

> PulseAudio must be running (standard on most desktop Linux distros).
> If you see a FUSE error on first run, install `libfuse2`:
> `sudo apt install libfuse2`

---

## Installation, Option B — Build from Source

### Prerequisites

**macOS:**

Install [Lazarus](https://www.lazarus-ide.org/) (which includes FPC), then install
Xcode Command Line Tools:

```bash
xcode-select --install
```

**Linux:**

```bash
sudo apt install lazarus fpc libpulse-dev pkg-config gcc \
                 libcanberra-gtk-module libcanberra-gtk0
```

### Build — macOS ARM64

```bash
git clone https://github.com/WU6P/MorseRunner-Linux-MacOS.git
cd MorseRunner-Linux-MacOS
./build_mac.sh
open MorseRunner.app
```

### Build — Linux x86_64 or ARM64

```bash
git clone https://github.com/WU6P/MorseRunner-Linux-MacOS.git
cd MorseRunner-Linux-MacOS
./build_linux.sh
./MorseRunner
```

---

## Original Windows / Community Edition

For the full history, roadmap, and community information for the Windows version,
see [README_original.md](README_original.md).

---

## Credits

Original MorseRunner by Alex Shovkoplyas VE3NEA ([dxatlas.com](https://www.dxatlas.com/MorseRunner/)).
Windows version further developed by Mike W7SST ([github.com/w7sst/MorseRunner](https://github.com/w7sst/MorseRunner)).
Linux/macOS port by Nian WU6P.
