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

Audio subsystem
~~~~~~~~~~~~~~~
The Windows original used MMSystem (waveOutOpen/Write/Close). On macOS this was
replaced with CoreAudio. Because LCL's Pascal cannot call Objective-C APIs directly,
a thin Obj-C bridge file (src/VCL/AudioBackend2.m) wraps the CoreAudio callback
interface. It is compiled separately with clang and linked into the final binary.

ld-classic linker requirement
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
FPC 3.2.2 generates Obj-C metadata atoms in its compiled Cocoa widgetset .o files
that are rejected by the new ld-prime linker shipped with macOS 26 / Xcode 16
toolchain (ld-1230.x). Specifically, the __objc_const section contains malformed
split symbols that cause ld-prime to segfault or refuse to link.

The workaround is to use ld-classic (/Library/Developer/CommandLineTools/usr/bin/
ld-classic), which ships alongside ld-prime and does not enforce this validation.
build_mac.sh automates this: it lets lazbuild generate ppaslink.sh (the link
command file), patches it to substitute ld-classic for ld, then re-runs the link.

Path resolution inside .app bundle
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
On macOS, applications must use NSBundle to locate bundled resources rather than
paths relative to the working directory or argv[0]. GetDataPath.pas provides two
functions:
  GetDataPath  — returns .app/Contents/Resources/ (read-only contest data files)
  GetUserPath  — returns the folder next to .app (INI, WAV, log files)
Eleven source files that used ParamStr(1) as a path prefix were updated to use
GetDataPath.GetDataPath() instead.

FPC 3.2.2 incompatibilities with Delphi source
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Several patterns in the original Delphi code needed adjustment for FPC 3.2.2:

1. Inline var declarations (var X: T := V; inside begin/end) — not supported.
   Move declarations to the function var block.

2. For-loop inline vars (for var X: T in collection) — not supported.
   Declare the loop variable in the var block.

3. TArray.BinarySearch<T> — not available in FPC generics.
   Replaced with hand-written binary search.

4. TComparer<T>.Construct with static class methods — FPC 3.2.2 requires constref
   parameters; const is incompatible. All affected static comparators changed from
   (const left, right: T) to (constref left, right: T). (FPC 3.3.1 is more
   permissive but is not used here.)

5. Anonymous functions inside TComparer<T>.Construct — rejected by FPC 3.2.2.
   Replaced with standalone wrapper functions.

6. System.Classes, System.SysUtils, Vcl.* — namespace prefixes stripped.

7. TStringList.Create(Boolean) — FPC has no Boolean overload; use plain Create.

8. TRegExpr API vs TPerlRegEx — PerlRegEx.pas wrapper maps the Delphi API to FPC's
   RegExpr (Exec/ExecNext instead of Match/MatchAgain, etc.).

9. Name shadowing — TLexer.Pos field shadows built-in Pos() function; resolved by
   qualifying as System.Pos().

10. TStringList.Sort() does not set the Sorted flag in FPC — must also set
    Sorted := True explicitly for Find() to work correctly afterwards.

11. TList<T>.BinarySearch index parameter — FPC expects var index: Int64, not
    Integer.

12. TStringList.Create(TDuplicates, Boolean, Boolean) — Delphi-only 3-param
    overload. Use Create then set .Duplicates, .Sorted, .CaseSensitive separately.

13. Unit name / function name collision — when a unit and an exported function share
    the same name (e.g. unit GetDataPath exports function GetDataPath), FPC requires
    the unit-qualified form: GetDataPath.GetDataPath(). Bare use gives "Syntax
    error, '.' expected".

Keyboard focus when launching from Finder/Spotlight
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
When launched from Finder or Spotlight (rather than the Terminal), macOS does not
always make the application the active key window before the first form is shown.
The fix is to call Application.BringToFront (which invokes NSApp
activateIgnoringOtherApps on the Cocoa side) in the FormShow handler, before
SetForegroundWindow and SetFocus. This ensures text entry fields accept keyboard
input regardless of how the app was launched.


License
-------
Mozilla Public License 2.0 (inherited from Morse Runner Community Edition upstream).
