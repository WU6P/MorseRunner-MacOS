# MorseRunner Linux Port

## Overview

Linux port of MorseRunner for Ubuntu x86_64 and Ubuntu ARM64.
Uses PulseAudio for audio output and LCL GTK2 for the GUI.

**Zero changes to shared files** (except 4 filename case fixes — see below).
The Linux port adds 5 new files that overlay the macOS-specific components
while reusing all shared code. All files are now integrated into MR_merge.

## Linux-Specific Files

```
linux/
├── GetDataPath.pas          — XDG-compliant data/user paths
└── VCL/
    ├── SndOut.pas            — TAlSoundOut using PulseAudio backend
    └── AudioBackendPulse.c   — PulseAudio ring-buffer + playback thread

MorseRunner_linux.lpi         — Lazarus project file for Linux (GTK2)
build_linux.sh                — Build script (gcc + lazbuild)
install_deps.sh               — One-time dependency installer
package_for_linux.sh          — Run on Mac to produce ready-to-build tarball
```

## Reused from mac/ (no changes)

These mac/ files are LCL-generic and work on Linux as-is:
- `mac/Main.pas` + `mac/Main.lfm` — Main form (LCL, not Cocoa-specific)
- `mac/Log.pas` — TMemo-based log window
- `mac/Ini.pas` — TIniFile configuration
- `mac/Globals.pas` — Shared state / callback pointers
- `mac/ContestFactory.pas` — Contest instantiation
- `mac/PerlRegEx.pas` — FPC RegExpr wrapper
- `mac/VCL/WavFile.pas` — Pure Pascal WAV I/O
- `mac/VCL/VolmSldr.pas` — Volume slider (LCL Canvas)
- `mac/VCL/PermHint.pas` — Hint window (LCLIntf)
- `mac/VCL/SndCustm.pas` — Base audio class (DARWIN ifdefs are skipped)

## Unit Search Path Order

```
linux → linux/VCL → mac → mac/VCL → . → VCL → Util
```

`linux/` overrides only GetDataPath and SndOut. Everything else falls
through to mac/ (shared Unix/LCL code) or root (contest logic).

---

## Prerequisites (Ubuntu)

```bash
sudo apt install lazarus fpc libpulse-dev pkg-config gcc \
                 libcanberra-gtk-module libcanberra-gtk0 libgtk-3-dev
```

`install_deps.sh` does this automatically.

**Do NOT build with `--ws=gtk3`** — see GTK section below.

---

## Build & Run

```bash
chmod +x build_linux.sh install_deps.sh
./install_deps.sh       # once on a new machine
./build_linux.sh        # compile
./MorseRunner           # launch (wrapper script → calls MorseRunner.bin)
./build_linux.sh run    # build and launch
./build_linux.sh clean  # remove build artefacts
```

`build_linux.sh` auto-detects x86_64 vs aarch64. Same script for both.

---

## Workflow: Mac → Linux Transfer

All source is now in MR_merge. To transfer to a Linux machine:

```bash
# On Mac — tarball the merged repo (exclude build artefacts)
cd MR_merge
tar -czf /tmp/MorseRunner_linux.tar.gz \
  --exclude='.DS_Store' --exclude='*.dproj' --exclude='*.dpr' \
  --exclude='MorseRunner.app' --exclude='lib/' \
  --exclude='MorseRunner.compiled' --exclude='*.o' \
  -C .. MR_merge

# On Linux
scp /tmp/MorseRunner_linux.tar.gz feng@<linux-host>:~/
ssh feng@<linux-host>
tar -xzf MorseRunner_linux.tar.gz
cd MR_merge
./install_deps.sh   # once
./build_linux.sh    # build
./MorseRunner       # run
```

---

## Audio Architecture

```
Pascal main thread  → AudioBackendPulse_Write() → SPSC ring buffer (65536 frames)
Playback thread     → waits for ≥512 frames      → pa_simple_write() → PulseAudio
                    ← gNeedsData flag             ← TTimer polls at 15 ms
```

### Critical Design: No Silence Injection

The playback thread **waits** (2 ms sleep loop) when the ring buffer is empty
instead of writing silence to PulseAudio. This is the key difference from a
naive implementation.

