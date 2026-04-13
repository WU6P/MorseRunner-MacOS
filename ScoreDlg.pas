//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit ScoreDlg;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  {$ifdef MSWINDOWS}Windows, Messages,{$endif}
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  StdCtrls, ini;

type
  TScoreDialog = class(TForm)
    Label1: TLabel;
    Edit1: TEdit;
    Button1: TButton;
    Button2: TButton;
    Label2: TLabel;
    Label3: TLabel;
    Button3: TButton;
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure Button3Click(Sender: TObject);
  end;

var
  ScoreDialog: TScoreDialog;

implementation

uses {$ifdef FPC}Globals{$else}Main{$endif};

{$ifdef FPC}{$R *.lfm}{$else}{$R *.DFM}{$endif}

procedure TScoreDialog.Button1Click(Sender: TObject);
begin
  {$ifdef FPC}
  if Assigned(Globals.GViewScoreBoardProc) then Globals.GViewScoreBoardProc();
  {$else}
  MainForm.ViewScoreBoardMNU.Click;
  {$endif}
end;

procedure TScoreDialog.Button2Click(Sender: TObject);
begin
  Close;
end;

procedure TScoreDialog.Button3Click(Sender: TObject);
begin
  {$ifdef FPC}
  if Assigned(Globals.GPostHiScoreProc) then Globals.GPostHiScoreProc(Edit1.Text);
  {$else}
  MainForm.PostHiScore(Edit1.Text);
  {$endif}
end;

procedure TScoreDialog.FormCreate(Sender: TObject);
begin
  Button3.Enabled := Length(SubmitHiScoreURL) > 0;
end;

end.
