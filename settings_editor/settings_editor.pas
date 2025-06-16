{
Редактор настроек settings.ini.

Версия: 0.0.0.1
}

program settings_editor;

uses
  App, 	     // TApplication
  Objects,  // TRect
  Drivers,  // Hotkey
  Views,    // cmQuit
  Menus,
  Dialogs,
  AboutDlg;    // 

// Коды комманд меню
const
  cmOpen = 1002;      // Открыть settings.ini
  cmAbout = 1001;     // О программе...


type
  TSettingsEditorApp = object(TApplication)
    procedure InitStatusLine; virtual;	 // Инициализация статусной строки
    procedure InitMenuBar; virtual;      // Инициализация меню
    procedure HandleEvent(var Event: TEvent); virtual; // Обработчик событий
  private
    procedure ShowAbout();
end;


// Инициализация статусной строки
procedure TSettingsEditorApp.InitStatusLine;
var
  R: TRect;           // 

  status_def: PStatusDef;           // 
  item1, item2, item3: PStatusItem;  //
begin
  GetExtent(R);       //
  R.A.Y := R.B.Y - 1; //

  item3 := NewStatusKey('~F1~ Помощь', kbF1, cmHelp, nil);
  item2 := NewStatusKey('~F10~ Меню', kbF10, cmMenu, item3);
  item1 := NewStatusKey('~Alt+X~ Выход', kbAltX, cmQuit, item2);
  status_def := NewStatusDef(0, $FFFF, item1, nil);

  StatusLine := New(PStatusLine, Init(R, status_def));
end;


// Инициализация меню
procedure TSettingsEditorApp.InitMenuBar;                                                 
var                                                                           
  R: TRect;                          
                                                                              
  menu: PMenu;                          
  file_menu, help_menu,                          
  separator_line, open_menuitem, exit_menuitem, about_menuitem: PMenuItem; 
                                                                              
begin                                                                         
  GetExtent(R);                                                               
  R.B.Y := R.A.Y + 1;                                                         
                                                                              
  about_menuitem := NewItem('О программе...', '', kbNoKey, cmAbout, hcNoContext, nil);      
  help_menu := NewSubMenu('Помощь', hcNoContext, NewMenu(about_menuitem), nil);              
                                                                              
  exit_menuitem := NewItem('Выход', 'Alt-X', kbAltX, cmQuit, hcNoContext, nil);    
  separator_line := NewLine(exit_menuitem);                                                      
  open_menuitem := NewItem('Открыть', 'F3', kbF3, cmOpen, hcNoContext, separator_line);
  file_menu := NewSubMenu('Файл', hcNoContext, NewMenu(open_menuitem), help_menu);              
                                                                              
  menu := NewMenu(file_menu);
                                                                              
  MenuBar := New(PMenuBar, Init(R, menu));                                       
end;                                                                          


// Обработчик событий
procedure TSettingsEditorApp.HandleEvent(var Event: TEvent);
var
  Rect: TRect; 

begin
  GetExtent(Rect);

  Rect.A.Y := Rect.B.Y - 1;
  inherited HandleEvent(Event);

  if Event.What = evCommand then begin
    case Event.Command of
      cmAbout: 
      begin
        // Здесь вызов диалога О программе...
        ShowAbout();
      end;

      // Открыть файл
      cmOpen: 
      begin
        // 
      end;
      else 
      begin
        Exit;
      end;
    end;
  end;
  ClearEvent(Event);
end;


procedure TSettingsEditorApp.ShowAbout();
var
  about_dialog: PSettingsEditorAboutDlg;
begin
  about_dialog := New(PSettingsEditorAboutDlg, Init);     
  if ValidView(about_dialog) <> nil then 
  begin
    Desktop^.ExecView(about_dialog);           
    Dispose(about_dialog, Done);               
  end;
end;

var
  SettingsEditorApp: TSettingsEditorApp;


begin
  SettingsEditorApp.Init;   // 
  SettingsEditorApp.Run;    // 
  SettingsEditorApp.Done;   // 
end.
