//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit Log;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  Classes, ExtCtrls;

// TColor: use Integer-based definition for interface compatibility.
// LCL's Graphics.TColor is also Integer; clXxx constants remain compatible.
type
  TColor = Integer;

procedure SaveQso;
procedure LastQsoToScreen;
procedure Clear;
procedure UpdateStats(AVerifyResults : boolean);
procedure UpdateStatsHst;
procedure CheckErr;
//procedure PaintHisto;
procedure ShowRate;
procedure ScoreTableInit(const ColDefs: array of string);
procedure SetExchColumns(AExch1ColPos, AExch2ColPos: integer;
  AExch1ExColPos: integer = -1;
  AExch2ExColPos: integer = -1);
procedure ScoreTableInsert(const ACol1, ACol2, ACol3, ACol4, ACol5, ACol6: string; const ACol7: string = ''; const ACol8: string = '');
procedure ScoreTableUpdateCheck;
function FormatScore(const AScore: integer):string;
procedure UpdateSbar;
procedure SbarUpdateStationInfo(const ACallsign: string);
procedure SBarUpdateSummary(const AExchSummary: String);
procedure SBarUpdateDebugMsg(const AMsgText: string);
procedure DisplayError(const AExchError: string; const AColor: TColor);
function ExtractCallsign(Call: string): string;
function ExtractPrefix(Call: string; DeleteTrailingLetters: boolean = True): string;
{$ifdef DEBUG}
function ExtractPrefix0(Call: string): string;
{$endif}

{$ifdef DEBUG}
// Debugging API patterned after LazLogger.
// (Used in anticipation of a future port to Lazarus compiler)
procedure DebugLn(const AMsg: string) overload;
procedure DebugLn(const AFormat: string; const AArgs: array of const) overload;
procedure DebugLnEnter(const AMsg: string) overload;
procedure DebugLnEnter(const AFormat: string; const AArgs: array of const) overload;
procedure DebugLnExit(const AMsg: string) overload;
procedure DebugLnExit(const AFormat: string; const AArgs: array of const) overload;
{$endif}


type
  TLogError = (leNONE, leNIL,   leDUP, leCALL, leRST,
               leNAME, leCLASS, leNR,  leSEC,  leQTH,
               leZN,   leSOC,   leST,  lePWR,  leERR,
               lePREC, leCHK);

  PQso = ^TQso;
  TQso = record
    T: TDateTime;
    Call, TrueCall, RawCallsign: string;
    Rst, TrueRst: integer;
    Nr, TrueNr: integer;
    Prec, TruePrec: string;     // SS' Precedence character
    Check, TrueCheck: integer;  // SS' Chk (year licensed)
    Sect, TrueSect: string;     // SS' Arrl/RAC Section
    Exch1, TrueExch1: string;   // exchange 1 (e.g. 3A, OpName)
    Exch2, TrueExch2: string;   // exchange 2 (e.g. OR, CWOPSNum)
    TrueWpm: string;            // WPM of sending DxStn (reported in log)
    Pfx: string;                // extracted call prefix
    MultStr: string;            // contest-specific multiplier (e.g. Pfx, dxcc)
    Points: integer;            // points for this QSO
    Dupe: boolean;              // this qso is a DUP.
    ExchError: TLogError;       // Callsign error code
    Exch1Error: TLogError;      // Exchange 1 qso primary error code
    Exch1ExError: TLogError;    // Exchange 1 qso secondary error code (used by ARRL SS)
    Exch2Error: TLogError;      // Exchange 2 qso primary error code
    Exch2ExError: TLogError;    // Exchange 2 qso secondary error code (used by ARRL SS)
    Err: string;                // Qso error string (e.g. corrections)
    ColumnErrorFlags: Integer;  // holds column-specific errors using bit mask
                                // with (0x01 << ColumnInx).

    procedure CheckExch1(var ACorrections: TStringList);
    procedure CheckExch2(var ACorrections: TStringList);

    procedure SetColumnErrorFlag(AColumnInx: integer);
    function TestColumnErrorFlag(ColumnInx: Integer): Boolean;
  end;

  THisto= class(TObject)
    private Histo: array[0..47] of integer;
    //private w, h, CallCount: integer;
    private Duration: integer;
    private PaintBoxH: TPaintBox;
    public constructor Create(APaintBox: TPaintBox);
    public procedure ReCalc(ADuration: integer);
    public procedure Repaint;
  end;

  {
    A MultList hold a set of unique strings, each representing a unique
    multiplier for the current contest. The underlying TStringList is sorted
    and duplicate strings are ignored.

    An instance of this class is used for both raw and verified multipliers.
  }
  TMultList= class(TStringList)
    public
      constructor Create;
      procedure ApplyMults(const AMultipliers: string);
  end;

const
  EM_SCROLLCARET = $B7;
  WM_VSCROLL= $0115;

var
  QsoList: array of TQso;
  RawMultList:      TMultList; // sorted, no dups; counts raw multipliers.
  VerifiedMultList: TMultList; // sorted, no dups; counts verified multipliers.
  RawPoints:        integer;   // accumalated raw QSO points total
  VerifiedPoints:   integer;   // accumulated verified QSO points total
  CallSent: boolean; // msgHisCall has been sent; cleared upon edit.
  NrSent: boolean;   // msgNR has been sent; cleared after qso is completed.
  ShowCorrections: boolean;   // show exchange correction column.
  SBarDebugMsg: String;         // sbar debug message
  SBarStationInfo: String;    // sbar station info (UserText from call history file)
  SBarSummaryMsg: String;     // sbar exchange summary (ARRL SS)
  SBarErrorMsg: String;       // sbar exchange error
  SBarErrorColor: TColor;     // sbar exchange error color
  Histo: THisto;

  // the following column index values are used to set error flags in TQso.ColumnErrorFlags
  CallColumnInx: Integer;
  Exch1ColumnInx: Integer;
  Exch1ExColumnInx: Integer;
  Exch2ColumnInx: Integer;
  Exch2ExColumnInx: Integer;
  CorrectionColumnInx: Integer;

