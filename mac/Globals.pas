// Globals.pas — Shared global state to break Main↔Contest circular dependencies.
//
// Many simulation units (Contest, Station, Log, DxStn, MyStn, ScoreDlg…) previously
// imported `Main` in their implementation sections to access form controls and debug
// flags. That created a circular pending group in FPC 3.2.2 that prevented Contest.ppu
// and Station.ppu from being written, blocking all contest-mode units from compiling.
//
// This unit provides:
//   • Boolean debug flags (previously declared in Main.pas)
//   • Global string mirrors of the three exchange edit boxes
//   • References to key form controls (TListView, TStatusBar, …)
//   • Procedure-of-object callbacks for actions that must be dispatched to TMainForm
//
// TMainForm.FormCreate sets all pointers/callbacks at startup.
// Every unit that previously used Main.pas for these symbols now uses Globals instead.
unit Globals;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  ComCtrls,     // TListView
  StdCtrls,     // TMemo
  ExtCtrls,     // TPanel
  Graphics,     // TPaintBox
  WavFile,      // TAlWavFile
  ExchFields;   // TExchTypes

type
  TNoArgProc     = procedure of object;
  TStrArgProc    = procedure(const S: string) of object;

var
  // ── Debug flags (mirroring the B* vars previously in Main.pas) ───────────────
  BDebugCwDecoder    : Boolean = False;
  BDebugGhosting     : Boolean = False;
  BDebugExchSettings : Boolean = False;
  BCompet            : Boolean = False;

  // ── Exchange edit-box text mirrors (updated by TMainForm event handlers) ──────
  GEdit1Text : string = '';   // Edit1 — callsign field
  GEdit2Text : string = '';   // Edit2 — received exchange 1
  GEdit3Text : string = '';   // Edit3 — received exchange 2

  // ── UI component references (set in TMainForm.FormCreate) ─────────────────────
  GLabel3        : TLabel     = nil;   // MainForm.Label3  (exchange field 2 label)
  GLogListView   : TListView  = nil;   // MainForm.ListView2  (score/log table)
  GScoreListView : TListView  = nil;   // MainForm.ListView1  (score summary)
  GSBar          : TPanel     = nil;   // MainForm.sbar
  GMemo1         : TMemo      = nil;   // MainForm.Memo1
  GPaintBox1     : TPaintBox  = nil;   // MainForm.PaintBox1
  GPanel11       : TPanel     = nil;   // MainForm.Panel11
  GPanel2        : TPanel     = nil;   // MainForm.Panel2  (time display)
  GPanel4        : TPanel     = nil;   // MainForm.Panel4  (pile-up count)
  GPanel7        : TPanel     = nil;   // MainForm.Panel7  (qso/hr rate)
  GAlWavFile1    : TAlWavFile = nil;   // MainForm.AlWavFile1  (WAV recording)
  GVolumeSliderValue : Single = 1.0;  // MainForm.VolumeSlider1.Value (self-mon gain)
  GRecvExchTypes : TExchTypes = (Exch1: etRST; Exch2: etSerialNr);  // MainForm.RecvExchTypes

  // ── Method callbacks (set in TMainForm.FormCreate) ────────────────────────────
  GAdvanceProc          : TNoArgProc  = nil;  // MainForm.Advance
  GRunStopProc          : TNoArgProc  = nil;  // MainForm.Run(rmStop)
  GPopupScoreProc       : TNoArgProc  = nil;  // MainForm.PopupScore
  GPopupScoreHstProc    : TNoArgProc  = nil;  // MainForm.PopupScoreHst
  GPopupScoreWpxProc    : TNoArgProc  = nil;  // MainForm.PopupScoreWpx
  GSetMySerialNRProc    : TNoArgProc  = nil;  // MainForm.SetMySerialNR
  GViewScoreBoardProc   : TNoArgProc  = nil;  // MainForm.ViewScoreBoardMNU.Click
  GPostHiScoreProc      : TStrArgProc = nil;  // MainForm.PostHiScore(code)
  GWipeEditBoxesProc    : TNoArgProc  = nil;  // clear Edit1/2/3 (called from Contest)

implementation

end.
