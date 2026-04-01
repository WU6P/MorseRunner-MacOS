//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// WavFile.pas — macOS/LCL port of TAlWavFile.
// Original Windows version used Windows MMIO (mmioOpen/mmioRead etc.).
// This port uses pure Pascal TFileStream for portable WAV file I/O.
//
// WAV PCM layout:
//   RIFF <size> WAVE
//     fmt  <16>  <PCMWaveFormat: fmtTag, numCh, sampRate, byteRate, align, bits>
//     data <size>  <raw 16-bit signed PCM samples>
//
// Sample values: floats in range [-32767 .. +32767] (Morse Runner convention).
unit WavFile;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  SysUtils, Classes, Math, SndTypes;

type
  TAlWavFile = class(TComponent)
  private
    FStream        : TFileStream;
    FFileName      : TFileName;
    FIsOpen        : boolean;
    FWriteMode     : boolean;
    FStereo        : boolean;
    FSamplesPerSec : LongWord;
    FBytesPerSample: LongWord;
    FSampleCnt     : LongWord;
    FCurrentSample : LongWord;
    FLData         : TSingleArray;
    FRData         : TSingleArray;
    FInfo          : TStrings;
    FDataStart     : Int64;  // file offset right after the data chunk size field

    procedure SetStereo(const Value: boolean);
    procedure SetSamplesPerSec(const Value: LongWord);
    procedure SetBytesPerSample(const Value: LongWord);
    procedure SetInfo(const Value: TStrings);
    procedure SetFileName(const Value: TFileName);
    procedure ChkNotOpen;
    procedure ErrIf(Cond: boolean; const Msg: string);
  public
    constructor Create(AOwner: TComponent); override;
    destructor  Destroy; override;

    procedure OpenRead;
    procedure OpenWrite;
    procedure Close;
    procedure Seek(SampleNo: LongWord);
    procedure Read(ASampleCnt: LongWord);
    function  ReadTo(ALData, ARData: PSingle; ASampleCnt: LongWord): LongWord;
    procedure Write;
    procedure WriteFrom(ALData, ARData: PSingle; ASampleCnt: LongWord);
    procedure NormalizeData;

    property SampleCnt    : LongWord read FSampleCnt;
    property CurrentSample: LongWord read FCurrentSample;
    property IsOpen       : boolean  read FIsOpen;
    property LData        : TSingleArray read FLData write FLData;
    property RData        : TSingleArray read FRData write FRData;
  published
    property FileName      : TFileName read FFileName       write SetFileName;
    property Stereo        : boolean   read FStereo         write SetStereo        default false;
    property SamplesPerSec : LongWord  read FSamplesPerSec  write SetSamplesPerSec default 11025;
    property BytesPerSample: LongWord  read FBytesPerSample write SetBytesPerSample default 2;
    property Info          : TStrings  read FInfo           write SetInfo;
  end;

procedure Register;

implementation

procedure Register;
begin
  RegisterComponents('Snd', [TAlWavFile]);
end;

//------------------------------------------------------------------------------
// Stream helpers (little-endian WAV)
//------------------------------------------------------------------------------
procedure WriteTag(S: TStream; const Tag: AnsiString);
begin
  S.WriteBuffer(Tag[1], 4);
end;

procedure WriteU32(S: TStream; V: LongWord);
begin
  S.WriteBuffer(V, 4);
end;

procedure WriteU16(S: TStream; V: Word);
begin
  S.WriteBuffer(V, 2);
end;

function ReadTag(S: TStream): AnsiString;
begin
  SetLength(Result, 4);
  S.ReadBuffer(Result[1], 4);
end;

function ReadU32(S: TStream): LongWord;
begin
  S.ReadBuffer(Result, 4);
end;

function ReadU16(S: TStream): Word;
begin
  S.ReadBuffer(Result, 2);
end;

//------------------------------------------------------------------------------
// TAlWavFile
//------------------------------------------------------------------------------

constructor TAlWavFile.Create(AOwner: TComponent);
begin
  inherited Create(AOwner);
  FBytesPerSample := 2;
  FSamplesPerSec  := 11025;
  FStereo         := false;
  FIsOpen         := false;
  FInfo           := TStringList.Create;
end;

destructor TAlWavFile.Destroy;
begin
  if FIsOpen then Close;
  FInfo.Free;
  inherited Destroy;
end;

procedure TAlWavFile.ErrIf(Cond: boolean; const Msg: string);
begin
  if Cond then raise Exception.Create('TAlWavFile: ' + Msg);
end;

procedure TAlWavFile.ChkNotOpen;
begin
  ErrIf(FIsOpen, 'File is already open');
end;

procedure TAlWavFile.SetFileName(const Value: TFileName);
begin FFileName := Value; end;

procedure TAlWavFile.SetStereo(const Value: boolean);
begin FStereo := Value; end;

procedure TAlWavFile.SetSamplesPerSec(const Value: LongWord);
begin
  ChkNotOpen;
  FSamplesPerSec := Value;
