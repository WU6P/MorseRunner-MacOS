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

Download the zip for your platform from the
[Releases](https://github.com/WU6P/MorseRunner-Linux-MacOS/releases) page:

| File | Platform |
|---|---|
| `MorseRunner_macOS_arm64.zip` | macOS Apple Silicon |
| `MorseRunner_linux_x86_64.zip` | Linux x86_64 |
| `MorseRunner_linux_aarch64.zip` | Linux ARM64 |

### macOS ARM64

```bash
# Unzip, then double-click MorseRunner.app — or drag it to /Applications first
unzip MorseRunner_macOS_arm64.zip
open MorseRunner.app
```

> If macOS blocks the app ("unidentified developer"), right-click the app → **Open**.

### Linux x86_64 / ARM64

```bash
unzip MorseRunner_linux_x86_64.zip      # or _aarch64.zip on ARM hardware
cd MorseRunner_linux_x86_64             # or _aarch64
./install_runtime.sh                    # installs libpulse0 + GTK2 (once, needs sudo)
./MorseRunner                           # run
```

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

## Credits

Original MorseRunner by Alex Shovkoplyas VE3NEA ([dxatlas.com](https://www.dxatlas.com/MorseRunner/)).
Windows version further developed by Mike W7SST ([github.com/w7sst/MorseRunner](https://github.com/w7sst/MorseRunner)).
Linux/macOS port by Nian WU6P.
