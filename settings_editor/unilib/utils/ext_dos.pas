{************************************************}
{                                                }
{   Extended dos unit                            }
{                                                }
{   Turbo Pascal 7                               }
{   FreePacal                                    }
{   Delphi 2 - 5                                 }
{   Virtual Pascal 2.1                           }
{                                                }
{   Copyright (c) 1995-2000 by Alexs             }
{                                                }
{************************************************}

{$I Define.inc}

unit Ext_Dos;

interface

uses Dos, Objects, Ext_Type, Ext_Sys;

const
  MaxOpenFiles        = 60;
const
   { Extended access modes }
  stCompatibilityMode         = $00;
  stExclusive                 = $10;
  stDenyWrite                 = $20;
  stDenyRead                  = $30;
  stDenyNone                  = $40;
  stPrivate                   = $80;

{$IFNDEF WIN32}
type
  PSystemDate = ^TSystemDate;
  TSystemDate = DateTime;
{$ENDIF}

const
  ListSeparator=';';
  {$ifdef OS_LINUX}
  DirSeparator : Char = '/';
  {$else}
  DirSeparator : Char = '\';
  {$endif}
  FindAttr = ReadOnly + Archive;
  {$ifdef linux}
  AllFiles = '*';
  {$else}
  AllFiles = '*.*';
  {$endif}
  PrevDir  = '..';

type
  TVolumeParamRecord = record
    InfoLevel:word;
    DiskSerialNumber:Longint;
    VolumeLabel:array[0..10] of char;
    FileSystem:array[0..7] of char;
  end;

type
  PTempStream = ^TTempStream;
  TTempStream = object(TDosStream)
    FileName:PString;
    constructor Init(AFileName:FNameStr);
    destructor Done;virtual;
  end;

const
  bufDelete = true;
  bufNotDel = false;
  inMemory = true;
  inDisk = false;


function PathValid(Path: PathStr): boolean;
function DriveValid(Drive: Char): Boolean;
function CurrentDrive: Char;
function CurrentDir(Drive: Char): String;