{$ifdef DEBUG}
  RunUnitTest : boolean;  // run ExtractPrefix unit tests once
{$endif}


implementation

uses
  SysUtils, Math, StrUtils,
  Graphics, Controls, StdCtrls,
  PerlRegEx,
  Contest, Globals, DxStn, DxOper,
  RndFunc, ExchFields, Ini, Station, MorseKey;

const
  ShowHstCorrections: Boolean = true;
  LogColUtcWidth: Integer = 80;
  LogColPadding: Integer = 10;

  UTC_COL         = 'UTC,8,L';
  CALL_COL        = 'Call,10,L';
  NR_COL          = 'Nr,4,R';
  RST_COL         = 'RST,4,R';
  ARRL_SECT_COL   = 'Sect,4,L';
  FD_CLASS_COL    = 'Class,5,L';
  CORRECTIONS_COL = 'Corrections,11,L';
  WPM_COL         = 'Wpm,3.25,R';
  WPM_FARNS_COL   = 'Wpm,5,R';
  NAME_COL        = 'Name,8,L';
  STATE_PROV_COL  = 'State,5,L';
  PREFIX_COL      = 'Pref,4,L';
  ARRLDX_EXCH_COL = 'Exch,5,R';
  CWT_EXCH_COL    = 'Exch,5,L';
  SST_EXCH_COL    = 'Exch,5,L';
  ALLJA_EXCH_COL  = 'Exch,6,L';
  ACAG_EXCH_COL   = 'Exch,8,L';
  IARU_EXCH_COL   = 'Exch,6,L';
  WPX_EXCH_COL    = 'Exch,6,L';
  HST_EXCH_COL    = 'Exch,6,L';
  CQWW_RST_COL    = 'RST,4,L';
  CQ_ZONE_COL     = 'Zone,4,L';
  SS_CALL_COL     = 'Call,9,L';
  SS_PREC_COL     = 'Pr,2.5,L';
  SS_CHECK_COL    = 'Chk,3.25,C';

{$ifdef DEBUG}
  DEBUG_INDENT: Integer = 3;
{$endif}

var
  LogColScaling: Single;
  LogColWidthPerChar: Single;
  ScaleTableInitialized: boolean;
{$ifdef DEBUG}
  Indent: Integer = 0;
{$endif}
  SBarLastCallsign: String;


{ THisto }

constructor THisto.Create(APaintBox: TPaintBox);
begin
  Self.PaintBoxH := APaintBox;
end;

procedure THisto.ReCalc(ADuration: integer);
begin
  Self.Duration := ADuration;
end;

procedure THisto.Repaint;
var
  i: integer;
  x, y, w: integer;
begin
  FillChar(Histo, SizeOf(Histo), 0);

  for i := 0 to High(QsoList) do begin
    x := Trunc(QsoList[i].T * 1440) div 5;
    Inc(Histo[x]);
  end;

  with Self.PaintBoxH, Self.PaintBoxH.Canvas do begin
    w := Trunc(ClientWidth / 48);
    Brush.Color := Color;
    FillRect(Rect(0, 0, Width, Height));
    for i := 0 to High(Histo) do begin
      Brush.Color := clGreen;
      x := i * w;
      y := Height - 3 - Histo[i] * 2;
      FillRect(Rect(x, y, x+w-1, Height-2));
    end;
  end;
end;


{ TMultList }

constructor TMultList.Create;
begin
  inherited Create;
  Self.Sorted := true;
  Self.Duplicates := dupIgnore;
end;

procedure TMultList.ApplyMults(const AMultipliers: string);
begin
  AddStrings(SplitString(AMultipliers, ';'));
end;


{ FormatScore }

function FormatScore(const AScore: integer): string;
begin
  FormatScore := format('%6d', [AScore]);
end;


{ TQso methods }

procedure TQso.SetColumnErrorFlag(AColumnInx: integer);
begin
  assert((AColumnInx > -1) and (AColumnInx < 32));
  if AColumnInx <> -1 then
    ColumnErrorFlags := ColumnErrorFlags or (1 shl AColumnInx);
end;

function TQso.TestColumnErrorFlag(ColumnInx: Integer): Boolean;
begin
  Result := (ColumnErrorFlags and (1 shl ColumnInx)) <> 0;
end;

procedure TQso.CheckExch1(var ACorrections: TStringList);
begin
  Exch1Error := leNONE;
  Exch1ExError := leNONE;

  // Adding a contest: check for contest-specific exchange field 1 errors
  case Globals.GRecvExchTypes.Exch1 of
    etRST:     if TrueRst   <> Rst   then Exch1Error := leRST;
    etOpName:  if TrueExch1 <> Exch1 then Exch1Error := leNAME;
    etFdClass: if TrueExch1 <> Exch1 then Exch1Error := leCLASS;
    etSSNrPrecedence: begin
      if TrueNR <> NR then Exch1Error := leNR;
      if TruePrec <> Prec then Exch1ExError := lePrec;
    end
    else
      assert(false, 'missing exchange 1 case');
  end;

  case Exch1Error of
    leNONE: ;
    leRST: ACorrections.Add(Format('%d', [TrueRst]));
    leNR:  ACorrections.Add(Format('%d', [TrueNR]));
    else
      ACorrections.Add(TrueExch1);
  end;
  case Exch1ExError of
    lePrec: ACorrections.Add(TruePrec);
  end;
