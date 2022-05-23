{
Функции взаимодействия с операционной системой

Версия: 0.0.3.1
}
unit sysfunc;

{$mode objfpc}{$H+}

interface

uses
  {$IFDEF windows}
  Windows,
  {$ENDIF}
  Classes, SysUtils,
  Process {, UTF8Process};

{$IFDEF linux}
{ some linux-specific code }
const OS: AnsiString = 'linux';
{$ENDIF}

{$IFDEF windows}
{ some M$-specific code }
const OS: AnsiString = 'windows';
{$ENDIF}

{ Тип операционной системы: linux/windows}
function GetOSType(): AnsiString;

{ Проверка является ли ОС Linux }
function IsOSLinux(): Boolean;

{ Проверка является ли ОС Windows }
function IsOSWindows(): Boolean;

{ Наименование компьютера }
function GetNetComputerName(): AnsiString;

{$IFDEF WINDOWS}
  function Wow64DisableWow64FsRedirection(x: Pointer): longbool; stdcall; external 'Kernel32.dll' name 'Wow64DisableWow64FsRedirection';
  function Wow64RevertWow64FsRedirection (x: Pointer): longbool; stdcall; external 'Kernel32.dll' name 'Wow64RevertWow64FsRedirection';
{$ENDIF}
{Запуск внешней программы и получение списка выводимых строк}
function GetOutLinesOfProcess(ACommand: AnsiString): AnsiString;

implementation

uses
  strfunc;

{
Тип операционной системы: linux/windows
}
function GetOSType(): AnsiString;
begin
  Result := OS;
end;

{ Проверка является ли ОС Linux }
function IsOSLinux(): Boolean;
begin
  Result := OS = 'linux';
end;

{ Проверка является ли ОС Windows }
function IsOSWindows(): Boolean;
begin
  Result := OS = 'windows';
end;

{ Наименование компьютера }
function GetNetComputerName(): AnsiString;
{$IFDEF windows}
var
  buffer: Array[0..255] Of char;
  size: dword;
{$ENDIF}

begin
  Result := '';

  {$IFDEF windows}
  size := 256;
  if GetComputerName(buffer, size) then
    Result := buffer;
  {$ENDIF}
end;

{Запуск внешней программы и получение списка выводимых строк}
function GetOutLinesOfProcess(ACommand: AnsiString): AnsiString;
var
  process: TProcess;
  output_lines: TStringList;	// Выходные строки
  //{$IFDEF WINDOWS}
  //  pnt: Pointer;
  //{$ENDIF}
begin
  output_lines := TStringList.Create;
  process := TProcess.Create(nil);
  // Ожидание окончания работы внешней программы,
  // Отключить консоль,
  // Вывод результатов в спец поток
  process.Options := process.Options + [poWaitOnExit, poNoConsole, poUsePipes];

  process.Executable := ACommand;

  //{$IFDEF WINDOWS}
  //  pnt := nil;
  //  Wow64DisableWow64FsRedirection(pnt);
  //{$ENDIF}

  process.Execute;

  //{$IFDEF WINDOWS}
  //  Wow64RevertWow64FsRedirection(pnt);
  //{$ENDIF}

  // Результат вывода процесса -> список строк
  output_lines.LoadFromStream(process.Output);

  Result := strfunc.ConvertStrListToString(output_lines);

  // ВНИМАНИЕ! Не забываем список строк после использования удалить
  output_lines.Free;
  process.Free;
end;

end.

