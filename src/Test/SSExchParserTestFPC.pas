unit SSExchParserTestFPC;
{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  fpcunit, testregistry, SysUtils, SSExchParser, ExchFields;

type
  TTestSSExchParser = class(TTestCase)
  private
    parser: TSSExchParser;
    procedure RunTest(const AEnteredExchange, AExpected: string);
    procedure ErrorCheck(const AEnteredExchange, AExpected: string);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_Simple_1;
    procedure Test_Simple_2;
    procedure Test_Simple_3;
    procedure Test_Simple_4;
    procedure Test_Simple_5;
    procedure Test_Simple_6;
    procedure Test_Simple_7;
    procedure Test_Simple_8;
    procedure Test_Simple_9;
    procedure Test_Simple_10;
    procedure Test_Simple_11;
    procedure Test_Zero_1;
    procedure Test_Zero_2;
    procedure Test_Zero_3;
    procedure Test_Zero_4;
    procedure Test_Zero_5;
    procedure Test_Zero_6;
    procedure Test_Zero_7;
    procedure Test_Zero_8;
    procedure Test_Zero_9;
    procedure Test_Limit_1;
    procedure Test_Limit_2;
    procedure Test_Limit_3;
    procedure Test_Limit_4;
    procedure Test_Limit_5;
    procedure Test_Prec_1;
    procedure Test_Prec_2;
    procedure Test_Prec_3;
    procedure Test_Prec_4;
    procedure Test_Prec_5;
    procedure Test_Prec_6;
    procedure Test_Prec_7;
    procedure Test_Prec_8;
    procedure Test_Prec_9;
    procedure Test_Prec_10;
    procedure Test_Prec_11;
    procedure Test_Prec_12;
    procedure Test_Sect_1;
    procedure Test_Sect_2;
    procedure Test_Sect_3;
    procedure Test_Sect_4;
    procedure Test_Sect_5;
    procedure Test_Sect_6;
    procedure Test_Sect_7;
    procedure Test_Sect_7a;
    procedure Test_Sect_7b;
    procedure Test_Sect_8;
    procedure Test_Sect_9;
    procedure Test_Sect_10;
    procedure Test_Sect_11;
    procedure Test_Sect_12;
    procedure Test_Sect_13;
    procedure Test_Sect_14;
    procedure Test_Sect_15;
    procedure Test_Sect_16;
    procedure Test_Sect_17;
    procedure Test_Sect_18;
    procedure Test_Sect_19;
    procedure Test_Sect_20;
    procedure Test_Sect_21;
    procedure Test_Sect_22;
    procedure Test_Sect_23;
    procedure Test_Sect_24;
    procedure Test_Sect_31;
    procedure Test_Sect_32;
    procedure Test_Sect_33;
    procedure Test_Sect_34;
    procedure Test_Sect_35;
    procedure Test_Mixed_1;
    procedure Test_Mixed_2;
    procedure Test_Mixed_3;
    procedure Test_Mixed_4;
    procedure Test_Mixed_5;
    procedure Test_Mixed_6;
    procedure Test_Mixed_7;
    procedure Test_Mixed_8;
    procedure Test_Mixed_9;
    procedure Test_Mixed_10;
    procedure Test_Mixed_11;
    procedure Test_Mixed_12;
    procedure Test_Mixed_13;
    procedure Test_Mixed_14;
    procedure Test_Mixed_15;
    procedure Test_Mixed_16;
    procedure Test_Mixed_17;
    procedure Test_Mixed_18;
    procedure Test_Mixed_19;
    procedure Test_Mixed_20;
    procedure Test_Mixed_21;
    procedure Test_Mixed_22;
    procedure Test_Mixed_31;
    procedure Test_Mixed_32;
    procedure Test_Mixed_33;
    procedure Test_Mixed_34;
    procedure Test_Mixed_35;
    procedure Test_Mixed_36;
    procedure Test_Mixed_37;
    procedure Test_Mixed_38;
    procedure Test_Mixed_40;
    procedure Test_Mixed_41;
    procedure Test_Mixed_42;
    procedure Test_Mixed_43;
    procedure Test_Mixed_44;
    procedure Test_Mixed_45;
    procedure Test_Mixed_46;
    procedure Test_Mixed_47;
    procedure Test_Mixed_48;
    procedure Test_Mixed_49;
    procedure Test_Mixed_50;
    procedure Test_Mixed_51;
    procedure Test_Mixed_52;
    procedure Test_Mixed_53;
    procedure Test_Mixed_54;
    procedure Test_Mixed_55;
    procedure Test_Mixed_56;
    procedure Test_Misc_p04_1;
    procedure Test_Misc_p04_2;
    procedure Test_Misc_p04_3;
    procedure Test_Misc_p04_4;
    procedure Test_Misc_p04_6;
    procedure Test_Misc_p04_7;
    procedure Test_Misc_p04_8;
    procedure Test_Misc_p04_9;
    procedure Test_Misc_p04_10;
    procedure Test_Misc_p04_11;
    procedure Test_Misc_p04_12;
    procedure Test_Misc_p04_13;
    procedure Test_Misc_p04_14;
    procedure Test_Misc_p04_15;
    procedure Test_Misc_p05_1;
    procedure Test_Misc_p05_2;
    procedure Test_Misc_p05_3;
    procedure Test_Misc_p06_1;
    procedure Test_Misc_p06_2;
    procedure Test_Misc_p06_3;
    procedure Test_Misc_p06_4;
    procedure Test_Misc_p07_1;
    procedure Test_Misc_p07_2;
    procedure Test_Misc_p07_3;
    procedure Test_Misc_p07_4;
    procedure Test_Misc_p07_5;
    procedure Test_Misc_p07_6;
    procedure Test_Misc_p07_7;
    procedure Test_Misc_p08_1;
    procedure Test_Misc_p08_2;
    procedure Test_Misc_p08_3;
    procedure Test_Misc_p11_1;
    procedure Test_Misc_p11_2;
    procedure Test_Misc_p11_3;
    procedure Test_Misc_p11_4;
    procedure Test_Misc_p11_5;
    procedure Test_Misc_p11_6;
    procedure Test_Misc_p11b_1;
    procedure Test_Misc_p11b_2;
    procedure Test_Misc_p11b_3;
    procedure Test_Misc_p11b_4;
    procedure Test_Misc_p11b_5;
    procedure Test_Misc_p11b_6;
    procedure Test_Misc_p11b_7;
    procedure Test_Misc_p12_1;
    procedure Test_Misc_p12_2;
    procedure Test_Misc_p12_3;
    procedure Test_Misc_p12_4;
    procedure Test_Misc_p12_5;
    procedure Test_Misc_p12_6;
    procedure Test_Misc_p12_7;
    procedure Test_Misc_p12_8;
    procedure Test_Misc_p12_9;
    procedure Test_Misc_p12_10;
    procedure Test_Misc_p12_11;
    procedure Test_Misc_p12_12;
    procedure Test_Misc_p12_13;
    procedure Test_Misc_p12_14;
    procedure Test_Misc_p12_15;
    procedure Test_Misc_p12_15b;
    procedure Test_Misc_p12_15c;
    procedure Test_Misc_p12_16;
    procedure Test_Misc_p12_17;
    procedure Test_Misc_p13_1;
    procedure Test_Misc_p13_2;
    procedure Test_Misc_p13_3;
    procedure Test_Misc_p13_4;
    procedure Test_Misc_p13_5;
    procedure Test_Misc_p13_6;
    procedure Test_Misc_p13_7;
    procedure Test_Misc_p14_1;
    procedure Test_Misc_p14_2;
    procedure Test_Misc_p14_3;
    procedure Test_Misc_p14_4;
    procedure Test_Misc_p14_5;
    procedure Test_Misc_p14_6;
    procedure Test_Misc_p14_7;
    procedure Test_Misc_p14_8;
    procedure Test_Misc_p14_9;
    procedure Test_Misc_p14_10;
    procedure Test_Misc_p14_11;
    procedure Test_Misc_p14_12;
    procedure Test_Misc_p14_13;
    procedure Test_Misc_p14_14;
    procedure Test_Misc_p14_15b;
    procedure Test_Misc_p14_15;
    procedure Test_Misc_p14_15c;
    procedure Test_Misc_p14_15d;
    procedure Test_Misc_p14_15e;
    procedure Test_Misc_p15_1;
    procedure Test_Misc_p15_2;
    procedure Test_Misc_p15_3;
    procedure Test_Misc_p15_4;
    procedure Test_Misc_p15_5;
    procedure Test_Misc_p15_6;
    procedure Test_Misc_p15_7;
    procedure Test_Misc_p15_8;
    procedure Test_Misc_p15_9;
    procedure Test_Misc_p16_1;
    procedure Test_Misc_p16_2;
    procedure Test_Misc_p16_3;
    procedure Test_Misc_p16_4;
    procedure Test_Misc_4;
    procedure Test_Misc_5;
    procedure Test_Misc_6;
    procedure Test_Misc_7;
    procedure Test_Misc_8;
    procedure Test_Misc_9;
    procedure Test_Misc_10;
    procedure Test_Misc_11;
    procedure Test_Misc_12;
    procedure Test_Misc_13;
    procedure Test_Misc_14;
    procedure Test_Misc_15;
    procedure Test_Misc_16;
    procedure Test_Misc_17;
    procedure Test_Misc_18;
    procedure Test_Misc_19;
    procedure Test_Misc_20;
    procedure Test_Misc_21;
    procedure Test_Misc_22;
    procedure Test_Misc_23;
    procedure Test_Misc_24;
    procedure Test_Misc_25;
    procedure Test_Misc_26;
    procedure Test_Misc_27;
    procedure Test_Misc_28;
    procedure Test_Misc_29;
    procedure Test_Misc_31;
    procedure Test_Misc_32;
    procedure Test_Misc_33;
    procedure Test_Misc_34;
    procedure Test_Misc_35;
    procedure Test_Misc_40;
    procedure Test_Misc_41;
    procedure Test_Misc_42;
    procedure Test_Misc_43;
    procedure Test_Misc_44;
    procedure Test_Misc_50;
    procedure Test_Misc_51;
    procedure Test_Misc_52;
    procedure Test_Misc_53;
    procedure Test_Misc_54;
    procedure Test_Misc_60;
    procedure Test_Misc_61;
    procedure Test_Misc_62;
    procedure Test_Misc_63;
    procedure Test_Misc_64;
    procedure Test_Misc_65;
    procedure Test_Misc_66;
    procedure Test_Misc_67;
    procedure Test_Misc_68;
    procedure Test_Misc_69;
    procedure Test_Misc_70;
    procedure Test_Misc_71;
    procedure Test_Misc_72;
    procedure Test_Misc_73;
    { ErrorCheck tests }
    procedure Test_Err_Invalid_01;
    procedure Test_Err_Extra_01;
    procedure Test_Err_Extra_02;
    procedure Test_Err_Extra_03;
    procedure Test_Err_Extra_04;
    procedure Test_Err_Extra_05;
    procedure Test_Err_Extra_06;
    procedure Test_Err_Extra_07;
    procedure Test_Err_Extra_08;
    procedure Test_Err_Missing_01;
    procedure Test_Err_Missing_02;
    procedure Test_Err_Missing_11;
    procedure Test_Err_Missing_12;
    procedure Test_Err_Missing_13;
    procedure Test_Err_Missing_14;
    procedure Test_Err_Missing_21;
    procedure Test_Err_Missing_22;
    procedure Test_Err_Invalid_11;
    procedure Test_Err_Invalid_21;
    procedure Test_Err_Invalid_22;
    procedure Test_Err_Invalid_23;
    procedure Test_Err_Invalid_31;
    procedure Test_Err_Invalid_32;
    procedure Test_Err_Invalid_33a;
    procedure Test_Err_Invalid_33b;
    procedure Test_Err_Invalid_41;
    procedure Test_Err_Invalid_42;
    procedure Test_Err_Invalid_43;
    procedure Test_Err_Invalid_44a;
    procedure Test_Err_Invalid_44b;
  end;

  TTestMySSExch = class(TTestCase)
  private
    parser: TMyExchParser;
    procedure RunTest1(const AExchange, AExpected: string);
    procedure RunErrorCheck(const AMyExchange, AExpected: string);
  protected
    procedure SetUp; override;
    procedure TearDown; override;
  published
    procedure Test_General_1;
    procedure Test_General_2;
    procedure Test_General_3;
    procedure Test_General_4;
    procedure Test_General_5;
    procedure Test_General_6;
    procedure Test_Error_Invalid_01;
    procedure Test_Error_Extra_01;
    procedure Test_Error_Extra_02;
    procedure Test_Error_Extra_03;
    procedure Test_Error_Extra_04;
    procedure Test_Error_Extra_05;
    procedure Test_Error_Extra_06;
    procedure Test_Error_Extra_07;
    procedure Test_Error_Extra_08;
    procedure Test_Error_Missing_01;
    procedure Test_Error_Missing_02;
    procedure Test_Error_Missing_11;
    procedure Test_Error_Missing_12;
    procedure Test_Error_Missing_13;
    procedure Test_Error_Missing_14;
    procedure Test_Error_Missing_21;
    procedure Test_Error_Missing_22;
    procedure Test_Error_Invalid_11;
    procedure Test_Error_Invalid_21;
    procedure Test_Error_Invalid_22;
    procedure Test_Error_Invalid_23;
    procedure Test_Error_Invalid_31;
    procedure Test_Error_Invalid_32;
    procedure Test_Error_Invalid_33a;
    procedure Test_Error_Invalid_33b;
    procedure Test_Error_Invalid_41;
    procedure Test_Error_Invalid_42;
    procedure Test_Error_Invalid_43;
    procedure Test_Error_Invalid_44a;
    procedure Test_Error_Invalid_44b;
  end;

implementation

{ ---------------------------------------------------------------------------
  Helper
  --------------------------------------------------------------------------- }

procedure SplitTab(const s: string; out Left, Right: string);
var
  p: Integer;
begin
  p := Pos(#9, s);
  if p > 0 then
  begin
    Left  := Copy(s, 1, p - 1);
    Right := Copy(s, p + 1, MaxInt);
  end
  else
  begin
    Left  := s;
    Right := '';
  end;
end;

{ ---------------------------------------------------------------------------
  TTestSSExchParser
  --------------------------------------------------------------------------- }

procedure TTestSSExchParser.SetUp;
begin
  parser := TSSExchParser.Create;
end;

procedure TTestSSExchParser.TearDown;
begin
  FreeAndNil(parser);
end;

procedure TTestSSExchParser.RunTest(const AEnteredExchange, AExpected: string);
var
  R: boolean;
  S, ExchError, Summary: string;
begin
  ExchError := '';
  R := parser.ValidateEnteredExchange('', '', AEnteredExchange, ExchError);
  Summary := Format('%d.%s.%s.%s', [parser.NR, parser.Precedence, parser.Check, parser.Section]);
  if parser.Call <> '' then
    Summary := Summary + '.' + parser.Call;
  if R then
    AssertTrue(Format('Input="%s" Got="%s" Expected="%s"', [AEnteredExchange, Summary, AExpected.Trim]),
               AExpected.Trim = Summary)
  else
  begin
    S := Summary + '-' + ExchError;
    AssertTrue(Format('Input="%s" Got="%s" Expected="%s"', [AEnteredExchange, S, AExpected.Trim]),
               Pos(AExpected.Trim, S) > 0);
  end;
end;

procedure TTestSSExchParser.ErrorCheck(const AEnteredExchange, AExpected: string);
var
  R: boolean;
  ExchError: string;
begin
  ExchError := '';
  R := parser.ValidateEnteredExchange('', '', AEnteredExchange, ExchError);
  AssertFalse(Format('Expected "%s" to fail', [AEnteredExchange]), R);
  AssertTrue(Format('ExchError="%s" should contain "%s"', [ExchError, AExpected.Trim]),
             Pos(AExpected.Trim, ExchError) > 0);
end;

{ Simple }
procedure TTestSSExchParser.Test_Simple_1;  begin RunTest('1',           '1...-Missing/Invalid Precedence'); end;
procedure TTestSSExchParser.Test_Simple_2;  begin RunTest('12',          '0..12.-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Simple_3;  begin RunTest('123',         '123...-Missing/Invalid Precedence'); end;
procedure TTestSSExchParser.Test_Simple_4;  begin RunTest('1234',        '1234...-Missing/Invalid Precedence'); end;
procedure TTestSSExchParser.Test_Simple_5;  begin RunTest('11 22',       '11..22.'); end;
procedure TTestSSExchParser.Test_Simple_6;  begin RunTest('11 22 33',    '22..33.'); end;
procedure TTestSSExchParser.Test_Simple_7;  begin RunTest('11 22 33 44', '33..44.'); end;
procedure TTestSSExchParser.Test_Simple_8;  begin RunTest('1',           '1...-Missing/Invalid Precedence'); end;
procedure TTestSSExchParser.Test_Simple_9;  begin RunTest('1 2',         '2...'); end;
procedure TTestSSExchParser.Test_Simple_10; begin RunTest('1 2 3',       '3...'); end;
procedure TTestSSExchParser.Test_Simple_11; begin RunTest('1 2 3 4',     '4...'); end;

{ Zero }
procedure TTestSSExchParser.Test_Zero_1; begin RunTest('0 01',        '0..01.'); end;
procedure TTestSSExchParser.Test_Zero_2; begin RunTest('01 0',        '1..00.'); end;
procedure TTestSSExchParser.Test_Zero_3; begin RunTest('0 01 02',     '1..02.'); end;
procedure TTestSSExchParser.Test_Zero_4; begin RunTest('01 0 02',     '0..02.'); end;
procedure TTestSSExchParser.Test_Zero_5; begin RunTest('01 02 0',     '2..00.'); end;
procedure TTestSSExchParser.Test_Zero_6; begin RunTest('0 01 02 03',  '2..03.'); end;
procedure TTestSSExchParser.Test_Zero_7; begin RunTest('01 0 02 03',  '2..03.'); end;
procedure TTestSSExchParser.Test_Zero_8; begin RunTest('01 02 0 03',  '0..03.'); end;
procedure TTestSSExchParser.Test_Zero_9; begin RunTest('01 02 03 0',  '3..00.'); end;

{ Limit }
procedure TTestSSExchParser.Test_Limit_1; begin RunTest('9999 A 72 OR',   '9999.A.72.OR'); end;
procedure TTestSSExchParser.Test_Limit_2; begin RunTest('10000 A 72 OR',  '10000.A.72.OR'); end;
procedure TTestSSExchParser.Test_Limit_3; begin RunTest('10001 A 72 OR',  '10000.A.72.OR'); end;
procedure TTestSSExchParser.Test_Limit_4; begin RunTest('99999 A 72 OR',  '10000.A.72.OR'); end;
procedure TTestSSExchParser.Test_Limit_5; begin RunTest('999999 A 72 OR', '10000.A.72.OR'); end;

{ Prec }
procedure TTestSSExchParser.Test_Prec_1;  begin RunTest('1 A',        '1.A..'); end;
procedure TTestSSExchParser.Test_Prec_2;  begin RunTest('12 A',       '12.A..'); end;
procedure TTestSSExchParser.Test_Prec_3;  begin RunTest('123 A',      '123.A..'); end;
procedure TTestSSExchParser.Test_Prec_4;  begin RunTest('1234 A',     '1234.A..'); end;
procedure TTestSSExchParser.Test_Prec_5;  begin RunTest('1 X',        '1...'); end;
procedure TTestSSExchParser.Test_Prec_6;  begin RunTest('12 X',       '12...'); end;
procedure TTestSSExchParser.Test_Prec_7;  begin RunTest('123 X',      '123...'); end;
procedure TTestSSExchParser.Test_Prec_8;  begin RunTest('1234 X',     '1234...'); end;
procedure TTestSSExchParser.Test_Prec_9;  begin RunTest('1 A 123 B',  '123.B..'); end;
procedure TTestSSExchParser.Test_Prec_10; begin RunTest('1 A 123 B M','123.M..'); end;
procedure TTestSSExchParser.Test_Prec_11; begin RunTest('1 A B',      '1.B..'); end;
procedure TTestSSExchParser.Test_Prec_12; begin RunTest('1 A B U M S','1.S..'); end;

{ Sect }
procedure TTestSSExchParser.Test_Sect_1;  begin RunTest('12 OR',                '0..12.OR'); end;
procedure TTestSSExchParser.Test_Sect_2;  begin RunTest('12 34 OR',             '12..34.OR'); end;
procedure TTestSSExchParser.Test_Sect_3;  begin RunTest('12 34 OR 56',          '12..56.OR'); end;
procedure TTestSSExchParser.Test_Sect_4;  begin RunTest('12 34 OR 56 78',       '56..78.OR'); end;
procedure TTestSSExchParser.Test_Sect_5;  begin RunTest('12 OR 34',             '0..34.OR'); end;
procedure TTestSSExchParser.Test_Sect_6;  begin RunTest('12 OR 34 56',          '34..56.OR'); end;
procedure TTestSSExchParser.Test_Sect_7;  begin RunTest('1 2 3 ID 4',           '4..03.ID'); end;
procedure TTestSSExchParser.Test_Sect_7a; begin RunTest('1 2 3 ID 4 OR',        '2..04.OR'); end;
procedure TTestSSExchParser.Test_Sect_7b; begin RunTest('1 2 3 ID 4 OR WWA',    '2..04.WWA'); end;
procedure TTestSSExchParser.Test_Sect_8;  begin RunTest('1 2 3 ID 4 X',         '4..03.ID'); end;
procedure TTestSSExchParser.Test_Sect_9;  begin RunTest('1 2 3 ID 4 XX',        '2..04.ID'); end;
procedure TTestSSExchParser.Test_Sect_10; begin RunTest('1 2 3 ID 4 XX OR WWA', '2..04.WWA'); end;
procedure TTestSSExchParser.Test_Sect_11; begin RunTest('1 2 3 ID 4 XYZ',       '2..04.ID'); end;
procedure TTestSSExchParser.Test_Sect_12; begin RunTest('1 2 3 ID 4 WXYZ',      '4..03.ID'); end;
procedure TTestSSExchParser.Test_Sect_13; begin RunTest('11 22 33 ID 44',       '22..44.ID'); end;
procedure TTestSSExchParser.Test_Sect_14; begin RunTest('11 22 33 ID 44 55',    '44..55.ID'); end;
procedure TTestSSExchParser.Test_Sect_15; begin RunTest('11 22 33 ID 44 55 66', '55..66.ID'); end;
procedure TTestSSExchParser.Test_Sect_16; begin RunTest('11 12 13 XX',          '12..13.'); end;
procedure TTestSSExchParser.Test_Sect_17; begin RunTest('11 12 13 XYZ',         '12..13.'); end;
procedure TTestSSExchParser.Test_Sect_18; begin RunTest('11 12 13 XX OR',       '12..13.OR'); end;
procedure TTestSSExchParser.Test_Sect_19; begin RunTest('11 22 33 ID 44 X',     '44..33.ID'); end;
procedure TTestSSExchParser.Test_Sect_20; begin RunTest('11 22 33 ID 44 XX',    '22..44.ID'); end;
procedure TTestSSExchParser.Test_Sect_21; begin RunTest('11 22 33 ID 44 XYZ',   '22..44.ID'); end;
procedure TTestSSExchParser.Test_Sect_22; begin RunTest('11 22 33 ID 44 WXYZ',  '22..44.ID'); end;
procedure TTestSSExchParser.Test_Sect_23; begin RunTest('11 22 33 ID 44 O',     '44..33.ID'); end;
procedure TTestSSExchParser.Test_Sect_24; begin RunTest('11 22 33 ID 44 OR',    '22..44.OR'); end;
procedure TTestSSExchParser.Test_Sect_31; begin RunTest('11 12 13 XX',          '12..13.'); end;
procedure TTestSSExchParser.Test_Sect_32; begin RunTest('11 12 13 XX YY',       '12..13.'); end;
procedure TTestSSExchParser.Test_Sect_33; begin RunTest('11 12 13 XX YY WWA',   '12..13.WWA'); end;
procedure TTestSSExchParser.Test_Sect_34; begin RunTest('11 7 13 XX YY WWA',    '7..13.WWA'); end;
procedure TTestSSExchParser.Test_Sect_35; begin RunTest('7 11 8 XX YY WWA',     '7..08.WWA'); end;

{ Mixed }
procedure TTestSSExchParser.Test_Mixed_1;  begin RunTest('12 A 34 OR',           '12.A.34.OR'); end;
procedure TTestSSExchParser.Test_Mixed_2;  begin RunTest('1 22 3 ID',            '1..03.ID'); end;
procedure TTestSSExchParser.Test_Mixed_3;  begin RunTest('1 22 3 ID 4',          '4..03.ID'); end;
procedure TTestSSExchParser.Test_Mixed_4;  begin RunTest('1 A 22 3 ID 4',        '4.A.03.ID'); end;
procedure TTestSSExchParser.Test_Mixed_5;  begin RunTest('1 ID 22 3 A 4',        '4.A.22.ID'); end;
procedure TTestSSExchParser.Test_Mixed_6;  begin RunTest('1 A 22 4 ID 3 4',      '4.A.04.ID'); end;
procedure TTestSSExchParser.Test_Mixed_7;  begin RunTest('1 A 22 ID 3 4',        '4.A.22.ID'); end;
procedure TTestSSExchParser.Test_Mixed_8;  begin RunTest('1 A 22 123 ID 4',      '4.A.22.'); end;
procedure TTestSSExchParser.Test_Mixed_9;  begin RunTest('22 ID 1 A',            '1.A.22.ID'); end;
procedure TTestSSExchParser.Test_Mixed_10; begin RunTest('123 11 A ID',          '11.A..ID'); end;
procedure TTestSSExchParser.Test_Mixed_11; begin RunTest('72 OR 73 56 A',        '56.A.73.OR'); end;
procedure TTestSSExchParser.Test_Mixed_12; begin RunTest('72 OR 73 74 56 A',     '56.A.74.OR'); end;
procedure TTestSSExchParser.Test_Mixed_13; begin RunTest('72 OR 73 A 72 73 A',   '73.A.72.OR'); end;
procedure TTestSSExchParser.Test_Mixed_14; begin RunTest('72OR  73 A 72 73A',    '73.A.72.OR'); end;
procedure TTestSSExchParser.Test_Mixed_15; begin RunTest('72 OR 73 A 72 73',     '73.A.73.OR'); end;
procedure TTestSSExchParser.Test_Mixed_16; begin RunTest('72OR 73A 72 73',       '73.A.73.OR'); end;
procedure TTestSSExchParser.Test_Mixed_17; begin RunTest('72 OR 73 A 72 73 74',  '73.A.74.OR'); end;
procedure TTestSSExchParser.Test_Mixed_18; begin RunTest('72 OR 73 72 A 74 75',  '72.A.75.OR'); end;
procedure TTestSSExchParser.Test_Mixed_19; begin RunTest('72OR  73 72A  74 75',  '72.A.75.OR'); end;
procedure TTestSSExchParser.Test_Mixed_20; begin RunTest('1 2 OR 10 11 A',       '11.A.10.OR'); end;
procedure TTestSSExchParser.Test_Mixed_21; begin RunTest('1 2 OR 10 3 11 A',     '11.A.10.OR'); end;
procedure TTestSSExchParser.Test_Mixed_22; begin RunTest('1 2OR  10 3 11A',      '11.A.10.OR'); end;
procedure TTestSSExchParser.Test_Mixed_31; begin RunTest('XX YY ZZ 1',           '1...'); end;
procedure TTestSSExchParser.Test_Mixed_32; begin RunTest('XX YY ZZ 1 XX',        '0..01.'); end;
procedure TTestSSExchParser.Test_Mixed_33; begin RunTest('XX YY ZZ 1 XX YY',     '0..01.'); end;
procedure TTestSSExchParser.Test_Mixed_34; begin RunTest('XX YY ZZ 1 XX YY B',   '0.B.01.'); end;
procedure TTestSSExchParser.Test_Mixed_35; begin RunTest('XX YY ZZ 1 XX YY ID',  '0..01.ID'); end;
procedure TTestSSExchParser.Test_Mixed_36; begin RunTest('XX YY ZZ 1 XX ID B',   '0.B.01.ID'); end;
procedure TTestSSExchParser.Test_Mixed_37; begin RunTest('XX YY ZZ 1 XX B',      '0.B.01.'); end;
procedure TTestSSExchParser.Test_Mixed_38; begin RunTest('XX YY ZZ 1 XX B ID',   '0.B.01.ID'); end;
procedure TTestSSExchParser.Test_Mixed_40; begin RunTest('10A20OR',              '10.A.20.OR'); end;
procedure TTestSSExchParser.Test_Mixed_41; begin RunTest('20OR10A',              '10.A.20.OR'); end;
procedure TTestSSExchParser.Test_Mixed_42; begin RunTest('20OR 10A',             '10.A.20.OR'); end;
procedure TTestSSExchParser.Test_Mixed_43; begin RunTest('10 20OR 30A',          '30.A.20.OR'); end;
procedure TTestSSExchParser.Test_Mixed_44; begin RunTest('20OR 10 30A',          '30.A.10.OR'); end;
procedure TTestSSExchParser.Test_Mixed_45; begin RunTest('20OR10A W1AW',         '10.A.20.OR.W1AW'); end;
procedure TTestSSExchParser.Test_Mixed_46; begin RunTest('10A20OR W1AW',         '10.A.20.OR.W1AW'); end;
procedure TTestSSExchParser.Test_Mixed_47; begin RunTest('W1AW 20OR10A',         '10.A.20.OR.W1AW'); end;
procedure TTestSSExchParser.Test_Mixed_48; begin RunTest('W1AW 10A20OR',         '10.A.20.OR.W1AW'); end;
procedure TTestSSExchParser.Test_Mixed_49; begin RunTest('W1AW10A20OR',          '0....W1AW10A20OR'); end;
procedure TTestSSExchParser.Test_Mixed_50; begin RunTest('10A20ORW1AW',          '10.A.01.'); end;
procedure TTestSSExchParser.Test_Mixed_51; begin RunTest('86 TN',                '0..86.TN'); end;
procedure TTestSSExchParser.Test_Mixed_52; begin RunTest('86 TN WM',             '0..86.'); end;
procedure TTestSSExchParser.Test_Mixed_53; begin RunTest('86 TN WM 6',           '6..86.TN-Missing/Invalid Precedence'); end;
procedure TTestSSExchParser.Test_Mixed_54; begin RunTest('86 TN WM 66',          '0..66.TN-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Mixed_55; begin RunTest('86 TN WM 66 B',        '66.B.86.TN'); end;
procedure TTestSSExchParser.Test_Mixed_56; begin RunTest('86 TN WM4Q 66 B',      '66.B.86.TN.WM4Q'); end;

{ Misc.p04 }
procedure TTestSSExchParser.Test_Misc_p04_1;  begin RunTest('98',               '0..98.'); end;
procedure TTestSSExchParser.Test_Misc_p04_2;  begin RunTest('98 WNY',           '0..98.WNY'); end;
procedure TTestSSExchParser.Test_Misc_p04_3;  begin RunTest('98 WNY 1',         '1..98.WNY'); end;
procedure TTestSSExchParser.Test_Misc_p04_4;  begin RunTest('98 WNY 11',        '0..11.WNY'); end;
procedure TTestSSExchParser.Test_Misc_p04_6;  begin RunTest('98 WNY 11 A',      '11.A.98.WNY'); end;
procedure TTestSSExchParser.Test_Misc_p04_7;  begin RunTest('98 WNY N2DC 11 A', '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_8;  begin RunTest('98 WNY N2DC 11A',  '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_9;  begin RunTest('98 WNY 11A N2DC',  '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_10; begin RunTest('98 11A WNY N2DC',  '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_11; begin RunTest('11A 98 WNY N2DC',  '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_12; begin RunTest('98 WNY 11A N2DC',  '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_13; begin RunTest('98 WNY N2DC 11A',  '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_14; begin RunTest('98 N2DC WNY 11A',  '11.A.98.WNY.N2DC'); end;
procedure TTestSSExchParser.Test_Misc_p04_15; begin RunTest('N2DC 98 WNY 11A',  '11.A.98.WNY.N2DC'); end;

{ Misc.p05 }
procedure TTestSSExchParser.Test_Misc_p05_1; begin RunTest('123 124 11 A UT',      '11.A..UT'); end;
procedure TTestSSExchParser.Test_Misc_p05_2; begin RunTest('123 124 11 A UT 0',    '11.A.00.UT'); end;
procedure TTestSSExchParser.Test_Misc_p05_3; begin RunTest('123 124 11 A UT 125',  '125.A..UT'); end;

{ Misc.p06 }
procedure TTestSSExchParser.Test_Misc_p06_1; begin RunTest('1 111 OR',        '1...'); end;
procedure TTestSSExchParser.Test_Misc_p06_2; begin RunTest('12 111 OR',       '0..12.'); end;
procedure TTestSSExchParser.Test_Misc_p06_3; begin RunTest('12 111 OR UT',    '0..12.UT'); end;
procedure TTestSSExchParser.Test_Misc_p06_4; begin RunTest('12 111 OR UT 13', '12..13.UT'); end;

{ Misc.p07 }
procedure TTestSSExchParser.Test_Misc_p07_1; begin RunTest('12 111 OR UT 13',  '12..13.UT'); end;
procedure TTestSSExchParser.Test_Misc_p07_2; begin RunTest('12        UT 13',  '0..13.UT'); end;
procedure TTestSSExchParser.Test_Misc_p07_3; begin RunTest('12 111 OR UT',     '0..12.UT'); end;
procedure TTestSSExchParser.Test_Misc_p07_4; begin RunTest('12 A OR 133',      '133.A..OR'); end;
procedure TTestSSExchParser.Test_Misc_p07_5; begin RunTest('12 A OR 13',       '12.A.13.OR'); end;
procedure TTestSSExchParser.Test_Misc_p07_6; begin RunTest('12 OR 13',         '0..13.OR'); end;
procedure TTestSSExchParser.Test_Misc_p07_7; begin RunTest('11 12 ORR 133',    '133..12.'); end;

{ Misc.p08 }
procedure TTestSSExchParser.Test_Misc_p08_1; begin RunTest('11 12 UT 13',    '11..13.UT'); end;
procedure TTestSSExchParser.Test_Misc_p08_2; begin RunTest('11 12 XYZ 13',   '11..13.'); end;
procedure TTestSSExchParser.Test_Misc_p08_3; begin RunTest('11 12 XYZZ 123', '123..12.'); end;

{ Misc.p11 }
procedure TTestSSExchParser.Test_Misc_p11_1; begin RunTest('11 12',       '11..12.'); end;
procedure TTestSSExchParser.Test_Misc_p11_2; begin RunTest('11 12 A',     '12.A.11.'); end;
procedure TTestSSExchParser.Test_Misc_p11_3; begin RunTest('11 12 A 1',   '1.A.11.'); end;
procedure TTestSSExchParser.Test_Misc_p11_4; begin RunTest('11 12 A 13',  '12.A.13.'); end;
procedure TTestSSExchParser.Test_Misc_p11_5; begin RunTest('11 12 A 134', '134.A.11.'); end;
procedure TTestSSExchParser.Test_Misc_p11_6; begin RunTest('11 12 A 1345','1345.A.11.'); end;

{ Misc.p11b }
procedure TTestSSExchParser.Test_Misc_p11b_1; begin RunTest('11 12',            '11..12.'); end;
procedure TTestSSExchParser.Test_Misc_p11b_2; begin RunTest('11 12 OR',         '11..12.OR'); end;
procedure TTestSSExchParser.Test_Misc_p11b_3; begin RunTest('11 12 OR 1',       '1..12.OR'); end;
procedure TTestSSExchParser.Test_Misc_p11b_4; begin RunTest('11 12 OR 13',      '11..13.OR'); end;
procedure TTestSSExchParser.Test_Misc_p11b_5; begin RunTest('11 12 OR 134',     '134..12.OR'); end;
procedure TTestSSExchParser.Test_Misc_p11b_6; begin RunTest('11 12 OR 13 14',   '13..14.OR'); end;
procedure TTestSSExchParser.Test_Misc_p11b_7; begin RunTest('11 12 OR 13 14 15','14..15.OR'); end;

{ Misc.p12 }
procedure TTestSSExchParser.Test_Misc_p12_1;  begin RunTest('1 2 OR',          '1..02.OR'); end;
procedure TTestSSExchParser.Test_Misc_p12_2;  begin RunTest('1 OR 2',          '2..01.OR'); end;
procedure TTestSSExchParser.Test_Misc_p12_3;  begin RunTest('',                '0...-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Misc_p12_4;  begin RunTest('1',               '1...-Missing/Invalid Precedence'); end;
procedure TTestSSExchParser.Test_Misc_p12_5;  begin RunTest('2 4',             '4...'); end;
procedure TTestSSExchParser.Test_Misc_p12_6;  begin RunTest('2 0',             '2..00.'); end;
procedure TTestSSExchParser.Test_Misc_p12_7;  begin RunTest('2 00',            '2..00.'); end;
procedure TTestSSExchParser.Test_Misc_p12_8;  begin RunTest('2 000',           '0...'); end;
procedure TTestSSExchParser.Test_Misc_p12_9;  begin RunTest('56 A 0',          '56.A.00.'); end;
procedure TTestSSExchParser.Test_Misc_p12_10; begin RunTest('11 12 ID 134 14', '134..14.ID'); end;
procedure TTestSSExchParser.Test_Misc_p12_11; begin RunTest('11 12 ID 134 14 A','14.A.12.ID'); end;
procedure TTestSSExchParser.Test_Misc_p12_12; begin RunTest('11 12 ID 134 14 Z','14..12.ID'); end;
procedure TTestSSExchParser.Test_Misc_p12_13; begin RunTest('11 A 12 Z',       '12.A..'); end;
procedure TTestSSExchParser.Test_Misc_p12_14; begin RunTest('11 12 Z',         '12..11.'); end;
procedure TTestSSExchParser.Test_Misc_p12_15; begin RunTest('11 12 ZZ',        '11..12.'); end;
procedure TTestSSExchParser.Test_Misc_p12_15b;begin RunTest('11 12 ZZZ',       '11..12.'); end;
procedure TTestSSExchParser.Test_Misc_p12_15c;begin RunTest('11 12 ZZZZ',      '11..12.'); end;
procedure TTestSSExchParser.Test_Misc_p12_16; begin RunTest('0ID',             '0..00.ID'); end;
procedure TTestSSExchParser.Test_Misc_p12_17; begin RunTest('0 ID',            '0..00.ID'); end;

{ Misc.p13 }
procedure TTestSSExchParser.Test_Misc_p13_1; begin RunTest('01 02',        '1..02.'); end;
procedure TTestSSExchParser.Test_Misc_p13_2; begin RunTest('01 02 A',      '2.A.01.'); end;
procedure TTestSSExchParser.Test_Misc_p13_3; begin RunTest('01 02 A 03',   '2.A.03.'); end;
procedure TTestSSExchParser.Test_Misc_p13_4; begin RunTest('01 02 A 3',    '3.A.01.'); end;
procedure TTestSSExchParser.Test_Misc_p13_5; begin RunTest('01 02 A 57 3', '3.A.57.'); end;
procedure TTestSSExchParser.Test_Misc_p13_6; begin RunTest('01 02 A 003',  '3.A.01.'); end;
procedure TTestSSExchParser.Test_Misc_p13_7; begin RunTest('01 02 A 000',  '0.A.01.'); end;

{ Misc.p14 }
procedure TTestSSExchParser.Test_Misc_p14_1;  begin RunTest('01',               '0..01.-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Misc_p14_2;  begin RunTest('01 02',            '1..02.'); end;
procedure TTestSSExchParser.Test_Misc_p14_3;  begin RunTest('01 02 A',          '2.A.01.'); end;
procedure TTestSSExchParser.Test_Misc_p14_4;  begin RunTest('01 02 A 5',        '5.A.01.'); end;
procedure TTestSSExchParser.Test_Misc_p14_5;  begin RunTest('01 02 A 57',       '2.A.57.'); end;
procedure TTestSSExchParser.Test_Misc_p14_6;  begin RunTest('01 02 A 57 7',     '7.A.57.'); end;
procedure TTestSSExchParser.Test_Misc_p14_7;  begin RunTest('01 02 A 57 72',    '2.A.72.'); end;
procedure TTestSSExchParser.Test_Misc_p14_8;  begin RunTest('01 02 A 57 72 8',  '8.A.72.'); end;
procedure TTestSSExchParser.Test_Misc_p14_9;  begin RunTest('01 02 A 57 72 83', '2.A.83.'); end;
procedure TTestSSExchParser.Test_Misc_p14_10; begin RunTest('1',                '1...-Missing/Invalid Precedence'); end;
procedure TTestSSExchParser.Test_Misc_p14_11; begin RunTest('1 2',              '2...'); end;
procedure TTestSSExchParser.Test_Misc_p14_12; begin RunTest('1 2 3',            '3...'); end;
procedure TTestSSExchParser.Test_Misc_p14_13; begin RunTest('1 2 3 ID',         '2..03.ID'); end;
procedure TTestSSExchParser.Test_Misc_p14_14; begin RunTest('1 2 3 ID 4',       '4..03.ID'); end;
procedure TTestSSExchParser.Test_Misc_p14_15b;begin RunTest('1 2 3 ID 4 X',     '4..03.ID'); end;
procedure TTestSSExchParser.Test_Misc_p14_15; begin RunTest('1 2 3 ID 4 XX',    '2..04.ID'); end;
procedure TTestSSExchParser.Test_Misc_p14_15c;begin RunTest('1 2 3 ID 4 XXX',   '2..04.ID'); end;
procedure TTestSSExchParser.Test_Misc_p14_15d;begin RunTest('1 2 3 ID 4 XXXX',  '4..03.ID'); end;
procedure TTestSSExchParser.Test_Misc_p14_15e;begin RunTest('1 2 3 ID 4 WWA',   '2..04.WWA'); end;

{ Misc.p15 }
procedure TTestSSExchParser.Test_Misc_p15_1; begin RunTest('10',                    '0..10.-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Misc_p15_2; begin RunTest('10 20',                 '10..20.'); end;
procedure TTestSSExchParser.Test_Misc_p15_3; begin RunTest('10 20 30',              '20..30.'); end;
procedure TTestSSExchParser.Test_Misc_p15_4; begin RunTest('10 20 30 X',            '30..20.'); end;
procedure TTestSSExchParser.Test_Misc_p15_5; begin RunTest('10 20 30 X 40',         '30..40.'); end;
procedure TTestSSExchParser.Test_Misc_p15_6; begin RunTest('10 20 30 X 40 50',      '30..50.'); end;
procedure TTestSSExchParser.Test_Misc_p15_7; begin RunTest('10 20 30 X 40 50 A',    '50.A.40.'); end;
procedure TTestSSExchParser.Test_Misc_p15_8; begin RunTest('10 20 30 X 40 50 60',   '30..60.'); end;
procedure TTestSSExchParser.Test_Misc_p15_9; begin RunTest('10 20 30 X 40 50 60 A', '60.A.50.'); end;

{ Misc.p16 }
procedure TTestSSExchParser.Test_Misc_p16_1; begin RunTest('11 22 33 ID 44 X', '44..33.ID'); end;
procedure TTestSSExchParser.Test_Misc_p16_2; begin RunTest('11 0 33 ID',       '0..33.ID'); end;
procedure TTestSSExchParser.Test_Misc_p16_3; begin RunTest('11 0 33 ID X',     '0..33.ID'); end;
procedure TTestSSExchParser.Test_Misc_p16_4; begin RunTest('11 0 33 ID A',     '0.A.33.ID'); end;

{ Misc }
procedure TTestSSExchParser.Test_Misc_4;  begin RunTest('1 111 OR 66',           '1..66.'); end;
procedure TTestSSExchParser.Test_Misc_5;  begin RunTest('1 111 OR 66 A',         '66.A..'); end;
procedure TTestSSExchParser.Test_Misc_6;  begin RunTest('10 20 111 OR',          '10..20.'); end;
procedure TTestSSExchParser.Test_Misc_7;  begin RunTest('10 20 111 OR A',        '10.A.20.'); end;
procedure TTestSSExchParser.Test_Misc_8;  begin RunTest('10 20 111 222 OR',      '111..20.'); end;
procedure TTestSSExchParser.Test_Misc_9;  begin RunTest('10 20 111 222 OR ID',   '111..20.ID'); end;
procedure TTestSSExchParser.Test_Misc_10; begin RunTest('10 20 111 222 OR A ID', '111.A.20.ID'); end;
procedure TTestSSExchParser.Test_Misc_11; begin RunTest('10 20 111 222 OR ID A', '111.A.20.ID'); end;
procedure TTestSSExchParser.Test_Misc_12; begin RunTest('1 10 2',                '2..10.'); end;
procedure TTestSSExchParser.Test_Misc_13; begin RunTest('1 10 2 OR',             '1..02.OR'); end;
procedure TTestSSExchParser.Test_Misc_14; begin RunTest('1 10 2 OR 20',          '1..20.OR'); end;
procedure TTestSSExchParser.Test_Misc_15; begin RunTest('1 10 2 20',             '2..20.'); end;
procedure TTestSSExchParser.Test_Misc_16; begin RunTest('1 10 2 20 3',           '3..20.'); end;
procedure TTestSSExchParser.Test_Misc_17; begin RunTest('1 10 2 20 3 30',        '3..30.'); end;
procedure TTestSSExchParser.Test_Misc_18; begin RunTest('1 10 2 20 3 OR',        '2..03.OR'); end;
procedure TTestSSExchParser.Test_Misc_19; begin RunTest('1 10 2 20 3 OR 30',     '2..30.OR'); end;
procedure TTestSSExchParser.Test_Misc_20; begin RunTest('1 10 2 OR 20 3',        '3..20.OR'); end;
procedure TTestSSExchParser.Test_Misc_21; begin RunTest('1 10 2 OR 20 3 30',     '3..30.OR'); end;
procedure TTestSSExchParser.Test_Misc_22; begin RunTest('1 10 2 20 OR 3 30',     '3..30.OR'); end;
procedure TTestSSExchParser.Test_Misc_23; begin RunTest('1 10 2 20 3 OR 30',     '2..30.OR'); end;
procedure TTestSSExchParser.Test_Misc_24; begin RunTest('10 1 20 2 OR 30 3',     '3..30.OR'); end;
procedure TTestSSExchParser.Test_Misc_25; begin RunTest('OR 1 10 2 20 ID 3 30',  '3..30.ID'); end;
procedure TTestSSExchParser.Test_Misc_26; begin RunTest('10 1 20 2 A 30 3',      '3.A.30.'); end;
procedure TTestSSExchParser.Test_Misc_27; begin RunTest('OR 1 10 2 20 A 3 30',   '3.A.30.OR'); end;
procedure TTestSSExchParser.Test_Misc_28; begin RunTest('1 10 2 20 OR A 3 30',   '3.A.30.OR'); end;
procedure TTestSSExchParser.Test_Misc_29; begin RunTest('1 10 2 20 3 OR 30 A',   '30.A.03.OR'); end;
procedure TTestSSExchParser.Test_Misc_31; begin RunTest('A',             '0.A..-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Misc_32; begin RunTest('A 10',          '0.A.10.'); end;
procedure TTestSSExchParser.Test_Misc_33; begin RunTest('A 10 20',       '10.A.20.'); end;
procedure TTestSSExchParser.Test_Misc_34; begin RunTest('A 10 B 20',     '10.B.20.'); end;
procedure TTestSSExchParser.Test_Misc_35; begin RunTest('A 10 20 B',     '20.B.10.'); end;
procedure TTestSSExchParser.Test_Misc_40; begin RunTest('ID',            '0...ID-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Misc_41; begin RunTest('ID 10',         '0..10.ID'); end;
procedure TTestSSExchParser.Test_Misc_42; begin RunTest('ID 10 20',      '10..20.ID'); end;
procedure TTestSSExchParser.Test_Misc_43; begin RunTest('ID 10 A 20',    '10.A.20.ID'); end;
procedure TTestSSExchParser.Test_Misc_44; begin RunTest('ID 10 20 A',    '20.A.10.ID'); end;
procedure TTestSSExchParser.Test_Misc_50; begin RunTest('  ',            '0...-Missing/Invalid Serial Number'); end;
procedure TTestSSExchParser.Test_Misc_51; begin RunTest('20 ID 10 A  ',  '10.A.20.ID'); end;
procedure TTestSSExchParser.Test_Misc_52; begin RunTest('  20 ID 10 A',  '10.A.20.ID'); end;
procedure TTestSSExchParser.Test_Misc_53; begin RunTest('  20 ID 10 A  ','10.A.20.ID'); end;
procedure TTestSSExchParser.Test_Misc_54; begin RunTest('12 111 OR',     '0..12.'); end;
procedure TTestSSExchParser.Test_Misc_60; begin RunTest('W7SST ID 10 A 20',           '10.A.20.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_61; begin RunTest('ID W7SST 10 A 20',           '10.A.20.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_62; begin RunTest('ID 10 W7SST A 20',           '10.A.20.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_63; begin RunTest('ID 10 A W7SST 20',           '10.A.20.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_64; begin RunTest('ID 10 A 20 W7SST',           '10.A.20.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_65; begin RunTest('W7SST OR 1 10 2 20 ID 3 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_66; begin RunTest('OR W7SST 1 10 2 20 ID 3 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_67; begin RunTest('OR 1 W7SST 10 2 20 ID 3 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_68; begin RunTest('OR 1 10 W7SST 2 20 ID 3 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_69; begin RunTest('OR 1 10 2 W7SST 20 ID 3 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_70; begin RunTest('OR 1 10 2 20 W7SST ID 3 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_71; begin RunTest('OR 1 10 2 20 ID W7SST 3 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_72; begin RunTest('OR 1 10 2 20 ID 3 W7SST 30', '3..30.ID.W7SST'); end;
procedure TTestSSExchParser.Test_Misc_73; begin RunTest('OR 1 10 2 20 ID 3 30 W7SST', '3..30.ID.W7SST'); end;

{ ErrorCheck tests for TTestSSExchParser }
procedure TTestSSExchParser.Test_Err_Invalid_01;  begin ErrorCheck('',              'Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_01;    begin ErrorCheck('A 72 OR EX',    'Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_02;    begin ErrorCheck('A B 72 OR',     'Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_03;    begin ErrorCheck('123 A 72 OR EX','Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_04;    begin ErrorCheck('123 A 72 OR WWA','Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_05;    begin ErrorCheck('123 A 72 OR 56','Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_06;    begin ErrorCheck('123 A B 72 OR', 'Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_07;    begin ErrorCheck('A B 72 OR',     'Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Extra_08;    begin ErrorCheck('A B 72 OR ID',  'Invalid exchange'); end;
procedure TTestSSExchParser.Test_Err_Missing_01;  begin ErrorCheck('OR',            'missing Precedence'); end;
procedure TTestSSExchParser.Test_Err_Missing_02;  begin ErrorCheck('72 OR',         'missing Precedence'); end;
procedure TTestSSExchParser.Test_Err_Missing_11;  begin ErrorCheck('A',             'missing Check'); end;
procedure TTestSSExchParser.Test_Err_Missing_12;  begin ErrorCheck('A OR',          'missing Check'); end;
procedure TTestSSExchParser.Test_Err_Missing_13;  begin ErrorCheck('123 A OR',      'missing Check'); end;
procedure TTestSSExchParser.Test_Err_Missing_14;  begin ErrorCheck('123 A',         'missing Check'); end;
procedure TTestSSExchParser.Test_Err_Missing_21;  begin ErrorCheck('A 72',          'missing Section'); end;
procedure TTestSSExchParser.Test_Err_Missing_22;  begin ErrorCheck('123 A 72',      'missing Section'); end;
procedure TTestSSExchParser.Test_Err_Invalid_11;  begin ErrorCheck('NN A 123 OR',   'invalid Number'); end;
procedure TTestSSExchParser.Test_Err_Invalid_21;  begin ErrorCheck('C 1 OR',        'invalid Precedence'); end;
procedure TTestSSExchParser.Test_Err_Invalid_22;  begin ErrorCheck('123 C 123 OR',  'invalid Precedence'); end;
procedure TTestSSExchParser.Test_Err_Invalid_23;  begin ErrorCheck('123 xxA 123 OR','invalid Precedence'); end;
procedure TTestSSExchParser.Test_Err_Invalid_31;  begin ErrorCheck('A 1 OR',        'invalid Check'); end;
procedure TTestSSExchParser.Test_Err_Invalid_32;  begin ErrorCheck('A 1 OR',        'invalid Check'); end;
procedure TTestSSExchParser.Test_Err_Invalid_33a; begin ErrorCheck('A 123 OR',      'invalid Check'); end;
procedure TTestSSExchParser.Test_Err_Invalid_33b; begin ErrorCheck('A 2024 OR',     'invalid Check'); end;
procedure TTestSSExchParser.Test_Err_Invalid_41;  begin ErrorCheck('A 72 OR1',      'invalid Section'); end;
procedure TTestSSExchParser.Test_Err_Invalid_42;  begin ErrorCheck('123 A 72 1OR',  'invalid Section'); end;
procedure TTestSSExchParser.Test_Err_Invalid_43;  begin ErrorCheck('A 72 222',      'invalid Section'); end;
procedure TTestSSExchParser.Test_Err_Invalid_44a; begin ErrorCheck('123 A 72 222',  'invalid Section'); end;
procedure TTestSSExchParser.Test_Err_Invalid_44b; begin ErrorCheck('A 72 XYZZY',    'invalid Section'); end;

{ ---------------------------------------------------------------------------
  TTestMySSExch
  --------------------------------------------------------------------------- }

procedure TTestMySSExch.SetUp;
begin
  parser := TMyExchParser.Create;
end;

procedure TTestMySSExch.TearDown;
begin
  FreeAndNil(parser);
end;

procedure TTestMySSExch.RunTest1(const AExchange, AExpected: string);
var
  R: boolean;
begin
  R := parser.ParseMyExch(AExchange);
  AssertTrue(Format('Input="%s" expecting "%s"', [AExchange, AExpected]), R);
end;

procedure TTestMySSExch.RunErrorCheck(const AMyExchange, AExpected: string);
var
  R: boolean;
begin
  R := parser.ParseMyExch(AMyExchange);
  AssertFalse(Format('Expected "%s" to fail', [AMyExchange]), R);
  AssertTrue(Format('ErrorStr="%s" should contain "%s"', [parser.ErrorStr, AExpected.Trim]),
             Pos(AExpected.Trim, parser.ErrorStr) > 0);
end;

{ General tests }
procedure TTestMySSExch.Test_General_1; begin RunTest1('A 72 OR',     'A 72 OR'); end;
procedure TTestMySSExch.Test_General_2; begin RunTest1('123 A 72 OR', '123 A 72 OR'); end;
procedure TTestMySSExch.Test_General_3; begin RunTest1('22A 72OR',    '22A 72 OR'); end;
procedure TTestMySSExch.Test_General_4; begin RunTest1('22 A 72OR',   '22A 72 OR'); end;
procedure TTestMySSExch.Test_General_5; begin RunTest1('# A 72 OR',   '# A 72 OR'); end;
procedure TTestMySSExch.Test_General_6; begin RunTest1('#A 72 OR',    '#A 72 OR'); end;

{ Error tests }
procedure TTestMySSExch.Test_Error_Invalid_01;  begin RunErrorCheck('',              'Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_01;    begin RunErrorCheck('A 72 OR EX',    'Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_02;    begin RunErrorCheck('A B 72 OR',     'Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_03;    begin RunErrorCheck('123 A 72 OR EX','Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_04;    begin RunErrorCheck('123 A 72 OR WWA','Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_05;    begin RunErrorCheck('123 A 72 OR 56','Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_06;    begin RunErrorCheck('123 A B 72 OR', 'Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_07;    begin RunErrorCheck('A B 72 OR',     'Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Extra_08;    begin RunErrorCheck('A B 72 OR ID',  'Invalid exchange'); end;
procedure TTestMySSExch.Test_Error_Missing_01;  begin RunErrorCheck('OR',            'missing Precedence'); end;
procedure TTestMySSExch.Test_Error_Missing_02;  begin RunErrorCheck('72 OR',         'missing Precedence'); end;
procedure TTestMySSExch.Test_Error_Missing_11;  begin RunErrorCheck('A',             'missing Check'); end;
procedure TTestMySSExch.Test_Error_Missing_12;  begin RunErrorCheck('A OR',          'missing Check'); end;
procedure TTestMySSExch.Test_Error_Missing_13;  begin RunErrorCheck('123 A OR',      'missing Check'); end;
procedure TTestMySSExch.Test_Error_Missing_14;  begin RunErrorCheck('123 A',         'missing Check'); end;
procedure TTestMySSExch.Test_Error_Missing_21;  begin RunErrorCheck('A 72',          'missing Section'); end;
procedure TTestMySSExch.Test_Error_Missing_22;  begin RunErrorCheck('123 A 72',      'missing Section'); end;
procedure TTestMySSExch.Test_Error_Invalid_11;  begin RunErrorCheck('NN A 123 OR',   'invalid Number'); end;
procedure TTestMySSExch.Test_Error_Invalid_21;  begin RunErrorCheck('C 1 OR',        'invalid Precedence'); end;
procedure TTestMySSExch.Test_Error_Invalid_22;  begin RunErrorCheck('123 C 123 OR',  'invalid Precedence'); end;
procedure TTestMySSExch.Test_Error_Invalid_23;  begin RunErrorCheck('123 xxA 123 OR','invalid Precedence'); end;
procedure TTestMySSExch.Test_Error_Invalid_31;  begin RunErrorCheck('A 1 OR',        'invalid Check'); end;
procedure TTestMySSExch.Test_Error_Invalid_32;  begin RunErrorCheck('A 1 OR',        'invalid Check'); end;
procedure TTestMySSExch.Test_Error_Invalid_33a; begin RunErrorCheck('A 123 OR',      'invalid Check'); end;
procedure TTestMySSExch.Test_Error_Invalid_33b; begin RunErrorCheck('A 2024 OR',     'invalid Check'); end;
procedure TTestMySSExch.Test_Error_Invalid_41;  begin RunErrorCheck('A 72 OR1',      'invalid Section'); end;
procedure TTestMySSExch.Test_Error_Invalid_42;  begin RunErrorCheck('123 A 72 1OR',  'invalid Section'); end;
procedure TTestMySSExch.Test_Error_Invalid_43;  begin RunErrorCheck('A 72 222',      'invalid Section'); end;
procedure TTestMySSExch.Test_Error_Invalid_44a; begin RunErrorCheck('123 A 72 222',  'invalid Section'); end;
procedure TTestMySSExch.Test_Error_Invalid_44b; begin RunErrorCheck('A 72 XYZZY',    'invalid Section'); end;

initialization
  RegisterTest(TTestSSExchParser);
  RegisterTest(TTestMySSExch);

end.
