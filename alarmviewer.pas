unit alarmviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  Buttons,
  Process,
  mmSystem,
  strfunc,
  dtfunc,
  logfunc,
  settings,
  filefunc,
  dbf, DB, SQLite3Conn, SQLDB, Types;

type
  TAlarm = record
    name, message: string;
    status: Boolean;
  end;

  { TAlarmViewerForm }

  TAlarmViewerForm = class(TForm)
    IconImageList: TImageList;
    LogSpeedButton: TSpeedButton;
    CtrlPanel: TPanel;
    ScanTimer: TTimer;
    AlarmStringGrid: TStringGrid;
    LogSQLite3Connection: TSQLite3Connection;
    LogSQLQuery: TSQLQuery;
    LogSQLTransaction: TSQLTransaction;
    SirenSpeedButton: TSpeedButton;
    SysTrayIcon: TTrayIcon;

    procedure AlarmStringGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormWindowStateChange(Sender: TObject);
    procedure LogSpeedButtonClick(Sender: TObject);
    procedure ScanTimerTimer(Sender: TObject);
    procedure SirenSpeedButtonClick(Sender: TObject);
    procedure SysTrayIconClick(Sender: TObject);

  private
    FSettings: settings.TICSettingsManager;
    FAlarms: Array of TAlarm;
    FIsError: Boolean;

    { Функция парсинга текста проверки аварий }
    function ParseCheckTxt(sTxt: AnsiString): Boolean;

    { Установить иконку трея если есть ошибка }
    function SetTrayIcon(aIsError: Boolean): Boolean;

    { Запуск сирены< если есть ошибка }
    function RunSiren(aIsError: Boolean): Boolean;

    { Зарегистрировать ошибку }
    function SaveLogMessage(aMessage: AnsiString; aMsgType: AnsiString; aIfNotLogged: Boolean = True): Boolean;

    { Удалить не актуальные записи из журнала }
    function DeleteNotActual(aActualInterval: AnsiString = ''): Boolean;
  public

  end;

var
  AlarmViewerForm: TAlarmViewerForm;

implementation

{$R *.lfm}

{ TAlarmViewerForm }

procedure TAlarmViewerForm.FormCreate(Sender: TObject);
var
  scan_tick: Integer;
  log_filename: AnsiString;
  lines_txt: AnsiString;
begin
  FSettings := settings.TICSettingsManager.Create;
  FSettings.LoadSettings(settings.SETTINGS_INI_FILENAME);

  // Установка периода сканирования из настроек
  scan_tick := StrToInt(FSettings.GetOptionValue('OPTIONS', 'scan_tick'));
  if scan_tick > 100 then
    ScanTimer.Interval := scan_tick;

  // Установка файла журнала
  log_filename := FSettings.GetOptionValue('OPTIONS', 'log_filename');
  LogSQLite3Connection.DataBaseName := log_filename;

  // Состояние запуска сирены при наличии ошибок
  if UpperCase(FSettings.GetOptionValue('OPTIONS', 'siren_on')) = 'TRUE' then
    SirenSpeedButton.Down := True;

  if RunCommand('uni_alarmchecker.exe', [], lines_txt, [poWaitOnExit, poNoConsole]) then
    ParseCheckTxt(strfunc.EncodeString(lines_txt, 'cp866', 'utf-8'));

end;

procedure TAlarmViewerForm.AlarmStringGridDrawCell(Sender: TObject; aCol,
  aRow: Integer; aRect: TRect; aState: TGridDrawState);
begin
  if (aCol = 1) and (aRow > 0) then
    if aRow < Length(FAlarms) then
      IconImageList.Draw(AlarmStringGrid.Canvas, aRect.Left + 16, aRect.Top, Integer(FAlarms[aRow - 1].status));
end;

procedure TAlarmViewerForm.FormDestroy(Sender: TObject);
begin
  FSettings.Destroy;
end;

procedure TAlarmViewerForm.FormWindowStateChange(Sender: TObject);
begin
  if WindowState = wsMinimized then // Если окно сворачивается
  begin
    Hide; // Скрыть окно
    SysTrayIcon.Visible := True; // Показать иконку в трее
  end;
end;

procedure TAlarmViewerForm.LogSpeedButtonClick(Sender: TObject);
var
  message, new_msg: AnsiString;
begin
  message := AlarmStringGrid.Rows[AlarmStringGrid.Row][3];

  try
    LogSQLQuery.SQL.Clear;
    LogSQLQuery.SQL.Add('SELECT datetime(log_dt) AS log_dt, message AS message FROM alarm_log WHERE message = :MESSAGE');
    LogSQLQuery.ParamByName('MESSAGE').Text := message;
    LogSQLQuery.Open;
    new_msg := LogSQLQuery.FieldByName('log_dt').AsString + ' ' + LogSQLQuery.FieldByName('message').AsString;
    LogSQLQuery.Close;
    ShowMessage(new_msg);
  except
    LogSQLQuery.Close;
    logfunc.FatalMsg('Ошибка чтения данных журнала');
  end;
end;

procedure TAlarmViewerForm.ScanTimerTimer(Sender: TObject);
var
  lines_txt: AnsiString;
begin
  // Один тик таймера
  if RunCommand('uni_alarmchecker.exe', [], lines_txt, [poWaitOnExit, poNoConsole]) then
    ParseCheckTxt(strfunc.EncodeString(lines_txt, 'cp866', 'utf-8'));
end;

procedure TAlarmViewerForm.SirenSpeedButtonClick(Sender: TObject);
begin
  FSettings.Content.SaveOptionValue('OPTIONS', 'siren_on', strfunc.BooleanToStr(SirenSpeedButton.Down));
  RunSiren(FIsError);
