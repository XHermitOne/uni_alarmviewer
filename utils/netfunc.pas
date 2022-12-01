{
Функции работы с сетью.

Версия: 0.0.2.1
}
unit netfunc;

{$mode objfpc}{$H+}

interface

uses
    //Classes, SysUtils,
    //blcksock,
    //synautil,
    //synsock,
    crt,
    pingsend;

{
Проверка связи Ping
@param sHost Имя/IP адрес пингуемого компьютера
@return True - Связь есть / False - Нет пинга
}
function DoPing(sHost: AnsiString): Boolean;

{
Проверка связи по нескольким Ping. Не жесткая проверк (Пинги могут пропадать)
@param sHost Имя/IP адрес пингуемого компьютера
@param uCount: Количество проверяемых пингов.
@param uDelay: Задержка между пингами в миллисекундах.
@return True - Связь есть / False - Нет пинга
}
function DoAnySeriesPing(sHost: AnsiString; uCount: Integer; uDelay: Cardinal): Boolean;

{
Проверка связи по нескольким Ping. Жесткая проверка (Все пинги должны присутствовать)
@param sHost Имя/IP адрес пингуемого компьютера
@param uCount: Количество проверяемых пингов.
@param uDelay: Задержка между пингами в миллисекундах.
@return True - Связь есть / False - Нет пинга
}
function DoAllSeriesPing(sHost: AnsiString; uCount: Integer; uDelay: Cardinal): Boolean;

implementation

{
Проверка связи Ping
@param sHost Имя/IP адрес пингуемого компьютера
@return True - Связь есть / False - Нет пинга
}
function DoPing(sHost: AnsiString): Boolean;
var
  ping_send: TPingSend;
begin
  Result := False;
  ping_send := TPingSend.Create;
  try
    ping_send.Timeout := 750;
    Result := ping_send.Ping(sHost);
  finally
    ping_send.Free;
  end;
end;

{
Проверка связи по нескольким Ping
@param sHost Имя/IP адрес пингуемого компьютера
@param uCount: Количество проверяемых пингов.
@param uDelay: Задержка между пингами в миллисекундах.
@return True - Связь есть / False - Нет пинга
}
function DoAnySeriesPing(sHost: AnsiString; uCount: Integer; uDelay: Cardinal): Boolean;
var
  i: Integer;
begin
  Result := False;
  for i := 0 to uCount - 1 do
  begin
    Result := Result or DoPing(sHost);
    if uDelay > 0 then
       crt.Delay(uDelay);
  end;
end;

{
Проверка связи по нескольким Ping
@param sHost Имя/IP адрес пингуемого компьютера
@param uCount: Количество проверяемых пингов.
@param uDelay: Задержка между пингами в миллисекундах.
@return True - Связь есть / False - Нет пинга
}
function DoAllSeriesPing(sHost: AnsiString; uCount: Integer; uDelay: Cardinal): Boolean;
var
  i: Integer;
begin
  Result := True;
  for i := 0 to uCount - 1 do
  begin
    Result := Result and DoPing(sHost);
    if uDelay > 0 then
       Delay(uDelay);
  end;
end;

end.

