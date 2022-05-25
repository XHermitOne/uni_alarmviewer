; uni_alarmviewer_install.nsi
;--------------------------------

; Подключение поддержки диалоговых окон
!include nsDialogs.nsh
!include LogicLib.nsh

; Наименование инсталятора
Name "Система отслеживания и журналирования аварий. Сборка от ${__DATE__}"

; Установить иконку
Icon "uni_alarmviewer.ico"

; Результирующий файл
OutFile "uni_alarmviewer-setup.exe"

; Инсталяционная директория
InstallDir "c:\uni_alarmviewer\"

; Ключ реестра для проверки директории (если вы инсталлируете снова,  то
; старые файлы будут заменены новыми автоматически)
InstallDirRegKey HKLM SOFTWARE\uni_alarmviewer "Install_Dir"

; Текст, предлагающий пользователю ввести каталог
ComponentText "Инсталяция системы отслеживания и журналирования аварий"

; Текст для выбора папки инсталяции
DirText "Инсталяционная папка:"

; Стиль XP
XPStyle on

; Страницы инсталятора
Page components ;Страница выбора инсталируемых пакетов по секциям
Page instfiles ;Страница инсталяции выбранных файлов
Page custom nsDialogsPage nsDialogsPageLeave ;Дополнительная страница пользовательских настроек

; Элементы управления диалога настройки
Var DIALOG_SETTINGS
Var LABEL_LOG_DB_FILENAME
Var EDIT_LOG_DB_FILENAME
Var CHECKBOX_AUTOSTART


; === Функции ===
Function nsDialogsPage

    nsDialogs::Create 1018
    Pop $DIALOG_SETTINGS
    ${If} $DIALOG_SETTINGS == error
          Abort
    ${EndIf}

    GetFunctionAddress $0 OnBack
    nsDialogs::OnBack $0

    ${NSD_CreateLabel} 0 0 100% 12u "Имя файла БД SQLite журнала аварий:"
    Pop $LABEL_LOG_DB_FILENAME
    
    ${NSD_CreateText} 0 20 100% 12u Y:\alarm_log.db
    Pop $EDIT_LOG_DB_FILENAME

    ${NSD_CreateCheckbox} 0 50 100% 8u "Автозапуск при запуске ОС Windows"
    Pop $CHECKBOX_AUTOSTART
    GetFunctionAddress $0 OnCheckboxAutostart
    nsDialogs::OnClick $CHECKBOX_AUTOSTART $0

    nsDialogs::Show

FunctionEnd

Function nsDialogsPageLeave

    ; Сохранить в INI файле настройки
    ${NSD_GetText} $EDIT_LOG_DB_FILENAME $0
    WriteINIStr "$INSTDIR\settings.ini" "OPTIONS" "log_filename" "$0"

FunctionEnd

Function OnBack

    MessageBox MB_YESNO "Прекратить настройку?" IDYES +2
    Abort

FunctionEnd

Function OnCheckboxAutostart
    Pop $0 # HWND
    CreateShortCut "$SMSTARTUP\uni_alarmviewer.lnk" "$INSTDIR\uni_alarmviewer.exe"
FunctionEnd

; === Пакеты для инсталляции ===
; --- Обязательные пакеты ---
Section "Система отслеживания и журналирования аварий <UNI_ALARMVIEWER>"

  ; Установите выходной путь к каталогу установки.
  SetOutPath $INSTDIR

  File "README.md"
  File "LICENSE"

  ; Скопировать туда 
  File "uni_alarmchecker.exe"
  ; Скопировать иконку
  File "uni_alarmchecker.ico"
  ;File "uni_alarmchecker.res"

  ; Скопировать туда 
  File "uni_alarmviewer.exe"
  ; Скопировать иконку
  File "uni_alarmviewer.ico"
  ;File "uni_alarmchecker.res"

  CopyFiles /FILESONLY "$EXEDIR\*.wav" "$INSTDIR"
  
  ; Файлы настройки
  CopyFiles /FILESONLY "$EXEDIR\*.ini" "$INSTDIR"
  CopyFiles /FILESONLY "$EXEDIR\*.txt" "$INSTDIR"

  ; Создать программу деинсталяции
  WriteUninstaller $INSTDIR\uninstall.exe

SectionEnd


Section "Системные библиотеки"
  ; Скопировать *.dll в system32
  CopyFiles /FILESONLY "$EXEDIR\sqlite3.dll" "$SYSDIR"
SectionEnd


; необязательный раздел (может быть отключен пользователем)
;--------------------------------
; Деинсталятор

UninstallText "Деинсталяция системы  отслеживания и журналирования аварий <UNI_ALARMVIEWER>. Нажмите Next для продолжения."

Section "Uninstall"

  ; Удалить инсталяционную папку
  RMDir /r "$INSTDIR"

  Delete "$SMSTARTUP\uni_alarmviewer.lnk"  

  MessageBox MB_OK "Деинсталяция UNI_ALARMVIEWER завершена успешно"

SectionEnd
