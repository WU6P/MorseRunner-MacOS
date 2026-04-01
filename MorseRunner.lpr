program MorseRunner;

{$ifdef FPC}{$MODE Delphi}{$endif}
{$H+}

// Unit search paths — belt-and-suspenders in addition to .lpi OtherUnitFiles
{$UNITPATH src}
{$UNITPATH src/VCL}
{$UNITPATH src/Util}

uses
  {$ifdef unix}
  cthreads,
  {$endif}
  Interfaces,   // LCL widgetset (Cocoa on macOS)
  Forms,
  Main     in 'src/Main.pas',
  ScoreDlg in 'src/ScoreDlg.pas',
  Log      in 'src/Log.pas';

{$R *.res}

begin
  Application.Title := 'Morse Runner';
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
