{
Классы работы с INI файлами

Версия: 0.0.4.1
}
unit inifunc;

{$mode objfpc}{$H+}

interface

uses
    Classes, SysUtils, INIFiles, StrUtils, dictionary;

const
  MEMO_SIGNATURE: AnsiString = 'MEMO: ';

type
    {
    TIniDictionary - Словарь словарей для хранения содержимого INI файла
    с разделением данных по секциям.
    }
    TIniDictionary = class(TStrDictionary)
    private
      { Полное наименование последнего загруженного INI файла }
      FINIFileName: AnsiString;

    public

      constructor Create();
      constructor Create(sINIFileName: AnsiString);
      destructor Destroy; override;

      {
      Загрузить содержимое INI файла
      @param sINIFileName Полное наименование INI файла
      @return True - загрузка прошла успешно / False - ошибка
      }
      function LoadIniFile(sINIFileName: AnsiString): Boolean;

      {
      Записать содержимое INI файла
      @param sINIFileName Полное наименование INI файла
      @return True - запись прошла успешно / False - ошибка
      }
      function SaveIniFile(sINIFileName: AnsiString = ''): Boolean;

      {
      Получить значение параметра
      @param sSectionName Наименование секции
      @param sOptionName Наименование параметра
      @return Строка значения указанного параметра. Если параметр не существует то возвращает пустую строку
      }
      function GetOptionValue(sSectionName: AnsiString; sOptionName: AnsiString): AnsiString;

      {
      Сохранить значение параметра
      @param sSectionName Наименование секции
      @param sOptionName Наименование параметра
      @param sValue: Значение параметра в виде строки
      @return True/False
      }
      function SetOptionValue(sSectionName: AnsiString; sOptionName: AnsiString; sValue: AnsiString): Boolean;

      {
      Сохранить значение параметра в файле
      @param sSectionName Наименование секции
      @param sOptionName Наименование параметра
      @param sValue: Значение параметра в виде строки
      @param sIniFileName: Имя INI файла. Если не определено то считется текущий файл.
      @return True/False
      }
      function SaveOptionValue(sSectionName: AnsiString; sOptionName: AnsiString; sValue: AnsiString; sIniFileName: AnsiString = ''): Boolean;

      {
      Загрузить текст из текстового файла.
      Связь с текстовыми файлами используется для вынесения многострочного текста
      за пределы INI файла.
      Текстовый файл должен находиться в той же папке что и INI файл.
      Загрузка производиться по сигнатуре MEMO:
      @param sTxtFileName: Полное имя текстового файла.
      @return: Текст, содержащийся внутри файла в виде строки
      или пустая строка в случае ошибки.
      }
      function ReadTxtFile(sTxtFileName: AnsiString): AnsiString;

      { Сохранить текстовый файл }
      function WriteTxtFile(sTxtFileName: AnsiString; sTxtContent: AnsiString): Boolean;

    published
      property INIFileName: AnsiString read FINIFileName;

    end;

implementation

uses
  logfunc, filefunc, strfunc;

constructor TIniDictionary.Create();
begin
  inherited Create;
end;

constructor TIniDictionary.Create(sINIFileName: AnsiString);
begin
  inherited Create;
  LoadIniFile(sINIFileName);
end;

destructor TIniDictionary.Destroy;
begin
  ClearContent(True);

  // ВНИМАНИЕ! Нельзя использовать функции Free.
  // Если объект создается при помощи Create, то удаляться из
  // памяти должен с помощью Dуstroy
  // Тогда не происходит утечки памяти
  inherited Destroy;
end;

{
Загрузить содержимое INI файла
}
function TIniDictionary.LoadIniFile(sINIFileName: AnsiString): Boolean;
var
  i_section, i_option, idx: Integer;
  ini_file: TIniFile;
  section_list: TStringList;
  option_list: TStringList;
  section_name, option, option_name, option_value: AnsiString;
  section_dict: TStrDictionary;

