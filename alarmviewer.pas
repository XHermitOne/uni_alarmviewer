unit alarmviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  Buttons,
  Process,
  strfunc,
  logfunc, settings, Types;

type
  TAlarm = record
    name, message: string;
    status: Boolean;
  end;

  { TAlarmViewerForm }

  TAlarmViewerForm = class(TForm)
    IconImageList: TImageList;
    LogSpeedButton: TSpeedButton;
    PrgControlBar: TControlBar;
    ScanTimer: TTimer;
    AlarmStringGrid: TStringGrid;
    SirenSpeedButton: TSpeedButton;
    SysTrayIcon: TTrayIcon;

    procedure AlarmStringGridDrawCell(Sender: TObject; aCol, aRow: Integer;
      aRect: TRect; aState: TGridDrawState);
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure ScanTimerTimer(Sender: TObject);
    procedure SirenSpeedButtonClick(Sender: TObject);
    procedure SysTrayIconClick(Sender: TObject);

  private
    FSettings: settings.TICSettingsManager;
    FAlarms: Array of TAlarm;
    FIsError: Boolean;

    { Функция парсинга текста проверки аварий }
    function ParseCheckTxt(sTxt: AnsiString): Boolean;

  public

  end;

var
  AlarmViewerForm: TAlarmViewerForm;

implementation

{$R *.lfm}

{ TAlarmViewerForm }

procedure TAlarmViewerForm.FormCreate(Sender: TObject);
begin
  FSettings := settings.TICSettingsManager.Create;
  FSettings.LoadSettings(settings.SETTINGS_INI_FILENAME);
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

procedure TAlarmViewerForm.FormShow(Sender: TObject);
var
  lines_txt: AnsiString;
begin
  if RunCommand('uni_alarmchecker.exe', [], lines_txt, [poWaitOnExit, poNoConsole]) then
    ParseCheckTxt(strfunc.EncodeString(lines_txt, 'cp866', 'utf-8'));
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
end;

procedure TAlarmViewerForm.SysTrayIconClick(Sender: TObject);
begin
  if Visible then
    Hide
  else
    Show;
end;

{ Функция парсинга текста проверки аварий }
function TAlarmViewerForm.ParseCheckTxt(sTxt: AnsiString): Boolean;
var
  lines: TStringList;
  line: AnsiString;
  i_line: Integer;
  tag_name, message, check: AnsiString;
  pos_1, pos_2: Integer;
  bmp: TBitmap;
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
  end;

  lines.Destroy;

  // Установить иконку трея если есть ошибки
  bmp := TBitmap.Create;
  try
    IconImageList.GetBitmap(Integer(not FIsError), bmp);
    SysTrayIcon.Icon.Assign(bmp);
    SysTrayIcon.Show;
  finally
    bmp.Free;
  end;

  Result := True;
end;

end.

