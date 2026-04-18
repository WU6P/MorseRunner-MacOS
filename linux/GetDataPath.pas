unit GetDataPath;

{$ifdef FPC}{$MODE Delphi}{$endif}

interface

// Read-only data files (call lists, MASTER.DTA, etc.)
function GetDataPath: string;

// Writeable user files (INI, WAV, HST results)
function GetUserPath: string;

implementation

uses SysUtils;

function GetDataPath: string;
var
  AppDir, DataDir, ExeDir: string;
begin
  // Inside an AppImage, $APPDIR is set by the runtime to the squashfs mount root.
  // Data files are installed at $APPDIR/usr/share/MorseRunner/.
  AppDir := GetEnvironmentVariable('APPDIR');
  if AppDir <> '' then
  begin
    DataDir := AppDir + '/usr/share/MorseRunner/';
    if DirectoryExists(DataDir) then
    begin
      Result := DataDir;
      Exit;
    end;
  end;
  // Fallback: flat-zip layout — data files live next to the binary.
  ExeDir := ExtractFilePath(ParamStr(0));
  Result := ExeDir;
end;

function GetUserPath: string;
var
  DataHome, AppDir: string;
begin
  // XDG Base Directory: use $XDG_DATA_HOME/MorseRunner/
  // Falls back to ~/.local/share/MorseRunner/ if $XDG_DATA_HOME is unset.
  DataHome := GetEnvironmentVariable('XDG_DATA_HOME');
  if DataHome = '' then
    DataHome := GetEnvironmentVariable('HOME') + '/.local/share';

  AppDir := DataHome + '/MorseRunner/';

  if not DirectoryExists(AppDir) then
    ForceDirectories(AppDir);

  Result := AppDir;
end;

end.
