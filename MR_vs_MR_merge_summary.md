# MR vs MR_merge — File Comparison Summary

**Date:** 2026-04-13

MR is the original Windows-only Delphi project.
MR_merge combines MR (Windows) + MR_mac (macOS) into one codebase that compiles
on both platforms.

---

## 1. Unchanged Files (Identical Content)

These files exist in both MR and MR_merge with **zero** content changes.

### Windows-Specific Units (renamed with `_win` suffix, content identical)

| MR | MR_merge | Notes |
|----|----------|-------|
| Main.pas | Main_win.pas | Renamed only |
| Log.pas | Log_win.pas | Renamed only |
| Ini.pas | Ini_win.pas | Renamed only |
| VCL/SndOut.pas | VCL/SndOut_win.pas | Renamed only |
| VCL/SndCustm.pas | VCL/SndCustm_win.pas | Renamed only |
| VCL/WavFile.pas | VCL/WavFile_win.pas | Renamed only |
| VCL/VolmSldr.pas | VCL/VolmSldr_win.pas | Renamed only |
| VCL/PermHint.pas | VCL/PermHint_win.pas | Renamed only |
| PerlRegEx/PerlRegEx.pas | PerlRegEx/PerlRegEx_win.pas | Renamed only |

> The `_win` suffix avoids filename collisions with the macOS versions in `mac/`.
> The internal `unit` declaration is unchanged (e.g. still `unit Main;`).
> Delphi's `.dpr` uses `in` clauses to map unit names to the `_win` filenames.

### Forms, Resources, Data Files, Tests, Tools (byte-identical)

