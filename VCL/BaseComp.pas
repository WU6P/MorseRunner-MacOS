//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit BaseComp;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  {$ifdef MSWINDOWS}Windows, Messages,{$endif}
  SysUtils, Classes, Controls, Forms;

type
  TBaseComponent = class(TComponent)
  private
    {$ifdef MSWINDOWS}FHandle: THandle;{$endif}
    FEnabled: boolean;
    procedure SetEnabled(AEnabled: boolean);
    {$ifdef MSWINDOWS}
    procedure WndProc(var Message: TMessage);
    procedure WMQueryEndSession(var Message: TMessage); message WM_QUERYENDSESSION;
    {$endif}
  protected
    procedure DoSetEnabled(AEnabled: boolean); virtual;
    procedure Loaded; override;
    {$ifdef MSWINDOWS}property Handle: THandle read FHandle;{$endif}
  public
    property Enabled: boolean read FEnabled write SetEnabled default false;
    constructor Create(AOwner: TComponent); override;
    destructor Destroy; override;
  end;


implementation

{ TBaseComponent }

constructor TBaseComponent.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  {$ifdef MSWINDOWS}FHandle := 0;{$endif}
  FEnabled := false;
end;


destructor TBaseComponent.Destroy;
begin
  Enabled := false;
  inherited Destroy;
end;


procedure TBaseComponent.Loaded;
begin
  inherited Loaded;

  if FEnabled then
  begin
    FEnabled := false;
    SetEnabled(true);
  end;
end;

{$ifdef MSWINDOWS}
procedure TBaseComponent.WndProc(var Message: TMessage);
begin
  try
    Dispatch(Message);
  except
    Application.HandleException(Self);
  end;
end;

procedure TBaseComponent.WMQueryEndSession(var Message: TMessage);
begin
  try
    Enabled := false;
  except;
  end;
  inherited;
  Message.Result := integer(true);
end;
{$endif}

procedure TBaseComponent.SetEnabled(AEnabled: boolean);
begin
  if (not (csDesigning in ComponentState)) and
     (not (csLoading in ComponentState)) and
     (AEnabled <> FEnabled) then
    DoSetEnabled(AEnabled);
  FEnabled := AEnabled;
end;


procedure TBaseComponent.DoSetEnabled(AEnabled: boolean);
begin
  {$ifdef MSWINDOWS}
  if AEnabled
    then
      FHandle := AllocateHwnd(WndProc)
    else
      begin
      if FHandle <> 0 then DeallocateHwnd(FHandle);
      FHandle := 0;
      end;
  {$endif}
end;


end.
