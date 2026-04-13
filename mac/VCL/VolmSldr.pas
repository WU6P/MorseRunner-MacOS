//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// VolmSldr.pas — macOS/LCL port
// Replaced Windows GDI calls:
//   DrawEdge(Handle, R, BDR_SUNKENOUTER, ...)  -> manual canvas border drawing
//   DrawFrameControl(Handle, R, DFC_BUTTON, .) -> manual 3D button drawing
// CM_MOUSELEAVE message is also supported in LCL (same constant name).
unit VolmSldr;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  SysUtils, Classes, Graphics, Controls, Forms, Dialogs,
  Math, LMessages, LCLIntf, Types, PermHint;

type
  TVolumeSlider = class(TGraphicControl)
  private
    FHintWin: TPermanentHintWindow;
    FMargin: integer;
    FValue: Single;
    FOnChange: TNotifyEvent;

    FDownValue: Single;
    FDownX: integer;
    FOverloaded: boolean;
    FShowHint: boolean;
    FHintStep: Integer;
    FDbMax: Single;
    FDbScale: Single;

    procedure SetMargin(const Value: integer);
    procedure SetValue(const Value: Single);
    function ThumbRect: TRect;
    procedure SetOverloaded(const Value: boolean);
    procedure CMMouseLeave(var Message: TLMessage); message CM_MOUSELEAVE;
    procedure SetShowHint(const Value: boolean);
    procedure SetDbMax(const Value: Single);
    procedure SetDbScale(const Value: Single);
    function GetDb: Single;
    procedure UpdateHint;
    procedure SetDb(const AdB: Single);
    procedure SetHintStep(const AHintStep: Integer);
  protected
    procedure Paint; override;
    procedure MouseDown(Button: TMouseButton; Shift: TShiftState;
      X, Y: Integer); override;
    procedure MouseMove(Shift: TShiftState; X, Y: Integer); override;
    procedure MouseUp(Button: TMouseButton; Shift: TShiftState; X, Y: Integer); override;
  public
    constructor Create(AOwner: TComponent); override;
  published
    property ShowHint: boolean read FShowHint write SetShowHint;
    property HintStep: Integer read FHintStep write SetHintStep;
    property Margin: integer read FMargin write SetMargin;
    property Value: Single read FValue write SetValue;
    property Enabled;
    property Overloaded: boolean read FOverloaded write SetOverloaded;
    property OnChange: TNotifyEvent read FOnChange write FOnChange;
    property OnDblClick;

    property DbMax: Single read FDbMax write SetDbMax;
    property DbScale: Single read FDbScale write SetDbScale;
    property Db: Single read GetDb write SetDb;
  end;

procedure Register;


implementation

const
  VMargin = 6;


procedure Register;
begin
  RegisterComponents('Snd', [TVolumeSlider]);
end;

// Draw a sunken 3D border (replaces DrawEdge with BDR_SUNKENOUTER)
procedure DrawSunkenBorder(ACanvas: TCanvas; R: TRect);
begin
  ACanvas.Pen.Color := clBtnShadow;
  ACanvas.MoveTo(R.Left,    R.Bottom - 1);
  ACanvas.LineTo(R.Left,    R.Top);
  ACanvas.LineTo(R.Right,   R.Top);
  ACanvas.Pen.Color := clBtnHighlight;
  ACanvas.MoveTo(R.Right - 1, R.Top + 1);
  ACanvas.LineTo(R.Right - 1, R.Bottom - 1);
  ACanvas.LineTo(R.Left,  R.Bottom - 1);
end;

// Draw a raised 3D button face (replaces DrawFrameControl DFC_BUTTON/DFCS_BUTTONPUSH)
procedure DrawButtonFace(ACanvas: TCanvas; R: TRect);
begin
  ACanvas.Brush.Color := clBtnFace;
  ACanvas.FillRect(R);
  // Highlight: top + left edges
  ACanvas.Pen.Color := clBtnHighlight;
  ACanvas.MoveTo(R.Left,    R.Bottom - 1);
  ACanvas.LineTo(R.Left,    R.Top);
  ACanvas.LineTo(R.Right,   R.Top);
  // Shadow: bottom + right edges
  ACanvas.Pen.Color := clBtnShadow;
  ACanvas.MoveTo(R.Right - 1, R.Top + 1);
  ACanvas.LineTo(R.Right - 1, R.Bottom - 1);
  ACanvas.LineTo(R.Left,  R.Bottom - 1);
end;

// Fill rect interior with background, leaving border (replaces BF_MIDDLE)
procedure FillInterior(ACanvas: TCanvas; R: TRect);
begin
  InflateRect(R, -1, -1);
  ACanvas.Brush.Color := clBtnFace;
  ACanvas.FillRect(R);
end;


{ TVolumeSlider }

constructor TVolumeSlider.Create(AOwner: TComponent);
begin
  inherited;
  FMargin := 5;
  FValue := 1.00;
  Width := 60;
  Height := 20;
  ControlStyle := [csCaptureMouse, csClickEvents, csDoubleClicks, csOpaque];
  FHintWin := TPermanentHintWindow.Create(Self);
  FShowHint := true;
  FHintStep := 0;

  FDbMax := 0;
  FDbScale := 60;
  UpdateHint;
