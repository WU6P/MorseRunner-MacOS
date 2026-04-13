// PerlRegEx.pas — TPerlRegEx compatibility wrapper for FPC
// Wraps FPC's TRegExpr to provide the subset of TPerlRegEx API used by
// Morse Runner. Not a full compatibility layer — only the methods actually
// called in this codebase are implemented.
unit PerlRegEx;
{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  SysUtils, Classes, RegExpr;

type
  PCREString = UTF8String;

  TPerlRegExOptions = set of (
    preCaseLess,       // case-insensitive
    preMultiLine,      // ^ and $ match line boundaries
    preExtended,       // ignore whitespace in pattern
    preSingleLine,     // . matches \n
    preUnGreedy,
    preNoAutoCapture,
    preNoAutoSub,
    preAnchored        // match only at Start position
  );

  TPerlRegEx = class
  private
    FRegExpr    : TRegExpr;
    FSubject    : PCREString;
    FRegEx      : PCREString;
    FOptions    : TPerlRegExOptions;
    FMatched      : Boolean;
    FIsCompiled   : Boolean;
    FStart        : Integer;  // 1-based current position (updated after match)
    FStop         : Integer;  // 1-based end position (0 = use full subject)
    FSubjectDirty : Boolean;  // True when Subject changed but Exec not yet called

    function GetMatchedText: PCREString;
    function GetMatchedOffset: Integer;
    function GetGroups(Index: Integer): PCREString;
    function GetGroupCount: Integer;
    function GetCompiled: Boolean;
    procedure SetOptions(AOptions: TPerlRegExOptions);
    procedure SetSubject(const AValue: PCREString);
  public
    constructor Create; overload;
    constructor Create(const ARegEx: PCREString); overload;
    destructor Destroy; override;

    // Pre-compile the regex (optional — TRegExpr compiles lazily)
    procedure Compile;

    // Execute match from beginning of subject
    function Match: Boolean;

    // Execute match from current Start position; if anchored, must start there.
    // On success, updates Start to position after matched text.
    function MatchAgain: Boolean;

    // Study — no-op in TRegExpr (PCRE optimization hint, not needed)
    procedure Study;

    // Named capture group → index (negative = named, positive = numbered)
    function NamedGroup(const Name: PCREString): Integer;

    property RegEx:       PCREString         read FRegEx   write FRegEx;
    property Compiled:    Boolean            read GetCompiled;
    property Subject:     PCREString         read FSubject write SetSubject;
    property Options:     TPerlRegExOptions  read FOptions write SetOptions;
    property Start:       Integer            read FStart   write FStart;
    property Stop:        Integer            read FStop    write FStop;
    property MatchedText: PCREString         read GetMatchedText;
    property MatchedOffset: Integer          read GetMatchedOffset;
    property Groups[Index: Integer]: PCREString read GetGroups;
    property GroupCount:  Integer            read GetGroupCount;
  end;

  // TPerlRegExList — matches a set of regexes against a shared subject,
  // returning the earliest match across all regexes on each Match/MatchAgain.
  // Owns the TPerlRegEx objects added to it (Clear frees them).
  TPerlRegExList = class
  private
    FList      : TList;
    FSubject   : PCREString;
    FMatchedReg: TPerlRegEx;
    FStart     : Integer;

    procedure SetSubject(const AValue: PCREString);
    function  BestMatch(StartPos: Integer): Boolean;
  public
    constructor Create;
    destructor  Destroy; override;

    procedure Add(AReg: TPerlRegEx);
    function  Match: Boolean;
    function  MatchAgain: Boolean;
    function  IndexOf(AReg: TPerlRegEx): Integer;
    procedure Clear;

    property Subject:    PCREString  write SetSubject;
    property MatchedRegEx: TPerlRegEx read FMatchedReg;
  end;

implementation

{ TPerlRegEx }

constructor TPerlRegEx.Create;
begin
  FRegExpr      := TRegExpr.Create;
  FMatched      := False;
  FStart        := 1;
  FStop         := 0;
  FSubjectDirty := True;
end;

procedure TPerlRegEx.SetSubject(const AValue: PCREString);
begin
  FSubject      := AValue;
  FSubjectDirty := True;   // Exec must be re-called before ExecPos
  FStart        := 1;
end;

constructor TPerlRegEx.Create(const ARegEx: PCREString);
begin
  Create;
  FRegEx := ARegEx;
end;

destructor TPerlRegEx.Destroy;
begin
  FRegExpr.Free;
  inherited;
end;

procedure TPerlRegEx.SetOptions(AOptions: TPerlRegExOptions);
begin
  FOptions := AOptions;
  FRegExpr.ModifierI := preCaseLess  in AOptions;
  FRegExpr.ModifierM := preMultiLine in AOptions;
  FRegExpr.ModifierX := preExtended  in AOptions;
  FRegExpr.ModifierS := preSingleLine in AOptions;
end;

procedure TPerlRegEx.Compile;
begin
  FRegExpr.Expression := string(FRegEx);
  FRegExpr.Compile;
  FIsCompiled := True;
end;

procedure TPerlRegEx.Study;
begin
  // no-op: TRegExpr doesn't have a separate Study step
end;

function TPerlRegEx.GetCompiled: Boolean;
begin
  Result := FIsCompiled;
end;

function TPerlRegEx.Match: Boolean;
begin
  FRegExpr.Expression := string(FRegEx);
  FMatched := FRegExpr.Exec(string(FSubject));
  FSubjectDirty := False;  // input is now initialised in FRegExpr
  if FMatched then
    FStart := FRegExpr.MatchPos[0] + FRegExpr.MatchLen[0];
  Result := FMatched;
end;

function TPerlRegEx.MatchAgain: Boolean;
var
  Pos: Integer;
  MatchStart: Integer;
begin
  FRegExpr.Expression := string(FRegEx);
  // If the subject was set without a prior Match/Exec call, initialise now.
  if FSubjectDirty then
  begin
    FRegExpr.Exec(string(FSubject));  // sets internal input; match result ignored
    FSubjectDirty := False;
  end;

  Pos := FStart;
  if Pos < 1 then Pos := 1;

  // ExecPos finds a match at or after Pos in the currently-loaded input string.
  if FStop > 0 then
  begin
    FMatched := FRegExpr.ExecPos(Pos);
    if FMatched and (FRegExpr.MatchPos[0] + FRegExpr.MatchLen[0] - 1 > FStop) then
      FMatched := False;
  end
  else
    FMatched := FRegExpr.ExecPos(Pos);

  if FMatched then
  begin
    MatchStart := FRegExpr.MatchPos[0];
    // preAnchored: match must start exactly at Pos
    if (preAnchored in FOptions) and (MatchStart <> Pos) then
    begin
      FMatched := False;
      Result := False;
      Exit;
    end;
    FStart := MatchStart + FRegExpr.MatchLen[0];
    // Advance past zero-length matches to avoid infinite loops,
    // but NOT when anchored — caller controls position in that case.
    if (FRegExpr.MatchLen[0] = 0) and not (preAnchored in FOptions) then
      Inc(FStart);
  end;

  Result := FMatched;
end;

function TPerlRegEx.GetMatchedText: PCREString;
begin
  if FMatched then
    Result := PCREString(FRegExpr.Match[0])
  else
    Result := '';
end;

function TPerlRegEx.GetMatchedOffset: Integer;
begin
  if FMatched then
    Result := FRegExpr.MatchPos[0]
  else
    Result := 0;
end;

function TPerlRegEx.GetGroups(Index: Integer): PCREString;
begin
  if not FMatched then begin Result := ''; Exit; end;
  if (Index >= 0) and (Index <= FRegExpr.SubExprMatchCount) then
    Result := PCREString(FRegExpr.Match[Index])
  else
    Result := '';
end;

function TPerlRegEx.GetGroupCount: Integer;
begin
  if not FMatched then begin Result := 0; Exit; end;
  // Return the index of the highest group that participated in the match.
  // Non-participating groups have MatchPos <= 0 (positions are 1-based).
  Result := FRegExpr.SubExprMatchCount;
  while (Result > 0) and (FRegExpr.MatchPos[Result] <= 0) do
    Dec(Result);
end;

// Parse APattern for (?P<AName>...) or (?<AName>...) and return its
// 1-based capture-group number, or 0 if not found.
function FindNamedGroupIndex(const APattern, AName: string): Integer;
var
  i, j, GroupNum: Integer;
  GrpName: string;
  InClass: Boolean;
begin
  Result   := 0;
  GroupNum := 0;
  InClass  := False;
  i := 1;
  while i <= Length(APattern) do
  begin
    case APattern[i] of
      '\':
        Inc(i, 2);   // skip escaped character
      '[':
        begin InClass := True;  Inc(i); end;
      ']':
        begin InClass := False; Inc(i); end;
      '(':
        if not InClass then
        begin
          if (i + 1 <= Length(APattern)) and (APattern[i+1] = '?') then
          begin
            // (?P<name>...)
            if (i + 3 <= Length(APattern)) and
               (APattern[i+2] = 'P') and (APattern[i+3] = '<') then
            begin
              Inc(GroupNum);
              j := i + 4;
              GrpName := '';
              while (j <= Length(APattern)) and (APattern[j] <> '>') do
              begin
                GrpName := GrpName + APattern[j];
                Inc(j);
              end;
              if GrpName = AName then begin Result := GroupNum; Exit; end;
              i := j + 1;
              Continue;
            end;
            // (?<name>...)  — not a lookbehind (?<=...) / (?<!...)
            if (i + 2 <= Length(APattern)) and (APattern[i+2] = '<') and
               (i + 3 <= Length(APattern)) and
               not (APattern[i+3] in ['=', '!']) then
            begin
              Inc(GroupNum);
              j := i + 3;
              GrpName := '';
              while (j <= Length(APattern)) and (APattern[j] <> '>') do
              begin
                GrpName := GrpName + APattern[j];
                Inc(j);
              end;
              if GrpName = AName then begin Result := GroupNum; Exit; end;
              i := j + 1;
              Continue;
            end;
            // (?:...) / (?=...) / (?!...) — non-capturing, no increment
            Inc(i);
          end
          else
          begin
            Inc(GroupNum);   // plain capturing group
            Inc(i);
          end;
        end
        else
          Inc(i);
      else
        Inc(i);
    end;
  end;
end;

function TPerlRegEx.NamedGroup(const Name: PCREString): Integer;
begin
  // Return the actual 1-based capture-group number so Groups[NamedGroup('x')]
  // works without a separate MatchFromName call.
  Result := FindNamedGroupIndex(string(FRegEx), string(Name));
end;

{ TPerlRegExList }

constructor TPerlRegExList.Create;
begin
  FList := TList.Create;
  FStart := 1;
  FMatchedReg := nil;
end;

destructor TPerlRegExList.Destroy;
begin
  Clear;
  FList.Free;
  inherited;
end;

procedure TPerlRegExList.Add(AReg: TPerlRegEx);
begin
  FList.Add(AReg);
end;

procedure TPerlRegExList.SetSubject(const AValue: PCREString);
begin
  FSubject := AValue;
  FStart   := 1;
  FMatchedReg := nil;
end;

function TPerlRegExList.BestMatch(StartPos: Integer): Boolean;
var
  i: Integer;
  Reg: TPerlRegEx;
  MatchPos, BestPos: Integer;
  BestReg: TPerlRegEx;
begin
  BestPos := MaxInt;
  BestReg := nil;

  for i := 0 to FList.Count - 1 do
  begin
    Reg := TPerlRegEx(FList[i]);
    Reg.FRegExpr.Expression := string(Reg.FRegEx);
    // Always call Exec first to initialise the internal input string,
    // then ExecPos to find the match at or after StartPos.
    Reg.FRegExpr.Exec(string(FSubject));  // set input (result ignored)
    if not Reg.FRegExpr.ExecPos(StartPos) then Continue;
    MatchPos := Reg.FRegExpr.MatchPos[0];
    if MatchPos < BestPos then
    begin
      BestPos := MatchPos;
      BestReg := Reg;
    end;
  end;

  if BestReg <> nil then
  begin
    FMatchedReg := BestReg;
    BestReg.FMatched := True;
    FStart := BestPos + BestReg.FRegExpr.MatchLen[0];
    if BestReg.FRegExpr.MatchLen[0] = 0 then
      Inc(FStart);
    Result := True;
  end
  else
  begin
    FMatchedReg := nil;
    Result := False;
  end;
end;

function TPerlRegExList.Match: Boolean;
begin
  FStart := 1;
  Result := BestMatch(1);
end;

function TPerlRegExList.MatchAgain: Boolean;
begin
  Result := BestMatch(FStart);
end;

function TPerlRegExList.IndexOf(AReg: TPerlRegEx): Integer;
begin
  Result := FList.IndexOf(AReg);
end;

procedure TPerlRegExList.Clear;
var
  i: Integer;
begin
  for i := 0 to FList.Count - 1 do
    TPerlRegEx(FList[i]).Free;
  FList.Clear;
  FMatchedReg := nil;
end;

end.
