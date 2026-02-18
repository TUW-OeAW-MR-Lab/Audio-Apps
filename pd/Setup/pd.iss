;ExpSuite pd & YAMI packages - software installer for ExpSuite applications
;Copyright (C) Acoustics Research Institute - Austrian Academy of Sciences
;Licensed under the EUPL, Version 1.2 or – as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "Licence")
;You may not use this work except in compliance with the Licence.
;You may obtain a copy of the Licence at: http://joinup.ec.europa.eu/software/page/eupl
;Unless required by applicable law or agreed to in writing, software distributed under the Licence is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
;See the Licence for the specific language governing  permissions and limitations under the Licence.

;****Preprocessor****
;See http://www.jrsoftware.org/ispphelp/
#define MyAppName "PD"
#define MyAppVersion "0.49"
#define MyAppExeName "My YAMI.bat"

[Setup]
AppId={{fec51a60-0f2e-4d72-86ef-ae2de0dbd3b4}
AppName={#MyAppName}
AppVersion={#MyAppVersion} & YAMI 1.4
;AppVerName={#MyAppName} {#MyAppVersion}
DefaultDirName={sd}\{#MyAppName}
DefaultGroupName={#MyAppName}
OutputBaseFilename=pd_setup
OutputDir=.\
Compression=lzma2/ultra64
SolidCompression=yes
SetupIconFile=..\tcl\pd.ico
UninstallDisplayIcon={app}\unins000.exe
ChangesAssociations=yes

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

;[Tasks]
;Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[Files]
Source: "..\*"; DestDir: "{app}"; Excludes: "\Setup,\flext,\extra\dyn~,\extra\vasp,\extra\zexy"; Flags: ignoreversion recursesubdirs createallsubdirs

[Icons]
Name: "{group}\..\ExpSuite\PD\{#MyAppName}"; Filename: "{app}\YAMI\My YAMI.bat"; WorkingDir: "{app}\YAMI\"
Name: "{group}\..\ExpSuite\PD\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}"
;Name: "{commondesktop}\{#MyAppName}"; Filename: "{app}\{#MyAppExeName}"; Tasks: desktopicon

;Creating this registries we link the app extension to the app we just installed. We also create and open connected registry. This registries will be deleted when uninstalling (Flag uninsdeletekey)
[Registry]
Root: HKCR; Subkey: ".{#MyAppName}"; ValueType: string; ValueData: "{#MyAppName}"; Flags: uninsdeletekey
Root: HKCR; Subkey: "{#MyAppName}"; ValueType: string; ValueData: "{#MyAppName} Files"; Flags: uninsdeletekey
Root: HKCR; Subkey: "{#MyAppName}\DefaultIcon"; ValueType: string; ValueName: ""; ValueData: """{app}\bin\{#MyAppName}.exe"",0"; Flags: uninsdeletekey
Root: HKCR; Subkey: "{#MyAppName}\shell\Open\command"; ValueType: string; ValueData: """{app}\bin\{#MyAppName}.exe"" ""%1"""; Flags: uninsdeletekey
;Root: HKCR; Subkey: "{#MyAppName}\shell\Open Connected\command"; ValueType: string; ValueData: """{app}\{#MyAppName}.exe"" ""%1""/C"; Flags: uninsdeletekey
;Root: HKCR; Subkey: "{#MyAppName}\DefaultIcon"; ValueType: string; ValueData: """{app}\bin\pd.exe"",0"; Flags: uninsdeletekey

[Run]
Filename: "{app}\YAMI\{#MyAppExeName}"; Description: "{cm:LaunchProgram,{#StringChange(MyAppName, "&", "&&")}}"; Flags: shellexec postinstall skipifsilent

[Code]
function NextButtonClick(CurPageID: Integer): Boolean;
begin
Result := True;
if CurPageID = wpSelectDir then
  begin
  if Pos(' ',expandconstant('{app}'))<> 0 then
    begin
    if (MsgBox ('Dir path has spaces, this may cause problems while executing PD and YAMI'#13#13'Do you want to change it?', mbConfirmation, MB_YESNO)=idYes)=True then
      Result:= False;
    end;
  end;
end;