| Category | Files |
|----------|-------|
| Delphi forms | Main.dfm, ScoreDlg.dfm |
| Icons/bitmaps | MorseRunner.ico, MorseRunner_Icon.ico, _Icon1–3.ico, MorseRunner16.bmp, MorseRunner32.bmp |
| Data files | MASTER.DTA, DXCC.LIST, CWOPS.LIST, NAQPCW.txt, CQWWCW.txt, ARRLDXCW_USDX.txt, FDGOTA.txt, K1USNSST.txt, IARU_HF.txt, HstResults.txt, SSCW.txt, JARL_ACAG.TXT, JARL_ALLJA.TXT, Readme.txt |
| Documentation | LICENSE.md, README.md, MorseRunner171a.pdf |
| VCL package | VCL/MorseRunnerVcl.dpk, VCL/MorseRunnerVcl.dproj, VCL/VolmSldr.dcr, VCL/VolumCtl.dcr |
| Tests | Test/DxOperTest.pas, LexerTest.pas, MySSExchTest.pas, SSExchParserTest.pas, SSLexerTest.pas, UnitTests.dpr, UnitTests.dproj |
| PerlRegEx | PerlRegEx/pcre.pas, PerlRegEx/pcre/*.obj (20 files), PerlRegEx/*.hlp/*.cnt, PerlRegEx/README.txt |
| Tools | tools/make-install.sh, tools/verify-normalization.sh |
| Config | MRCE.groupproj, MorseRunner.cmds, MorseRunner.deployproj, MorseRunner.lst, MorseRunner.otares, manifest.xml |
| GitHub | .github/ (all files) |

---

## 2. Modified Files — Delphi Project References

Only 2 project files were modified, and **only** to update the `_win` filenames:

### MorseRunner.dpr

All 9 `in` clauses updated:

```
Main in 'Main.pas'              → Main in 'Main_win.pas'
Log in 'Log.pas'                → Log in 'Log_win.pas'
Ini in 'Ini.pas'                → Ini in 'Ini_win.pas'
PermHint in 'VCL\PermHint.pas' → PermHint in 'VCL\PermHint_win.pas'
SndCustm in 'VCL\SndCustm.pas' → SndCustm in 'VCL\SndCustm_win.pas'
SndOut in 'VCL\SndOut.pas'      → SndOut in 'VCL\SndOut_win.pas'
VolmSldr in 'VCL\VolmSldr.pas' → VolmSldr in 'VCL\VolmSldr_win.pas'
WavFile in 'VCL\WavFile.pas'   → WavFile in 'VCL\WavFile_win.pas'
PerlRegEx in 'PerlRegEx\PerlRegEx.pas' → PerlRegEx in 'PerlRegEx\PerlRegEx_win.pas'
```

### MorseRunner.dproj

Same 9 `<DCCReference Include=...>` entries updated to match the `_win` filenames.

---

## 3. Modified Files — Shared Units with `{$ifdef FPC}` Conditionals

These 40 files have FPC/macOS conditional code added while preserving the original
Delphi code paths unchanged. The Delphi compiler ignores all `{$ifdef FPC}` blocks.

### Recurring Patterns Applied Across Files

| Pattern | What | Why |
|---------|------|-----|
| `{$ifdef FPC}{$MODE Delphi}{$endif}` | Compiler mode directive | FPC needs this for Delphi syntax compatibility |
| `System.X` → `{$ifdef FPC}X{$else}System.X{$endif}` | Unit name shortening | FPC uses `Classes` not `System.Classes`, `Math` not `System.Math` |
| `const` → `{$ifdef FPC}constref{$else}const{$endif}` | Parameter passing | FPC generics (TComparer) require `constref` |
| `ParamStr(1)` → `GetDataPath.GetDataPath` | Data file path | macOS .app bundle puts data in Contents/Resources/ |
| `MainForm.X` → `Globals.GX` | UI decoupling | macOS uses different Main.pas; Globals breaks circular dependency |
| Inline `var` → block-level `var` | Variable declarations | FPC doesn't support Delphi 10.3+ inline var syntax |
| `{$ifdef MSWINDOWS}Windows, Messages{$endif}` | Windows-only units | Exclude Windows API units on macOS |
| `{$ifdef FPC}{$R *.lfm}{$else}{$R *.DFM}{$endif}` | Form resources | Lazarus uses .lfm, Delphi uses .dfm |

### Per-File Change Summary

#### Trivial — `{$MODE Delphi}` only (7 files)

| File | Change |
|------|--------|
| DualExchContest.pas | `{$MODE Delphi}` added |
| QrmStn.pas | `{$MODE Delphi}` added |
| QrnStn.pas | `{$MODE Delphi}` added |
| Qsb.pas | `{$MODE Delphi}` added |
| RndFunc.pas | `{$MODE Delphi}` added |
| StnColl.pas | `{$MODE Delphi}` added |
| Util/ArrlSections.pas | `{$MODE Delphi}` added |

#### Small — `{$MODE Delphi}` + unit name fixes + data path (22 files)

| File | Changes |
|------|---------|
| ACAG.pas | `System.StrUtils`→`StrUtils`, +`GetDataPath`, `const`→`constref`, `ParamStr(1)`→`GetDataPath` |
| ALLJA.pas | Same pattern as ACAG |
| ArrlDx.pas | +`GetDataPath`, `const`→`constref`, excludes `Main` under FPC, `ParamStr(1)`→`GetDataPath` |
| CallLst.pas | `{$MODE Delphi}`, +`GetDataPath`, path resolution changed |
| CqWW.pas | +`GetDataPath`, `const`→`constref`, `ParamStr(1)`→`GetDataPath` |
| CWOPS.pas | `{$MODE Delphi}`, +`GetDataPath`, `const`→`constref`, `ParamStr(1)`→`GetDataPath` |
| CWSST.pas | Same pattern as CWOPS |
| DXCC.pas | `{$MODE Delphi}`, +`GetDataPath`, `ParamStr(1)`→`GetDataPath` |
| DxOper.pas | `{$MODE Delphi}`, `Main`→`Globals`, `MainForm.Edit1.Text`→`Globals.GEdit1Text` |
| DxStn.pas | `{$MODE Delphi}`, `Dialogs` excluded, `Main`→`Globals`, status bar + edit fields via Globals |
| FarnsKeyer.pas | `{$MODE Delphi}` |
| IaruHf.pas | +`GetDataPath`, `const`→`constref`, exclude `Main`, TStringList constructor fix |
| Mixers.pas | `{$MODE Delphi}` |
| MorseKey.pas | `{$MODE Delphi}` |
| MorseTbl.pas | `{$MODE Delphi}` |
| MyStn.pas | `{$MODE Delphi}`, `Main`→`Globals`, `MainForm.Advance`→`Globals.GAdvanceProc` |
| CqWpx.pas | `System.Math`→`Math`, `Main`→`Globals`, `MainForm.SetMySerialNR`→`Globals.GSetMySerialNRProc` |
| Crc32.pas | `{$MODE Delphi}`, `Windows` conditional on MSWINDOWS |
| MovAvg.pas | `{$MODE Delphi}`, Windows-only units wrapped in `{$ifdef MSWINDOWS}` |
| QuickAvg.pas | `{$MODE Delphi}`, Windows-only units wrapped in `{$ifdef MSWINDOWS}` |
| SndTypes.pas | `{$MODE Delphi}`, `Windows/MMSystem/ComObj` wrapped, `TWaveHdr` field wrapped |
| VolumCtl.pas | `{$MODE Delphi}`, Windows-only units wrapped in `{$ifdef MSWINDOWS}` |

#### Medium — Significant `{$ifdef}` blocks (11 files)

| File | Key Changes |
|------|-------------|
| ArrlFd.pas | +`GetDataPath`, `constref`, `System.Generics.Collections`→`Generics.Collections`, `Clipbrd` for FPC, `ComparePendingCallWrapper` function added for FPC, inline vars hoisted |
| ArrlSS.pas | +`GetDataPath`, `constref`, `GetCheckSection` marked `override` for FPC, inline vars hoisted |
| NaQp.pas | +`GetDataPath`, `ExchFields` moved to interface uses, `constref`, `IsCallLocalToContest` override, `index: integer`→`int64` for binary search, inline vars hoisted |
| SerNRGen.pas | `System.Math`→`Math`, inline vars hoisted, binary search reimplemented manually for FPC (FPC lacks the specific TArray.BinarySearch overload) |
| ScoreDlg.pas | `{$MODE Delphi}`, `Windows/Messages` conditional, `Main`→`Globals`, `{$R *.lfm}` for FPC, button handlers use Globals callbacks |
| ExchFields.pas | `{$MODE Delphi}`, duplicate `TExchTypes` record with `class operator Equal` added for FPC (type originally defined in Main.pas) |
| Util/Lexer.pas | `{$MODE Delphi}`, `System.Classes`→`Classes` |
| Util/SSExchParser.pas | `{$MODE Delphi}`, `System.X`→`X`, `TStringList.Create(False)`→`Create` + `.Sorted := True`, inline vars hoisted, conditional `begin`/`end` blocks |
| BaseComp.pas | `{$MODE Delphi}`, `Windows/Messages` conditional, `FHandle`/`AllocateHWnd`/`DeallocateHWnd`/`WndProc` wrapped in `{$ifdef MSWINDOWS}` |
| Station.pas | `{$MODE Delphi}`, `ExchTypesUndef` init moved to `initialization` section, `Main`→`Globals`, inline vars hoisted |
| Contest.pas | **Largest diff.** `System.Classes`→`Classes`, virtual methods `IsCallLocalToContest`/`GetCheckSection` added, all `MainForm.Edit/Panel/VolumeSlider` references → `Globals.G*` vars/callbacks, WAV file via `Globals.GAlWavFile1`, `MainForm.Run(rmStop)` → `Globals.GRunStopProc` |

---

## 4. New Files in MR_merge (Not in MR)

### macOS Platform Units (in `mac/`)

| File | Purpose |
|------|---------|
| mac/Main.pas + mac/Main.lfm | macOS main form (LCL/Cocoa). Complete rewrite — uses TMemo instead of TRichEdit, LCL controls, Cocoa-compatible event handling, CoreAudio integration |
| mac/Log.pas | macOS logging — TMemo-based instead of TRichEdit, no Windows message handling |
| mac/Ini.pas | macOS settings — TIniFile-based instead of TRegistry, defines contest type records |
| mac/Globals.pas | Shared global state — breaks Main↔Contest circular dependency. Defines all `G*` variables and callback function pointers used by shared units |
| mac/GetDataPath.pas | Resolves data file path inside .app bundle (`Contents/Resources/`) |
| mac/ContestFactory.pas | Factory pattern for contest creation — replaces case statement that was in Main.pas |
| mac/PerlRegEx.pas | FPC regex wrapper — provides TPerlRegEx interface using FPC's built-in TRegExpr |
| mac/ScoreDlg.lfm | Lazarus form for score dialog |

### macOS Audio Stack (in `mac/VCL/`)

| File | Purpose |
|------|---------|
| mac/VCL/SndOut.pas | CoreAudio audio output — replaces MMSystem waveOut |
| mac/VCL/SndCustm.pas | macOS sound customization layer |
| mac/VCL/WavFile.pas | macOS WAV file handling |
| mac/VCL/VolmSldr.pas | LCL volume slider component |
| mac/VCL/PermHint.pas | LCL persistent hint component |
| mac/VCL/AudioBackend2.m | Objective-C CoreAudio backend (compiled separately with clang) |

### Build/Project Files

| File | Purpose |
|------|---------|
| MorseRunner.lpr | Lazarus program file (macOS entry point) |
| MorseRunner.lpi | Lazarus project info (unit search paths: mac > mac/VCL > root > VCL > Util) |
| build.sh | macOS build script — compiles AudioBackend2.m, runs lazbuild, patches linker for ld-classic, assembles .app bundle |
| build_mac.sh | Alternate macOS build script (from MR_mac port) |
| release.sh | Release packaging script |
| Info.plist | macOS .app bundle metadata |
| ScoreDlg.lfm | Lazarus score dialog form (root copy, identical to mac/ copy) |
| MorseRunner_Icon4.ico | Additional icon variant |
| MorseRunner.res | Lazarus resource file |
| MERGE_PLAN.md | Documents the merge strategy and file status |

---

## 5. Architecture Summary

```
MR_merge/
│
├── Delphi (Windows) path:
│   MorseRunner.dpr → Main_win.pas, Log_win.pas, Ini_win.pas
│                    → VCL/*_win.pas (SndOut, SndCustm, WavFile, VolmSldr, PermHint)
│                    → PerlRegEx/PerlRegEx_win.pas
│                    → Shared *.pas (with {$ifdef FPC} blocks ignored by Delphi)
│
├── Lazarus (macOS) path:
│   MorseRunner.lpr → mac/Main.pas, mac/Log.pas, mac/Ini.pas
│                    → mac/VCL/*.pas (SndOut, SndCustm, WavFile, VolmSldr, PermHint)
│                    → mac/PerlRegEx.pas, mac/Globals.pas, mac/GetDataPath.pas
│                    → mac/ContestFactory.pas
│                    → Shared *.pas (FPC reads the {$ifdef FPC} code paths)
│
└── Shared (both platforms):
    40 .pas files with {$ifdef FPC} conditionals
    All data files, test files, icons, forms (.dfm), tools
```

### Key Design Decision

Files with >150 diff lines between platforms are kept as **separate copies**
rather than merged with `{$ifdef}`:
- Main.pas — 3500+ diff lines (completely different UI framework)
- Audio stack — completely different OS APIs (MMSystem vs CoreAudio)
- Log.pas — TRichEdit vs TMemo
- Ini.pas — TRegistry vs TIniFile

Files with <150 diff lines use **inline `{$ifdef FPC}` conditionals** to keep
a single source of truth.

---

## 6. File Count Summary

| Category | MR (original) | MR_merge | Delta |
|----------|---------------|----------|-------|
| Shared .pas (with `{$ifdef}` added) | 40 | 40 | 0 new, 40 modified |
| Windows-only .pas (renamed) | 9 | 9 | 0 new, 9 renamed |
| macOS-only .pas (new) | 0 | 13 | +13 |
| macOS .m (Obj-C) | 0 | 1 | +1 |
| Lazarus project files | 0 | 2 | +2 (.lpr, .lpi) |
| Lazarus form files | 0 | 3 | +3 (.lfm) |
| Build scripts | 0 | 3 | +3 |
| macOS config (Info.plist) | 0 | 1 | +1 |
| Delphi project files (modified) | 2 | 2 | 0 new, 2 modified |
| Everything else (identical) | ~55 | ~55 | 0 |
| **Total** | **~108** | **~131** | **+23 new files** |
