// LexerTestFPC.pas — FPCUnit port of LexerTest.pas + SSLexerTest.pas
// Original tests used DUnitX; this file uses FPCUnit (shipped with FPC).
unit LexerTestFPC;
{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  fpcunit, testregistry,
  SysUtils, Classes, TypInfo,
  Lexer, SSExchParser;  // SSExchParser exports SSLexerRules, TExchTokenType, TSSLexer

// ------------------------------------------------------------------
// Enum types for the different lexer rule sets.
// Declared at unit scope so TypeInfo() can find their RTTI.
// ------------------------------------------------------------------

// TTestTLexer uses 3 simple rules
type TLexerTokenType = (ttLAlpha, ttLNumeric, ttLAlphaNumeric);

// TTestTLexerWs uses 9 rules including whitespace
type TLexerTokenTypeWs = (ttLWsWhitespace, ttLWsNumberPrec, ttLWsCheckSect,
  ttLWsDigits, ttLWsDigit2, ttLWsDigit1, ttLWsCallsign, ttLWsPrec, ttLWsSect);

// Token rule arrays for TTestTLexer
const LexerBasicRules: array[0..2] of TTokenRuleDef = (
  (R: '[A-Z]+';         T: Ord(ttLAlpha)),
  (R: '\d+';            T: Ord(ttLNumeric)),
  (R: '[A-Z][A-Z\d]*';  T: Ord(ttLAlphaNumeric))
);

// Token rule array for TTestTLexerWs
const LexerWsRules: array[0..8] of TTokenRuleDef = (
  (R: ' +';                   T: Ord(ttLWsWhitespace)),
  (R: '\d+[QABUMS]';          T: Ord(ttLWsNumberPrec)),
  (R: '\d{2}[A-Z]{2,3}';      T: Ord(ttLWsCheckSect)),
  (R: '\d\d\d+';              T: Ord(ttLWsDigits)),
  (R: '\d\d';                 T: Ord(ttLWsDigit2)),
  (R: '\d';                   T: Ord(ttLWsDigit1)),
  (R: '[A-Z]+\d+[A-Z\d/]+';   T: Ord(ttLWsCallsign)),
  (R: '[QABUMS]';             T: Ord(ttLWsPrec)),
  (R: '[A-Z]{2,3}';           T: Ord(ttLWsSect))
);

type

  // ----------------------------------------------------------------
  // Base class holding the lexer runner shared by all fixtures.
  // ----------------------------------------------------------------
  TLexerTestBase = class(TTestCase)
  protected
    aLexer: TLexer;
    Info  : PTypeInfo;

    // Runs aLexer against AValue, checking each token against the
    // comma-separated list in ExpectedTokens.
    // Each entry is a substring that must appear in the token's
    // string representation 'ttXxx(val) at N'.
    procedure RunTokenTest(const AValue, ExpectedTokens: string);
    function  TokenToStr(const AToken: TExchToken): string;
  end;

  // ----------------------------------------------------------------
  // Tests with 3 simple rules: ttAlpha, ttNumeric, ttAlphaNumeric
  // ----------------------------------------------------------------
  TTestTLexer = class(TLexerTestBase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEmptyAndWhitespace;
    procedure TestAlpha;
    procedure TestNumeric;
    procedure TestAlphaNumeric;
    procedure TestMixed;
    procedure TestErrors;
  end;

  // ----------------------------------------------------------------
  // Tests with 9 rules including whitespace token
  // ----------------------------------------------------------------
  TTestTLexerWs = class(TLexerTestBase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestDigits;
    procedure TestMixed;
  end;

  // ----------------------------------------------------------------
  // Tests using SSLexerRules from SSExchParser
  // ----------------------------------------------------------------
  TTestSSRules = class(TLexerTestBase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestBasic;
    procedure TestNumbers;
    procedure TestCallsigns;
    procedure TestMixed;
  end;

  // ----------------------------------------------------------------
  // Tests using TSSLexer (SS exchange lexer object)
  // ----------------------------------------------------------------
  TTestSSLexer = class(TLexerTestBase)
  public
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure TestEmpty;
    procedure TestBasic;
    procedure TestNumbers;
    procedure TestCallsigns;
    procedure TestMixed;
  end;

implementation

{ TLexerTestBase }

function TLexerTestBase.TokenToStr(const AToken: TExchToken): string;
var
  tokName: string;
begin
  if Info <> nil then
    tokName := GetEnumName(Info, AToken.TokenType)
  else
    tokName := IntToStr(AToken.TokenType);
  Result := Format('%s(%s) at %d', [tokName, AToken.Value, AToken.Pos]);
end;

procedure TLexerTestBase.RunTokenTest(const AValue, ExpectedTokens: string);
var
  sl: TStringList;
  token: TExchToken;
  tokenStr, expected: string;
  I: Integer;
begin
  sl := TStringList.Create;
  try
    sl.Delimiter := ',';
    sl.StrictDelimiter := True;
    sl.DelimitedText := ExpectedTokens;

    I := 0;
    aLexer.Input(AValue);
    try
      while aLexer.NextToken(token) do
      begin
        AssertTrue(Format('Extra token from "%s": got %s',
          [AValue, TokenToStr(token)]), I < sl.Count);
        if I >= sl.Count then Break;
        tokenStr := TokenToStr(token);
        expected := Trim(sl[I]);
        AssertTrue(Format('Token %d mismatch in "%s": want "%s" in "%s"',
          [I, AValue, expected, tokenStr]),
          (expected = '') or (Pos(expected, tokenStr) > 0));
        Inc(I);
      end;
    except
      on E: TLexer.ELexerError do
      begin
        if I < sl.Count then
        begin
          expected := Trim(sl[I]);
          AssertTrue(Format('LexerError "%s" missing "%s"', [E.Message, expected]),
            (expected = '') or (Pos(expected, E.Message) > 0));
          Inc(I);
        end;
      end;
    end;
    AssertEquals(Format('Token count mismatch for "%s"', [AValue]), sl.Count, I);
  finally
    sl.Free;
  end;
end;

{ TTestTLexer }

procedure TTestTLexer.SetUp;
begin
  aLexer := TLexer.Create(LexerBasicRules, True);
  Info   := TypeInfo(TLexerTokenType);
end;

procedure TTestTLexer.TearDown;
begin
  FreeAndNil(aLexer);
end;

procedure TTestTLexer.TestEmptyAndWhitespace;
begin
  RunTokenTest('',    '');
  RunTokenTest('  ',  '');
  RunTokenTest('  A', 'ttLAlpha(A) at 3');
  RunTokenTest('A  ', 'ttLAlpha(A) at 1');
  RunTokenTest(' A ', 'ttLAlpha(A) at 2');
end;

procedure TTestTLexer.TestAlpha;
begin
  RunTokenTest('A',       'ttLAlpha(A) at 1');
  RunTokenTest('AB',      'ttLAlpha(AB) at 1');
  RunTokenTest('ABC',     'ttLAlpha(ABC) at 1');
  RunTokenTest('ABC DEF', 'ttLAlpha(ABC) at 1,ttLAlpha(DEF) at 5');
end;

procedure TTestTLexer.TestNumeric;
begin
  RunTokenTest('1',             'ttLNumeric(1) at 1');
  RunTokenTest('12',            'ttLNumeric(12) at 1');
  RunTokenTest('123',           'ttLNumeric(123) at 1');
  RunTokenTest('1234',          'ttLNumeric(1234) at 1');
  RunTokenTest('123 456',       'ttLNumeric(123) at 1,ttLNumeric(456) at 5');
  RunTokenTest('1234 567 89 0', 'ttLNumeric(1234) at 1,ttLNumeric(567) at 6,ttLNumeric(89) at 10,ttLNumeric(0) at 13');
end;

procedure TTestTLexer.TestAlphaNumeric;
begin
  RunTokenTest('ABC123', 'ttLAlpha(ABC) at 1,ttLNumeric(123) at 4');
  RunTokenTest('ABC123 A1B2C3',
    'ttLAlpha(ABC) at 1,ttLNumeric(123) at 4,ttLAlpha(A) at 8,ttLNumeric(1) at 9,ttLAlpha(B),ttLNumeric(2),ttLAlpha(C),ttLNumeric(3)');
end;

procedure TTestTLexer.TestMixed;
begin
  RunTokenTest('22 A 56 OR',
    'ttLNumeric(22) at 1, ttLAlpha(A) at 4, ttLNumeric(56) at 6, ttLAlpha(OR) at 9');
  RunTokenTest('22A 56OR',
    'ttLNumeric(22) at 1,ttLAlpha(A) at 3, ttLNumeric(56) at 5, ttLAlpha(OR) at 7');
  RunTokenTest('1 22 333 A OR WWA 4444',
    'ttLNumeric, ttLNumeric, ttLNumeric, ttLAlpha(A), ttLAlpha(OR), ttLAlpha(WWA), ttLNumeric(4444)');
end;

procedure TTestTLexer.TestErrors;
begin
  RunTokenTest('3.2',    'ttLNumeric(3) at 1,Invalid data (.) at position 2');
  RunTokenTest('XY+ZZY', 'ttLAlpha(XY) at 1,Invalid data (+) at position 3');
end;

{ TTestTLexerWs }

procedure TTestTLexerWs.SetUp;
begin
  aLexer := TLexer.Create(LexerWsRules, False);
  Info   := TypeInfo(TLexerTokenTypeWs);
end;

procedure TTestTLexerWs.TearDown;
begin
  FreeAndNil(aLexer);
end;

procedure TTestTLexerWs.TestDigits;
begin
  RunTokenTest('1',       'ttLWsDigit1(1) at 1');
  RunTokenTest('1 ',      'ttLWsDigit1(1) at 1, ttLWsWhitespace( ) at 2');
  RunTokenTest(' 1 ',     'ttLWsWhitespace( ) at 1, ttLWsDigit1(1) at 2, ttLWsWhitespace( ) at 3');
  RunTokenTest('12',      'ttLWsDigit2(12) at 1');
  RunTokenTest('123',     'ttLWsDigits(123) at 1');
  RunTokenTest('   123  ','ttLWsWhitespace(   ) at 1, ttLWsDigits(123) at 4, ttLWsWhitespace(  ) at 7');
end;

procedure TTestTLexerWs.TestMixed;
begin
  RunTokenTest('22 A 56 OR',
    'ttLWsDigit2(22) at 1, ttLWsWhitespace, ttLWsPrec(A) at 4, ttLWsWhitespace, ttLWsDigit2(56) at 6, ttLWsWhitespace, ttLWsSect(OR) at 9');
  RunTokenTest('22 A 56 OR ',
    'ttLWsDigit2(22) at 1, ttLWsWhitespace, ttLWsPrec(A) at 4, ttLWsWhitespace, ttLWsDigit2(56) at 6, ttLWsWhitespace, ttLWsSect(OR) at 9, ttLWsWhitespace');
end;

{ TTestSSRules }

procedure TTestSSRules.SetUp;
begin
  aLexer := TLexer.Create(SSLexerRules, True);
  Info   := TypeInfo(TExchTokenType);
end;

procedure TTestSSRules.TearDown;
begin
  FreeAndNil(aLexer);
end;

procedure TTestSSRules.TestBasic;
begin
  RunTokenTest('', '');
  RunTokenTest('ABC', 'ttAlpha(ABC) at 1');
  RunTokenTest('ABC DEF', 'ttAlpha(ABC) at 1,ttAlpha(DEF) at 5');
end;

procedure TTestSSRules.TestNumbers;
begin
  RunTokenTest('1',    'ttDigit1(1) at 1');
  RunTokenTest('12',   'ttDigit2(12) at 1');
  RunTokenTest('123',  'ttDigits(123) at 1');
  RunTokenTest('1234', 'ttDigits(1234) at 1');
  RunTokenTest('123 456', 'ttDigits(123) at 1,ttDigits(456) at 5');
  RunTokenTest('1A',   'ttDigit1(1) at 1,ttAlpha(A) at 2');
  RunTokenTest('123Q', 'ttDigits(123) at 1,ttAlpha(Q) at 4');
  RunTokenTest('72OR', 'ttDigit2(72) at 1,ttAlpha(OR)');
end;

procedure TTestSSRules.TestCallsigns;
begin
  RunTokenTest('W7SST',     'ttCallsign(W7SST) at 1');
  RunTokenTest('W7SST/5',   'ttCallsign(W7SST/5) at 1');
  RunTokenTest('KP4/W7SST', 'ttCallsign(KP4/W7SST) at 1');
  RunTokenTest('W7S',       'ttCallsign(W7S) at 1');
  RunTokenTest('WN7SST',    'ttCallsign(WN7SST) at 1');
end;

procedure TTestSSRules.TestMixed;
begin
  RunTokenTest('22 A 56 OR',
    'ttDigit2(22) at 1, ttAlpha(A) at 4, ttDigit2(56) at 6, ttAlpha(OR) at 9');
  RunTokenTest('W1AW 22A 56OR',
    'ttCallsign(W1AW), ttDigit2, ttAlpha, ttDigit2, ttAlpha');
end;

{ TTestSSLexer }

procedure TTestSSLexer.SetUp;
begin
  aLexer := TSSLexer.Create;
  Info   := TypeInfo(TExchTokenType);
end;

procedure TTestSSLexer.TearDown;
begin
  FreeAndNil(aLexer);
end;

procedure TTestSSLexer.TestEmpty;
begin
  RunTokenTest('',    '');
  RunTokenTest(' ',   '');
  RunTokenTest('   ', '');
end;

procedure TTestSSLexer.TestBasic;
begin
  RunTokenTest('  A',  'ttPrec(A) at 3');
  RunTokenTest('A  ',  'ttPrec(A) at 1');
  RunTokenTest(' A ',  'ttPrec(A) at 2');
  RunTokenTest('ABC',  'ttAlpha(ABC) at 1');
  RunTokenTest('1',    'ttDigit1(1) at 1');
  RunTokenTest('12',   'ttDigit2(12) at 1');
  RunTokenTest('123',  'ttDigits(123) at 1');
end;

procedure TTestSSLexer.TestNumbers;
begin
  RunTokenTest('1A',   'ttDigit1(1) at 1,ttPrec(A) at 2');
  RunTokenTest('123Q', 'ttDigits(123) at 1,ttPrec(Q) at 4');
  RunTokenTest('72OR', 'ttDigit2(72) at 1,ttSect(OR)');
  RunTokenTest('72 OR','ttDigit2(72),ttSect(OR) at 4');
  RunTokenTest('7 WWA','ttDigit1(7),ttSect(WWA) at 3');
  RunTokenTest('7 A',  'ttDigit1(7),ttPrec(A) at 3');
  RunTokenTest('7A',   'ttDigit1(7) at 1,ttPrec(A) at 2');
end;

procedure TTestSSLexer.TestCallsigns;
begin
  RunTokenTest('W7SST',     'ttCallsign(W7SST) at 1');
  RunTokenTest('W7SST/5',   'ttCallsign(W7SST/5) at 1');
  RunTokenTest('W7SST/QRP', 'ttCallsign(W7SST/QRP) at 1');
  RunTokenTest('KP4/W7SST', 'ttCallsign(KP4/W7SST) at 1');
  RunTokenTest('W7S',       'ttCallsign(W7S) at 1');
  RunTokenTest('WN7SST',    'ttCallsign(WN7SST) at 1');
end;

procedure TTestSSLexer.TestMixed;
begin
  RunTokenTest('22 A 56 OR',
    'ttDigit2(22) at 1, ttPrec(A) at 4, ttDigit2(56) at 6, ttSect(OR) at 9');
  RunTokenTest('W1AW 22A 56OR',
    'ttCallsign(W1AW), ttDigit2, ttPrec, ttDigit2, ttSect');
  RunTokenTest('ABC123', 'ttAlpha(ABC) at 1,ttDigits(123) at 4');
end;

initialization
  RegisterTest(TTestTLexer);
  RegisterTest(TTestTLexerWs);
  RegisterTest(TTestSSRules);
  RegisterTest(TTestSSLexer);
end.