**Why it matters**: `pa_simple_write` on PulseAudio is a push model. If the
thread writes silence while the ring is empty, PA buffers that silence ahead
of real audio. When Pascal's timer later fills the ring with real audio, the
real audio plays after all the buffered silence — producing "cut into small
pieces" / choppy sound.

`GetAudio()` in Contest.pas always produces real samples (including explicit
zero samples during Morse silence periods), so the ring is only truly empty
at startup or during very long delays. Sleeping in those cases is correct.

Contrast with macOS CoreAudio (AudioQueue): it uses a pull-callback model
where the OS calls our code when it needs data, so silence injection is
impossible by design. The Linux port must emulate this discipline manually.

---

## GTK Widgetset: Use GTK2, Not GTK3

**Use `--ws=gtk2`** (the default in `build_linux.sh`).

### Why not GTK3?

GTK3 with Lazarus LCL on Ubuntu 25.10 has two problems:

1. **Broken widget rendering**: Forms designed for GTK2 metrics have oversized
   buttons and layout errors under GTK3. LCL form layouts assume GTK2 pixel
   sizes.

2. **LCL GTK3 backend errors**: `signal 'event' is invalid for instance of
   type 'GtkCssCustomGadget'` — LCL tries to connect signals to internal GTK3
   gadgets that are not full widgets. Many `GTK_IS_WIDGET` assertion failures.

### GTK2 depth-mismatch warnings (harmless)

On Ubuntu with a compositor (Wayland/Mutter), GTK2 sees this on stderr:

```
Gtk-CRITICAL: IA__gtk_paint_flat_box: assertion
  'style->depth == gdk_drawable_get_depth (window)' failed
```

**Cause**: The compositor gives windows a 32-bit ARGB visual; GTK2 styles
are created with the screen's default 24-bit visual. The assertion fires but
the app keeps running — it just skips painting that background.

**Fix**: `GDK_NATIVE_WINDOWS=1` forces GTK2 to use native X11 windows for
all widgets, so all windows share the same visual and depths always match.

`build_linux.sh` generates `./MorseRunner` as a launcher wrapper (the real
compiled binary is `MorseRunner.bin`):

```bash
#!/bin/bash
DIR="$(cd "$(dirname "$0")" && pwd)"
GDK_NATIVE_WINDOWS=1 "$DIR/MorseRunner.bin" "$@" 2>/dev/null
```

**Always launch via `./MorseRunner` (the wrapper), not `./MorseRunner.bin` directly.**

---

## Data File Case-Sensitivity Fixes (MR_merge)

Linux filesystems are case-sensitive. macOS is not, so mismatches were
invisible on Mac. The following files had incorrect case in the Pascal source:

| File on disk | Old code reference | Fixed to |
|---|---|---|
| `CQWWCW.txt` | `CQWWCW.TXT` | `CQWWCW.txt` |
| `NAQPCW.txt` | `NAQPCW.TXT` | `NAQPCW.txt` |
| `SSCW.txt` | `SSCW.TXT` | `SSCW.txt` |
| `FDGOTA.txt` | `FDGOTA.TXT` | `FDGOTA.txt` |

Files fixed in MR_merge: `CqWW.pas`, `NaQp.pas`, `ArrlSS.pas`, `ArrlFd.pas`.

`JARL_ACAG.TXT` and `JARL_ALLJA.TXT` already matched (uppercase on disk and
in code), so no change needed.

---

## FPC/lazbuild Working Directory Fix

`lazbuild` passes `MorseRunner.lpr` as a **relative path** to FPC.
FPC resolves it against its working directory, not the project file's location.

Fix: `cd "$PROJ_ROOT"` before calling `lazbuild`, and pass the `.lpi` filename
as a relative path (not absolute):

```bash
cd "$PROJ_ROOT"
"$LAZBUILD" "MorseRunner_linux.lpi" ...
```

---

## Integration Status

Linux support is fully integrated into MR_merge as of 2026-04-14.

All Linux-specific files live in `linux/` and `MorseRunner_linux.lpi`.
No existing Windows or macOS files were modified (except the 4 case fixes).
Windows and macOS builds are unaffected.
