// TestRunner.pas — Minimal FPCUnit console test runner for MR_mac unit tests.
// Does not use TTestRunner/CustApp (which requires MacOSAll on this FPC build).
// Instead drives fpcunit directly via TTestResult.
program TestRunner;
{$ifdef FPC}{$MODE Delphi}{$endif}

uses
  SysUtils, Classes,
  fpcunit, testregistry, plaintestreport,
  // Test units — each registers its fixture in initialization
  PerlRegExTest,
  LexerTestFPC,
  SSExchParserTestFPC,
  DxOperTestFPC;

var
  Suite  : TTestSuite;
  Res    : TTestResult;
  Writer : TPlainResultsWriter;
begin
  Suite  := GetTestRegistry;
  Res    := TTestResult.Create;
  Writer := TPlainResultsWriter.Create(nil);
  try
    Res.AddListener(Writer);
    Suite.Run(Res);
    Writer.WriteResult(Res);
    WriteLn;
    WriteLn(Format('Tests run: %d  Failures: %d  Errors: %d',
      [Suite.CountTestCases, Res.NumberOfFailures, Res.NumberOfErrors]));
    if (Res.NumberOfFailures = 0) and (Res.NumberOfErrors = 0) then
      WriteLn('ALL TESTS PASSED.')
    else
      WriteLn('SOME TESTS FAILED.');
  finally
    Writer.Free;
    Res.Free;
  end;
end.
