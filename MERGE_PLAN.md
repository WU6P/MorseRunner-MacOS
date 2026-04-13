# MR_merge Project Plan

## Goal
Combine the Windows Delphi project (MR) and macOS Lazarus port (MorseRunner) into a
single codebase. MR's file structure is the base. Shared units get `{$ifdef FPC}`
conditionals. Heavy platform-divergent files live as **separate copies** in a `mac/`
subdirectory with the same unit names — FPC's search path resolves to `mac/` first,
Delphi never sees it.

---

## Directory Layout

```
MR_merge/
  MorseRunner.dpr          ← Delphi entry (unchanged from MR)
  MorseRunner.dproj        ← Delphi project (unchanged from MR)
  MorseRunner.lpr          ← Lazarus entry (points to mac/ units)
  MorseRunner.lpi          ← Lazarus project (search path: mac > root)
  build.sh                 ← macOS build script (lazbuild + clang)

  Main.pas                 ← Windows version (original MR)
  Main.dfm                 ← Delphi form
  Log.pas                  ← Windows version
  Ini.pas                  ← Windows version
  ScoreDlg.pas             ← Shared (has {$ifdef FPC} blocks)
  ScoreDlg.dfm             ← Delphi form
  Contest.pas              ← Shared (has {$ifdef FPC} blocks)
  Station.pas              ← Shared (has {$ifdef FPC} blocks)
  ... (38 other shared .pas files with {$ifdef FPC} conditionals)

  VCL/
    SndOut.pas             ← Windows version (MMSystem waveOut)
    SndCustm.pas           ← Windows version
    WavFile.pas            ← Windows version
    VolmSldr.pas           ← Windows version
    PermHint.pas           ← Windows version
    BaseComp.pas           ← Shared (has {$ifdef} blocks)
    ... (9 other shared VCL units)

  mac/                     ← macOS-only overrides (same unit names)
    Main.pas               ← macOS version (LCL/Cocoa)
    Main.lfm               ← Lazarus form
    Log.pas                ← macOS version (TMemo-based)
    Ini.pas                ← macOS version (TIniFile-based)
    PerlRegEx.pas          ← FPC regex wrapper (replaces pcre.pas)
    Globals.pas            ← Circular dependency breaker (FPC-only)
    GetDataPath.pas        ← .app bundle path resolution (FPC-only)
    ContestFactory.pas     ← Contest factory (FPC-only)
    ScoreDlg.lfm           ← Lazarus score dialog form
    VCL/
      SndOut.pas           ← macOS version (CoreAudio)
      SndCustm.pas         ← macOS version
      WavFile.pas          ← macOS version
      VolmSldr.pas         ← macOS version (LCL slider)
      PermHint.pas         ← macOS version (LCL hints)
      AudioBackend2.m      ← Obj-C CoreAudio backend

  PerlRegEx/               ← Windows PCRE (unchanged, Delphi only)
  Util/                    ← Shared utilities (with {$ifdef FPC})
  Test/                    ← Delphi test project (unchanged)
  tools/                   ← Build tools (unchanged)
  ... (data files, resources, docs — unchanged)
```

## Key Design Decision: Dual-file approach for heavy units

Files with >150 diff lines between Windows and macOS are kept as **separate platform
copies** rather than merged with `{$ifdef}`. Rationale:

- Main.pas has 3500 diff lines — merging would be unreadable
- Audio stack (SndOut, SndCustm, WavFile) uses completely different OS APIs
- Log.pas: TRichEdit vs TMemo with no shared formatting code
- Ini.pas: TRegistry vs TIniFile with different read/write patterns

FPC resolves `mac/` first via search path order, so `uses SndOut` picks up
`mac/VCL/SndOut.pas` on macOS and `VCL/SndOut.pas` on Windows.

---

## File Status Summary

### Shared files — modified with `{$ifdef FPC}` conditionals (38 files)

**Trivial (1-line MODE directive, 13 files) — DONE:**
StnColl, DualExchContest, MorseKey, FarnsKeyer, Mixers, MorseTbl,
ArrlSections, Qsb, RndFunc, MovAvg, QuickAvg, VolumCtl, SndTypes

**Small changes (10-50 diff lines, 18 files) — DONE:**
CallLst, DxOper, MyStn, DXCC, CqWpx, ExchFields, CWOPS, CqWW, CWSST,
ALLJA, ACAG, ArrlDx, IaruHf, NaQp, ScoreDlg, SerNRGen, ArrlSS, DxStn

**Medium changes (50-150 diff lines, 7 files) — DONE:**
ArrlFd, SSExchParser, Lexer, Station, BaseComp, Contest
(PermHint moved to dual-file)

### Dual-file units — separate win/mac versions (8 units, 15 files)