{file's routins}
function ValidFileName( FileName:FNameStr):boolean;
procedure BakUpFile( AName:FNameStr; BakExt:ExtStr; Del:Boolean );
function ReplaceExt(FileName: PathStr; NExt: ExtStr; Force: Boolean):PathStr;
// function FileExists(FileName: string): Boolean;
procedure DeleteFile(FName:FNameSTr);
function FileAttr(FileName:FNameStr):word;
function FileTime(FileName:FNameStr):Longint;
function TempStream(inMem:Boolean):PStream;
procedure CopyFile(S,D:FNameStr);
function ExtractPath(S:FNameStr):DirStr;
function ExtractName(S:FNameStr):NameStr;
function ExtractExt(S:FNameStr):ExtStr;
procedure FixupFName(var FName:FNameSTr; MaxLen:integer);
procedure ReduceFName(var FName:FNameSTr; MaxLen:integer);
function FNameReduce(FName:FNameSTr; MaxLen:integer):string;

{stream's method}
procedure WriteString(var S:TStream;Text:string);
function ReadString(var S:TStream):string;
procedure WriteText(var S:TStream;Text:string);
function ReadText(var S:TStream):string;

{application method's}
function CalcFileName( AEXEName:PathStr; AFileName:PathStr): PathStr;
function ExeName:string;
function ExePath:string;
function TempDir:string;
function GetTempStream:PStream;
function GetTempName(AName:FNameStr):FNameStr;

{date & time routins}
procedure GetDateTime(var D:DateTime);
function IsLeapYear(Year: Word): Boolean;
function DayOfWeek(Day, Month, Year: Integer) : Integer;
function DayOfWeekA(DateTime:TDateTime) : Integer;
function DayInMonth(Month, Year: Integer):integer;
function Date: TDateTime;
function Time: TDateTime;
function Now: TDateTime;
function IncMonth(const Date: TDateTime; NumberOfMonths: Integer): TDateTime;
function CurrentYear: Word;
function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;
procedure DecodeTime(Time: TDateTime; var Hour, Min, Sec, MSec: Word);
function EncodeDate(Year, Month, Day: Word): TDateTime;
procedure DecodeDate(Date: TDateTime; var Year, Month, Day: Word);
function DateToStr(D:TDateTime):string;
function TimeToStr(D:TDateTime):string;
function StrToDate(S:String):TDateTime;
function StrToTime(S:string):TDateTime;
function FormatDateTime(ADate:TDateTime; Format:string):string;

// procedure InitCountryEnvironment;

implementation

uses Strings, Ext_Math, Ext_Str, SysUtils

{$IFDEF WIN32}
,windows
{$ENDIF}
;
{$I Ext_dos.inc}

function GetTempName(AName:FNameStr):FNameStr;
var i:Longint;
    Dir: DirStr;
    Name: NameStr;
    Ext: ExtStr;
begin
  FSplit( AName, Dir, Name, Ext);
  i:=-1;
  repeat
    inc(i);
    AName:=Dir+IntToStr(i)+Ext;
  until (i>99999) or not FileExists(AName);
  GetTempName:=AName;
end;

constructor TTempStream.Init(AFileName:FNameStr);
begin
  inherited Init(AFileName, stCreate);
{$IFNDEF FPC}
  TDosStream.Done;
  TDosStream.Init(AFileName, stOpen or stExclusive or stPrivate);
{$ENDIF}
  FileName:=NewStr(AFileName);
end;

destructor TTempStream.Done;
var S:string;
begin
  S:=FileName^;
  DisposeStr(FileName);
  inherited Done;
{$IFNDEF VER120}
  DeleteFile(S);
{$ENDIF}
end;

function GetTempStream:PStream;
begin
  GetTempStream:=New(PTempStream, Init(GetTempName(TempDir+ExeName)));
end;

{*****************  CalcFileName *************************}
{ Принимает имя файла AEXEName и ищет в каталоге,         }
{   в котором находится AEXEName, файл AFileName.         }
{      Возвращает полный путь.                            }
{*********************************************************}
function CalcFileName( AEXEName:PathStr; AFileName:PathStr): PathStr;
var
  EXEName: PathStr;
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  if Lo(DosVersion) >= 3 then EXEName := ParamStr(0)
  else EXEName := FSearch(AEXEName, GetEnv('PATH'));
  FSplit(EXEName, Dir, Name, Ext);
  if Dir[Length(Dir)] = '\' then Dec(Dir[0]);
  CalcFileName := FSearch( AFileName, Dir);
end;


procedure BakUpFile(AName: FNameStr; BakExt: ExtStr; Del: Boolean);
var
  Name: FNameStr;
  NewS, OLdS: TBufStream;
begin
  if not FileExists(AName) then exit;
  Name := ReplaceExt(AName, BakExt, true);
  if Del then RenameFile(AName, Name)
  else
  begin
    NewS.Init(AName, stOpenRead, 2048);
    OldS.Init(Name, stCreate, 2048);
    OldS.CopyFrom(NewS, NewS.GetSize);
    NewS.Done;
    OldS.Done;
  end;
end;

function DriveValid(Drive: Char): Boolean;
begin
  DriveValid := ChUpCase(Drive) in ['A'..'Z']
end;

function CurrentDir(Drive: Char): String;
var 
  S: string;
begin
  GetDir(byte(Drive) - 64, S);
  CurrentDir := S;
end;

function CurrentDrive: Char;
var 
  S: string;
begin
  GetDir(0, S);
  CurrentDrive := S[1];
end;

function PathValid(Path: PathStr): boolean;
var
  ExpPath: PathStr;
  // DirInfo: SearchRec;
  DirInfo: TRawbyteSearchRec;
begin
  ExpPath := FExpand(Path);
  if Length(ExpPath) <= 3 then
     PathValid := (Length(ExpPath) > 1) and DriveValid(ExpPath[1])
  else
  begin
     if ExpPath[Length(ExpPath)] = '\' then dec(ExpPath[0]);
     FindFirst(ExpPath , Directory, DirInfo);
     PathValid := DosError = 0;
  end;
end;

function ValidFileName(FileName: FNameStr):boolean;
const
  IllegalChars = ';,=+<>|"[]';
var
  Dir: DirSTr;
  Name: NameSTr;
  Ext: ExtStr;

  function Contains(S1,S2:string):Boolean;
  var 
    i: integer;
  begin
    for i := 1 to Length(S2) do
      if Pos(S2[i], S1) <> 0 then
      begin
        Contains := true;
        exit;
      end;
    Contains := false;
  end;

begin
  ValidFileName := true;
  if not FileExists(FileName) then
  begin
     FSplit(FileName, Dir, Name, Ext);
     if not ((Dir = '') or PathValid(Dir)) or Contains(Name, IllegalChars + DirSeparator) or
        Contains(Dir, IllegalChars) then ValidFileName := false;
  end;
end;

{----- ReplaceExt(FileName, NExt, Force) -------------------------------}
{  Replace the extension of the given file with the given extension.    }
{  If the an extension already exists Force indicates if it should be   }
{  replaced anyway.                                                     }
{-----------------------------------------------------------------------}
function ReplaceExt(FileName: PathStr; NExt: ExtStr; Force: Boolean):
  PathStr;
var
  Dir: DirStr;
  Name: NameStr;
  Ext: ExtStr;
begin
  FileName := StUpCase(FileName);
  FSplit(FileName, Dir, Name, Ext);
  if Force or (Ext = '') then
    ReplaceExt := Dir + Name + NExt else
    ReplaceExt := FileName;
end;
{$IFNDEF WIN32}
{function FileExists(FileName: string): Boolean;
var
  F: file;
  Attr: Word;
begin
  Assign(F, FileName);
  GetFAttr(F, Attr);
  FileExists := DosError = 0;
end;}
{$ENDIF}

procedure WriteString(var S:TStream;Text:String);
var B:byte;
begin
  B:=Length(Text);
  S.Write(B,SizeOf(Byte));
  S.Write(Text[1], B);
end;

function ReadString(var S:TStream):string;
var
  AString:string;
  B:byte;
begin
  S.Read(B, SizeOf(Byte));
  SetLength(AString,B);
  S.Read(AString[1], B);
  ReadString:=AString;
end;

procedure DeleteFile(FName:FNameSTr);
var F:File;
begin
  if FileExists(FName) then
  begin
    Assign(F,FName);
    Erase(F);
  end
end;

procedure GetDateTime(var D:DateTime);
var
 Hour, Minute, Second, Sec100:word;
 Year, Month, Day, DayOfWeek:word;
begin
  GetTime(Hour, Minute, Second, Sec100);
  GetDate(Year, Month, Day, DayOfWeek);
  D.Hour:=Hour;
  D.Min:=Minute;
  D.Sec:=Second;
  D.Year:=Year;
  D.Month:=Month;
  D.Day:=Day;
end;

function FileAttr(FileName:FNameStr):word;
var
  f:file;
  Attr:word;
begin
  if FileExists(FileName) then
  begin
    Assign(F, FileName);
    GetFAttr(F, Attr);
    FileAttr:=Attr;
  end
  else FileAttr:=0;
end;

function FileTime(FileName:FNameStr):Longint;
var
  f:file;
  ftime:longint;
begin
  if FileExists(FileName) then
  begin
     Assign(f, FileName);
     GetFTime(f,ftime);
     FileTime:=ftime;
  end
  else FileTime:=0;
end;

function TempStream(inMem:Boolean):PStream;
begin
  if inMem then TempStream:=New(PMemoryStream,Init(2048,1024))
  else TempStream:=GetTempStream;
end;

procedure WriteText(var S:TStream;Text:string);
begin
  S.Write(Text[1],Length(Text));
  Text:=#13#10;
  S.Write(Text[1],Length(Text));
end;

function ReadText(var S:TStream):string;
var
  st:string;
  c:char;
begin
 st:='';
 S.Read(C,1);
 while ((C<>#13) and (C<>#10)) and (S.Status=stOk) do
 begin
  st:=st+c;
  S.Read(C,1);
 end;
 if C=#13 then S.Read(C,1);
 ReadText:=st;
end;

function ExeName:string;
var
  S1,S2,S3:ShortString;
begin
  FSplit(FExpand(ParamStr(0)),S1,S2,S3);
  ExeName:=S2;
end;

function ExePath:string;
var
  S1,S2,S3:Shortstring;
begin
  FSplit(FExpand(ParamStr(0)),S1,S2,S3);
  ExePath:=S1;
end;

{0 - воскресенье
 6 - субота}
{Month:
 1 - январь}
function DayOfWeek(Day, Month, Year: Integer) : Integer;
var
  century, yr, dw: Integer;
begin
  if Month < 3 then
  begin
    Inc(Month, 10);
    Dec(Year);
  end
  else
     Dec(Month, 2);
  century := Year div 100;
  yr := year mod 100;
  dw := (((26 * month - 2) div 10) + day + yr + (yr div 4) +
    (century div 4) - (2 * century)) mod 7;
  if dw < 0 then DayOfWeek := dw + 7
  else DayOfWeek := dw;
end;

function IsLeapYear(Year: Word): Boolean;
begin
  IsLeapYear:=(Year mod 4=0) and ((Year mod 100<>0) or (Year mod 400=0));
end;

function DayInMonth(Month, Year: Integer):integer;
begin
  DayInMonth:=DaysInMonth[Month] + Byte(IsLeapYear(Year) and (Month = 2));
end;

function Date: TDateTime;
var
  SystemTime:DateTime;
begin
  GetDateTime(SystemTime);
  with SystemTime do Date:=EncodeDate(Year, Month, Day);
end;

function Time: TDateTime;
var
  SystemTime:DateTime;
begin
  GetDateTime(SystemTime);
  with SystemTime do
       Time := EncodeTime(Hour, Min, Sec, 0);
end;

function Now: TDateTime;
begin
  Now := Date + Time;
end;

function IncMonth(const Date: TDateTime; NumberOfMonths: Integer): TDateTime;
var
  Year, Month, Day: Word;
  Sign: Integer;
begin
  if NumberOfMonths >= 0 then Sign := 1 else Sign := -1;
  DecodeDate(Date, Year, Month, Day);
  Year := Year + (NumberOfMonths div 12);
  NumberOfMonths := NumberOfMonths mod 12;
  Inc(Month, NumberOfMonths);
  if Word(Month-1) > 11 then   { // if Month <= 0, word(Month-1) > 11)}
  begin
    Inc(Year, Sign);
    Inc(Month, -12 * Sign);
  end;
  if Day > DayInMonth(Month,Year) then Day:=DayInMonth(Month,Year);
  IncMonth := EncodeDate(Year, Month, Day) + Frac(Date);
end;

function CurrentYear:Word;
var
  SystemTime:DateTime;
begin
  GetDateTime(SystemTime);
  CurrentYear:=SystemTime.Year;
end;

function EncodeTime(Hour, Min, Sec, MSec: Word): TDateTime;
begin
  if (Hour < 24) and (Min < 60) and (Sec < 60) and (MSec < 1000) then
     EncodeTime:=(Hour*3600000.0 + Min*60000.0 + Sec*1000.0 + MSec)/MSecsPerDay
  else EncodeTime:=0;
end;

procedure DecodeTime(Time: TDateTime; var Hour, Min, Sec, MSec: Word);
var
  L:Longint;
begin
  L:=Round(Frac(Time)*MSecsPerDay);
  Hour:=L div 3600000;
  L:=L mod 3600000;
  Min:=L div 60000;
  L:=L mod 60000;
  Sec:=L div 1000;
  MSec:=L mod 1000;
end;

function EncodeDate(Year, Month, Day: Word): TDateTime;
var
  I: Integer;
begin
  if (Year >= 0) and (Year <= 9999) and (Month >= 1) and (Month <= 12) and
    (Day >= 1) and (Day <= DayInMonth(Month,Year)) then
  begin
    for I := 1 to Month - 1 do Inc(Day, DayInMonth(I,Year));
    I:=Year - 1;
    EncodeDate:=I*365.0+I div 4 - I div 100 + I div 400 + Day - DateDelta;
  end
  else EncodeDate:=0;
end;

procedure DecodeDate(Date: TDateTime; var Year, Month, Day: Word);
const
  D1 = 365;
  D4 = D1 * 4 + 1;
  D100 = D4 * 25 - 1;
  D400 = D100 * 4 + 1;
var
  Y, M, D, I: Word;
  T: Longint;
begin
  T := Trunc(Date);
  begin
    Dec(T);
    T:=T+DateDelta;
    Y := 1;
    while T >= D400 do
    begin
      Dec(T, D400);
      Inc(Y, 400);
    end;
    I:=T div D100;
    D:=T mod D100;
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D100);
    end;
    Inc(Y, I * 100);
    I:=D div D4;
    D:=D mod D4;
    Inc(Y, I * 4);
    I:=D div D1;
    D:=D mod D1;
    if I = 4 then
    begin
      Dec(I);
      Inc(D, D1);
    end;
    Inc(Y, I);
    M := 1;
    while True do
    begin
      I := DayInMonth(M,Y);
      if D < I then Break;
      Dec(D, I);
      Inc(M);
    end;
    Year := Y;
    Month := M;
    Day := D + 1;
  end;
end;

function StrToDate(S:String):TDateTime;
var
  i:integer;
  Day, Month, Year:word;
  Century:word;
begin
  i:=Pos(DateSeparator,S);
  Day:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  i:=Pos(DateSeparator,S);
  Month:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  Year:=StrToInt(S);
  if ExpandDate and (Year<100) then
  begin
    Century:=(CurrentYear div 100) * 100;
    if TwoDigitYearCenturyWindow=0 then Year:=Century+Year
    else
    begin
      if Year<=TwoDigitYearCenturyWindow then Year:=Century+Year
      else Year:=Century+Year-100;
    end;
  end;
  StrToDate:=EncodeDate(Year, Month, Day);
end;

function StrToTime(S:string):TDateTime;
var
  Hour, Min, Sec, MSec: Word;
  i:integer;
begin
  i:=Pos(TimeSeparator,S);
  Hour:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  i:=Pos(TimeSeparator,S);
  Min:=StrToInt(Copy(S,1,i-1));
  Delete(S,1,i);
  Sec:=StrToInt(S);
  MSec:=0;
  StrToTime:=EncodeTime(Hour, Min, Sec, MSec);
end;

function DateToStr(D:TDateTime):string;
var Year, Month, Day: Word;
    S1,S2,S3:string[4];
    S4:string[10];
    I:integer;
begin
  DecodeDate(D, Year, Month, Day);
  if not ExpandDate then
  begin
    Year:=Year mod 100;
    Str(Year:2,S3);
  end
  else Str(Year:4,S3);
  Str(Month:2,S2);
  Str(Day, S1);
  S4:=S1+DateSeparator+S2+DateSeparator+S3;
  for i:=2 to Length(S4) do
      if S4[i]=' ' then S4[i]:='0';
  DateToStr:=S4;
end;

function TimeToStr(D:TDateTime):string;
var
  S1,S2,S3:string[2];
  Hour, Min, Sec, MSec: Word;
begin
  DecodeTime(D, Hour, Min, Sec, MSec);
  Str(Hour:2,S1);
  Str(Min:2, S2);
  if Min<10 then s2[1]:='0';
  Str(Sec:2, S3);
  if Sec<10 then S3[1]:='0';
  TimeToStr:=S1+TimeSeparator+S2+TimeSeparator+S3;
end;

function DayOfWeekA(DateTime:TDateTime) : Integer;
var Y,M,D:word;
begin
  DecodeDate(DateTime, Y,M,D);
  DayOfWeekA:=DayOfWeek(Y,M,D);
end;


procedure CopyFile(S, D: FNameStr);
var
  So, Dest: TDosStream;
  f: file;
  L: Longint;
begin
  if FileExists(S) then
  begin
    So.Init(S,stOpen);
    Dest.Init(D, stCreate);
    Dest.CopyFrom(So,So.GetSize);
    So.Done;
    Dest.Done;
  end;
  Assign(f, s);
  GetFTime(f, l);
  Assign(f, D);
  SetFTime(f, l);
end;

function ExtractPath(S:FNAmeStr):DirStr;
var Dir: DirStr;
    Name: NameStr;
    Ext: ExtStr;
begin
  FSplit(S,Dir,Name,Ext);
  ExtractPath:=Dir;
end;

function ExtractName(S:FNameStr):NameStr;
var Dir: DirStr;
    Name: NameStr;
    Ext: ExtStr;
begin
  FSplit(S,Dir,Name,Ext);
  ExtractName:=Name;
end;

function ExtractExt(S:FNameStr):ExtStr;
var Dir: DirStr;
    Name: NameStr;
    Ext: ExtStr;
begin
  FSplit(S,Dir,Name,Ext);
  ExtractExt:=Ext;
end;


function TempDir:string;
var s:string;
begin
  S:=GetEnv('TMP');
  if S='' then S:=GetEnv('TEMP');
  if (S<>'') and (S[Length(S)]<>'\') then S:=S+'\';
  TempDir:=S;
end;


function FormatDateTime(ADate:TDateTime; Format:string):string;
var 
  Count, CurPos:integer;
  CDay,CYear,CMonth, CHour, CMin, CSec, MSec:word;
  CurChar:char;

  function GetNextToken:Char;
  begin
    CurChar:=#0;
    while (CurPos<=length(Format)) and (Format[CurPos]<#33) do inc(CurPos);
    if CurPos<Length(Format) then
    begin
      CurChar:=Format[CurPos];
      Count:=1;
      while (CurPos+Count<=Length(Format)) and (Format[CurPos+count]=CurChar) do
        inc(Count);
    end;
    GetNextToken:=chLoCase(CurChar);
  end;
begin
  if Format='' then FormatDateTime:=DateToStr(ADate)
  else
  begin
    FormatDateTime := '';
    CurPos := 1;
    DecodeDate(ADate, CYear, CMonth, CDay);
    DecodeTime(ADate, CHour, CMin, CSec, MSec);
    while CurPos < Length(Format) do
    begin
      case GetNextToken of
        'd': case Count of
              1: FormatDateTime := FormatDateTime + IntToStr(CDay);
              2: if CDay < 10 then FormatDateTime := FormatDateTime + '0' + IntToStr(CDay)
                 else FormatDateTime := FormatDateTime + IntToStr(CDay);
              3,5: FormatDateTime := FormatDateTime + ShortDayNames[DayOfWeekA(ADate)];
              4,6: FormatDateTime := FormatDateTime + LongDayNames[DayOfWeekA(ADate)];
              {5..6 для совместимости с Дельфи}
             end;
        'm': case Count of
              1: FormatDateTime := FormatDateTime + IntToStr(CMonth);
              2: if CMonth < 10 then FormatDateTime := FormatDateTime + '0' + IntToStr(CMonth)
                 else FormatDateTime := FormatDateTime + IntToStr(CMonth);
              3: FormatDateTime := FormatDateTime + ShortMonthNames[CMonth];
              4: FormatDateTime := FormatDateTime + LongMonthNames[CMonth];
             end;
        'y': case Count of
              2: FormatDateTime := FormatDateTime + IntToStr(CYear mod 100);
              4: FormatDateTime := FormatDateTime + IntToStr(CYear);
             end;
        '/': FormatDateTime := FormatDateTime + DateSeparator;
        ':': FormatDateTime := FormatDateTime + TimeSeparator;
        's': if Count = 2 then
               if CSec < 10 then FormatDateTime := FormatDateTime + '0' + IntToStr(CSec)
               else FormatDateTime := FormatDateTime + IntToStr(CSec)
             else FormatDateTime := FormatDateTime + IntToStr(CSec);
        'n': if Count = 2 then
               if CMin < 10 then FormatDateTime := FormatDateTime + '0' + IntToStr(CMin)
               else FormatDateTime := FormatDateTime + IntToStr(CMin)
             else FormatDateTime := FormatDateTime + IntToStr(CMin);
        'h': if Count = 2 then
               if CHour < 10 then FormatDateTime := FormatDateTime + '0' + IntToStr(CHour)
               else FormatDateTime := FormatDateTime + IntToStr(CHour)
             else FormatDateTime := FormatDateTime + IntToStr(CHour);
        '''',
        '"': begin
               inc(CurPos);
               while (CurPos <= Length(Format)) and (Format[CurPos] <> CurChar) do
               begin
                 FormatDateTime := FormatDateTime + Format[CurPos];
                 inc(CurPos)
               end;
             end;
      end;
      Inc(CurPos, Count);
    end;
  end;
end;


procedure Cs0024(var DirName:DirSTr);
var
  FromRoot:Boolean;
  BackSpace:integer;
begin
  if DirName='\' then DirName:=''
  else
  begin
    if DirName[1]='\' then
    begin
      FromRoot:=true;
      DirName:=Copy(DirName,2,255);
    end
    else  FromRoot:=false;
    if DirName[1]='.' then DirName:=Copy(DirName,5,255);
    BackSpace:=Pos('\',DirName);
    if BackSpace<>0 then DirName:='...\'+Copy(DirName,BackSpace+1,255)
    else DirName:='';
    if FromRoot then DirName:='\'+DirName;
  end;
end;

procedure FixupFName(var FName:FNameStr; MaxLen:integer);
var
  Drive:string[3];
  Dir:DirSTr;
  NewDir:DirSTr;
  Name:NameSTr;
  Ext:ExtStr;
begin
  if FName='' then Exit;
  FSplit(FName,Dir,Name,Ext);
  Drive:='';
  if (Length(Dir)>2) and (Dir[2]=':') then
  begin
     if (Dir[1]='A') or (Dir[1]='B') then
         Dir:=''
     else
     begin
       NewDir:=CurrentDir(ChUpCase(FName[1]));
       if Length(NewDir)>3 then NewDir:=NewDir+'\';
       Dir:=Copy(Dir,3,255);
       NewDir:=Copy(NewDIr,3,255);
       if Compare(NewDir,Dir)=0 then Dir:=Copy(Dir,Length(NewDir)+1,255);
     end;
     if FName[1]<>CurrentDrive then Drive:=FName[1]+':';
  end;
  FName:=Drive+Dir+Name+Ext;
  ReduceFName(FName, MaxLen);
end;

procedure ReduceFName(var FName:FNameSTr; MaxLen:integer);
var
  Drive:string[3];
  Dir:DirSTr;
  Name:NameSTr;
  Ext:ExtStr;

begin
  FSplit(FName,Dir,Name,Ext);
  if Dir[2]=':' then
  begin
    Drive:=Copy(Dir,1,2);
    Dir:=Copy(Dir,3,255);
  end
  else Drive:='';
  while (Length(FName)>MaxLen) and ((Length(Dir)<>0)or (Length(Drive)<>0)) do
  begin
    if Dir='\...\' then
    begin
      Drive:='';
      Dir:='...\';
    end
    else
    if Dir='' then Drive:=''
    else Cs0024(Dir);
    FName:=Drive+Dir+Name+Ext;
  end;
end;

function FNameReduce(FName:FNameSTr; MaxLen:integer):string;
begin
 ReduceFName( FName, MaxLen);
 FNameReduce:=FName;
end;


end.
