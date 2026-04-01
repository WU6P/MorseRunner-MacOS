// DxOperTestFPC.pas — FPCUnit port of DxOperTest.pas
// Original tests used DUnitX; this file uses FPCUnit (shipped with FPC).
unit DxOperTestFPC;
{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  fpcunit, testregistry,
  SysUtils, Math, TypInfo, PerlRegEx;

type
  TCallCheckResult = (mcNo, mcYes, mcAlmost);

  TTestDxOperIsMyCall = class(TTestCase)
  private
    Call: string;
    LastCheckedCall: string;
    LastCallCheck: TCallCheckResult;
    CallConfidence: Integer;
    Penalty: Integer;
    Ini_LIDs: Boolean;

    function IsMyCall(const APattern: string;
      ARandomResult: boolean;
      ACallConfidencePtr: PInteger = nil): TCallCheckResult;

    procedure RunCallTest(const ADxCall, AEnteredCall, AExpected: string);

  protected
    procedure SetUp; override;

  published
    procedure TestWild;
    procedure Test1x1;
    procedure Test1x2;
    procedure Test1x3;
    procedure Test1x3_9;
    procedure Test2x2;
    procedure Test2x3;
    procedure TestFY_2x3;
    procedure Test2x3_9;
  end;

implementation

function ToStr(const val: TCallCheckResult): string; overload;
begin
  Result := GetEnumName(TypeInfo(TCallCheckResult), Ord(val));
end;

procedure TTestDxOperIsMyCall.SetUp;
begin
  Call := '';
  LastCheckedCall := '';
  LastCallCheck := mcNo;
  CallConfidence := 0;
  Penalty := 0;
  Ini_LIDs := False;
end;

procedure TTestDxOperIsMyCall.RunCallTest(const ADxCall, AEnteredCall, AExpected: string);
var
  R, Expected: TCallCheckResult;
  EnteredCall: string;
  Confidence: Integer;
  Msg: string;
begin
  case Trim(AExpected)[1] of
    'N': Expected := mcNo;
    'Y': Expected := mcYes;
    'P': Expected := mcAlmost;
  else
    Fail('Invalid Expected value: ' + AExpected +
         '; expecting N(mcNo), Y(mcYes), P(mcAlmost)');
    Exit;
  end;

  Self.Call := Trim(ADxCall);
  EnteredCall := Trim(AEnteredCall);

  LastCheckedCall := '';
  LastCallCheck := mcNo;
  CallConfidence := 0;
  Confidence := 0;

  R := IsMyCall(EnteredCall, False, @Confidence);

  if R <> Expected then
    begin
      Msg := Format('    %s, Entered: ''%s'' --> %s, %s expected, P=%d.',
        [Self.Call, EnteredCall, ToStr(R), ToStr(Expected), Self.Penalty]);
      Fail(Msg);
    end;
end;

{
  Below is a verbatim copy of TDxOperator.IsMyCall() from DxOperTest.pas,
  adapted for FPC (string helpers replaced with equivalent FPC expressions).
}
function TTestDxOperIsMyCall.IsMyCall(const APattern: string;
  ARandomResult: boolean;
  ACallConfidencePtr: PInteger): TCallCheckResult;
var
  C0: string;
  M: array of array of integer;
  x, y: integer;
  P: integer;
  reg: TPerlRegEx;
begin
  C0 := Call;
  reg := NIL;

  Result := mcNo;

  if LastCheckedCall = APattern then
    begin
      Result := LastCallCheck;
      if ACallConfidencePtr <> nil then ACallConfidencePtr^ := CallConfidence;
    end
  else
    begin
      LastCheckedCall := APattern;

      if Pos('?', APattern) > 0 then
        try
          reg := TPerlRegEx.Create();
          if APattern[Length(APattern)] = '?' then
            reg.RegEx := StringReplace(APattern, '?', '.', [rfReplaceAll]) + '*'
          else
            reg.RegEx := StringReplace(APattern, '?', '.', [rfReplaceAll]);
          reg.Subject := C0;
          if reg.Match then
            begin
              Result := mcAlmost;
              // count incorrect characters
              P := Length(C0) - Length(StringReplace(APattern, '?', '', [rfReplaceAll]));
              Self.Penalty := P;
              // confidence = 100 * correct chars / total length
              CallConfidence := (100 * (Length(C0) - P)) div Length(C0);
            end
          else
            begin
              Result := mcNo;
              CallConfidence := 0;
            end;
        finally
          FreeAndNil(reg);
        end
      else
        begin
          //dynamic programming algorithm to determine "Edit Distance", which is
          //the number of character edits needed for the two strings to match.
          SetLength(M, Length(APattern)+1, Length(C0)+1);
          for x:=0 to High(M) do
            M[x,0] := x;
          for y:=0 to High(M[0]) do
            M[0,y] := y;

          for x:=1 to High(M) do
            for y:=1 to High(M[0]) do begin
              if APattern[x] = C0[y] then
                M[x][y] := M[x - 1][y - 1]
              else
                M[x][y] := 1 + MinIntValue([M[x    ][y - 1],
                                            M[x - 1][y    ],
                                            M[x - 1][y - 1]]);
            end;

          //classify by penalty
          //Penalty is the Edit Distance (# of missing or invalid characters)
          P := M[High(M), High(M[0])];
          Self.Penalty := M[High(M), High(M[0])];
          if (P = 0) then
            Result := mcYes
          else if P <= (Length(C0)-1)/2 then
            Result := mcAlmost
          else
            Result := mcNo;

          //partial match for matching any substring within the call
          if (Result = mcNo) and (Pos(APattern, C0) > 0) then
            begin
              Result := mcAlmost;
              P := Length(C0) - Length(APattern);
              Self.Penalty := P;
            end;

          // confidence = 100 * correct chars / total length
          case Result of
            mcYes:    CallConfidence := 100;
            mcAlmost: CallConfidence := 100 * (Length(C0) - P) div Length(C0);
            mcNo:     CallConfidence := 0;
          end;
        end;

      LastCallCheck := Result;
      if ACallConfidencePtr <> nil then ACallConfidencePtr^ := CallConfidence;
    end;

  //accept a wrong call, or reject the correct one
  if ARandomResult and Ini_LIDs and (Length(APattern) > 3) then
    begin
      case Result of
        mcYes: if Random < 0.01 then
          begin
            // LID rejects correct call; sends <HisCall>
            Result := mcAlmost;
            if ACallConfidencePtr <> nil then
              ACallConfidencePtr^ := 100 * (Length(C0)-1) div Length(C0);
          end;
        mcAlmost: if Random < 0.04 then
          begin
            // LID accepts a wrong call; doesn't correct a partial call
            Result := mcYes;
            if ACallConfidencePtr <> nil then
              ACallConfidencePtr^ := 100;
          end;
        end;
    end;
end;

// ---------------------------------------------------------------------------
// Test methods
// ---------------------------------------------------------------------------

procedure TTestDxOperIsMyCall.TestWild;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..15] of TEntry = (
    (DxCall:'AA0AA'; Entered:'W?';      Expected:'N'),
    (DxCall:'AA0AA'; Entered:'AA0?';    Expected:'P'),
    (DxCall:'AA0AA'; Entered:'AA0??';   Expected:'P'),
    (DxCall:'AA0AA'; Entered:'??0??';   Expected:'P'),
    (DxCall:'AA0AA'; Entered:'??0AA';   Expected:'P'),
    (DxCall:'AA0AA'; Entered:'A?0?A';   Expected:'P'),
    (DxCall:'AA0AA'; Entered:'?A0A?';   Expected:'P'),
    (DxCall:'AA0AA'; Entered:'A?0?';    Expected:'P'),
    (DxCall:'AA0AA'; Entered:'AA?';     Expected:'P'),
    (DxCall:'AA0AA'; Entered:'A?';      Expected:'P'),
    (DxCall:'AA0AA'; Entered:'?';       Expected:'P'),
    (DxCall:'AA0AA'; Entered:'W?';      Expected:'N'),
    (DxCall:'AA0AA'; Entered:'W7?';     Expected:'N'),
    (DxCall:'AA0AA'; Entered:'W7S?';    Expected:'N'),
    (DxCall:'AA0AA'; Entered:'W7SS?';   Expected:'N'),
    (DxCall:'AA0AA'; Entered:'W7SST?';  Expected:'N')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
end;

procedure TTestDxOperIsMyCall.Test1x1;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..11] of TEntry = (
    (DxCall:'W7S'; Entered:'W7S';    Expected:'Y'),
    (DxCall:'W7S'; Entered:'A0X';    Expected:'N'),
    (DxCall:'W7S'; Entered:'W7';     Expected:'P'),
    (DxCall:'W7S'; Entered:'W7X';    Expected:'P'),
    (DxCall:'W7S'; Entered:'W7XX';   Expected:'N'),
    (DxCall:'W7S'; Entered:'W7XXX';  Expected:'N'),
    (DxCall:'W7S'; Entered:'W6S';    Expected:'P'),
    (DxCall:'W7S'; Entered:'W6X';    Expected:'N'),
    (DxCall:'W7S'; Entered:'A7S';    Expected:'P'),
    (DxCall:'W7S'; Entered:'W7SSS';  Expected:'N'),
    (DxCall:'W7S'; Entered:'W7S';    Expected:'Y'),
    (DxCall:'W7S'; Entered:'W7S';    Expected:'Y')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
end;

procedure TTestDxOperIsMyCall.Test1x2;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..10] of TEntry = (
    (DxCall:'W7SS'; Entered:'W7SS';   Expected:'Y'),
    (DxCall:'W7SS'; Entered:'W7S';    Expected:'P'),
    (DxCall:'W7SS'; Entered:'W7';     Expected:'P'),
    (DxCall:'W7SS'; Entered:'W7SST';  Expected:'P'),
    (DxCall:'W7SS'; Entered:'A7SS';   Expected:'P'),
    (DxCall:'W7SS'; Entered:'A7SST';  Expected:'N'),
    (DxCall:'W7SS'; Entered:'S';      Expected:'P'),
    (DxCall:'W7SS'; Entered:'SS';     Expected:'P'),
    (DxCall:'W7SS'; Entered:'7SS';    Expected:'P'),
    (DxCall:'W7SS'; Entered:'W7SS';   Expected:'Y'),
    (DxCall:'W7AU'; Entered:'W7AB';   Expected:'P')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
end;

procedure TTestDxOperIsMyCall.Test1x3;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..12] of TEntry = (
    (DxCall:'W7SST'; Entered:'W7SST';   Expected:'Y'),
    (DxCall:'W7SST'; Entered:'W7SSTT';  Expected:'P'),
    (DxCall:'W7SST'; Entered:'W7';      Expected:'P'),
    (DxCall:'W7SST'; Entered:'W7S';     Expected:'P'),
    (DxCall:'W7SST'; Entered:'W7SS';    Expected:'P'),
    (DxCall:'W7SST'; Entered:'W7SSS';   Expected:'P'),
    (DxCall:'W7SST'; Entered:'A7SST';   Expected:'P'),
    (DxCall:'W7SST'; Entered:'W7ABC';   Expected:'N'),
    (DxCall:'W7SST'; Entered:'T';       Expected:'P'),
    (DxCall:'W7SST'; Entered:'ST';      Expected:'P'),
    (DxCall:'W7SST'; Entered:'SST';     Expected:'P'),
    (DxCall:'W7SST'; Entered:'7SS';     Expected:'P'),
    (DxCall:'W7SST'; Entered:'W7XST';   Expected:'P')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
  // Wildcard sub-case: W7??T should be P
  RunCallTest('W7SST', 'W7??T', 'P');
end;

procedure TTestDxOperIsMyCall.Test1x3_9;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..15] of TEntry = (
    (DxCall:'W7SST/9'; Entered:'W7SST/9';  Expected:'Y'),
    (DxCall:'W7SST/9'; Entered:'W7SSTT/9'; Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7SST/8';  Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7';       Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7S';      Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7SS';     Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7SSS';    Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'A7SST';    Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7ABC';    Expected:'N'),
    (DxCall:'W7SST/9'; Entered:'T';        Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'ST';       Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'SST';      Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'7SS';      Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7XST';    Expected:'P'),
    (DxCall:'W7SST/9'; Entered:'W7??T';    Expected:'P'),
    (DxCall:'W7ABU/9'; Entered:'W7AB';     Expected:'P')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
  // Additional wildcard sub-cases
  RunCallTest('W7SST/9', 'W7??T?',  'P');
  RunCallTest('W7SST/9', 'W7??T/?', 'P');
  RunCallTest('W7SST/9', 'W7SST?',  'P');
end;

procedure TTestDxOperIsMyCall.Test2x2;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..20] of TEntry = (
    (DxCall:'AA0AA';    Entered:'AA0AA';    Expected:'Y'),
    (DxCall:'AA0AA';    Entered:'AA0A';     Expected:'P'),
    (DxCall:'AA0AA';    Entered:'AA0';      Expected:'P'),
    (DxCall:'AA0AA';    Entered:'AA';       Expected:'P'),
    (DxCall:'AA0AA';    Entered:'A';        Expected:'P'),
    (DxCall:'AA0AA';    Entered:'A0AA';     Expected:'P'),
    (DxCall:'AA0AA';    Entered:'0AA';      Expected:'P'),
    (DxCall:'AA0AA';    Entered:'AA';       Expected:'P'),
    (DxCall:'AA0AA';    Entered:'A';        Expected:'P'),
    (DxCall:'AA0AA';    Entered:'A0A';      Expected:'P'),
    (DxCall:'AA0AA';    Entered:'0A';       Expected:'P'),
    (DxCall:'AA0AA';    Entered:'A0';       Expected:'P'),
    (DxCall:'AA0AA';    Entered:'AA7AA';    Expected:'P'),
    (DxCall:'AA0AA';    Entered:'AA7BB';    Expected:'N'),
    (DxCall:'AA0AA';    Entered:'AA7BBB';   Expected:'N'),
    (DxCall:'AA0AA';    Entered:'AB7CD';    Expected:'N'),
    (DxCall:'AA0AA';    Entered:'AA0AA/7';  Expected:'P'),
    (DxCall:'AA0AA';    Entered:'FY/AA0AA'; Expected:'N'),
    (DxCall:'AA0AA';    Entered:'FY';       Expected:'N'),
    (DxCall:'FY/AA0AA'; Entered:'FY';       Expected:'P'),
    (DxCall:'FY/AA0AA'; Entered:'FY/';      Expected:'P')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
  RunCallTest('FY/AA0AA', 'FY/AA', 'P');
end;

procedure TTestDxOperIsMyCall.Test2x3;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..19] of TEntry = (
    (DxCall:'WN7SST'; Entered:'WN7SST';  Expected:'Y'),
    (DxCall:'WN7SST'; Entered:'WN';      Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7';     Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7S';    Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7SS';   Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7SSS';  Expected:'P'),
    (DxCall:'WN7SST'; Entered:'AN7SST';  Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7ABC';  Expected:'N'),
    (DxCall:'WN7SST'; Entered:'T';       Expected:'P'),
    (DxCall:'WN7SST'; Entered:'ST';      Expected:'P'),
    (DxCall:'WN7SST'; Entered:'SST';     Expected:'P'),
    (DxCall:'WN7SST'; Entered:'7SS';     Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7XST';  Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7??T';  Expected:'P'),
    (DxCall:'WN7SST'; Entered:'W7SST';   Expected:'P'),
    (DxCall:'WN7SST'; Entered:'W7ST';    Expected:'P'),
    (DxCall:'WN7SST'; Entered:'WN7ST';   Expected:'P'),
    (DxCall:'WN7SST'; Entered:'W7AB';    Expected:'N'),
    (DxCall:'WN7SST'; Entered:'W7ABC';   Expected:'N'),
    (DxCall:'WN7SST'; Entered:'7';       Expected:'P')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
end;

procedure TTestDxOperIsMyCall.TestFY_2x3;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..24] of TEntry = (
    (DxCall:'FY/WN7SST'; Entered:'FY/WN7SST'; Expected:'Y'),
    (DxCall:'FY/WN7SST'; Entered:'FY/WN7SST'; Expected:'Y'),
    (DxCall:'FY/WN7SST'; Entered:'WN';        Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'WN7';       Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'WN7S';      Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'WN7SS';     Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'WN7SSS';    Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'AN7SST';    Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'WN7ABC';    Expected:'N'),
    (DxCall:'FY/WN7SST'; Entered:'T';         Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'ST';        Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'SST';       Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'7SS';       Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'WN7XST';   Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'WN7??T';   Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'W7SST';    Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'W7ST';     Expected:'N'),
    (DxCall:'FY/WN7SST'; Entered:'WN7ST';    Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'W7AB';     Expected:'N'),
    (DxCall:'FY/WN7SST'; Entered:'W7ABC';    Expected:'N'),
    (DxCall:'FY/WN7SST'; Entered:'FY';       Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'FY?';      Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'FY/WN7';  Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'FY/';      Expected:'P'),
    (DxCall:'FY/WN7SST'; Entered:'FY/W?7';  Expected:'P')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
  RunCallTest('FY/WN7SST', 'FX/W7SST', 'P');
end;

procedure TTestDxOperIsMyCall.Test2x3_9;
type
  TEntry = record DxCall, Entered, Expected: string; end;
const
  Data: array[0..26] of TEntry = (
    (DxCall:'WN7SST/9'; Entered:'WN7SST/9'; Expected:'Y'),
    (DxCall:'WN7SST/9'; Entered:'WN';       Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'WN7';      Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'WN7S';     Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'WN7SS';    Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'WN7SSS';   Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'AN7SST';   Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'WN7ABC';   Expected:'N'),
    (DxCall:'WN7SST/9'; Entered:'T';        Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'ST';       Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'SST';      Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'7SS';      Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'WN7XST';  Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'WN7??T';  Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'W7SST';   Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'W7ST';    Expected:'N'),
    (DxCall:'WN7SST/9'; Entered:'WN7ST';   Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'W7AB';    Expected:'N'),
    (DxCall:'WN7SST/9'; Entered:'W7ABC';   Expected:'N'),
    (DxCall:'WN7SST/9'; Entered:'FY';      Expected:'N'),
    (DxCall:'WN7SST/9'; Entered:'FY?';     Expected:'N'),
    (DxCall:'WN7SST/9'; Entered:'/9';      Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'9';       Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'6';       Expected:'N'),
    (DxCall:'WN7SST/9'; Entered:'7';       Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'T/9';     Expected:'P'),
    (DxCall:'WN7SST/9'; Entered:'SST/9';   Expected:'P')
  );
var
  i: Integer;
begin
  for i := 0 to High(Data) do
    RunCallTest(Data[i].DxCall, Data[i].Entered, Data[i].Expected);
  RunCallTest('WN7SST/9', '7SST/9',     'P');
  RunCallTest('WN7SST/9', 'WN7?/9',    'N');
  RunCallTest('WN7SST/9', 'WN7???/9',  'P');
end;

initialization
  RegisterTest(TTestDxOperIsMyCall);

end.