end;

procedure TAlarmViewerForm.SysTrayIconClick(Sender: TObject);
begin
  SysTrayIcon.Visible := False; // Скрываем иконку в трее
  WindowState := wsNormal; // Разворачиваем окно
  Show; // Показываем окно
end;

{ Функция парсинга текста проверки аварий }
function TAlarmViewerForm.ParseCheckTxt(sTxt: AnsiString): Boolean;
var
  lines: TStringList;
  line: AnsiString;
  i_line: Integer;
  tag_name, message, check: AnsiString;
  pos_1, pos_2: Integer;
begin
  lines := strfunc.ParseStrLines(sTxt);
  SetLength(FAlarms, lines.Count);

  AlarmStringGrid.RowCount := 1;
  FIsError := False;

  for i_line := 0 to lines.Count - 1 do
  begin
    line := lines[i_line];
    pos_1 := Pos(':', line);
    pos_2 := Pos('...', line);
    tag_name :=  Copy(line, 1, pos_1 - 1);
    message := strfunc.StripStr(Copy(line, pos_1 + 1, pos_2 - pos_1 - 1));
    check := strfunc.StripStr(Copy(line, pos_2 + 3, line.Length - pos_2 - 1), ' ');

    FAlarms[i_line].name := tag_name;
    FAlarms[i_line].message := message;
    if not FIsError then
      FIsError := check <> 'OK';
    FAlarms[i_line].status := check = 'OK';

    AlarmStringGrid.InsertRowWithValues(i_line + 1, ['', '', '', message]);

    SaveLogMessage(message, check);
  end;

  lines.Destroy;

  SetTrayIcon(FIsError);
  //if SirenSpeedButton.Down then
  RunSiren(FIsError);

  DeleteNotActual();

  Result := True;
end;

{ Установить иконку трея если есть ошибка }
function TAlarmViewerForm.SetTrayIcon(aIsError: Boolean): Boolean;
var
  bmp: TBitmap;
begin
  Result := True;
  // Установить иконку трея если есть ошибки
  bmp := TBitmap.Create;
  try
    IconImageList.GetBitmap(Integer(not aIsError), bmp);
    SysTrayIcon.Icon.Assign(bmp);
    // SysTrayIcon.Show;
  finally
    bmp.Free;
  end;

end;

{ Запуск сирены< если есть ошибка }
function TAlarmViewerForm.RunSiren(aIsError: Boolean): Boolean;
begin
  Result := False;
  if aIsError and SirenSpeedButton.Down then
  begin
    SndPlaySound('fur-elise---bethoven_[Pro-Sound.org].wav', snd_Loop or snd_Async or snd_NoDefault);
    Result := True;
  end
  else
    sndPlaySound(nil, snd_Async or snd_NoDefault);
end;

{ Зарегистрировать ошибку }
function TAlarmViewerForm.SaveLogMessage(aMessage: AnsiString; aMsgType: AnsiString; aIfNotLogged: Boolean = True): Boolean;
begin
  Result := False;

  try
    if not aIfNotLogged then
    begin
      LogSQLQuery.SQL.Clear;
      LogSQLQuery.SQL.Add('INSERT INTO alarm_log(log_dt, message, msg_type) VALUES (:LOG_DT, :MESSAGE, :MSG_TYPE)');
      LogSQLQuery.ParamByName('LOG_DT').AsDateTime := Now;
      LogSQLQuery.ParamByName('MESSAGE').Text := aMessage;
      LogSQLQuery.ParamByName('MSG_TYPE').Text := aMsgType;
      LogSQLQuery.ExecSQL;
      LogSQLTransaction.Commit;
      LogSQLQuery.Close;
      Result := True;
    end
    else
    begin
      LogSQLQuery.SQL.Clear;
      LogSQLQuery.SQL.Add('INSERT INTO alarm_log(log_dt, message, msg_type) SELECT :LOG_DT, :MESSAGE, :MSG_TYPE WHERE NOT EXISTS(SELECT 1 FROM alarm_log WHERE message = :MESSAGE AND msg_type = :MSG_TYPE);');
      LogSQLQuery.ParamByName('LOG_DT').AsDateTime := Now;
      LogSQLQuery.ParamByName('MESSAGE').Text := aMessage;
      LogSQLQuery.ParamByName('MSG_TYPE').Text := aMsgType;
      LogSQLQuery.ExecSQL;
      LogSQLTransaction.Commit;
      LogSQLQuery.Close;
      Result := True;
    end;
  except
    LogSQLTransaction.Rollback;
    logfunc.FatalMsg('Ошибка записи в журнал');
  end;

end;

{ Удалить не актуальные записи из журнала }
function TAlarmViewerForm.DeleteNotActual(aActualInterval: AnsiString = ''): Boolean;
var
  sql: AnsiString;
begin
  Result := False;

  if strfunc.IsEmptyStr(aActualInterval) then
     aActualInterval := FSettings.GetOptionValue('OPTIONS', 'log_actual_interval');

  sql := Format('DELETE FROM alarm_log WHERE message = '#39 + ''#39 + ' OR msg_type = '#39 + ''#39 + ' OR datetime(log_dt) < datetime('#39 +'now'#39 + ', '#39 + '-%s'#39 + ')', [aActualInterval]);
  //ShowMessage(sql);
  try
    LogSQLQuery.SQL.Clear;
    LogSQLQuery.SQL.Add(sql);
    LogSQLQuery.ExecSQL;
    LogSQLTransaction.Commit;
    LogSQLQuery.Close;
  except
    LogSQLTransaction.Rollback;
    logfunc.FatalMsgFmt('Ошибка удаления не актуальных записей из журнала <%s>', [sql]);
  end;

end;

end.