| Unit | Windows (root) | macOS (mac/) | Status |
|------|---------------|-------------|--------|
| Main | Main.pas + Main.dfm | mac/Main.pas + mac/Main.lfm | DONE |
| Log | Log.pas | mac/Log.pas | DONE |
| Ini | Ini.pas | mac/Ini.pas | DONE |
| PerlRegEx | PerlRegEx/PerlRegEx.pas | mac/PerlRegEx.pas | DONE |
| SndOut | VCL/SndOut.pas | mac/VCL/SndOut.pas | DONE |
| SndCustm | VCL/SndCustm.pas | mac/VCL/SndCustm.pas | DONE |
| WavFile | VCL/WavFile.pas | mac/VCL/WavFile.pas | DONE |
| VolmSldr | VCL/VolmSldr.pas | mac/VCL/VolmSldr.pas | DONE |
| PermHint | VCL/PermHint.pas | mac/VCL/PermHint.pas | DONE |

### macOS-only new files (in mac/)

| File | Purpose | Status |
|------|---------|--------|
| mac/Globals.pas | Break Main↔Contest circular dep | DONE |
| mac/GetDataPath.pas | .app bundle resource path | DONE |
| mac/ContestFactory.pas | Factory for contest creation | DONE |
| mac/VCL/AudioBackend2.m | CoreAudio Obj-C backend | DONE |
| mac/ScoreDlg.lfm | Lazarus score dialog form | DONE |

### Untouched files from MR (~35-40 files)

- PerlRegEx/pcre.pas + all .obj files (Windows PCRE)
- PerlRegEx/PerlRegEx.pas (Delphi version)
- Data files: MASTER.DTA, DXCC.LIST, CWOPS.LIST, *.txt (~12 files)
- Delphi project: MorseRunner.dpr, .dproj, MRCE.groupproj
- Forms: Main.dfm, ScoreDlg.dfm
- Tests: Test/*.pas, UnitTests.dpr, UnitTests.dproj
- Resources: .ico, .bmp, .otares, manifest.xml
- Docs: LICENSE.md, README.md, Readme.txt
- .github/, tools/

### New project/build files created

| File | Purpose | Status |
|------|---------|--------|
| MorseRunner.lpr | Lazarus program file | DONE |
| MorseRunner.lpi | Lazarus project info | DONE |
| build.sh | macOS build script | DONE |
| Info.plist | macOS .app metadata | DONE |

---

## Execution Phases

### Phase 1 — Setup [DONE]
- Created MR_merge/ with all MR files
- Added mac/ subdirectory with macOS-specific files
- Created Lazarus project files (.lpr, .lpi) with mac/ search paths
- Copied build scripts

### Phase 2 — Trivial units (13 files) [DONE]
- Added {$ifdef FPC}{$MODE Delphi}{$endif} + conditional uses

### Phase 3 — Small/medium shared units (25 files) [DONE]
- Added {$ifdef FPC} for: uses clauses, const→constref, ParamStr→GetDataPath,
  MainForm→Globals, System.X→X, inline vars, TStringList constructors

### Phase 4 — Heavy units (dual-file approach) [DONE]
- Placed macOS versions in mac/ and mac/VCL/
- Windows versions stay at root (untouched from MR)
- FPC search path: mac/ > mac/VCL/ > root > VCL/ > Util/

### Phase 5 — Test build on macOS [DONE]
- Fixed 6 units with mangled {$MODE Delphi} directive (FarnsKeyer, Qsb, StnColl, DualExchContest, RndFunc, Mixers, MorseKey)
- Added {$MODE Delphi} to QrmStn, QrnStn (string vs ShortString mismatch)
- Fixed VCL/Crc32.pas: conditional Windows uses
- Fixed mac/ContestFactory.pas: lowercase unit names (ArrlFd, NaQp, etc.)
- Fixed ArrlFd.pas: duplicate Generics.Collections in impl uses
- Added MorseRunner.res (copied from MorseRunner project)
- Fixed linker crash: Xcode 16 ld 1230.1 segfaults on FPC's -multiply_defined suppress flag.
  build.sh now patches ppaslink.sh to use ld-classic and assembles the .app bundle manually.
- App launches successfully

---

## Remaining Risks

1. **Search path priority**: FPC must find mac/*.pas before root/*.pas.
   The .lpi OtherUnitFiles and build.sh -Fu flags set mac/ first.
   If lazbuild ignores the order, compilation will fail with Windows API errors.

2. **Shared units reference Globals/GetDataPath**: Under FPC, these are found
   in mac/. Under Delphi, they don't exist but are inside {$ifdef FPC} guards.
   Any missed guard = Delphi compile error.

3. **Form file pairing**: Main_mac.pas in mac/ must find Main.lfm in mac/.
   The {$R *.lfm} directive searches relative to the unit file location,
   so this should work since both are in mac/.

4. **ScoreDlg.lfm location**: ScoreDlg.pas is a shared file at root level
   but its .lfm is in mac/. The {$ifdef FPC}{$R *.lfm} may not find it.
   May need to move ScoreDlg.lfm to root or adjust the resource path.

5. **Future maintenance**: Changes to shared units must be tested on both
   platforms. Changes to dual-file units must be applied to both copies.