end;

procedure TAlWavFile.SetBytesPerSample(const Value: LongWord);
begin
  ChkNotOpen;
  FBytesPerSample := Value;
end;

procedure TAlWavFile.SetInfo(const Value: TStrings);
begin
  FInfo.Assign(Value);
end;

//------------------------------------------------------------------------------
// OpenRead
//------------------------------------------------------------------------------
procedure TAlWavFile.OpenRead;
var
  Tag        : AnsiString;
  ChunkSize  : LongWord;
  FmtFound   : boolean;
  DataFound  : boolean;
  NumCh      : Word;
  BitsPerSamp: Word;
  BlockSz    : LongWord;
begin
  ChkNotOpen;
  FWriteMode     := false;
  FCurrentSample := 0;
  FSampleCnt     := 0;
  FDataStart     := 0;
  FmtFound       := false;
  DataFound      := false;

  FStream := TFileStream.Create(FFileName, fmOpenRead or fmShareDenyWrite);
  try
    Tag := ReadTag(FStream);
    ErrIf(Tag <> 'RIFF', 'Not a RIFF file');
    ReadU32(FStream);              // total size - 8 (ignored on read)
    Tag := ReadTag(FStream);
    ErrIf(Tag <> 'WAVE', 'Not a WAVE file');

    while FStream.Position < FStream.Size - 8 do
    begin
      Tag       := ReadTag(FStream);
      ChunkSize := ReadU32(FStream);

      if Tag = 'fmt ' then
      begin
        ErrIf(ChunkSize < 16, 'fmt chunk too small');
        ReadU16(FStream);                // wFormatTag (1=PCM; accept without checking)
        NumCh           := ReadU16(FStream);
        FSamplesPerSec  := ReadU32(FStream);
        ReadU32(FStream);                // nAvgBytesPerSec (ignored)
        ReadU16(FStream);                // nBlockAlign (ignored)
        BitsPerSamp     := ReadU16(FStream);
        FStereo         := NumCh = 2;
        FBytesPerSample := BitsPerSamp shr 3;
        if ChunkSize > 16 then
          FStream.Seek(Int64(ChunkSize - 16), soCurrent);
        FmtFound := true;
      end
      else if Tag = 'data' then
      begin
        FDataStart := FStream.Position;
        BlockSz    := FBytesPerSample * LongWord(IfThen(FStereo, 2, 1));
        if BlockSz > 0 then
          FSampleCnt := ChunkSize div BlockSz;
        DataFound := true;
        Break;
      end
      else
      begin
        // Skip unknown chunk (even-aligned)
        FStream.Seek(Int64(ChunkSize + (ChunkSize and 1)), soCurrent);
      end;
    end;

    ErrIf(not FmtFound,  'No fmt chunk in WAV file');
    ErrIf(not DataFound, 'No data chunk in WAV file');
  except
    FStream.Free;
    FStream := nil;
    raise;
  end;
  FIsOpen := true;
end;

//------------------------------------------------------------------------------
// OpenWrite
//------------------------------------------------------------------------------
procedure TAlWavFile.OpenWrite;
var
  NumCh      : Word;
  BlockAlign : Word;
  BitsPerSamp: Word;
begin
  ChkNotOpen;
  FWriteMode     := true;
  FCurrentSample := 0;
  FSampleCnt     := 0;

  FStream := TFileStream.Create(FFileName, fmCreate);
  try
    NumCh       := IfThen(FStereo, 2, 1);
    BitsPerSamp := Word(FBytesPerSample * 8);
    BlockAlign  := NumCh * Word(FBytesPerSample);

    // RIFF header (size placeholder — fixed in Close)
    WriteTag(FStream, 'RIFF');
    WriteU32(FStream, 0);
    WriteTag(FStream, 'WAVE');

    // fmt chunk
    WriteTag(FStream, 'fmt ');
    WriteU32(FStream, 16);
    WriteU16(FStream, 1);                              // PCM
    WriteU16(FStream, NumCh);
    WriteU32(FStream, FSamplesPerSec);
    WriteU32(FStream, FSamplesPerSec * BlockAlign);    // nAvgBytesPerSec
    WriteU16(FStream, BlockAlign);
    WriteU16(FStream, BitsPerSamp);

    // data chunk header (size placeholder — fixed in Close)
    WriteTag(FStream, 'data');
    WriteU32(FStream, 0);
    FDataStart := FStream.Position;
  except
    FStream.Free;
    FStream := nil;
    raise;
  end;
  FIsOpen := true;
end;

//------------------------------------------------------------------------------
// Close — fix up RIFF and data chunk size fields for write mode.
//------------------------------------------------------------------------------
procedure TAlWavFile.Close;
var
  DataBytes: LongWord;
  TotalSize: LongWord;
