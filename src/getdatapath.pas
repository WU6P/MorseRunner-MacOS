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
  AppSupportDir: string;
begin
  // macOS standard: store user files in ~/Library/Application Support/MorseRunner/
  // This avoids the "access Documents folder" permission prompt
  AppSupportDir := GetEnvironmentVariable('HOME') + '/Library/Application Support/MorseRunner/';

  // Create directory if it doesn't exist
  if not DirectoryExists(AppSupportDir) then
    ForceDirectories(AppSupportDir);

  Result := AppSupportDir;
end;

end.
