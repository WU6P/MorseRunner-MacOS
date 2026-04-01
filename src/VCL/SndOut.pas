//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// SndOut.pas — macOS/LCL port of TAlSoundOut.
//
// Architecture (replaces Windows MMSystem + TWaitThread):
//   • AudioBackend2.m (CoreAudio, Clang) manages a ring-buffer AudioQueue.
//   • A TTimer fires every ~15 ms on the LCL main thread.
//   • When the ring buffer needs data (AudioBackend2_NeedsData = 1), the timer
//     fires OnBufAvailable, which causes the application to call PutData().
//   • PutData() normalises float samples and writes them to the ring buffer via
//     AudioBackend2_Write().
//
// The original TAlSoundOut interface is preserved so Main.pas needs no changes:
//   AlSoundOut1.Enabled         := true/false
//   AlSoundOut1.SamplesPerSec   := 11025
//   AlSoundOut1.BufCount        := 4
//   AlSoundOut1.OnBufAvailable  := AlSoundOut1BufAvailable
//   AlSoundOut1.PutData(Tst.GetAudio)
unit SndOut;

{$ifdef FPC}{$MODE Delphi}{$endif}

// Link AudioBackend2.o — compiled from AudioBackend2.m by the Makefile.
{$L AudioBackend2.o}

interface

uses
  SysUtils, Classes, Controls, ExtCtrls, Math,
  SndTypes, SndCustm,
  BaseUnix, UnixType;   // RestoreDefaultSignals, SetExceptionMask

// ---------------------------------------------------------------------------
// C interface to AudioBackend2.m (compiled from AudioBackend2.m by Clang)
// ---------------------------------------------------------------------------
function  AudioBackend2_Start(sampleRate, bufFrames, numBufs: Integer): Integer;
  cdecl; external;
procedure AudioBackend2_Stop;
  cdecl; external;
function  AudioBackend2_Write(samples: PSingle; nFrames: Integer): Integer;
  cdecl; external;
function  AudioBackend2_NeedsData: Integer;
  cdecl; external;
procedure AudioBackend2_ClearNeedsData;
  cdecl; external;
function  AudioBackend2_Available: Integer;
  cdecl; external;
procedure AudioBackend2_SetVolume(vol: Single);
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

// Restore OS-default signal handlers so CoreAudio's internal threads can use
// SIGSEGV / SIGBUS without being intercepted by FPC's signal handler.
procedure RestoreDefaultSignals;
var
  sa: SigActionRec;
begin
  FillByte(sa, SizeOf(sa), 0);
  sa.sa_handler := SigActionHandler(SIG_DFL);
  FPSigAction(SIGSEGV, @sa, nil);
  FPSigAction(SIGBUS,  @sa, nil);
end;


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

    // Clear FPU exception traps so CoreAudio threads inherit a clean FPCR.
    SetExceptionMask([exInvalidOp, exDenormalized, exZeroDivide,
                      exOverflow,  exUnderflow,    exPrecision]);
    RestoreDefaultSignals;

    Status := AudioBackend2_Start(Integer(SamplesPerSec),
                                  512,              // bufFrames (fixed; matches Ini.BufSize default)
                                  Integer(BufCount));
    if Status <> 0 then
      raise Exception.CreateFmt('AudioBackend2_Start failed: OSStatus %d', [Status]);

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
    AudioBackend2_Stop;
  end;
end;


// Called from TTimer on the main thread ~every 15 ms.
// When the ring buffer falls below its low-water mark, AudioBackend2 sets the
// NeedsData flag; we clear it and fire OnBufAvailable so the application can
// call PutData().
procedure TAlSoundOut.TimerTick(Sender: TObject);
begin
  if not FEnabled then Exit;
  if AudioBackend2_NeedsData <> 0 then
  begin
    AudioBackend2_ClearNeedsData;
    if Assigned(FOnBufAvailable) then
      FOnBufAvailable(Self);
    Inc(FBufsDone);

    if FCloseWhenDone and (AudioBackend2_Available = 0) then
      Enabled := false;
  end;
end;


// PutData — feed audio samples to the ring buffer.
// Data values are in the range [-32767, +32767] (matches original Windows code).
// AudioBackend2_Write normalises them to [-1, 1] for CoreAudio Float32 format.
function TAlSoundOut.PutData(Data: TSingleArray): boolean;
var
  Written: Integer;
begin
  Result := false;
  if not FEnabled then Exit;
  if Length(Data) = 0 then Exit;
  Written := AudioBackend2_Write(@Data[0], Length(Data));
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