end;


procedure TQso.CheckExch2(var ACorrections: TStringList);

  function ReducePowerStr(const text: string): string;
  begin
    assert(Globals.GRecvExchTypes.Exch2 in [etPower, etCqZone]);
    Result := StringReplace(
               StringReplace(
                StringReplace(
                 StringReplace(text, 'T', '0', [rfReplaceAll]),
                'O', '0', [rfReplaceAll]),
               'A', '1', [rfReplaceAll]),
              'N', '9', [rfReplaceAll]);
  end;

  function ReduceNumeric(const text: string): integer;
  begin
    Result := StrToIntDef(ReducePowerStr(text), 0);
  end;

begin
  Exch2Error := leNONE;
  Exch2ExError := leNONE;

  // Adding a contest: check for contest-specific exchange field 2 errors
  case Globals.GRecvExchTypes.Exch2 of
    etSerialNr:    if TrueNr <> NR then Exch2Error := leNR;
    etGenericField:
      case Ini.SimContest of
        scCwt:
          if TrueExch2 <> Exch2 then
            if IsNum(TrueExch2) then
              Exch2Error := leNR
            else
              Exch2Error := leQTH;
        scSst:
          if TrueExch2 <> Exch2 then
            Exch2Error := leQTH;
        scIaruHf:
          if TrueExch2 <> Exch2 then
            if IsNum(TrueExch2) then
              Exch2Error := leZN
            else
              Exch2Error := leSOC;
        else
          if TrueExch2 <> Exch2 then
            Exch2Error := leERR;
      end;
    etCqZone:
      if ReduceNumeric(TrueExch2) <> ReduceNumeric(Exch2) then
        Exch2Error := leZN;
    etArrlSection: if TrueExch2 <> Exch2 then Exch2Error := leSEC;
    etStateProv:   if TrueExch2 <> Exch2 then Exch2Error := leST;
    etItuZone:     if TrueExch2 <> Exch2 then Exch2Error := leZN;
    etPower: if ReducePowerStr(TrueExch2) <> ReducePowerStr(Exch2) then
               Exch2Error := lePWR;
    etJaPref: if TrueExch2 <> Exch2 then Exch2Error := leNR;
    etJaCity: if TrueExch2 <> Exch2 then Exch2Error := leNR;
    etNaQpExch2: if TrueExch2 <> Exch2 then Exch2Error := leST;
    etNaQpNonNaExch2:
      if not (TrueExch2.Equals(Exch2) or
              (Exch2.Equals('DX') and TrueExch2.IsEmpty)) then
        Exch2Error := leST;
    etSSCheckSection: begin
      if TrueCheck <> Check then Exch2Error := leCHK;
      if TrueSect <> Sect then Exch2ExError := leSEC;
    end
    else
      assert(false, 'missing exchange 2 case');
  end;

  case Exch2Error of
    leNONE: ;
    leNR:
      if (SimContest = scHst) and ShowHstCorrections and (RunMode = rmHst) then
      begin
        assert(Globals.GRecvExchTypes.Exch2 = etSerialNr);
        ACorrections.Add(format('%.4d', [TrueNR]));
      end
      else if (SimContest = scArrlSS) then
        ACorrections.Add(TrueSect)
      else
        ACorrections.Add(TrueExch2);
    leCHK:
        ACorrections.Add(format('%.02d', [TrueCheck]));
    leST:
      if (SimContest = scNaQP) and
        (Globals.GRecvExchTypes.Exch2 = etNaQpNonNaExch2) and
        TrueExch2.IsEmpty then
        ACorrections.Add(' ')
      else
        ACorrections.Add(TrueExch2);
    else
      ACorrections.Add(TrueExch2);
  end;

  case Exch2ExError of
    leNONE: ;
    leSEC:
      begin
        assert(SimContest = scArrlSS);
        ACorrections.Add(TrueSect);
      end;
    else
      assert(false);
  end;
end;


{ ScoreTableInit }

procedure ScoreTableInit(const ColDefs: array of string);
var
  I: integer;
  tl: TStringList;
  CallColumnName, CorrectionsColumnName: string;
  Name: string;
  Width: integer;
  Alignment: TAlignment;
  FS: TFormatSettings;

  function GetColumnName(const AColDef: string): string;
  begin
    Result := Copy(AColDef, 1, Pos(',', AColDef) - 1);
  end;