begin
  Result := False;
  if sIniFileName = '' then
  begin
    logfunc.WarningMsg('Не определен INI файл для загрузки данных');
    Exit;
  end;
  if not FileExists(sIniFileName) then
  begin
    logfunc.WarningMsgFmt('Файл INI <%s> не найден', [sIniFileName]);
    Exit;
  end;

  // Запомнить полное имя последнего открытого INI файла
  FINIFileName := sINIFileName;

  ini_file := TIniFile.Create(sIniFileName);

  // ВНИМАНИЕ! Перед использованием списков строк в функции
  // надо их создать/выделить под них память
  section_list := TStringList.Create;
  option_list := TStringList.Create;
  try
    try
      ini_file.ReadSections(section_list);
      for i_section :=0 to section_list.Count - 1 do
      begin
        section_name := section_list[i_section];
        section_dict := TStrDictionary.Create;

        option_list.Clear;
        ini_file.ReadSectionValues(section_name, option_list);
        for i_option :=0 to option_list.Count - 1 do
        begin
          option := Trim(option_list[i_option]);
          if AnsiStartsStr(';', option) then
            // Это коментарий обрабатывать не надо
            continue;
          idx := Pos('=', option);
          option_name := Copy(option, 0, idx - 1);
          option_value := Copy(option, idx + 1, Length(option) - idx);

          // Значение опции может начинаться с сигнатуры.
          // Такие случаи необходимо обрабатывать отдельно
          if strfunc.IsStartsWith(option_value, MEMO_SIGNATURE) then
          begin
            // Значение опции храниться в отдельном текстовом многострочном файле
            option_value := filefunc.ReadTxtFile(strfunc.ReplaceStart(option_value, MEMO_SIGNATURE, ''));
            logfunc.DebugMsgFmt('Чтение расширенной настройки <%s> - <%s>', [option_name, option_value]);
          end;

          section_dict.AddStrValue(option_name, option_value);
        end;
        AddObject(section_name, section_dict);
      end;
      Result := True;
    finally
      ini_file.Free;
    end;
  except
    logfunc.FatalMsg('Ошибка загрузки настроек программы');
  end;
  // ВНИМАНИЕ! В конце обязательно освободить память
  option_list.Destroy;
  section_list.Destroy;
end;

{
Записать содержимое INI файла
@param sINIFileName Полное наименование INI файла
@return True - запись прошла успешно / False - ошибка
}
function TIniDictionary.SaveIniFile(sINIFileName: AnsiString = ''): Boolean;
var
  i_section, i_option: Integer;
  ini_file: TIniFile;
  section_list: TStringList;
  option_list: TStringList;
  section_name, option_name, option_value: AnsiString;
  section_dict: TStrDictionary;
begin
  Result := False;

  if sIniFileName = '' then
    sIniFileName := FINIFileName;
  if sIniFileName = '' then
  begin
    logfunc.WarningMsg('Не определен INI файл для записи данных');
    Exit;
  end;

  ini_file := TIniFile.Create(sIniFileName);

  try
    // Перебор по секциям
    section_list := GetKeys();
    for i_section :=0 to section_list.Count - 1 do
    begin
      section_name := section_list[i_section];
      section_dict := GetByName(section_name) As TStrDictionary;

      // Перебор по опциям
      option_list := section_dict.GetKeys();
      for i_option := 0 to option_list.Count - 1 do
      begin
        option_name := option_list[i_option];
        option_value := section_dict.GetStrValue(option_name);
        ini_file.WriteString(section_name, option_name, option_value);
      end;
    end;
    Result := True;
  except
    logfunc.FatalMsg('Ошибка записи настроек программы');
  end;
  // Удалить объект
  ini_file.Free;

end;

{
Получить значение параметра
}
function TIniDictionary.GetOptionValue(sSectionName: AnsiString; sOptionName: AnsiString): AnsiString;
var
  section: TStrDictionary;
