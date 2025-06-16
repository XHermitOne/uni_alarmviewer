unit AboutDlg;

interface

uses
  App, Objects, Drivers, Views, Dialogs;

type
  PSettingsEditorAboutDlg = ^TSettingsEditorAboutDlg;
  TSettingsEditorAboutDlg = object(TDialog)
    constructor Init; 
  end;

implementation

constructor TSettingsEditorAboutDlg.Init;
var
  R: TRect;
begin
  R.Assign(0, 0, 42, 11);
  R.Move(23, 3);

  inherited Init(R, 'About'); 

  // StaticText
  R.Assign(5, 2, 41, 8);
  Insert(new(PStaticText, Init(R,
    'Free Vison Tutorial 1.0' + #13 +
    '2017' + #13 +
    'Gechrieben von M. Burkhard' + #13#32#13 +
    'FPC: '+ {$I %FPCVERSION%} + '   OS:'+ {$I %FPCTARGETOS%} + '   CPU:' + {$I %FPCTARGETCPU%})));

  // Ok-Button
  R.Assign(27, 8, 37, 10);
  Insert(new(PButton, Init(R, '~O~K', cmOK, bfDefault)));
end;

end.