begin
  ErrIf(not FIsOpen, 'File not open');
  if FWriteMode then
  begin
    DataBytes := LongWord(FStream.Position - FDataStart);
    TotalSize := LongWord(FStream.Position) - 8;
    FStream.Position := 4;
    WriteU32(FStream, TotalSize);
    FStream.Position := FDataStart - 4;
    WriteU32(FStream, DataBytes);
  end;
  FStream.Free;
  FStream        := nil;
  FIsOpen        := false;
  FCurrentSample := 0;
end;

//------------------------------------------------------------------------------
// Seek
//------------------------------------------------------------------------------
procedure TAlWavFile.Seek(SampleNo: LongWord);
var
  BlockSz: LongWord;
begin
  ErrIf(not FIsOpen or FWriteMode, 'Not open for reading');
  BlockSz := FBytesPerSample * LongWord(IfThen(FStereo, 2, 1));
  FStream.Position := FDataStart + Int64(SampleNo) * BlockSz;
  FCurrentSample   := SampleNo;
end;

//------------------------------------------------------------------------------
// WriteFrom — write ASampleCnt float samples to the WAV file as 16-bit PCM.
// ALData: left (or mono) channel, range [-32767..+32767].
// ARData: right channel (may be nil for mono or duplicated from left).
//------------------------------------------------------------------------------
procedure TAlWavFile.WriteFrom(ALData, ARData: PSingle; ASampleCnt: LongWord);
var
  i   : LongWord;
  SL, SR: SmallInt;
  pL  : PSingle;
  pR  : PSingle;
begin
  ErrIf(not FIsOpen or not FWriteMode, 'Not open for writing');
  pL := ALData;
  pR := ARData;
  for i := 0 to ASampleCnt - 1 do
  begin
    SL := SmallInt(Max(-32767, Min(32767, Round(pL^))));
    FStream.WriteBuffer(SL, SizeOf(SmallInt));
    if FStereo then
    begin
      if pR <> nil then
        SR := SmallInt(Max(-32767, Min(32767, Round(pR^))))
      else
        SR := SL;
      FStream.WriteBuffer(SR, SizeOf(SmallInt));
      if pR <> nil then Inc(pR);
    end;
    Inc(pL);
    Inc(FSampleCnt);
    Inc(FCurrentSample);
  end;
end;

//------------------------------------------------------------------------------
// Write — write FLData / FRData arrays.
//------------------------------------------------------------------------------
procedure TAlWavFile.Write;
var
  pR: PSingle;
begin
  ErrIf(Length(FLData) = 0, 'LData is empty');
  if FStereo and (Length(FRData) > 0) then
    pR := @FRData[0]
  else
    pR := nil;
  WriteFrom(@FLData[0], pR, LongWord(Length(FLData)));
end;

//------------------------------------------------------------------------------
// ReadTo — read ASampleCnt samples into caller-supplied float buffers.
//------------------------------------------------------------------------------
function TAlWavFile.ReadTo(ALData, ARData: PSingle; ASampleCnt: LongWord): LongWord;
var
  i        : LongWord;
  Remaining: LongWord;
  SL, SR   : SmallInt;
  pL       : PSingle;
  pR       : PSingle;
begin
  ErrIf(not FIsOpen or FWriteMode, 'Not open for reading');
  Remaining := FSampleCnt - FCurrentSample;
  if ASampleCnt > Remaining then ASampleCnt := Remaining;
  pL := ALData;
  pR := ARData;
  for i := 0 to ASampleCnt - 1 do
  begin
    FStream.ReadBuffer(SL, SizeOf(SmallInt));
    pL^ := SL;
    Inc(pL);
    if FStereo then
    begin
      FStream.ReadBuffer(SR, SizeOf(SmallInt));
      if pR <> nil then
      begin
        pR^ := SR;
        Inc(pR);
      end;
    end;
    Inc(FCurrentSample);
  end;
  Result := ASampleCnt;
end;

//------------------------------------------------------------------------------
// Read — read into FLData / FRData.
//------------------------------------------------------------------------------
procedure TAlWavFile.Read(ASampleCnt: LongWord);
begin
  SetLength(FLData, ASampleCnt);
  if FStereo then SetLength(FRData, ASampleCnt);
  if FStereo then
    ReadTo(@FLData[0], @FRData[0], ASampleCnt)
  else
    ReadTo(@FLData[0], nil, ASampleCnt);
end;

//------------------------------------------------------------------------------
// NormalizeData — scale FLData/FRData so peak = 32767.
//------------------------------------------------------------------------------
procedure TAlWavFile.NormalizeData;
var
  i   : integer;
  Peak: Single;
begin
  Peak := 0;
  for i := 0 to High(FLData) do
    if Abs(FLData[i]) > Peak then Peak := Abs(FLData[i]);
  if FStereo then
    for i := 0 to High(FRData) do
      if Abs(FRData[i]) > Peak then Peak := Abs(FRData[i]);
  if Peak < 1 then Exit;
  for i := 0 to High(FLData) do FLData[i] := FLData[i] / Peak * 32767;
  if FStereo then
    for i := 0 to High(FRData) do FRData[i] := FRData[i] / Peak * 32767;
end;


end.
