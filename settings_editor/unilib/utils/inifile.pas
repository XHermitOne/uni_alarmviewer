{*******************************************************}
{                                                       }
{          Turbo Pascal 7.0                             }
{          FreePacal                                    }
{          Delphi 4                                     }
{       Access ini files                                }
{                                                       }
{       Copyright (c) 1995-98 by Alexs                  }
{                                                       }
{*******************************************************}

{$I Define.inc}

unit IniFile;

interface

uses Objects;

type
  PIniFile = ^TIniFile;
  TIniFile = object(TObject)
    private  
      FFileName: FNameStr;
      FModified: boolean;
      FList: PCollection;
      FLine: string;

    public
      constructor Init(FName: FNameStr);
      destructor Done; virtual;
      function CountItem(Section: string):integer;
      function ReadBoolean(Section, Name: string; Default: boolean): boolean;
      function ReadInteger(Section, Name: string; Default: integer): integer;
      function ReadString(Section, Name: string; Default: string): string;
      function ReadReal(Section, Name: string; Default: real): real;
      procedure WriteBoolean(Section, Name: string; Value: boolean);
      procedure WriteInteger(Section, Name: string; Value: integer);
      procedure WriteString(Section, Name: string; Value: string);
      procedure WriteReal(Section, Name: string; Value: real);
      procedure EraseSection(const Section: string);
      procedure DeleteKey(const Section, Ident: String);
  private
      function GetSection(Name: string; AutoCreate: boolean): PCollection;
      function GetParamName(Sect: PCollection; Name: string): Pointer;
      function ReadHeader(S: PStream): string;
      function ReadItem(S: PStream): Pointer;
      procedure UnGetLine(S: string);
{    function GetItem(Section,Name:string; AutoCreate:boolean): pointer;}
      function GetLine(S: PStream): string;

  public
      property IniFileName: FNameStr read FFileName;
      property IsModified: Boolean read FModified;
      //property List: PCollection read FList;
      //property Line: String read FLine;
  end;

function ApplicationIniFile:PIniFile;

implementation

uses Ext_Str, Ext_Math, SysUtils, Ext_Dos;

type
  PParamRec = ^TParamRec;
  TParamRec = record
     ParamName: string;
     ParamValue: string;
  end;

type
  PParamCollection = ^TParamCollection;
  TParamCollection = object(TCollection)
    NameSect: string;
    constructor Init(ANameSect: string);
    procedure FreeItem(Item: Pointer); virtual;
  end;


constructor TParamCollection.Init(ANameSect:string);
begin
  inherited Init(10,5);
  NameSect := ANameSect;
end;

procedure TParamCollection.FreeItem(Item: Pointer);
begin
  FreeMem(Item, SizeOf(TParamRec));
end;


constructor TIniFile.Init(FName: FNameStr);
var
  S: PBufStream;
  H: string;
  P: PParamCollection;
  Rec: PParamRec;
  TempStreamError: Pointer;
begin
  inherited Init;
  FList := New(PCollection,Init(10,5));
  FFileName := FName;
  S := New(PBufStream, Init(FFileName, stOpenRead, 2048));
  while S^.Status = stOk do
  begin
    TempStreamError := StreamError;
    StreamError := nil;
    H := ReadHeader(S);
    if S^.Status = stOk then
    begin
      P := New(PParamCollection, Init(H));
      FList^.Insert(P);
      Rec := ReadItem(S);
      while Rec <> nil do
      begin
        P^.Insert(rec);
        Rec := ReadItem(S);
      end;
    end;
    StreamError := TempStreamError;
  end;
  S^.Free;
end;

