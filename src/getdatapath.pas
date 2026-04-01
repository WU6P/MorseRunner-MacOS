unit GetDataPath;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

// Read-only data files (call lists, MASTER.DTA, etc.)
function GetDataPath: string;

// Writeable user files (INI, WAV, HST results) - next to the .app or binary
function GetUserPath: string;

implementation

uses SysUtils;

function GetDataPath: string;
var
  ExeDir, ResourcesDir: string;
begin
  ExeDir := ExtractFilePath(ParamStr(0));
  // When inside a .app bundle: .app/Contents/MacOS/ → .app/Contents/Resources/
  ResourcesDir := ExeDir + '../Resources/';
  if DirectoryExists(ResourcesDir) then
    Result := ExpandFileName(ResourcesDir) + PathDelim
  else
    Result := ExeDir;
end;

function GetUserPath: string;
var
  ExeDir, AppBundle: string;
begin
  ExeDir := ExtractFilePath(ParamStr(0));
  // If inside .app bundle, place user files next to the .app folder
  AppBundle := ExpandFileName(ExeDir + '../../..');
  if ExtractFileExt(AppBundle) = '.app' then
    Result := ExtractFilePath(AppBundle)
  else
    Result := ExeDir;
end;

end.