end;


function TVolumeSlider.ThumbRect: TRect;
var
  x: integer;
begin
  x := FMargin + Round((Width - 2 * FMargin) * FValue);
  Result := Rect(x-4, VMargin div 2, x+5, Height - (VMargin div 2) + 1);
end;


procedure TVolumeSlider.Paint;
var
  R: TRect;
  Bmp: TBitMap;
begin
  Bmp := TBitMap.Create;
  try
    Bmp.Width := Width;
    Bmp.Height := Height;
    with Bmp.Canvas do
    begin
      // Background
      Brush.Color := clBtnFace;
      FillRect(Rect(0, 0, Width, Height));
      // Triangle ramp
      Pen.Color := clWhite;
      MoveTo(FMargin, Height - VMargin);
      LineTo(Width - FMargin, Height - VMargin);
      LineTo(Width - FMargin, VMargin);
      Pen.Color := clBtnShadow;
      LineTo(FMargin - 1, Height - VMargin - 1);
      // Overload indicator box (sunken border + optional red fill)
      R := Bounds(FMargin + 1, VMargin - 2, 7, 5);
      DrawSunkenBorder(Bmp.Canvas, R);
      FillInterior(Bmp.Canvas, R);
      if FOverloaded then
      begin
        Brush.Color := clRed;
        R := Bounds(FMargin + 2, VMargin - 1, 5, 3);
        FillRect(R);
      end;
      // Thumb
      R := ThumbRect;
      if Enabled then
        DrawButtonFace(Bmp.Canvas, R)
      else
      begin
        DrawSunkenBorder(Bmp.Canvas, R);
        FillInterior(Bmp.Canvas, R);
      end;
    end;
    Canvas.Draw(0, 0, Bmp);
  finally
    Bmp.Free;
  end;
end;


procedure TVolumeSlider.SetMargin(const Value: integer);
begin
  FMargin := Max(5, Min((Width div 2) - 5, Value));
  Invalidate;
end;


procedure TVolumeSlider.SetValue(const Value: Single);
begin
  FValue := Max(0, Min(1, Value));
  UpdateHint;
  Invalidate;
end;


procedure TVolumeSlider.MouseDown(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  if (Button = mbLeft) and PtInRect(ThumbRect, Point(X, Y))
    then begin FDownValue := FValue; FDownX := X; end
    else ControlState := ControlState - [csClicked];
end;


procedure TVolumeSlider.MouseMove(Shift: TShiftState; X, Y: Integer);
begin
  if not (ssLeft in Shift) then
  begin
    ControlState := ControlState - [csClicked];
    MouseCapture := false;
  end;

  if (PtInRect(ClientRect, Point(X, Y)) or (csClicked in ControlState)) and FShowHint
    then FHintWin.ShowHint(Hint)
    else FHintWin.HideHint;

  if not (csClicked in ControlState) then Exit;

  Value := FDownValue + (X - FDownX) / (Width - 2 * FMargin);
  Repaint;
  if Assigned(FOnChange) then FOnChange(Self);
end;


procedure TVolumeSlider.SetOverloaded(const Value: boolean);
begin
  if FOverloaded = Value then Exit;
  FOverloaded := Value;
  Repaint;
end;

procedure TVolumeSlider.CMMouseLeave(var Message: TLMessage);
begin
  if not (csClicked in ControlState)
    then FHintWin.HideHint;
end;

procedure TVolumeSlider.SetShowHint(const Value: boolean);
begin
  FShowHint := Value;
end;

procedure TVolumeSlider.SetDbMax(const Value: Single);
begin
  FDbMax := Value;
  UpdateHint;
end;

procedure TVolumeSlider.SetDbScale(const Value: Single);
begin
  FDbScale := Value;
  UpdateHint;
end;

function TVolumeSlider.GetDb: Single;
begin
  Result := DbMax + (FValue - 1) * DbScale;
end;

procedure TVolumeSlider.SetHintStep(const AHintStep: Integer);
begin
  FHintStep := max(0, AHintStep);
  UpdateHint;
end;

procedure TVolumeSlider.UpdateHint;
var
  V: Single;
begin
  case FHintStep of
  0:
    if dB >= 0.05 then
      Hint := Format('+%.1f dB', [dB])
    else if dB > -0.05 then
      Hint := Format(' %.1f dB', [dB])
    else
      Hint := Format('%.1f dB', [dB]);
  else
    begin
      V := FHintStep * round(dB / FHintStep);
      if V >= 0.5 then
        Hint := Format('+%.0f dB', [min(FDbMax, V)])
      else if V > -0.5 then
        Hint := Format(' %.0f dB', [V])
      else if V >= (FDbMax - FDbScale + FHintStep) then
        Hint := Format('%.0f dB', [max(FDbMax - FDbScale, V)])
      else
        Hint := 'Off';
    end;
  end;
end;

procedure TVolumeSlider.SetDb(const AdB: Single);
begin
  Value := (AdB - DbMax) / DbScale + 1;
end;

procedure TVolumeSlider.MouseUp(Button: TMouseButton; Shift: TShiftState;
  X, Y: Integer);
begin
  FHintWin.HideHint;
  inherited;
end;


end.
