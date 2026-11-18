; Copyright (c) 2022 TAOS Data, Inc. <jhtao@taosdata.com>
;
; SPDX-License-Identifier: AGPL-3.0-or-later
;
; This program is free software: you can use, redistribute, and/or modify
; it under the terms of the GNU Affero General Public License, version 3
; or later ("AGPL"), as published by the Free Software Foundation.
;
; This program is distributed in the hope that it will be useful, but WITHOUT
; ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
; FITNESS FOR A PARTICULAR PURPOSE.
;
; You should have received a copy of the GNU Affero General Public License
; along with this program. If not, see <http://www.gnu.org/licenses/>.

#define MyAppName "TDengine"
#define MyAppPublisher "taosdata"
#define MyAppURL "http://www.taosdata.com/"
#define MyAppBeforeInstallTxt "windows_before_install.txt"
#define MyAppIco "favicon.ico"
#define MyAppInstallDir "C:\TDengine"
#define MyAppOutputDir "./"
#define MyAppSourceDir "C:\TDengine"
;#define MyAppAllFile "\*"
#define MyAppCfgName "\cfg\*"
#define MyAppDriverName "\driver\*"
#define MyAppConnectorName "\connector\*"
#define MyAppExamplesName "\examples\*"
#define MyAppIncludeName "\include\*"
#define MyAppExeName "\*.exe"
#define MyAppTaosExeName "\taos.bat"
#define MyAppTaosdemoExeName "\taosBenchmark.exe"
#define MyAppDLLName "\*.dll"
#define MyStartMenuGroupName "TDengine TSDB Client"
;#define MyAppVersion "3.0"
;#define MyAppInstallName "TDengine"
[Setup]
VersionInfoVersion={#MyAppVersion}
AppId={{A0F7A93C-79C4-485D-B2B8-F0D03DF42FAB}
AppName={#CusName}
AppVersion={#MyAppVersion}
;AppVerName={#MyAppName} {#MyAppVersion}
AppPublisher={#MyAppPublisher}
AppPublisherURL={#MyAppURL}
AppSupportURL={#MyAppURL}
AppUpdatesURL={#MyAppURL}
DefaultDirName={#MyAppInstallDir}
DefaultGroupName={#MyStartMenuGroupName}
DisableProgramGroupPage=yes
UsePreviousGroup=no
InfoBeforeFile={#MyAppBeforeInstallTxt}
OutputDir={#MyAppOutputDir}
OutputBaseFilename={#MyAppInstallName}
SetupIconFile={#MyAppIco}
UninstallDisplayIcon={app}\include\favicon.ico
Compression=lzma
SolidCompression=yes
DisableDirPage=no
UsePreviousAppDir=yes
Uninstallable=yes
ArchitecturesAllowed=x64
ArchitecturesInstallIn64BitMode=x64

[Languages]
Name: "chinesesimp"; MessagesFile: "compiler:Default.isl"
;Name: "english"; MessagesFile: "compiler:Languages\English.isl"

[Files]
#ifexist "vc_redist_files.issinc"
#include "vc_redist_files.issinc"
#else
#ifexist "..\..\..\taos-internal\packaging\vc_redist_files.issinc"
#include "..\..\..\taos-internal\packaging\vc_redist_files.issinc"
#else
#include "..\..\..\enterprise\packaging\vc_redist_files.issinc"
#endif
#endif
;Source: {#MyAppSourceDir}{#MyAppAllFile}; DestDir: "{app}"; Flags: igNoreversion recursesubdirs createallsubdirs 
Source: taos.bat; DestDir: "{app}\include"; Flags: igNoreversion;
;Source: taosdemo.png; DestDir: "{app}\include"; Flags: igNoreversion;
;Source: taosShell.png; DestDir: "{app}\include"; Flags: igNoreversion;
Source: favicon.ico; DestDir: "{app}\include"; Flags: igNoreversion;
Source: {#MyAppSourceDir}{#MyAppDLLName}; DestDir: "{win}\System32"; Flags: igNoreversion recursesubdirs createallsubdirs 64bit;Check:IsWin64;
Source: {#MyAppSourceDir}{#MyAppCfgName}; DestDir: "{app}\cfg"; Flags: igNoreversion recursesubdirs createallsubdirs onlyifdoesntexist uninsneveruninstall
Source: {#MyAppSourceDir}{#MyAppDriverName}; DestDir: "{app}\driver"; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}{#MyAppDLLName}; DestDir: "{app}\driver"; Flags: igNoreversion
; ODBC driver files are only staged when TD_BUILD_WITH_ODBC=ON; community
; Windows builds do not ship them, so skip the taos_odbc payload.
;Source: {#MyAppSourceDir}\taos_odbc\*; DestDir: "{app}\taos_odbc"; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}\*.dll; DestDir: "{app}"; Flags: igNoreversion recursesubdirs createallsubdirs
;Source: {#MyAppSourceDir}{#MyAppConnectorName}; DestDir: "{app}\connector"; Flags: igNoreversion recursesubdirs createallsubdirs
;Source: {#MyAppSourceDir}{#MyAppExamplesName}; DestDir: "{app}\examples"; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}{#MyAppIncludeName}; DestDir: "{app}\include"; Excludes: "taos.bat"; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}{#MyAppExeName}; DestDir: "{app}"; Excludes: {#MyAppExcludeSource} ; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}{#MyAppTaosdemoExeName}; DestDir: "{app}"; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}\taos.exe; DestDir: "{app}"; DestName: "{#CusPrompt}.exe"; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}\taosBenchmark.exe; DestDir: "{app}"; DestName: "{#CusPrompt}Benchmark.exe"; Flags: igNoreversion recursesubdirs createallsubdirs
Source: {#MyAppSourceDir}\taosdump.exe; DestDir: "{app}"; DestName: "{#CusPrompt}dump.exe"; Flags: igNoreversion recursesubdirs createallsubdirs


[run]
; Register the Windows services. taosd needs --win_service so it dispatches
; through the SCM; taosAdapter's service entry point is unconditional.
; Both are installed as DEMAND (manual) start, matching make_install.bat, so a
; fresh install does not begin serving until the user runs `sc start taosd`.
; The client package excludes these executables, so the FileExists() guard
; keeps it from registering services that point at missing files.
; An existing service is re-pointed at the install directory instead of
; failing to be created, which keeps upgrades working when it moves.
Filename: {sys}\sc.exe; Parameters: "create taosd start= DEMAND binPath= ""{app}\taosd.exe --win_service"""; Flags: runhidden; Check: ServiceNeedsCreate('taosd')
Filename: {sys}\sc.exe; Parameters: "config taosd binPath= ""{app}\taosd.exe --win_service"""; Flags: runhidden; Check: ServiceNeedsRepoint('taosd')
Filename: {sys}\sc.exe; Parameters: "create taosadapter start= DEMAND binPath= ""{app}\taosadapter.exe"""; Flags: runhidden; Check: ServiceNeedsCreate('taosadapter')
Filename: {sys}\sc.exe; Parameters: "config taosadapter binPath= ""{app}\taosadapter.exe"""; Flags: runhidden; Check: ServiceNeedsRepoint('taosadapter')
; ODBC registration runs only when the taos_odbc payload is present (see the
; commented [Files] entry above); community builds without ODBC skip it.
;Filename: "C:\Windows\System32\odbcconf.exe"; Parameters: "/S /F win_odbc_install.ini"; WorkingDir: "{app}\taos_odbc\x64"; Flags: runhidden; StatusMsg: "Configuring ODBC x64"
;Filename: "C:\Windows\SysWOW64\odbcconf.exe"; Parameters: "/S /F win_odbc_install.ini"; WorkingDir: "{app}\taos_odbc\x86"; Flags: runhidden; StatusMsg: "Configuring ODBC x86"

[UninstallRun]
; Stop before delete; both are ignored when the service was never created
; (client package) or is already stopped. --win_service makes taosd answer the
; SCM stop control, so `sc stop` actually returns.
RunOnceId: "stoptaosd"; Filename: {sys}\sc.exe; Parameters: "stop taosd"; Flags: runhidden
RunOnceId: "stoptaosadapter"; Filename: {sys}\sc.exe; Parameters: "stop taosadapter"; Flags: runhidden
RunOnceId: "deltaosd"; Filename: {sys}\sc.exe; Parameters: "delete taosd"; Flags: runhidden
RunOnceId: "deltaosadapter"; Filename: {sys}\sc.exe; Parameters: "delete taosadapter"; Flags: runhidden

[Registry]
Root: HKLM; Subkey: "SYSTEM\CurrentControlSet\Control\Session Manager\Environment"; \
    ValueType: expandsz; ValueName: "Path"; ValueData: "{olddata};{app}"; \
    Check: NeedsAddPath(ExpandConstant('{app}'))

[Code]
#ifexist "vc_redist_code.issinc"
#include "vc_redist_code.issinc"
#else
#ifexist "..\..\..\taos-internal\packaging\vc_redist_code.issinc"
#include "..\..\..\taos-internal\packaging\vc_redist_code.issinc"
#else
#include "..\..\..\enterprise\packaging\vc_redist_code.issinc"
#endif
#endif

function InitializeSetup(): Boolean;
begin
  Result := EnsureVCRuntime();
end;
function NeedsAddPath(Param: string): boolean;
var
  OrigPath: string;
begin
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    Result := True;
    exit;
  end;
  { look for the path with leading and trailing semicolon }
  { Pos() returns 0 if not found }
  Result := Pos(';' + Param + ';', ';' + OrigPath + ';') = 0;
end;

{ Windows service helpers. The client package ships without taosd.exe and
  taosadapter.exe, so every registration is gated on the executable being
  present in the install directory. }

function ServiceExists(Name: String): Boolean;
var
  DisplayName: String;
begin
  Result := RegQueryStringValue(HKLM, 'SYSTEM\CurrentControlSet\Services\' + Name, 'DisplayName', DisplayName);
end;

function ServiceNeedsCreate(Name: String): Boolean;
var
  Exe: String;
begin
  if Name = 'taosd' then
    Exe := ExpandConstant('{app}\taosd.exe')
  else
    Exe := ExpandConstant('{app}\taosadapter.exe');
  Result := FileExists(Exe) and (not ServiceExists(Name));
end;

function ServiceNeedsRepoint(Name: String): Boolean;
begin
  { create ran above when the exe is present; config is only needed when the
    service survived from an earlier installation at a different directory. }
  Result := FileExists(ExpandConstant('{app}\' + Name + '.exe')) and ServiceExists(Name);
end;

function RemovePath(Param: string): Boolean;
var
  OrigPath: string;
  NewPath: string;
begin
  Result := True;
  if not RegQueryStringValue(HKEY_LOCAL_MACHINE,
    'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
    'Path', OrigPath)
  then begin
    exit;
  end;

  NewPath := ';' + OrigPath + ';';
  while StringChangeEx(NewPath, ';' + Param + ';', ';', True) > 0 do
  begin
  end;
  while StringChangeEx(NewPath, ';;', ';', True) > 0 do
  begin
  end;
  if (Length(NewPath) > 0) and (Copy(NewPath, 1, 1) = ';') then
    Delete(NewPath, 1, 1);
  if (Length(NewPath) > 0) and (Copy(NewPath, Length(NewPath), 1) = ';') then
    Delete(NewPath, Length(NewPath), 1);

  if NewPath <> OrigPath then
    Result := RegWriteExpandStringValue(HKEY_LOCAL_MACHINE,
      'SYSTEM\CurrentControlSet\Control\Session Manager\Environment',
      'Path', NewPath);
end;

var
  ExistingInstallDir: String;

function GetExistingInstallDir: String;
var
  AppPath: String;
begin
  Result := '';
  if RegQueryStringValue(HKEY_LOCAL_MACHINE, 'SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{A0F7A93C-79C4-485D-B2B8-F0D03DF42FAB}_is1', 'Inno Setup: App Path', AppPath) and DirExists(AppPath) then
    Result := RemoveBackslashUnlessRoot(AppPath);
end;

function NormalizeInstallDir(InstallDir: string): string;
begin
  InstallDir := RemoveBackslashUnlessRoot(InstallDir);
  if CompareText(ExtractFileName(InstallDir), 'TDengine') = 0 then
    Result := InstallDir
  else
    Result := AddBackslash(InstallDir) + 'TDengine';
end;

procedure NormalizeInstallDirectory;
begin
  if WizardForm.DirEdit.Text <> '' then
    WizardForm.DirEdit.Text := NormalizeInstallDir(WizardForm.DirEdit.Text);
end;

function NextButtonClick(CurPageID: Integer): Boolean;
begin
  if CurPageID = wpSelectDir then
    NormalizeInstallDirectory;
  Result := True;
end;

function PrepareToInstall(var NeedsRestart: Boolean): String;
begin
  NormalizeInstallDirectory;
  if (ExistingInstallDir <> '') and (CompareText(WizardDirValue(), ExistingInstallDir) <> 0) then
  begin
    Result := 'An existing TDengine installation was found at ' + ExistingInstallDir + '.' + #13#10 + #13#10 + 'To prevent PATH and configuration conflicts, this upgrade must use the existing installation directory.';
    exit;
  end;
  if ExistingInstallDir <> '' then WizardForm.DirEdit.Text := ExistingInstallDir;
  Result := '';
end;

procedure InitializeWizard;
begin
  ExistingInstallDir := GetExistingInstallDir();
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if (CurPageID = wpSelectDir) and (ExistingInstallDir <> '') then
  begin
    WizardForm.DirEdit.Text := ExistingInstallDir;
    WizardForm.DirEdit.Enabled := False;
    WizardForm.DirBrowseButton.Enabled := False;
  end;
end;

function DeleteOdbcDsnRegistry: Boolean;
begin
  RegDeleteKeyIncludingSubkeys(HKCU, 'SOFTWARE\ODBC\ODBC.INI\TAOS_ODBC_DSN');  
  RegDeleteKeyIncludingSubkeys(HKCU, 'SOFTWARE\ODBC\ODBC.INI\TAOS_ODBC_WS_DSN')

  RegDeleteValue(HKCU, 'SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources', 'TAOS_ODBC_DSN'); 
  RegDeleteValue(HKCU, 'SOFTWARE\ODBC\ODBC.INI\ODBC Data Sources', 'TAOS_ODBC_WS_DSN'); 

  Result := True;
end;

function DeleteOdbcDriverRegistry: Boolean;
begin
  // Delete 64-bit ODBC driver registry 
  RegDeleteKeyIncludingSubkeys(HKLM64, 'SOFTWARE\ODBC\ODBCINST.INI\TAOS_ODBC_DRIVER');    
  RegDeleteValue(HKLM64, 'SOFTWARE\ODBC\ODBCINST.INI\ODBC Drivers', 'TAOS_ODBC_DRIVER');

  // Delete 32-bit ODBC driver registry 
  RegDeleteKeyIncludingSubkeys(HKLM64, 'SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\TAOS_ODBC_DRIVER');
  RegDeleteValue(HKLM64, 'SOFTWARE\Wow6432Node\ODBC\ODBCINST.INI\ODBC Drivers', 'TAOS_ODBC_DRIVER');

  Result := True;
end;


procedure DeinitializeUninstall();
begin
	DeleteOdbcDsnRegistry();
	DeleteOdbcDriverRegistry();
  RemovePath(ExpandConstant('{app}'));
end;

[InstallDelete]
; The legacy TDengine group belongs exclusively to previous TSDB packages.
Name: "{commonprograms}\TDengine"; Type: filesandordirs

[UninstallDelete]
Name: {app}\driver; Type: filesandordirs 
Name: {app}\connector; Type: filesandordirs
Name: {app}\examples; Type: filesandordirs
Name: {app}\include; Type: filesandordirs

[Tasks]
Name: "desktopicon";Description: "{cm:CreateDesktopIcon}"; GroupDescription:"{cm:AdditionalIcons}"; Flags: checkablealone

[Icons]
Name:"{group}\Taos Shell"; Filename: "{app}\include\{#MyAppTaosExeName}" ; Parameters: "taos.exe" ; IconFilename: "{app}\include\{#MyAppIco}"
Name:"{group}\Installation Folder"; Filename: "{app}\"
Name:"{group}\taosBenchmark"; Filename: "{app}\include\{#MyAppTaosExeName}" ; Parameters: "taosBenchmark.exe" ; IconFilename: "{app}\include\{#MyAppIco}"
Name: "{group}\{cm:UninstallProgram,{#MyAppName}}"; Filename: "{uninstallexe}" ; IconFilename: "{app}\include\{#MyAppIco}"
Name:"{commondesktop}\Taos Shell"; Filename: "{app}\include\{#MyAppTaosExeName}" ; Parameters: "taos.exe" ; Tasks: desktopicon; WorkingDir: "{app}" ; IconFilename: "{app}\include\{#MyAppIco}" 


[Messages]
SelectDirLabel3=If the selected path does not end with TDengine, Setup creates a TDengine subdirectory there.
ConfirmUninstall=Do you really want to uninstall {#CusName} from your computer?%n%nPress [Y] to completely delete %1 and all its components;%nPress [N] to keep the software on your computer.
