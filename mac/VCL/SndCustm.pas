//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// SndCustm.pas — macOS/LCL port of TCustomSoundInOut.
// Original Windows version used Windows MMSystem (waveOutOpen etc.) and a
// dedicated TWaitThread running a Windows message loop.
// This port delegates all audio I/O to AudioBackend2.m (CoreAudio / Clang).
unit SndCustm;

{$ifdef FPC}{$MODE Delphi}{$endif}
{$ifdef DARWIN}
{$linkframework AudioToolbox}
{$linkframework CoreAudio}
{$linkframework Foundation}
{$endif}

interface

uses
  SysUtils, Classes, SndTypes;

type
  TCustomSoundInOut = class(TComponent)
  private
    FSamplesPerSec : LongWord;
    FBufCount      : LongWord;
    procedure SetEnabled(AEnabled: boolean);
    procedure SetSamplesPerSec(const Value: LongWord);
    procedure SetBufCount(const Value: LongWord);
  protected
    FEnabled       : boolean;
    FBufsAdded     : LongWord;
    FBufsDone      : LongWord;
    procedure Loaded; override;
    procedure DoSetEnabled(AEnabled: boolean); virtual;
    property Enabled      : boolean   read FEnabled       write SetEnabled       default false;
    property SamplesPerSec: LongWord  read FSamplesPerSec write SetSamplesPerSec default 11025;
    property BufCount     : LongWord  read FBufCount      write SetBufCount;
    property BufsAdded    : LongWord  read FBufsAdded;
    property BufsDone     : LongWord  read FBufsDone;
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;
  end;


implementation

{ TCustomSoundInOut }

constructor TCustomSoundInOut.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FSamplesPerSec := 11025;
  FBufCount      := 4;
  FBufsAdded     := 0;
  FBufsDone      := 0;
  FEnabled       := false;
end;


destructor TCustomSoundInOut.Destroy;
begin
  Enabled := false;
  inherited;
end;


// Do not enable at design or load time.
procedure TCustomSoundInOut.SetEnabled(AEnabled: boolean);
begin
  if (not (csDesigning in ComponentState)) and
     (not (csLoading  in ComponentState)) and
     (AEnabled <> FEnabled) then
    DoSetEnabled(AEnabled);
  FEnabled := AEnabled;
end;


// Enable after all properties have been streamed in from the .lfm.
procedure TCustomSoundInOut.Loaded;
begin
  inherited Loaded;
  if FEnabled and not (csDesigning in ComponentState) then
  begin
    FEnabled := false;
    SetEnabled(true);
  end;
end;


procedure TCustomSoundInOut.DoSetEnabled(AEnabled: boolean);
begin
  // Subclasses override to start/stop the audio device.
end;


procedure TCustomSoundInOut.SetSamplesPerSec(const Value: LongWord);
begin
  if Value = FSamplesPerSec then Exit;
  Enabled := false;
  FSamplesPerSec := Value;
end;


procedure TCustomSoundInOut.SetBufCount(const Value: LongWord);
begin
  if Value = FBufCount then Exit;
  if FEnabled then
    raise Exception.Create('Cannot change buffer count while audio is active');
  FBufCount := Value;
end;


end.
