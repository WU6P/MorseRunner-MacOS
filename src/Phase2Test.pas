program Phase2Test;
{$MODE objfpc}
{$H+}
// Phase 2 compilation test: checks that core logic units compile under FPC 3.3.1

uses
  SysUtils,
  // VCL DSP/audio types
  SndTypes, Mixers, MovAvg, QuickAvg, VolumCtl, MorseTbl, MorseKey, FarnsKeyer,
  Crc32,
  // Core logic
  ExchFields, RndFunc, Qsb, Station, DxOper, Ini,
  StnColl, DxStn, MyStn,
  Log,
  Contest,
  // Contest implementations
  DXCC, ArrlSections, CallLst, SerNRGen,
  DualExchContest, CqWW, CqWpx, ArrlDx, ArrlFd, ArrlSS,
  CWOPS, CWSST, NaQp, ACAG, ALLJA, IaruHf,
  // Util
  Lexer, SSExchParser;

begin
  WriteLn('Phase 2 compilation test passed.');
end.
