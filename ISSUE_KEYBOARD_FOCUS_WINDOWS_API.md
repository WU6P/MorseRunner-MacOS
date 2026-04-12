# Issue: Windows-only API calls in FormShow (Line 767-768)

## Problem
The original code used Windows VCL APIs that don't exist in Lazarus/LCL:
```pascal
Application.Activate;        // VCL only — LCL has no Activate method
SetForegroundWindow(Handle); // Windows API — not available on macOS
```

These caused:
```
Error: (5038) identifier idents no member "Activate"
```

## Why This Failed
- `Application.Activate` is a VCL (Windows) method; LCL doesn't implement it
- `SetForegroundWindow()` is Windows-specific; there's no macOS equivalent in LCL
- Delphi code targeting Windows doesn't automatically port to LCL without platform-specific rewrites

## Solution Applied
Replaced with LCL cross-platform equivalent:
```pascal
Application.BringToFront;  // LCL method, works on macOS
Edit4.SetFocus;            // LCL method, works on macOS
```

## Lesson
When porting from Delphi/VCL to Lazarus/LCL:
- Avoid `Application.Activate`, use `Application.BringToFront`
- Don't use Windows APIs directly; use LCL equivalents
- Test on target platform (macOS) early to catch platform-specific failures
