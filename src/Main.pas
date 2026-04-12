//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
unit Main;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  Classes, SysUtils, Math, TypInfo, IniFiles, StrUtils,
  Graphics, Controls, Forms, Dialogs, StdCtrls, ExtCtrls,
  ComCtrls, Spin, Buttons, Menus,
  LCLIntf, LCLType,
  SndCustm, SndOut, SndTypes, WavFile,
  Contest, Ini, VolmSldr, VolumCtl, ExchFields, Station,
  Crc32, ScoreDlg,
  MorseKey, FarnsKeyer, CallLst,
  Log, PerlRegEx, RndFunc,
  GetDataPath;

const
  sVersion: String = '1.85.3';

type

  { TMainForm }

  TMainForm = class(TForm)
    // --- controls ---
    Bevel1: TBevel;
    Panel1: TPanel;
      Label1: TLabel;
      SpeedButton4: TSpeedButton;
      SpeedButton5: TSpeedButton;
      SpeedButton6: TSpeedButton;
      SpeedButton7: TSpeedButton;
      SpeedButton8: TSpeedButton;
      SpeedButton9: TSpeedButton;
      SpeedButton10: TSpeedButton;
      SpeedButton11: TSpeedButton;
      Bevel2: TBevel;
      Edit1: TEdit;
      Label2: TLabel;
      Edit2: TEdit;
      Label3: TLabel;
      Edit3: TEdit;
      Panel2: TPanel;
      Panel3: TPanel;
        PaintBox1: TPaintBox;
      Panel4: TPanel;
      Panel7: TPanel;
      Panel8: TPanel;
        Shape2: TShape;
      Panel11: TPanel;
        ListView1: TListView;
    Panel5: TPanel;
    Panel6: TPanel;
      Shape1: TShape;
      Label12: TLabel;
      Label13: TLabel;
      Label14: TLabel;
      Label15: TLabel;
      Label16: TLabel;
      Label19: TLabel;
      Label20: TLabel;
      Label21: TLabel;
      Label22: TLabel;
      Memo1: TMemo;
      ListView2: TListView;
      sbar: TPanel;
    Panel9: TPanel;
      GroupBox3: TGroupBox;
        Label11: TLabel;
        CheckBox2: TCheckBox;
        CheckBox3: TCheckBox;
        CheckBox4: TCheckBox;
        CheckBox5: TCheckBox;
        CheckBox6: TCheckBox;
        SpinEdit3: TSpinEdit;
      GroupBox1: TGroupBox;
        Label4: TLabel;
        Label5: TLabel;
        Label6: TLabel;
        Label7: TLabel;
        Label9: TLabel;
        Label18: TLabel;
        Edit4: TEdit;
        SpinEdit1: TSpinEdit;
        CheckBox1: TCheckBox;
        ComboBox1: TComboBox;
        ComboBox2: TComboBox;
      Panel10: TPanel;
        Label8: TLabel;
        Label10: TLabel;
        SpinEdit2: TSpinEdit;
        ToolBar1: TToolBar;
          ToolButton1: TToolButton;
      ContestGroup: TGroupBox;
        Label17: TLabel;
        SimContestCombo: TComboBox;
        ExchangeEdit: TEdit;
    // --- menus ---
    MainMenu1: TMainMenu;
      File1: TMenuItem;
        ViewScoreTable1: TMenuItem;
        ViewScoreBoardMNU: TMenuItem;
        N9: TMenuItem;
        AudioRecordingEnabled1: TMenuItem;
        PlayRecordedAudio1: TMenuItem;
        N8: TMenuItem;
        Exit1: TMenuItem;
      Send1: TMenuItem;
        CQ1: TMenuItem;
        Exchange1: TMenuItem;
        TU1: TMenuItem;
        MyCall1: TMenuItem;
        HisCall1: TMenuItem;
        QSOB41: TMenuItem;
        N1: TMenuItem;
        AGN1: TMenuItem;
        NRQM: TMenuItem;
      Run1: TMenuItem;
        PileUp1: TMenuItem;
        SingleCalls1: TMenuItem;
        Competition1: TMenuItem;
        HSTCompetition2: TMenuItem;
        Stop1MNU: TMenuItem;
      Settings1: TMenuItem;
        Call1: TMenuItem;
        QSK1: TMenuItem;
        CWSpeed1: TMenuItem;
          N10WPM1: TMenuItem;
          N15WPM1: TMenuItem;
          N20WPM1: TMenuItem;
          N25WPM1: TMenuItem;
          N30WPM1: TMenuItem;
          N35WPM1: TMenuItem;
          N40WPM1: TMenuItem;
          N45WPM1: TMenuItem;
          N50WPM1: TMenuItem;
          N55WPM1: TMenuItem;
          N60WPM1: TMenuItem;
        CWBandwidth1: TMenuItem;
          N100Hz1: TMenuItem;
          N150Hz1: TMenuItem;
          N200Hz1: TMenuItem;
          N250Hz1: TMenuItem;
          N300Hz1: TMenuItem;
          N350Hz1: TMenuItem;
          N400Hz1: TMenuItem;
          N450Hz1: TMenuItem;
          N500Hz1: TMenuItem;
          N550Hz1: TMenuItem;
          N600Hz1: TMenuItem;
        CWBandwidth2: TMenuItem;
          N100Hz2: TMenuItem;
          N150Hz2: TMenuItem;
          N200Hz2: TMenuItem;
          N250Hz2: TMenuItem;
          N300Hz2: TMenuItem;
          N350Hz2: TMenuItem;
          N400Hz2: TMenuItem;
          N450Hz2: TMenuItem;
          N500Hz2: TMenuItem;
          N550Hz2: TMenuItem;
          N600Hz2: TMenuItem;
        MonLevel1: TMenuItem;
          N30dB1: TMenuItem;
          N20dB1: TMenuItem;
          N10dB1: TMenuItem;
          N0dB1: TMenuItem;
        N6: TMenuItem;
        QRN1: TMenuItem;
        QRM1: TMenuItem;
        QSB1: TMenuItem;
        Flutter1: TMenuItem;
        LIDS1: TMenuItem;
        Activity1: TMenuItem;
          N11: TMenuItem;
          N21: TMenuItem;
          N31: TMenuItem;
          N41: TMenuItem;
          N51: TMenuItem;
          N61: TMenuItem;
          N71: TMenuItem;
          N81: TMenuItem;
          N91: TMenuItem;
        N7: TMenuItem;
        Duration1: TMenuItem;
          N5min1: TMenuItem;
          N10min1: TMenuItem;
          N15min1: TMenuItem;
          N30min1: TMenuItem;
          N60min1: TMenuItem;
          N90min1: TMenuItem;
          N120min1: TMenuItem;
        Operator1: TMenuItem;
        NRDigits1: TMenuItem;
          SerialNRSet1: TMenuItem;
          SerialNRSet2: TMenuItem;
          SerialNRSet3: TMenuItem;
          SerialNRCustomRange: TMenuItem;
        CWMaxRxSpeed1: TMenuItem;
          CWMaxRxSpeedSet0: TMenuItem;
          CWMaxRxSpeedSet1: TMenuItem;
          CWMaxRxSpeedSet2: TMenuItem;
          CWMaxRxSpeedSet4: TMenuItem;
          CWMaxRxSpeedSet6: TMenuItem;
          CWMaxRxSpeedSet8: TMenuItem;
          CWMaxRxSpeedSet10: TMenuItem;
        CWMinRxSpeed1: TMenuItem;
          CWMinRxSpeedSet0: TMenuItem;
          CWMinRxSpeedSet1: TMenuItem;
          CWMinRxSpeedSet2: TMenuItem;
          CWMinRxSpeedSet4: TMenuItem;
          CWMinRxSpeedSet6: TMenuItem;
          CWMinRxSpeedSet8: TMenuItem;
          CWMinRxSpeedSet10: TMenuItem;
        mnuShowCallsignInfo: TMenuItem;
      Help1: TMenuItem;
        Readme1: TMenuItem;
        About1: TMenuItem;
        N2: TMenuItem;
        WebPage1: TMenuItem;
        N10: TMenuItem;
        FirstTime1: TMenuItem;
    PopupMenu1: TPopupMenu;
      PileupMNU: TMenuItem;
      SingleCallsMNU: TMenuItem;
      CompetitionMNU: TMenuItem;
      HSTCompetition1: TMenuItem;
      StopMNU: TMenuItem;

    // --- event handlers ---
    procedure FormCreate(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormKeyPress(Sender: TObject; var Key: Char);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormKeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
      MousePos: TPoint; var Handled: Boolean);
    procedure AlSoundOut1BufAvailable(Sender: TObject);
    procedure SendClick(Sender: TObject);
    procedure Edit1KeyPress(Sender: TObject; var Key: Char);
    procedure Edit2KeyPress(Sender: TObject; var Key: Char);
    procedure Edit3KeyPress(Sender: TObject; var Key: Char);
    procedure Edit3KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure Edit1Enter(Sender: TObject);
    procedure Edit2Enter(Sender: TObject);
    procedure Edit3Enter(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure Edit2Change(Sender: TObject);
    procedure Edit3Change(Sender: TObject);
    procedure Edit4Change(Sender: TObject);
    procedure Edit4Exit(Sender: TObject);
    procedure ExchangeEditChange(Sender: TObject);
    procedure ExchangeEditExit(Sender: TObject);
    procedure SpinEdit1Change(Sender: TObject);
    procedure SpinEdit1Exit(Sender: TObject);
    procedure SpinEdit2Change(Sender: TObject);
    procedure SpinEdit3Change(Sender: TObject);
    procedure CheckBox1Click(Sender: TObject);
    procedure CheckBoxClick(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure SimContestComboChange(Sender: TObject);
    procedure PaintBox1Paint(Sender: TObject);
    procedure Panel8MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure Shape2MouseDown(Sender: TObject; Button: TMouseButton;
      Shift: TShiftState; X, Y: Integer);
    procedure RunBtnClick(Sender: TObject);
    procedure RunMNUClick(Sender: TObject);
    procedure StopMNUClick(Sender: TObject);
    procedure ViewScoreBoardMNUClick(Sender: TObject);
    procedure ViewScoreTable1Click(Sender: TObject);
    procedure VolumeSliderDblClick(Sender: TObject);
    procedure VolumeSlider1Change(Sender: TObject);
    procedure Exit1Click(Sender: TObject);
    procedure FirstTime1Click(Sender: TObject);
    procedure About1Click(Sender: TObject);
    procedure Readme1Click(Sender: TObject);
    procedure WebPage1Click(Sender: TObject);
    procedure Call1Click(Sender: TObject);
    procedure QSK1Click(Sender: TObject);
    procedure NWPMClick(Sender: TObject);
    procedure Pitch1Click(Sender: TObject);
    procedure Bw1Click(Sender: TObject);
    procedure SelfMonClick(Sender: TObject);
    procedure File1Click(Sender: TObject);
    procedure Settings1Click(Sender: TObject);
    procedure PlayRecordedAudio1Click(Sender: TObject);
    procedure AudioRecordingEnabled1Click(Sender: TObject);
    procedure LIDS1Click(Sender: TObject);
    procedure CWMaxRxSpeedClick(Sender: TObject);
    procedure CWMinRxSpeedClick(Sender: TObject);
    procedure NRDigitsClick(Sender: TObject);
    procedure SerialNRCustomRangeClick(Sender: TObject);
    procedure Activity1Click(Sender: TObject);
    procedure Duration1Click(Sender: TObject);
    procedure Operator1Click(Sender: TObject);
    procedure mnuShowCallsignInfoClick(Sender: TObject);
    procedure ListView2CustomDrawSubItem(Sender: TCustomListView;
      Item: TListItem; SubItem: Integer; State: TCustomDrawState;
      var DefaultDraw: Boolean);
    procedure ListView2SelectItem(Sender: TObject; Item: TListItem;
      Selected: Boolean);
    procedure SimContestComboPopulate;
    procedure CWOPSNumberClick(Sender: TObject);

  private
    MustAdvance: boolean;
    UserCallsignDirty: boolean;
    UserExchangeDirty: boolean;
    CWSpeedDirty: boolean;
    RitLocal: integer;

    procedure IniErrorMsg(const aMsg: string);
    function  CreateContest(AContestId: TSimContest): TContest;
    procedure ConfigureExchangeFields;
    procedure SetMyExch1(const AExchType: TExchange1Type; const AValue: string);
    procedure SetMyExch2(const AExchType: TExchange2Type; const AValue: string);
    procedure SaveRecvFieldSizes;
    procedure RestoreRecvFields;
    procedure ResizeRecvFields;
    procedure ProcessSpace;
    procedure SendMsg(AMsg: TStationMessage);
    procedure ProcessEnter(AShift: TShiftState);
    procedure EnableCtl(Ctl: TWinControl; AEnable: boolean);
    procedure SetToolbuttonDown(AToolbutton: TToolButton; ADown: boolean);
    procedure IncRit(dF: integer);
    procedure UpdateRitIndicator;
    procedure DecSpeed;
    procedure IncSpeed;

  public
    CompetitionMode: boolean;
    RecvExchTypes: TExchTypes;
    AlSoundOut1: TAlSoundOut;
    AlWavFile1: TAlWavFile;
    VolumeSlider1: TVolumeSlider;

    procedure Run(Value: TRunMode);
    procedure RunStop;          // wrapper: Run(rmStop) — assignable to TNoArgProc
    procedure ViewScoreBoard;   // wrapper: ViewScoreBoardMNUClick — assignable to TNoArgProc
    procedure WipeBoxes;
    procedure PopupScoreWpx;
    procedure PopupScoreHst;
    procedure PopupScore;
    procedure Advance;
    procedure SetContest(AContestNum: TSimContest);
    function  SetMyExchange(const AExchange: string): Boolean;
    procedure SetDefaultRunMode(V: Integer);
    procedure SetMySerialNR;
    procedure SetQsk(Value: boolean);
    procedure SetWpm(AWpm: integer);
    function  SetMyCall(ACall: string): Boolean;
    procedure SetPitch(PitchNo: integer);
    procedure SetBw(BwNo: integer);
    procedure ReadCheckboxes;
    procedure UpdateTitleBar;
    procedure PostHiScore(const sScore: string);
    procedure UpdSerialNR(V: integer);
    procedure UpdSerialNRCustomRange(const ARange: string);
    procedure UpdCWMinRxSpeed(minspd: integer);
    procedure UpdCWMaxRxSpeed(Maxspd: integer);
  end;

function ToStr(const val: TExchange1Type): string; overload;
function ToStr(const val: TExchange2Type): string; overload;

var
  MainForm: TMainForm;
  SavedContest: Integer = -1;
  SaveEdit1Width: integer = 0;
  SaveEdit2Width: integer = 0;
  SaveEdit3Width: integer = 0;
  SaveLabel3Left: integer = 0;
  SaveEdit3Left: integer = 0;

  { debug switches - set via .INI file or compile-time switches }
  BDebugExchSettings: boolean;
  BDebugCwDecoder: boolean;
  BDebugGhosting: boolean;

const
  CDebugExchSettings: boolean = false;
  CDebugCwDecoder: boolean = false;
  CDebugGhosting: boolean = false;


implementation

uses
  fphttpclient, Globals,
  DXCC,
  ContestFactory;

{$R *.lfm}

procedure DbgLog(const S: string);
var F: TextFile;
begin
  AssignFile(F, '/tmp/mr_debug.txt');
  {$I-} Append(F); {$I+}
  if IOResult <> 0 then Rewrite(F);
  WriteLn(F, S);
  CloseFile(F);
end;


// Moved here from Ini.pas to break circular unit dependency (Ini→Main→ARRLFD→Contest→Ini)
procedure FromIni(cb : TErrMessageCallback);
var
  V: integer;
  C: PContestDefinition;
  SC: TSimContest;
  KeyName: String;
  IniFile: TCustomIniFile;

  procedure ReadSerialNRSetting(
    IniFile: TCustomIniFile;
    snt: TSerialNRTypes;
    const DefaultVal : string);
  var
    pRange: PSerialNRSettings;
    Err : string;
    ValueStr : string;
  begin
    pRange := @Ini.SerialNRSettings[snt];
    ValueStr := IniFile.ReadString(SEC_STN, pRange.Key, DefaultVal);
    if not pRange.ParseSerialNR(ValueStr, Err) then
      begin
        Err := Format(
          'Error while reading MorseRunner.ini file.'#13 +
          'Invalid Keyword Value: ''%s=%s'':'#13 +
          '%s'#13 +
          'Please correct this keyword or remove the MorseRunner.ini file.',
          [pRange.Key, pRange.RangeStr, Err]);
        cb(Err);
      end;
  end;

begin
  IniFile := TIniFile.Create(GetDataPath.GetUserPath + 'MorseRunner.ini');
  with IniFile do
    try
      // initial Contest pick will be first item in the Contest Dropdown.
      V:= Ord(FindContestByName(MainForm.SimContestCombo.Items[0]));
      // Load SimContest, but do not call SetContest() until UI is initialized.
      V:= ReadInteger(SEC_TST, 'SimContest', V);
      if V > Length(ContestDefinitions) then V := 0;
      SimContest := TSimContest(V);
      ActiveContest := @ContestDefinitions[SimContest];
      MainForm.SimContestCombo.ItemIndex :=
        MainForm.SimContestCombo.Items.IndexOf(ActiveContest.Name);

      // load contest-specific Exchange Strings from .INI file.
      for SC := Low(ContestDefinitions) to High(ContestDefinitions) do begin
        C := @ContestDefinitions[SC];
        assert(C.T = SC);
        KeyName := Format('%sExchange', [C.Key]);
        UserExchangeTbl[SC] := ReadString(SEC_STN, KeyName, C.ExchDefault);
      end;

      ArrlClass := ReadString(SEC_STN, 'ArrlClass', '3A');
      ArrlSection := ReadString(SEC_STN, 'ArrlSection', 'ON');

      // load station settings...
      // Calls to SetMyCall, SetPitch, SetBw, etc., moved to MainForm.SetContest
      Call := ReadString(SEC_STN, 'Call', Call);
      MainForm.ComboBox1.ItemIndex := ReadInteger(SEC_STN, 'Pitch', 3);
      MainForm.ComboBox2.ItemIndex := ReadInteger(SEC_STN, 'BandWidth', 9);

      HamName := ReadString(SEC_STN, 'Name', '');
      DeleteKey(SEC_STN, 'cwopsnum');  // obsolete at v1.83

      MainForm.UpdCWMaxRxSpeed(ReadInteger(SEC_STN, 'CWMaxRxSpeed', MaxRxWpm));
      MainForm.UpdCWMinRxSpeed(ReadInteger(SEC_STN, 'CWMinRxSpeed', MinRxWpm));

      // convert older NRDigits (pre-V1.84) to new SerialNR (v1.84)
      if ValueExists(SEC_STN, 'NRDigits') then begin
        NRDigits := ReadInteger(SEC_STN, 'NRDigits', NRDigits);
        case NRDigits of
          1: SerialNR := snStartContest;
          2: SerialNR := snCustomRange;
          3: SerialNR := snMidContest;
          4: SerialNR := snEndContest;
          else SerialNR := snStartContest;
        end;
        DeleteKey(SEC_STN, 'NRDigits');
        WriteInteger(SEC_STN, 'SerialNR', Ord(SerialNR));
        NRDigits := 0;
      end;

      ReadSerialNRSetting(IniFile, snMidContest, SerialNrMidContestDef);
      ReadSerialNRSetting(IniFile, snEndContest, SerialNrEndContestDef);
      ReadSerialNRSetting(IniFile, snCustomRange, SerialNrCustomRangeDef);
      MainForm.UpdSerialNRCustomRange(SerialNRSettings[snCustomRange].RangeStr);
      MainForm.UpdSerialNR(ReadInteger(SEC_STN, 'SerialNR', Ord(SerialNR)));

      Wpm := ReadInteger(SEC_STN, 'Wpm', Wpm);
      Qsk := ReadBool(SEC_STN, 'Qsk', Qsk);
      CallsFromKeyer := ReadBool(SEC_STN, 'CallsFromKeyer', CallsFromKeyer);
      GetWpmUsesGaussian := ReadBool(SEC_STN, 'GetWpmUsesGaussian', GetWpmUsesGaussian);

      Activity := ReadInteger(SEC_BND, 'Activity', Activity);
      MainForm.SpinEdit3.Value := Activity;

      MainForm.CheckBox4.Checked := ReadBool(SEC_BND, 'Qrn', Qrn);
      MainForm.CheckBox3.Checked := ReadBool(SEC_BND, 'Qrm', Qrm);
      MainForm.CheckBox2.Checked := ReadBool(SEC_BND, 'Qsb', Qsb);
      MainForm.CheckBox5.Checked := ReadBool(SEC_BND, 'Flutter', Flutter);
      MainForm.CheckBox6.Checked := ReadBool(SEC_BND, 'Lids', Lids);
      MainForm.ReadCheckBoxes;

      V := ReadInteger(SEC_TST, 'DefaultRunMode', Ord(DefaultRunMode));
      MainForm.SetDefaultRunMode(Max(Ord(rmPileUp), Min(Ord(rmHst), V)));
      Duration := ReadInteger(SEC_TST, 'Duration', Duration);
      MainForm.SpinEdit2.Value := Duration;
      HiScore := ReadInteger(SEC_TST, 'HiScore', HiScore);
      CompDuration := Max(1, Min(60, ReadInteger(SEC_TST, 'CompetitionDuration', CompDuration)));

      WebServer := ReadString(SEC_SYS, 'WebServer', DEFAULTWEBSERVER);
      SubmitHiScoreURL := ReadString(SEC_SYS, 'SubmitHiScoreURL', '');
      PostMethod := UpperCase(ReadString(SEC_SYS, 'PostMethod', 'POST'));
      MainForm.mnuShowCallsignInfo.Checked := ReadBool(SEC_SYS, 'ShowCallsignInfo', true);

      //buffer size
      V := ReadInteger(SEC_SYS, 'BufSize', 0);
      if V = 0 then
        begin V := 3; WriteInteger(SEC_SYS, 'BufSize', V); end;
      V := Max(1, Min(5, V));
      BufSize := 64 shl V;

      // [Station]
      V := ReadInteger(SEC_STN, 'SelfMonVolume', 0);
      V := max(-60, min(0, V));
      SelfMonVolume := V;
      MainForm.VolumeSlider1.Db := SelfMonVolume;
      SaveWav := ReadBool(SEC_STN, 'SaveWav', SaveWav);

      // [Settings]
      FarnsworthCharRate := ReadInteger(SEC_SET, 'FarnsworthCharacterRate', FarnsworthCharRate);
      WpmStepRate := Max(1, Min(20, ReadInteger(SEC_SET, 'WpmStepRate', WpmStepRate)));
      RitStepIncr := ReadInteger(SEC_SET, 'RitStepIncr', RitStepIncr);
      RitStepIncr := Max(-500, Min(500, RitStepIncr));
      ShowCheckSection := ReadInteger(SEC_SET, 'ShowCheckSection', ShowCheckSection);
      ShowExchangeSummary := ReadInteger(SEC_SET, 'ShowExchangeSummary', ShowExchangeSummary);
      StationIdRate := ReadInteger(SEC_SET, 'StationIdRate', StationIdRate);
      SingleCallStartDelay := ReadInteger(SEC_SET, 'SingleCallStartDelay', SingleCallStartDelay);
      SingleCallStartDelay := Max(0, Min(SingleCallStartDelay, 2500));

      // [Debug]
      DebugExchSettings := ReadBool(SEC_DBG, 'DebugExchSettings', DebugExchSettings);
      DebugCwDecoder := ReadBool(SEC_DBG, 'DebugCwDecoder', DebugCwDecoder);
      DebugGhosting := ReadBool(SEC_DBG, 'DebugGhosting', DebugGhosting);
      AllStationsWpmS := ReadInteger(SEC_DBG, 'AllStationsWpmS', AllStationsWpmS);
      F8 := ReadString(SEC_DBG, 'F8', F8);
    finally
      Free;
    end;
end;


procedure ToIni;
var
  SC: TSimContest;
  KeyName: String;
begin
  with TIniFile.Create(GetDataPath.GetUserPath + 'MorseRunner.ini') do
    try
      WriteBool(SEC_SYS, 'ShowCallsignInfo', MainForm.mnuShowCallsignInfo.Checked);

      // write contest-specfic Exchange Strings to .INI file.
      WriteInteger(SEC_TST, 'SimContest', Ord(SimContest));
      for SC := Low(ContestDefinitions) to High(ContestDefinitions) do begin
        assert(ContestDefinitions[SC].T = SC);
        KeyName := Format('%sExchange', [ContestDefinitions[SC].Key]);
        WriteString(SEC_STN, KeyName, UserExchangeTbl[SC]);
      end;

      WriteString(SEC_STN, 'ArrlClass', ArrlClass);
      WriteString(SEC_STN, 'ArrlSection', ArrlSection);

      WriteString(SEC_STN, 'Call', Call);
      WriteInteger(SEC_STN, 'Pitch', MainForm.ComboBox1.ItemIndex);
      WriteInteger(SEC_STN, 'BandWidth', MainForm.ComboBox2.ItemIndex);
      WriteInteger(SEC_STN, 'Wpm', Wpm);
      WriteBool(SEC_STN, 'Qsk', Qsk);

      {
        Note - HamName and CWOPSNum are written to .ini file by
        TMainForm.Operator1Click and TMainForm.CWOPSNumberClick.
        Once specified, HamName and CWOPSNum are added to the application's
        title bar. Thus, HamName and cwopsnum are not written here.

        WriteString(SEC_STN, 'Name', HamName);
        WriteString(SEC_STN, 'cwopsnum', CWOPSNum);
      }
      WriteInteger(SEC_STN, 'CWMaxRxSpeed', MaxRxWpm);
      WriteInteger(SEC_STN, 'CWMinRxSpeed', MinRxWpm);
      WriteInteger(SEC_STN, 'SerialNR', Ord(SerialNR));
{ future...
      WriteString(SEC_STN, Ini.SerialNRSettings[snMidContest].Key,
                           Ini.SerialNRSettings[snMidContest].RangeStr);
      WriteString(SEC_STN, Ini.SerialNRSettings[snEndContest].Key,
                           Ini.SerialNRSettings[snEndContest].RangeStr);
}
      WriteString(SEC_STN, Ini.SerialNRSettings[snCustomRange].Key,
                           Ini.SerialNRSettings[snCustomRange].RangeStr);

      WriteInteger(SEC_BND, 'Activity', Activity);
      WriteBool(SEC_BND, 'Qrn', Qrn);
      WriteBool(SEC_BND, 'Qrm', Qrm);
      WriteBool(SEC_BND, 'Qsb', Qsb);
      WriteBool(SEC_BND, 'Flutter', Flutter);
      WriteBool(SEC_BND, 'Lids', Lids);

      WriteInteger(SEC_TST, 'DefaultRunMode', Ord(DefaultRunMode));
      WriteInteger(SEC_TST, 'Duration', Duration);
      WriteInteger(SEC_TST, 'HiScore', HiScore);
      WriteInteger(SEC_TST, 'CompetitionDuration', CompDuration);

      // [Station]
      WriteInteger(SEC_STN, 'SelfMonVolume', SelfMonVolume);
      WriteBool(SEC_STN, 'SaveWav', SaveWav);

      // [Settings]
      WriteInteger(SEC_SET, 'FarnsworthCharacterRate', FarnsworthCharRate);
      WriteInteger(SEC_SET, 'WpmStepRate', WpmStepRate);
      WriteInteger(SEC_SET, 'RitStepIncr', RitStepIncr);
      WriteInteger(SEC_SET, 'ShowCheckSection', ShowCheckSection);
      WriteInteger(SEC_SET, 'ShowExchangeSummary', ShowExchangeSummary);
      WriteInteger(SEC_SET, 'StationIdRate', StationIdRate);
      WriteInteger(SEC_SET, 'SingleCallStartDelay', SingleCallStartDelay);

    finally
      Free;
    end;
end;


function ToStr(const val: TExchange1Type): string; overload;
begin
  Result := GetEnumName(typeInfo(TExchange1Type), Ord(val));
end;

function ToStr(const val: TExchange2Type): string; overload;
begin
  Result := GetEnumName(typeInfo(TExchange2Type), Ord(val));
end;

{ return whether the Edit2 control is the RST exchange field. }
function Edit2IsRST: Boolean;
begin
  Result := MainForm.RecvExchTypes.Exch1 = etRST;
end;


procedure TMainForm.IniErrorMsg(const aMsg: string);
begin
  MessageDlg(aMsg, mtError, [mbOK], 0);
end;


procedure TMainForm.FormCreate(Sender: TObject);
begin
  Randomize;

  Memo1.Font.Name := 'Consolas';
  Memo1.Font.Size := 11;

  Self.Caption := 'Morse Runner - Community Edition';
  Label12.Caption := Format('Morse Runner %s ', [sVersion]);
  Label13.Caption := Label12.Caption;
  Label14.Caption := Label12.Caption;
  ListView2.Visible := False;
  ListView2.Clear;

  UserCallsignDirty := False;
  UserExchangeDirty := False;

  // init score table (ListView1) with 3 rows: Qsos, Mults, Score
  with ListView1.Items.Add do begin Caption := 'Qsos';  SubItems.Add(''); SubItems.Add(''); end;
  with ListView1.Items.Add do begin Caption := 'Mults'; SubItems.Add(''); SubItems.Add(''); end;
  with ListView1.Items.Add do begin Caption := 'Score'; SubItems.Add(''); SubItems.Add(''); end;

  // populate contest combo
  SimContestComboPopulate;

  // load DXCC support
  gDXCCList := TDXCC.Create;

  Histo := THisto.Create(PaintBox1);

  // create audio components programmatically (not in .lfm)
  AlSoundOut1 := TAlSoundOut.Create(Self);
  AlSoundOut1.BufCount := 4;
  AlSoundOut1.OnBufAvailable := AlSoundOut1BufAvailable;

  AlWavFile1 := TAlWavFile.Create(Self);

  VolumeSlider1 := TVolumeSlider.Create(GroupBox1);
  VolumeSlider1.Parent := GroupBox1;
  VolumeSlider1.Left := 92;
  VolumeSlider1.Top := 129;
  VolumeSlider1.Width := 60;
  VolumeSlider1.Height := 20;
  VolumeSlider1.DbMax := 0;
  VolumeSlider1.DbScale := 60;
  VolumeSlider1.HintStep := 3;
  VolumeSlider1.Db := 0;
  VolumeSlider1.OnChange := VolumeSlider1Change;
  VolumeSlider1.OnDblClick := VolumeSliderDblClick;

  // Wire up Globals so simulation units can access UI without importing Main
  Globals.GLabel3        := Label3;
  Globals.GLogListView   := ListView2;
  Globals.GScoreListView := ListView1;
  Globals.GSBar          := sbar;
  Globals.GMemo1         := Memo1;
  Globals.GPaintBox1     := PaintBox1;
  Globals.GPanel11       := Panel11;
  Globals.GPanel2        := Panel2;
  Globals.GPanel4        := Panel4;
  Globals.GPanel7        := Panel7;
  Globals.GAlWavFile1    := AlWavFile1;
  Globals.GVolumeSliderValue := VolumeSlider1.Value;
  Globals.GAdvanceProc       := Self.Advance;
  Globals.GRunStopProc       := Self.RunStop;
  Globals.GPopupScoreProc    := Self.PopupScore;
  Globals.GPopupScoreHstProc := Self.PopupScoreHst;
  Globals.GPopupScoreWpxProc := Self.PopupScoreWpx;
  Globals.GSetMySerialNRProc := Self.SetMySerialNR;
  Globals.GViewScoreBoardProc := Self.ViewScoreBoard;
  Globals.GPostHiScoreProc   := Self.PostHiScore;
  Globals.GWipeEditBoxesProc := Self.WipeBoxes;
  Edit2.OnChange := Edit2Change;
  Edit3.OnChange := Edit3Change;

  // Read settings from .INI file
  FromIni(IniErrorMsg);

  BDebugExchSettings := CDebugExchSettings or Ini.DebugExchSettings;
  BDebugCwDecoder    := CDebugCwDecoder    or Ini.DebugCwDecoder;
  Globals.BDebugExchSettings := BDebugExchSettings;
  Globals.BDebugCwDecoder    := BDebugCwDecoder;

  MakeKeyer(DEFAULTRATE, Ini.BufSize);

  SetContest(Ini.SimContest);
end;


procedure TMainForm.FormShow(Sender: TObject);
begin
  // On macOS, when launched from Terminal the terminal retains keyboard focus.
  // Activate the application and give focus to the input field.
  Application.Activate;
  SetForegroundWindow(Handle);
  Edit4.SetFocus;
end;


procedure TMainForm.FormDestroy(Sender: TObject);
begin
  ToIni;
  gDXCCList.Free;
  Histo.Free;
  Tst.Free;
  DestroyKeyer;
end;


function TMainForm.CreateContest(AContestId: TSimContest): TContest;
begin
  Result := ContestFactory.CreateContest(AContestId);
end;


procedure TMainForm.AlSoundOut1BufAvailable(Sender: TObject);
begin
  if AlSoundOut1.Enabled then
    AlSoundOut1.PutData(Tst.GetAudio);
end;


procedure TMainForm.SendClick(Sender: TObject);
var
  Msg: TStationMessage;
begin
  assert(CQ1.Tag      = Ord(msgCQ));
  assert(Exchange1.Tag = Ord(msgNR));
  assert(TU1.Tag      = Ord(msgTU));
  assert(MyCall1.Tag  = Ord(msgMyCall));
  assert(HisCall1.Tag = Ord(msgHisCall));
  assert(QSOB41.Tag   = Ord(msgB4));
  assert(N1.Tag       = Ord(msgQm));
  assert(AGN1.Tag     = Ord(msgNIL));
  assert(NRQM.Tag     = Ord(msgNrQm));

  assert(SpeedButton4.Tag  = Ord(msgCQ));
  assert(SpeedButton5.Tag  = Ord(msgNR));
  assert(SpeedButton6.Tag  = Ord(msgTU));
  assert(SpeedButton7.Tag  = Ord(msgMyCall));
  assert(SpeedButton8.Tag  = Ord(msgHisCall));
  assert(SpeedButton9.Tag  = Ord(msgB4));
  assert(SpeedButton10.Tag = Ord(msgQm));
  assert(SpeedButton11.Tag = Ord(msgNIL));

  Msg := TStationMessage((Sender as TComponent).Tag);
  SendMsg(Msg);
end;


procedure TMainForm.SendMsg(AMsg: TStationMessage);
begin
  if SpinEdit1.Focused then
    SpinEdit1Exit(SpinEdit1);

  if AMsg = msgHisCall then
  begin
    Tst.SetHisCall(Edit1.Text);
    RecvExchTypes := Tst.GetRecvExchTypes(skMyStation, Tst.Me.MyCall, Tst.Me.HisCall);
    Globals.GRecvExchTypes := RecvExchTypes;
  end;
  if AMsg = msgNR then
    NrSent := true;
  Tst.Me.SendMsg(AMsg);
end;


procedure TMainForm.Edit1KeyPress(Sender: TObject; var Key: Char);
begin
  if not CharInSet(Key, ['A'..'Z', 'a'..'z', '0'..'9', '/', '?', #8]) then
    Key := #0;
end;

procedure TMainForm.Edit2KeyPress(Sender: TObject; var Key: Char);
begin
  case RecvExchTypes.Exch1 of
    etRST:
      begin
        if RunMode <> rmHst then
          case Key of
            'a', 'A': Key := '1';
            'e', 'E': Key := '5';
            'n', 'N': Key := '9';
          end;
        if not CharInSet(Key, ['0'..'9', #8]) then
          Key := #0;
      end;
    etOpName:
      begin
        if not CharInSet(Key, ['A'..'Z', 'a'..'z', #8]) then
          Key := #0;
      end;
    etFdClass:
      begin
        if not CharInSet(Key, ['0'..'9','A'..'F','a'..'f','X','x',#8]) then
          Key := #0;
      end;
  else
    assert(false, Format('invalid exchange field 1 type: %s', [ToStr(RecvExchTypes.Exch1)]));
  end;
end;

procedure TMainForm.Edit3KeyUp(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  ExchSummary, ExchError: string;
begin
  if (SimContest in [scArrlSS]) and ((Key < VK_F1) or (Key > VK_F12)) then
  begin
    if Tst.OnExchangeEdit(Edit1.Text, Edit2.Text, Edit3.Text,
      ExchSummary, ExchError) then
    begin
      Log.SBarUpdateSummary(ExchSummary);
      if not Log.SBarErrorMsg.IsEmpty and ExchError.IsEmpty then
        Log.DisplayError('', clDefault);
    end;
  end;
end;

procedure TMainForm.Edit3Enter(Sender: TObject);
begin
  Edit3.SelStart := 0;
  Edit3.SelLength := Edit3.GetTextLen;
end;

procedure TMainForm.Edit3KeyPress(Sender: TObject; var Key: Char);
begin
  case RecvExchTypes.Exch2 of
    etSerialNr, etItuZone, etAge:
      begin
        if RunMode <> rmHst then
          case Key of
            'a', 'A': Key := '1';
            'n', 'N': Key := '9';
            't', 'T': Key := '0';
          end;
        if not CharInSet(Key, ['0'..'9', #8]) then
          Key := #0;
      end;
    etCqZone:
      begin
        if RunMode <> rmHst then
          case Key of
            'a', 'A': Key := '1';
            'n', 'N': Key := '9';
            'o', 'O': Key := '0';
            't', 'T': Key := '0';
          end;
        if not CharInSet(Key, ['0'..'9', #8]) then
          Key := #0;
      end;
    etGenericField:
      begin
        if not CharInSet(Key, ['0'..'9', 'A'..'Z', 'a'..'z', #8]) then
          Key := #0;
      end;
    etPower:
      begin
        if not CharInSet(Key, ['0'..'9', 'K', 'k', 'W', 'w', 'A', 'a',
                               'n', 'N', 'o', 'O', 't', 'T', #8]) then
          Key := #0;
      end;
    etArrlSection:
      begin
        if not CharInSet(Key, ['A'..'Z', 'a'..'z', #8]) then
          Key := #0;
      end;
    etStateProv:
      begin
        if not CharInSet(Key, ['A'..'Z', 'a'..'z', #8]) then
          Key := #0;
      end;
    etNaQPExch2, etNaQpNonNaExch2:
      begin
        if not CharInSet(Key, ['0'..'9', 'A'..'Z', 'a'..'z', '/', #8]) then
          Key := #0;
      end;
    etJaPref, etJaCity:
      begin
        if not CharInSet(Key, ['0'..'9', 'L', 'M', 'H', 'P', 'l', 'm', 'h', 'p', #8]) then
          Key := #0;
      end;
    etSSCheckSection:
      begin
        if not CharInSet(Key, ['0'..'9', 'A'..'Z', 'a'..'z', '/', #32, #8]) then
          Key := #0;
      end;
  else
    assert(false, Format('invalid exchange field 2 type: %s', [ToStr(RecvExchTypes.Exch2)]));
  end;
end;


procedure TMainForm.FormKeyPress(Sender: TObject; var Key: Char);
var
  ExchError: string;
begin
  case Key of
    #23: // ^W = Wipe
      WipeBoxes;
    #21: // ^U = pileup activity toggle
      begin
        if NoStopActivity = 0 then
        begin
          Label8.Caption := 'min';
          NoStopActivity := 1;
        end
        else
        begin
          NoStopActivity := 0;
          Label8.Caption := 'min.';
        end;
      end;
    #25: // ^Y = Edit
      ;
    #27: // Esc = Abort send
      begin
        if msgHisCall in Tst.Me.Msg then
          CallSent := false;
        if msgNR in Tst.Me.Msg then
          NrSent := false;
        Tst.Me.AbortSend;
      end;
    ';': // <his> <#>
      begin
        Tst.OnExchangeEditComplete;
        SendMsg(msgHisCall);
        SendMsg(msgNr);
      end;
    '.', '+', '[', ',': // TU & Save
      begin
        ExchError := '';
        if not Tst.CheckEnteredCallLength(Edit1.Text, ExchError) then
        begin
          DisplayError(ExchError, clRed);
          Exit;
        end;
        Tst.OnExchangeEditComplete;
        if not CallSent then
          SendMsg(msgHisCall);
        SendMsg(msgTU);
        Log.SaveQso;
      end;
    ' ': // advance to next exchange field
      if (ActiveControl <> ExchangeEdit) and
         not ((ActiveControl = Edit3) and (SimContest = scArrlSS)) then
        ProcessSpace
      else
        Exit;
  else
    Exit;
  end;
  Key := #0;
end;


procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_INSERT:
      begin
        Tst.OnExchangeEditComplete;
        SendMsg(msgHisCall);
        SendMsg(msgNr);
        Key := 0;
      end;
    VK_RETURN:
      ProcessEnter(Shift);
    87, 119: // Alt-W = Wipe
      if ssAlt in Shift then WipeBoxes else Exit;
    VK_UP:
      if not (ssCtrl in Shift) then IncRit(1)
      else if RunMode <> rmHst then SetBw(ComboBox2.ItemIndex + 1);
    VK_DOWN:
      if not (ssCtrl in Shift) then IncRit(-1)
      else if RunMode <> rmHst then SetBw(ComboBox2.ItemIndex - 1);
    VK_PRIOR: // PgUp
      IncSpeed;
    VK_NEXT: // PgDn
      DecSpeed;
    VK_F9:
      if (ssAlt in Shift) or (ssCtrl in Shift) then DecSpeed;
    VK_F10:
      if (ssAlt in Shift) or (ssCtrl in Shift) then IncSpeed;
    VK_F11:
      WipeBoxes;
  else
    Exit;
  end;
  Key := 0;
end;


procedure TMainForm.FormKeyUp(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  case Key of
    VK_INSERT, VK_RETURN:
      Key := 0;
  end;
end;


procedure TMainForm.FormMouseWheelDown(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if not (ssCtrl in Shift) then IncRit(1)
  else if RunMode <> rmHst then SetBw(ComboBox2.ItemIndex - 1);
  Handled := true;
end;

procedure TMainForm.FormMouseWheelUp(Sender: TObject; Shift: TShiftState;
  MousePos: TPoint; var Handled: Boolean);
begin
  if not (ssCtrl in Shift) then IncRit(-1)
  else if RunMode <> rmHst then SetBw(ComboBox2.ItemIndex + 1);
  Handled := true;
end;


procedure TMainForm.ProcessSpace;
begin
  MustAdvance := false;
  if Edit2IsRST then
  begin
    if ActiveControl = Edit1 then
    begin
      if Edit2.Text = '' then Edit2.Text := '599';
      ActiveControl := Edit3;
    end
    else if ActiveControl = Edit2 then
    begin
      if Edit2.Text = '' then Edit2.Text := '599';
      ActiveControl := Edit3;
    end
    else
      ActiveControl := Edit1;
  end
  else
  begin
    if ActiveControl = Edit1 then
    begin
      if SimContest = scFieldDay then
        SbarUpdateStationInfo(Edit1.Text);
      if SimContest = scArrlSS then
        ActiveControl := Edit3
      else
        ActiveControl := Edit2;
    end
    else if ActiveControl = Edit2 then
      ActiveControl := Edit3
    else
      ActiveControl := Edit1;
  end;
end;


procedure TMainForm.ProcessEnter(AShift: TShiftState);
var
  C, N, R, Q: boolean;
  ExchError: string;
begin
  if ActiveControl = ExchangeEdit then
  begin
    ExchangeEditExit(ActiveControl);
    Exit;
  end;
  if ActiveControl = Edit4 then
  begin
    Edit4Exit(ActiveControl);
    Exit;
  end;
  if ActiveControl = SpinEdit1 then
  begin
    SpinEdit1Exit(ActiveControl);
    if RunMode = rmStop then
      Exit;
  end;
  MustAdvance := false;
  ExchError := '';

  sbar.Font.Color := clDefault;

  // Ctrl/Shift/Alt + Enter → shortcut to SaveQSO
  if (ssCtrl in AShift) or (ssShift in AShift) or (ssAlt in AShift) then
  begin
    if not Tst.CheckEnteredCallLength(Edit1.Text, ExchError) then
    begin
      DisplayError(ExchError, clRed);
      Exit;
    end;
    Log.SaveQso;
    Exit;
  end;

  if SimContest in [scCwt, scFieldDay, scWpx, scCQWW, scArrlDx, scIaruHf] then
    SbarUpdateStationInfo(Edit1.Text)
  else if not BDebugCwDecoder then
    SbarUpdateStationInfo('');

  if Edit1.Text = '' then
  begin
    SendMsg(msgCq);
    if (RunMode <> rmStop) and
          ((ActiveControl = SpinEdit1) or (ActiveControl = SpinEdit3)) then
      MustAdvance := true;
    Exit;
  end;

  Tst.OnExchangeEditComplete;
  DisplayError('', clDefault);

  C := CallSent;
  N := NrSent;
  Q := (Edit2.Text <> '') or (SimContest in [scArrlSS]);
  case SimContest of
    scArrlSS:
      R := Tst.ValidateEnteredExchange(Edit1.Text, Edit2.Text, Edit3.Text, ExchError);
    scNaQp:
      R := (Edit3.Text <> '') or (not Tst.IsCallLocalToContest(Edit1.Text));
  else
    R := (Edit3.Text <> '');
  end;

  if (not C) or ((not N) and (not R)) then
    SendMsg(msgHisCall);
  if not N then
    SendMsg(msgNR);
  if N and (not R or not Q) then
  begin
    DisplayError(ExchError, clDefault);
    SendMsg(msgQm);
  end;

  if R and Q and (C or N) then
  begin
    if not Tst.ValidateEnteredExchange(Edit1.Text, Edit2.Text, Edit3.Text, ExchError) then
    begin
      DisplayError(ExchError, clRed);
      Exit;
    end;
    SendMsg(msgTU);
    Log.SaveQso;
  end
  else
    MustAdvance := true;
end;


procedure TMainForm.Edit1Enter(Sender: TObject);
var
  P: integer;
begin
  P := Pos('?', Edit1.Text);
  if P > 0 then
  begin
    Edit1.SelStart := P - 1;
    Edit1.SelLength := 1;
  end;
end;

procedure TMainForm.Edit2Enter(Sender: TObject);
begin
  if Edit2IsRST then
  begin
    if Length(Edit2.Text) = 3 then
    begin
      Edit2.SelStart := 1;
      Edit2.SelLength := 1;
    end;
  end
  else
  begin
    Edit2.SelStart := 0;
    Edit2.SelLength := Edit2.GetTextLen;
  end;
end;


procedure TMainForm.IncSpeed;
begin
  if RunMode = rmHST then
    SetWpm(Trunc(Wpm / 5) * 5 + 5)
  else
    SetWpm(Wpm + Ini.WpmStepRate);
end;

procedure TMainForm.DecSpeed;
begin
  if RunMode = rmHST then
    SetWpm(Ceil(Wpm / 5) * 5 - 5)
  else
    SetWpm(Wpm - Ini.WpmStepRate);
end;


procedure TMainForm.Edit4Change(Sender: TObject);
begin
  UserCallsignDirty := True;
end;

procedure TMainForm.Edit4Exit(Sender: TObject);
begin
  if UserCallsignDirty then
    SetMyCall(Trim(Edit4.Text));
end;

procedure TMainForm.ExchangeEditChange(Sender: TObject);
begin
  UserExchangeDirty := True;
end;

procedure TMainForm.ExchangeEditExit(Sender: TObject);
begin
  if UserExchangeDirty then
    SetMyExchange(Trim(ExchangeEdit.Text));
end;


procedure TMainForm.SetContest(AContestNum: TSimContest);
begin
  if not (AContestNum in [scWpx, scCwt, scFieldDay, scNaQp, scHst,
    scCQWW, scArrlDx, scSst, scAllJa, scAcag, scIaruHf, scArrlSS]) then
  begin
    ShowMessage('The selected contest is not yet supported.');
    SimContestCombo.ItemIndex :=
      SimContestCombo.Items.IndexOf(ActiveContest.Name);
    Exit;
  end;

  WipeBoxes;
  RestoreRecvFields;

  sbar.Caption := '';
  sbar.Font.Color := clDefault;
  sbar.Visible := mnuShowCallsignInfo.Checked;

  if Assigned(Tst) then
    FreeAndNil(Tst);

  assert(ContestDefinitions[AContestNum].T = AContestNum,
    'Contest definitions are out of order');

  Ini.SimContest := AContestNum;
  Ini.ActiveContest := @ContestDefinitions[AContestNum];
  SimContestCombo.ItemIndex :=
    SimContestCombo.Items.IndexOf(Ini.ActiveContest.Name);

  Tst := CreateContest(AContestNum);

  FreeAndNil(Keyer);
  if SimContest in [scSST] then
    Keyer := TFarnsKeyer.Create(DEFAULTRATE, Ini.BufSize)
  else
    Keyer := TKeyer.Create(DEFAULTRATE, Ini.BufSize);

  DbgLog('SetContest: ExchangeEdit.Text will be set to: [' + Ini.UserExchangeTbl[SimContest] + ']');
  ExchangeEdit.Text := UpperCase(Ini.UserExchangeTbl[SimContest]);
  DbgLog('SetContest: ExchangeEdit.Text after set: [' + ExchangeEdit.Text + ']');
  SetMyCall(UpperCase(Ini.Call));
  SetPitch(ComboBox1.ItemIndex);
  SetBw(ComboBox2.ItemIndex);
  SetWpm(Ini.Wpm);
  SetQsk(Ini.Qsk);

  assert(Tst.Filt.SamplesInInput = Ini.BufSize);
  assert(Tst.Filt2.SamplesInInput = Ini.BufSize);
  assert(Tst.Me.SentExchTypes = Tst.GetSentExchTypes(skMyStation, Ini.Call));
end;


function TMainForm.SetMyExchange(const AExchange: string): Boolean;
var
  sl: TStringList;
  ExchError: string;
  SentExchTypes: TExchTypes;
begin
  DbgLog('SetMyExchange called: AExchange=' + AExchange + ' Ini.Call=' + Ini.Call);
  sl := TStringList.Create;
  try
    DbgLog('SetMyExchange: checking SentExchTypes assert');
    assert(Tst.Me.SentExchTypes = Tst.GetSentExchTypes(skMyStation, Ini.Call),
      'set by TMainForm.SetMyCall');
    SentExchTypes := Tst.Me.SentExchTypes;

    DbgLog('SetMyExchange: calling ValidateMyExchange');
    if not Tst.ValidateMyExchange(AExchange, sl, ExchError) then
    begin
      DbgLog('SetMyExchange: ValidateMyExchange failed: ' + ExchError);
      Result := False;
      DisplayError(ExchError, clRed);
      ExchangeEdit.Text := AExchange;
      Ini.UserExchangeTbl[SimContest] := AExchange;
      Exit;
    end
    else
    begin
      Result := True;
      sbar.Visible := mnuShowCallsignInfo.Checked;
      sbar.Font.Color := clDefault;
      sbar.Caption := '';
    end;

    if (Ord(SimContest) <> SavedContest) and (SaveEdit3Left <> 0) then
      RestoreRecvFields;

    SetMyExch1(SentExchTypes.Exch1, sl[0]);
    SetMyExch2(SentExchTypes.Exch2, sl[1]);
    assert(Tst.Me.SentExchTypes = SentExchTypes);

    ExchangeEdit.Text := AExchange;
    Ini.UserExchangeTbl[SimContest] := AExchange;
    UpdateTitleBar;
    UserExchangeDirty := False;
  finally
    sl.Free;
  end;
end;


procedure TMainForm.UpdateTitleBar;
begin
  if (SimContest = scHst) and not HamName.IsEmpty then
    Caption := Format('Morse Runner - Community Edition:  %s', [HamName])
  else
    Caption := 'Morse Runner - Community Edition';
end;


procedure TMainForm.SetDefaultRunMode(V: Integer);
begin
  if (V >= Ord(rmPileUp)) and (V <= Ord(rmHst)) then
    DefaultRunMode := TRunMode(V)
  else
    DefaultRunMode := rmPileUp;

  assert(PopupMenu1.Items[0].Tag = Ord(rmPileUp));
  assert(PopupMenu1.Items[1].Tag = Ord(rmSingle));
  assert(PopupMenu1.Items[2].Tag = Ord(rmWpx));
  assert(PopupMenu1.Items[3].Tag = Ord(rmHst));
  PopupMenu1.Items[Ord(DefaultRunMode) - 1].Default := True;
end;


procedure TMainForm.SetMySerialNR;
begin
  assert(Tst.Me.SentExchTypes.Exch2 = etSerialNr);
  SetMyExch2(Tst.Me.SentExchTypes.Exch2, Ini.UserExchange2[SimContest]);
end;


function TMainForm.SetMyCall(ACall: string): Boolean;
var
  err: string;
begin
  Ini.Call := ACall;
  Edit4.Text := ACall;
  Tst.Me.MyCall := ACall;

  if not Tst.OnSetMyCall(ACall, err) then
  begin
    MessageDlg(err, mtError, [mbOK], 0);
    Result := False;
    Exit;
  end;
  assert(Tst.Me.SentExchTypes = Tst.GetSentExchTypes(skMyStation, ACall));

  Result := SetMyExchange(Trim(ExchangeEdit.Text));
  ConfigureExchangeFields;
  UserCallsignDirty := False;
end;


procedure TMainForm.ConfigureExchangeFields;
const
  AExchangeLabel: PChar = 'Exchange';
var
  Visible: Boolean;
begin
  RecvExchTypes := Tst.GetRecvExchTypes(skMyStation, Tst.Me.MyCall, Trim(Edit1.Text));
  Globals.GRecvExchTypes := RecvExchTypes;
  ResizeRecvFields;

  Visible := AExchangeLabel <> '';
  Label17.Visible := Visible;
  ExchangeEdit.Visible := Visible;
  Label17.Caption := AExchangeLabel;
  ExchangeEdit.Enabled := ActiveContest.ExchFieldEditable;

  assert(RecvExchTypes.Exch1 = TExchange1Type(Exchange1Settings[RecvExchTypes.Exch1].T),
    Format('Exchange1Settings[%d] ordering error', [Ord(RecvExchTypes.Exch1)]));
  Label2.Caption := Exchange1Settings[RecvExchTypes.Exch1].C;
  Edit2.MaxLength := Exchange1Settings[RecvExchTypes.Exch1].L;

  assert(RecvExchTypes.Exch2 = TExchange2Type(Exchange2Settings[RecvExchTypes.Exch2].T),
    Format('Exchange2Settings[%d] ordering error', [Ord(RecvExchTypes.Exch2)]));
  Label3.Caption := Exchange2Settings[RecvExchTypes.Exch2].C;
  Edit3.MaxLength := Exchange2Settings[RecvExchTypes.Exch2].L;
end;


procedure TMainForm.SetMyExch1(const AExchType: TExchange1Type;
  const AValue: string);
var
  L: integer;
begin
  case AExchType of
    etRST:
      begin
        Ini.UserExchange1[SimContest] := AValue;
        Tst.Me.RST := StrToInt(StringReplace(StringReplace(AValue, 'E', '5', [rfReplaceAll]), 'N', '9', [rfReplaceAll]));
        Tst.Me.Exch1 := AValue;
        if BDebugExchSettings then Edit2.Text := AValue;
      end;
    etOpName:
      begin
        Ini.HamName := AValue;
        Ini.UserExchange1[SimContest] := AValue;
        Tst.Me.OpName := AValue;
        Tst.Me.Exch1 := AValue;
        if BDebugExchSettings then Edit2.Text := AValue;
      end;
    etFdClass:
      begin
        Ini.ArrlClass := AValue;
        Ini.UserExchange1[SimContest] := AValue;
        Tst.Me.Exch1 := AValue;
        if BDebugExchSettings then Edit2.Text := AValue;
      end;
    etSSNrPrecedence:
      begin
        Ini.UserExchange1[SimContest] := AValue;
        if AValue.IsEmpty then
        begin
          Tst.Me.NR := 1;
          Tst.Me.Exch1 := '';
        end
        else if AValue[1] = '#' then
        begin
          if SerialNR in [snMidContest, snEndContest] then
            Tst.Me.NR := 1 + (Tst.GetRandomSerialNR div 10) * 10
          else
            Tst.Me.NR := 1;
          L := 2;
          if AValue[L] = ' ' then
            while AValue[L+1] = ' ' do
              Inc(L);
          Tst.Me.Exch1 := AValue.Substring(L-1);
        end
        else if CharInSet(AValue[1], ['0'..'9']) then
        begin
          L := 1;
          repeat Inc(L) until not CharInSet(AValue[L], ['0'..'9']);
          Tst.Me.NR := AValue.Substring(0, L-1).ToInteger;
          if AValue[L] = ' ' then
            while AValue[L+1] = ' ' do
              Inc(L);
          Tst.Me.Exch1 := AValue.Substring(L-1);
          if BDebugExchSettings then Edit2.Text := AValue;
        end
        else
        begin
          if SerialNR in [snMidContest, snEndContest] then
            Tst.Me.NR := 1 + (Tst.GetRandomSerialNR div 10) * 10
          else
            Tst.Me.NR := 1;
          Tst.Me.Exch1 := ' ' + AValue;
        end;
        if BDebugExchSettings then Edit2.Text := AValue;
      end;
  else
    assert(false, Format('Unsupported exchange 1 type: %s.', [ToStr(AExchType)]));
  end;
  Tst.Me.SentExchTypes.Exch1 := AExchType;
end;


procedure TMainForm.SetMyExch2(const AExchType: TExchange2Type;
  const AValue: string);
var
  S: string;
begin
  assert(RunMode = rmStop);
  case AExchType of
    etSerialNr:
      begin
        S := StringReplace(StringReplace(StringReplace(AValue, 'T', '0', [rfReplaceAll]),
          'O', '0', [rfReplaceAll]), 'N', '9', [rfReplaceAll]);
        Ini.UserExchange2[SimContest] := AValue;
        if SimContest = scHST then
          Tst.Me.NR := 1
        else if (Pos('#', S) > 0) and (SerialNR in [snMidContest, snEndContest]) then
          Tst.Me.NR := 1 + (Tst.GetRandomSerialNR div 10) * 10
        else if IsNum(S) then
          Tst.Me.Nr := StrToInt(S)
        else
          Tst.Me.Nr := 1;
        if BDebugExchSettings then Edit3.Text := IntToStr(Tst.Me.Nr);
      end;
    etGenericField, etNaQpExch2, etNaQpNonNaExch2:
      begin
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then Edit3.Text := AValue;
      end;
    etArrlSection:
      begin
        Ini.ArrlSection := AValue;
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then Edit3.Text := AValue;
      end;
    etStateProv, etPower:
      begin
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then Edit3.Text := AValue;
      end;
    etCqZone:
      begin
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then Edit3.Text := AValue;
      end;
    etItuZone:
      begin
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then Edit3.Text := AValue;
      end;
    etJaPref:
      begin
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then Edit3.Text := AValue;
      end;
    etJaCity:
      begin
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then Edit3.Text := AValue;
      end;
    etSSCheckSection:
      begin
        Ini.UserExchange2[SimContest] := AValue;
        Tst.Me.Exch2 := AValue;
        if BDebugExchSettings then
        begin
          Edit3.Text := Edit2.Text + ' ' + AValue;
          Edit2.Text := '';
        end;
      end;
  else
    assert(false, Format('Unsupported exchange 2 type: %s.', [ToStr(AExchType)]));
  end;
  Tst.Me.SentExchTypes.Exch2 := AExchType;
end;


procedure TMainForm.SaveRecvFieldSizes;
begin
  SaveEdit1Width := Edit1.Width;
  SaveEdit2Width := Edit2.Width;
  SaveEdit3Width := Edit3.Width;
  SaveLabel3Left := Label3.Left;
  SaveEdit3Left  := Edit3.Left;
  SavedContest   := Ord(Ini.SimContest);
end;


procedure TMainForm.RestoreRecvFields;
begin
  if SaveEdit3Left <> 0 then
  begin
    Edit1.Width  := SaveEdit1Width;
    Edit2.Width  := SaveEdit2Width;
    Edit3.Width  := SaveEdit3Width;
    Label3.Left  := SaveLabel3Left;
    Edit3.Left   := SaveEdit3Left;
    Label2.Show;
    Edit2.Show;
    SaveEdit1Width := 0;
    SaveEdit2Width := 0;
    SaveEdit3Width := 0;
    SaveLabel3Left := 0;
    SaveEdit3Left  := 0;
    SavedContest   := UndefSimContest;
  end;
end;


procedure TMainForm.ResizeRecvFields;
var
  Reduce1: integer;
  L1, L2: integer;
  CharWidth: Single;
  Delta: integer;
begin
  case SimContest of
    scArrlSS:
      if SaveEdit3Left = 0 then
      begin
        SaveRecvFieldSizes;
        Edit2.Hide;
        Label2.Hide;
        Reduce1 := (SaveEdit1Width * 4) div 9;
        Label3.Left := Label3.Left - (Label3.Left - Label2.Left) - Reduce1;
        Edit3.Left  := Edit2.Left - Reduce1;
        Edit3.Width := Edit3.Width + (SaveEdit3Left - Edit2.Left + Reduce1 + 15);
        Edit1.Width := Edit1.Width - Reduce1;
      end;
    scAllJa, scAcag:
      if SaveEdit3Left = 0 then
      begin
        SaveRecvFieldSizes;
        L1 := Exchange1Settings[RecvExchTypes.Exch1].L + 1;
        L2 := Exchange2Settings[RecvExchTypes.Exch2].L + 1;
        CharWidth := (SaveEdit2Width + SaveEdit3Width) / (L1 + L2);
        Edit2.Width := Round(CharWidth * L1);
        Edit3.Width := Round(CharWidth * L2);
        Delta := SaveEdit2Width - Edit2.Width;
        Label3.Left := Label3.Left - Delta;
        Edit3.Left  := Edit3.Left  - Delta;
      end;
  end;
end;


procedure TMainForm.SetPitch(PitchNo: integer);
begin
  PitchNo := Max(0, Min(PitchNo, ComboBox1.Items.Count - 1));
  Ini.Pitch := 300 + PitchNo * 50;
  ComboBox1.ItemIndex := PitchNo;
  Tst.Modul.CarrierFreq := Ini.Pitch;
end;


procedure TMainForm.SetBw(BwNo: integer);
begin
  BwNo := Max(0, Min(BwNo, ComboBox2.Items.Count - 1));
  Ini.Bandwidth := 100 + BwNo * 50;
  ComboBox2.ItemIndex := BwNo;
  Tst.Filt.Points  := Round(0.7 * DEFAULTRATE / Ini.BandWidth);
  Tst.Filt.GainDb  := 10 * Log10(500 / Ini.Bandwidth);
  Tst.Filt2.Points := Tst.Filt.Points;
  Tst.Filt2.GainDb := Tst.Filt.GainDb;
  UpdateRitIndicator;
end;


procedure TMainForm.SimContestComboChange(Sender: TObject);
begin
  SetContest(FindContestByName(SimContestCombo.Items[SimContestCombo.ItemIndex]));
end;

procedure TMainForm.SimContestComboPopulate;
var
  C: TContestDefinition;
begin
  SimContestCombo.Items.Clear;
  for C in ContestDefinitions do
    SimContestCombo.Items.Add(C.Name);
  SimContestCombo.Sorted := True;
end;

procedure TMainForm.ComboBox2Change(Sender: TObject);
begin
  SetBw(ComboBox2.ItemIndex);
end;

procedure TMainForm.ComboBox1Change(Sender: TObject);
begin
  SetPitch(ComboBox1.ItemIndex);
end;


procedure TMainForm.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  AlSoundOut1.Enabled := false;
  if AlWavFile1.IsOpen then AlWavFile1.Close;
end;


procedure TMainForm.SpinEdit1Change(Sender: TObject);
begin
  if SpinEdit1.Focused then
    CWSpeedDirty := True
  else
    SetWpm(SpinEdit1.Value);
end;

procedure TMainForm.SpinEdit1Exit(Sender: TObject);
begin
  if CWSpeedDirty then
    SetWpm(SpinEdit1.Value);
end;

procedure TMainForm.CheckBox1Click(Sender: TObject);
begin
  SetQsk(CheckBox1.Checked);
  ActiveControl := Edit1;
end;

procedure TMainForm.CheckBoxClick(Sender: TObject);
begin
  ReadCheckboxes;
  ActiveControl := Edit1;
end;

procedure TMainForm.ReadCheckboxes;
begin
  Ini.Qrn     := CheckBox4.Checked;
  Ini.Qrm     := CheckBox3.Checked;
  Ini.Qsb     := CheckBox2.Checked;
  Ini.Flutter := CheckBox5.Checked;
  Ini.Lids    := CheckBox6.Checked;
end;

procedure TMainForm.SpinEdit2Change(Sender: TObject);
begin
  Ini.Duration := SpinEdit2.Value;
  Histo.ReCalc(Ini.Duration);
end;

procedure TMainForm.SpinEdit3Change(Sender: TObject);
begin
  Ini.Activity := SpinEdit3.Value;
end;

procedure TMainForm.PaintBox1Paint(Sender: TObject);
begin
  Histo.Repaint;
end;

procedure TMainForm.Exit1Click(Sender: TObject);
begin
  Close;
end;


procedure TMainForm.RunStop;
begin
  Run(rmStop);
end;


procedure TMainForm.ViewScoreBoard;
begin
  ViewScoreBoardMNUClick(nil);
end;


procedure TMainForm.WipeBoxes;
begin
  Edit1.Text := '';
  Edit2.Text := '';
  Edit3.Text := '';
  Globals.GEdit1Text := '';
  Globals.GEdit2Text := '';
  Globals.GEdit3Text := '';
  ActiveControl := Edit1;

  if SimContest = scArrlSS then
    Log.SBarUpdateSummary('');

  if Assigned(Tst) then
    Tst.OnWipeBoxes;

  CallSent := false;
  NrSent   := false;
end;


procedure TMainForm.FirstTime1Click(Sender: TObject);
const
  Msg = '                       First Time?' + #13 +
        'Welcome to Morse Runner Community Edition' + #13 + #13 +
        'Initial Setup:' + #13 +
        '1) Select the Contest you wish to operate.' + #13 +
        '2) Type the exchange you wish to send.' + #13 +
        '3) In the station section replace VE3NEA with your call.' + #13 +
        '4) Select your CW Speed, Tone, and Bandwidth.' + #13 +
        '5) Turn on Band Conditions for realistic hardships.' + #13 +
        '6) Activity is the average amount of responses you want per CQ.' + #13 +
        '7) Select the time limit.' + #13 +
        '8) The Run button has a drop down.' + #13 +
        '   - Pile up - Hit F1 to call CQ. Get ready for pileups!' + #13 +
        '   - Single Calls - Work one station at a time.' + #13 +
        'More detailed help is in the readme, but this gets you started.' + #13 +
        'Have Fun!' + #13 + #13 +
        'Please visit us at:' + #13 +
        '    https://www.github.com/w7sst/MorseRunner/#readme';
begin
  ShowMessage(Msg);
end;


procedure TMainForm.About1Click(Sender: TObject);
const
  Msg = 'CW CONTEST SIMULATOR' + #13#13 +
        'Version %s' + #13#13 +
        'Copyright '#169'2004-2016 Alex Shovkoplyas, VE3NEA' + #13 +
        'Copyright '#169'2022-2025 Morse Runner Community Edition Contributors' + #13#13 +
        'https://www.github.com/w7sst/MorseRunner/#readme';
begin
  ShowMessage(Format(Msg, [sVersion]));
end;


procedure TMainForm.Readme1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := GetDataPath.GetDataPath + 'readme.txt';
  OpenDocument(FileName);
end;


procedure TMainForm.Edit1Change(Sender: TObject);
begin
  Globals.GEdit1Text := Edit1.Text;
  if Edit1.Text = '' then
    NrSent := false;
  if not Tst.Me.UpdateCallInMessage(Edit1.Text) then
    CallSent := false;
end;


procedure TMainForm.Edit2Change(Sender: TObject);
begin
  Globals.GEdit2Text := Edit2.Text;
end;


procedure TMainForm.Edit3Change(Sender: TObject);
begin
  Globals.GEdit3Text := Edit3.Text;
end;


procedure TMainForm.RunMNUClick(Sender: TObject);
begin
  SetDefaultRunMode((Sender as TComponent).Tag);
  Run(DefaultRunMode);
end;


procedure TMainForm.EnableCtl(Ctl: TWinControl; AEnable: boolean);
const
  Clr: array[boolean] of TColor = (clBtnFace, clWindow);
begin
  Ctl.Enabled := AEnable;
  if Ctl is TSpinEdit then (Ctl as TSpinEdit).Color := Clr[AEnable]
  else if Ctl is TEdit then (Ctl as TEdit).Color := Clr[AEnable];
end;


procedure TMainForm.Run(Value: TRunMode);
var
  BCompet, BStop: boolean;
  S: string;
begin
  DbgLog('Run called: Value=' + IntToStr(Ord(Value)) + ' Ini.RunMode=' + IntToStr(Ord(Ini.RunMode)));
  if Value = Ini.RunMode then
  begin
    DbgLog('Run: early exit - Value = Ini.RunMode');
    Exit;
  end;

  if Value <> rmStop then
  begin
    if UserCallsignDirty then
    begin
      DbgLog('Run: UserCallsignDirty, calling SetMyCall');
      if not SetMyCall(Trim(Edit4.Text)) then
      begin
        DbgLog('Run: SetMyCall failed, exiting');
        Exit;
      end;
    end;
    if UserExchangeDirty then
    begin
      DbgLog('Run: UserExchangeDirty, calling SetMyExchange');
      if not SetMyExchange(Trim(ExchangeEdit.Text)) then
      begin
        DbgLog('Run: SetMyExchange failed, exiting');
        Exit;
      end;
    end;

    if (Value = rmHst) and
       ((SimContest <> scHst) or (Ini.SerialNR <> snStartContest)) then
    begin
      S := 'Error: HST Competition mode requires the following settings:' + #13 +
           '  1. ''HST (High Speed Test)'' in the Contest dropdown.' + #13 +
           '  2. ''Start of Contest'' in the ''Settings | Serial NR'' menu.' + #13 +
           'Please correct these settings and try again.';
      MessageDlg(S, mtError, [mbOK], 0);
      Exit;
    end;

    DbgLog('Run: calling OnContestPrepareToStart, Ini.Call=' + Ini.Call);
    if not Tst.OnContestPrepareToStart(Ini.Call, ExchangeEdit.Text) then
    begin
      DbgLog('Run: OnContestPrepareToStart returned false, exiting');
      Exit;
    end;
    DbgLog('Run: OnContestPrepareToStart succeeded');
  end;

  BStop   := Value = rmStop;
  BCompet := Value in [rmWpx, rmHst];
  RunMode := Value;

  BDebugExchSettings := (CDebugExchSettings or Ini.DebugExchSettings) and not BCompet;
  BDebugCwDecoder    := (CDebugCwDecoder    or Ini.DebugCwDecoder)    and not BCompet;
  BDebugGhosting     := (CDebugGhosting     or Ini.DebugGhosting)     and not BCompet;

  EnableCtl(SimContestCombo, BStop);
  EnableCtl(Edit4,           BStop);
  EnableCtl(ExchangeEdit,    BStop and ActiveContest.ExchFieldEditable);
  EnableCtl(SpinEdit2,       BStop);
  SetToolbuttonDown(ToolButton1, not BStop);

  ToolButton1.Caption := IfThen(BStop, '   Run   ', '  Stop  ');

  EnableCtl(CheckBox2, not BCompet);
  EnableCtl(CheckBox3, not BCompet);
  EnableCtl(CheckBox4, not BCompet);
  EnableCtl(CheckBox5, not BCompet);
  EnableCtl(CheckBox6, not BCompet);
  if RunMode = rmWpx then
  begin
    CheckBox2.Checked := true;
    CheckBox3.Checked := true;
    CheckBox4.Checked := true;
    CheckBox5.Checked := true;
    CheckBox6.Checked := true;
    SpinEdit2.Value := CompDuration;
  end
  else if RunMode = rmHst then
  begin
    CheckBox2.Checked := false;
    CheckBox3.Checked := false;
    CheckBox4.Checked := false;
    CheckBox5.Checked := false;
    CheckBox6.Checked := false;
    SpinEdit2.Value := CompDuration;
  end;

  PileupMNU.Enabled       := BStop;
  SingleCallsMNU.Enabled  := BStop;
  CompetitionMNU.Enabled  := BStop;
  HSTCompetition1.Enabled := BStop;
  StopMNU.Enabled         := not BStop;

  PileUp1.Enabled         := BStop;
  SingleCalls1.Enabled    := BStop;
  Competition1.Enabled    := BStop;
  HSTCompetition2.Enabled := BStop;
  Stop1MNU.Enabled        := not BStop;
  ViewScoreTable1.Enabled := BStop;

  Call1.Enabled       := BStop;
  Duration1.Enabled   := BStop;
  QRN1.Enabled        := not BCompet;
  QRM1.Enabled        := not BCompet;
  QSB1.Enabled        := not BCompet;
  Flutter1.Enabled    := not BCompet;
  LIDS1.Enabled       := not BCompet;

  Activity1.Enabled    := Value <> rmHst;
  CWBandwidth2.Enabled := Value <> rmHst;
  CWMinRxSpeed1.Enabled:= Value <> rmHst;
  CWMaxRxSpeed1.Enabled:= Value <> rmHst;
  NRDigits1.Enabled    := Value <> rmHst;

  EnableCtl(SpinEdit3, RunMode <> rmHst);
  if RunMode = rmHst then SpinEdit3.Value := 4;

  EnableCtl(ComboBox2, RunMode <> rmHst);
  if RunMode = rmHst then begin ComboBox2.ItemIndex := 10; SetBw(10); end;

  if RunMode = rmHst then ListView1.Visible := false
  else if RunMode <> rmStop then ListView1.Visible := true;

  Panel4.Caption := '';
  case Value of
    rmStop:    Panel4.Caption := '';
    rmPileup:  Panel4.Caption := 'Pile-Up';
    rmSingle:  Panel4.Caption := 'Single Calls';
    rmWpx:     Panel4.Caption := 'COMPETITION';
    rmHst:     Panel4.Caption := 'H S T';
  end;
  if BCompet then Panel4.Font.Color := clRed
  else            Panel4.Font.Color := clGreen;

  if not BStop then
  begin
    Tst.Me.AbortSend;
    Tst.BlockNumber := 0;
    Log.Clear;
    WipeBoxes;

    Memo1.Visible := false;
    Memo1.Align   := alNone;
    sbar.Align    := alBottom;
    sbar.Visible  := mnuShowCallsignInfo.Checked;
    ListView2.Align   := alClient;
    ListView2.Clear;
    ListView2.Visible := true;
    Panel5.Update;
  end;

  if not BStop then
    IncRit(0);

  if BStop then
  begin
    if AlWavFile1.IsOpen then
      AlWavFile1.Close;
  end
  else
  begin
    AlWavFile1.FileName := GetDataPath.GetUserPath + 'MorseRunner.wav';
    if SaveWav then
      AlWavFile1.OpenWrite;
  end;

  AlSoundOut1.Enabled := not BStop;

  // On macOS/Cocoa, clicking the toolbar button steals keyboard focus.
  // Return focus to the appropriate edit field.
  if not BStop then
    Edit1.SetFocus
  else
    Edit4.SetFocus;
end;


procedure TMainForm.RunBtnClick(Sender: TObject);
begin
  if RunMode = rmStop then
    Run(DefaultRunMode)
  else
    Tst.FStopPressed := true;
end;

procedure TMainForm.SetToolbuttonDown(AToolbutton: TToolButton; ADown: boolean);
begin
  AToolbutton.Down := ADown;
end;


procedure TMainForm.PopupScoreWpx;
var
  S, FName: string;
  Score: integer;
  DlgScore: TScoreDialog;
begin
  S := Format('%s %s %s %s ',
    [FormatDateTime('yyyy-mm-dd', Now),
     Trim(Ini.Call),
     Trim(ListView1.Items[0].SubItems[1]),
     Trim(ListView1.Items[1].SubItems[1])]);
  S := S + '[' + IntToHex(CalculateCRC32(S, $C90C2086), 8) + ']';

  FName := GetDataPath.GetUserPath + 'MorseRunner.lst';
  with TStringList.Create do
  try
    if FileExists(FName) then LoadFromFile(FName);
    Add(S);
    SaveToFile(FName);
  finally
    Free;
  end;

  DlgScore := TScoreDialog.Create(Self);
  try
    DlgScore.Edit1.Text := S;
    Score := StrToIntDef(ListView1.Items[2].SubItems[1], 0);
    if Score > HiScore then
      DlgScore.Height := 192
    else
      DlgScore.Height := 129;
    HiScore := Max(HiScore, Score);
    DlgScore.ShowModal;
  finally
    DlgScore.Free;
  end;
end;


procedure TMainForm.PopupScoreHst;
var
  S: string;
  FName: TFileName;
begin
  S := Format('%s'#9'%s'#9'%s'#9'%s', [
    FormatDateTime('yyyy-mm-dd hh:nn', Now),
    Ini.Call, Ini.HamName,
    Panel11.Caption]);

  FName := GetDataPath.GetUserPath + 'HstResults.txt';
  with TStringList.Create do
  try
    if FileExists(FName) then LoadFromFile(FName);
    Add(S);
    SaveToFile(FName);
  finally
    Free;
  end;

  ShowMessage('HST Score: ' + ListView1.Items[2].SubItems[1]);
end;


procedure TMainForm.PopupScore;
begin
  // stub: called from Contest.pas but currently unused
end;


procedure TMainForm.ViewScoreBoardMNUClick(Sender: TObject);
begin
  OpenURL(WebServer);
end;

procedure TMainForm.ViewScoreTable1Click(Sender: TObject);
var
  FName: string;
begin
  ListView2.Align   := alNone;
  ListView2.Visible := false;
  sbar.Visible      := false;
  Memo1.Align       := alClient;
  Memo1.Visible     := true;
  Memo1.Lines.Clear;
  FName := GetDataPath.GetUserPath + 'MorseRunner.lst';
  if FileExists(FName) then
    Memo1.Lines.LoadFromFile(FName)
  else
    Memo1.Lines.Add('Your score table is empty');
end;


procedure TMainForm.Panel8MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  if X < Shape2.Left then IncRit(-1)
  else if X > (Shape2.Left + Shape2.Width) then IncRit(1);
end;

procedure TMainForm.Shape2MouseDown(Sender: TObject; Button: TMouseButton;
  Shift: TShiftState; X, Y: Integer);
begin
  IncRit(0);
end;


procedure TMainForm.mnuShowCallsignInfoClick(Sender: TObject);
begin
  with Sender as TMenuItem do
  begin
    Checked := not Checked;
    if ListView2.Visible then
      sbar.Visible := Checked;
  end;
end;


procedure TMainForm.IncRit(dF: integer);
var
  RitStepIncr: integer;
begin
  RitStepIncr := IfThen(RunMode = rmHST, 50, Ini.RitStepIncr);
  if RitStepIncr < 0 then
  begin
    dF := -dF;
    RitStepIncr := -RitStepIncr;
  end;
  case dF of
   -2: if Ini.Rit > -500 then Inc(RitLocal, -5);
   -1: if Ini.Rit > -500 then Inc(RitLocal, -RitStepIncr);
    0: RitLocal := 0;
    1: if Ini.Rit < 500 then Inc(RitLocal, RitStepIncr);
    2: if Ini.Rit < 500 then Inc(RitLocal, 5);
  end;
  Ini.Rit := Min(500, Max(-500, RitLocal));
  UpdateRitIndicator;
end;

procedure TMainForm.UpdateRitIndicator;
begin
  Shape2.Width := Ini.Bandwidth div 9;
  Shape2.Left  := ((Panel8.Width - Shape2.Width) div 2) + (Ini.Rit div 9);
end;


procedure TMainForm.Advance;
var
  S: string;
begin
  if not MustAdvance then Exit;

  if Edit2IsRST and (Edit2.Text = '') then
    Edit2.Text := '599';

  if (Edit1.Text = '') or (Pos('?', Edit1.Text) > 0) then
  begin
    if ActiveControl = Edit1 then Edit1Enter(nil)
    else ActiveControl := Edit1;
  end
  else
  begin
    if Edit2IsRST or not Edit2.Showing then
      ActiveControl := Edit3
    else
      ActiveControl := Edit2;

    if (SimContest = scArrlSS) and
      (Ini.ShowCheckSection > 0) and
      (ActiveControl = Edit3) and (Edit3.Text = '') and
      (Random < (ShowCheckSection / 100)) then
    begin
      S := Tst.GetCheckSection(Edit1.Text, 0.10);
      if not S.IsEmpty then S := S + ' ';
      Edit3.Text := S;
      Edit3.SelStart := Length(S);
    end;
  end;

  MustAdvance := false;
end;


procedure TMainForm.VolumeSliderDblClick(Sender: TObject);
begin
  with Sender as TVolumeSlider do
  begin
    Value := 1;
    OnChange(Sender);
  end;
end;

procedure TMainForm.VolumeSlider1Change(Sender: TObject);
begin
  Ini.SelfMonVolume := Round(VolumeSlider1.Db);
  Globals.GVolumeSliderValue := VolumeSlider1.Value;
end;

procedure TMainForm.WebPage1Click(Sender: TObject);
begin
  OpenURL('https://www.github.com/w7sst/MorseRunner#readme');
end;


procedure TMainForm.PostHiScore(const sScore: string);
var
  HttpClient: TFPHTTPClient;
  S, sUrl, sp: string;
  ParamList: TStringList;
  p: integer;
  ResponseStr: string;
begin
  S := Format(SubmitHiScoreURL, [sScore]);
  S := StringReplace(S, ' ', '%20', [rfReplaceAll]);

  HttpClient := TFPHTTPClient.Create(nil);
  try
    HttpClient.AllowRedirect := true;
    if PostMethod <> 'POST' then
    begin
      S := StringReplace(S, '[', '%5B', [rfReplaceAll]);
      S := StringReplace(S, ']', '%5D', [rfReplaceAll]);
      ResponseStr := HttpClient.Get(S);
    end
    else
    begin
      p := Pos('?', S);
      sUrl := Copy(S, 1, p - 1);
      sp   := Copy(S, p + 1, MaxInt);
      ParamList := TStringList.Create;
      try
        ParamList.Delimiter := '&';
        ParamList.StrictDelimiter := True;
        ParamList.DelimitedText := sp;
        ParamList.Text := StringReplace(ParamList.Text, '%20', ' ', [rfReplaceAll]);
        HttpClient.RequestHeaders.Add('Content-Type: application/x-www-form-urlencoded');
        ResponseStr := HttpClient.FormPost(sUrl, ParamList);
      finally
        ParamList.Free;
      end;
    end;
    ShowMessage('Sent!');
  except
    ShowMessage('Error!');
  end;
  HttpClient.Free;
end;


procedure TMainForm.Call1Click(Sender: TObject);
begin
  SetMyCall(UpperCase(Trim(InputBox('Callsign', 'Callsign', Edit4.Text))));
end;

procedure TMainForm.SetQsk(Value: boolean);
begin
  Qsk := Value;
  CheckBox1.Checked := Qsk;
end;

procedure TMainForm.QSK1Click(Sender: TObject);
begin
  SetQsk(not QSK1.Checked);
end;

procedure TMainForm.NWPMClick(Sender: TObject);
begin
  SetWpm((Sender as TMenuItem).Tag);
end;

procedure TMainForm.SetWpm(AWpm: integer);
begin
  Wpm := Max(10, Min(120, AWpm));
  SpinEdit1.Value := Wpm;
  Tst.Me.SetWpm(Wpm);
  CWSpeedDirty := False;
end;

procedure TMainForm.Pitch1Click(Sender: TObject);
begin
  SetPitch((Sender as TMenuItem).Tag);
end;

procedure TMainForm.Bw1Click(Sender: TObject);
begin
  SetBw((Sender as TMenuItem).Tag);
end;

procedure TMainForm.File1Click(Sender: TObject);
var
  Stp: boolean;
begin
  Stp := RunMode = rmStop;
  AudioRecordingEnabled1.Enabled := Stp;
  PlayRecordedAudio1.Enabled := Stp and FileExists(GetDataPath.GetUserPath + 'MorseRunner.wav');
  AudioRecordingEnabled1.Checked := Ini.SaveWav;
end;

procedure TMainForm.PlayRecordedAudio1Click(Sender: TObject);
var
  FileName: string;
begin
  FileName := GetDataPath.GetUserPath + 'MorseRunner.wav';
  OpenDocument(FileName);
end;

procedure TMainForm.AudioRecordingEnabled1Click(Sender: TObject);
begin
  Ini.SaveWav := not Ini.SaveWav;
end;

procedure TMainForm.SelfMonClick(Sender: TObject);
begin
  VolumeSlider1.Db := (Sender as TMenuItem).Tag;
  VolumeSlider1.OnChange(Sender);
end;

procedure TMainForm.Settings1Click(Sender: TObject);
begin
  QSK1.Checked    := Ini.Qsk;
  QRN1.Checked    := Ini.Qrn;
  QRM1.Checked    := Ini.Qrm;
  QSB1.Checked    := Ini.Qsb;
  Flutter1.Checked:= Ini.Flutter;
  LIDS1.Checked   := Ini.Lids;
end;

procedure TMainForm.CWMaxRxSpeedClick(Sender: TObject);
begin
  UpdCWMaxRxSpeed((Sender as TMenuItem).Tag);
end;

procedure TMainForm.UpdCWMaxRxSpeed(Maxspd: integer);
begin
  Ini.MaxRxWpm := Maxspd;
  CWMaxRxSpeedSet0.Checked  := Maxspd = 0;
  CWMaxRxSpeedSet1.Checked  := Maxspd = 1;
  CWMaxRxSpeedSet2.Checked  := Maxspd = 2;
  CWMaxRxSpeedSet4.Checked  := Maxspd = 4;
  CWMaxRxSpeedSet6.Checked  := Maxspd = 6;
  CWMaxRxSpeedSet8.Checked  := Maxspd = 8;
  CWMaxRxSpeedSet10.Checked := Maxspd = 10;
end;

procedure TMainForm.CWMinRxSpeedClick(Sender: TObject);
begin
  UpdCWMinRxSpeed((Sender as TMenuItem).Tag);
end;

procedure TMainForm.UpdCWMinRxSpeed(minspd: integer);
begin
  if (Wpm < 15) and (minspd > 4) then minspd := 4;
  Ini.MinRxWpm := minspd;
  CWMinRxSpeedSet0.Checked  := minspd = 0;
  CWMinRxSpeedSet1.Checked  := minspd = 1;
  CWMinRxSpeedSet2.Checked  := minspd = 2;
  CWMinRxSpeedSet4.Checked  := minspd = 4;
  CWMinRxSpeedSet6.Checked  := minspd = 6;
  CWMinRxSpeedSet8.Checked  := minspd = 8;
  CWMinRxSpeedSet10.Checked := minspd = 10;
end;

procedure TMainForm.NRDigitsClick(Sender: TObject);
begin
  UpdSerialNR((Sender as TMenuItem).Tag);
end;

procedure TMainForm.SerialNRCustomRangeClick(Sender: TObject);
var
  snt: integer;
  RangeStr: string;
  ClickedOK, Done: boolean;
  tempRange: TSerialNRSettings;
  Err: string;
begin
  snt := (Sender as TMenuItem).Tag;
  tempRange := Ini.SerialNRSettings[snCustomRange];
  RangeStr  := tempRange.RangeStr;
  Done := False;
  repeat
    ClickedOK := Dialogs.InputQuery('Enter Custom Serial Number Range',
      'Enter min-max values (e.g. 01-99):', RangeStr);
    if not ClickedOK then Break;
    tempRange.ParseSerialNR(RangeStr, Err);
    if Err <> '' then
      MessageDlg(Err, mtError, [mbOK], 0)
    else
    begin
      Ini.SerialNRSettings[snCustomRange] := tempRange;
      UpdSerialNRCustomRange(tempRange.RangeStr);
      UpdSerialNR(snt);
      Done := true;
    end;
  until Done;
end;

procedure TMainForm.UpdSerialNR(V: integer);
var
  snt: TSerialNrTypes;
begin
  assert(Ord(snStartContest) = SerialNRSet1.Tag);
  assert(Ord(snMidContest)   = SerialNRSet2.Tag);
  assert(Ord(snEndContest)   = SerialNRSet3.Tag);
  assert(Ord(snCustomRange)  = SerialNRCustomRange.Tag);

  snt := TSerialNrTypes(V);
  if not Ini.SerialNRSettings[snt].IsValid then
    snt := snStartContest;

  Ini.SerialNR := snt;
  SerialNRSet1.Checked       := snt = snStartContest;
  SerialNRSet2.Checked       := snt = snMidContest;
  SerialNRSet3.Checked       := snt = snEndContest;
  SerialNRCustomRange.Checked:= snt = snCustomRange;

  if not (RunMode in [rmStop, rmHST]) then
    Tst.SerialNrModeChanged;
end;

procedure TMainForm.UpdSerialNRCustomRange(const ARange: string);
begin
  if Ini.SerialNRSettings[snCustomRange].IsValid then
    SerialNRCustomRange.Caption := Format('Custom Range (%s)...', [ARange])
  else
    SerialNRCustomRange.Caption := 'Custom Range...';
end;

procedure TMainForm.LIDS1Click(Sender: TObject);
begin
  with Sender as TMenuItem do Checked := not Checked;
  CheckBox4.Checked := QRN1.Checked;
  CheckBox3.Checked := QRM1.Checked;
  CheckBox2.Checked := QSB1.Checked;
  CheckBox5.Checked := Flutter1.Checked;
  CheckBox6.Checked := LIDS1.Checked;
  ReadCheckboxes;
end;

procedure TMainForm.ListView2CustomDrawSubItem(Sender: TCustomListView;
  Item: TListItem; SubItem: Integer; State: TCustomDrawState;
  var DefaultDraw: Boolean);
var
  View: TListView;
  Qso: PQso;
  ColumnFlag: integer;
begin
  if Length(QsoList) = 0 then Exit;
  View := Sender as TListView;
  Qso  := @QsoList[Item.Index];

  if Log.ShowCorrections then
  begin
    ColumnFlag := 1 shl SubItem;
    if (Qso.Err <> '   ') and ((Qso.ColumnErrorFlags and ColumnFlag) <> 0) then
      View.Canvas.Font.Color := clRed
    else
      View.Canvas.Font.Color := clBlack;
  end
  else if SubItem = Log.CorrectionColumnInx then
    View.Canvas.Font.Color := clRed
  else
    View.Canvas.Font.Color := clBlack;

  if SimContest = scHst then
    if (SubItem = 4) and (Qso.Err <> '   ') and (Qso.TrueCall <> '') then
      View.Canvas.Font.Style := [fsStrikeOut]
    else
      View.Canvas.Font.Style := [];
end;

procedure TMainForm.ListView2SelectItem(Sender: TObject; Item: TListItem;
  Selected: Boolean);
begin
  if Selected and mnuShowCallsignInfo.Checked then
    SbarUpdateStationInfo(Item.SubItems[0]);
end;

procedure TMainForm.Activity1Click(Sender: TObject);
begin
  Ini.Activity := (Sender as TMenuItem).Tag;
  SpinEdit3.Value := Ini.Activity;
end;

procedure TMainForm.Duration1Click(Sender: TObject);
begin
  Ini.Duration := (Sender as TMenuItem).Tag;
  SpinEdit2.Value := Ini.Duration;
end;

procedure TMainForm.Operator1Click(Sender: TObject);
begin
  HamName := InputBox('HST Operator', 'Enter operator''s name', HamName);
  HamName := UpperCase(HamName);
  UpdateTitleBar;
  with TIniFile.Create(GetDataPath.GetUserPath + 'MorseRunner.ini') do
  try
    WriteString(SEC_STN, 'Name', HamName);
  finally
    Free;
  end;
end;

procedure TMainForm.StopMNUClick(Sender: TObject);
begin
  Tst.FStopPressed := true;
end;

procedure TMainForm.CWOPSNumberClick(Sender: TObject);
begin
  // stub: CWOPS number setting handler
end;

end.
