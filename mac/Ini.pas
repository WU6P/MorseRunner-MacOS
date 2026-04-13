//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit Ini;
{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  ExchFields,
  IniFiles;

const
  SEC_STN = 'Station';
  SEC_BND = 'Band';
  SEC_TST = 'Contest';
  SEC_SYS = 'System';
  SEC_SET = 'Settings';
  SEC_DBG = 'Debug';

  DEFAULTBUFCOUNT = 8;
  DEFAULTBUFSIZE = 512;
  DEFAULTRATE = 11025;

  DEFAULTWEBSERVER = 'http://www.dxatlas.com/MorseRunner/MrScore.asp';
type
  // Adding a contest: Append new TSimContest enum value for each contest.
  TSimContest = (scWpx, scCwt, scFieldDay, scNaQp, scHst, scCQWW, scArrlDx,
                 scSst, scAllJa, scAcag, scIaruHf, scArrlSS);
  TRunMode = (rmStop, rmPileup, rmSingle, rmWpx, rmHst);

  // Serial NR types
  TSerialNRTypes = (snStartContest, snMidContest, snEndContest, snCustomRange);

  // Serial Number Settings.
  // Defines parameters used to generate various serial numbers.
  // Used by SerialNRGenerator. Stored in .ini file.
  TSerialNRSettings = record
    Key: PChar;         // .INI file keyword
    RangeStr: string;   // Range specification of the form: 01-99 (stored in .ini)
    MinVal: integer;    // range starting value
    MaxVal: integer;    // range ending value

    // MinDigits/MaxDigits below are used for formatting leading zeros:
    // (e.g. Format('%*d', [digits, NR]
    MinDigits: integer; // number of digits in MinVal
    MaxDigits: integer; // number of digits in max value

    procedure Init(const Range: string; AMin, AMax: integer);
    function IsValid : boolean;
    function ParseSerialNR(const ValueStr : string; var Err : string) : Boolean;
    function GetNR : integer;
  end;

  PSerialNRSettings = ^TSerialNRSettings;

  // Contest definition.
  TContestDefinition = record
    Name: PChar;    // Contest Name. Used in SimContestCombo dropdown box.
    Key: PChar;     // Identifying key (used in Ini files)
    ExchType1: TExchange1Type;
    ExchType2: TExchange2Type;
    ExchCaptions: array[0..1] of String; // exchange field captions
    ExchFieldEditable: Boolean; // whether the Exchange field is editable
    ExchDefault: PChar; // contest-specific Exchange default message
    Msg: PChar;     // Exchange error message
    T: TSimContest; // used to verify array ordering and lookup by Name
  end;

  PContestDefinition = ^TContestDefinition;

  TErrMessageCallback = procedure(const aMsg: string) of object;

const
  UndefSimContest = -1;   // sentinel: no contest selected (compare with Ord(SimContest))

  SerialNrMidContestDef : string = '50-500';
  SerialNrEndContestDef : string = '500-5000';
  SerialNrCustomRangeDef : string = '01-99';

  {
    Each contest is declared here. Long-term, this will be a generalized
    table-driven implementation allowing new contests to be configured
    by updating an external configuration file, perhaps a .yaml file.

    Note: The order of this table must match the declared order of
    TSimContest above.

    Adding a contest: update ContestDefinitions[] array (append at end
    because .INI uses TSimContest value).
  }
  ContestDefinitions: array[TSimContest] of TContestDefinition = (
    (Name: 'CQ WPX';
     Key: 'CqWpx';
     ExchType1: etRST;
     ExchType2: etSerialNr;
     ExchFieldEditable: True;
     ExchDefault: '5NN #';
     Msg: '''RST <serial>'' (e.g. 5NN #|123)';
     T:scWpx),
     // 'expecting RST (e.g. 5NN)'

    (Name: 'CWOPS CWT';
     Key: 'Cwt';
     ExchType1: etOpName;
     ExchType2: etGenericField;
     ExchCaptions: ('Name', 'Exch');
     ExchFieldEditable: True;
     ExchDefault: 'DAVID 123';
     Msg: '''<op name> <CWOPS Number|State|Country>'' (e.g. DAVID 123)';
     T:scCwt),
     // expecting two strings [Name,Number] (e.g. David 123)
     // Contest Exchange: <Name> <CW Ops Num|State|Country Prefix>

    (Name: 'ARRL Field Day';
     Key: 'ArrlFd';
     ExchType1: etFdClass;
     ExchType2: etArrlSection;
     ExchFieldEditable: True;
     ExchDefault: '3A OR';
     Msg: '''<class> <section>'' (e.g. 3A OR)';
     T:scFieldDay),
     // expecting two strings [Class,Section] (e.g. 3A OR)

    (Name: 'NCJ NAQP';
     Key: 'NAQP';
     ExchType1: etOpName;
     ExchType2: etNaQpExch2;
     ExchFieldEditable: True;
     ExchDefault: 'ALEX ON';
     Msg: '''<name> [<state|prov|dxcc-entity>]'' (e.g. ALEX ON)';
     T:scNaQp),
     // expecting one or two strings {Name,[State|Prov|DXCC Entity]} (e.g. MIKE OR)

    (Name: 'HST (High Speed Test)';
     Key: 'HST';
     ExchType1: etRST;
     ExchType2: etSerialNr;
     ExchFieldEditable: False;
     ExchDefault: '5NN #';
     Msg: '''RST <serial>'' (e.g. 5NN #)';
     T:scHst),
     // expecting RST (e.g. 5NN)

    (Name: 'CQ WW';
     Key: 'CQWW';
     ExchType1: etRST;
     ExchType2: etCQZone;
     ExchFieldEditable: True;
     ExchDefault: '5NN 3';
     Msg: '''RST <cq-zone>'' (e.g. 5NN 3)';
     T:scCQWW),

    (Name: 'ARRL DX';
     Key: 'ArrlDx';
     ExchType1: etRST;
     ExchType2: etStateProv;  // or etPower
     ExchFieldEditable: True;
     ExchDefault: '5NN ON';   // or '5NN KW'
     Msg: '''RST <state|province|power>'' (e.g. 5NN ON)';
     T:scARRLDX),

    (Name: 'K1USN Slow Speed Test';
     Key: 'Sst';
     ExchType1: etOpName;
     ExchType2: etGenericField;  // or etStateProvDx?
     ExchCaptions: ('Name', 'State/Prov/DX');
     ExchFieldEditable: True;
     ExchDefault: 'BRUCE MA';
     Msg: '''<op name> <State|Prov|DX>'' (e.g. BRUCE MA)';
     T:scSst),
     // expecting two strings [Name,QTH] (e.g. BRUCE MA)
     // Contest Exchange: <Name> <State|Prov|DX>

    (Name: 'JARL ALL JA';
     Key: 'AllJa';
     ExchType1: etRST;
     ExchType2: etJaPref;
     ExchFieldEditable: True;
     ExchDefault: '5NN 10H';
     Msg: '''RST <Pref><Power>'' (e.g. 5NN 10H)';
     T:scAllJa),

    (Name: 'JARL ACAG';
     Key: 'Acag';
     ExchType1: etRST;
     ExchType2: etJaCity;
     ExchFieldEditable: True;
     ExchDefault: '5NN 1002H';
     Msg: '''RST <City|Gun|Ku><Power>'' (e.g. 5NN 1002H)';
     T:scAcag),

    (Name: 'IARU HF';
     Key: 'IaruHf';
     ExchType1: etRST;
     ExchType2: etGenericField;
     ExchCaptions: ('RST', 'Zone/Soc');
     ExchFieldEditable: True;
     ExchDefault: '5NN 6';
     Msg: '''RST <Itu-zone|IARU Society>'' (e.g. 5NN 6)';
     T:scIaruHf),

    (Name: 'ARRL Sweepstakes';
     Key: 'SSCW';
     ExchType1: etSSNrPrecedence;   // full exchange info is entered via Exch2; or my serial number (sent)
     ExchType2: etSSCheckSection;
     ExchFieldEditable: True;
     ExchDefault: 'A 72 OR';
     Msg: '''[#|123] <precedence> <check> <section>'' (e.g. A 72 OR)';
     T:scArrlSS)
     // Entered Exchange: # <precedence> * <check> <section>
     // where precedence={Q,A,B,U,M,S}, check='year licenced', ARRL/RAC section.
     // Sent Exchange: # A W7SST 72 OR
     // Fields: NR:numeric, Prec:string, Check:numeric, Section:string
     // N1MM default ordering w/ call history: 72 OR. I type 123A
     // N1MM automatic rendering: 123A <call> 72 OR
  );

var
  Call: string = 'VE3NEA';
  HamName: string = 'Alex';
  ArrlClass: string = '3A';
  ArrlSection: string = 'GH';
  Wpm: integer = 25;
  WpmStepRate: integer = 2;
  MaxRxWpm: integer = 0;
  MinRxWpm: integer = 0;
  NRDigits: integer = 1;
  SerialNRSettings: array[TSerialNRTypes] of TSerialNRSettings = (
    (Key:'SerialNrStartContest'; RangeStr:'Default';  MinVal:1;   MaxVal:176;  minDigits:1; maxDigits:3),
    (Key:'SerialNrMidContest';   RangeStr:'50-500';   MinVal:50;  MaxVal:500;  minDigits:2; maxDigits:3),
    (Key:'SerialNrEndContest';   RangeStr:'500-5000'; MinVal:500; MaxVal:5000; minDigits:3; maxDigits:4),
    (Key:'SerialNrCustomRange';  RangeStr:'01-99';    MinVal:1;   MaxVal:99;   minDigits:2; maxDigits:2)
  );
  SerialNR: TSerialNRTypes = snStartContest;
  BandWidth: integer = 500;
  Pitch: integer = 600;
  Qsk: boolean = false;
  Rit: integer = 0;
  RitStepIncr: integer = 50;
  BufSize: integer = DEFAULTBUFSIZE;
  WebServer: string = '';
  SubmitHiScoreURL: string= '';
  PostMethod: string = '';
  ShowCallsignInfo: integer= 1;
  StationIdRate: Integer = 3;
  SingleCallStartDelay: Integer = 0;
  Activity: integer = 2;
  Qrn: boolean = false;
  Qrm: boolean = false;
  Qsb: boolean = false;
  Flutter: boolean = false;
  Lids: boolean = false;
  NoActivityCnt: integer=0;
  NoStopActivity: integer=0;
  GetWpmUsesGaussian: boolean = false;
  ShowCheckSection: integer=50;
  ShowExchangeSummary: integer = 1; // 0=Off, 1=Above Field, 2=Status Bar

  Duration: integer = 30;
  RunMode: TRunMode = rmStop;
  DefaultRunMode: TRunMode = rmPileUp;
  HiScore: integer;
  CompDuration: integer = 60;

  SelfMonVolume: Integer = 0;
  SaveWav: boolean = false;
  FarnsworthCharRate: integer = 25;
  AllStationsWpmS: integer = 0;      // force all stations to this Wpm
  CallsFromKeyer: boolean = false;
  F8: string = '';

  { display parsed Exchange field settings; calls/exchanges (in rmSingle mode) }
  DebugExchSettings: boolean = false;
  DebugCwDecoder: boolean = false;  // stream CW to status bar
  DebugGhosting: boolean = false;   // enable DxStation Ghosting debug

  SimContest: TSimContest = scWpx;
  ActiveContest: PContestDefinition = @ContestDefinitions[scWpx];
  UserExchangeTbl: array[TSimContest] of string;
  UserExchange1: array[TSimContest] of string;
  UserExchange2: array[TSimContest] of string;

function IsNum(Num: String): Boolean;
function FindContestByName(const AContestName : String) : TSimContest;
function ToStr(const val: TRunMode): String; overload;


implementation

uses
  Classes,        // for TStringList
  Math,           // for Min, Max
  SysUtils,       // for Format(),
  TypInfo;        // for typeInfo


function ToStr(const val : TRunMode) : string; overload;
begin
  Result := GetEnumName(typeInfo(TRunMode), Ord(val));
end;




{ TSerialNRSettings methods...}
procedure TSerialNRSettings.Init(const Range: string; AMin, AMax: integer);
begin
  Self.RangeStr := Range;
  Self.MinVal := AMin;
  Self.MaxVal := AMax;
end;


function TSerialNRSettings.IsValid: Boolean;
begin
  Result := (MinVal > 0) and (MinVal <= MaxVal);
end;


function TSerialNRSettings.GetNR : integer;
begin
  assert(IsValid);
  if IsValid then
    Result := MinVal + Random(MaxVal - MinVal)
  else
    Result := 1;
end;


function TSerialNRSettings.ParseSerialNR(
  const ValueStr : string;
  var Err : string) : Boolean;
var
  sl : TStringList;
begin
  sl := TStringList.Create;
  try
    Self.RangeStr := ValueStr;

    // split Range into two strings [Min, Max)
    sl.Clear;
    ExtractStrings(['-'], [], PChar(ValueStr), sl);
    Err := '';
    if (sl.Count <> 2) or
       (ValueStr.CountChar('-') <> 1) or
       not TryStrToInt(sl[0], Self.MinVal) or
       not TryStrToInt(sl[1], Self.MaxVal) then
      Err := Format(
        'Error: ''%s'' is an invalid range.'#13 +
        'Expecting min-max values with up to 4-digits each (e.g. 100-300).',
        [ValueStr])
    else if (Self.MinVal > 9999) or (Self.MaxVal > 9999) then
      Err := Format(
        'Error: ''%s'' is an invalid range.'#13 +
        'Expecting range values to be less than or equal to 9999.',
        [ValueStr])
    else if (Self.MinVal > Self.MaxVal) then
      Err := Format(
        'Error: ''%s'' is an invalid range.'#13 +
        'Expecting Min value to be less than Max value.',
        [ValueStr]);
    if Err = '' then
      begin
        Self.MinDigits := sl[0].Length;
        Self.MaxDigits := sl[1].Length;
      end
    else
      begin
        Self.MinDigits := 0;
        Self.MaxDigits := 0;
      end;
    Result := Err = '';

  finally
    sl.Free;
  end;
end;


function IsNum(Num: String): Boolean;
var
   X : Integer;
begin
   Result := Length(Num) > 0;
   for X := 1 to Length(Num) do begin
       if Pos(copy(Num,X,1),'0123456789') = 0 then begin
           Result := False;
           Exit;
       end;
   end;
end;


function FindContestByName(const AContestName : String) : TSimContest;
var
  C : TContestDefinition;
begin
  for C in ContestDefinitions do
    if CompareText(AContestName, C.Name) = 0 then
      begin
        Result := C.T;
        // DebugLn('Ini.FindContestByName(%s) --> %s', [AContestName, DbgS(Result)]);
        Exit;
      end;

  raise Exception.Create(
      Format('error: ''%s'' is an unsupported contest name', [AContestName]));
  Halt;
end;


end.

