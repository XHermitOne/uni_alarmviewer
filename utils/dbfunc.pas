{
Функции работы с БД.

Версия: 0.0.2.1
}
unit dbfunc;

{$mode objfpc}{$H+}

interface

uses
    Classes,
    SQLdb, ODBCConn,
    logfunc;

{
Настроить параметры соединения с БД
@param aDriver Драйвер БД
@param aDataSourceName Имя источника данных настроенного в ODBC
@return Объект соединения
}
function ConnectODBC(aDriver: AnsiString; aDataSourceName: AnsiString): TODBCConnection;

{
Закрыть соединение
}
function DisconnectODBC(aConnection: TODBCConnection): Boolean;

{
Проверка связи с БД MySQL
@param aDriver Драйвер БД
@param aDataSourceName Имя источника данных настроенного в ODBC
@return True - Связь есть / False - Нет
}
function CheckODBCConnection(aDriver: AnsiString; aDataSourceName: AnsiString): Boolean;

{
Проверка существования записей удовлетворяющих условию
@param aDriver Драйвер БД
@param aDataSourceName Имя источника данных настроенного в ODBC
@param aSQL Текст SQL выражения для проверки
@return True - Есть записи / False - Нет
}
function ExistsRecordsODBC(aDriver: AnsiString; aDataSourceName: AnsiString; aSQL: AnsiString): Boolean;

implementation

{
Настроить параметры соединения с БД
@param aDataSourceName Имя источника данных настроенного в ODBC
@return Объект соединения
}
function ConnectODBC(aDriver: AnsiString; aDataSourceName: AnsiString): TODBCConnection;
var
  odbc_connection: TODBCConnection;
begin
  odbc_connection := TODBCConnection.Create(nil);
  odbc_connection.Driver := aDriver;
  odbc_connection.DatabaseName := aDataSourceName;
  //odbc_connection.UserName := aUserName;
  //odbc_connection.Password := aPassword;
  //odbc_connection.Params.Add('DATABASE=server');
  odbc_connection.Params.Add('AUTOCOMMIT=1');

  try
    odbc_connection.Open;
    // odbc_connection.Text := 'Connected ... OK';
  except
    //on E: ESQLDatabaseError do
    //logfunc.ErrorMsg(E.Message);
    logfunc.FatalMsgFmt('Ошибка создания связи с <%s : %s>', [aDataSourceName, aDriver]);
  end;

  Result := odbc_connection;
end;

{
Закрыть соединение
}
function DisconnectODBC(aConnection: TODBCConnection): Boolean;
begin
  Result := False;
  if aConnection.Connected then
  begin
    aConnection.Close;
    aConnection.Destroy();
    aConnection := nil;
    Result := True;
  end;
end;

{
Проверка связи с БД
@param aDriver Драйвер БД
@param aDataSourceName Имя источника данных настроенного в ODBC
@return True - Связь есть / False - Нет
}
function CheckODBCConnection(aDriver: AnsiString; aDataSourceName: AnsiString): Boolean;
var
  odbc_connection: TODBCConnection;
  transaction: TSQLTransaction;
  query: TSQLQuery;
begin
  Result := False;
  odbc_connection := ConnectODBC(aDriver, aDataSourceName);

  if odbc_connection.Connected then
  begin
    {
    Для выполнения запроса необходимо выстроить связи:
    ODBCConnection <---+
                       |
    SQLTransaction.Database
               ^
               |
    SQLQuery.Transaction
    }
    transaction := TSQLTransaction.Create(nil);
    transaction.Database := odbc_connection;

    query := TSQLQuery.Create(nil);
    query.Transaction := transaction;
    try
      query.SQL.Text := 'SELECT 1';
      query.ExecSQL;
      Result := True;
    except
      //on E: ESQLDatabaseError do
      //  logfunc.ErrorMsg(E.Message);
      logfunc.FatalMsgFmt('Ошибка проверки доступа к БД <%s : %s>', [aDataSourceName, aDriver]);
    end;
    query.Destroy;
    transaction.Destroy;
  end
  else
    logfunc.ErrorMsgFmt('Не установлена связь с <%s : %s>', [aDataSourceName, aDriver]);

  DisconnectODBC(odbc_connection);
end;

{
Проверка существования записей удовлетворяющих условию
@param aDriver Драйвер БД
@param aDataSourceName Имя источника данных настроенного в ODBC
@param aSQL Текст SQL выражения для проверки
@return True - Есть записи / False - Нет
}
function ExistsRecordsODBC(aDriver: AnsiString; aDataSourceName: AnsiString; aSQL: AnsiString): Boolean;
var
  odbc_connection: TODBCConnection;
  transaction: TSQLTransaction;
  query: TSQLQuery;
begin
  Result := False;
  odbc_connection := ConnectODBC(aDriver, aDataSourceName);

  if odbc_connection.Connected then
  begin
    {
    Для выполнения запроса необходимо выстроить связи:
    ODBCConnection <---+
                       |
    SQLTransaction.Database
               ^
               |
    SQLQuery.Transaction
    }
    transaction := TSQLTransaction.Create(nil);
    transaction.Database := odbc_connection;

    query := TSQLQuery.Create(nil);
    query.Transaction := transaction;
    try
      query.SQL.Text := aSQL;
      query.Open;
      query.First;
      //logfunc.DebugMsgFmt('Полей [%d]', [query.Fields.Count]);
      Result := query.Fields[0].AsBoolean;
      query.Close;
    except
      //on E: ESQLDatabaseError do
      //  logfunc.ErrorMsg(E.Message);
      logfunc.FatalMsgFmt('Ошибка проверки существования записей удовлетворяющих условию <%s : %s : %s>', [aDataSourceName, aDriver, aSQL]);
    end;
    query.Destroy;
    transaction.Destroy;
  end
  else
    logfunc.ErrorMsgFmt('Не установлена связь с <%s : %s>', [aDataSourceName, aDriver]);

  DisconnectODBC(odbc_connection);
end;

end.

