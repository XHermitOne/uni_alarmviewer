unit alarmviewer;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, Forms, Controls, Graphics, Dialogs, Grids, ExtCtrls,
  Buttons,
  engine, log, settings;

type

  { TAlarmViewerForm }

  TAlarmViewerForm = class(TForm)
    PrgControlBar: TControlBar;
    AlarmDrawGrid: TDrawGrid;
    SirenSpeedButton: TSpeedButton;
    LogSpeedButton: TSpeedButton;
    ScanTimer: TTimer;
    SysTrayIcon: TTrayIcon;
    procedure FormCreate(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
  private

  public

  end;

var
  AlarmViewerForm: TAlarmViewerForm;

implementation

{$R *.lfm}

{ TAlarmViewerForm }

procedure TAlarmViewerForm.FormCreate(Sender: TObject);
begin
  //if LOG_MODE then
  //  OpenLog(ChangeFileExt(ParamStr(0), '.log'));

  // Создание формы - создание движка
  // Инициализируем объект движка и всех его внутренних объектов
  engine.PRG_ENGINE := TICAlarmViewer.Create(nil);
  engine.PRG_ENGINE.Start;

end;

procedure TAlarmViewerForm.FormDestroy(Sender: TObject);
begin
  // Удаление формы
  // Удаление движка
  // Корректно завершаем работу движка
  engine.PRG_ENGINE.Stop;
  engine.PRG_ENGINE.Destroy;
  engine.PRG_ENGINE := nil;

end;

end.

