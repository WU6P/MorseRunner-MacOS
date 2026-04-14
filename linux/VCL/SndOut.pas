//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// SndOut.pas — Linux/LCL port of TAlSoundOut.
//
// Architecture (mirrors macOS AudioBackend2 design):
//   • AudioBackendPulse.c (PulseAudio, gcc) manages a ring-buffer + playback thread.
//   • A TTimer fires every ~15 ms on the LCL main thread.
//   • When the ring buffer needs data (AudioBackendPulse_NeedsData = 1), the timer
//     fires OnBufAvailable, which causes the application to call PutData().
//   • PutData() normalises float samples and writes them to the ring buffer via
//     AudioBackendPulse_Write().
//
// The original TAlSoundOut interface is preserved so Main.pas needs no changes:
//   AlSoundOut1.Enabled         := true/false
//   AlSoundOut1.SamplesPerSec   := 11025
//   AlSoundOut1.BufCount        := 4
//   AlSoundOut1.OnBufAvailable  := AlSoundOut1BufAvailable
//   AlSoundOut1.PutData(Tst.GetAudio)
unit SndOut;

{$ifdef FPC}{$MODE Delphi}{$endif}

// Link AudioBackendPulse.o — compiled from AudioBackendPulse.c by build_linux.sh.
{$L AudioBackendPulse.o}

// Link PulseAudio libraries
{$linklib pulse-simple}
{$linklib pulse}
{$linklib pthread}

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Math,
  SndTypes, SndCustm;

// ---------------------------------------------------------------------------
// C interface to AudioBackendPulse.c (compiled by gcc)
// ---------------------------------------------------------------------------
function  AudioBackendPulse_Start(sampleRate, bufFrames, numBufs: Integer): Integer;
  cdecl; external;
procedure AudioBackendPulse_Stop;
  cdecl; external;
function  AudioBackendPulse_Write(samples: PSingle; nFrames: Integer): Integer;
  cdecl; external;
function  AudioBackendPulse_NeedsData: Integer;
  cdecl; external;
procedure AudioBackendPulse_ClearNeedsData;
  cdecl; external;
function  AudioBackendPulse_Available: Integer;
  cdecl; external;
procedure AudioBackendPulse_SetVolume(vol: Single);
  cdecl; external;

procedure Register;

type
  TAlSoundOut = class(TCustomSoundInOut)
  private
    FTimer          : TTimer;
    FOnBufAvailable : TNotifyEvent;
    FCloseWhenDone  : boolean;
    procedure TimerTick(Sender: TObject);
  protected
    procedure DoSetEnabled(AEnabled: boolean); override;
  public
    function  PutData(Data: TSingleArray): boolean;
    procedure Purge;
  published
    property Enabled;
    property SamplesPerSec;
    property BufsAdded;
    property BufsDone;
    property BufCount;
    property CloseWhenDone: boolean read FCloseWhenDone write FCloseWhenDone default false;
    property OnBufAvailable: TNotifyEvent read FOnBufAvailable write FOnBufAvailable;
  end;


implementation


procedure Register;
begin
  RegisterComponents('Al', [TAlSoundOut]);
end;


{ TAlSoundOut }

procedure TAlSoundOut.DoSetEnabled(AEnabled: boolean);
var
  Status: Integer;
begin
  if AEnabled then
  begin
    FBufsAdded := 0;
    FBufsDone  := 0;

    {$ifdef CPUAARCH64}
    // Clear FPU exception traps so PulseAudio playback thread inherits
    // a clean FPCR. FPC sets trap enable bits on ARM64 which can cause
    // SIGFPE in audio processing code.
    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
                      exOverflow,  exUnderflow,    exPrecision]);
    {$endif}

    Status := AudioBackendPulse_Start(Integer(SamplesPerSec),
                                      512,              // bufFrames
                                      Integer(BufCount));
    if Status <> 0 then
      raise Exception.CreateFmt('AudioBackendPulse_Start failed: error %d', [Status]);

    // TTimer fires on the LCL main thread — safe to call Pascal event handlers.
    FTimer := TTimer.Create(nil);
    FTimer.Interval := 15;   // ms; well below one buffer (~46 ms at 11025 Hz)
    FTimer.OnTimer  := TimerTick;
    FTimer.Enabled  := true;
  end
  else
  begin
    if Assigned(FTimer) then
    begin
      FTimer.Enabled := false;
      FreeAndNil(FTimer);
    end;
    AudioBackendPulse_Stop;
  end;
end;


// Called from TTimer on the main thread ~every 15 ms.
// When the ring buffer falls below its low-water mark, AudioBackendPulse sets
// the NeedsData flag; we clear it and fire OnBufAvailable so the application
// can call PutData().
procedure TAlSoundOut.TimerTick(Sender: TObject);
begin
  if not FEnabled then Exit;
  if AudioBackendPulse_NeedsData <> 0 then
  begin
    AudioBackendPulse_ClearNeedsData;
    if Assigned(FOnBufAvailable) then
      FOnBufAvailable(Self);
    Inc(FBufsDone);

    if FCloseWhenDone and (AudioBackendPulse_Available = 0) then
      Enabled := false;
  end;
end;


// PutData — feed audio samples to the ring buffer.
// Data values are in the range [-32767, +32767] (matches original Windows code).
// AudioBackendPulse_Write normalises them to [-1, 1] for PulseAudio Float32 format.
function TAlSoundOut.PutData(Data: TSingleArray): boolean;
var
  Written: Integer;
begin
  Result := false;
  if not FEnabled then Exit;
  if Length(Data) = 0 then Exit;
  Written := AudioBackendPulse_Write(@Data[0], Length(Data));
  Result  := Written > 0;
  if Result then Inc(FBufsAdded);
end;


procedure TAlSoundOut.Purge;
begin
  // Drain the ring buffer by stopping and restarting audio.
  if FEnabled then
  begin
    DoSetEnabled(false);
    DoSetEnabled(true);
  end;
end;


end.
