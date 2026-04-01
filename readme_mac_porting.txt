Morse Runner CE — macOS Port
============================

Background
----------
Morse Runner Community Edition (MRCE) is an amateur radio CW (Morse code) contest
practice simulator originally written in Object Pascal (Delphi/RAD Studio) for
Windows. It simulates realistic contest pile-ups so operators can practice copying
callsigns and exchanges at speed.

This repository is a native macOS port targeting Apple M1 (ARM64). The port
translates the original Windows/VCL codebase to run under Lazarus/FPC with the
LCL Cocoa widgetset, while keeping all contest logic, station simulation, and Morse
keyer code unchanged. Audio is handled through CoreAudio via a small Objective-C
bridge (AudioBackend2.m) instead of the original Windows MMSystem API.

The original Windows project: https://github.com/w7sst/MorseRunner


Original Documentation
----------------------
See Readme.txt in this repository for the full original program documentation,
including contest modes, operating instructions, scoring, and keyboard shortcuts.


How to Use (macOS)
------------------
1. Download and unzip MorseRunner.zip (or clone this repository and build — see
   below).

2. Open the unzipped folder in Finder and double-click MorseRunner.app.

3. On first launch macOS Gatekeeper may block the app because it is not from the
   Mac App Store. To open it:
   - Right-click (or Control-click) MorseRunner.app
   - Choose "Open" from the menu
   - Click "Open" in the dialog that appears
   You only need to do this once; subsequent launches work normally.

4. The app window will open. Select a contest mode from the Contest menu, set your
   callsign and exchange in the right-hand panel, then press F1 or click Start.

Requirements: macOS 11.0 (Big Sur) or later, Apple M1 or newer.


Building from Source
--------------------
Prerequisites:
  - Lazarus IDE (includes FPC 3.2.2): https://www.lazarus-ide.org
  - Xcode Command Line Tools: xcode-select --install

Build:
  cd MorseRunner
  bash build_mac.sh

The script compiles AudioBackend2.m with clang, compiles all Pascal units with
lazbuild, links with ld-classic (required — see technical notes below), and
produces MorseRunner.app and MorseRunner.zip.

Intermediate binary: MR_mac (the raw Mach-O executable before bundling)
Application bundle:  MorseRunner.app
Distributable zip:   MorseRunner.zip


Technical Background
--------------------

Overview of changes from Windows original
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Source files: 53 .pas + 2 .lfm + 1 .lpr + 1 .m  (vs 50 .pas + 2 .dfm + 1 .dpr)
Unchanged:    ~40 files — contest logic, station simulation, Morse keyer, DSP/mixing,
              exchange parsing. Pure Pascal, no Windows dependencies.
Ported:       UI (VCL → LCL), audio (MMSystem → CoreAudio), regex (PCRE .obj → FPC
              RegExpr), path resolution, form files (.dfm → .lfm).

Key library substitutions
~~~~~~~~~~~~~~~~~~~~~~~~~~
  UI framework      VCL (Vcl.Forms, Vcl.ToolWin, ...)  →  LCL (Forms, ComCtrls, ...)
  UI platform       Win32 GDI / Windows, Messages       →  LCLIntf, LCLType (Cocoa)
  Regular exprs     PerlRegEx + Windows x86 PCRE .obj   →  FPC RegExpr (wrapper kept)
  Audio             MMSystem waveOutOpen/Write/Close     →  CoreAudio via AudioBackend2.m
  HTTP              Indy IdHTTP                          →  FPC fphttpclient
  Shell             ShellExecute                        →  LCLIntf.OpenURL
  Standard units    System.Classes, System.SysUtils      →  Classes, SysUtils (plain FPC)
  Path resolution   ParamStr(1) / ParamStr(0)            →  GetDataPath (Resources)
                                                            GetUserPath (next to .app)
  Form files        .dfm (Delphi)                        →  .lfm (Lazarus)
  Compiler          Delphi RAD Studio                   →  FPC 3.2.2 (ppca64)
  Linker            MSVC linker                         →  ld-classic (see below)
  Build system      .dproj                              →  build_mac.sh


License
-------
Mozilla Public License 2.0 (inherited from Morse Runner Community Edition upstream).
