{
Функции отладки.

Цветовая расскраска сообщений в коммандной оболочке
производиться только под Linux.
Для Windows систем цветовая раскраска отключена.

Шаблон для использования в современных
командных оболочках и языках
программирования таков: \x1b[...m.
Это ESCAPE-последовательность,
где \x1b обозначает символ ESC
(десятичный ASCII код 27), а вместо "..."
подставляются значения из таблицы,
приведенной ниже, причем они могут
комбинироваться, тогда нужно их
перечислить через точку с запятой.

атрибуты

0 	нормальный режим

1 	жирный

4 	подчеркнутый

5 	мигающий

7 	инвертированные цвета

8 	невидимый

цвет текста

30 	черный

31 	красный

32 	зеленый

33 	желтый

34 	синий

35 	пурпурный

36 	голубой

37 	белый

цвет фона

40 	черный

41 	красный

42 	зеленый

43 	желтый

44 	синий

45 	пурпурный

46 	голубой

47 	белый

Версия: 0.2.1.1

ВНИМАНИЕ! Вывод сообщений под Linux проверять только в терминале.
Только он выводит корректно сообщения.
}

unit dbgfunc;

{$mode objfpc}{$H+}

interface

uses
    SysUtils,
    { Для функций перекодировки UTF8ToWinCP }
    LazUTF8

  {$IFDEF WIN32}  
    ,crt
  {$ENDIF}
  ;

const
  { Цвета в консоли Linux }
  RED_COLOR_TEXT: AnsiString = Chr($1b) + '[31;1m';       // red
  GREEN_COLOR_TEXT: AnsiString = Chr($1b) + '[32m';       // green
  YELLOW_COLOR_TEXT: AnsiString = Chr($1b) + '[33;1m';    // yellow
  BLUE_COLOR_TEXT: AnsiString = Chr($1b) + '[34m';        // blue
  PURPLE_COLOR_TEXT: AnsiString = Chr($1b) + '[35m';      // purple
  CYAN_COLOR_TEXT: AnsiString = Chr($1b) + '[36m';        // cyan
  WHITE_COLOR_TEXT: AnsiString = Chr($1b) + '[37m';       // white
  NORMAL_COLOR_TEXT: AnsiString = Chr($1b) + '[0m';       // normal

{
Определить актуальную кодировку для вывода текста.
@return Актуальная кодировка для вывода текста
}
function GetDefaultEncoding(): AnsiString;
{Определить включен ли режим отладки}
function GetDebugMode(): Boolean;

{
Перекодирование AnsiString строки в AnsiString.
@param sTxt Текст в AnsiString
@param sCodePage Указание кодировки
@return Перекодированный текст
}
function EncodeUnicodeString(sTxt: AnsiString; sCodePage: AnsiString = ''): AnsiString;

{
Печать цветового текста
@param sTxt Печатаемый текст
@param sColor Дополнительное указание цветовой раскраски
}
procedure PrintColorTxt(sTxt: AnsiString; sColor: AnsiString);

{
Печать текста
@param sTxt Печатаемый текст
@param bNewLine Произвести перевод строки?
}
procedure PrintTxt(sTxt: AnsiString; bNewLine: Boolean = True);

{
Вывести ОТЛАДОЧНУЮ информацию.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}

procedure DebugMsg(sMsg: AnsiString; bForcePrint: Boolean = False; bForceLog: Boolean = False);

{
Вывести ТЕКСТОВУЮ информацию.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure InfoMsg(sMsg: AnsiString; bForcePrint: Boolean = False; bForceLog: Boolean = False);

{
Вывести информацию об ОШИБКЕ.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ErrorMsg(sMsg: AnsiString; bForcePrint: Boolean = False; bForceLog: Boolean = False);

{
Вывести ПРЕДУПРЕЖДЕНИЕ.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure WarningMsg(sMsg: AnsiString; bForcePrint: Boolean = False; bForceLog: Boolean = False);

{
Вывести СООБЩЕНИЕ об ИСКЛЮЧИТЕЛЬНОЙ СИТУАЦИИ.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure FatalMsg(sMsg: AnsiString; bForcePrint: Boolean = False; bForceLog: Boolean = False);

{
Вывести СЕРВИСНУЮ информацию.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ServiceMsg(sMsg: AnsiString; bForcePrint: Boolean = False; bForceLog: Boolean = False);

{
Вывести ОТЛАДОЧНУЮ информацию с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure DebugMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean = False; bForceLog: Boolean = False);
{
Вывести текстовую ИНФОРМАЦИЮ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure InfoMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean = False; bForceLog: Boolean = False);
{
Вывести СЕРВИСНУЮ информацию с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ServiceMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean = False; bForceLog: Boolean = False);
{
Вывести информацию об ОШИБКЕ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ErrorMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean = False; bForceLog: Boolean = False);
{
Вывести ПРЕДУПРЕЖДЕНИЕ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure WarningMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean = False; bForceLog: Boolean = False);
{
Вывести СООБЩЕНИЕ об ИСКЛЮЧИТЕЛЬНОЙ СИТУАЦИИ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure FatalMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean = False; bForceLog: Boolean = False);

var
    { Режим отладки }
    DEBUG_MODE: Boolean = True;

implementation

{
Определить актуальную кодировку для вывода текста.
@return Актуальная кодировка для вывода текста
}
function GetDefaultEncoding(): AnsiString;
begin
  {$IFNDEF WIN32}  
  Result := 'utf-8';
  {$ELSE}
  Result := 'cp1251';
  {$ENDIF}
end;

{
Определить включен ли режим отладки
}
function GetDebugMode(): Boolean;
begin
  Result := DEBUG_MODE;
end;

{
Перекодирование AnsiString строки в AnsiString.
@param sTxt Текст в AnsiString
@param sCodePage Указание кодировки
@return Перекодированный текст
}
function EncodeUnicodeString(sTxt: AnsiString; sCodePage: AnsiString): AnsiString;
begin
  Result := '';
  if sCodePage = '' then
    sCodePage := GetDefaultEncoding();

  if (sCodePage = 'utf-8') or (sCodePage = 'UTF-8') or (sCodePage = 'utf8') or (sCodePage = 'UTF8') then
  begin
    // ВНИМАНИЕ! Мы везде работаем с UTF-8 кодировкой
    // Поэтому перекодировать здесь не надо
    Result := sTxt;
  end
  else if (sCodePage = 'cp1251') or (sCodePage = 'CP1251') then
  begin
    // С Windows системами мы можем пользоваться
    // функциями UTF8ToWinCP и WinCPToUTF8 модуль LazUTF8
    Result := LazUTF8.UTF8ToWinCP(sTxt);
  end
  else
    PrintColorTxt(Format('Не поддерживаемая кодировка <%s>', [sCodePage]), YELLOW_COLOR_TEXT);
end;

{
Печать цветового текста
@param sTxt Печатаемый текст
@param sColor Дополнительное указание цветовой раскраски
}
procedure PrintColorTxt(sTxt: AnsiString; sColor: AnsiString);
var
    str_txt: AnsiString;
begin
  str_txt := EncodeUnicodeString(sTxt, GetDefaultEncoding());
  // Для Windows систем цветовая раскраска отключена
  {$IFNDEF WIN32}  
  // Добавление цветовой раскраски для Linux систем
  str_txt := sColor + str_txt + NORMAL_COLOR_TEXT;
  {$ELSE}
  if sColor = RED_COLOR_TEXT then
    crt.TextColor(crt.Red)
  else if sColor = GREEN_COLOR_TEXT then
    crt.TextColor(crt.Green)
  else if sColor = YELLOW_COLOR_TEXT then
    crt.TextColor(crt.Yellow)
  else if sColor = BLUE_COLOR_TEXT then
    crt.TextColor(crt.Blue)
  else if sColor = PURPLE_COLOR_TEXT then
    crt.TextColor(crt.Magenta)
  else if sColor = CYAN_COLOR_TEXT then
    crt.TextColor(crt.Cyan)
  else if sColor = WHITE_COLOR_TEXT then
    crt.TextColor(crt.White)
  else if sColor = NORMAL_COLOR_TEXT then
    crt.TextColor(crt.Mono);
  {$ENDIF}

  // Если журналирование переведено в SysLog, то ничего не делать
  WriteLn(str_txt);

  // В конце отключим цвет, возможно далее будет стандартный вывод
  {$IFDEF WIN32}  
   crt.TextColor(crt.Mono);
  {$ENDIF}
end;

{
Печать текста
@param sTxt Печатаемый текст
@param bNewLine Произвести перевод строки?
}
procedure PrintTxt(sTxt: AnsiString; bNewLine: Boolean = True);
begin
    if bNewLine then
      WriteLn(stdout, sTxt)
    else
      Write(stdout, sTxt);
end;


{
Вывести ОТЛАДОЧНУЮ информацию.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure DebugMsg(sMsg: AnsiString; bForcePrint: Boolean; bForceLog: Boolean);
begin
    if (GetDebugMode()) or (bForcePrint) then
      PrintColorTxt('DEBUG. ' + sMsg, BLUE_COLOR_TEXT);
end;

{
Вывести ТЕКСТОВУЮ информацию.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure InfoMsg(sMsg: AnsiString; bForcePrint: Boolean; bForceLog: Boolean);
begin
    if (GetDebugMode()) or (bForcePrint) then
      PrintColorTxt('INFO. ' + sMsg, GREEN_COLOR_TEXT);
end;

{
Вывести информацию об ОШИБКЕ.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ErrorMsg(sMsg: AnsiString; bForcePrint: Boolean; bForceLog: Boolean);
begin
    if (GetDebugMode()) or (bForcePrint) then
      PrintColorTxt('ERROR. ' + sMsg, RED_COLOR_TEXT);
end;

{
Вывести ПРЕДУПРЕЖДЕНИЕ.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure WarningMsg(sMsg: AnsiString; bForcePrint: Boolean; bForceLog: Boolean);
begin
    if (GetDebugMode()) or (bForcePrint) then
      PrintColorTxt('WARNING. ' + sMsg, YELLOW_COLOR_TEXT);
end;


{
Вывести СООБЩЕНИЕ об ИСКЛЮЧИТЕЛЬНОЙ СИТУАЦИИ.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure FatalMsg(sMsg: AnsiString; bForcePrint: Boolean; bForceLog: Boolean);
var
    buf : array[0..511] of char;
    msg, except_msg: AnsiString;
begin
    msg := Format('FATAL. %s', [sMsg]);

    ExceptionErrorMessage(ExceptObject, ExceptAddr, @buf, SizeOf(buf));
    except_msg := buf;

    if (GetDebugMode()) or (bForcePrint) then
      begin
        PrintColorTxt(msg, RED_COLOR_TEXT);
        PrintColorTxt(except_msg, RED_COLOR_TEXT);
      end;
end;

{
Вывести СЕРВИСНУЮ информацию.
@param sMsg Текстовое сообщение
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ServiceMsg(sMsg: AnsiString; bForcePrint: Boolean; bForceLog: Boolean);
begin
    if (GetDebugMode()) or (bForcePrint) then
      PrintColorTxt('SERVICE. ' + sMsg, CYAN_COLOR_TEXT);
end;

{
Вывести ОТЛАДОЧНУЮ информацию с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure DebugMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean; bForceLog: Boolean);
begin
  DebugMsg(Format(sMsgFmt, aArgs), bForcePrint, bForceLog);
end;

{
Вывести текстовую ИНФОРМАЦИЮ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure InfoMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean; bForceLog: Boolean);
begin
  InfoMsg(Format(sMsgFmt, aArgs), bForcePrint, bForceLog);
end;

{
Вывести СЕРВИСНУЮ информацию с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ServiceMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean; bForceLog: Boolean);
begin
  ServiceMsg(Format(sMsgFmt, aArgs), bForcePrint, bForceLog);
end;

{
Вывести информацию об ОШИБКЕ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure ErrorMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean; bForceLog: Boolean);
begin
  ErrorMsg(Format(sMsgFmt, aArgs), bForcePrint, bForceLog);
end;

{
Вывести ПРЕДУПРЕЖДЕНИЕ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure WarningMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean; bForceLog: Boolean);
begin
  WarningMsg(Format(sMsgFmt, aArgs), bForcePrint, bForceLog);
end;

{
Вывести СООБЩЕНИЕ об ИСКЛЮЧИТЕЛЬНОЙ СИТУАЦИИ с форматированным текстовым сообщением.
@param sMsgFmt Формат текстового сообщения
@param aArgs Аргументы текстового сообщения
@param bForcePrint Принудительно вывести на экран
@param bForceLog Принудительно записать в журнале
}
procedure FatalMsgFmt(sMsgFmt: AnsiString; const aArgs : Array Of Const; bForcePrint: Boolean; bForceLog: Boolean);
begin
  FatalMsg(Format(sMsgFmt, aArgs), bForcePrint, bForceLog);
end;

end.

