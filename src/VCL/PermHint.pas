//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// PermHint.pas — macOS/LCL port
// Original Windows version used GetCursorPos (WinAPI) and x86 assembler to
// compute cursor height margin. On macOS: use Mouse.CursorPos from LCLIntf,
// and return a fixed cursor height margin (macOS cursors are always ~16px).
unit PermHint;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, LCLIntf;

type
  TPermanentHintWindow = class(THintWindow)
  public
    Active: boolean;

    constructor Create(AOwner: TComponent); override;
    procedure ShowHint(Txt: string);
    procedure ShowHintAt(Txt: string; x, y: integer);
    procedure HideHint;
  end;

function GetCursorHeightMargin: Integer;

implementation

{ TPermanentHintWindow }

constructor TPermanentHintWindow.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  Color := clInfoBk;
end;


procedure TPermanentHintWindow.ShowHint(Txt: string);
var
  P: TPoint;
begin
  P := Mouse.CursorPos;
  ShowHintAt(Txt, P.x, P.y + GetCursorHeightMargin);
end;


procedure TPermanentHintWindow.HideHint;
begin
  ReleaseHandle;
  Application.ShowHint := true;
  Active := false;
end;


procedure TPermanentHintWindow.ShowHintAt(Txt: string; x, y: integer);
var
  R: TRect;
begin
  Active := true;
  Application.ShowHint := false;
  R := CalcHintRect(Screen.Width, Txt, nil);
  OffsetRect(R, x, y);
  ActivateHint(R, Txt);
  Update;
end;


// On macOS the standard cursor height is 16 pixels. The original Windows
// implementation used WinAPI + x86 asm to measure the actual cursor bitmap
// height, which is Windows/x86 specific. A fixed value is correct for macOS.
function GetCursorHeightMargin: Integer;
begin
  Result := 16;
end;


end.