begin
  Result := '';
  if HasKey(sSectionName) then
  begin
    section := GetByName(sSectionName) As TStrDictionary;
    if section <> nil then
      Result := section.GetStrValue(sOptionName);
  end;
end;

{
Сохранить значение параметра
@param sSectionName Наименование секции
@param sOptionName Наименование параметра
@param sValue: Значение параметра в виде строки
@return True/False
}
function TIniDictionary.SetOptionValue(sSectionName: AnsiString; sOptionName: AnsiString; sValue: AnsiString): Boolean;
var
  section: TStrDictionary;
begin
  Result := False;
  if HasKey(sSectionName) then
  begin
    section := GetByName(sSectionName) As TStrDictionary;
    if section <> nil then
      Result := section.SetStrValue(sOptionName, sValue);
  end;

end;

{
Сохранить значение параметра в файле
@param sSectionName Наименование секции
@param sOptionName Наименование параметра
@param sValue: Значение параметра в виде строки
@param sIniFileName: Имя INI файла. Если не определено то считется текущий файл.
@return True/False
}
function TIniDictionary.SaveOptionValue(sSectionName: AnsiString; sOptionName: AnsiString; sValue: AnsiString; sIniFileName: AnsiString = ''): Boolean;
var
  ini_file: TIniFile;
begin
  Result := False;

  if sIniFileName = '' then
    sIniFileName := FINIFileName;
  if sIniFileName = '' then
  begin
    logfunc.WarningMsg('Не определен INI файл для записи данных');
    Exit;
  end;

  ini_file := nil;
  try
    ini_file := TIniFile.Create(sIniFileName);
    ini_file.WriteString(sSectionName, sOptionName, sValue);
    Result := True;
  except
    logfunc.FatalMsgFmt('Ошибка записи настройки программы <%s : %s : %s>', [sSectionName, sOptionName, sValue]);
  end;
  // Удалить объект
  if ini_file <> nil then
    ini_file.Free;

end;

{
Загрузить текст из текстового файла.
Связь с текстовыми файлами используется для вынесения многострочного текста
за пределы INI файла.
Текстовый файл должен находиться в той же папке что и INI файл.
Загрузка производиться по сигнатуре TXT:
@param sTxtFileName: Краткое имя текстового файла.
@return: Текст, содержащийся внутри файла в виде строки
или пустая строка в случае ошибки.
}
function TIniDictionary.ReadTxtFile(sTxtFileName: AnsiString): AnsiString;
var
  txt_filename: AnsiString;
  parent_path: AnsiString;

begin
  Result := '';

  if sTxtFileName = '' then
  begin
    logfunc.WarningMsg('Не определен текстовый файл многострочных данных');
    Exit;
  end;

  // Получить полное имя файла
  parent_path := ExtractFileDir(INIFileName);
  txt_filename := parent_path + PathDelim + sTxtFileName;

  if not FileExists(txt_filename) then
  begin
    logfunc.WarningMsgFmt('Текстовый файл многострочных данных <%s> не найден', [txt_filename]);
    Exit;
  end;

  Result := filefunc.ReadTxtFile(txt_filename);
end;

{ Сохранить текстовый файл }
function TIniDictionary.WriteTxtFile(sTxtFileName: AnsiString; sTxtContent: AnsiString): Boolean;
var
  txt_filename: AnsiString;
  parent_path: AnsiString;

begin
  Result := False;

  if sTxtFileName = '' then
  begin
    logfunc.WarningMsg('Не определен текстовый файл многострочных данных');
    Exit;
  end;

  // Получить полное имя файла
  parent_path := ExtractFileDir(INIFileName);
  txt_filename := parent_path + PathDelim + sTxtFileName;

  Result := filefunc.WriteTxtFile(txt_filename, sTxtContent);
end;

end.