destructor TIniFile.Done;
var
  S: PBufStream;
  i: integer;
  
  procedure DoWriteSection(PCol: PParamCollection);
  var 
    i: integer;

    procedure DoWriteValue(Rec: PParamRec);
    begin
      WriteText(S^, Rec^.ParamName + '=' + Rec^.ParamValue);
    end;
  begin
    WriteText(S^, #13#10'[' + PCol^.NameSect + ']');
    for i := 0 to PCol^.Count - 1 do DoWriteValue(PCol^.At(i));
  end;

begin
  if FModified then
  begin
    S := New(PBufStream, Init(FFileName, stCreate, 2048));
    for i := 0 to FList^.Count - 1 do DoWriteSection(FList^.At(i));
    S^.Free;
  end;
  PObject(FList)^.Free;
  inherited Done;
end;

function TIniFile.ReadBoolean(Section, Name: string; Default: boolean): boolean;
var 
  P: PCollection;
  Rec: PParamRec;
begin
  ReadBoolean := Default;
  P := GetSection(Section, true);
  Rec := nil;
  if P <> nil then
    Rec := GetParamName(P,Name);
  if Rec <> nil then 
    ReadBoolean := (Rec^.ParamValue[1] = '1') or (chUpCase(Rec^.ParamValue[1]) = 'Y');
end;

function TIniFile.ReadInteger(Section, Name: string; Default: integer): integer;
var 
  P: PCollection;
  Rec: PParamRec;
begin
  ReadInteger := Default;
  P := GetSection(Section, true);
  Rec := nil;
  if P <> nil then 
    Rec := GetParamName(P, Name);
  if Rec <> nil then 
    ReadInteger := StrToInt(Rec^.ParamValue);
end;

function TIniFile.ReadString(Section, Name: string; Default: string): string;
var 
  P: PCollection;
  Rec: PParamRec;
begin
  ReadString := Default;
  P := GetSection(Section, true);
  Rec := nil;
  if P <> nil then 
    Rec := GetParamName(P, Name);
  if Rec <> nil then 
    ReadString := Rec^.ParamValue;
end;

function TIniFile.ReadReal(Section, Name: string; Default: real): real;
var 
  P: PCollection;
  Rec: PParamRec;
begin
  ReadReal := Default;
  P := GetSection(Section, true);
  Rec := nil;
  if P <> nil then 
    Rec := GetParamName(P, Name);
  if Rec <> nil then 
    ReadReal := StrToFloat(Rec^.ParamValue);
end;

procedure TIniFile.WriteBoolean(Section, Name: string; Value: boolean);
var 
  P: PCollection;
  Rec: PParamRec;
begin
  FModified := true;
  P := GetSection(Section, true);
  Rec := GetParamName(P, Name);
  if Rec = nil then
  begin
    GetMem(Rec, SizeOf(TParamRec));
    FillChar(Rec^, SizeOf(TParamRec), 0);
    P^.Insert(Rec);
    Rec^.ParamName := Name;
  end;
  Rec^.ParamValue := IntToStr(Byte(Value));
end;

procedure TIniFile.WriteInteger(Section, Name: string; Value: integer);
var 
  P: PCollection;
  Rec: PParamRec;
begin
  FModified := true;
  P := GetSection(Section, true);
  Rec := GetParamName(P, Name);
  if Rec = nil then
  begin
    GetMem(Rec, SizeOf(TParamRec));
    FillChar(Rec^, SizeOf(TParamRec), 0);
    P^.Insert(Rec);
    Rec^.ParamName := Name;
  end;
  Rec^.ParamValue := IntToStr(Value);
end;

procedure TIniFile.WriteString(Section, Name: string; Value: string);
var 
  P: PCollection;
  Rec: PParamRec;
begin
  FModified := true;
  P := GetSection(Section, true);
  Rec := GetParamName(P, Name);
  if Rec = nil then
  begin
    GetMem(Rec, SizeOf(TParamRec));
    FillChar(Rec^, SizeOf(TParamRec), 0);
    P^.Insert(Rec);
    Rec^.ParamName := Name;
  end;
  Rec^.ParamValue := Value;
end;

procedure TIniFile.WriteReal(Section, Name: string; Value: real);
var 
  P: PCollection;
  Rec: PParamRec;
begin
  FModified := true;
  P := GetSection(Section, true);
  Rec := GetParamName(P, Name);
  if Rec = nil then
  begin
    GetMem(Rec, SizeOf(TParamRec));
    FillChar(Rec^, SizeOf(TParamRec), 0);
    P^.Insert(Rec);
    Rec^.ParamName := Name;
  end;
  Rec^.ParamValue := FloatToStr(Value);
end;

procedure TIniFile.EraseSection(const Section: string);
var
  P: PCollection;
begin
  P := GetSection(Section, False);
  if P <> nil then
  begin
    FList^.Delete(P); { remove pointer from collection }
    FList^.FreeItem(P); { dispose of Item }
  end;
end;

procedure TIniFile.DeleteKey(const Section, Ident: String);
var
  P: PCollection;
  Rec: PParamRec;
begin
  P := GetSection(Section, true);
  Rec := GetParamName(P, Ident);
  if Rec <> nil then
  begin
    P^.Delete(Rec); { remove pointer from collection }
    P^.FreeItem(Rec); { dispose of Item }
  end;
end;

function TIniFile.GetSection(Name: string; AutoCreate: boolean): PCollection;
var
  i: integer;
  P: PCollection;
begin
  P := nil;
  for i := 0 to FList^.Count - 1 do
    if stUpCase(Name) = stUpCase(PParamCollection(FList^.At(i))^.NameSect) then
    begin
      GetSection := PParamCollection(FList^.At(i));
      exit;
    end;
  if AutoCreate then
  begin
     P := New(PParamCollection, Init(Name));
     PParamCollection(P)^.NameSect := Name;
     FList^.Insert(P);
  end;
  GetSection := P;
end;

function TIniFile.GetParamName(Sect: PCollection; Name: string): Pointer;
  function Test(Item: PParamRec): Boolean;
  begin
    Test := Item^.ParamName = Name;
  end;
var 
  i: integer;
begin
  GetParamName := nil;
  if Sect <> nil then
  begin
    for i := 0 to Sect^.Count - 1 do
      if Test(Sect^.At(i)) then
      begin
        GetParamName := Sect^.At(i);
        Exit;
      end;
  end;
end;

function TIniFile.GetLine(S: PStream): string;
begin
  if FLine <> '' then
  begin
    GetLine := FLine;
    FLine := ''
  end
  else GetLine := ReadText(S^);
end;

procedure TIniFile.UnGetLine(S: string);
begin
  FLine := S;
end;

function TIniFile.ReadHeader(S: PStream): string;
var
  st: string;
begin
  St := Trim(GetLine(S));
  while ((St = '') or (st[1] <> '[')) and (S^.Status = stOk) do St := Trim(ReadText(S^));
  if st <> '' then
  begin
    Delete(st, pos('[', st), 1);
    Delete(st, pos(']', st), 1);
  end;
  ReadHeader := St;
end;

function TIniFile.ReadItem(S: PStream): Pointer;
var
  Rec: PParamRec;
  st: string;
  C: byte;
begin
  ReadItem := nil;
  st := Trim(GetLine(S));
  while (S^.Status = stOk) and ((st = '') or (st[1] = ';')) do st := Trim(GetLine(S));
  if S^.Status <> stOk then exit;
  if st[1] <> '[' then
  begin
    C := Pos('=', st); 
    if c = 0 then exit;
    GetMem(Rec, SizeOf(TParamRec));
    FillChar(Rec^, SizeOf(TParamRec), 0);
    Rec^.ParamName := Copy(st, 1, c - 1);
    Rec^.ParamValue := Copy(st, c + 1, 255);
    ReadItem := Rec;
  end
  else UnGetLine(St);
end;

function TIniFile.CountItem(Section: string): integer;
var
  P: PCollection;
begin
  P := GetSection(Section, false);
  if P <> nil then CountItem := P^.Count
  else CountItem := 0;
end;

function ApplicationIniFile:PIniFile;
begin
  ApplicationIniFile := New(PIniFile, Init(ExePath + ExeName + '.ini'));
end;

end.
