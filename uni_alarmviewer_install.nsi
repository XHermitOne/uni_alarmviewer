; uni_alarmviewer_install.nsi
;--------------------------------

; ����������� ��������� ���������� ����
!include nsDialogs.nsh
!include LogicLib.nsh

; ������������ �����������
Name "������� ������������ � �������������� ������. ������ �� ${__DATE__}"

; ���������� ������
Icon "uni_alarmviewer.ico"

; �������������� ����
OutFile "uni_alarmviewer-setup.exe"

; �������������� ����������
InstallDir "c:\uni_alarmviewer\"

; ���� ������� ��� �������� ���������� (���� �� ������������� �����,  ��
; ������ ����� ����� �������� ������ �������������)
InstallDirRegKey HKLM SOFTWARE\uni_alarmviewer "Install_Dir"

; �����, ������������ ������������ ������ �������
ComponentText "���������� ������� ������������ � �������������� ������"

; ����� ��� ������ ����� ����������
DirText "�������������� �����:"

; ����� XP
XPStyle on

; �������� �����������
Page components ;�������� ������ ������������� ������� �� �������
Page instfiles ;�������� ���������� ��������� ������
Page custom nsDialogsPage nsDialogsPageLeave ;�������������� �������� ���������������� ��������

; �������� ���������� ������� ���������
Var DIALOG_SETTINGS
Var LABEL_LOG_DB_FILENAME
Var EDIT_LOG_DB_FILENAME
Var CHECKBOX_AUTOSTART


; === ������� ===
Function nsDialogsPage

    nsDialogs::Create 1018
    Pop $DIALOG_SETTINGS
    ${If} $DIALOG_SETTINGS == error
          Abort
    ${EndIf}

    GetFunctionAddress $0 OnBack
    nsDialogs::OnBack $0

    ${NSD_CreateLabel} 0 0 100% 12u "��� ����� �� SQLite ������� ������:"
    Pop $LABEL_LOG_DB_FILENAME
    
    ${NSD_CreateText} 0 20 100% 12u Y:\alarm_log.db
    Pop $EDIT_LOG_DB_FILENAME

    ${NSD_CreateCheckbox} 0 50 100% 8u "���������� ��� ������� �� Windows"
    Pop $CHECKBOX_AUTOSTART
    GetFunctionAddress $0 OnCheckboxAutostart
    nsDialogs::OnClick $CHECKBOX_AUTOSTART $0

    nsDialogs::Show

FunctionEnd

Function nsDialogsPageLeave

    ; ��������� � INI ����� ���������
    ${NSD_GetText} $EDIT_LOG_DB_FILENAME $0
    WriteINIStr "$INSTDIR\settings.ini" "OPTIONS" "log_filename" "$0"

FunctionEnd

Function OnBack

    MessageBox MB_YESNO "���������� ���������?" IDYES +2
    Abort

FunctionEnd

Function OnCheckboxAutostart
    Pop $0 # HWND
    CreateShortCut "$SMSTARTUP\uni_alarmviewer.lnk" "$INSTDIR\uni_alarmviewer.exe"
FunctionEnd

; === ������ ��� ����������� ===
; --- ������������ ������ ---
Section "������� ������������ � �������������� ������ <UNI_ALARMVIEWER>"

  ; ���������� �������� ���� � �������� ���������.
  SetOutPath $INSTDIR

  File "README.md"
  File "LICENSE"

  ; ����������� ���� 
  File "uni_alarmchecker.exe"
  ; ����������� ������
  File "uni_alarmchecker.ico"
  ;File "uni_alarmchecker.res"

  ; ����������� ���� 
  File "uni_alarmviewer.exe"
  ; ����������� ������
  File "uni_alarmviewer.ico"
  ;File "uni_alarmchecker.res"

  CopyFiles /FILESONLY "$EXEDIR\*.wav" "$INSTDIR"
  
  ; ����� ���������
  CopyFiles /FILESONLY "$EXEDIR\*.ini" "$INSTDIR"
  CopyFiles /FILESONLY "$EXEDIR\*.txt" "$INSTDIR"

  ; ������� ��������� ������������
  WriteUninstaller $INSTDIR\uninstall.exe

SectionEnd


Section "��������� ����������"
  ; ����������� *.dll � system32
  CopyFiles /FILESONLY "$EXEDIR\sqlite3.dll" "$SYSDIR"
SectionEnd


; �������������� ������ (����� ���� �������� �������������)
;--------------------------------
; ������������

UninstallText "������������ �������  ������������ � �������������� ������ <UNI_ALARMVIEWER>. ������� Next ��� �����������."

Section "Uninstall"

  ; ������� �������������� �����
  RMDir /r "$INSTDIR"

  Delete "$SMSTARTUP\uni_alarmviewer.lnk"  

  MessageBox MB_OK "������������ UNI_ALARMVIEWER ��������� �������"

SectionEnd