begin
  tl := TStringList.Create;
  tl.QuoteChar := '''';
  tl.Delimiter := ',';
  FS := DefaultFormatSettings;
  FS.DecimalSeparator := '.';
  try
    if not ScaleTableInitialized then
    begin
      Width := Globals.GLogListView.Column[0].Width;
      LogColScaling := Width / LogColUtcWidth;
      LogColWidthPerChar := Width / 8.5;
      ScaleTableInitialized := true;
    end;

    CallColumnInx := -1;
    Exch1ColumnInx := -1;
    Exch1ExColumnInx := -1;
    Exch2ColumnInx := -1;
    Exch2ExColumnInx := -1;
    CorrectionColumnInx := -1;
    CallColumnName := GetColumnName(CALL_COL);
    CorrectionsColumnName := GetColumnName(CORRECTIONS_COL);

    for I := Low(ColDefs) to High(ColDefs) do begin
      tl.DelimitedText := ColDefs[I];
      assert(tl.Count = 3);
      Name := tl[0];
      if I = 0 then
        Width := Globals.GLogListView.Column[I].Width
      else
        Width := Round(StrToFloat(tl[1], FS) * LogColWidthPerChar + LogColPadding * LogColScaling);
      Alignment := taLeftJustify;
      case tl[2][1] of
        'L': Alignment := taLeftJustify;
        'C': Alignment := taCenter;
        'R': Alignment := taRightJustify;
        else
          assert(false, 'invalid alignment');
      end;

      // add additional columns if needed
      while I >= Globals.GLogListView.Columns.Count do
        Globals.GLogListView.Columns.Add;

      Globals.GLogListView.Column[I].Caption := Name;
      Globals.GLogListView.Column[I].Width := Width;
      Globals.GLogListView.Column[I].Alignment := Alignment;

      if Name = CallColumnName then
        CallColumnInx := I
      else if CorrectionsColumnName.StartsWith(Name) then
        CorrectionColumnInx := I;
    end;

    // delete unused columns
    while I < Globals.GLogListView.Columns.Count do
      Globals.GLogListView.Columns.Delete(I);

    Log.SetExchColumns(2, 3);

  finally
    tl.Free;
  end;
end;


{ SetExchColumns }

procedure SetExchColumns(AExch1ColPos, AExch2ColPos: integer;
  AExch1ExColPos, AExch2ExColPos: integer);
begin
  Log.Exch1ColumnInx := AExch1ColPos;
  Log.Exch2ColumnInx := AExch2ColPos;
  Log.Exch1ExColumnInx := AExch1ExColPos;
  Log.Exch2ExColumnInx := AExch2ExColPos;
end;


{ ScoreTableInsert }

procedure ScoreTableInsert(const ACol1, ACol2, ACol3, ACol4, ACol5, ACol6: string; const ACol7: string = ''; const ACol8: string = '');
begin
  Globals.GLogListView.Items.BeginUpdate;
  with Globals.GLogListView.Items.Add do begin
    Caption := ACol1;
    SubItems.Add(ACol2);
    SubItems.Add(ACol3);
    SubItems.Add(ACol4);
    SubItems.Add(ACol5);
    SubItems.Add(ACol6);
    if ACol7 <> '' then SubItems.Add(ACol7);
    if ACol8 <> '' then SubItems.Add(ACol8);
    Selected := True;
  end;
  Globals.GLogListView.Items.EndUpdate;

  // LCL: scroll to last item (replaces Perform(WM_VSCROLL, SB_BOTTOM, 0))
  if Globals.GLogListView.Items.Count > 0 then
    Globals.GLogListView.Items[Globals.GLogListView.Items.Count - 1].MakeVisible(False);
end;


{ ScoreTableUpdateCheck }

procedure ScoreTableUpdateCheck;
begin
  with Globals.GLogListView do begin
    if CorrectionColumnInx > 0 then
      Items[Items.Count-1].SubItems[CorrectionColumnInx-1] := QsoList[High(QsoList)].Err;
    Invalidate;  // refresh item display (LCL: no TListItem.Update)
  end;
end;


{ SbarUpdateStationInfo }

procedure SbarUpdateStationInfo(const ACallsign: string);
var
  s: string;
begin
  if ACallsign = SBarLastCallsign then Exit;
  SBarLastCallsign := ACallsign;

  s := '';
  if ACallsign <> '' then
  begin
    // Adding a contest: SbarUpdateStationInfo - update status bar with station info
    s := Tst.GetStationInfo(ACallsign);

    // '&' are suppressed in LCL panels; replace with '&&'
    s := StringReplace(s, '&', '&&', [rfReplaceAll]);
  end;

  SBarStationInfo := s;
  UpdateSbar;
end;


{ SBarUpdateSummary }

procedure SBarUpdateSummary(const AExchSummary: String);
begin
  if SBarSummaryMsg = AExchSummary then Exit;
  SBarSummaryMsg := AExchSummary;
  UpdateSbar;
end;


{ SBarUpdateDebugMsg }

procedure SBarUpdateDebugMsg(const AMsgText: string);
begin
  if SBarDebugMsg = AMsgText then Exit;

  if AMsgText = '' then
    SBarDebugMsg := ''
  else
    SBarDebugMsg := Copy(AMsgText + '; ' + SBarDebugMsg, 1, 40);
  UpdateSbar;
end;


{ UpdateSbar }
// [<Exchange Summary> --] [(Error | UserText)] [>> Debug]

procedure UpdateSbar;
var
  S: String;
begin
  S := '';

  // optional exchange summary...
  if Ini.ShowExchangeSummary <> 0 then
    if SimContest in [scArrlSS] then
      case Ini.ShowExchangeSummary of
        1:
          if SBarSummaryMsg = '' then begin
            if Globals.GLabel3 <> nil then
              Globals.GLabel3.Caption := Exchange2Settings[etSSCheckSection].C;
          end else begin
            if Globals.GLabel3 <> nil then
              Globals.GLabel3.Caption := SBarSummaryMsg;
          end;
        2:
          S := SBarSummaryMsg;
      end;

  // error or UserText...
  if SBarErrorMsg <> '' then
  begin
    if S <> '' then
      S := S + ' -- ';
    S := S + SBarErrorMsg;
  end
  else if SBarStationInfo <> '' then
  begin
    if S <> '' then
      S := S + ' -- ';
    S := S + SBarStationInfo;
  end;

  // during debug, use status bar to show CW stream
  if SBarDebugMsg <> '' then
    S := format('  %-45s >> %-40s', [S, SBarDebugMsg]);

  if Globals.GSBar <> nil then begin
    if SBarErrorMsg = '' then
      Globals.GSBar.Font.Color := clDefault
    else
      Globals.GSBar.Font.Color := SBarErrorColor;
  end;

  Globals.GSBar.Caption := S;
end;


{ DisplayError }

procedure DisplayError(const AExchError: string; const AColor: TColor);
begin
  if (Log.SBarErrorMsg = AExchError) and
     (Log.SBarErrorColor = AColor) then Exit;

  Log.SBarErrorMsg := AExchError;
  Log.SBarErrorColor := AColor;
  UpdateSbar;
end;


{ Clear }

procedure Clear;
var
  Empty: string;
begin
  QsoList := nil;
  RawMultList.Clear;
  VerifiedMultList.Clear;
  RawPoints := 0;
  VerifiedPoints := 0;

  ShowCorrections := (SimContest <> scHst) or ShowHstCorrections;

  Tst.Stations.Clear;
  Globals.GMemo1.Lines.Clear;
  Globals.GMemo1.Font.Name := 'Consolas';
  Globals.GLogListView.Clear;

  // Adding a contest: set Score Table titles
  case Ini.SimContest of
    scCwt:
      ScoreTableInit([UTC_COL, CALL_COL, NAME_COL, CWT_EXCH_COL, CORRECTIONS_COL, WPM_COL]);
    scSst:
      ScoreTableInit([UTC_COL, CALL_COL, NAME_COL, SST_EXCH_COL, CORRECTIONS_COL, WPM_FARNS_COL]);
    scFieldDay:
      ScoreTableInit([UTC_COL, CALL_COL, FD_CLASS_COL, ARRL_SECT_COL, CORRECTIONS_COL, WPM_COL]);
    scArrlSS:
      begin
      ScoreTableInit([UTC_COL, SS_CALL_COL, NR_COL, SS_PREC_COL, SS_CHECK_COL, ARRL_SECT_COL, CORRECTIONS_COL, WPM_COL]);
      SetExchColumns(2, 4, 3, 5);
      end;
    scNaQp:
      ScoreTableInit([UTC_COL, 'Call,8,L', NAME_COL, STATE_PROV_COL, PREFIX_COL, CORRECTIONS_COL, WPM_COL]);
    scCQWW:
      ScoreTableInit([UTC_COL, CALL_COL, CQWW_RST_COL, CQ_ZONE_COL, CORRECTIONS_COL, WPM_COL]);
    scArrlDx:
      ScoreTableInit([UTC_COL, CALL_COL, RST_COL, ARRLDX_EXCH_COL, CORRECTIONS_COL, WPM_COL]);
    scAllJa:
      ScoreTableInit([UTC_COL, CALL_COL, RST_COL, ALLJA_EXCH_COL, CORRECTIONS_COL, WPM_COL]);
    scAcag:
      ScoreTableInit([UTC_COL, CALL_COL, RST_COL, ACAG_EXCH_COL, CORRECTIONS_COL, WPM_COL]);
    scIaruHf:
      ScoreTableInit([UTC_COL, CALL_COL, RST_COL, IARU_EXCH_COL, CORRECTIONS_COL, WPM_COL]);
    scWpx:
      ScoreTableInit([UTC_COL, CALL_COL, RST_COL, WPX_EXCH_COL, CORRECTIONS_COL, WPM_COL]);
    scHst:
      if ShowCorrections then
        ScoreTableInit([UTC_COL, CALL_COL, RST_COL, HST_EXCH_COL, 'Score,5,R', 'Correct,8,L', WPM_COL])
      else
        ScoreTableInit([UTC_COL, CALL_COL, 'Recv,10,L', 'Sent,9,L', 'Score,5,R', 'Chk,3,L', WPM_COL]);
    else
      assert(false, 'missing case');
  end;

  if SimContest = scHst then
    Empty := ''
  else
    Empty := FormatScore(0);

  Globals.GScoreListView.Items[0].SubItems[0] := Empty;
  Globals.GScoreListView.Items[1].SubItems[0] := Empty;
  Globals.GScoreListView.Items[0].SubItems[1] := Empty;
  Globals.GScoreListView.Items[1].SubItems[1] := Empty;
  Globals.GScoreListView.Items[2].SubItems[0] := FormatScore(0);
  Globals.GScoreListView.Items[2].SubItems[1] := FormatScore(0);

  Globals.GPaintBox1.Invalidate;
end;


{ CallToScore - local helper for HST mode }

function CallToScore(S: string): integer;
var
  i: integer;
begin
  S := Keyer.Encode(S);
  Result := -1;
  for i := 1 to Length(S) do
    case S[i] of
      '.': Inc(Result, 2);
      '-': Inc(Result, 4);
      ' ': Inc(Result, 2);
    end;
end;


{ UpdateStatsHst }

procedure UpdateStatsHst;
var
  CallScore, RawScore, Score: integer;
  i: integer;
begin
  RawScore := 0;
  Score := 0;

  for i := 0 to High(QsoList) do begin
    CallScore := CallToScore(QsoList[i].Call);
    Inc(RawScore, CallScore);
    if QsoList[i].Err = '   ' then
      Inc(Score, CallScore);
  end;

  Globals.GScoreListView.Items[0].SubItems[0] := '';
  Globals.GScoreListView.Items[1].SubItems[0] := '';
  Globals.GScoreListView.Items[2].SubItems[0] := FormatScore(RawScore);

  Globals.GScoreListView.Items[0].SubItems[1] := '';
  Globals.GScoreListView.Items[1].SubItems[1] := '';
  Globals.GScoreListView.Items[2].SubItems[1] := FormatScore(Score);

  Globals.GPaintBox1.Invalidate;

  Globals.GPanel11.Caption := IntToStr(Score);
end;


{ UpdateStats }

procedure UpdateStats(AVerifyResults: boolean);
var
  Mul: integer;
begin
  if not AVerifyResults then
    with QsoList[High(QsoList)] do
    begin
      Inc(RawPoints, Points);
      RawMultList.ApplyMults(MultStr);
    end;
  Mul := RawMultList.Count;

  Globals.GScoreListView.Items[0].SubItems[0] := FormatScore(RawPoints);
  Globals.GScoreListView.Items[1].SubItems[0] := FormatScore(Mul);
  Globals.GScoreListView.Items[2].SubItems[0] := FormatScore(RawPoints * Mul);

  if AVerifyResults then
    with QsoList[High(QsoList)] do
      if Err = '   ' then begin
        Inc(VerifiedPoints, Points);
        VerifiedMultList.ApplyMults(MultStr);
      end;
  Mul := VerifiedMultList.Count;

  Globals.GScoreListView.Items[0].SubItems[1] := FormatScore(VerifiedPoints);
  Globals.GScoreListView.Items[1].SubItems[1] := FormatScore(Mul);
  Globals.GScoreListView.Items[2].SubItems[1] := FormatScore(VerifiedPoints * Mul);

  Globals.GPaintBox1.Invalidate;
end;


{ SaveQso }

procedure SaveQso;
var
  Call: string;
  ExchError: string;
  i: integer;
  Qso: PQso;
begin
  begin
    Call := StringReplace(Globals.GEdit1Text, '?', '', [rfReplaceAll]);

    if not Tst.CheckEnteredCallLength(Call, ExchError) then
    begin
      DisplayError(ExchError, clRed);
      Exit;
    end;

    SetLength(QsoList, Length(QsoList) + 1);
    Qso := @QsoList[High(QsoList)];

    Qso.T := BlocksToSeconds(Tst.BlockNumber) / 86400;
    Qso.Call := Call;

    Tst.SaveEnteredExchToQso(Qso^, Globals.GEdit2Text, Globals.GEdit3Text);

    Qso.Points := 1;
    Qso.RawCallsign := ExtractCallsign(Qso.Call);
    Qso.Pfx := ExtractPrefix(Qso.Call);
    Qso.MultStr := Tst.ExtractMultiplier(Qso);
    if SimContest = scHst then
      Qso.Pfx := IntToStr(CallToScore(Qso.Call));

    Qso.Dupe := false;
    for i := 0 to High(QsoList) - 1 do
      with QsoList[i] do
        if (Call = Qso.Call) and (Err = '   ') then
          Qso.Dupe := true;

    // find Wpm from DX's log
    for i := Tst.Stations.Count - 1 downto 0 do
      if Tst.Stations[i] is TDxStation then
        with Tst.Stations[i] as TDxStation do
          if Oper.CallConfidenceCheck(Qso.Call, False) in [mcYes, mcAlmost] then
          begin
            Qso.TrueWpm := WpmAsText();
            Break;
          end;

    // grab data from DX's log if QSO is complete
    for i := Tst.Stations.Count - 1 downto 0 do
      if Tst.Stations[i] is TDxStation then
        with Tst.Stations[i] as TDxStation do
          if (Oper.State = osDone) and
            (Oper.CallConfidenceCheck(Qso.Call, False) in [mcYes, mcAlmost]) then
          begin
            DataToLastQso;
            Tst.ResetQsoState;
            Break;
          end;

    CheckErr;
  end;

  LastQsoToScreen;
  if SimContest = scHst then
    UpdateStatsHst
  else
    UpdateStats({AVerifyResults=}False);

  if Assigned(Globals.GWipeEditBoxesProc) then Globals.GWipeEditBoxesProc();

  if (Tst.Me.SentExchTypes.Exch1 in [etSSNrPrecedence]) or
     (Tst.Me.SentExchTypes.Exch2 in [etSerialNr]) then
    Inc(Tst.Me.NR);

  Tst.OnSaveQsoComplete;
end;


{ LastQsoToScreen }

procedure LastQsoToScreen;
begin
  with QsoList[High(QsoList)] do begin
    // Adding a contest: LastQsoToScreen, add last qso to Score Table
    case Ini.SimContest of
    scCwt:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , Exch1
        , Exch2
        , Err, format('%3s', [TrueWpm]));
    scSst:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , Exch1
        , Exch2
        , Err, format('%3s', [TrueWpm]));
    scFieldDay:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , Exch1
        , Exch2
        , Err, format('%3s', [TrueWpm]));
    scNaQp:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , Exch1
        , Exch2
        , Pfx
        , Err, format('%3s', [TrueWpm]));
    scWpx:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , format('%.3d', [Rst])
        , format('%4d', [NR])
        , Err, format('%3s', [TrueWpm]));
    scHst:
      if ShowCorrections then
        ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
          , format('%.3d', [Rst])
          , format(IfThen(RunMode = rmHst, '%.4d', '%4d'), [NR])
          , Pfx
          , Err, format('%3s', [TrueWpm]))
      else
        ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
          , format('%.3d %.4d', [Rst, Nr])
          , format('%.3d %.4d', [Tst.Me.Rst, Tst.Me.NR])
          , Pfx
          , Err, format('%3s', [TrueWpm]));
    scCQWW:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , format('%.3d', [Rst])
        , format('%.2d', [StrToIntDef(Exch2, 0)])
        , Err, format('%3s', [TrueWpm]));
    scArrlDx:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , format('%.3d', [Rst])
        , Exch2
        , Err, format('%3s', [TrueWpm]));
    scAllJa:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , format('%.3d', [Rst])
        , Exch2
        , Err, format('%3s', [TrueWpm]));
    scAcag:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , format('%.3d', [Rst])
        , Exch2
        , Err, format('%3s', [TrueWpm]));
    scIaruHf:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , format('%.3d', [Rst])
        , Exch2
        , Err, format('%3s', [TrueWpm]));
    scArrlSS:
      ScoreTableInsert(FormatDateTime('hh:nn:ss', t), Call
        , format('%4d', [NR])
        , Prec
        , format('%.2d', [Check])
        , Sect
        , Err, format('%3s', [TrueWpm]));
    else
      assert(false, 'missing case');
    end;
  end;
end;


{ CheckErr }

procedure CheckErr;
const
  ErrorStrs: array[TLogError] of string = (
    '',     'NIL', 'DUP', 'CALL', 'RST',
    'NAME', 'CL',  'NR',  'SEC',  'QTH',
    'ZN',   'SOC', 'ST',  'PWR',  'ERR',
    'PREC', 'CHK');
var
  Corrections: TStringList;
begin
  Corrections := TStringList.Create;
  try
    with QsoList[High(QsoList)] do begin
      if TrueCall = '' then
        ExchError := leNIL
      else if TrueCall <> Call then
      begin
        ExchError := leCALL;
        Corrections.Add(TrueCall);
      end
      else if Dupe and not Log.ShowCorrections then
        ExchError := leDUP
      else
        ExchError := leNONE;

      Tst.FindQsoErrors(QsoList[High(QsoList)], Corrections);

      ColumnErrorFlags := 0;

      if ExchError in [leNIL, leDUP] then
      begin
        Err := ErrorStrs[ExchError];
        if ExchError <> leDUP then SetColumnErrorFlag(CorrectionColumnInx);
      end
      else if ShowCorrections then
      begin
        if Dupe then
          Corrections.Insert(0, ErrorStrs[leDUP]);
        Corrections.StrictDelimiter := True;
        Corrections.Delimiter := ',';
        Err := StringReplace(Corrections.DelimitedText, ',', ' ', [rfReplaceAll]);
        if ExchError    <> leNONE then SetColumnErrorFlag(CallColumnInx);
        if Exch1Error   <> leNONE then SetColumnErrorFlag(Exch1ColumnInx);
        if Exch1ExError <> leNONE then SetColumnErrorFlag(Exch1ExColumnInx);
        if Exch2Error   <> leNONE then SetColumnErrorFlag(Exch2ColumnInx);
        if Exch2ExError <> leNONE then SetColumnErrorFlag(Exch2ExColumnInx);
      end
      else
      begin
        if Exch1Error <> leNONE then
          Err := ErrorStrs[Exch1Error]
        else if Exch2Error <> leNONE then
          Err := ErrorStrs[Exch2Error]
        else if Exch1ExError <> leNONE then
          Err := ErrorStrs[Exch1ExError]
        else if Exch2ExError <> leNONE then
          Err := ErrorStrs[Exch2ExError]
        else
          Err := '';
        SetColumnErrorFlag(CorrectionColumnInx);
      end;

      if Err = '' then
        Err := '   ';
    end;
  finally
    Corrections.Free;
  end;
end;


{ ShowRate }

procedure ShowRate;
var
  i, Cnt: integer;
  T, D: Single;
begin
  T := BlocksToSeconds(Tst.BlockNumber) / 86400;
  if T = 0 then Exit;
  D := Min(5/1440, T);

  Cnt := 0;
  for i := High(QsoList) downto 0 do
    if QsoList[i].T > (T - D) then Inc(Cnt) else Break;

  if Globals.GPanel7 <> nil then Globals.GPanel7.Caption := Format('%d  qso/hr.', [Round(Cnt / D / 24)]);
end;


{ ExtractCallsign - Code by BG4FQD, ported to PerlRegEx wrapper }

function ExtractCallsign(Call: string): string;
var
  reg: TPerlRegEx;
  bMatch: boolean;
begin
  reg := TPerlRegEx.Create;
  try
    Result := '';
    reg.Subject := Call;
    reg.RegEx := '(([0-9][A-Z])|([A-Z]{1,2}))[0-9][A-Z0-9]*[A-Z]';
    bMatch := reg.Match;
    if bMatch then begin
      if reg.MatchedOffset > 1 then
        bMatch := (Call[reg.MatchedOffset - 1] = '/');
      if bMatch then
        Result := string(reg.MatchedText);
    end;
  finally
    reg.Free;
  end;
end;


{$ifdef DEBUG}
function ExtractPrefix0(Call: string): string;
var
  reg: TPerlRegEx;
begin
  reg := TPerlRegEx.Create;
  try
    Result := '-';
    reg.Subject := Call;
    reg.RegEx := '(([0-9][A-Z])|([A-Z]{1,2}))[0-9]';
    if reg.Match then
      Result := string(reg.MatchedText);
  finally
    reg.Free;
  end;
end;
{$endif}


function ExtractPrefix(Call: string; DeleteTrailingLetters: boolean): string;
const
  DIGITS = ['0'..'9'];
  LETTERS = ['A'..'Z'];
var
  p: integer;
  S1, S2, Dig: string;
begin
{$ifdef DEBUG}
  if RunUnitTest then begin
    RunUnitTest := false;
    assert(ExtractPrefix0('W7SST') = 'W7');
    assert(ExtractPrefix0('W7SST/6') = 'W7');
    assert(ExtractPrefix0('N7SST/6') = 'N7');
    assert(ExtractPrefix0('F6/W7SST') = 'F6');
    assert(ExtractPrefix0('F6/AB7Q') = 'F6');
    assert(ExtractPrefix0('W7SST/W') = 'W7');
    assert(ExtractPrefix0('F6FVY/W7') = 'F6');

    assert(ExtractPrefix('W7SST') = 'W7');
    assert(ExtractPrefix('W7SST/6') = 'W6');
    assert(ExtractPrefix('N7SST/6') = 'N6');
    assert(ExtractPrefix('F6/W7SST') = 'F6');
    assert(ExtractPrefix('W7SST/W') = 'W0');
    assert(ExtractPrefix('F6FVY/W7') = 'W7');
    assert(ExtractPrefix('F6/W7SST/P') = 'F6');
    assert(ExtractPrefix('W7SST/W/QRP') = 'W0');
    assert(ExtractPrefix('F6FVY/W7/MM') = 'W7');
  end;
{$endif}
  //kill modifiers
  Call := Call + '|';
  Call := StringReplace(Call, '/QRP|', '', []);
  Call := StringReplace(Call, '/MM|', '', []);
  Call := StringReplace(Call, '/M|', '', []);
  Call := StringReplace(Call, '/P|', '', []);
  Call := StringReplace(Call, '|', '', []);
  Call := StringReplace(Call, '//', '/', [rfReplaceAll]);
  if Length(Call) < 2 then
  begin
    Result := '';
    Exit;
  end;

  Dig := '';

  //select shorter piece
  p := Pos('/', Call);
  if p = 0 then Result := Call
  else if p = 1 then Result := Copy(Call, 2, MAXINT)
  else if p = Length(Call) then Result := Copy(Call, 1, p-1)
  else
    begin
    S1 := Copy(Call, 1, p-1);
    S2 := Copy(Call, p+1, MAXINT);

    if (Length(S1) = 1) and CharInSet(S1[1], DIGITS) then begin
        Dig := S1; Result := S2;
    end
    else
        if (Length(S2) = 1) and CharInSet(S2[1], DIGITS) then begin
            Dig := S2;
            Result := S1;
        end
        else
            if Length(S1) <= Length(S2) then
                Result := S1
            else
                Result := S2;
    end;

  if Pos('/', Result) > 0 then begin
    Result := '';
    Exit;
  end;

  if not DeleteTrailingLetters then
    Exit;

  //delete trailing letters, retain at least 2 chars
  for p := Length(Result) downto 3 do
    if CharInSet(Result[p], DIGITS) then
      Break
    else
      Delete(Result, p, 1);

  //ensure digit
  if not CharInSet(Result[Length(Result)], DIGITS) then
    Result := Result + '0';
  //replace digit
  if Dig <> '' then
    Result[Length(Result)] := Dig[1];

  Result := Copy(Result, 1, 5);
end;


{$ifdef DEBUG}
procedure DebugLn(const AMsg: string) overload;
begin
  WriteLn(StringOfChar(' ', Log.Indent) + AMsg);
end;

procedure DebugLn(const AFormat: string; const AArgs: array of const) overload;
begin
  WriteLn(StringOfChar(' ', Log.Indent) + format(AFormat, AArgs));
end;

procedure DebugLnEnter(const AMsg: string) overload;
begin
  WriteLn(StringOfChar(' ', Log.Indent) + AMsg);
  Inc(Log.Indent, DEBUG_INDENT);
end;

procedure DebugLnEnter(const AFormat: string; const AArgs: array of const) overload;
begin
  WriteLn(StringOfChar(' ', Log.Indent) + format(AFormat, AArgs));
  Inc(Log.Indent, DEBUG_INDENT);
end;

procedure DebugLnExit(const AMsg: string) overload;
begin
  if AMsg <> '' then
    WriteLn(StringOfChar(' ', Log.Indent) + AMsg);
  if Log.Indent >= DEBUG_INDENT then Dec(Log.Indent, DEBUG_INDENT);
end;

procedure DebugLnExit(const AFormat: string; const AArgs: array of const) overload;
begin
  if AFormat <> '' then
    WriteLn(StringOfChar(' ', Log.Indent) + format(AFormat, AArgs));
  if Log.Indent >= DEBUG_INDENT then Dec(Log.Indent, DEBUG_INDENT);
end;
{$endif}


initialization
  RawMultList := TMultList.Create;
  VerifiedMultList := TMultList.Create;
  ScaleTableInitialized := False;
{$ifdef DEBUG}
  RunUnitTest := true;
{$endif}

finalization
  RawMultList.Free;
  VerifiedMultList.Free;

end.
