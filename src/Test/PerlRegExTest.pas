// PerlRegExTest.pas — FPCUnit tests for TPerlRegEx and TPerlRegExList
// Ported from SSExchParserTest.pas Test3() and Test4() in the original DUnitX suite.
unit PerlRegExTest;
{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  fpcunit, testregistry, SysUtils, PerlRegEx;

type
  TTestPerlRegEx = class(TTestCase)
  published
    // Tests basic match/MatchAgain/GroupCount/Groups on a single regex
    procedure TestMatchAndGroups;
    // Tests TPerlRegExList: multiple regexes, earliest-match semantics
    procedure TestRegExList;
  end;

implementation

procedure TTestPerlRegEx.TestMatchAndGroups;
var
  Reg: TPerlRegEx;
begin
  Reg := TPerlRegEx.Create;
  try
    // Simple alternation
    Reg.RegEx  := '(A|B|C)';
    Reg.Compile;
    Reg.Subject := 'B';
    AssertTrue('Match should succeed', Reg.Match);
    AssertEquals('Groups[0] should be B', PCREString('B'), Reg.Groups[0]);

    // Named group and MatchAgain across a multi-char subject
    Reg.RegEx  := '((A)|(B)|(?P<c>C))';
    Reg.Subject := 'A';
    AssertTrue('Match A', Reg.Match);
    AssertEquals('GroupCount for A', 2, Reg.GroupCount);
    AssertEquals('Groups[0] for A', PCREString('A'), Reg.Groups[0]);
    AssertEquals('Groups[1] for A', PCREString('A'), Reg.Groups[1]);

    Reg.Subject := 'ABC';
    AssertTrue('Match ABC start', Reg.Match);
    AssertEquals('GroupCount after first match', 2, Reg.GroupCount);
    AssertEquals('Groups[0] after first match', PCREString('A'), Reg.Groups[0]);
    AssertEquals('Groups[1] after first match', PCREString('A'), Reg.Groups[1]);

    AssertTrue('MatchAgain → B', Reg.MatchAgain);
    AssertEquals('GroupCount after B match', 3, Reg.GroupCount);
    AssertEquals('Groups[0] for B', PCREString('B'), Reg.Groups[0]);
    AssertEquals('Groups[1] for B', PCREString('B'), Reg.Groups[1]);
    AssertEquals('Groups[2] for B (A arm, empty)', PCREString(''), Reg.Groups[2]);
    AssertEquals('Groups[3] for B', PCREString('B'), Reg.Groups[3]);
    AssertEquals('Groups[4] for B (c arm, empty)', PCREString(''), Reg.Groups[4]);
    AssertEquals('Named group c for B (empty)',
      PCREString(''), Reg.Groups[Reg.NamedGroup('c')]);

    AssertTrue('MatchAgain → C', Reg.MatchAgain);
    AssertEquals('GroupCount after C match', 4, Reg.GroupCount);
    AssertEquals('Groups[0] for C', PCREString('C'), Reg.Groups[0]);
    AssertEquals('Groups[1] for C', PCREString('C'), Reg.Groups[1]);
    AssertEquals('Groups[2] for C (A arm, empty)', PCREString(''), Reg.Groups[2]);
    AssertEquals('Groups[3] for C (B arm, empty)', PCREString(''), Reg.Groups[3]);
    AssertEquals('Groups[4] for C (named c)', PCREString('C'), Reg.Groups[4]);

    AssertFalse('Final MatchAgain should fail', Reg.MatchAgain);
  finally
    Reg.Free;
  end;
end;

procedure TTestPerlRegEx.TestRegExList;
var
  Reg1, Reg2, Reg3: TPerlRegEx;
  RegList: TPerlRegExList;
  MatchedReg: TPerlRegEx;
begin
  RegList := TPerlRegExList.Create;
  try
    Reg1 := TPerlRegEx.Create; Reg1.RegEx := 'A'; Reg1.Study;
    Reg2 := TPerlRegEx.Create; Reg2.RegEx := 'B'; Reg2.Study;
    Reg3 := TPerlRegEx.Create; Reg3.RegEx := 'C'; Reg3.Study;
    RegList.Add(Reg1);
    RegList.Add(Reg2);
    RegList.Add(Reg3);

    RegList.Subject := 'ABC';
    AssertTrue('Match a', RegList.Match);
    MatchedReg := RegList.MatchedRegEx;
    AssertTrue('MatchedText contains A',
      Pos(PCREString('A'), MatchedReg.MatchedText) > 0);
    AssertEquals('IndexOf Reg1', 0, RegList.IndexOf(MatchedReg));

    AssertTrue('MatchAgain b', RegList.MatchAgain);
    MatchedReg := RegList.MatchedRegEx;
    AssertTrue('MatchedText contains B',
      Pos(PCREString('B'), MatchedReg.MatchedText) > 0);
    AssertEquals('IndexOf Reg2', 1, RegList.IndexOf(MatchedReg));

    AssertTrue('MatchAgain c', RegList.MatchAgain);
    MatchedReg := RegList.MatchedRegEx;
    AssertTrue('MatchedText contains C',
      Pos(PCREString('C'), MatchedReg.MatchedText) > 0);
    AssertEquals('IndexOf Reg3', 2, RegList.IndexOf(MatchedReg));

    AssertFalse('Final MatchAgain should fail', RegList.MatchAgain);
  finally
    RegList.Clear;
    RegList.Free;
  end;
end;

initialization
  RegisterTest(TTestPerlRegEx);
end.
