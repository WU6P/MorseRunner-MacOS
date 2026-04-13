program MorseRunner;

{$ifdef FPC}{$MODE Delphi}{$endif}
{$H+}

// Unit search paths — mac/ overrides root for platform-specific units
{$UNITPATH mac}
{$UNITPATH mac/VCL}
{$UNITPATH .}
{$UNITPATH VCL}
{$UNITPATH Util}

uses
  {$ifdef unix}
  cthreads,
  {$endif}
  Interfaces,   // LCL widgetset (Cocoa on macOS)
  Forms,
  Main     in 'mac/Main.pas',
  ScoreDlg in 'ScoreDlg.pas',
  Log      in 'mac/Log.pas';

{$R *.res}

begin
  Application.Title := 'Morse Runner';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
