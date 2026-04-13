//------------------------------------------------------------------------------
//This Source Code Form is subject to the terms of the Mozilla Public
//License, v. 2.0. If a copy of the MPL was not distributed with this
//file, You can obtain one at http://mozilla.org/MPL/2.0/.
//------------------------------------------------------------------------------
// ContestFactory.pas — Instantiates the correct TContest subclass for a given
// TSimContest id.  Extracted from Main.pas so that the 11 contest-mode units
// (ARRLFD, NAQP, …) are NOT imported by Main.pas, breaking the chain that
// caused lazbuild to fail resolving them as implementation-uses dependencies.
//------------------------------------------------------------------------------
unit ContestFactory;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

uses
  Contest, Ini;

function CreateContest(AContestId: TSimContest): TContest;

implementation

uses
  ArrlFd, NaQp, CWOPS, CqWW, CqWpx, ArrlDx, CWSST, ALLJA, ACAG,
  IaruHf, ArrlSS;

function CreateContest(AContestId: TSimContest): TContest;
begin
  Result := nil;
  case AContestId of
    scWpx, scHst: Result := TCqWpx.Create;
    scCwt:        Result := TCWOPS.Create;
    scFieldDay:   Result := TArrlFieldDay.Create;
    scNaQp:       Result := TNcjNaQp.Create;
    scCQWW:       Result := TCqWW.Create;
    scArrlDx:     Result := TArrlDx.Create;
    scSst:        Result := TCWSST.Create;
    scAllJa:      Result := TALLJA.Create;
    scAcag:       Result := TACAG.Create;
    scIaruHf:     Result := TIaruHf.Create;
    scArrlSS:     Result := TSweepstakes.Create;
  else
    assert(false);
  end;
end;

end.
