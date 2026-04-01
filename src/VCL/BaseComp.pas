//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// BaseComp.pas — macOS/LCL port
// The original Windows version used AllocateHwnd/DeallocateHwnd to receive
// Windows messages (primarily WM_QUERYENDSESSION for graceful shutdown).
// On macOS/LCL, we simply manage the Enabled state without OS message hooks.
unit BaseComp;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  SysUtils, Classes, Controls, Forms;

type
  TBaseComponent = class(TComponent)
  private
    FEnabled: boolean;
    procedure SetEnabled(AEnabled: boolean);
  protected
    procedure DoSetEnabled(AEnabled: boolean); virtual;
    procedure Loaded; override;
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
  // Subclasses override this to start/stop their subsystem.
  // Nothing to do at base level — AllocateHwnd is Windows-only and not needed
  // on macOS. The original WM_QUERYENDSESSION handler is replaced by
  // TApplication.OnException / application terminate notifications in LCL.
end;


end.
